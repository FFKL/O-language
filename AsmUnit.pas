
Unit AsmUnit;

Interface

Procedure Assemble;

Implementation

Uses AsmText, AsmScan, AsmTable, OError, OVM;

Type 
  tLineProc = Procedure ;

Var 
  PC: integer;

Procedure Gen(Cmd: integer);
Begin
  If PC < MemSize Then
    Begin
      M[PC] := Cmd;
      PC := PC + 1;
    End
  Else
    Error('Memory size is exceeded');
End;

Procedure LineFirst;
Begin
  If Lex = lexLabel Then
    Begin
      NewName(PC);
      NextLex;
    End;
  If Lex In [lexName, lexNum, LexOpCode] Then
    Begin
      PC := PC + 1;
      NextLex;
    End;
End;

Procedure LineSecond;

Var 
  Addr: integer;
Begin
  If Lex = lexLabel Then
    NextLex;
  Case Lex Of 
    lexName:
             Begin
               Find(Addr);
               Gen(Addr);
               NextLex;
             End;
    lexNum:
            Begin
              Gen(Num);
              NextLex;
            End;
    lexOpCode:
               Begin
                 Gen(OpCode);
                 NextLex;
               End;
  End;
End;

Procedure Pass(Line: tLineProc);
Begin
  ResetText;
  NextLex;
  PC := 0;
  Line;
  While Lex = lexEOL Do
    Begin
      NextLex;
      Line;
    End;
  If Lex <> lexEOT Then
    Expected('end of text');
End;

Procedure Assemble;
Begin
  Pass(@LineFirst);
  Pass(@LineSecond);
  WriteLn;
  WriteLn('Compilation is finished');
  WriteLn('Code size ', PC);
  WriteLn;
End;

End.
