# simplemachine.py
# loads into offset 0 contents of test vector, and runs with
# verbose mode on

import cpu
import sys

m = cpu.Machine()
m.mem.load_from_file(sys.argv[1], offset=0x200)
m.pc = 0x200
running = True
while running:
    running = m.step()
    