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
        print "break, dump status\n"
        print mac
        print ""
    elif mac.d == 2:
        print "break, dump memory\n"
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
    
# imm: immediate
# zpg: zero page
# zpx: zero page,x
# abs: absolute
# abx: absolute,x
# aby: absolute,y
# idx: indirect,x
# idy: indirect,y

instruction_table = {
    0x69:('adc', imm, adc, 'svzc', 2),
    0x29:('and', imm, and_op, 'sz', 2),
    0x0a:('asl', imm, asl, 'szc', 2),
    0x49:('eor', imm, eor, 'sz', 2),
    0x00:('brk', imm, brk, '', 2),
    }
    