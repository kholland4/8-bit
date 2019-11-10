# Instruction set

Each instruction for the computer consists of an 8-bit opcode and an 8-bit immediate value.
The opcode is further divided into two 4-bit segments called 'ih' and 'il'.
```
| 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 |
| opcode         | immediate      |
| ih     | il    |                |
```

Because the computer is not microcoded, each opcode directly controls parts of the system.
This is achieved by handling every operation as bus transfer.
The 'ih' portion of the opcode determines which part of the computer will output to the bus, and
the 'il' portion of the opcode determines which part will use that data.

### 'ih' values
| #   | symbol      | meaning                       |
| --- | ----------- | ----------------------------- |
| 0   | D ->        | Immediate value to bus
| 1   | A ->        | A register to bus
| 2   | B ->        | B register to bus
| 3   | RH,RL ->    | Low byte of memory at [rh,rl] to bus
| 4   | RH,D ->     | Low byte of memory at [rh,d] to bus
| 5   | IO ->       | IO port to bus
| 6   | RH,RL(I) -> | High byte of memory at [rh,rl] to bus
| 7   | FLAGS ->    | Flags register to bus
| 8   | AND ->      | A & B to bus
| 9   | OR ->       | A | B to bus
| 10  | XOR ->      | A ^ B to bus
| 11  | ADD ->      | A + B + flags to bus
| 12  | BSR ->      | B >> 1 to bus
| 13  | A<B ->      | A<B to bus
| 14  | A=B ->      | A=B to bus
| 15  | A>B ->      | A>B to bus

### 'il' values
| #   | symbol      | meaning                       |
| --- | ----------- | ----------------------------- |
| 0   | A <-        | Load A register from bus
| 1   | B <-        | Load B register from bus
| 2   | RH <-       | Load RH register from bus
| 3   | RH,RL <-    | Load low byte of memory at [rh,rl] from bus
| 4   | RH,D <-     | Load low byte of memory at [rh,d] from bus
| 5   | RL <-       | Load RL register from bus
| 6   | IO <-       | Output bus to IO port
| 7   | FLAGS <-    | Load flags register from bus
| 8   | BRANCH <-   | Branch to [iph,ipl] if bus[0] == 1
| 9   | IPL <-      | Load IPL register from bus
| 10  | IPH <-      | Load IPH register from bus
| 11  | RH,RL(I) <- | Load high byte of memory at [rh,rl] from bus
| 12  | IO2 <-      | Output bus to IO port #2
| 13  | IO3 <-      | Output bus to IO port #3
| 14  | IO4 <-      | Output bus to IO port #4
| 15  | IO5 <-      | Output bus to IO port #5
