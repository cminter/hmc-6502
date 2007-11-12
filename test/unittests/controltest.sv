// controltest.sv
// tests development memory system
// tbarr at cs dot hmc dot edu

`timescale 1 ns / 1 ps

module controltest;
  logic ph1, ph2, reset;
  logic [7:0] data_in;
  logic [3:0] controls;
  
  control control(data_in, ph1, ph2, reset, controls);
  
  always begin
    ph1 <= 1; #1; ph1 <= 0; #1;
  end
    always begin
    ph2 <= 0; #1; ph2 <= 1; #1;
  end
  
  initial begin
    // start test
    reset = 1;
    #10;
    reset = 0;
    control.op_en_reg.q = 1;
    data_in = 8'h1;
    #2;
    data_in = 8'h0;
    #6;
    data_in = 8'h2;
    #2;
    data_in = 8'h0;
  end
endmodule
