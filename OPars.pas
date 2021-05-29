
Unit OPars;

Interface
Procedure Compile;
Procedure StatSeq;

Implementation

Uses OScan, OError, OGen, OTable, OVM;

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

Var 
  CurrProcedure: tObj;
  ReturnLastGOTO: Integer;

Procedure Expression(Var T: tType);
Forward;

Procedure ParseType;

Var 
  TypeRef: tObj;
Begin
  If Lex <> lexName Then
    Expected('name')
  Else
    Begin
      Find(Name, TypeRef);
      If TypeRef^.Cat <> catType Then
        Expected('type name')
      Else If TypeRef^.Typ <> typInt Then
             Expected('integer type');
      NextLex;
    End;
End;

Procedure Check(Target: tLex; Message: String);
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

(* Variable = Name. *)
Procedure Variable(Var X: tObj);
Begin
  If Lex <> lexName Then
    Expected('name')
  Else
    Begin
      Find(Name, X);
      If X^.Cat = catVar Then
        GenAddr(X)
      Else If X^.Cat = catLVar Then
             Begin
               Gen(X^.Val);
               Gen(cmLLoad);
             End
      Else If X^.Cat = catLVal Then
             Gen(X^.Val)
      Else
        Expected('variable name');
      NextLex;
    End;
End;

(* Variable ":=" Expression *)
Procedure AssignmentStatement;

Var 
  TargetVar: tObj;
Begin
  Variable(TargetVar);
  If Lex = lexAss Then
    Begin
      NextLex;
      IntExpression;
      If TargetVar^.Cat = catVar Then
        Gen(cmSave)
      Else If TargetVar^.Cat = catLVar Then
             Gen(cmSave)
      Else If TargetVar^.Cat = catLVal Then
             Gen(cmLSave)
      Else
        Error('Assignemnt target is not variable');
    End
  Else
    Expected('":="');
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

Procedure StProc(P: integer);

Var 
  c: integer;
  X: tObj;
Begin
  Case P Of 
    spDEC:
           Begin
             Variable(X);
             Gen(cmDup);
             Gen(cmLoad);
             If Lex = lexComma Then
               Begin
                 NextLex;
                 IntExpression;
               End
             Else
               Gen(1);
             Gen(cmSub);
             Gen(cmSave);
           End;
    spINC:
           Begin
             Variable(X);
             Gen(cmDup);
             Gen(cmLoad);
             If Lex = lexComma Then
               Begin
                 NextLex;
                 IntExpression;
               End
             Else
               Gen(1);
             Gen(cmAdd);
             Gen(cmSave);
           End;
    spInOpen:
      { empty };
    spInInt:
             Begin
               Variable(X);
               Gen(cmIn);
               Gen(cmSave);
             End;
    spOutInt:
              Begin
                IntExpression;
                Check(lexComma, '","');
                IntExpression;
                Gen(cmOut);
              End;
    spOutLn:
             Gen(cmOutLn);
    spHalt:
            Begin
              ConstExpr(c);
              GenConst(c);
              Gen(cmStop);
            End;
  End;
End;

(* Name ["(" {Expression | Variable} ")"] *)
Procedure StProcCallStatement(P: integer);
Begin
  Check(lexName, 'procedure name');
  If Lex = lexLPar Then
    Begin
      NextLex;
      StProc(P);
      Check(lexRPar, '")"');
    End
  Else If P In [spOutLn, spInOpen] Then
         StProc(P)
  Else
    Expected('"("');
End;

Procedure Proc(NameRef: tObj);
Begin
  Gen(NameRef^.Val);
  Gen(cmCall);
End;

Procedure VarArg;

Var 
  X: tObj;
Begin
  If Lex <> lexName Then
    Expected('name');
  Find(Name, X);
  If X^.Cat = catLVar Then
    Begin
      Gen(X^.Val);
      Gen(cmLLoad);
    End
  Else If X^.Cat = catLVal Then
         Begin
           Gen(cmGetBP);
           Gen(X^.Val);
           Gen(cmSub);
         End
  Else If X^.Cat = catVar Then
         Begin
           GenAddr(X);
         End
  Else
    Expected('variable or value');
  NextLex;
End;

Procedure ProcArgs(ProcRef: tObj);

Var 
  CurrArg: integer;
  CurrParam: tFP;
Begin
  CurrArg := 1;
  FindProcFP(CurrArg, ProcRef, CurrParam);
  If CurrParam = Nil Then
    Error('Arguments and params lengths mismatch');
  If CurrParam^.Cat = catFPVal Then
    IntExpression
  Else
    VarArg;
  While Lex = lexComma Do
    Begin
      CurrArg := CurrArg + 1;
      NextLex;
      FindProcFP(CurrArg, ProcRef, CurrParam);
      If CurrParam = Nil Then
        Error('Arguments and params lengths mismatch');
      If CurrParam^.Cat = catFPVal Then
        IntExpression
      Else
        VarArg;
    End;
  If CurrParam^.Next <> Nil Then
    Error('Arguments and params lengths mismatch');
