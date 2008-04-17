// chip.sv
// chip module for hmc-6502 CPU
// 5mar08
// tbarr at cs hmc edu

`timescale 1 ns / 1 ps
`default_nettype none

module chip(output logic [15:0] address,
            inout wire [7:0] data,
            input logic ph1, ph2, reset,
            output logic read_en, razor_error);
            
            logic [7:0] data_in, data_out;
            
            assign data = (read_en) ? 8'bz : data_out;
            assign data_in = (read_en) ? data : 8'bz;
            
            core core(.address(address), .data_in(data_in), 
                      .data_out(data_out), .ph1(ph1), .ph2(ph2), 
                      .reset(reset), .read_en(read_en), 
                      .razor_error(razor_error));
endmodule
