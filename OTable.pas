
Unit OTable;

Interface

Uses OScan, OError;

Type 
  tCat = (catConst, catVar, catType, catStProc, catModule, catGuard);
  tType = (typNone, typInt, typBool);
  tObj = ^tObjRec;
  tObjRec = Record
    Name: tName;
    Cat: tCat;
    Typ: tType;
    Val: integer;
    Prev: tObj;
  End;

Procedure InitNameTable;
Procedure Enter(N: tName; C: tCat; T: tType; V: integer);
Procedure NewName(Name: tName; Cat: tCat; Var Obj: tObj);
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
      Top := Obj;
    End
  Else
    Error('Name already defined');
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
