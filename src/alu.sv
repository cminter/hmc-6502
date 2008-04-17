// alu.sv
// alu for hmc-6502 CPU
// 31oct07
// tbarr at cs hmc edu

`timescale 1 ns / 1 ps

module alu(input logic [7:0] a, b,
	         output logic [7:0] y,
           input logic [3:0] op,
           input logic [9:0] alu_tristate_controls, alu_tristate_controls_b,
           input logic c_in, bcd,
           output logic zero, negative, overflow, c_out);
  
  logic testbits;
  assign testbits = (op === 4'h9);
  
  assign zero = (y === 8'b0); // Z flag
  assign negative = y[7] | (testbits & a[7]); // S flag

  // If we're doing a subtract, invert a to put through the adders.
  logic [7:0] a_conditionally_inverted;
  assign a_conditionally_inverted = (op === 4'h3) ? ~a : a;

  logic [7:0] full_sum;
  logic [6:0] low7_sum;
  logic low7_cout, high_sum, full_cout;

  adderc #7 lower7_add(a_conditionally_inverted[6:0], b[6:0], c_in, low7_sum, low7_cout);
  adderc #1 high_add(a_conditionally_inverted[7], b[7], low7_cout, high_sum, full_cout);
  assign full_sum = {high_sum, low7_sum};

  // The whole purpose of this was to get the carry out from bits 6 and 7 to
  // produce the overflow flag:
  assign overflow = (low7_cout ^ full_cout) | (testbits & a[6]);

  always_comb begin
    case (op)
      4'h0: {c_out, y} = a + c_in; // inc
      4'h1: {c_out, y} = a - c_in; // dec
      4'h2: {c_out, y} = {full_cout, full_sum}; // add
      4'h3: {c_out, y} = {full_cout, full_sum}; // sub
      4'h4: {y, c_out} = {c_in, a}; // ror
      4'h5: {c_out, y} = {a, 1'b0}; // asl
      4'h6: {c_out, y} = {a, c_in}; // rol
      4'h7: {c_out, y} = {1'b0, a | b}; // OR
      4'h8: {c_out, y} = {1'b0, a & b}; // AND
      4'h9: {y, c_out} = {1'b0, a & b}; // test bits
      4'ha: {c_out, y} = {1'b0, a ^ b}; // EOR
      4'hb: {y, c_out} = 9'b111111111; // ones (for setting flags)
      default: {y, c_out} = 9'b0;
    endcase
  end
endmodule
