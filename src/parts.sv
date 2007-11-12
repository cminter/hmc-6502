// parts.sv
// parts bin for hmc-6502 CPU
// 31oct07
// tbarr at cs hmc edu

`timescale 1 ns / 1 ps

// Adder with carry in and out
module adderc #(parameter WIDTH = 8)
             (input logic [WIDTH-1:0]  a, b,
              input logic              cin,
              output logic [WIDTH-1:0] y,
              output logic             cout);
 
  assign {cout, y} = a + b + cin;
endmodule

module tristate #(parameter WIDTH = 8)
                (input logic [WIDTH-1:0] in,
                 input logic enable,
                 output [WIDTH-1:0] bus);
  
  wire [WIDTH-1:0] highz;
  assign highz = {WIDTH{1'bz}};
  
  assign bus = (enable) ? in : highz;
endmodule

module latch #(parameter WIDTH = 8)
             (input logic [WIDTH-1:0] d,
              output logic [WIDTH-1:0] q,
              input logic clk, reset);
  
  always_latch
    if (reset) q <= 0;
      else if (clk) q <= d;
endmodule

module flopr #(parameter WIDTH = 8)
             (input logic [WIDTH-1:0] d,
              output logic [WIDTH-1:0] q,
              input logic clk, reset);
  
  always_ff @ (posedge clk)
    if (reset) q <= 0;
    else q <= d;
endmodule

module buslatch (input logic in_enable, out_enable,
                 output logic [7:0] value,
                 input logic [7:0] in_bus,
                 inout [7:0] out_bus,
                 input logic clk, reset);
  
  logic gated_clk;
  assign gated_clk = in_enable & clk;
  
  latch #8 latch(in_bus, value, gated_clk, reset);
  tristate #8 tris(value, out_enable, out_bus);
endmodule

module halfadder #(parameter WIDTH = 16)
                  (input logic [WIDTH-1:0] a,
                   input logic c,
                   output logic [WIDTH-1:0] y);
  assign y = a + c;
endmodule

module flaglatch (input logic [7:0] in_enable,
                  input logic out_enable,
                  output logic [7:0] value,
                  input logic [7:0] in_bus,
                  inout [7:0] out_bus,
                  input logic clk, reset);
  
  // fanned out buslatch
  latch #1 latch0(in_bus[0], value[0], clk & in_enable[0], reset);
  latch #1 latch1(in_bus[1], value[1], clk & in_enable[1], reset);
  latch #1 latch2(in_bus[2], value[2], clk & in_enable[2], reset);
  latch #1 latch3(in_bus[3], value[3], clk & in_enable[3], reset);
  latch #1 latch4(in_bus[4], value[4], clk & in_enable[4], reset);
  latch #1 latch5(in_bus[5], value[5], clk & in_enable[5], reset);
  latch #1 latch6(in_bus[6], value[6], clk & in_enable[6], reset);
  latch #1 latch7(in_bus[7], value[7], clk & in_enable[7], reset);
  
  tristate #8 tris(value, out_enable, out_bus);
endmodule

// muxes - from MIPS project
module mux2 #(parameter WIDTH = 8)
             (input  [WIDTH-1:0] d0, d1, 
              input              s, 
              output [WIDTH-1:0] y);

  assign y = s ? d1 : d0; 
endmodule

module mux3 #(parameter WIDTH = 8)
             (input  [WIDTH-1:0] d0, d1, d2,
              input  [1:0]       s, 
              output [WIDTH-1:0] y);

  assign y = s[1] ? d2 : (s[0] ? d1 : d0); 
endmodule

module mux4 #(parameter WIDTH = 8)
             (input  [WIDTH-1:0] d0, d1, d2, d3,
              input  [1:0]       s, 
              output [WIDTH-1:0] y);

  assign y = s[1] ? (s[0] ? d3 : d2)
                     : (s[0] ? d1 : d0); 
endmodule

module mux5 #(parameter WIDTH = 8)
             (input  [WIDTH-1:0] d0, d1, d2, d3, d4,
              input   [2:0]  s,
              output  [WIDTH-1:0] y);

  // 101 = d4; 100 = d3; 010 = d2; 001 = d1; 000 = d0

  assign y = s[2] ? (s[0] ? d4 : d3)
                     : (s[1] ? d2 : (s[0] ? d1 : d0));
endmodule

// modified from MIPS project
module regfile(input         clk, reset,
               input         write_enable, 
               input  [1:0]  read_addr_a, read_addr_b, write_addr, 
               input  [7:0]  write_data, 
               output [7:0]  read_data_a, read_data_b);

  reg [7:0] reg_file [3:0];
  
  logic gated_clk;
  assign gated_clk = clk & write_enable;
  
  // three ported register file
  // read two ports combinationally
  // write third port as latch

  always_latch
    if (reset) begin
      reg_file[0] = 8'b0;
      reg_file[1] = 8'b0;
      reg_file[2] = 8'b0;
      reg_file[3] = 8'b0;
    end
    else if (gated_clk) reg_file[write_addr] <= write_data;

  assign read_data_a = reg_file[read_addr_a];
  assign read_data_b = reg_file[read_addr_b];
endmodule