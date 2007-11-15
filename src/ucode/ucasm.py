# ucasm.py
# microcode assembler for 6502
# tbarr@cs.hmc.edu, 28oct2007

import sys
from odict import OrderedDict

class ParseError(Exception):
    pass

def int2bin(n, count=8):
    """returns the binary of integer n, using count number of digits"""
    return "".join([str((n >> y) & 1) for y in range(count-1, -1, -1)])

class State:
    def __init__(self):
        self.state_num = None
        self.next_state = None
        self.vals = ""
        self.fields = ""
    
        # input state table
        self.in_states = { 'a_sel' : None,
                           'b_sel' : None,
                           'alu_op' : "pass",
                           'write_en' : "none",
                           'pc_w_en' : "0",
                           'pc_sel' : "pc_next",
                           'a_h_sel' : "pc_next",
                           'a_l_sel' : "pc_next",
                           'th_lat' : "0",
                           'tl_lat' : "0",
                           'memwrite' : "0",
                           'flag' : "0"}
                           
        self.out_states = OrderedDict([
                           ('th_in_en', '0'), # done
                           ('th_out_en', '0'), 
                           ('tl_in_en', '0'),  # done
                           ('tl_out_en', '0'), 
                           ('p_in_en', '00000000'), 
                           ('p_out_en', '0'), 
                           ('p_sel', '0'), 
                           ('reg_write_en', '0'), 
                           ('reg_read_addr_a', '00'), 
                           ('reg_read_addr_b', '00'), 
                           ('reg_write_addr', '00'), 
                           ('reg_a_en', '0'), 
                           ('pch_in_en', '0'), 
                           ('pch_out_en', '0'), 
                           ('pcl_in_en', '0'), 
                           ('pcl_out_en', '0'), 
                           ('pc_inc_en', '0'), 
                           ('pc_sel', '0'), 
                           ('d_in_en', '0'), # done
                           ('d_out_sel', '0'), 
                           ('ah_sel', '00'), 
                           ('al_sel', '0'), 
                           ('alu_op', '0000'), 
                           ('c_temp_en', '0'), 
                           ('carry_sel', '0')])
    
    def parse_line(self):
        fields_parsed = self.fields.split('\t')
        vals_parsed = self.vals.split('\t')
        if not len(fields_parsed) == len(vals_parsed):
            raise ParseError, "field mismatch"
        for (attr, value) in zip(fields_parsed, vals_parsed):
            if not attr in self.in_states.keys():
                raise ParseError, "invalid field: %s" % attr
            self.in_states[attr] = value
    
    def make_line(self):
        # parse all the fields
        if '1' in self.in_states['th_lat']:
            self.out_states['th_in_en'] = '1'
        if '1' in self.in_states['tl_lat']:
            self.out_states['tl_in_en'] = '1'
        if 'db' in self.in_states['a_sel']:
            self.out_states['d_in_en'] = '1'
            
        return '_'.join(self.out_states.values())
        
    def __repr__(self):
        return "state %s: %s" % (self.state_num, self.in_states)

def process_block(block, next_state_num):
    # assign everybody a state num
    for state in block[2]:
        state.state_num = next_state_num
        state.next_state = next_state_num + 1
        next_state_num += 1
    # go back to base state on last
    block[2][-1].next_state = 0
    print ""
    print "// %s" % block[0]
    
    # now parse and generate the blocks
    for state in block[2]:
        state.parse_line()
        print state.make_line()
    # print block
    return next_state_num

def do_file():
    f = open(sys.argv[1])
    current_block = [None, "", []]
    next_state_num = 0

    for line in f:
        if line[0] in ['#', '\n']:
            # ignore comments
            continue
        elif line.strip()[-1] == ':':
            # finish old block
            if current_block[0]:
                next_state_num = process_block(current_block, next_state_num)
            # set current block
            current_block[2] = []
            current_block[1] = ""
            current_block[0] = line.strip()[:-1]
            continue
        else:
            if not current_block[1]:
                current_block[1] = line.strip()
            else:
                new_state = State()
                new_state.fields = current_block[1]
                new_state.vals = line.strip()
                current_block[2].append(new_state)
            
    # one left...
    next_state_num = process_block(current_block, next_state_num)
    
if __name__ == "__main__":
    do_file()