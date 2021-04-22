
Unit OPars;

Interface
Procedure Compile;
Procedure StatSeq;
forward;

Implementation

Uses OScan, OError, OGen;

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

Procedure IntExpression;

Var 
  T: tType;
Begin
  Expression(T);
  If T <> typInt Then
    Expected('integer expression');
End;

Procedure BoolExpression;

Var 
  T: tType;
Begin
  Expression(T);
  If T <> typBool Then
    Expected('boolean expression');
End;

Procedure StFunc(F: integer; Var T: tType);
Begin
  Case F Of 
    spABS:
           Begin
             IntExpression;
             GenAbs;
             T := typInt;
           End;
    spMAX:
           Begin
             ParseType;
             GenMax;
             T := typInt;
           End;
    spMin:
           Begin
             ParseType;
             GenMin;
             T := typInt;
           End;
    spODD:
           Begin
             IntExpression;
             GenOdd;
             T := typBool;
           End;
  End;
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

Procedure Statement;

Var :
      X: tObj;
Begin
  If Lex = lexName Then
    Begin
      Find(Name, X);
      If X^.Cat = catModule Then
        Begin
          NextLex;
          Check(lexDot, '"."');
          If (Lex = lexName) And (Length(X^.Name) + Length(Name) < NameLen)
            Then
            Find(X^.Name + '.' + Name, X)
          Else
            Expected('name from module ' + X^.Name);
        End;
      If X^.Cat = catVar Then
        AssignmentStatement
      Else If (X^.Cat = catStProc) And (X^.Typ = typNone)
             Then
             CallStatement(X^.Val)
      Else
        Expected('variable or procedure designation');
    End
  Else If Lex = lexIF Then
         IfStatement
  Else If Lex = lexWHILE Then
         WhileStatement
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
          GenAddr(X);
          Gen(cmLoad);
          T := X^.Typ;
          NextLex;
        End
      Else If X^.Cat = catConst Then
             Begin
               GenConst(X^.Val);
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
           GenConst(Num);
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

Var 
  Op: tLex;
Begin
  Factor(T);
  If Lex In [lexMult, lexDIV, lexMOD] Then
    Begin
      If T <> typInt Then
        Error(
        'The type of the operation is incompatible with the type of the operand'
        );
      Repeat
        Op := Lex;
        NextLex;
        Factor(T);
        If T <> typInt Then
          Expected('integer expression');
        Case Op Of 
          lexMult: Gen(cmMult);
          lexDIV: Gen(cmDIV);
          lexMOD: Gen(cmMOD);
        End;
      Until Not(Lex In [lexMult, lexDIV, lexMOD]);
    End;
End;


(* ["+" | "-"] Term {PlusMinusOperation Term} *)
Procedure SimpleExpr(Var T: tType);

Var 
  Op: tLex;
Begin
  If Lex In [lexPlus, lexMinus] Then
    Begin
      Op := Lex;
      NextLex;
      Term(T);
      If T <> typInt Then
        Expected('integer expression');
      If Op = lexMinus Then
        Gen(cmNeg);
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
        Op := Lex;
        NextLex;
        Term(T);
        If T <> typInt Then
          Expected('integer expression');
        Case Op Of 
          lexPlus:  Gen(cmAdd);
          lexMinus: Gen(cmSub);
        End;
      Until Not(Lex In [lexPlus, lexMinus]);
    End;
End;

(* SimpleExpression [RelationalOperator SimpleExpression] *)
Procedure Expression(Var T: tType);

Var 
  Op: tLex;
Begin
  SimpleExpr(T);
  If Lex In [lexEQ, lexNE, lexGT, lexGE, lexLT, lexLE]
    Then
    Begin
      Op := Lex;
      If T <> typInt Then
        Error(
        'The type of the operation is incompatible with the type of the operand'
        );
      NextLex;
      SimpleExpr(T);
      If T <> typInt Then
        Expected('integer expression');
      GenComp(Op);
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
