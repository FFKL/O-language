
Program O;

Uses OText, OPars, OScan, OVM, OGen;

Procedure Init;
Begin
  ResetText;
  InitScan;
  InitGen;
End;

Procedure Done;
Begin
  CloseText;
End;

Begin
  WriteLn('O compiler');
  Init;
  Compile;
  Run;
  Done;
End.
