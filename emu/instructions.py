# instructions.py
# defines instructions for 6502 microprocessor
# 29sep07, tbarr@cs.hmc.edu

from address_modes import *
import sys

def adc(mac):
    mac.a = mac.d + mac.a + mac.get_flag(mac.C)
    
def brk_old(mac):
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
    elif mac.d == 3:
        raw_input('brk(3), pausing...')
    else:
        print "brk(%s)" % mac.d
    
def brk(mac):
    print "break"
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
    
def bit(mac):
    # to test
    mac.result = mac.d & mac.a
    if (mac.d & 0x80):
        mac.set_flag(mac.N)
    else:
        mac.clear_flag(mac.N)
    if (mac.d & 0x40):
        mac.set_flag(mac.V)
    else:
        mac.clear_flag(mac.V)
    
def cmp(mac):
    mac.result = mac.d - mac.a

def cpx(mac):
    # to test
    mac.result = mac.d - mac.x
    
def cpy(mac):
    # to test
    mac.result = mac.d - mac.y
    
def dec(mac):
    # to test
    mac.mem[mac.daddr] = (mac.d - 1) & 0xff
    
def inc(mac):
    # to test
    mac.mem[mac.daddr] = (mac.d + 1) & 0xff
    
def jmp(mac):
    # to test
    mac.pc = mac.daddr
    print "jumped to %s" % mac.pc
    
def ldx(mac):
    # to test
    mac.a = mac.x
    
def ldy(mac):
    # to test
    mac.a = mac.y
    
def ora(mac):
    # to test
    mac.a = mac.a | mac.d
    
def rol(mac):
    # todo
    raise Exception, "rol"
    
def ror(mac):
    # todo
    raise Exception, "ror"
    
def sbc(mac):
    # to test
    mac.a = mac.a - mac.m - mac.get_flag(mac.C)
    
def stx(mac):
    # to test
    mac.mem[mac.daddr] = mac.x
    
def sty(mac):
    # to test
    mac.mem[mac.daddr] = mac.y
    
# register instructions
def tax(mac):
    mac.result = mac.x = mac.a
    
def txa(mac):
    mac.result = mac.a = mac.x
    
def tay(mac):
    mac.result = mac.y = mac.a
    
def tya(mac):
    mac.result = mac.a = mac.y
    
def dex(mac):
    mac.x -= 1
    mac.result = mac.x
    
def inx(mac):
    mac.x += 1
    mac.result = mac.x
    
def dey(mac):
    mac.y -= 1
    mac.result = mac.y
    
def iny(mac):
    mac.y += 1
    mac.result = mac.y
