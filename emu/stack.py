# stack.py
# implements stack functionality
# tbarr@cs.hmc.edu, 17oct07

def jsr(mac):
    # to test
    oldpc = mac.pc - 1
    mac.push(oldpc & 0xff)
    mac.push((oldpc & 0xff00) >> 8)
    mac.pc = mac.daddr
    print "jsring to: %s" % hex(mac.pc)
    
def txs(mac):
    # to test
    mac.sp = mac.x
    
def tsx(mac):
    # to test
    mac.x = mac.sp
    
def pha(mac):
    # to test
    mac.push(mac.a)
    
def pla(mac):
    # to test
    mac.a = mac.pop()
    
def jts(mac):
    # to test
    mac.push(mac.pc & 0x00ff)
    mac.push((mac.pc & 0xff00) >> 8)
    mac.pc = mac.daddr

def rts(mac):
    # to test
    newpc = mac.pop() << 8
    newpc += mac.pop()
    mac.pc = newpc + 1
    
def php(mac):
    # to test
    mac.push(mac.flags)
    
def plp(mac):
    #to test
    mac.flags = mac.push()
    
def rti(mac):
    # to test
    self.flags = mac.pop()
    self.pc = mac.pop() << 8
    self.pc += mac.pop()