// test_structure.sv

`timescale 1 ns / 1 ps

module test_structure( input logic osc_en,
                       output logic osc_out );
  logic a;
  
  assign a = !(osc_out & osc_en);
  assign #7 osc_out = a;
  
endmodule
