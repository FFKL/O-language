
Unit AsmText;

Interface

Const 
  chSpace = ' ';
  chTab = chr(9);
  chEOL = chr(13);
  chEOT = chr(0);

Var 
  Ch: char;
  Pos: integer;
  Line: integer;

Procedure OpenText;
Procedure ResetText;
Procedure CloseText;
Procedure NextCh;
