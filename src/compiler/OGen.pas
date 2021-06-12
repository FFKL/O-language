
Unit OGen;
{OVM code generator}

Interface

Uses OTable, OScan;

Var 
  PC: integer;

Procedure InitGen;
Procedure Gen(Cmd: integer);
Procedure GenConst(C: integer);
Procedure GenAbs;
Procedure GenMin;
Procedure GenMax;
Procedure GenOdd;
Procedure GenComp(Op: tLex);
Procedure GenAddr(X: tObj);
Procedure Fixup(A: integer);

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

Procedure GenConst(C: integer);
Begin
  Gen(abs(c));
  If C < 0 Then
    Gen(cmNeg);
End;

Procedure GenAbs;
Begin
  Gen(cmDup);
  Gen(0);
  Gen(PC + 3);
  Gen(cmIfGE);
  Gen(cmNeg);
End;

Procedure GenMin;
Begin
  Gen(MaxInt);
  Gen(cmNeg);
  Gen(1);
  Gen(cmSub);
End;

Procedure GenMax;
Begin
  Gen(MaxInt);
End;

Procedure GenOdd;

Const 
  TemporaryMemoryAddress = 0;
Begin
  Gen(2);
  Gen(cmMod);
  Gen(0);
  Gen(TemporaryMemoryAddress);
  Gen(cmIfEQ);
End;

Procedure GenComp(Op: tLex);

Const 
  TemporaryMemoryAddress = 0;
Begin
  Gen(TemporaryMemoryAddress);
  Case Op Of 
    lexEQ: Gen(cmIfNE);
    lexNE: Gen(cmIfEQ);
    lexLE: Gen(cmIfGT);
    lexLT: Gen(cmIfGE);
    lexGE: Gen(cmIfLT);
    lexGT: Gen(cmIfLE);
  End;
End;

Procedure GenAddr(X: tObj);
Begin
  Gen(X^.Val);
  X^.Val := PC + 1;
End;

Procedure Fixup(A: integer);

Var 
  temp: integer;
Begin
  While A > 0 Do
    Begin
      temp := M[A - 2];
      M[A - 2] := PC;
      A := temp;
    End;
End;

End.
