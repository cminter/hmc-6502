Before starting work on the HDL, I will produce a complete, instruction level emulator for the CPU. This will help me understand the operation of the CPU, and hopefully solve many of the possible issues with designing the CPU before I actually start doing so.

To do:
Document memory map.
Write machine.py containing minimal machine class. This is analogous to the machine class from the MIPS project, though it should really only need memory and IP at this point.
Implement instruction decoder. (instructions may spawn across multiple bytes.)
Test against contrived instructions.
Complete machine.py with all registers.
Implement remaining instructions.
Test against non-contrived code.
Write test vectors.
Test test vectors against simulator.
Test TVs against actual machine, or against trusted emulator.