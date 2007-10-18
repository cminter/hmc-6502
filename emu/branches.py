# branches.py
# implements branching and jumping modes

from utils import signed

def branch(mac, flag, truth):
    print "got branch, %s, %s" % (flag, truth)
    if not (truth ^ mac.get_flag(flag)):
        # take branch
        mac.pc = (mac.pc + signed(mac.d)) & 0xffff
        
def make_branch(flag, truth):
    return lambda mac: branch(mac, flag, truth)