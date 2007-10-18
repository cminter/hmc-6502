# simplemachine.py
# loads into offset 0 contents of test vector, and runs with
# verbose mode on

import cpu
import sys

m = cpu.Machine()
m.mem.load_from_file(sys.argv[1], offset=0x200)
m.mem[0xfffd] = 0x02
m.mem[0xfffc] = 0x00
m.reset()
running = True
while running:
    running = m.step()
    