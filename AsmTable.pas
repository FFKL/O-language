
Unit AsmTable;

Interface

Uses AsmScan;

Type 
  tObj = ^tObjRec;
  tObjRec = Record
    Name: tName;
    Addr: integer;
    Prev: tObj;
  End;

Procedure InitNameTable;
Procedure NewName(Addr: integer);
Procedure Find(Var Addr: integer);

Implementation

Uses OError;

Var 
  Top: tObj;

Procedure InitNameTable;
Begin
  Top := Nil;
End;

Procedure NewName(Addr: integer);

Var 
  Obj: tObj;
Begin
  Obj := Top;
  While (Obj <> Nil) And (Obj^.Name <> Name) Do
    Obj := Obj^.Prev;
  If Obj = Nil Then
    Begin
      New(Obj);
      Obj^.Name := Name;
      Obj^.Addr := Addr;
      Obj^.Prev := Top;
      Top := Obj;
    End
  Else
    Error('Name already defined');
End;

Procedure Find(Var Addr: integer);

Var Obj: tObj;
Begin
  Obj := Top;
  While (Obj <> Nil) And (Obj^.Name <> Name) Do
    Obj := Obj^.Prev;
  If Obj = Nil Then
    Error('Undeclared name')
  Else
    Addr := Obj^.Addr;
End;

End.
