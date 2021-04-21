
Unit OGen;
{OVM code generator}

Interface

Var 
  PC: integer;

Procedure InitGen;
Procedure Gen(Cmd: integer);

Implementation

Uses OVM;

Procedure InitGen;
Begin
  PC := 0;
End;

Procedure Gen(Cmd: integer);
Begin
  M[PC] := Cmd;
  PC := PC + 1;
End;

End.
