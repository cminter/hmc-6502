// top.sv
// top level test module for hmc-6502
// 2dec07
// tbarr at cs hmc edu

`timescale 1 ns / 1 ps

module top(input logic ph1, ph2, reset);
  
  // holds memory system and CPU. nothing exported, use heirarchical names
  // to examine operation
  
  logic [15:0] address;
  wire [7:0] data;
  
  wire razor_error;
  
  chip chip(address, data, ph1, ph2, reset, read_en, razor_error);
  mem mem(ph1, ph2, reset, address, data, read_en);
  
endmodule