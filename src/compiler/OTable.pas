
Unit OTable;

Interface

Uses OScan, OError;

Type 
  tCat = (
          catConst,
          catVar,
          catLVar,
          catLVal,
          catProc,
          catType,
          catStProc,
          catModule,
          catGuard
         );
  tType = (typNone, typInt, typBool);
  tFPCat = (catFPVar, catFPVal);
  tFP = ^tFPRec;
  tFPRec = Record
    Cat: tFPCat;
    Typ: tType;
    Next: tFP;
  End;
  tObj = ^tObjRec;
  tObjRec = Record
    Name: tName;
    Cat: tCat;
    Typ: tType;
    Val: integer;
    Prev: tObj;
    ProcFP: tFP;
  End;

Procedure InitNameTable;
Procedure Enter(N: tName; C: tCat; T: tType; V: integer);
Procedure NewName(Name: tName; Cat: tCat; Var Obj: tObj);
Procedure NewProcFP(C: tFPCat; T: tType; Var Obj: tObj);
Procedure FindProcFP(Position: integer; Var Obj: tObj; Var Param: tFP);
Procedure Find(Name: tName; Var Obj: tObj);
Procedure OpenScope;
Procedure CloseScope;
Procedure FirstVar(Var VRef: tObj);
Procedure NextVar(Var VRef: tObj);

Implementation

Var 
  Top: tObj;
  Bottom: tObj;
  CurrObj: tObj;

Procedure InitNameTable;
Begin
  Top := Nil;
End;

Procedure Enter(N: tName; C: tCat; T: tType; V:integer);

Var 
  P: tObj;
Begin
  New(P);
  P^.Name := N;
  P^.Cat := C;
  P^.Typ := T;
  P^.Val := V;
  P^.Prev := Top;
  P^.ProcFP := Nil;
  Top := P;
End;

Procedure OpenScope;
Begin
  Enter('', catGuard, typNone, 0);
  If Top^.Prev = Nil Then
    Bottom := Top;
End;

Procedure CloseScope;

Var 
  P: tObj;
Begin
  While Top^.Cat <> catGuard Do
    Begin
      P := Top;
      Top := Top^.Prev;
      Dispose(P);
    End;
  P := Top;
  Top := Top^.Prev;
  Dispose(P);
End;

Procedure NewName(Name: tName; Cat: tCat; Var Obj: tObj);
Begin
  Obj := Top;
  While (Obj^.Cat <> catGuard) And (Obj^.Name <> Name) Do
    Obj := Obj^.Prev;
  If Obj^.Cat = catGuard Then
    Begin
      New(Obj);
      Obj^.Name := Name;
      Obj^.Cat := Cat;
      Obj^.Val := 0;
      Obj^.Prev := Top;
      Obj^.ProcFP := Nil;
      Top := Obj;
    End
  Else
    Error('Name already defined');
End;

Procedure NewProcFP(C: tFPCat; T: tType; Var Obj: tObj);

Var 
  Param: tFP;
  Last: tFP;
Begin
  If Obj^.Cat = catProc Then
    Begin
      If Obj^.ProcFP = Nil Then
        Begin
          New(Param);
          Param^.Cat := C;
          Param^.Typ := T;
          Param^.Next := Nil;
          Obj^.ProcFP := Param;
        End
      Else
        Begin
          Param := Obj^.ProcFP;
          While Param^.Next <> Nil Do
            Param := Param^.Next;
          Last := Param;
          New(Param);
          Param^.Cat := C;
          Param^.Typ := T;
          Param^.Next := Nil;
          Last^.Next := Param;
        End;
    End
  Else
    Error('Unable to add format parameter to non-Procedure');
End;

Procedure FindProcFP(Position: integer; Var Obj: tObj; Var Param: tFP);

Var 
  CurrPosiiton: integer;
Begin
  Param := Obj^.ProcFP;
  If Position <> 1 Then
    Begin
      For CurrPosiiton := 2 To Position Do
        Param := Param^.Next;
    End;
End;

Procedure Find(Name: tName; Var Obj: tObj);
Begin
  Bottom^.Name := Name;
  Obj := Top;
  While Obj^.Name <> Name Do
    Obj := Obj^.Prev;
  If Obj = Bottom Then
    Error('Undeclared name');
End;

Procedure FirstVar(Var VRef: tObj);
Begin
  CurrObj := Top;
  NextVar(VRef);
End;

Procedure NextVar(Var VRef: tObj);
Begin
  While (CurrObj <> Bottom) And (CurrObj^.Cat <> catVar) Do
    CurrObj := CurrObj^.Prev;
  If CurrObj = Bottom Then
    VRef := Nil
  Else
    Begin
      VRef := CurrObj;
      CurrObj := CurrObj^.Prev;
    End
End;

End.
