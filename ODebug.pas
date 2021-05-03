
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
      Write(M[Count]);
      Write(' <- ');
      Count := Count + 1;
    End;
  Write('Top');
  WriteLn;
End;

End.
