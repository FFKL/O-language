
Unit OScan;

Interface

Const 
  NameLen = 31;

Type 
  tName = string[NameLen];
  tLex = (lexNone, lexName, lexNum,
          lexMODULE, lexIMPORT, lexBEGIN, lexEND,
          lexCONST, lexVAR, lexWHILE, lexDO,
          lexIF, lexTHEN, lexELSIF, lexELSE,
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
