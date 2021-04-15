
Unit OPars;

Interface
Procedure Compile;

Implementation

Uses OScan;
Procedure Compile;

Var lexAmount: integer;
Begin
{TODO: replace the demo procedure with a real implementation}
  lexAmount := 0;
  While Lex <> lexEOT Do
    Begin
      lexAmount := lexAmount + 1;
      NextLex;
    End;
  WriteLn('Lexems amount - ', lexAmount);
End;
End.
