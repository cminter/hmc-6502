Bitfield for flags is: [N,V,_,B,D,I,Z,C]
N = Negative Result -- sometimes (S)ign Bit
V = Overflow_ = Expansion Bit
B = Break Command
D = Decimal Mode
I = Interrupt Disable
Z = Zero Result
C = Carry

Carry: Carry out from alu[7](7.md)

Overflow: Carry out from alu[6](6.md)

Zero flag: Set when aluout==0

Decimal mode: controls BCD mode of CPU

Break: Set when processor interrupts from getting break command

Expansion bit: To prevent cracking during thermal cycles.

Interrupt disable: Disables servicing of interrupts (is this set on getting an interrupt, like in MIPS)

Negative result: alu[7](7.md)