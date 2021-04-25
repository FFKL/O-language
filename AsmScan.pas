
Unit AsmScan;

Interface

Const 
  NameLen = 31;

Type 
  tName = string[NameLen];
  tLex = (
          lexLabel,
          lexOpCode,
          lexNum,
          lexName,
          lexEOL,
          lexEOT
         );

Var 
  Lex: tLex;
  Num: integer;
  OpCode: integer;
  Name: tName;
  LexPos: integer;

Procedure InitScan;
Procedure NextLex;
