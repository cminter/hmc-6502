// control.sv
// control FSM and opcode ROM for hmc-6502 CPU
// 31oct07
// tbarr at cs hmc edu

`timescale 1 ns / 1 ps
`default_nettype none

// always kept in this order!
parameter C_STATE_WIDTH = 32;
parameter C_OP_WIDTH = 14;
parameter C_INT_WIDTH = 12; // total width of internal state signals

parameter BRANCH_TAKEN_STATE = 8'd87;
parameter BRANCH_NOT_TAKEN_STATE = 8'd4;

parameter C_TOTAL = (C_STATE_WIDTH + C_OP_WIDTH + C_INT_WIDTH);

module control(input logic [7:0] data_in, p,
               input logic ph1, ph2, reset,
               output logic [7:0] p_in_en,
               output logic [(C_STATE_WIDTH + C_OP_WIDTH - 1):0] controls_s1);
               
  // all controls become valid on ph1, and hold through end of ph2.
  logic [7:0] latched_opcode;
  logic first_cycle, last_cycle, c_op_sel, last_cycle_s2;
  
  logic [(C_OP_WIDTH - 1):0] c_op_state, c_op_opcode;
  logic [(C_OP_WIDTH - 1):0] c_op_selected;
  logic [(C_STATE_WIDTH - 1):0] c_state;
  
  logic branch_polarity, branch_taken;
  
  logic [7:0] state, next_state, next_state_states, next_state_opcode;
  logic [7:0] next_state_s2;
  logic [7:0] next_state_branch;
  logic [1:0] next_state_sel;
  
  logic [7:0] op_flags;
  
  // opcode logic
  latch #1 opcode_lat_p1(last_cycle, last_cycle_s2, ph1);
  latch #1 opcode_lat_p2(last_cycle_s2, first_cycle, ph2);
  latchren #8 opcode_buf(data_in, latched_opcode, ph1, first_cycle, reset);
  opcode_pla opcode_pla(latched_opcode, {c_op_opcode, branch_polarity, 
                                         op_flags, next_state_opcode});
  
  // branch logic
  // - p is stable 1, but won't be written on the branch op.
  // - the paranoid would add a latch to make it stable 2.
  branchlogic branchlogic(p, op_flags, branch_polarity, branch_taken);
  mux2 #8 branch_state_sel(BRANCH_NOT_TAKEN_STATE, 
                           BRANCH_TAKEN_STATE, branch_taken, next_state_branch);
  
  // next state logic
  mux3 #8 next_state_mux(next_state_states, next_state_opcode, next_state_branch,
                         next_state_sel, next_state);
  
  // state PLA
  latchr #8 state_lat_p1(next_state, next_state_s2, ph1, reset);
  latchr #8 state_lat_p2(next_state_s2, state, ph2, reset);
  
  state_pla state_pla(state, {c_state, c_op_state, {last_cycle,
                                                    c_op_sel,
                                                    next_state_sel,
                                                    next_state_states}});
  
  and8 flag_masker(op_flags, controls_s1[24], p_in_en);
  
  // opcode specific controls
  mux2 #(C_OP_WIDTH) func_mux(c_op_state, c_op_opcode, c_op_sel, c_op_selected);
  
  // output
  latch #(C_STATE_WIDTH + C_OP_WIDTH) controls_latch({c_state, c_op_selected}, controls_s1,
                        ph1);
endmodule

