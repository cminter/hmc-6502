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
#   THIS CODE HAS NOT BEEN TESTED: I'VE TESTED ALL THE IMPORTANT BITS, BUT
#   WE MAY STILL NEED TO DEBUG THE FILEIO STUFF.

help = """Translation script to replace next-state names with their
corresponding numbers as defined in 6502.ucode.compiled.
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
        infile = open(sys.argv[1])
    except IndexError:
        usage()
        sys.stderr.write('Please provide the input filename.\n')
        sys.exit(1)
    
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
        name_dict[line[0]] = int2bin(line[1], NUMBITS)

    # Read and parse the input list.  Uses an even more magic list
    # comprehension that matches one of the values in name_dict against each
    # line and replaces it with its corresponding value
    input_list = infile.readlines()
    output_list = [re.sub(pat, dict[pat], line) for line in input_list for
            pat in name_dict if re.search(pat, line)]

    # Write out the new file.
    outfile = open('translated_opcodes.txt', 'w')
    outfile.write(output_list)
    outfile.close()



if __name__ == "__main__":
    main()

