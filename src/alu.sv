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
  assign testbits = (op === 4'h9);
  
  assign zero = (y === 8'b0); // Z flag
  assign negative = y[7] | (testbits & a[7]); // S flag
  assign overflow = (a[7] ^ b[7])  | (testbits & a[6]); // 2's complement overflow, V flag
  
  logic [7:0] sub_y;
  logic sub_c_out;
  adderc #8 sub_adder(~a, b, c_in, sub_y, sub_c_out);

  logic [7:0] adc_sum;
  logic [6:0] adc_low7_sum;
  logic adc_low7_cout, adc_high_sum, adc_cout;
  adderc #7 adc_lower7_add(a[6:0], b[6:0], c_in, adc_low7_sum, adc_low7_cout);
  adderc #1 adc_high_add(a[7], b[7], adc_low7_cout, adc_high_sum, adc_cout);
  assign adc_sum = {adc_high_sum, adc_low7_sum};

  logic [7:0] sbc_sum;
  logic [6:0] sbc_low7_sum;
  logic sbc_low7_cout, sbc_high_sum, sbc_cout;
  adderc #7 sbc_lower7_add(~a[6:0], b[6:0], c_in, sbc_low7_sum, sbc_low7_cout);
  adderc #1 sbc_high_add(~a[7], b[7], sbc_low7_cout, sbc_high_sum, sbc_cout);
  assign sbc_sum = {sbc_high_sum, sbc_low7_sum};

  logic carry6, carry7;

  always_comb begin
    case (op)
      4'h0: {c_out, y} = a + c_in; // inc
      4'h1: {c_out, y} = a - c_in; // dec
      4'h2: {c_out, y} = {adc_cout, adc_sum}; // add
      4'h3: {c_out, y} = {sbc_cout, sbc_sum}; // sub
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
