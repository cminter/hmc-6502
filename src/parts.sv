// parts.sv
// parts bin for hmc-6502 CPU
// 31oct07
// tbarr at cs hmc edu
// All the bits and pieces used in larger modules.

`timescale 1 ns / 1 ps

// Adder with carry in and out
module adderc #(parameter WIDTH = 8)
             (input logic [WIDTH-1:0]  a, b,
              input logic              cin,
              output logic [WIDTH-1:0] y,
              output logic             cout);
 
  assign {cout, y} = a + b + cin;
endmodule

// Adder with no carry in (actually described in code as A+C_in rather than
// A+B but it's functionally equivalent)
module halfadder #(parameter WIDTH = 8)
             (input logic [WIDTH-1:0]  a,
              input logic              cin,
              output logic [WIDTH-1:0] y,
              output logic             cout);
 
  assign {cout, y} = a + cin;
endmodule

// Decides whether or not to take a branch by comparing unmasked flags to the
// processor state register and branhc polarity.
module branchlogic(input logic [7:0] p, op_flags,
                   input logic branch_polarity,
                   output logic branch_taken);
  
  logic flag_high;
  assign flag_high = | (op_flags & p);
  assign branch_taken = branch_polarity ^ flag_high;
endmodule

// The almighty tristate.
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
              input logic clk);
  
  always_latch
      if (clk) q <= d;
endmodule

// Razor Latch module.  In verilog this is functionally equivallent to a
// normal latch, but the error output is important in actual hardware.  See
// the description of razor latches in the chip report for more information.
module razorlatch #(parameter WIDTH = 8)
             (input logic [WIDTH-1:0] d,
              output logic [WIDTH-1:0] q,
              input logic clk,
              output logic error);
  
  always_latch
      if (clk) q <= d;
endmodule

module latchr #(parameter WIDTH = 8)
             (input logic [WIDTH-1:0] d,
              output logic [WIDTH-1:0] q,
              input logic clk, resetb);
  
  always_latch
    if (!resetb) q <= 0;
      else if (clk) q <= d;
endmodule

module latchen #(parameter WIDTH = 8)
             (input logic [WIDTH-1:0] d,
              output logic [WIDTH-1:0] q,
              input logic clk, en);
  
  always_latch
    if (clk & en) q <= d;
endmodule

module latchren #(parameter WIDTH = 8)
             (input logic [WIDTH-1:0] d,
              output logic [WIDTH-1:0] q,
              input logic clk, en, resetb);
  
  always_latch
    if (!resetb) q <= 0;
      else if (clk & en) q <= d;
endmodule

module and8 (input logic [7:0] a,
             input logic s,
             output logic [7:0] y);
  assign y[0] = a[0] & s;
  assign y[1] = a[1] & s;
  assign y[2] = a[2] & s;
  assign y[3] = a[3] & s;
  assign y[4] = a[4] & s;
  assign y[5] = a[5] & s;
  assign y[6] = a[6] & s;
  assign y[7] = a[7] & s;
endmodule

module flopr #(parameter WIDTH = 8)
             (input logic [WIDTH-1:0] d,
              output logic [WIDTH-1:0] q,
              input logic clk, resetb);
  
  always_ff @ (posedge clk)
    if (!resetb) q <= 0;
    else q <= d;
endmodule

module registerbuf (input logic in_enable, out_enable,
                 output logic [7:0] value,
                 input logic [7:0] in_bus,
                 inout [7:0] out_bus,
                 input logic clk);
  
  logic gated_clk;
  assign gated_clk = in_enable & clk;
  
  latch #8 latch(in_bus, value, gated_clk);
  tristate #8 tris(value, out_enable, out_bus);
endmodule

// Incrementer
module inc #(parameter WIDTH = 16)
                  (input logic [WIDTH-1:0] a,
                   input logic c_in,
                   output logic [WIDTH-1:0] y,
                   output logic c_out);
  assign {c_out, y} = a + c_in;
endmodule

module registerbufmasked (input logic [7:0] in_enable,
                  input logic out_enable,
                  output logic [7:0] value,
                  input logic [7:0] in_bus,
                  inout [7:0] out_bus,
                  input logic clk);
  
  // fanned out registerbuf
  latch #1 latch0(in_bus[0], value[0], clk & in_enable[0]);
  latch #1 latch1(in_bus[1], value[1], clk & in_enable[1]);
  latch #1 latch2(in_bus[2], value[2], clk & in_enable[2]);
  latch #1 latch3(in_bus[3], value[3], clk & in_enable[3]);
  latch #1 latch4(in_bus[4], value[4], clk & in_enable[4]);
  latch #1 latch5(in_bus[5], value[5], clk & in_enable[5]);
  latch #1 latch6(in_bus[6], value[6], clk & in_enable[6]);
  latch #1 latch7(in_bus[7], value[7], clk & in_enable[7]);
  
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
module regfile(input         clk, 
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
    if (gated_clk) reg_file[write_addr] <= write_data;

  assign read_data_a = reg_file[read_addr_a];
  assign read_data_b = reg_file[read_addr_b];
endmodule
