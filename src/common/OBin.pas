
Unit OBin;

Interface

Procedure Generate;
Procedure Load;

Implementation

Uses OVM, OError;

Const 
  DefaultFilename = 'out';

Procedure Generate;

Var 
  binFile: File Of integer;
  currCmd: integer;
Begin
  Assign(binFile, DefaultFilename);
  ReWrite(binFile);
  For currCmd := 0 To (PC - 1) Do
    Write(binFile, M[currCmd]);
  Close(binFile);
End;


Procedure Load;

Var 
  binFile: File Of integer;
  cmd: integer;
  loaderPC: integer;
Begin
  If ParamCount < 1 Then
    Begin
      Writeln('Call format:');
      Writeln ('   О <input file>');
      Halt;
    End;
  loaderPC := 0;
  Assign(binFile, ParamStr(1));
  {$i-}
  Reset(binFile);
  {$i+}
  If IOResult <> 0 Then
    {TODO: use special error}
    Error('Input file was not found');
  While Not eof(binFile) 
    Do
    Begin
      Read(binFile, cmd);
      M[loaderPC] := cmd;
      loaderPC := loaderPC + 1
    End;
  Close(binFile);
End;

End.
