# ucasm.py
# microcode assembler for 6502
# tbarr@cs.hmc.edu, 28oct2007

import sys

class ParseError(Exception):
    pass

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
                           'a_h_lat' : "0",
                           'a_l_lat' : "0",
                           'memwrite' : "0"}
    
    def parse_line(self):
        fields_parsed = self.fields.split('\t')
        vals_parsed = self.vals.split('\t')
        if not len(fields_parsed) == len(vals_parsed):
            raise (ParseError, "field mismatch")
        for (attr, value) in zip(fields_parsed, vals_parsed):
            if not attr in self.in_states.keys():
                raise (ParseError, "invalid field: %s" % attr)
            self.in_states[attr] = value
            
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
    
    # now parse and generate the blocks
    for state in block[2]:
        state.parse_line()
    print block
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