
Unit OPars;

Interface
Procedure Compile;
Procedure StatSeq;
forward;

Implementation

Uses OScan, OError;

Procedure Check(Target: tLex, Message: String);
Begin
  If Lex <> Target Then
    Expected(Message)
  Else
    NextLex;
End;

(* IMPORT Name {"," Name} ";" *)
Procedure Import;
Begin
  Check(lexIMPORT, 'IMPORT');
  Check(lexName, 'module name');
  While Lex = lexComma Do
    Begin
      NextLex;
      Check(lexName, 'module name');
    End;
  Check(lexSemi, '";"');
End;

(* {CONST {ConstantsDeclaration ";"} | VAR{VariablesDeclaration ";"}} *)
Procedure DeclSeq;
Begin
  While Lex In [lexCONST, lexVAR] Do
    Begin
      If Lex = lexCONST Then
        Begin
          NextLex;
          While Lex = lexName Do
            Begin
              ConstDecl;
              Check(lexSemi, '";"');
            End;
        End
      Else
        Begin
          NextLex;
          While Lex = lexName Do
            Begin
              VarDecl;
              Check(lexSemi, '";"');
            End;
        End;
    End;
End;

(* Statement {";" Statement} *)
Procedure StatSeq;
Begin
  Statement;
  While Lex = lexSemi Do
    Begin
      NextLex;
      Statement;
    End;
End;

(* Factor {MulOperator Factor} *)
Procedure Term;
Begin
  Factor;
  While Lex In [lexMult, lexDIV, lexMOD] Do
    Begin
      NextLex;
      Factor;
    End;
End;

(* MODULE Name ";" [Import] DeclarationsSequence [BEGIN StatementsSequence] END Name "." *)
Procedure Module;
Begin
  Check(lexMODULE, 'MODULE');
  Check(lexName, 'module name');
  Check(lexSemi, '";"');
  If Lex = lexIMPORT Then
    Import;
  DeclSeq;
  If Lex = lexBEGIN Then
    Begin
      NextLex;
      StatSeq;
    End;
  Check(lexEND, 'END');
  Check(lexName, 'module name');
  Check(lexDot, '"."');
End;

Procedure Compile;
Begin
  Module;
  WriteLn('Program compiled');
End;
End.
