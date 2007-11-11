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
  
  assign zero = ~(&(y));
  assign negative = y[7];
  assign overflow = 0; // TODO
  
  always_comb begin
    case (op)
      4'h0: {c_out, y} = a + b + c_in; // add
      4'h1: {c_out, y} = b - a - c_in; // sub - borrow may be sketchy.
      4'h2: {c_out, y} = {1'b0, a | b}; // OR
      4'h3: {c_out, y} = {1'b0, a & b}; // AND
      4'h4: {c_out, y} = {1'b0, a ^ b}; // EOR
      4'h5: {c_out, y} = a + c_in; // inc
      4'h6: {c_out, y} = a - c_in; // dec
      4'h7: {c_out, y} = {a, 1'b0}; // asl
      4'h8: {c_out, y} = {a, c_in}; // rol
      4'h9: {y, c_out} = {c_in, a}; // ror
      4'ha: {y, c_out} = 9'b0; // test bits - TODO
      4'hb: {y, c_out} = 9'b111111111; // ones (for setting flags)
      default: {y, c_out} = 9'b0;
    endcase
  end
endmodule
