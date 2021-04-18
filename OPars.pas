
Unit OPars;

Interface
Procedure Compile;
Procedure StatSeq;
forward;

Implementation

Uses OScan, OError;

Const 
  spABS = 1;
  spMAX = 2;
  spMIN = 3;
  spDEC = 4;
  spODD = 5;
  spHALT = 6;
  spINC = 7;
  spInOpen = 8;
  spInInt = 9;
  spOutInt = 10;
  spOutLn = 11;

Procedure Check(Target: tLex, Message: String);
Begin
  If Lex <> Target Then
    Expected(Message)
  Else
    NextLex;
End;

Procedure ImportModule;

Var 
  ImpRef: tObj;
Begin
  If Lex = lexName Then
    Begin
      NewName(Name, catModule, ImpRef);
      If Name = 'In' Then {Built-in 'In' module}
        Begin
          Enter('In.Open', catStProc, typNone, spInOpen);
          Enter('In.Int', catStProc, typNone, spInInt);
        End
      Else If Name = 'Out' Then {Built-in 'Out' module}
             Begin
               Enter('Out.Int', catStProc, typNone, spOutInt);
               Enter('Out.Ln', catStProc, typNone, spOutLn);
             End
      Else Error('Unknown module');
      NextLex;
    End
  Else
    Expected('imported module name');
End;

(* IMPORT Name {"," Name} ";" *)
Procedure Import;
Begin
  Check(lexIMPORT, 'IMPORT');
  ImportModule;
  While Lex = lexComma Do
    Begin
      NextLex;
      ImportModule;
    End;
  Check(lexSemi, '";"');
End;

(* ["+" | "-"] (Integer | Name) *)
Procedure ConstExpr(var Value: integer);
Var
  NameTableRecord: tObj;
  Operation: tLex;
begin
  Operation := lexPlus;
  if Lex in [lexPlus, lexMinus] then begin
    Operation := Lex;
    NextLex;
  end;
  if Lex = lexNum then begin
    Value := Num;
    NextLex;
    end
  else if Lex = lexName then begin
      Find(Name, NameTableRecord);
      if NameTableRecord^.Cat = catGuard then
        Error('There is no way to define a constant through it itself' )
      else if NameTableRecord^.Cat = catGuard then
        Expected('constant name')
      else
        Value := NameTableRecord^.Val;
      NextLex;
    end
  else
    Expected('constant expression');
  if Operation = lexMinus then
    Value := -Value;
end;

(* Name "=" ConstExpression *)
Procedure ConstDecl;

Var 
  ConstRef: tObj;
Begin
  NewName(Name, catGuard, ConstRef);
  NextLex;
  Check(lexEQ, '"="');
  ConstExpr(ConstRef^.Val);
  ConstRef^.Typ := typInt; {Only integer is present}
  ConstRef^.Cat := catConst;
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
            [BEGIN StatementsSequence] END Name "."  Check(lexSemi, '";"');
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

(* MODULE Name ";" [Import] DeclarationsSequence *)
(* [BEGIN StatementsSequence] END Name "." *)
Procedure Module;

Var 
  ModRef: tObj;
Begin
  Check(lexMODULE, 'MODULE');
  If Lex <> lexName Then
    Expected('module name')
  Else
    NewName(Name, catModule, ModRef);
  NextLex;
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
  If Lex <> lexName Then
    Expected('module name')
  Else If Name <> ModRef^.Name Then
         Expected('module name "' + ModRef^.Name + '"')
  Else
    NextLex;
  Check(lexDot, '"."');
End;

Procedure Compile;
Begin
  InitNameTable;
  OpenScope;
  Enter('ABS', catStProc, typInt, spABS);
  Enter('MAX', catStProc, typInt, spMAX);
  Enter('MIN', catStProc, typInt, spMIN);
  Enter('DEC', catStProc, typNone, spDEC);
  Enter('ODD', catStProc, typBool, spODD);
  Enter('HALT', catStProc, typNone, spHALT);
  Enter('INC', catStProc, typNone, spINC);
  Enter('INTEGER', catType, typInt, 0);
  OpenScope;
  Module;
  CloseScope;
  CloseScope;
  WriteLn;
  WriteLn('Compilation is finished');
End;
End.
