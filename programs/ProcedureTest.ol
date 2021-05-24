MODULE ProcTest;

IMPORT In, Out;

CONST
  Two = 2;

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

PROCEDURE LocalAdd(a, b: INTEGER);
VAR
  localAdder: INTEGER;
BEGIN
  localAdder := 30;
  Add(localAdder, a);
  Add(localAdder, b);
END LocalAdd;

BEGIN
  LocalAdd(11, 12);

  Add(1, 3);
  Add(4, 5);

  Sub(3, 10);
  Sub(40, 23);

  SubAndAdd(10, 13);
END ProcTest.
