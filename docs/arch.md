# Architecture

The core operation of the computer is broken up into two cycles: fetch and execute (non-pipelined).
During the fetch cycle, the instruction decoder is disabled (freeing up all buses) and
the memory address is taken from the program counter.
After a half clock cycle, memory output is latched into the instruction (I) and data (D) registers and
the program counter is incremented.
During the execute cycle, the instruction decoder is enabled and the program counter's output disabled.
The system is given a half clock cycle to stabilize, after which the appropriate registers are latched.
Execution continues with another fetch cycle.

### Buses

The computer has two buses: a main 8-bit bus and a 16-bit memory address bus.
The main bus is connected to virtually all parts of the computer and is used to execute instructions.
The memory address bus is connected to the program counter and memory address registers
(and also the D register for the immediate address mode); it feeds into the address lines of the memory chips.

### Registers

There are only two general-purpose registers: the A and B registers.
These are hardwired to the five ALU operations (AND, OR, XOR, ADD, BSR), each of which can be outputted onto the bus.
The ALU also makes use of a one-bit carry flag register, which can be both read from and written to.
Memory addressing is accomplished using the RH and RL registers (high and low bytes of the memory address, respectively);
these are write-only.
Jumps are accomplished with the IPH and IPL registers (high and low bytes of the address to jump to);
these are also write-only.
Additional control lines are provided for IO expansion boards (IO, IO2, IO3, IO4, and IO5).
IO is read/write, while IO2 thru IO5 are write-only.
Fetched instructions are stored in the instruction (I) and data (D) registers.
The D register is read-only, and the I register is inaccessible.
All registers are 8 bits wide unless otherwise noted.

### Memory access

The computer uses two 128K x 8 RAM chips in a 128K x 16 configuration (only 64K x 16 is accessible).
Memory addresses are 16 bits wide; data is 16 bits wide as well.

Memory can be read or written in one of three different addressing modes.
The first, [rh,rl], uses the RH (high byte) and RL (low byte) registers as the memory address;
it operates on the low byte of memory.
The second, [rh,d], uses the RH (high byte) and D (low byte) registers;
it operates on the low byte as well.
The third, [rh,rl](i), uses the RH and RL registers as in the first addressing mode but
reads from and writes to the high byte of memory rather than the low byte.

### Instruction format

See [isa.md](isa.md)
