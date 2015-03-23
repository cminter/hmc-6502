The 8-bit opcode fully specifies the operation of the CPU for the operation. It defines both the operation, and where the input data will come from.

The addressing modes are:

(opcode [one, [two](two.md)]: bytes in instruction)

Non indexed (fixed address):
  * Implied (implied by opcode)
  * Immediate (data=one)
  * Zero page (data=data at location {00, one})
  * Absolute (data=data at location {two, one})
  * Relative (first taken instruction @ PC + one + 0'd2)

Indexed (variable address):
  * 