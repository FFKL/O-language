
Unit ODebug;

Interface

Procedure PrintStack(SP: integer);

Implementation

Uses OVM;

Procedure PrintStack(SP: integer);

Var 
  Count: integer;
Begin
  Count := SP;
  While Count <= MemSize  Do
    Begin
      Write(M[Count], ' <- ');
      Count := Count + 1;
    End;
  WriteLn('Top');
End;

End.
