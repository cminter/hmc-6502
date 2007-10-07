# utils.py
# tbarr@cs.hmc.edu, 6oct07

LENGTH = 8

# fixed width at 8
def unsigned(signedInt, length=LENGTH):
    # make sure we're in bounds for either signed or unsigned
    if not (-(2**length)/2 <= signedInt <= (2**length - 1)):
        raise (ValueError, "number out of range for given length")

    if signedInt >= 0:
        # we don't need to manipulate the number at all, aside from
        # stripping off the 0x, the 'L' if it's there and zero pad the number
        return signedInt

    # now we actually need to find the two's complement value
    # flip the bits, add one.
    twoComp = abs((signedInt ^ (2**length-1)) + 1)
    return twoComp

def signed(unsignedInt, length=LENGTH):
    if unsignedInt < (2**(length-1)):
        return unsignedInt
    else:
        # subtract one, flip bits
        return -((unsignedInt - 1) ^ (2**length-1))
    
def bcd2int(bcd_num):
    pass