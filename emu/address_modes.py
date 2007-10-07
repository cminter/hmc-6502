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
    daddr = machine.mem[address+1] + (machine.mem[address+2] << 8)
    return (machine.mem[daddr], daddr)
    
def abx(machine, address):
    daddr = machine.mem[address+1] + (machine.mem[address+2] << 8) + machine.x
    return (machine.mem[daddr], daddr)
    
def aby(machine, address):
    daddr = machine.mem[address+1] + (machine.mem[address+2] << 8) + machine.y
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
    # "For example if address $3000 contains $40, $30FF contains $80, and 
    # $3100 contains $50, the result of JMP ($30FF) will be a transfer of 
    # control to $4080 rather than $5080 as you intended i.e. the 6502 took 
    # the low byte of the address from $30FF and the high byte from $3000."
    ia = machine.mem[address+1] + (machine.mem[address+2] << 8)
    daddr_low = machine.mem[ia]
    daddr_high = machine.mem[(ia & 0xff00) + ((ia + 1) & 0x00ff)]
    daddr = daddr_low + 0x100 * daddr_high
    return (None, daddr)
    
def acc(machine, address):
    return (machine.a, None)