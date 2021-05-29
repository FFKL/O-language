# O language

O language compiler and a virtual machine based on `S.Z.Sverdlov Programming Languages and Methods Of Translation` book.

## VM Commands Set

| Code   | Term  | Name                     | Stack                       | Action                        |
|--------|-------|--------------------------|-----------------------------|-------------------------------|
| c >= 0 | -     | Const                    | -> c                        |                               |
| -1     | STOP  | Stop                     | ->                          |                               |
| -2     | ADD   | Addition                 | x, y -> x + y               |                               |
| -3     | SUB   | Subtraction              | x, y -> x - y               |                               |
| -4     | MUL   | Multiplication           | x, y -> x * y               |                               |
| -5     | DIV   | Division                 | x, y -> x DIV y             |                               |
| -6     | MOD   | Modulo                   | x, y -> x MOD y             |                               |
| -7     | NEG   | Negation                 | x -> -x                     |                               |
| -8     | LOAD  | Get value                | A -> M[A]                   |                               |
| -9     | SAVE  | Save value               | A, x ->                     | M[A] := x                     |
| -10    | DUP   | Duplication              | x -> x, x                   |                               |
| -11    | DROP  | Drop                     | x ->                        |                               |
| -12    | SWAP  | Swap                     | x, y -> y, x                |                               |
| -13    | OVER  | Up                       | x, y -> x, y, x             |                               |
| -14    | GOTO  | Unconditional jump       | A ->                        | PC := A                       |
| -15    | IFEQ  | Jump if equal            | x, y, A ->                  | if x = y then PC := A         |
| -16    | IFNE  | Jump if not equal        | x, y, A ->                  | if x <> y then PC := A        |
| -17    | IFLE  | Jump if less or equal    | x, y, A ->                  | if x <= y then PC := A        |
| -18    | IFLT  | Jump if less             | x, y, A ->                  | if x < y then PC := A         |
| -19    | IFGE  | Jump if greater or equal | x, y, A ->                  | if x >= y then PC := A        |
| -20    | IFGT  | Jump if greater          | x, y, A ->                  | if x > y then PC := A         |
| -21    | IN    | Input                    | -> x                        | ReadLn(M[SP])                 |
| -22    | OUT   | Output                   | x, w ->                     | Write(x:w)                    |
| -23    | OUTLN | Line feed                | ->                          | WriteLn                       |
| -24    | CALL  | Procedure call           | A -> PC                     | Swap(M[SP], PC)               |
| -25    | RET   | Return from procedure    | P0, P1, ..., Pn-1, RA, n -> | PC := RA; SP := SP + n + 2;   |
| -26    | ENTER | Allocate stack memory    | n -> x1, x2, ..., xn        | SP := SP - n + 1              |
| -27    | LEAVE | Free stack memory        | x1, x2, ..., xn, n ->       | SP := SP + n + 1              |
| -28    | GETBP | Get base pointer         | -> BP                       | M[SP] := BP                   |
| -29    | SETBP | Set base pointer         | A ->                        | BP := A                       |
| -30    | LLOAD | Get local variable       | A -> M[BP - A]              | M[SP] := M[BP - A]            |
| -31    | LSAVE | Save local variable      | A, x ->                     | M[BP - A] := x                |
| -32    | GETSP | Get stack pointer        | -> SP                       | M[SP - 1] := SP               |