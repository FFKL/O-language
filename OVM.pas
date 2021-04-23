
Unit OVM; {O Virtual Machine}

Interface

Const 
  MemSize = 8 * 1024;

  cmStop  = -1;
  {Arithmetic Commands}
  cmAdd   = -2;
  cmSub   = -3;
  cmMult  = -4;
  cmDiv   = -5;
  cmMod   = -6;
  cmNeg   = -7;
  {Memory Commands}
  cmLoad  = -8;
  cmSave  = -9;
  {Stack Commands}
  cmDup   = -10;
  cmDrop  = -11;
  cmSwap  = -12;
  cmOver  = -13;
  {Jump Commands}
  cmGOTO  = -14;
  cmIfEQ  = -15;
  cmIfNE  = -16;
  cmIfLE  = -17;
  cmIfLT  = -18;
  cmIfGE  = -19;
  cmIfGT  = -20;
  {I/O Commands}
  cmIn    = -21;
  cmOut   = -22;
  cmOutLn = -23;

Var 
  M: array [0..MemSize - 1] Of integer;

Procedure Run;

Implementation

Procedure Run;

Var 
  PC: integer;
  SP: integer;
  Cmd: integer;
  Buf: integer;
Begin
  PC := 0;
  SP := MemSize;
  Cmd := M[PC];
  While Cmd <> cmStop Do
    Begin
      PC := PC + 1;
      If Cmd >= 0 Then
        Begin
          SP := SP - 1;
          M[SP] := Cmd;
        End
      Else
        Case Cmd Of 
          cmAdd:
                 Begin
                   SP := SP + 1;
                   M[SP] := M[SP] + M[SP - 1];
                 End;
          cmSub:
                 Begin
                   SP := SP + 1;
                   M[SP] := M[SP] + M[SP - 1];
                 End;
          cmMult:
                  Begin
                    SP := SP + 1;
                    M[SP] := M[SP] * M[SP - 1];
                  End;
          cmDiv:
                 Begin
                   SP := SP + 1;
                   M[SP] := M[SP] Div M[SP - 1];
                 End;
          cmMod:
                 Begin
                   SP := SP + 1;
                   M[SP] := M[SP] Mod M[SP - 1];
                 End;
          cmNeg:
                 M[SP] := -M[SP];
          cmLoad:
                  M[SP] := M[M[SP]];
          cmSave:
                  Begin
                    M[M[SP + 1]] := M[SP];
                    SP := SP + 2;
                  End;
          cmDup:
                 Begin
                   SP := SP - 1;
                   M[SP] := M[SP + 1];
                 End;
          cmDrop:
                  SP := SP + 1;
          {TODO: change to xor algorithm}
          cmSwap:
                  Begin
                    Buf := M[SP];
                    M[SP] := M[SP + 1];
                    M[SP + 1] := Buf;
                  End;
          cmOver:
                  Begin
                    SP := SP - 1;
                    M[SP] := M[SP + 2];
                  End;
          cmGOTO:
                  Begin
                    PC := M[SP];
                    SP := SP + 1;
                  End;
          cmIfEQ:
                  Begin
                    If M[SP + 2] = M[SP + 1] Then
                      PC := M[SP];
                    SP := SP + 3;
                  End;
          cmIfNE:
                  Begin
                    If M[SP + 2] <> M[SP + 1] Then
                      PC := M[SP];
                    SP := SP + 3;
                  End;
          cmIfLE:
                  Begin
                    If M[SP + 2] <= M[SP + 1] Then
                      PC := M[SP];
                    SP := SP + 3;
                  End;
          cmIfLT:
                  Begin
                    If M[SP + 2] < M[SP + 1] Then
                      PC := M[SP];
                    SP := SP + 3;
                  End;
          cmIfGE:
                  Begin
                    If M[SP + 2] >= M[SP + 1] Then
                      PC := M[SP];
                    SP := SP + 3;
                  End;
          cmIfGT:
                  Begin
                    If M[SP + 2] > M[SP + 1] Then
                      PC := M[SP];
                    SP := SP + 3;
                  End;
          cmIn:
                Begin
                  SP := SP - 1;
                  Write('?');
                  ReadLn(M[SP]);
                End;
          cmOut:
                 Begin
                   Write(M[SP + 1]:M[SP]);
                   SP := SP + 2;
                 End;
          cmOutLn:
                   WriteLn;
          Else
            Begin
              WriteLn('Unacceptable operation code');
              M[PC] := cmStop;
            End;
        End;
      Cmd := M[PC];
    End;
  WriteLn;
  If SP < MemSize Then
    WriteLn('Return code ', M[SP]);
  Write('Press ENTER');
  ReadLn;
End;

End.
