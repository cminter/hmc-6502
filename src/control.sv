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

parameter BRANCH_TAKEN_STATE = 8'd103;
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
      `include "src/ucode/opcode_translator/translated_opcodes.txt"

    // NOT AUTO-GENERATED
    8'h00: out_data <= 31'b0000_0_0_00_00_00_0_0__0_11111111_00000000; // reset
    default: out_data <= 'x;
  endcase
endmodule
