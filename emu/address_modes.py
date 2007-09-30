# address_modes.py
# defines addressing modes for 6502
# 29sep07, tbarr@cs.hmc.edu

# immediate addressing mode
def imm(machine, address):
    return machine.mem[address+1]
    
def imp(machine, address):
    return None