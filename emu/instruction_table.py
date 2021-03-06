# instruction_table.py
# opcode map
# 30sep07, tbarr@cs.hmc.edu

from instructions import *
from branches import *
from stack import *

# flag constants
# THIS IS BAD, WE'RE REPEATING THIS
C = 1<<0
Z = 1<<1
I = 1<<2
D = 1<<3
B = 1<<4
# bit 5 is expansion
V = 1<<6
N = 1<<7

instruction_table = {
    # automated generation
    0x69:('adc', imm, adc, 'nvzc', 2),
    0x65:('adc', zpg, adc, 'nvzc', 2),
    0x75:('adc', zpx, adc, 'nvzc', 2),
    0x6d:('adc', abs, adc, 'nvzc', 3),
    0x7d:('adc', abx, adc, 'nvzc', 3),
    0x79:('adc', aby, adc, 'nvzc', 3),
    0x61:('adc', idx, adc, 'nvzc', 2),
    0x71:('adc', idy, adc, 'nvzc', 2),
    0x29:('and', imm, and_op, 'nz', 2),
    0x25:('and', zpg, and_op, 'nz', 2),
    0x35:('and', zpx, and_op, 'nz', 2),
    0x2d:('and', abs, and_op, 'nz', 3),
    0x3d:('and', abx, and_op, 'nz', 3),
    0x39:('and', aby, and_op, 'nz', 3),
    0x21:('and', idx, and_op, 'nz', 2),
    0x31:('and', idy, and_op, 'nz', 2),
    0x0a:('asl', acc, asl, 'nzc', 1),
    0x06:('asl', zpg, asl, 'nzc', 2),
    0x16:('asl', zpx, asl, 'nzc', 2),
    0x0e:('asl', abs, asl, 'nzc', 3),
    0x1e:('asl', abx, asl, 'nzc', 3),
    0x24:('bit', zpg, bit, 'z', 2), # flags not set in usual way
    0x2c:('bit', abs, bit, 'z', 3),
    0xc9:('cmp', imm, cmp, 'nzc', 2),
    0xc5:('cmp', zpg, cmp, 'nzc', 2),
    0xd5:('cmp', zpx, cmp, 'nzc', 2),
    0xcd:('cmp', abs, cmp, 'nzc', 3),
    0xdd:('cmp', abx, cmp, 'nzc', 3),
    0xd9:('cmp', aby, cmp, 'nzc', 3),
    0xc1:('cmp', idx, cmp, 'nzc', 2),
    0xd1:('cmp', idy, cmp, 'nzc', 2),
    0xe0:('cpx', imm, cpx, 'nzc', 2),
    0xe4:('cpx', zpg, cpx, 'nzc', 2),
    0xec:('cpx', abs, cpx, 'nzc', 3),
    0xc0:('cpy', imm, cpy, 'nzc', 2),
    0xc4:('cpy', zpg, cpy, 'nzc', 2),
    0xcc:('cpy', abs, cpy, 'nzc', 3),
    0xc6:('dec', zpg, dec, 'nz', 2),
    0xd6:('dec', zpx, dec, 'nz', 2),
    0xce:('dec', abs, dec, 'nz', 3),
    0xde:('dec', abx, dec, 'nz', 3),
    0x49:('eor', imm, eor, 'nz', 2),
    0x45:('eor', zpg, eor, 'nz', 2),
    0x55:('eor', zpx, eor, 'nz', 2),
    0x4d:('eor', abs, eor, 'nz', 3),
    0x5d:('eor', abx, eor, 'nz', 3),
    0x59:('eor', aby, eor, 'nz', 3),
    0x41:('eor', idx, eor, 'nz', 2),
    0x51:('eor', idy, eor, 'nz', 2),
    0xe6:('inc', zpg, inc, 'nz', 2),
    0xf6:('inc', zpx, inc, 'nz', 2),
    0xee:('inc', abs, inc, 'nz', 3),
    0xfe:('inc', abx, inc, 'nz', 3),
    0x4c:('jmp', abs, jmp, '', 3),
    0x6c:('jmp', ind, jmp, '', 3),
    0x20:('jsr', abs, jsr, '', 3),
    0xa9:('lda', imm, lda, 'nz', 2),
    0xa5:('lda', zpg, lda, 'nz', 2),
    0xb5:('lda', zpx, lda, 'nz', 2),
    0xad:('lda', abs, lda, 'nz', 3),
    0xbd:('lda', abx, lda, 'nz', 3),
    0xb9:('lda', aby, lda, 'nz', 3),
    0xa1:('lda', idx, lda, 'nz', 2),
    0xb1:('lda', idy, lda, 'nz', 2),
    0xa2:('ldx', imm, ldx, 'nz', 2),
    0xa6:('ldx', zpg, ldx, 'nz', 2),
    0xb6:('ldx', zpy, ldx, 'nz', 2),
    0xae:('ldx', abs, ldx, 'nz', 3),
    0xbe:('ldx', aby, ldx, 'nz', 3),
    0xa0:('ldy', imm, ldy, 'nz', 2),
    0xa4:('ldy', zpg, ldy, 'nz', 2),
    0xb4:('ldy', zpx, ldy, 'nz', 2),
    0xac:('ldy', abs, ldy, 'nz', 3),
    0xbc:('ldy', abx, ldy, 'nz', 3),
    0x4a:('lsr', acc, lsr, 'nzc', 1),
    0x46:('lsr', zpg, lsr, 'nzc', 2),
    0x56:('lsr', zpx, lsr, 'nzc', 2),
    0x4e:('lsr', abs, lsr, 'nzc', 3),
    0x5e:('lsr', abx, lsr, 'nzc', 3),
    0x09:('ora', imm, ora, 'nz', 2),
    0x05:('ora', zpg, ora, 'nz', 2),
    0x15:('ora', zpx, ora, 'nz', 2),
    0x0d:('ora', abs, ora, 'nz', 3),
    0x1d:('ora', abx, ora, 'nz', 3),
    0x19:('ora', aby, ora, 'nz', 3),
    0x01:('ora', idx, ora, 'nz', 2),
    0x11:('ora', idy, ora, 'nz', 2),
    0x2a:('rol', acc, rol, 'nzc', 1),
    0x26:('rol', zpg, rol, 'nzc', 2),
    0x36:('rol', zpx, rol, 'nzc', 2),
    0x2e:('rol', abs, rol, 'nzc', 3),
    0x3e:('rol', abx, rol, 'nzc', 3),
    0x6a:('ror', acc, ror, 'nzc', 1),
    0x66:('ror', zpg, ror, 'nzc', 2),
    0x76:('ror', zpx, ror, 'nzc', 2),
    0x6e:('ror', abs, ror, 'nzc', 3),
    0x7e:('ror', abx, ror, 'nzc', 3),
    0xe9:('sbc', imm, sbc, 'nvzc', 2),
    0xe5:('sbc', zpg, sbc, 'nvzc', 2),
    0xf5:('sbc', zpx, sbc, 'nvzc', 2),
    0xed:('sbc', abs, sbc, 'nvzc', 3),
    0xfd:('sbc', abx, sbc, 'nvzc', 3),
    0xf9:('sbc', aby, sbc, 'nvzc', 3),
    0xe1:('sbc', idx, sbc, 'nvzc', 2),
    0xf1:('sbc', idy, sbc, 'nvzc', 2),
    0x85:('sta', zpg, sta, '', 2),
    0x95:('sta', zpx, sta, '', 2),
    0x8d:('sta', abs, sta, '', 3),
    0x9d:('sta', abx, sta, '', 3),
    0x99:('sta', aby, sta, '', 3),
    0x81:('sta', idx, sta, '', 2),
    0x91:('sta', idy, sta, '', 2),
    0x86:('stx', zpg, stx, '', 2),
    0x96:('stx', zpy, stx, '', 2),
    0x8e:('stx', abs, stx, '', 3),
    0x84:('sty', zpg, sty, '', 2),
    0x94:('sty', zpx, sty, '', 2),
    0x8c:('sty', abs, sty, '', 3),
    
    # manually entered
    0x00:('brk', imm, brk, '', 2),
    0xea:('nop', imm, lambda x: None.__init__, '', 2),
    
    # flag instructions
    0x18:('clc', imp, lambda x: x.clear_flag(x.C), '', 1),
    0x38:('sec', imp, lambda x: x.set_flag(x.C), '', 1),
    0x58:('cli', imp, lambda x: x.clear_flag(x.I), '', 1),
    0x78:('sei', imp, lambda x: x.set_flag(x.I), '', 1),
    0xb8:('clv', imp, lambda x: x.clear_flag(x.V), '', 1),
    0xd8:('cld', imp, lambda x: x.clear_flag(x.D), '', 1),
    0xf8:('sed', imp, lambda x: x.set_flag(x.D), '', 1),
    
    # register instructions
    0xaa:('tax', imp, tax, 'nz', 1),
    0x8a:('txa', imp, txa, 'nz', 1),
    0xca:('dex', imp, dex, 'nz', 1),
    0xe8:('inx', imp, inx, 'nz', 1),
    0x98:('tya', imp, tya, 'nz', 1),
    0xa8:('tay', imp, tay, 'nz', 1),
    0x88:('dey', imp, dey, 'nz', 1),
    0xc8:('iny', imp, iny, 'nz', 1),
    
    # branch instructions
    0x10:('bpl', imm, make_branch(N, False), '', 2),
    0x30:('bmi', imm, make_branch(N, True), '', 2),
    0x50:('bvc', imm, make_branch(V, False), '', 2),
    0x70:('bvs', imm, make_branch(V, True), '', 2),
    0x90:('bcc', imm, make_branch(C, False), '', 2),
    0xB0:('bcs', imm, make_branch(C, True), '', 2),
    0xD0:('bne', imm, make_branch(Z, False), '', 2),
    0xf0:('beq', imm, make_branch(Z, True), '', 2),
    
    # stack instructions:
    0x9a:('txs', imp, txs, '', 1),
    0xba:('tsx', imp, tsx, '', 1),
    0x48:('pha', imp, pha, '', 1),
    0x68:('pla', imp, pla, '', 1),
    0x08:('php', imp, php, '', 1),
    0x28:('plp', imp, plp, '', 1),
    0x60:('rts', imp, rts, '', 1),
    0x40:('rti', imp, rti, '', 1)
}