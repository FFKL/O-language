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

PROCEDURE Function(a: INTEGER): INTEGER;
VAR
  sum: INTEGER;
BEGIN
  sum := a + 1;
  IF sum >= 3 THEN
    RETURN sum;
  END;
  RETURN sum + 1;
END Function;

BEGIN
  Variable := Function(2);
  PrintInt(Variable, 0);
  
  Out.Ln;
  
  LocalAdd(Variable, Variable - 2);
  PrintInt(Variable, 0);

  Out.Ln;

  Add(1, 3);
  Add(4, 5);

  Sub(3, 10);
  Sub(40, 23);

  SubAndAdd(10, 13);
END ProcTest.
