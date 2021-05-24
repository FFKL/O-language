
Unit OScan;

Interface

Const 
  NameLen = 31;

Type 
  tName = string[NameLen];
  tLex = (lexNone, lexName, lexNum,
          lexMODULE, lexIMPORT, lexBEGIN, lexEND,
          lexCONST, lexVAR, lexWHILE, lexDO, lexRETURN,
          lexIF, lexTHEN, lexELSIF, lexELSE, lexPROCEDURE,
          lexMult, lexDIV, lexMOD, lexPlus, lexMinus,
          lexEQ, lexNE, lexLT, lexLE, lexGT, lexGE,
          lexDot, lexComma, lexColon, lexSemi, lexAss,
          lexLpar, lexRpar,
          lexEOT);

Var 
  Lex: tLex;
  Name: tName;
  Num: integer;
  LexPos: integer;
Procedure InitScan;
Procedure NextLex;

Implementation

Uses OText, OError;

Const 
  KWNum = 34; {Table size}

Type 
  tKeyWord = string[9]; {PROCEDURE word length}

Var 
  nkw: integer; {Common key words amount}
  KWTable: array [1..KWNum] Of 
           Record
             Word: tKeyWord;
             Lex: tLex;
           End;

Procedure EnterKW(Name: tKeyWord; Lex: tLex);
Begin
  nkw := nkw + 1;
  KWTable[nkw].Word := Name;
  KWTable[nkw].Lex := Lex;
End;

Function TestKW: tLex;

Var 
  i: integer;
Begin
  i := nkw;
  While (i > 0) And (Name <> KWTable[i].Word) Do
    i := i - 1;
  If i > 0 Then
    TestKW := KWTable[i].Lex
  Else
    TestKW := lexName;
End;

Procedure InitScan;
Begin
  nkw := 0;

  EnterKW('ARRAY', lexNone);
  EnterKW('BY', lexNone);
  EnterKW('BEGIN', lexBEGIN);
  EnterKW('CASE', lexNone);
  EnterKW('CONST', lexCONST);
  EnterKW('DIV', lexDIV);
  EnterKW('DO', lexDO);
  EnterKW('ELSE', lexELSE);
  EnterKW('ELSIF', lexELSIF);
  EnterKW('END', lexEND);
  EnterKW('EXIT', lexNone);
  EnterKW('TOR', lexNone);
  EnterKW('IF', lexIF);
  EnterKW('IMPORT', lexIMPORT);
  EnterKW('IN', lexNone);
  EnterKW('IS', lexNone);
  EnterKW('LOOP', lexNone);
  EnterKW('MOD', lexMOD);
  EnterKW('MODULE', lexMODULE);
  EnterKW('NIL', lexNone);
  EnterKW('OF', lexNone);
  EnterKW('OR', lexNone);
  EnterKW('POINTER', lexNone);
  EnterKW('PROCEDURE', lexPROCEDURE);
  EnterKW('RECORD', lexNone);
  EnterKW('REPEAT', lexNone);
  EnterKW('RETURN', lexRETURN);
  EnterKW('THEN', lexTHEN);
  EnterKW('TO', lexNone);
  EnterKW('TYPE', lexNone);
  EnterKW('UNTIL', lexNone);
  EnterKW('VAR', lexVAR);
  EnterKW('WHILE', lexWHILE);
  EnterKW('WITH', lexNone);

  NextLex;
End;

Procedure Ident;

Var 
  i: integer;
Begin
  i := 0;
  Repeat
    If i < NameLen Then
      Begin
        i := i + 1;
        Name[i] := Ch;
      End
    Else
      Error('Long name');
    NextCh;
  Until Not(Ch In ['A'..'Z', 'a'..'z', '0'..'9']);
  Name[0] := chr(i);
  Lex := TestKW;
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

Procedure Comment;
Begin
  NextCh;
  Repeat
    While (Ch <> '*') And (Ch <> chEOT) Do
      If Ch = '(' Then
        Begin
          NextCh;
          If Ch = '*' Then Comment;
        End
      Else
        NextCh;
    If Ch = '*' Then
      NextCh;
  Until (Ch In [')', chEOT]);
  If Ch = ')' Then
    NextCh
  Else
    Begin
      LexPos := Pos;
      Error('Comment was not finished');
    End;
End;

Procedure NextLex;
Begin
  While Ch In [chSpace, chTab, chEOL] Do
    NextCh;
  LexPos := Pos;
  Case Ch Of 
    'A'..'Z', 'a'..'z':
                        Ident;
    '0'..'9':
              Number;
    ';':
         Begin
           NextCh;
           Lex := lexSemi;
         End;
    '.':
         Begin
           NextCh;
           Lex := lexDot;
         End;
    ',':
         Begin
           NextCh;
           Lex := lexComma;
         End;
    ':':
         Begin
           NextCh;
           If Ch = '=' Then
             Begin
               NextCh;
               Lex := lexAss;
             End
           Else
             Lex := lexColon;
         End;
    '=':
         Begin
           NextCh;
           Lex := lexEQ;
         End;
    '#':
         Begin
           NextCh;
           Lex := lexNE;
         End;
    '<':
         Begin
           NextCh;
           If Ch = '=' Then
             Begin
               NextCh;
               Lex := lexLE;
             End
           Else
             Lex := lexLT;
         End;
    '>':
         Begin
           NextCh;
           If Ch = '=' Then
             Begin
               NextCh;
               Lex := lexGE;
             End
           Else
             Lex := lexGT;
         End;
    '(':
         Begin
           NextCh;
           If Ch = '*' Then
             Begin
               Comment;
               NextLex;
             End
           Else Lex := lexLpar;
         End;
    ')':
         Begin
           NextCh;
           Lex := lexRpar;
         End;
    '+':
         Begin
           NextCh;
           Lex := lexPlus;
         End;
    '-':
         Begin
           NextCh;
           Lex := lexMinus;
         End;
    '*':
         Begin
           NextCh;
           Lex := lexMult;
         End;
    chEOT:
           Lex := lexEOT;
    Else Error('Unacceptable symbol');
  End;
End;

End.
