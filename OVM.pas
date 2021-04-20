
Unit OVM; {O Virtual Machine}

Interface;

Const 
  MemSize = 8 * 1024;

  cmStop  = -1;
  {Arithmetic Commands}
  cmAdd   = -2;
  cmSub   = -3;
  cmMult  = -4;
  cmDiv   = -5;
  cmMod   = -6;
  cmNeg   = -7;
  {Memory Commands}
  cmLoad  = -8;
  cmSave  = -9;
  {Stack Commands}
  cmDup   = -10;
  cmDrop  = -11;
  cmSwap  = -12;
  cmOver  = -13;
  {Jump Commands}
  cmGOTO  = -14;
  cmIfEQ  = -15;
  cmIfNE  = -16;
  cmIfLE  = -17;
  cmIfLT  = -18;
  cmIfGE  = -19;
  cmIfGT  = -20;
  {I/O Commands}
  cmIn    = -21;
  cmOut   = -22;
  cmOutLn = -23;

Var 
  M: array [0..MemSize - 1] Of integer;

Procedure Run;
