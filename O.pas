
Program O;

Uses OText, OPars;

Procedure Init;
Begin
  ResetText;
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
