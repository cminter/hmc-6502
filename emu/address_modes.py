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
    
def zpx(machine, address):
    daddr = (machine.mem[address+1] + machine.x) & 0xff
    return (machine.mem[daddr], daddr)
    
def zpy(machine, address):
    # IS THIS EVEN RIGHT?
    daddr = (machine.mem[address+1] + machine.y) & 0xff
    return (machine.mem[daddr], daddr)
    
def abs(machine, address):
    daddr = machine.mem[address+1] + machine.mem[address+2] << 8
    return (machine.mem[daddr], daddr)
    
def abx(machine, address):
    daddr = machine.mem[address+1] + machine.mem[address+2] << 8 + machine.x
    return (machine.mem[daddr], daddr)
    
def aby(machine, address):
    daddr = machine.mem[address+1] + machine.mem[address+2] << 8 + machine.y
    return (machine.mem[daddr], daddr)
    
def idx(machine, address):
    ia = (machine.mem[address+1] + machine.x) & 0xff
    daddr = machine.mem[ia]
    return (machine.mem[daddr], daddr)
    
def idy(machine, address):
    ia = (machine.mem[address+1]) & 0xff
    daddr = machine.mem[ia] + machine.y
    return (machine.mem[daddr], daddr)
    
def ind(machine, address):
    #todo
    pass
    
def acc(machine, address):
    return (machine.a, None)