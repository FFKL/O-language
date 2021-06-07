MODULE Primes;
(* Prime numbers from 2 to п *)

IMPORT In, Out;

VAR
  n, c, i, d: INTEGER;
BEGIN
  In.Open;
  In.Int(n);
  c := 0; (* Counter *)
  i := 2;
  WHILE i <= n DO
    (* Divide by 2, 3 *)
      d := 2;
      WHILE i MOD d # 0 DO
        INC(d)
      END;
    IF d = i THEN (* i - prime number *)
      INC(c);
      Out.Int(d, 8)
    END;
    INC(i);
  END;
  Out.Ln;
  Out.Int(c, 0);
END Primes.
