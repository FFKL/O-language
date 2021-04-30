MODULE ProcTest;

IMPORT In, Out;

CONST
  Two = 2;

PROCEDURE Proc(a, b: INTEGER; d: INTEGER);
BEGIN
  Out.Int(a + b, d);
  Out.Ln;
END Proc;

BEGIN
  Proc(1, 3, 1);
  Proc(4, 5, 1);
END ProcTest.
