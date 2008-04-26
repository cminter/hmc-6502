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

parameter BRANCH_TAKEN_STATE = 8'd12;
parameter BRANCH_NOT_TAKEN_STATE = 8'd11;

parameter C_TOTAL = (C_STATE_WIDTH + C_OP_WIDTH + C_INT_WIDTH);

module control(input logic [7:0] data_in, p,
               input logic ph1, ph2, resetb,
               output logic [7:0] p_in_en,
               output logic [9:0] alu_tristate_controls, alu_tristate_controls_b,
               output logic [(C_STATE_WIDTH + C_OP_WIDTH - 1):0] controls_out);
               
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
  
  // lines for carry_sel patch
  logic [1:0] carry_sel_op, carry_sel_selected;
  
  // opcode logic
  latch #1 opcode_lat_p1(last_cycle, last_cycle_s2, ph1);
  latch #1 opcode_lat_p2(last_cycle_s2, first_cycle, ph2);
  latchren #8 opcode_buf(data_in, latched_opcode, ph1, first_cycle, resetb);
  opcode_pla opcode_pla(latched_opcode, {carry_sel_op, 
                                         c_op_opcode, branch_polarity, 
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
  latchr #8 state_lat_p1(next_state, next_state_s2, ph1, resetb);
  latchr #8 state_lat_p2(next_state_s2, state, ph2, resetb);
  
  state_pla state_pla(state, {c_state, c_op_state, {last_cycle,
                                                    c_op_sel,
                                                    next_state_sel,
                                                    next_state_states}});
  
  and8 flag_masker(op_flags, controls_out[24], p_in_en);
  
  // opcode specific controls
  mux2 #(C_OP_WIDTH) func_mux(c_op_state, c_op_opcode, c_op_sel, c_op_selected);
  
  // create decoded signal for ALU
  alu_mux_controls alu_mux_generator(controls_out[13:10], alu_tristate_controls, alu_tristate_controls_b);
  
  
  latch #1 controls_op_02(c_op_selected[02], controls_out[02], ph1);
  latch #1 controls_op_03(c_op_selected[03], controls_out[03], ph1);

  latch #1 controls_op_08(c_op_selected[08], controls_out[08], ph1);
  
  assign controls_out[00] = c_op_selected[00];
  assign controls_out[01] = c_op_selected[01];

  assign controls_out[04] = c_op_selected[04];
  assign controls_out[05] = c_op_selected[05];
  assign controls_out[06] = c_op_selected[06];
  assign controls_out[07] = c_op_selected[07];

  assign controls_out[09] = c_op_selected[09];
  assign controls_out[10] = c_op_selected[10];
  assign controls_out[11] = c_op_selected[11];
  assign controls_out[12] = c_op_selected[12];
  assign controls_out[13] = c_op_selected[13];
  
  latch #1 controls_state_09(c_state[09], controls_out[23], ph1);
  latch #1 controls_state_10(c_state[10], controls_out[24], ph1);

  latch #1 controls_state_13(c_state[13], controls_out[27], ph1);
  latch #1 controls_state_14(c_state[14], controls_out[28], ph1);
  latch #1 controls_state_15(c_state[15], controls_out[29], ph1);
  latch #1 controls_state_16(c_state[16], controls_out[30], ph1);
  latch #1 controls_state_17(c_state[17], controls_out[31], ph1);
  latch #1 controls_state_18(c_state[18], controls_out[32], ph1);
  latch #1 controls_state_19(c_state[19], controls_out[33], ph1);
  latch #1 controls_state_20(c_state[20], controls_out[34], ph1);
  latch #1 controls_state_21(c_state[21], controls_out[35], ph1);
  
  latch #1 controls_state_23(c_state[23], controls_out[37], ph1);

  latch #1 controls_state_25(c_state[25], controls_out[39], ph1);
  latch #1 controls_state_26(c_state[26], controls_out[40], ph1);
  latch #1 controls_state_27(c_state[27], controls_out[41], ph1);

  latch #1 controls_state_29(c_state[29], controls_out[43], ph1);
  latch #1 controls_state_31(c_state[31], controls_out[45], ph1);

  assign controls_out[14] = c_state[00];
  assign controls_out[15] = c_state[01];
  assign controls_out[16] = c_state[02];
  assign controls_out[17] = c_state[03];
  assign controls_out[18] = c_state[04];
  assign controls_out[19] = c_state[05];
  assign controls_out[20] = c_state[06];
  assign controls_out[21] = c_state[07];
  assign controls_out[22] = c_state[08];

  
  // carry_sel is now selected by c_op_sel
  mux2 #2 carry_sel_mux(c_state[12:11], carry_sel_op, c_op_sel, 
                        carry_sel_selected);
  assign controls_out[26:25] = carry_sel_selected;
                        
  assign controls_out[36] = c_state[22];

  assign controls_out[38] = c_state[24];

  assign controls_out[42] = c_state[28];
  assign controls_out[44] = c_state[30];
  
  
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
                 output logic [(C_OP_WIDTH + 17 - 1 + 2):0] out_data);
  always_comb
  case(opcode)
      `include "src/ucode/opcode_translator/translated_opcodes.txt"

    // NOT AUTO-GENERATED
    8'h00: out_data <= 33'bzz_0000_0_0_00_00_00_0_0__0_11111111_01101111; // break
    default: out_data <= '0; // processor resets on undefined opcode
  endcase
endmodule

module alu_mux_controls(input logic [3:0] op,
	         output logic [9:0] alu_tristate_controls, alu_tristate_controls_b);    
 
 assign alu_tristate_controls_b = ~alu_tristate_controls;
           
 always_comb begin;
    case (op)
      4'h0: alu_tristate_controls = 10'b1000000000;
      4'h1: alu_tristate_controls = 10'b1000000000;
      4'h2: alu_tristate_controls = 10'b1000000000;
      4'h3: alu_tristate_controls = 10'b1000000000;
      4'h4: alu_tristate_controls = 10'b0100000000;
      4'h5: alu_tristate_controls = 10'b0010000000;
      4'h6: alu_tristate_controls = 10'b0001000000;
      4'h7: alu_tristate_controls = 10'b0000100000;
      4'h8: alu_tristate_controls = 10'b0000010000;
      4'h9: alu_tristate_controls = 10'b0000001000;
      4'ha: alu_tristate_controls = 10'b0000000100;
      4'hb: alu_tristate_controls = 10'b0000000010;
      default: alu_tristate_controls = 10'b0000000001;
    endcase
  end
endmodule
