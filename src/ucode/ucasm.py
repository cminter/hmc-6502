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
                           'wrt_en' : "none",
                           'pc_w_en' : "0",
                           'pc_sel' : "pc_n",
                           'a_h_sel' : "pc_n",
                           'a_l_sel' : "pc_n",
                           'th_lat' : "0",
                           'tl_lat' : "0",
                           'memwri' : "0",
                           'flag' : "0",
                           'pcinc' : '1'}
                           
        self.out_states = OrderedDict([
                           ('th_in_en', '0'), # done
                           ('th_out_en', '0'), 
                           ('tl_in_en', '0'),  # done
                           ('tl_out_en', '0'), 
                           ('p_out_en', '0'), 
                           ('p_sel', '0'), 
                           ('reg_write_en', '0'), 
                           ('reg_read_addr_a', '00'), 
                           ('reg_read_addr_b', '00'), 
                           ('reg_write_addr', '00'), 
                           ('reg_a_en', '0'), 
                           ('pch_in_en', '0'), 
                           ('pch_out_en_b', '0'), 
                           ('pcl_in_en', '0'), 
                           ('pcl_out_en_b', '0'), 
                           ('pc_inc_en', '1'), 
                           ('pc_sel', '0'), 
                           ('d_in_en', '0'), # done
                           ('d_out_sel', '0'), 
                           ('ah_sel', '000'), 
                           ('al_sel', '00'), 
                           ('alu_op', '0000'), 
                           ('c_temp_en', '0'), 
                           ('carry_sel', '0'),
                           ('mem_rw', '1')])
    
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
        if 'tl' == self.in_states['a_sel']:
            self.out_states['tl_out_en'] = '1'
        if 'th' == self.in_states['a_sel']:
            self.out_states['th_out_en'] = '1'
        if 'sp' == self.in_states['a_sel']:
            self.out_states['reg_read_addr_a'] = '11'
            self.out_states['reg_a_en'] = '1'
        if 'x' == self.in_states['b_sel']:
            self.out_states['reg_read_addr_b'] = '01'
        if 'y' == self.in_states['b_sel']:
            self.out_states['reg_read_addr_b'] = '10'
        if 'pc_h' == self.in_states['b_sel']:
            self.out_states['pch_out_en_b'] = '1'
        if 'pc_l' == self.in_states['b_sel']:
            self.out_states['pcl_out_en_b'] = '1'
        if 'sp' == self.in_states['wrt_en']:
            self.out_states['reg_write_addr'] = '11'
            self.out_states['reg_write_en'] = '1'
        if '1' == self.in_states['pc_w_en']:
            self.out_states['pch_in_en'] = '1'
            self.out_states['pcl_in_en'] = '1'
        if '10' == self.in_states['pc_w_en']:
            self.out_states['pch_in_en'] = '1'
        if '01' == self.in_states['pc_w_en']:
            self.out_states['pcl_in_en'] = '1'
        if 'r' == self.in_states['pc_sel']:
            self.out_states['pc_sel'] = '1'
        
        # address selection
        if 'r' == self.in_states['a_h_sel']:
            self.out_states['ah_sel'] = '001'
        if 'temp' == self.in_states['a_h_sel']:
            self.out_states['ah_sel'] = '010'
        if '0' == self.in_states['a_h_sel']:
            self.out_states['ah_sel'] = '100'
        if '1' == self.in_states['a_h_sel']:
            self.out_states['ah_sel'] = '101'
        if 'ff' == self.in_states['a_h_sel']:
            self.out_states['ah_sel'] = '111'
        if 'r' == self.in_states['a_l_sel']:
            self.out_states['al_sel'] = '10'
        if 'temp' == self.in_states['a_l_sel']:
            self.out_states['al_sel'] = '11'
            
        # other latches
        if '1' == self.in_states['tl_lat']:
            self.out_states['tl_in_en'] = '1'
        if '1' == self.in_states['th_lat']:
            self.out_states['th_in_en'] = '1'
            
        if '1' == self.in_states['memwri']:
            self.out_states['mem_rw'] = '0'
            
        if '0' == self.in_states['pcinc']:
            self.out_states['pc_inc_en'] = '1'
            
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
        if line.strip() == '':
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