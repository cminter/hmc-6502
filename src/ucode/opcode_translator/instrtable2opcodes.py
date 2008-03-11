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
        <reg_a_en>_<reg_b_en>__FIXME:<?>_<?>_<next_state_label>;
"""

import re
import sys
import os

# Number of bits in binary representation of the state; if we can extract
# this from the label file we shoud do so:
NUMBITS = 8

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
    input_list = [line for line in input_list if len(line) == 7]
    for line in input_list:
        line[6] = line[6][0]

    #FIXME: Generate the control signals.
    # Write the lines of output based on the input:
    outfile = open('opcodes.txt', 'w')
    for line in input_list:
        opcode = line[0]
        aluop = int2bin(hex2int(line[6]), 4)
        
        outfile.write("8'h%d: out_data <= 31'b%d_%d_%d_%d_%d_%d_%d_%d__FIXME_FIXME_FIXME;\n"
                %(opcode, aluop, d_in_en, reg_write_en, reg_read_addr_a,
                  reg_read_addr_b, reg_write_addr, reg_a_en, reg_b_en))

    outfile.close()

if __name__ == "__main__":
    main()

