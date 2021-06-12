
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


Implementation

Uses AsmText, OError, OVM;

Const 
  CmdNum = 23;

Type 
  tMnemo = string[5];

Var 
  cmd: integer;
  Code: array [1..CmdNum] Of integer;
  Mnemo: array [1..CmdNum] Of tMnemo;

Procedure EnterCode(Op: integer; Mn: tMnemo);
Begin
  cmd := cmd + 1;
  Code[cmd] := Op;
  Mnemo[cmd] := mn;
End;

Procedure TestOpCode;

Var 
  i: integer;
Begin
  i := CmdNum;
  While (i > 0) And (Mnemo[i] <> Name) Do
    i := i - 1;
  If i = 0 Then
    Lex := lexName
  Else
    Begin
      Lex := lexOpCode;
      OpCode := Code[i];
    End;
End;

Procedure Ident;

Var 
  i: integer;
Begin
  i := 0;
  Name := '';
  Repeat
    If i < NameLen Then
      Begin
        i := i + 1;
        Name[i] := Ch;
      End;
    NextCh;
  Until Not (Ch In ['A'..'Z', 'a'..'z', '0'..'9']);
  Name[0] := chr(i);
  If Ch = ':' Then
    Begin
      Lex := lexLabel;
      NextCh;
    End
  Else
    TestOpCode;
End;

Procedure Number;

Var 
  digit: integer;
Begin
  Lex := lexNum;
  Num := 0;
  Repeat
    digit := ord(Ch) - ord('0');
    If (Maxint - digit) Div 10 >= Num Then
      Num := 10 * Num + digit
    Else
      Error('Unsupported number size.');
    NextCh;
  Until Not (Ch In ['0'..'9']);
End;

Procedure NextLex;
Begin
  While Ch In [' ', chTab] Do
    NextCh;
  LexPos := Pos;
  Case Ch Of 
    'A'..'Z', 'a'..'z':
                        Ident;
    '0'..'9':
              Number;
    ';':
         Begin
           While (Ch <> ChEOL) And (Ch <> chEOT) Do
             NextCh;
           NextLex;
         End;
    chEOL:
           Begin
             Lex := lexEOL;
             NextCh;
           End;
    chEOT:
           Lex := lexEOT;
    Else
      Error('Unacceptable symbol')
  End;
End;

Procedure InitScan;
Begin
  cmd := 0;
  EnterCode(cmStop, 'STOP');
  EnterCode(cmAdd, 'ADD');
  EnterCode(cmSub, 'SUB');
  EnterCode(cmMult, 'MULT');
  EnterCode(cmDIV, 'DIV');
  EnterCode(cmMOD, 'MOD');
  EnterCode(cmNeg, 'NEC');
  EnterCode(cmDup, 'DUP');
  EnterCode(cmDrop, 'DROP');
  EnterCode(cmSwap, 'SWAP');
  EnterCode(cmOver, 'OVER');
  EnterCode(cmLoad, 'LOAD');
  EnterCode(cmSave, 'SAVE');
  EnterCode(cmGoto, 'GOTO');
  EnterCode(cmIfEQ, 'IFEQ');
  EnterCode(cmIfNE, 'IFNE');
  EnterCode(cmIfLE, 'IFLE');
  EnterCode(cmIfLT, 'IFLT');
  EnterCode(cmIfGE, 'IFGE');
  EnterCode(cmIfGT, 'IFGT');
  EnterCode(cmIn, 'IN');
  EnterCode(cmOut, 'OUT');
  EnterCode(cmOutLn,'OUTLN');
End;

End.
