// alu.sv
// alu for hmc-6502 CPU
// 31oct07
// tbarr at cs hmc edu

`timescale 1 ns / 1 ps

module alu(input logic [7:0] a, b,
	         output logic [7:0] y,
           input logic [3:0] op,
           input logic c_in, bcd,
           output logic zero, negative, overflow, c_out);
  
  logic testbits;
  assign testbits = (op === 4'ha);
  
  assign zero = (y === 8'b0); // Z flag
  assign negative = y[7] | (testbits & a[7]); // S flag
  assign overflow = (a[7] ^ b[7])  | (testbits & a[6]); // 2's complement overflow, V flag
  
  always_comb begin
    case (op)
      4'h0: {c_out, y} = a + c_in; // inc
      4'h1: {c_out, y} = a - c_in; // dec
      4'h2: {c_out, y} = a + b + c_in; // add
      4'h3: {c_out, y} = b - a - c_in; // sub.
      4'h4: {c_out, y} = {1'b0, a | b}; // OR
      4'h5: {c_out, y} = {a, 1'b0}; // asl
      4'h6: {c_out, y} = {a, c_in}; // rol
      4'h7: {y, c_out} = {c_in, a}; // ror
      4'h8: {c_out, y} = {1'b0, a & b}; // AND
      4'h9: {y, c_out} = {1'b0, a & b}; // test bits
      4'ha: {c_out, y} = {1'b0, a ^ b}; // EOR
      4'hb: {y, c_out} = 9'b111111111; // ones (for setting flags)
      default: {y, c_out} = 9'b0;
    endcase
  end
endmodule
