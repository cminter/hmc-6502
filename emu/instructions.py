# instructions.py
# defines instructions for 6502 microprocessor
# 29sep07, tbarr@cs.hmc.edu

from address_modes import *
import sys

def adc(mac):
    mac.a = mac.d + mac.a
    
def brk(mac):
    if mac.d == 0:
        print "brk(0), exiting"
        sys.exit()
    elif mac.d == 1:
        print "\nbreak, dump status"
        print mac
        print ""
    elif mac.d == 2:
        print "\nbreak, dump memory"
        print mac.mem
        print ""
    else:
        print "invalid break, quitting"
        sys.exit()
    
def and_op(mac):
    mac.a = mac.d & mac.a
    
def asl(mac):
    mac.a = mac.d << 1
    
def eor(mac):
    mac.a = mac.a ^ mac.d
    
def lda(mac):
    mac.a = mac.d
    
def lsr(mac):
    mac.result = (mac.a >> 1) & 0x100
    mac.a = mac.a >> 1
    mac.result += mac.a
    
def sta(mac):
    mac.mem[mac.daddr] = mac.a
    
# imm: immediate
# zpg: zero page
# zpx: zero page,x
# abs: absolute
# abx: absolute,x
# aby: absolute,y
# idx: indirect,x
# idy: indirect,y

instruction_table = {
    0x69:('adc', imm, adc, 'nzcv', 2),
    0x6d:('adc', abs, adc, 'nzcv', 2),
    0x29:('and', imm, and_op, 'nz', 2),
    0x0a:('asl', imm, asl, 'nzc', 2),
    0x49:('eor', imm, eor, 'nz', 2),
    0x00:('brk', imm, brk, '', 2),
    0xa9:('lda', imm, lda, 'nz', 2),
    
    # flag instructions
    0x18:('clc', imp, lambda x: x.clear_flag(x.C), '', 1),
    0x38:('sec', imp, lambda x: x.set_flag(x.C), '', 1),
    0x58:('cli', imp, lambda x: x.clear_flag(x.I), '', 1),
    0x78:('sei', imp, lambda x: x.set_flag(x.I), '', 1),
    0xb8:('clv', imp, lambda x: x.clear_flag(x.V), '', 1),
    0xd8:('cld', imp, lambda x: x.clear_flag(x.D), '', 1),
    0xf8:('sed', imp, lambda x: x.set_flag(x.D), '', 1),
    
    # memory instructions
    0x8d:('sta', abs, sta, '', 3),
    0xad:('lda', abs, lda, '', 3)
    }
    