End;

Procedure ProcCallStatement(ProcRef: tObj);
Begin
  Check(lexName, 'procedure name');
  If Lex = lexLPar Then
    Begin
      NextLex;
      If Lex <> lexRPar Then
        ProcArgs(ProcRef);
      Proc(ProcRef);
      Check(lexRPar, '")"');
    End
  Else Proc(ProcRef);
End;

Procedure WhileStatement;

Var 
  WhilePC: integer;
  CondPC: integer;
Begin
  WhilePC := PC;
  Check(lexWHILE, 'WHILE');
  BoolExpression;
  CondPC := PC;
  Check(lexDO, 'DO');
  StatSeq;
  Check(lexEND, 'END');
  Gen(WhilePC);
  Gen(cmGOTO);
  Fixup(CondPC);
End;

Procedure IfStatement;

Var 
  CondPC: integer;
  LastGOTO: integer;
Begin
  Check(lexIF, 'IF');
  LastGOTO := 0;
  BoolExpression;
  CondPC := PC;
  Check(lexTHEN, 'THEN');
  StatSeq;
  While Lex = lexELSIF Do
    Begin
      Gen(LastGOTO);
      Gen(cmGOTO);
      LastGOTO := PC;
      NextLex;
      Fixup(CondPC);
      BoolExpression;
      CondPC := PC;
      Check(lexTHEN, 'THEN');
      StatSeq;
    End;
  If Lex = lexELSE Then
    Begin
      Gen(LastGOTO);
      Gen(cmGOTO);
      LastGOTO := PC;
      NextLex;
      Fixup(CondPC);
      StatSeq;
    End
  Else
    Fixup(CondPC);
  Check(lexEND, 'END');
  Fixup(LastGOTO);
End;

Procedure ReturnStatement;
Begin
  Check(lexRETURN, 'RETURN');
  If CurrProcedure = Nil Then
    Error('Unable to use return statement outside a procedure');
  If CurrProcedure^.Typ = typInt Then
    IntExpression;
  Gen(ReturnLastGOTO);
  Gen(cmGOTO);
  ReturnLastGOTO := PC;
End;

Procedure Statement;

Var 
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
      If X^.Cat In [catVar, catLVal, catLVar] Then
        AssignmentStatement
      Else If (X^.Cat = catStProc) And (X^.Typ = typNone)
             Then
             StProcCallStatement(X^.Val)
      Else If (X^.Cat = catProc) Then
             ProcCallStatement(X)
      Else
        Expected('variable or procedure designation');
    End
  Else If Lex = lexIF Then
         IfStatement
  Else If Lex = lexWHILE Then
         WhileStatement
  Else If Lex = lexRETURN Then
         ReturnStatement
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
      Else If X^.Cat = catLVal Then
             Begin
               Gen(X^.Val);
               Gen(cmLLoad);
               T := X^.Typ;
               NextLex;
             End
      Else If X^.Cat = catLVar Then
             Begin
               Gen(X^.Val);
               Gen(cmLLoad);
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
      Else If (X^.Cat = catProc) And (X^.Typ <> typNone) Then
             Begin
               ProcCallStatement(X);
               T := X^.Typ;
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
        Error('Mismatched operation and operand types');
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
        Error('Mismatched operation and operand types');
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
        Error('Mismatched operation and operand types');
      NextLex;
      SimpleExpr(T);
      If T <> typInt Then
        Expected('integer expression');
      GenComp(Op);
      T := typBool;
    End;
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

Procedure FormalParametersSection(Var ProcRef: tObj; Var ParamsAmount: integer);

Var 
  NameRef: tObj;
  NameCat: tCat;
  FPCat: tFPCat;
Begin
  If Lex = lexVAR Then
    Begin
      NameCat := catLVar;
      FPCat := catFPVar;
      NextLex
    End
  Else
    Begin
      NameCat := catLVal;
      FPCat := catFPVal;
    End;

  If Lex <> lexName Then
    Expected('name')
  Else
    Begin
      NewName(Name, NameCat, NameRef);
      NameRef^.Typ := typInt; {Only integer is present}
      NameRef^.Val := ParamsAmount;
      ParamsAmount := ParamsAmount + 1;
      NewProcFP(FPCat, typInt, ProcRef);
      NextLex;
    End;
  While Lex = lexComma Do
    Begin
      NextLex;
      If Lex <> lexName Then
        Expected('name')
      Else
        Begin
          NewName(Name, NameCat, NameRef);
          NameRef^.Typ := typInt; {Only integer is present}
          NameRef^.Val := ParamsAmount;
          ParamsAmount := ParamsAmount + 1;
          NewProcFP(FPCat, typInt, ProcRef);
          NextLex;
        End;
    End;
  Check(lexColon, '":"');
  ParseType;
End;

Procedure FormalParameters(Var ProcRef: tObj; Var ParamsAmount: integer);
Begin
  If Lex In [lexName, lexVAR] Then
    Begin
      FormalParametersSection(ProcRef, ParamsAmount);
      While Lex = lexSemi Do
        Begin
          NextLex;
          FormalParametersSection(ProcRef, ParamsAmount);
        End;
    End;
