# ucasm.py
# microcode assembler for 6502
# tbarr@cs.hmc.edu, 28oct2007

import sys
from odict import OrderedDict

BASE_STATE = 4

class ParseError(Exception):
    pass

def int2bin(n, count=8):
    """returns the binary of integer n, using count number of digits"""
    return "".join([str((n >> y) & 1) for y in range(count-1, -1, -1)])

def hex2bin(s):
    try:
        i = int(s.split('x')[1], 16)
    except IndexError:
        raise ParseError, "invalid hex string"
    return int2bin(i)

class Vector:
    groups = OrderedDict([('state', None),
                          ('opcode', None),
                          ('internal', None)])
    
    def __init__(self):
        self.groups['state'] = OrderedDict([
                           ('th_in_en', '0'),
                           ('th_out_en', '0'), 
                           ('tl_in_en', '0'),
                           ('tl_out_en', '0'), 
                           ('p_sel', '0'),
                           ('p_out_en', '0'),  
                           ('pch_in_en', '0'), 
                           ('pch_out_en', '0'), 
                           ('pcl_in_en', '0'), 
                           ('pcl_out_en', '0'), 
                           ('pc_inc_en', '1'), 
                           ('pc_sel', '0'), 
                           ('d_out_sel', '0'), 
                           ('ah_sel', '000'), 
                           ('al_sel', '00'), 
                           ('c_temp_en', '0'), 
                           ('carry_sel', '00'),
                           ('flag_en', '0'),
                           ('read_en', '1'),
                           ('constant_en', '0'),
                           ('constant', '00000000')])
        self.groups['opcode'] = OrderedDict([
                           ('alu_op', '0000'),
                           ('d_in_en', '0'), 
                           ('reg_write_en', '0'), 
                           ('reg_read_addr_a', '00'), 
                           ('reg_read_addr_b', '00'), 
                           ('reg_write_addr', '00'), 
                           ('reg_a_en', '0'),
                           ('reg_b_en', '0')])
        self.groups['internal'] = OrderedDict([
                           ('last_cycle', '0'),
                           ('func_mode', '0'),
                           ('next_source', '00'),
                           ('next_state', '00000000')])
    
    def bin_rep(self):
        parts = ["".join(group.values()) for group in self.groups.values()]
        return "_".join(parts)
    
    def total_len(self):
        return len(self.bin_rep().replace('_',''))
    
    def __setattr__(self, name, value):
        for group in self.groups.values():
            if name in group.keys():
                group[name] = value

