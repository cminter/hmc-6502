This page will mainly serve as my notes for readings about the CPU. Nothing here is anything you wouldn't learn just as well from the programming guide.

The accumulator holds data, and arithmetic operations usually operate on A with the data from some memory location, and stores the result back in the accumulator.

The ADC instruction uses the carry flag in the status register as both a carry in and carry out for an 8-bit add. This lets you string together an indefinite number of adds to create an (n\*8)-bit add.