End;

Procedure ProcLocalVarsDecl(Var VarsAmount: integer; ParamsShift: integer);

Const 
  VarsShift = 2; {Return address + old base pointer}

Var 
  NameRef: tObj;
Begin
  If Lex = lexName Then
    Begin
      NewName(Name, catLVal, NameRef);
      NameRef^.Typ := typInt; {Only integer is present}
      NameRef^.Val := VarsAmount + ParamsShift + VarsShift;
      VarsAmount := VarsAmount + 1;
      NextLex;
      While Lex = lexComma Do
        Begin
          NextLex;
          If Lex <> lexName Then
            Expected('name')
          Else
            Begin
              NewName(Name, catLVal, NameRef);
              NameRef^.Typ := typInt; {Only integer is present}
              NameRef^.Val := VarsAmount + ParamsShift + VarsShift;
              VarsAmount := VarsAmount + 1;
              NextLex;
            End;
        End;
      Check(lexColon, '":"');
      ParseType;
    End
  Else
    Expected('name');
End;

Procedure ProcDecl;

Var 
  ProcRef: tObj;
  ParamsAmount: integer;
  VariablesAmount: integer;
Begin
  ParamsAmount := 0;
  VariablesAmount := 0;
  If Lex <> lexName Then
    Expected('procedure name')
  Else
    Begin
      NewName(Name, catProc, ProcRef);
      ProcRef^.Typ := typNone;
      ProcRef^.Val := PC;
      CurrProcedure := ProcRef;
      NextLex;
    End;
  OpenScope;
  If Lex = lexLPar Then
    Begin
      NextLex;
      FormalParameters(ProcRef, ParamsAmount);
      Check(lexRPar, '")"');
    End;
  If Lex = lexColon Then
    Begin
      NextLex;
      ParseType;
      ProcRef^.Typ := typInt;
    End;
  Check(lexSemi, '";"');
  If (ParamsAmount = 0) And (ProcRef^.Typ <> typNone) Then
    Gen(cmDup);
  Gen(cmGetBP);
  Gen(cmGetSP);
  If (ParamsAmount = 0) And (ProcRef^.Typ <> typNone) Then
    Gen(2)
  Else
    Gen(ParamsAmount + 1);
  Gen(cmAdd);
  Gen(cmSetBP);
  If Lex = lexVar Then
    Begin
      NextLex;
      ProcLocalVarsDecl(VariablesAmount, ParamsAmount);
      Check(lexSemi, '";"');
      Gen(VariablesAmount);
      Gen(cmEnter);
    End;
  Check(lexBEGIN, 'BEGIN');
  StatSeq;
  Fixup(ReturnLastGOTO);
  If ProcRef^.Typ <> typNone Then
    Begin
      Gen(cmGetBP);
      Gen(cmSwap);
      Gen(cmSave);
    End;
  Gen(VariablesAmount);
  Gen(cmLeave);
  Gen(cmSetBP);
  If ParamsAmount = 0 Then
    Gen(cmGOTO)
  Else If (ProcRef^.Typ <> typNone) Then
         Begin
           Gen(ParamsAmount - 1);
           Gen(cmRet);
         End
  Else
    Begin
      Gen(ParamsAmount);
      Gen(cmRet);
    End;
  CloseScope;
  ReturnLastGOTO := 0;
  CurrProcedure := Nil;
  Check(lexEND, 'END');
  If Lex <> lexName Then
    Expected('procedure name')
  Else If Name <> ProcRef^.Name Then
         Expected('procedure name "' + ProcRef^.Name + '"')
  Else
    NextLex;
End;

(* { CONST {ConstantsDeclaration ";"} *)
(* | VAR{VariablesDeclaration ";"} *)
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

(* ProcedureDeclaration ";" {ProcedureDeclaration ";"} *)
Procedure ProcSeq;

Var 
  SkipProcSequenceGOTO: integer;
Begin
  Gen(0);
  Gen(cmGOTO);
  SkipProcSequenceGOTO := PC;
  While Lex = lexPROCEDURE Do
    Begin
      NextLex;
      ProcDecl;
      Check(lexSemi, '";"');
    End;
  Fixup(SkipProcSequenceGOTO);
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

Procedure AllocateVariables;

Var 
  VRef: tObj;
Begin
  FirstVar(VRef);
  While VRef <> Nil Do
    Begin
      If VRef^.Val = 0 Then
        Warning('Variable ' + VRef^.Name + ' is not used')
      Else
        Begin
          Fixup(VRef^.Val);
          PC := PC + 1;
        End;
      NextVar(VRef);
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
  If Lex = lexPROCEDURE Then
    ProcSeq;
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
  Gen(0); {Exit Status}
  Gen(cmStop);
  AllocateVariables;
End;

Procedure Compile;
Begin
  ReturnLastGOTO := 0;
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
