
Unit AsmTable;

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
