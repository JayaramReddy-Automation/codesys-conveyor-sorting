// DUT: E_PartType
// Result of the part classification at the infeed.

{attribute 'qualified_only'}
{attribute 'strict'}
TYPE E_PartType :
(
    NONE   := 0,  // No part being tracked
    TYPE_A := 1,  // Goes to bin A
    TYPE_B := 2,  // Goes to bin B
    REJECT := 3   // Unknown part (both or neither sensor), runs to reject bin
);
END_TYPE
