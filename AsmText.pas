
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

Implementation

Uses OError;

Const 
  TabSize = 3;

Var 
  f: text;

Procedure OpenText;
Begin
  If ParamCount < 1 Then
    Begin
      Writeln('Call format:');
      Writeln ('   ОASM <input file>');
      Halt;
    End
  Else
    Begin
      Assign(f, ParamStr(1));
      {$i-}
      Reset(f);
      {$I+}
      If IOResult <> 0 Then
        Error('Input file was not found')
    End;
End;

Procedure ResetText;
Begin
  Reset(f);
  Pos := 0;
  Line := 1;
  NextCh;
End;

Procedure CloseText;
Begin
  Close(f);
End;

Procedure NextCh;
Begin
  If eof(f) Then
    Ch := chEOT
  Else If eoln(f) Then
         Begin
           ReadLn(f);
           WriteLn;
           Line := Line + 1;
           Pos := 0;
           Ch := chEOL;
         End
  Else
    Begin
      Read(f, Ch);
      If Ch <> chTab Then
        Begin
          Write(Ch);
          Pos := Pos + 1;
        End
      Else
        Repeat
          Write(' ');
          Pos := Pos + 1;
        Until Pos Mod TabSize = 0;
    End;
End;

End.
