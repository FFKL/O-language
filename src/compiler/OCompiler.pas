
Program OCompiler;

Uses OText, OPars, OScan, OVM, OGen, OBin;

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
  OBin.Generate;
  Done;
End.
