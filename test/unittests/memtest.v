// memtest.v
// tests development memory system
// tbarr at cs dot hmc dot edu

`timescale 1 ns / 1 ps

module memtest;
  reg ph1, ph2, reset, read_write_sel;
  reg [15:0] address;
  reg [7:0] data_write;
  
  wire [7:0] data;
  
  mem mem(ph1, ph2, reset, address, data, read_write_sel);
  
  assign data = (read_write_sel) ? 8'bz : data_write;
  
  always begin
    ph1 <= 1; #1; ph1 <= 0; #1;
  end
    always begin
    ph2 <= 0; #1; ph2 <= 1; #1;
  end
  
  initial begin
    address = 16'b0; reset = 0; read_write_sel = 0;
    data_write = 8'h42;
    #10;
    read_write_sel = 1;
    #2;
    address = 16'b1;
    #1
    address = 16'b0;
    #3;
    address = 16'hfffd;
    #4;
    address = 16'hf000;
    #4;
    address = 16'hf001;
  end
endmodule
