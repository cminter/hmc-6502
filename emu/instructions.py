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
    
def bit(mac):
    # todo
    pass
    
def cmp(mac):
    # really not sure about the correct behaviour of this
    # to test
    mac.result = mac.d - mac.a

def cpx(mac):
    # to test
    mac.result = mac.d - mac.x
    
def cpy(mac):
    # to test
    mac.result = mac.d - mac.y
    
def dec(mac):
    # to test
    mac.mem[mac.daddr] = (mac.data - 1) & 0xff
    
def inc(mac):
    # to test
    mac.mem[mac.daddr] = (mac.data + 1) & 0xff
    
def jmp(mac):
    # todo
    pass
    
def jsr(mac):
    # todo
    pass
    
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
    # to test
    pass
    
def ror(mac):
    # todo
    pass
    
def sbc(mac):
    # todo
    pass
    
def stx(mac):
    # to test
    mac.mem[mac.daddr] = mac.x
    
def sty(mac):
    # to test
    mac.mem[mac.daddr] = mac.y
    