module state_pla(input logic [7:0] state,
                 output logic [(C_TOTAL - 1):0] out_controls);
  always_comb
  case(state)
      `include "src/ucode/6502.ucode.compiled"
      default: out_controls <= 'x;
    endcase
endmodule

module opcode_pla(input logic [7:0] opcode,
                 output logic [(C_OP_WIDTH + 17 - 1):0] out_data);
  always_comb
  case(opcode)
/*
    8'h69: out_data <= 31'b0010_1_1_00_00_00_0_1__0_00000010_00000111;
    8'h65: out_data <= 31'b0010_1_1_00_00_00_0_1__0_00000000_00001000;
    8'h85: out_data <= 31'b0000_1_0_00_00_00_0_1__0_00000000_00001010;
    8'h8d: out_data <= 31'b0000_1_0_00_00_00_0_1__0_00000000_00001100;
    8'hf0: out_data <= 31'b0010_0_0_00_00_00_0_0__0_00000010_01000010;
    8'hA9: out_data <= 31'b0000_1_1_00_00_00_0_0__0_10000010_00000111;
    8'h49: out_data <= 31'b1010_1_1_00_00_00_0_1__0_10000010_00000111;
    8'hC5: out_data <= 31'b0011_1_0_00_00_00_0_1__0_10000011_00001000;
    8'hD0: out_data <= 31'b0010_1_0_00_00_00_0_0__1_00000010_01000010;
    8'hE5: out_data <= 31'b0011_1_1_00_00_00_0_1__0_11000011_00001000;
*/
8'h69: out_data <= 31'b0010_1_1_00_00_00_0_1__0_11000011_00000111; //adc (imm)
8'h65: out_data <= 31'b0010_1_1_00_00_00_0_1__0_11000011_00001000; //adc (mem_ex_zpa)
8'h75: out_data <= 31'b0010_1_1_00_00_00_0_1__0_11000011_00101011; //adc (zp_x)
8'h6D: out_data <= 31'b0010_1_1_00_00_00_0_1__0_11000011_00011101; //adc (abs)
8'h7D: out_data <= 31'b0010_1_1_00_00_00_0_1__0_11000011_00100101; //adc (abs_x)
8'h79: out_data <= 31'b0010_1_1_00_00_00_0_1__0_11000011_00101000; //adc (abs_y)
8'h61: out_data <= 31'b0010_1_1_00_00_00_0_1__0_11000011_00100000; //adc (indirect_x)
8'h71: out_data <= 31'b0010_1_1_00_00_00_0_1__0_11000011_00110000; //adc (indirect_y)
8'h29: out_data <= 31'b1000_1_1_00_00_00_0_1__0_10000010_00000111; //and (imm)
8'h25: out_data <= 31'b1000_1_1_00_00_00_0_1__0_10000010_00001000; //and (mem_ex_zpa)
8'h35: out_data <= 31'b1000_1_1_00_00_00_0_1__0_10000010_00101011; //and (zp_x)
8'h2D: out_data <= 31'b1000_1_1_00_00_00_0_1__0_10000010_00011101; //and (abs)
8'h3D: out_data <= 31'b1000_1_1_00_00_00_0_1__0_10000010_00100101; //and (abs_x)
8'h39: out_data <= 31'b1000_1_1_00_00_00_0_1__0_10000010_00101000; //and (abs_y)
8'h21: out_data <= 31'b1000_1_1_00_00_00_0_1__0_10000010_00100000; //and (indirect_x)
8'h31: out_data <= 31'b1000_1_1_00_00_00_0_1__0_10000010_00110000; //and (indirect_y)
8'h0A: out_data <= 31'b0101_0_1_00_00_00_1_0__0_10000011_00101111; //asl (acc)
8'h06: out_data <= 31'b0101_1_1_00_00_00_0_0__0_10000011_00001000; //asl (mem_ex_zpa)
8'h16: out_data <= 31'b0101_1_1_00_00_00_0_0__0_10000011_00101011; //asl (zp_x)
8'h0E: out_data <= 31'b0101_1_1_00_00_00_0_0__0_10000011_00011101; //asl (abs)
8'h1E: out_data <= 31'b0101_1_1_00_00_00_0_0__0_10000011_00100101; //asl (abs_x)
8'h24: out_data <= 31'b1001_1_0_00_00_00_0_1__0_11000010_00001000; //bit (mem_ex_zpa)
8'h2C: out_data <= 31'b1001_1_0_00_00_00_0_1__0_11000010_00011101; //bit (abs)
8'hC9: out_data <= 31'b0011_1_0_00_00_00_0_1__0_10000011_00000111; //cmp (imm)
8'hC5: out_data <= 31'b0011_1_0_00_00_00_0_1__0_10000011_00001000; //cmp (mem_ex_zpa)
8'hD5: out_data <= 31'b0011_1_0_00_00_00_0_1__0_10000011_00101011; //cmp (zp_x)
8'hCD: out_data <= 31'b0011_1_0_00_00_00_0_1__0_10000011_00011101; //cmp (abs)
8'hDD: out_data <= 31'b0011_1_0_00_00_00_0_1__0_10000011_00100101; //cmp (abs_x)
8'hD9: out_data <= 31'b0011_1_0_00_00_00_0_1__0_10000011_00101000; //cmp (abs_y)
8'hC1: out_data <= 31'b0011_1_0_00_00_00_0_1__0_10000011_00100000; //cmp (indirect_x)
8'hD1: out_data <= 31'b0011_1_0_00_00_00_0_1__0_10000011_00110000; //cmp (indirect_y)
8'hE0: out_data <= 31'b0011_1_0_00_01_00_0_1__0_10000011_00000111; //cpx (imm)
8'hE4: out_data <= 31'b0011_1_0_00_01_00_0_1__0_10000011_00001000; //cpx (mem_ex_zpa)
8'hEC: out_data <= 31'b0011_1_0_00_01_00_0_1__0_10000011_00011101; //cpx (abs)
8'hC0: out_data <= 31'b0011_1_0_00_10_00_0_1__0_10000011_00000111; //cpy (imm)
8'hC4: out_data <= 31'b0011_1_0_00_10_00_0_1__0_10000011_00001000; //cpy (mem_ex_zpa)
8'hCC: out_data <= 31'b0011_1_0_00_10_00_0_1__0_10000011_00011101; //cpy (abs)
8'hC6: out_data <= 31'b0001_1_0_00_00_00_0_0__0_10000010_00001000; //dec (mem_ex_zpa)
8'hD6: out_data <= 31'b0001_1_0_00_00_00_0_0__0_10000010_00101011; //dec (zp_x)
8'hCE: out_data <= 31'b0001_1_0_00_00_00_0_0__0_10000010_00011101; //dec (abs)
8'hDE: out_data <= 31'b0001_1_0_00_00_00_0_0__0_10000010_00100101; //dec (abs_x)
8'h49: out_data <= 31'b1010_1_1_00_00_00_0_1__0_10000010_00000111; //eor (imm)
8'h45: out_data <= 31'b1010_1_1_00_00_00_0_1__0_10000010_00001000; //eor (mem_ex_zpa)
8'h55: out_data <= 31'b1010_1_1_00_00_00_0_1__0_10000010_00101011; //eor (zp_x)
8'h4D: out_data <= 31'b1010_1_1_00_00_00_0_1__0_10000010_00011101; //eor (abs)
8'h5D: out_data <= 31'b1010_1_1_00_00_00_0_1__0_10000010_00100101; //eor (abs_x)
8'h59: out_data <= 31'b1010_1_1_00_00_00_0_1__0_10000010_00101000; //eor (abs_y)
8'h41: out_data <= 31'b1010_1_1_00_00_00_0_1__0_10000010_00100000; //eor (indirect_x)
8'h51: out_data <= 31'b1010_1_1_00_00_00_0_1__0_10000010_00110000; //eor (indirect_y)
8'hE6: out_data <= 31'b0000_1_0_00_00_00_0_0__0_10000010_00001000; //inc (mem_ex_zpa)
8'hF6: out_data <= 31'b0000_1_0_00_00_00_0_0__0_10000010_00101011; //inc (zp_x)
8'hEE: out_data <= 31'b0000_1_0_00_00_00_0_0__0_10000010_00011101; //inc (abs)
8'hFE: out_data <= 31'b0000_1_0_00_00_00_0_0__0_10000010_00100101; //inc (abs_x)
8'h4C: out_data <= 31'b0101_1_0_00_00_00_0_0__0_00000000_01000010; //jmp (jmp_abs)
8'h6C: out_data <= 31'b0101_1_0_00_00_00_0_0__0_00000000_01000101; //jmp (jmp_ind)
8'h20: out_data <= 31'b0101_1_0_00_00_00_0_0__0_00000000_01000010; //jsr (jmp_abs)
8'hA9: out_data <= 31'b0000_1_1_00_00_00_0_0__0_10000010_00000111; //lda (imm)
8'hA5: out_data <= 31'b0000_1_1_00_00_00_0_0__0_10000010_00001000; //lda (mem_ex_zpa)
8'hB5: out_data <= 31'b0000_1_1_00_00_00_0_0__0_10000010_00101011; //lda (zp_x)
8'hAD: out_data <= 31'b0000_1_1_00_00_00_0_0__0_10000010_00011101; //lda (abs)
8'hBD: out_data <= 31'b0000_1_1_00_00_00_0_0__0_10000010_00100101; //lda (abs_x)
8'hB9: out_data <= 31'b0000_1_1_00_00_00_0_0__0_10000010_00101000; //lda (abs_y)
8'hA1: out_data <= 31'b0000_1_1_00_00_00_0_0__0_10000010_00100000; //lda (indirect_x)
8'hB1: out_data <= 31'b0000_1_1_00_00_00_0_0__0_10000010_00110000; //lda (indirect_y)
8'hA2: out_data <= 31'b0000_1_1_00_00_01_0_0__0_10000010_00000111; //ldx (imm)
8'hA6: out_data <= 31'b0000_1_1_00_00_01_0_0__0_10000010_00001000; //ldx (mem_ex_zpa)
8'hB6: out_data <= 31'b0000_1_1_00_00_01_0_0__0_10000010_00101101; //ldx (zp_y)
8'hAE: out_data <= 31'b0000_1_1_00_00_01_0_0__0_10000010_00011101; //ldx (abs)
8'hBE: out_data <= 31'b0000_1_1_00_00_01_0_0__0_10000010_00101000; //ldx (abs_y)
8'hA0: out_data <= 31'b0000_1_1_00_00_10_0_0__0_10000010_00000111; //ldy (imm)
8'hA4: out_data <= 31'b0000_1_1_00_00_10_0_0__0_10000010_00001000; //ldy (mem_ex_zpa)
8'hB4: out_data <= 31'b0000_1_1_00_00_10_0_0__0_10000010_00101011; //ldy (zp_x)
8'hAC: out_data <= 31'b0000_1_1_00_00_10_0_0__0_10000010_00011101; //ldy (abs)
8'hBC: out_data <= 31'b0000_1_1_00_00_10_0_0__0_10000010_00100101; //ldy (abs_x)
8'h4A: out_data <= 31'b0111_0_1_00_00_00_1_0__0_10000011_00101111; //lsr (acc)
8'h46: out_data <= 31'b0111_1_1_00_00_00_0_0__0_10000011_00001000; //lsr (mem_ex_zpa)
8'h56: out_data <= 31'b0111_1_1_00_00_00_0_0__0_10000011_00101011; //lsr (zp_x)
8'h4E: out_data <= 31'b0111_1_1_00_00_00_0_0__0_10000011_00011101; //lsr (abs)
8'h5E: out_data <= 31'b0111_1_1_00_00_00_0_0__0_10000011_00100101; //lsr (abs_x)
8'h09: out_data <= 31'b0100_1_1_00_00_00_0_1__0_10000010_00000111; //ora (imm)
8'h05: out_data <= 31'b0100_1_1_00_00_00_0_1__0_10000010_00001000; //ora (mem_ex_zpa)
8'h15: out_data <= 31'b0100_1_1_00_00_00_0_1__0_10000010_00101011; //ora (zp_x)
8'h0D: out_data <= 31'b0100_1_1_00_00_00_0_1__0_10000010_00011101; //ora (abs)
8'h1D: out_data <= 31'b0100_1_1_00_00_00_0_1__0_10000010_00100101; //ora (abs_x)
8'h19: out_data <= 31'b0100_1_1_00_00_00_0_1__0_10000010_00101000; //ora (abs_y)
8'h01: out_data <= 31'b0100_1_1_00_00_00_0_1__0_10000010_00100000; //ora (indirect_x)
8'h11: out_data <= 31'b0100_1_1_00_00_00_0_1__0_10000010_00110000; //ora (indirect_y)
8'h2A: out_data <= 31'b0110_0_1_00_00_00_1_0__0_10000011_00101111; //rol (acc)
8'h26: out_data <= 31'b0110_1_1_00_00_00_0_0__0_10000011_00001000; //rol (mem_ex_zpa)
8'h36: out_data <= 31'b0110_1_1_00_00_00_0_0__0_10000011_00101011; //rol (zp_x)
8'h2E: out_data <= 31'b0110_1_1_00_00_00_0_0__0_10000011_00011101; //rol (abs)
8'h3E: out_data <= 31'b0110_1_1_00_00_00_0_0__0_10000011_00100101; //rol (abs_x)
8'h6a: out_data <= 31'b0111_0_1_00_00_00_1_0__0_10000011_00101111; //ror (acc)
8'h66: out_data <= 31'b0111_1_1_00_00_00_0_0__0_10000011_00001000; //ror (mem_ex_zpa)
8'h76: out_data <= 31'b0111_1_1_00_00_00_0_0__0_10000011_00101011; //ror (zp_x)
8'h6e: out_data <= 31'b0111_1_1_00_00_00_0_0__0_10000011_00011101; //ror (abs)
8'h7e: out_data <= 31'b0111_1_1_00_00_00_0_0__0_10000011_00100101; //ror (abs_x)
8'hE9: out_data <= 31'b0011_1_1_00_00_00_0_1__0_11000011_00000111; //sbc (imm)
8'hE5: out_data <= 31'b0011_1_1_00_00_00_0_1__0_11000011_00001000; //sbc (mem_ex_zpa)
8'hF5: out_data <= 31'b0011_1_1_00_00_00_0_1__0_11000011_00101011; //sbc (zp_x)
8'hED: out_data <= 31'b0011_1_1_00_00_00_0_1__0_11000011_00011101; //sbc (abs)
8'hFD: out_data <= 31'b0011_1_1_00_00_00_0_1__0_11000011_00100101; //sbc (abs_x)
8'hF9: out_data <= 31'b0011_1_1_00_00_00_0_1__0_11000011_00101000; //sbc (abs_y)
8'hE1: out_data <= 31'b0011_1_1_00_00_00_0_1__0_11000011_00100000; //sbc (indirect_x)
8'hF1: out_data <= 31'b0011_1_1_00_00_00_0_1__0_11000011_00110000; //sbc (indirect_y)
8'h85: out_data <= 31'b0000_1_0_00_00_00_0_1__0_00000000_00001010; //sta (mem_wr_zpa)
8'h95: out_data <= 31'b0000_1_0_00_00_00_0_1__0_00000000_00001100; //sta (mem_wr_zpx)
8'h8D: out_data <= 31'b0000_1_0_00_00_00_0_1__0_00000000_00010010; //sta (mem_wr_abs)
8'h9D: out_data <= 31'b0000_1_0_00_00_00_0_1__0_00000000_00100101; //sta (abs_x)
8'h99: out_data <= 31'b0000_1_0_00_00_00_0_1__0_00000000_00101000; //sta (abs_y)
8'h91: out_data <= 31'b0000_1_0_00_00_00_0_1__0_00000000_00010101; //sta (mem_wr_idy)
8'h86: out_data <= 31'b0000_1_0_00_01_00_0_1__0_00000000_00001010; //stx (mem_wr_zpa)
8'h96: out_data <= 31'b0000_1_0_00_01_00_0_1__0_00000000_00001111; //stx (mem_wr_zpy)
8'h8E: out_data <= 31'b0000_1_0_00_01_00_0_1__0_00000000_00011101; //stx (abs)
8'h84: out_data <= 31'b0000_1_0_00_10_00_0_1__0_00000000_00001010; //sty (mem_wr_zpa)
8'h94: out_data <= 31'b0000_1_0_00_10_00_0_1__0_00000000_00001100; //sty (mem_wr_zpx)
8'h8C: out_data <= 31'b0000_1_0_00_10_00_0_1__0_00000000_00011101; //sty (abs)
8'hEA: out_data <= 31'b0011_1_0_00_00_00_0_0__0_00000000_00000101; //nop (none)
8'h18: out_data <= 31'b0011_0_0_00_00_00_1_1__0_00000001_00000110; //clc (single_byte)
8'h38: out_data <= 31'b1011_0_0_00_00_00_1_1__0_00000001_00000110; //sec (single_byte)
8'h58: out_data <= 31'b0011_0_0_00_00_00_1_1__0_00000100_00000110; //cli (single_byte)
8'h78: out_data <= 31'b0011_0_0_00_00_00_1_1__0_00000100_00000110; //sei (single_byte)
8'hb8: out_data <= 31'b0011_0_0_00_00_00_1_1__0_01000000_00000110; //clv (single_byte)
8'hd8: out_data <= 31'b0011_0_0_00_00_00_1_1__0_00001000_00000110; //cld (single_byte)
8'hf8: out_data <= 31'b0011_0_0_00_00_00_1_1__0_00001000_00000110; //sed (single_byte)
8'haa: out_data <= 31'b0000_0_1_00_00_01_1_0__0_10000010_00000110; //tax (single_byte)
8'h8a: out_data <= 31'b0000_0_1_01_00_00_1_0__0_10000010_00000110; //txa (single_byte)
8'h98: out_data <= 31'b0000_0_1_10_00_00_1_0__0_10000010_00000110; //tya (single_byte)
8'ha8: out_data <= 31'b0000_0_1_00_00_10_1_0__0_10000010_00000110; //tay (single_byte)
8'h10: out_data <= 31'b0000_1_0_00_00_00_0_0__0_10000000_01010110; //bpl (branch_head)
8'h30: out_data <= 31'b0000_1_0_00_00_00_0_0__1_10000000_01010110; //bmi (branch_head)
8'h50: out_data <= 31'b0000_1_0_00_00_00_0_0__0_01000000_01010110; //bvc (branch_head)
8'h70: out_data <= 31'b0000_1_0_00_00_00_0_0__1_01000000_01010110; //bvs (branch_head)
8'h90: out_data <= 31'b0000_1_0_00_00_00_0_0__0_00000001_01010110; //bcc (branch_head)
8'hB0: out_data <= 31'b0000_1_0_00_00_00_0_0__1_00000001_01010110; //bcs (branch_head)
8'hD0: out_data <= 31'b0000_1_0_00_00_00_0_0__1_00000010_01010110; //bne (branch_head)
8'hf0: out_data <= 31'b0000_1_0_00_00_00_0_0__0_00000010_01010110; //beq (branch_head)
8'h9a: out_data <= 31'b0000_0_0_11_01_00_1_1__0_00000000_00000110; //txs (single_byte)
8'hba: out_data <= 31'b0000_1_1_00_00_01_0_0__0_10000010_00000110; //tsx (single_byte)
8'h48: out_data <= 31'b0000_0_0_11_00_00_1_1__0_00000000_00110111; //pha (push)
8'h68: out_data <= 31'b0000_1_1_00_00_00_0_0__0_10000010_00111001; //pla (pull)
8'h08: out_data <= 31'b0000_0_0_11_00_00_1_0__0_00000000_00110111; //php (push)
8'h28: out_data <= 31'b0000_1_0_00_00_00_0_0__0_11111111_00111001; //plp (pull)



    // NOT AUTO-GENERATED
    8'h00: out_data <= 31'b0000_0_0_00_00_00_0_0__0_11111111_00000000; // reset
    default: out_data <= 'x;
  endcase
endmodule