class State:
    def __init__(self):
        self.state_num = None
        self.next_state = None
        self.last_state = False
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
                           'pcinc' : '1',
                           'sta_src' : '00',
                           'last_cy' : '1',
                           'nxt_src': '0'}
        self.out = Vector()
        
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
        # parse all the fieldsself.out.
        if '1' in self.in_states['th_lat']:
            self.out.th_in_en = '1'
        if '1' in self.in_states['tl_lat']:
            self.out.tl_in_en = '1'
        if 'db' in self.in_states['a_sel']:
            self.out.d_in_en = '1'
        if 'tl' == self.in_states['a_sel']:
            self.out.tl_out_en = '1'
        if 'th' == self.in_states['a_sel']:
            self.out.th_out_en = '1'
        if 'sp' == self.in_states['a_sel']:
            self.out.reg_read_addr_a = '11'
            self.out.reg_a_en = '1'
        if '0x' in self.in_states['a_sel']:
            self.out.constant_en = '1'
            self.out.constant = hex2bin(self.in_states['a_sel'])

	if 'a' == self.in_states['b_sel']:
            self.out.reg_read_addr_b = '00'
            self.out.reg_b_en = '1'            
        if 'x' == self.in_states['b_sel']:
            self.out.reg_read_addr_b = '01'
            self.out.reg_b_en = '1'
        if 'y' == self.in_states['b_sel']:
            self.out.reg_read_addr_b = '10'
            self.out.reg_b_en = '1'
        if 'pc_h' == self.in_states['b_sel']:
            self.out.pch_out_en = '1'
        if 'pc_l' == self.in_states['b_sel']:
            self.out.pcl_out_en = '1'
        if 'sp' == self.in_states['wrt_en']:
            self.out.reg_write_addr = '11'
            self.out.reg_write_en = '1'
        if 'p' == self.in_states['wrt_en']:
            self.out.p_sel = '1'
            self.out.flag_en = '1'
        if 'a'== self.in_states['wrt_en']:
            self.out.reg_write_addr = '00'
            self.out.reg_write_en = '1'
        if '1' == self.in_states['pc_w_en']:
            self.out.pch_in_en = '1'
            self.out.pcl_in_en = '1'
        if '10' == self.in_states['pc_w_en']:
            self.out.pch_in_en = '1'
        if '01' == self.in_states['pc_w_en']:
            self.out.pcl_in_en = '1'
        if 'r' == self.in_states['pc_sel']:
            self.out.pc_sel = '1'
            
        if 'b' == self.in_states['nxt_src']:
            self.out.next_source = '10'
        
        # address selection
        if 'r' == self.in_states['a_h_sel']:
            self.out.ah_sel = '001' #a1
        if 'temp' == self.in_states['a_h_sel']:
            self.out.ah_sel = '010' #a2
        if '0' == self.in_states['a_h_sel']:
            self.out.ah_sel = '100' #a3
        if '1' == self.in_states['a_h_sel']:
            self.out.ah_sel = '101' #a4
        if 'r' == self.in_states['a_l_sel']:
            self.out.al_sel = '01'
        if 'temp' == self.in_states['a_l_sel']:
            self.out.al_sel = '10'
        if '1' == self.in_states['memwri']:
            self.out.read_en = '0' # high on READ.    
        
        # other latches
        if '1' == self.in_states['tl_lat']:
            self.out.tl_in_en = '1'
        if '1' == self.in_states['th_lat']:
            self.out.th_in_en = '1'
            
        if 'b' == self.in_states['memwri']:
            self.out.read_en = '0'
            self.out.d_out_sel = '1'
        if 'r' == self.in_states['memwri']:
            self.out.read_en = '0'
            self.out.d_out_sel = '0'
            
        if '1' == self.in_states['pcinc']:
            self.out.pc_inc_en = '1'
        if '0' == self.in_states['pcinc']:
            self.out.pc_inc_en = '0'
        if '1' == self.in_states['flag']:
            self.out.flag_en = '1'
        if 't' == self.in_states['flag']:
            self.out.flag_en = '0'
            self.out.c_temp_en = '1'
            
        # todo: flag selection, flag enable, branch enable
        if 'pass' == self.in_states['alu_op']:
            self.out.alu_op = int2bin(0x0, 4)
            self.out.carry_sel = '10'
        if 'inc' == self.in_states['alu_op']:
            self.out.alu_op = int2bin(0x0, 4)
            self.out.carry_sel = '11'
        if 'pass+t' == self.in_states['alu_op']:
            self.out.alu_op = int2bin(0x0, 4)
            self.out.carry_sel = '01'
        if 'add' == self.in_states['alu_op']:
            self.out.alu_op = int2bin(0x2, 4)
            self.out.carry_sel = '10'
        if 'add+1' == self.in_states['alu_op']:
            self.out.alu_op = int2bin(0x2, 4)
            self.out.carry_sel = '11'
        if 'add+t' == self.in_states['alu_op']:
            self.out.alu_op = int2bin(0x2, 4)
            self.out.carry_sel = '01'
        if 'dec' == self.in_states['alu_op']:
            self.out.alu_op = int2bin(0x1, 4)
            self.out.carry_sel = '11'
            
        if 'opcode' == self.in_states['sta_src']:
            self.out.next_source = '01'
        if 'func' in self.in_states.values():
            self.out.func_mode = '1'
        if '0' == self.in_states['last_cy']:
            self.out.last_cycle = '0'
        
    def __repr__(self):
        return "state %s: %s" % (self.state_num, self.in_states)

def process_block(block, next_state_num):
    # assign everybody a state num
    for state in block[2]:
        state.state_num = next_state_num
        state.next_state = next_state_num + 1
        next_state_num += 1
        
    # go back to base state on last
    block[2][-1].next_state = BASE_STATE
    block[2][-1].last_state = True
    
    print ""
    print "// %s:%s" % (block[0], block[2][0].state_num)
    
    # now parse and generate the blocks
    for state in block[2]:
        state.parse_line()
        state.out.__init__()
        if state.last_state:
            state.out.last_cycle = '1'
        state.make_line()
        state.out.next_state = int2bin(state.next_state)
        vector = state.out.bin_rep()
        
        # for use if I'm feeling cruel.
        hex_vector = hex(int(vector.replace('_',''), 2))[2:].replace('L','')
        
        print "8'd%03d : out_controls <= %d'b%s;" % (state.state_num,
                                               state.out.total_len(),
                                               vector)
    # print block
    return next_state_num

def do_file():
    try:
        f = open(sys.argv[1])
    except IndexError:
        f = open('6502.ucode')
    current_block = [None, "", []]
    next_state_num = 0
    
    print "// generated by ucasm"
    sizevec = Vector()
    print "// c_state = %s" % len("".join(sizevec.groups['state'].values()))
    print "// c_op = %s" % len("".join(sizevec.groups['opcode'].values()))
    print "// c_internal = %s" % len("".join(sizevec.groups['internal'].values()))
    
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
    
    print "\n// state signals"
    for signal in sizevec.groups['state'].keys():
        print "//  %s," % signal
    print "\n// op signals"
    for signal in sizevec.groups['opcode'].keys():
        print "//  %s," % signal
    
if __name__ == "__main__":
    do_file()
