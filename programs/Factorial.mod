MODULE FactorialProgram;

IMPORT In, Out;

VAR
  n: INTEGER;
  result: INTEGER;

PROCEDURE Factorial(n: INTEGER): INTEGER;
BEGIN
  IF n <= 1 THEN
    RETURN 1;
  END;

  RETURN n * Factorial(n - 1);
END Factorial;

BEGIN
  In.Open;
  In.Int(n);
  result := Factorial(n);
  Out.Int(result, 0);
  Out.Ln;
END FactorialProgram.
