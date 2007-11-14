// control.sv
// control FSM and opcode ROM for hmc-6502 CPU
// 31oct07
// tbarr at cs hmc edu

`timescale 1 ns / 1 ps

module control(input logic [7:0] data_in,
               input logic ph1, ph2, reset,
               
               // controls list from ucodeasm:
               output logic th_in_en,
               output logic th_out_en,
               output logic tl_in_en,
               output logic tl_out_en,
               output logic [7:0] p_in_en,
               output logic p_out_en,
               output logic p_sel,
               output logic reg_write_en,
               output logic [1:0] reg_read_addr_a,
               output logic [1:0] reg_read_addr_b,
               output logic [1:0] reg_write_addr,
               output logic reg_a_en,
               output logic pch_in_en,
               output logic pch_out_en,
               output logic pcl_in_en,
               output logic pcl_out_en,
               output logic pc_inc_en,
               output logic pc_sel,
               output logic d_in_en,
               output logic d_out_sel,
               output logic [1:0] ah_sel,
               output logic al_sel,
               output logic [3:0] alu_op,
               output logic c_temp_en,
               output logic carry_sel
               );
  // all controls become valid on ph1, and hold through end of ph2.
  
  // opcode decoding logic
  logic [7:0] latched_opcode;
  logic op_en, op_en_buf, opcode_gated_clk;
  logic [7:0] op_controls;
  
  flopr #1 op_en_reg(op_en, op_en_buf, ph2, reset);
  assign opcode_gated_clk = ph1 & op_en_buf;
  latch #8 opcode_buf(data_in, latched_opcode, opcode_gated_clk, reset);
  opcode_pla opcode_pla(latched_opcode, op_controls);
  
  // FSM logic
  logic [7:0] state, next_state;
  logic [9:0] c;
  logic next_state_sel;
  
  assign op_en = c_s2[4];
  assign next_state_sel = c_s2[5];
  
  mux2 #4 next_state_mux(c_s2[3:0], op_controls[3:0], next_state_sel, 
                         next_state);
  flopr #4 state_flop(next_state, state, ph1, reset);
  state_pla state_pla(state, c);
  
  assign controls[3:0] = c_s1[9:6];

endmodule

module state_pla(input logic [3:0] state,
                 output logic [9:0] out_controls);
  always_comb
  case(state)
    4'h0 : out_controls <= 10'b0000_1_0_0000;
    4'h1 : out_controls <= 10'b0001_0_0_0010;
    4'h2 : out_controls <= 10'b0010_0_0_0011;
    4'h3 : out_controls <= 10'b0111_0_1_0000;
    4'h4 : out_controls <= 10'b0001_0_0_0101;
    4'h5 : out_controls <= 10'b0010_0_0_0110;
    4'h6 : out_controls <= 10'b1011_0_1_0000;
    default: out_controls <= 8'b0;
  endcase
endmodule

module opcode_pla(input logic [7:0] opcode,
                 output logic [7:0] out_data);
  always_comb
  case(opcode)
    8'h01: out_data <= 8'h11;
    8'h02: out_data <= 8'h14;
    default: out_data <= 8'h00;
  endcase
endmodule
