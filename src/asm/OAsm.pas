
Program OASM;
{OVM assembler}

Uses AsmText, AsmScan, AsmTable, AsmUnit, OVM, OBin;

Procedure Init;
Begin
  AsmTable.InitNameTable;
  AsmText.OpenText;
  AsmScan.InitScan
End;

Procedure Done;
Begin
  AsmText.CloseText;
End;

Begin
  WriteLn('OVM assembler');
  Init;
  AsmUnit.Assemble;
  OBin.Generate;
  Done;
End.
