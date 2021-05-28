MODULE TowerOfHanoi;

IMPORT In, Out;

VAR
  n : INTEGER;

PROCEDURE Print(X, Y: INTEGER);
BEGIN
  Out.Int(X, 1);
  Out.Int(Y, 2);
  Out.Ln;
END Print;

PROCEDURE Move(n, X, Y, Z: INTEGER);
BEGIN
  IF n > 0 THEN
    Move(n - 1, X, Z, Y);
    Print(X, Y);
    Move(n - 1, Z, Y, X);
  END;
END Move;

BEGIN
  In.Open;
  In.Int(n);
  Move(n, 1, 2, 3);
END TowerOfHanoi.
