// DUT: E_ConveyorState
// States of the conveyor sorting station.
// Numbering in steps of 10 leaves room for new states later.

{attribute 'qualified_only'}
{attribute 'strict'}
TYPE E_ConveyorState :
(
    IDLE        := 0,   // Conveyor stopped, waiting for start
    RUNNING     := 10,  // Conveyor running, waiting for a part at the infeed
    CLASSIFYING := 20,  // Part detected, reading classification sensors
    TRANSPORT   := 30,  // Part travelling to the diverter, jam timer active
    DIVERTING   := 40,  // Diverter pulse active, part counted at the end
    FAULT       := 90,  // Jam detected, conveyor stopped, waiting for reset
    ESTOP       := 99   // E-stop active, all outputs off
);
END_TYPE
