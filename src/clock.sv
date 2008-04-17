// clock.sv
// clock system for hmc-6502 CPU
// 20mar08


`timescale 1 ns / 1 ps

module clockgen(input logic ph0,
                output logic ph1, ph2);
  
  assign ph2 = !ph0;
  assign ph1 =  ph0;
  
endmodule