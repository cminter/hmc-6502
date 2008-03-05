# Author:   Kyle Marsh <kmarsh@cs.hmc.edu>, Harvey Mudd College
# Date:     04 March 2008
#
#   IN:
#       *argv[1]                # List of lines destined for control.sv with
#                               # next-state labels instead of numbers
#       *6502.ucode.compiled    # File containing state labels and their
#                               # corresponding number in decimal
#
#   OUT:
#       *tranlsated_opcodes.txt # List of lines for control.sv with
#                               # next-state numbers in place
#
#   THIS CODE DOES NOT YET WORK.  DO NOT DEPEND ON IT YET

help = """opcode_label2bin:
    Translation script to replace next-state names with their corresponding
    numbers as defined in 6502.ucode.compiled.
"""

import re
import sys

# Number of bits in binary representation of the state:
NUMBITS = 8

def usage():
    sys.stderr.write(help)

def int2bin(n, count=8):
    """returns the binary of integer n, using count number of digits"""
    return "".join([str((n >> y) & 1) for y in range(count-1, -1, -1)])

def main():

    # Open the input file in a semi-robust manner.
    try:
        infilename = sys.argv[1]
    except IndexError:
        usage()
        sys.stderr.write('Please provide the input filename as the first\
                argument on the command line.\n')
        sys.exit(1)

    # HACK: Debug mode turned on when command line contains anything after
    # the input file name.
    try:
        d = sys.argv[2]
        debug = True
    except IndexError:
        debug = False

    try:
        if debug: sys.stderr.write('Opening file %s...' %infilename)
        infile = open(infilename)
    except IOError:
        usage()
        sys.stderr.write('Provided filename not valid.\n')
        sys.exit(1)
    
    if debug: sys.stderr.write('succeeded!\n')
    # Hard-coded relative path to ucode file
    namefile = open('../src/ucode/6502.ucode.compiled')
    name_list = namefile.readlines()
    
    # Magic list comprehension to suck out the lines with the labels and
    # numbers.  First chop off the leading comments which get in the way.
    name_list = name_list[4:]
    name_list = [line.strip('// ').strip() for line in name_list if
            line.startswith('// ')]

    # First part of each element is the key, second is the value; turn it
    # into a dictionary.
    name_dict = {}
    for line in name_list:
        line = line.split(':')
        name_dict[line[1]] = int2bin(int(line[1]), NUMBITS)

    # Read and parse the input list.  Uses an even more magic list
    # comprehension that matches one of the values in name_dict against each
    # line and replaces it with its corresponding value
    input_list = infile.readlines()
    output_list = [re.sub(pat, name_dict[pat], line) for line in input_list
            for pat in name_dict if re.search(pat, line)]

    # Write out the new file.
    outfile = open('translated_opcodes.txt', 'w')
    output_string = ''.join(output_list)
    outfile.write(output_string)
    outfile.close()



if __name__ == "__main__":
    main()

