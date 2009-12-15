This is my pipelined CPU implementation.

The main entity is located in CPU.vhdl. It is divided into entities by 
stage. Each stage has its own entity and its own register to store the 
state.

My implementation uses forwarding to handle data hazards.

I created an assembler (asm.pl) which converts the assembly in code.asm 
to machine code and stores it in memory.dat.

The current memory.dat file contains the machine code for the current 
code.asm file. My CPU contains a process which performs testing on the 
CPU. This is not currently active, but it can be activated by changing 
a false to a true. In order for this testing to succeed, the CPU needs 
to be running the code in memory.dat.

This code is also available on github: http://github.com/jncraton/MIPS-Lite