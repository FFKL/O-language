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

BEGIN
  Add(1, 3);
  Add(4, 5);

  Sub(3, 10);
  Sub(40, 23);

  SubAndAdd(10, 13);
END ProcTest.
