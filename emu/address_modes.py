# address_modes.py
# defines addressing modes for 6502
# 29sep07, tbarr@cs.hmc.edu

# imm: immediate
# zpg: zero page
# zpx: zero page,x
# abs: absolute
# abx: absolute,x
# aby: absolute,y
# idx: indirect,x
# idy: indirect,y

def imm(machine, address):
    return (machine.mem[address+1], None)
    
def imp(machine, address):
    return (None, None)
    
def zpg(machine, address):
    daddr = machine.mem[address+1]
    return (machine.mem[daddr], daddr)
    
def abs(machine, address):
    daddr = machine.mem[address+1] + machine.mem[address+2] << 8
    return (machine.mem[daddr], daddr)
    