# cpu.py
# implements base for 6502emu
# tbarr@cs.hmc.edu, 27sep07

from instructions import instruction_table

WIDTH = 8
MEMWORDS = 2

MAXMEM = 2**(WIDTH*MEMWORDS)

def int2bin(n, count=8):
    return "".join([str((n >> y) & 1) for y in range(count-1, -1, -1)])
    
class RangeError(Exception):
    pass
    
class InvalidOpcodeError(Exception):
    pass

class Memspace:
    def __init__(self):
        self.values = {}
        
    def __getitem__(self, mem_address):
        try:
            # wrap to right place
            return self.values[mem_address % MAXMEM]
        except KeyError:
            return 0
            
    def __setitem__(self, mem_address, value):
        if not 0 <= mem_address <= MAXMEM:
            raise RangeError
        self.values[mem_address] = value & 0xFF
        
    def __str__(self):
        memspace = self.values.items()
        memspace.sort(key=lambda x: x[0])
        return "\n".join(["[%s]: %s" % (hex(mem[0]), hex(mem[1])) for mem in memspace])
        
    def load_from_file(self, path, offset = 0x0):
        f = open(path)
        current_offset = offset
        for line in f:
            # don't read comments
            if line[0] == "#":
                continue
            self[current_offset] = int(line, 16)
            current_offset = (current_offset + 1) % (2**WIDTH)

class Machine:
    C = 1<<0
    Z = 1<<1
    I = 1<<2
    D = 1<<3
    B = 1<<4
    # bit 5 is expansion
    V = 1<<6
    N = 1<<7
    
    def __init__(self):
        self.mem = Memspace()
        
        # set flags
        self.flags = 0
        
        # set registers
        self.a = 0
        self.pc = 0
        self.x = 0
        self.y = 0
        
        # reset data bus
        self.d = None
        
    def set_flag(self, flag):
        self.flags = self.flags | flag
        
    def clear_flag(self, flag):
        self.set_flag(flag)
        self.flags = self.flags - flag
        
    def __str__(self):
        return "flags (NVxBDIZC): %s \na: %s \npc: %s \nx: %s\ny: %s" %\
            (int2bin(self.flags), hex(self.a), hex(self.pc), hex(self.x), hex(self.y))
        
    def step(self, address=None, verbose=True):
        if address is None:
            address = self.pc
        try:
            (name, address_mode, instruction_func, flags_to_set, length) \
                = instruction_table[self.mem[address]]
        except KeyError:
            raise InvalidOpcodeError
        
        # assert correct value on data bus    
        (self.d, self.daddr) = address_mode(self, address)
        
        # advance PC and run instruction
        # (advance PC first so that we can change it in the instruction
        # not all instructions that need to set flags actually set A,
        # so in those cases we write to result, and test that for our flags.
        old_a = self.a
        self.result = None
        self.pc = (address + length) % MAXMEM
        instruction_func(self)
        
        if self.result == None:
            self.result = self.a
        
        # set flags from result
        for flag in flags_to_set:
            if flag == 'n':
                if (self.result & 0x80):
                    self.set_flag(self.N)
                else:
                    self.clear_flag(self.N)
            
            elif flag == 'v':
                # see p28 of 6802 programming manual
                pass
                
            elif flag == 'z':
                if (self.result & 0xff) == 0x0:
                    self.set_flag(self.Z)
                else:
                    self.clear_flag(self.Z)
            
            elif flag == 'c':
                if (self.result & 0x100):
                    self.set_flag(self.V)
                else:
                    self.clear_flag(self.V)
            
            else:
                raise ValueError, "invalid flag to set"
                
        # normalize registers
        self.a = self.a & (2**WIDTH - 1)
        
        # display results
        if verbose:
            print "[%s]: %s(%s) a=%s" % (hex(address), name, self.d, self.a)
            
        # for future expansion, return false to stop
        return True
        