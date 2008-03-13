# Author:   Kyle Marsh <kmarsh@cs.hmc.edu>, Harvey Mudd College
# Date:     11 March 2008
#
#   IN:
#       *argv[1]                # Table of instructions including opcode,
#                               # instruction name, addressing mode, srcA,
#                               # srcB, dest, and aluop.
#
#   OUT:
#       *opcodes.txt            # list of opcodes generated from the table
#                               # with next-state labels instead of numbers.
#
#   NOTES:
#       *The opcode output is system verilog in the following form:
#           8'hXX: out_data <= 31'b<aluop>_<d_in_en>_<reg_write_en>_
#               <reg_read_addr_a>_<reg_read_addr_b>_<reg_write_addr>_
#               <reg_a_en>_<reg_b_en>__FIXME:<?>_<?>_<next_state_label>;
#
#       *This code reads and writes to files instead of standard IO because it
#       may be run on Windows machines and I don't know how the Windows shell
#       handles IO redirection.
#
#   THIS CODE DOES NOT YET WORK.  DO NOT DEPEND ON IT YET

help = """Useage: python instrtable2opcodes.py infile.txt
Script to take in a table of instructions and generate lines of verilog to
be included in the case statement of the opcode_pla module in control.sv.

Output lines are in the following form:
    8'hXX: out_data <= 31'b<aluop>_<d_in_en>_<reg_write_en>_
        <reg_read_addr_a>_<reg_read_addr_b>_<reg_write_addr>_
        <reg_a_en>_<reg_b_en>__<branch_polarity>_<flags>_<state_label>;
"""

import re
import sys
import os

# Global Constants
FIELDS = 9
OPCODE = 0
INSTR = 1
STATE = 2
SRCA = 3
SRCB = 4
DEST = 5
ALUOP = 6
BP = 7
FLAGS = 8

def usage():
    sys.stderr.write(help)

def int2bin(n, count=8):
    """returns the binary of integer n, using count number of digits"""
    return "".join([str((n >> y) & 1) for y in range(count-1, -1, -1)])

def hex2int(n):
    """fairly hacky function to convert a hex number in a string to an int."""
    hex = {'a':10, 'b':11, 'c':12, 'd':13, 'e':14, 'f':15}
    sum = 0
    for i in range(len(n)):
        if hex.__contains__(n[i]):
            sum += 16**(len(n)-i-1)*hex[n[i]]
        else:
            sum += 16**(len(n)-i-1)*int(n[i])
    return sum

def main():

    # Open the input file in a semi-robust manner.
    try:
        infilename = sys.argv[1]
    except IndexError:
        usage()
        sys.stderr.write('Please provide the input filename as the first '
                + 'argument on the command line.\n')
        sys.exit(1)
    try:
        infile = open(infilename)
    except IOError:
        usage()
        sys.stderr.write('%s is not a valid file.\n' %infilename)
        sys.exit(1)
    
    # Read the input file into a list, split the list on tab characters,
    # and throw away lines that do not contain 7 fields. Finally, trim the
    # last field to only one character in case it contains comments.
    input_list = [line.split('\t') for line in infile.readlines()]
    input_list = [line for line in input_list if len(line) == FIELDS]

    for line in input_list:
        line[ALUOP] = line[ALUOP][0]
        line[FLAGS] = line[FLAGS][0:2]

    # Write the lines of output based on the input:
    outfile = open('opcodes.txt', 'w')
    for line in input_list:
        opcode = str(line[OPCODE])
        aluop = str(int2bin(hex2int(line[ALUOP].lower()), 4))
        # If data comes from memory, disable register in:
        if line[SRCA] == 'dp':
            d_in_en = '1'
            reg_a_en = '0'
            reg_read_addr_a = '00'
        # Otherwise, set SrcA to a register:
        elif line[SRCA] == 'A':
            d_in_en = '0'
            reg_a_en = '1'
            reg_read_addr_a = '00'
        elif line[SRCA] == 'X':
            d_in_en = '0'
            reg_a_en = '1'
            reg_read_addr_a = '01'
        elif line[SRCA] == 'Y':
            d_in_en = '0'
            reg_a_en = '1'
            reg_read_addr_a = '10'
        elif line[SRCA] == 'SP':
            d_in_en = '0'
            reg_a_en = '1'
            reg_read_addr_a = '11'

        # Set SrcB:
        if line[SRCB] == '_':
            reg_b_en = '0'
            reg_read_addr_b = '00'
        elif line[SRCB] == 'A':
            reg_b_en = '1'
            reg_read_addr_b = '00'
        elif line[SRCB] == 'X':
            reg_b_en = '1'
            reg_read_addr_b = '01'
        elif line[SRCB] == 'Y':
            reg_b_en = '1'
            reg_read_addr_b = '10'
        elif line[SRCB] == 'SP':
            reg_b_en = '1'
            reg_read_addr_b = '11'

        # Set Dest:
        if line[DEST] == 'A':
            reg_write_en = '1'
            reg_write_addr = '00'
        elif line[DEST] == 'X':
            reg_write_en = '1'
            reg_write_addr = '01'
        elif line[DEST] == 'Y':
            reg_write_en = '1'
            reg_write_addr = '10'
        elif line[DEST] == 'SP':
            reg_write_en = '1'
            reg_write_addr = '11'
        else:
            reg_write_en = '0'
            reg_write_addr = '00'

        branch_polarity = str(line[BP])
        flags = str(int2bin(hex2int(line[FLAGS].lower()), 8))
        label = line[STATE]

        outfile.write("8'h%s: out_data <= 31'b%s_%s_%s_%s_%s_%s_%s_%s__%s_%s_%s;\n"
                %(opcode, aluop, d_in_en, reg_write_en, reg_read_addr_a,
                  reg_read_addr_b, reg_write_addr, reg_a_en, reg_b_en,
                  branch_polarity, flags, label))

    outfile.close()

if __name__ == "__main__":
    main()

