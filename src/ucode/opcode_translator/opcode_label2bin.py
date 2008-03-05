# Author:   Kyle Marsh <kmarsh@cs.hmc.edu>, Harvey Mudd College
# Date:     04 March 2008
#
#   IN:
#       *argv[1]                # List of lines destined for control.sv with
#                               # next-state labels instead of numbers.
#       *6502.ucode.compiled    # File containing state labels and their
#                               # corresponding number in decimal.
#       *argv[2]                # Optional expected output file for testing.
#
#   OUT:
#       *tranlsated_opcodes.txt # List of lines for control.sv with
#                               # next-state numbers in place
#       *out.diff               # If argv[2] supplied and valid, contains
#                               # `diff translated_opcodes.txt argv[2]'
#
#   NOTES:
#       This code reads and writes to files instead of standard IO because it
#       may be run on Windows machines and I don't know how the Windows shell
#       handles IO redirection.
#
#   THIS CODE DOES NOT YET WORK.  DO NOT DEPEND ON IT YET

help = """Useage: python opcode_label2bin.py infile [expected_output]
Translation script to replace next-state names in lines of the input file with
their corresponding numbers as defined in 6502.ucode.compiled.

If the optional expected_output file is included, this is compared against
the output of the script using diff and the result is sent to out.diff.  If
diff does not produce output the script prints the message "The actual
output matches the expected output." to stderr.

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
    
    # Providing a second filename on the command line initiates debug mode
    # which will diff the output against the expected output and save the
    # result of that in out.diff.  This is *nix specific, I think.
    try:
        expectedoutfilename = sys.argv[2]
        debug = True
        try:
            expectedoutfile = os.access(expectedoutfilename, os.R_OK)
        except IOError:
            usage()
            sys.stderr.write('%s is not a valid file.\n' %infilename)
            sys.exit(1)
    except IndexError:
        debug = False

    # Hard-coded relative path to ucode file
    namefile = open('../6502.ucode.compiled')
    name_list = namefile.readlines()
    namefile.close()
    
    # Suck out the lines with the labels and numbers.  First chop off the
    # leading comments which get in the way.  Assumes we know a significant
    # amount about the format of 6502.ucode.compiled.
    name_list = name_list[4:]
    name_list = [line.strip('// ').strip() for line in name_list if
            line.startswith('// ')]

    if debug: # Write the list of labels to a file.
        namelistoutfile = open('labels_list.txt', 'w')
        namelistoutfile.write('\n'.join(name_list))
        namelistoutfile.close()

    # First part of each element is the key, second is the value; turn it
    # into a dictionary.  All non alphanumeric characters in thekey are
    # escaped to make it regex-safe later.
    name_dict = {}
    for line in name_list:
        line = line.split(':')
        name_dict[re.escape(line[0])] = int2bin(int(line[1]), NUMBITS)

    if debug: # Write the dictionary of labels to a file.
        namedictoutfile = open('labels_dict.txt', 'w')
        dictstr = ''
        for elem in name_dict:
            dictstr += str(elem) + ':' + str(name_dict[elem]) + '\n'
        namedictoutfile.write(dictstr)
        namedictoutfile.close()

    # Read and parse the input list.  Uses an even more magic list
    # comprehension that matches one of the values in name_dict against each
    # line and replaces it with its corresponding value.
    # Note: this assumes that each input line has the format '^.*pat;$' in
    # order to avoid something like 'abs' matching 'abs_x'.
    input_list = infile.readlines()
    infile.close()
    output_list = [re.sub(pat, name_dict[pat], line) for line in input_list
            for pat in name_dict if re.search(pat + ';$', line)]

    # Write out the new file.
    outfile = open('translated_opcodes.txt', 'w')
    output_string = ''.join(output_list)
    outfile.write(output_string)
    outfile.close()

    if debug: # Diff the output against the expected output.
        os.system('diff %s translated_opcodes.txt > out.diff'
                %expectedoutfilename)
        if not os.stat('out.diff').st_size:
            sys.stderr.write("Actual output matches expected output.\n")
            os.unlink('out.diff')
        else:
            sys.stderr.write("Actual output differs from expected output:\n")
            os.execlp('cat', 'cat', 'out.diff')


if __name__ == "__main__":
    main()

