MODULE ProcTest;

IMPORT In, Out;

CONST
  Two = 2;

PROCEDURE Proc;
BEGIN
  Out.Int(Two + Two, 1);
  Out.Ln;
END Proc;

BEGIN
  Proc;
  Proc;
END ProcTest.
