// GVL: GVL_IO
// Inputs and outputs of the sorting station.
// In this project they are driven by the CODESYS visualisation (simulation).
// On real hardware each variable would be mapped to a physical channel
// in the I/O configuration of the fieldbus device.

{attribute 'qualified_only'}
VAR_GLOBAL
    // ---- Digital inputs ----
    xStartPB         : BOOL;          // Start push button (TRUE = pressed)
    xStopPB          : BOOL;          // Stop push button (TRUE = pressed)
    xResetPB         : BOOL;          // Fault reset push button
    xEStopOK         : BOOL := TRUE;  // E-stop circuit healthy (NC contact, TRUE = OK)
    xPartAtEntry     : BOOL;          // Photo sensor at the infeed
    xSensorTypeA     : BOOL;          // Classification sensor, TRUE = type A
    xSensorTypeB     : BOOL;          // Classification sensor, TRUE = type B
    xPartAtDiverter  : BOOL;          // Photo sensor at the diverter position

    // ---- Digital outputs ----
    xConveyorRun     : BOOL;          // Conveyor motor contactor / VFD run command
    xDiverterA       : BOOL;          // Pneumatic diverter to bin A
    xDiverterB       : BOOL;          // Pneumatic diverter to bin B
    xLampRunning     : BOOL;          // Green lamp
    xLampFault       : BOOL;          // Red lamp (steady = jam, blinking = E-stop)
END_VAR
