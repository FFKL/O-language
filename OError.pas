
Unit OError;

Interface
Procedure Error(Msg: String);
Procedure Expected(Msg: String);
Procedure Warning(Msg: String);

Implementation

Uses 
OText, OScan;
Procedure Error(Msg: String);

Var 
  ELine: integer;
Begin
  ELine := Line;
  While (Ch <> chEOL) And (Ch <> chEOT) Do
    NextCh;
  If Ch = chEOT Then WriteLn;
  WriteLn('^': LexPos);
  Writeln ('(Line ', ELine, ') Error: ', Msg);
  WriteLn;
  WriteLn('Press ENTER');
  Readln;
  Halt;
End;
Procedure Expected(Msg: String);
Begin
  Error('Expected ', Msg);
End;
Procedure Warning(Msg : String);
Begin
  WriteLn;
  Writeln('Warning: ', Msg);
  WriteLn;
End;
End.
