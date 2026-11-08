# I/O List

| Tag | Type | Description |
|---|---|---|
| `xStartPB` | DI | Start push button |
| `xStopPB` | DI | Stop push button |
| `xResetPB` | DI | Fault reset |
| `xEStopOK` | DI | E-stop circuit healthy (NC, TRUE = OK) |
| `xPartAtEntry` | DI | Photo sensor at infeed |
| `xSensorTypeA` | DI | Classification sensor (TRUE = type A) |
| `xSensorTypeB` | DI | Classification sensor (TRUE = type B) |
| `xPartAtDiverter` | DI | Photo sensor at diverter position |
| `xConveyorRun` | DO | Conveyor motor contactor / VFD run |
| `xDiverterA` | DO | Pneumatic diverter to bin A |
| `xDiverterB` | DO | Pneumatic diverter to bin B |
| `xLampRunning` | DO | Green lamp |
| `xLampFault` | DO | Red lamp |

Inputs are simulated with buttons on the CODESYS visualisation; no physical hardware is required.
