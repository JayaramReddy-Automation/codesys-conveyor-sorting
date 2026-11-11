// =====================================================================
// POU: PLC_PRG (Program, Structured Text)
// Conveyor sorting station - main state machine
//
// Sequence: IDLE -> RUNNING -> CLASSIFYING -> TRANSPORT -> DIVERTING -> RUNNING
// Faults:   jam timeout -> FAULT, E-stop -> ESTOP (both need reset, then start)
//
// Note: the real E-stop is a hardwired safety circuit. The PLC only
// monitors it (xEStopOK) to stop the sequence and show the state.
// =====================================================================

// ---------------- DECLARATION (top pane in CODESYS) ----------------
PROGRAM PLC_PRG
VAR
    eState            : E_ConveyorState := E_ConveyorState.IDLE;
    ePartType         : E_PartType := E_PartType.NONE;
    xStopRequest      : BOOL;     // Stop pressed: finish the current part, then stop

    // Edge detection
    rtStart           : R_TRIG;
    rtReset           : R_TRIG;
    rtPartAtEntry     : R_TRIG;
    rtPartAtDiverter  : R_TRIG;

    // Timers
    tonJam            : TON;      // Part must reach the diverter within T_JAM_TIMEOUT
    tonDivert         : TON;      // Length of the diverter pulse
    tonBlink          : TON;      // Blink clock for the fault lamp
    xBlink            : BOOL;

    // Production counters (read later by the OPC UA data logger)
    udiCountA         : UDINT;
    udiCountB         : UDINT;
    udiCountReject    : UDINT;
    udiCountJams      : UDINT;
END_VAR
VAR CONSTANT
    T_JAM_TIMEOUT     : TIME := T#5S;
    T_DIVERT_PULSE    : TIME := T#500MS;
    T_BLINK           : TIME := T#500MS;
END_VAR

// ---------------- IMPLEMENTATION (bottom pane in CODESYS) ----------------

// ---- Edge detection ----
rtStart(CLK := GVL_IO.xStartPB);
rtReset(CLK := GVL_IO.xResetPB);
rtPartAtEntry(CLK := GVL_IO.xPartAtEntry);
rtPartAtDiverter(CLK := GVL_IO.xPartAtDiverter);

// ---- Timers (called every scan, outside the CASE) ----
tonJam(IN := (eState = E_ConveyorState.TRANSPORT), PT := T_JAM_TIMEOUT);
tonDivert(IN := (eState = E_ConveyorState.DIVERTING), PT := T_DIVERT_PULSE);
tonBlink(IN := NOT tonBlink.Q, PT := T_BLINK);
IF tonBlink.Q THEN
    xBlink := NOT xBlink;
END_IF

// ---- E-stop has priority over every state ----
IF NOT GVL_IO.xEStopOK THEN
    eState := E_ConveyorState.ESTOP;
END_IF

// ---- Stop request is latched and handled by the states ----
IF GVL_IO.xStopPB THEN
    xStopRequest := TRUE;
END_IF

// ---- State machine ----
CASE eState OF

    E_ConveyorState.IDLE:
        xStopRequest := FALSE;
        ePartType := E_PartType.NONE;
        IF rtStart.Q AND GVL_IO.xEStopOK THEN
            eState := E_ConveyorState.RUNNING;
        END_IF

    E_ConveyorState.RUNNING:
        IF xStopRequest THEN
            eState := E_ConveyorState.IDLE;
        ELSIF rtPartAtEntry.Q THEN
            eState := E_ConveyorState.CLASSIFYING;
        END_IF

    E_ConveyorState.CLASSIFYING:
        // Exactly one sensor must be active, otherwise the part is rejected
        IF GVL_IO.xSensorTypeA AND NOT GVL_IO.xSensorTypeB THEN
            ePartType := E_PartType.TYPE_A;
        ELSIF GVL_IO.xSensorTypeB AND NOT GVL_IO.xSensorTypeA THEN
            ePartType := E_PartType.TYPE_B;
        ELSE
            ePartType := E_PartType.REJECT;
        END_IF
        eState := E_ConveyorState.TRANSPORT;

    E_ConveyorState.TRANSPORT:
        IF rtPartAtDiverter.Q THEN
            eState := E_ConveyorState.DIVERTING;
        ELSIF tonJam.Q THEN
            udiCountJams := udiCountJams + 1;
            eState := E_ConveyorState.FAULT;
        END_IF

    E_ConveyorState.DIVERTING:
        IF tonDivert.Q THEN
            CASE ePartType OF
                E_PartType.TYPE_A:
                    udiCountA := udiCountA + 1;
                E_PartType.TYPE_B:
                    udiCountB := udiCountB + 1;
            ELSE
                udiCountReject := udiCountReject + 1;
            END_CASE
            ePartType := E_PartType.NONE;

            IF xStopRequest THEN
                eState := E_ConveyorState.IDLE;
            ELSE
                eState := E_ConveyorState.RUNNING;
            END_IF
        END_IF

    E_ConveyorState.FAULT:
        // Operator clears the jam, then presses reset
        IF rtReset.Q THEN
            eState := E_ConveyorState.IDLE;
        END_IF

    E_ConveyorState.ESTOP:
        // E-stop must be released AND reset pressed; no automatic restart
        IF GVL_IO.xEStopOK AND rtReset.Q THEN
            eState := E_ConveyorState.IDLE;
        END_IF

END_CASE

// ---- Outputs: written in one place only ----
GVL_IO.xConveyorRun := (eState = E_ConveyorState.RUNNING)
                    OR (eState = E_ConveyorState.CLASSIFYING)
                    OR (eState = E_ConveyorState.TRANSPORT)
                    OR (eState = E_ConveyorState.DIVERTING);

GVL_IO.xDiverterA   := (eState = E_ConveyorState.DIVERTING) AND (ePartType = E_PartType.TYPE_A);
GVL_IO.xDiverterB   := (eState = E_ConveyorState.DIVERTING) AND (ePartType = E_PartType.TYPE_B);

GVL_IO.xLampRunning := GVL_IO.xConveyorRun;
GVL_IO.xLampFault   := (eState = E_ConveyorState.FAULT)
                    OR ((eState = E_ConveyorState.ESTOP) AND xBlink);
