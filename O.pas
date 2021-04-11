
Program O;

Uses OText, OPars, OScan;

Procedure Init;
Begin
  ResetText;
  InitScan;
End;

Procedure Done;
Begin
  CloseText;
End;

Begin
  WriteLn('O compiler');
  Init;
  Compile;
  Done;
End.
