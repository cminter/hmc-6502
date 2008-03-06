// control.sv
// control FSM and opcode ROM for hmc-6502 CPU
// 31oct07
// tbarr at cs hmc edu

`timescale 1 ns / 1 ps

// always kept in this order!
parameter C_STATE_WIDTH = 23;
parameter C_OP_WIDTH = 14;
parameter C_INT_WIDTH = 12; // total width of internal state signals

parameter BRANCH_TAKEN_STATE = 8'd42;
parameter BRANCH_NOT_TAKEN_STATE = 8'd45;

parameter C_TOTAL = (C_STATE_WIDTH + C_OP_WIDTH + C_INT_WIDTH);

module control(input logic [7:0] data_in, p,
               input logic ph1, ph2, reset,
               output logic [7:0] op_flags,
               output logic [(C_STATE_WIDTH + C_OP_WIDTH - 1):0] controls_s1);
               
  // all controls become valid on ph1, and hold through end of ph2.
  logic [7:0] latched_opcode;
  logic opcode_gated_clk, first_cycle;
  
  logic [(C_OP_WIDTH - 1):0] c_op_state, c_op_opcode;
  logic [(C_OP_WIDTH - 1):0] c_op_selected;
  logic [(C_STATE_WIDTH - 1):0] c_state;
  
  logic branch_polarity, flag_high, branch_taken;
  
  logic [7:0] state, next_state, next_state_states, next_state_opcode;
  logic [7:0] next_state_branch;
  logic [1:0] next_state_sel;

  logic [(C_STATE_WIDTH + C_OP_WIDTH - 1):0] controls_s2;
  
  // opcode logic
  flopr #1 opcode_reg(last_cycle, first_cycle, ph2, reset);
  assign opcode_gated_clk = ph1 & first_cycle;
  latch #8 opcode_buf(data_in, latched_opcode, opcode_gated_clk, reset);
  opcode_pla opcode_pla(latched_opcode, {c_op_opcode, branch_polarity, 
                                         op_flags, next_state_opcode});
  
  // branch logic
  // - p is stable 1, but won't be written on the branch op.
  // - the paranoid would add a latch to make it stable 2.
  assign flag_high = | (op_flags & p);
  assign branch_taken = branch_polarity ^ flag_high;
  mux2 #8 branch_state_sel(BRANCH_NOT_TAKEN_STATE, 
                           BRANCH_TAKEN_STATE, branch_taken, next_state_branch);
  
  // next state logic
  mux3 #8 next_state_mux(next_state_states, next_state_opcode, next_state_branch,
                         next_state_sel, next_state);
  
  // state PLA
  flopr #8 state_flop(next_state, state, ph2, reset);
  state_pla state_pla(state, {c_state, c_op_state, {last_cycle,
                                                    c_op_sel,
                                                    next_state_sel,
                                                    next_state_states}});
  
  // opcode specific controls
  mux2 #(C_OP_WIDTH) func_mux(c_op_state, c_op_opcode, c_op_sel, c_op_selected);
  
  // output
  assign controls_s2 = {c_state, c_op_selected};
  latch #(C_STATE_WIDTH + C_OP_WIDTH) controls_latch(controls_s2, controls_s1,
                        ph1, reset);
endmodule

module state_pla(input logic [7:0] state,
                 output logic [(C_TOTAL - 1):0] out_controls);
  always_comb
  case(state)
      // base
      8'd000 : out_controls <= 49'b00000010101000000001001_01011000000000_000100000000;
      
      // none
      8'd001 : out_controls <= 49'b00000010101000000001001_01010000000000_100000000000;
      
      // single_byte
      8'd002 : out_controls <= 49'b00000000001000000000011_00000000000000_110000000000;
      
      // imm
      8'd003 : out_controls <= 49'b00000010101000000000011_00001000000000_110000000000;
      
      // mem_ex_zpa
      8'd004 : out_controls <= 49'b00000000001000110101001_01011000000000_000000000101;
      8'd005 : out_controls <= 49'b00000010101000000000011_00001000000000_110000000000;
      
      // mem_wr_zpa
      8'd006 : out_controls <= 49'b00000000001010110101000_01011000000000_010000000111;
      8'd007 : out_controls <= 49'b00000010101000000000011_00001000000000_100000000000;
      
      // abs
      8'd008 : out_controls <= 49'b00100010101000000001001_01011000000000_000000001001;
      8'd009 : out_controls <= 49'b00000000001000011001001_01011000000000_000000001010;
      8'd010 : out_controls <= 49'b00000010101000000000011_00001000000000_110000000000;
      
      // indirect_x
      8'd011 : out_controls <= 49'b00000000001000110101001_00001000010000_000000001100;
      8'd012 : out_controls <= 49'b00100000001000110001001_01011000000000_000000001101;
      8'd013 : out_controls <= 49'b00000000001000110101101_00001000010000_000000001110;
      8'd014 : out_controls <= 49'b00000000001000011001001_01011000000000_000000001111;
      8'd015 : out_controls <= 49'b00000010101000000000011_00001000000000_110000000000;
      
      // abs_x
      8'd016 : out_controls <= 49'b00100010101000000001001_00001000010000_000000010001;
      8'd017 : out_controls <= 49'b00000000001000011000101_01011000000000_000000010010;
      8'd018 : out_controls <= 49'b00000010101000000000011_00001000000000_110000000000;
      
      // zp_x
      8'd019 : out_controls <= 49'b00000000001000110101001_00001000010000_000000010100;
      8'd020 : out_controls <= 49'b00000010101000000000011_00001000000000_110000000000;
      
      // indirect_y
      8'd021 : out_controls <= 49'b00000000001000110101001_01011000000000_000000010110;
      8'd022 : out_controls <= 49'b00100000001000000001001_01011000000000_000000010111;
      8'd023 : out_controls <= 49'b00000000001000110101101_01011000000000_000000011000;
      8'd024 : out_controls <= 49'b10000000001000011001001_01011000000000_000000011001;
      8'd025 : out_controls <= 49'b00110000001000100101001_00000000100000_000000011010;
      8'd026 : out_controls <= 49'b11000000001000011000101_01010000000000_000000011011;
      8'd027 : out_controls <= 49'b00000010101000000000011_00001000000000_110000000000;
      
      // push
      8'd028 : out_controls <= 49'b00000000001001000101100_01100111001110_010000011101;
      8'd029 : out_controls <= 49'b00000000001000000000001_00000000000000_100000000000;
      
      // pull
      8'd030 : out_controls <= 49'b00000000001001000101001_01010011000010_000000011111;
      8'd031 : out_controls <= 49'b00000000001000000001001_01011000000000_010000100000;
      8'd032 : out_controls <= 49'b00000010101000000001101_01010111001110_100000000000;
      
      // jsr
      8'd033 : out_controls <= 49'b00100010101000000001001_01011000000000_000000100010;
      8'd034 : out_controls <= 49'b10000000001000000001001_01011000000000_000000100011;
      8'd035 : out_controls <= 49'b00000000001001000101100_01100111001110_000000100100;
      8'd036 : out_controls <= 49'b00000000001000101001100_01100111001110_000000100101;
      8'd037 : out_controls <= 49'b00010000101100000001001_01010000000000_000000100110;
      8'd038 : out_controls <= 49'b01000010001100101001001_01010000000000_100000000000;
      
      // jmp_abs
      8'd039 : out_controls <= 49'b00100010101000000001001_01011000000000_000000101000;
      8'd040 : out_controls <= 49'b10000010001100011001001_01011000000000_000000101001;
      8'd041 : out_controls <= 49'b00010000101100101001001_01010000000000_100000000000;
      
      // jmp_ind
      8'd042 : out_controls <= 49'b00100010101000000001001_01011000000000_000000101011;
      8'd043 : out_controls <= 49'b10000000001000011001001_01011000000000_000000101100;
      8'd044 : out_controls <= 49'b00000000101100000001001_01011000000000_000000101101;
      8'd045 : out_controls <= 49'b00010000001000100101101_01010000000000_000000101110;
      8'd046 : out_controls <= 49'b00000010001100010001001_01011000000000_100000000000;
      
      // rts
      8'd047 : out_controls <= 49'b00000000001001000101001_01010011000010_000000110000;
      8'd048 : out_controls <= 49'b00000000101100000001001_01011000000000_000000110001;
      8'd049 : out_controls <= 49'b00000000001001000101101_01100111001110_000000110010;
      8'd050 : out_controls <= 49'b00000010001100000001001_01011000000000_000000110011;
      8'd051 : out_controls <= 49'b00000010101000000001101_01100111001110_100000000000;
      
      // rti
      8'd052 : out_controls <= 49'b00000000001001000101001_01010011000010_000000110101;
      8'd053 : out_controls <= 49'b00000000001000000001011_01011000000000_000000110110;
      8'd054 : out_controls <= 49'b00000000001001000101101_01100111001110_000000110111;
      8'd055 : out_controls <= 49'b00000000101100000001001_01011000000000_000000111000;
      8'd056 : out_controls <= 49'b00000000001001000101101_01100111001110_000000111001;
      8'd057 : out_controls <= 49'b00000010001100000001001_01011000000000_000000111010;
      8'd058 : out_controls <= 49'b00000010101000000001101_01100111001110_100000000000;
      
      // branch_head:59
      8'd059 : out_controls <= 49'b00100010101000000001001_00001000000000_100000000000;
      
      // branch_taken:60
      8'd060 : out_controls <= 49'b10000010001100000000001_00000000000000_000000111101;
      8'd061 : out_controls <= 49'b00000000101100101001001_00000000000000_100000000000;
      default: out_controls <= 'x;
    endcase
endmodule

module opcode_pla(input logic [7:0] opcode,
                 output logic [(C_OP_WIDTH + 17 - 1):0] out_data);
  always_comb
  case(opcode)
    8'h69: out_data <= 31'b0000_1_1_00_00_00_0_1__0_00000010_00000011;
    8'h65: out_data <= 31'b0000_1_1_00_00_00_0_1__0_00000000_00000100;
    8'h85: out_data <= 31'b0101_1_0_00_00_00_0_1__0_00000000_00000110;
    default: out_data <= 'x;
  endcase
endmodule
