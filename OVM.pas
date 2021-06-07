
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

  {Procedure Call}
  cmCall  = -24;
  cmRet   = -25;
  {Procedure Memory}
  cmEnter = -26;
  cmLeave = -27;
  {Base Pointer}
  cmGetBP = -28;
  cmSetBP = -29;
  {Local Variables}
  cmLLoad = -30;
  cmLSave = -31;
  {Stack Pointer}
  cmGetSP = -32;

Var 
  M: array [0..MemSize - 1] Of integer;

Procedure Run;

Implementation

Procedure Run;

Var 
  PC: integer;
  SP: integer;
  BP: integer;
  Cmd: integer;
  Temp: integer;
Begin
  PC := 0;
  BP := 0;
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
                   M[SP] := M[SP] - M[SP - 1];
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
          cmSwap:
                  Begin
                    Temp := M[SP];
                    M[SP] := M[SP + 1];
                    M[SP + 1] := Temp;
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
                  Write('> ');
                  ReadLn(M[SP]);
                End;
          cmOut:
                 Begin
                   Write(M[SP + 1]:M[SP]);
                   SP := SP + 2;
                 End;
          cmOutLn:
                   WriteLn;
          cmCall:
                  Begin
                    Temp := M[SP];
                    M[SP] := PC;
                    PC := Temp;
                  End;
          cmRet:
                 Begin
                   PC := M[SP + 1];
                   SP := SP + M[SP] + 2;
                 End;
          cmEnter:
                   SP := SP - M[SP] + 1;
          cmLeave:
                   SP := SP + M[SP] + 1;
          cmGetBP:
                   Begin
                     SP := SP - 1;
                     M[SP] := BP;
                   End;
          cmSetBP:
                   Begin
                     BP := M[SP];
                     SP := SP + 1;
                   End;
          cmLLoad:
                   M[SP] := M[BP - M[SP]];
          cmLSave:
                   Begin
                     M[BP - M[SP + 1]] := M[SP];
                     SP := SP + 2;
                   End;
          cmGetSP:
                   Begin
                     M[SP - 1] := SP;
                     SP := SP - 1;
                   End;
          Else
            Begin
              WriteLn('Unacceptable operation code');
              M[PC] := cmStop;
            End;
        End;
      Cmd := M[PC];
    End;
  If SP < MemSize Then
    ExitCode := M[SP]
  Else
    ExitCode := 1;
End;

End.
