MODULE ProcTest;

IMPORT In, Out;

CONST
  Two = 2;
VAR
  Variable: INTEGER;

PROCEDURE PrintInt(val: INTEGER; indent: INTEGER);
BEGIN
  Out.Int(val, indent);
  Out.Ln;
END PrintInt;

PROCEDURE Add(a, b: INTEGER);
BEGIN
  PrintInt(a + b, 0);
END Add;

PROCEDURE Sub(a, b: INTEGER);
BEGIN
  PrintInt(a - b, 0);
END Sub;

PROCEDURE SubAndAdd(a, b: INTEGER);
BEGIN
  Sub(a, b);
  Add(a, b);
END SubAndAdd;

PROCEDURE NestedAssignment(VAR a: INTEGER);
BEGIN
  a := 45;
END NestedAssignment;

PROCEDURE LocalAdd(VAR a: INTEGER; b: INTEGER);
VAR
  localAdder: INTEGER;
BEGIN
  localAdder := 30;
  Add(localAdder, a);
  Add(localAdder, b);
  NestedAssignment(localAdder);
  PrintInt(localAdder, 0);
  NestedAssignment(a);
END LocalAdd;

BEGIN
  Variable := 3;
  PrintInt(Variable, 0);
  LocalAdd(Variable, Variable - 2);
  PrintInt(Variable, 0);

  Add(1, 3);
  Add(4, 5);

  Sub(3, 10);
  Sub(40, 23);

  SubAndAdd(10, 13);
END ProcTest.
