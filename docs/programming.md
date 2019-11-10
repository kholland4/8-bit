# Programming

### Method 1

The computer has 4 asynchronous control lines used for programming (storing data to memory), as follows:

| name  | active h/l  | purpose |
| ----- | ----------- | ---     |
| P_IPH | active high | Load IPH from bus
| P_IPL | active high | Load IPL from bus and jump
| P_WI  | active low  | Load the high byte of memory from bus
| P_WD  | active low  | Load the low byte of memory from bus

Programming is performed by using the P_IPH and P_IPL lines in conjunction with the bus to set the memory address and
the P_WI and P_WD lines with the bus to store data. **These lines should only be used in fetch mode.**

It is recommended to connect an external device (i. e., an Arduino) to these control lines and the bus
for programming (see [here](software/8-bit_prgm/8-bit_prgm.ino)).

### Method 2

This method can be used for easier manual programming (i. e. without an external programming device).

Wire RCLK to low *(known hardware bug)*.
Use the reset and single-step buttons to set the memory address.
DIP switches are present near the memory chips; data can be entered here.
Two buttons next to the clock control DIP switch are used to write the high/low bytes of data.
