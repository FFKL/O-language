
Program O;

Uses OText, OPars, OScan, OTable;

Procedure Compile;
Begin
  InitNameTable;
  OpenScope;
  Enter('ABS', catStProc, typInt, spABS);
  Enter('MAX', catStProc, typInt, spMAX);
  Enter('MIN', catStProc, typInt, spMIN);
  Enter('DEC', catStProc, typNone, spDEC);
  Enter('ODD', catStProc, typBool, spODD);
  Enter('HALT', catStProc, typNone, spHALT);
  Enter('INC', catStProc, typNone, spINC);
  Enter('INTEGER', catType, typInt, 0);
  OpenScope;
  Module;
  CloseScope;
  CloseScope;
  WriteLn;
  WriteLn('Compilation is finished');
End;

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
