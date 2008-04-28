// core.sv
// core module for hmc-6502 CPU
// 31oct07
// tbarr at cs hmc edu

`timescale 1 ns / 1 ps

// core wires together the datapath and controller and throws in the clock
// generator.
module core(output logic [15:0] address,
            input [7:0] data_in,
            output [7:0] data_out,
            input logic ph0, resetb,
            output logic read_en, razor_error,
            input logic osc_en,
            output logic osc_out, ph1, ph2);
  
  // giant wad of controls
  logic th_in_en;
  logic th_out_en;
  logic tl_in_en;
  logic tl_out_en;
  logic [7:0] p_in_en, op_flags, p;
  logic p_out_en;
  logic p_sel;
  logic reg_write_en;
  logic [1:0] reg_read_addr_a;
  logic [1:0] reg_read_addr_b;
  logic [1:0] reg_write_addr;
  logic reg_a_en;
  logic reg_b_en;
  logic pch_in_en;
  logic pch_out_en;
  logic pcl_in_en;
  logic pcl_out_en;
  logic pc_inc_en;
  logic pc_sel;
  logic d_in_en;
  logic d_out_sel;
  logic [2:0] ah_sel;
  logic [1:0] al_sel;
  logic [3:0] alu_op;
  logic c_temp_en;
  logic [1:0] carry_sel;
  logic [7:0] constant;
  logic constant_en;
  logic flag_en;
  
  logic [9:0] alu_tristate_controls, alu_tristate_controls_b;
  
  test_structure test_structure(osc_en, osc_out);
  
  clockgen clockgen(ph0, ph1, ph2);
  
  datapath dp(data_in, data_out, address, p, ph1, ph2, resetb, razor_error,
              th_in_en, th_out_en, tl_in_en, tl_out_en, p_in_en, p_out_en, p_sel, 
              reg_write_en, reg_read_addr_a, reg_read_addr_b, reg_write_addr, reg_a_en, 
              reg_b_en, pch_in_en, pch_out_en, pcl_in_en, pcl_out_en, pc_inc_en, pc_sel, 
              d_in_en, d_out_sel, ah_sel, al_sel, alu_op, c_temp_en, carry_sel, constant, 
              constant_en, alu_tristate_controls, alu_tristate_controls_b);
              
  control con(data_in, p, ph1, ph2, resetb, p_in_en, alu_tristate_controls, alu_tristate_controls_b, {
                  th_in_en,
                  th_out_en,
                  tl_in_en,
                  tl_out_en,
                  p_sel,
                  p_out_en,
                  pch_in_en,
                  pch_out_en,
                  pcl_in_en,
                  pcl_out_en,
                  pc_inc_en,
                  pc_sel,
                  d_out_sel,
                  ah_sel,
                  al_sel,
                  c_temp_en,
                  carry_sel,
                  flag_en,
                  read_en,
                  constant_en,
                  constant,
                  alu_op,
                  d_in_en,
                  reg_write_en,
                  reg_read_addr_a,
                  reg_read_addr_b,
                  reg_write_addr,
                  reg_a_en,
                  reg_b_en});
endmodule
