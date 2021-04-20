
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

(* Name ["(" Expression | Type ")"] | Integer | "(" Expression ")" *)
Procedure Factor(Var T: tType);

Var 
  X: tObj;
Begin
  If Lex = lexName Then
    Begin
      Find(Name, X);
      If X^.Cat = catVar Then
        Begin
          T := X^.Typ;
          NextLex;
        End
      Else If X^.Cat = catConst Then
             Begin
               T := X^.Typ;
               NextLex;
             End
      Else If (X^.Cat = catStProc) And (X^.Typ <> typNone)
             Then
             Begin
               NextLex;
               Check(lexLPar, '"("');
               StFunc(X^.Val, T);
               Check(lexRPar, '")"');
             End
      Else
        Expected('variable, constant or procedure-function');
    End
  Else If Lex = lexNum Then
         Begin
           T := typInt;
           NextLex;
         End
  Else If Lex = lexLPar Then
         Begin
           NextLex;
           Expression(T);
           Check(lexRPar, '")"');
         End
  Else
    Expected('name, integer number or "("');
End;

(* Factor {MultDivModOperation Factor} *)
Procedure Term(Var T: tType);
Begin
  Factor(T);
  If Lex In [lexMult, lexDIV, lexMOD] Then
    Begin
      If T <> typInt Then
        Error(
        'The type of the operation is incompatible with the type of the operand'
        );
      Repeat
        NextLex;
        Factor(T);
        If T <> typInt Then
          Expected('integer expression');
      Until Not(Lex In [lexMult, lexDIV, lexMOD]);
    End;
End;


(* ["+" | "-"] Term {PlusMinusOperation Term} *)
Procedure SimpleExpr(Var T: tType);
Begin
  If Lex In [lexPlus, lexMinus] Then
    Begin
      NextLex;
      Term(T);
      If T <> typInt Then
        Expected('integer expression');
    End
  Else
    Term(T);
  If Lex In [lexPlus, lexMinus] Then
    Begin
      If T <> typInt Then
        Error(
        'The type of the operation is incompatible with the type of the operand'
        );
      Repeat
        NextLex;
        Term(T);
        If T <> typInt Then
          Expected('integer expression');
      Until Not(Lex In [lexPlus, lexMinus]);
    End;
End;

(* SimpleExpression [RelationalOperator SimpleExpression] *)
Procedure Expression(Var T: tType);
Begin
  SimpleExpr(T);
  If Lex In [lexEQ, lexNE, lexGT, lexGE, lexLT, lexLE]
    Then
    Begin
      If T <> typInt Then
        Error(
        'The type of the operation is incompatible with the type of the operand'
        );
      NextLex;
      SimpleExpr(T);
      If T <> typInt Then
        Expected('integer expression');
      T := typBool;
    End;
End;

(* ["+" | "-"] (Integer | Name) *)
Procedure ConstExpr(Var Value: integer);

Var 
  NameTableRecord: tObj;
  Operation: tLex;
Begin
  Operation := lexPlus;
  If Lex In [lexPlus, lexMinus] Then
    Begin
      Operation := Lex;
      NextLex;
    End;
  If Lex = lexNum Then
    Begin
      Value := Num;
      NextLex;
    End
  Else If Lex = lexName Then
         Begin
           Find(Name, NameTableRecord);
           If NameTableRecord^.Cat = catGuard Then
             Error('There is no way to define a constant through it itself' )
           Else If NameTableRecord^.Cat = catGuard Then
                  Expected('constant name')
           Else
             Value := NameTableRecord^.Val;
           NextLex;
         End
  Else
    Expected('constant expression');
  If Operation = lexMinus Then
    Value := -Value;
End;

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

(* Name {"," Name} ":" Type *)
Procedure VarDecl;

Var 
  NameRef: tObj;
Begin
  If Lex <> lexName Then
    Expected('name')
  Else
    Begin
      NewName(Name, catVar, NameRef);
      NameRef^.Typ := typInt; {Only integer is present}
      NextLex;
    End;
  While Lex = lexComma Do
    Begin
      NextLex;
      If Lex <> lexName Then
        Expected('name')
      Else
        Begin
          NewName(Name, catVar, NameRef);
          NameRef^.Typ := typInt; {Only integer is present}
          NextLex;
        End;
    End;
  Check(lexColon, '":"');
  ParseType;
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
