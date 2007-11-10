// partstest.v
// tests latches and medium level modules
// tbarr at cs dot hmc dot edu

`timescale 1 ns / 1 ps

module partstest;
  logic ph1, ph2, reset;
  wire [7:0] x_bus;
  logic [7:0] y_bus, y_buf, a_val, b_val;
  logic a_o_en, b_o_en, a_i_en;
  logic [7:0] b_i_en;
  
  // buslatch test
  assign y_buf = x_bus + 1;
  latch #8 alu_buf(y_buf, y_bus, ph2, reset);
  buslatch bl_a(a_i_en, a_o_en, a_val, y_bus, x_bus, ph1, reset);
  flaglatch bl_b(b_i_en, b_o_en, b_val, y_bus, x_bus, ph1, reset);
  
  always begin
    ph1 <= 1; #1; ph1 <= 0; #1;
  end
    always begin
    ph2 <= 0; #1; ph2 <= 1; #1;
  end
  
  initial begin
    reset = 1; a_o_en = 0; a_i_en = 0; b_o_en = 0; b_i_en = 8'b0; #2; reset = 0;
    #2; a_o_en = 1; #2; a_i_en = 1; #6; b_i_en = 8'b1111110;
  end

endmodule
