// applemem.sv
// basic memory system for development
// 0xb000-0xffff - ROM, from file.
// 0x0000-0x1000 - RAM, inits to X
// 31 October 2007, Thomas W. Barr
// tbarr at cs dot hmc dot edu

`timescale 1 ns / 1 ps
`default_nettype none

module mem(input logic ph1, ph2, reset,
	         input logic [15:0] address,
           inout wire [7:0] data,
           input logic read_write_sel );

  // 0x1000 = 4096
  logic [7:0] RAM[4095:0];
  logic [7:0] ROM[16383:0];
  reg [7:0] data_out;
  
  assign #3 data = (read_write_sel) ? data_out : 8'bz;
  
  always_ff @ ( posedge ph2 ) begin
    if ( read_write_sel ) begin
      if ( address[15:12] == 4'b0000 ) data_out = RAM[address[11:0]];
      else if ( address > 16'hbfff ) 
          begin
            data_out = ROM[(address - 16'hc000)];
          end
           else data_out = 8'b00; // zero on undefined read
      end
    //memwrite
    else 
      begin
        if ( address[15:12] == 4'b0000 ) RAM[address[11:0]] <= data;
        else $display("wrote (0x%h) out of bounds to %h", data, address);
      end
  end
  
endmodule
