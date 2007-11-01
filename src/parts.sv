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
 
  assign #1 {cout, y} = a + b + cin;
endmodule