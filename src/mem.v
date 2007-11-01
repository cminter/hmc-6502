// mem.v
// basic memory system for development
// 0xf000-0xffff - ROM, from file. program counter redirection = 0xf000
// 0x0000-0x1000 - RAM, inits to X
// 31 October 2007, Thomas W. Barr
// tbarr at cs dot hmc dot edu

`timescale 1 ns / 1 ps

module mem(input ph1, ph2, reset,
	         input [15:0] address,
           inout [7:0] data,
           input read_write_sel );

  // 0x1000 = 4096
  reg [7:0] RAM[4095:0];
  reg [7:0] ROM[4095:0];
  reg [7:0] data_out;
  
  assign data = (read_write_sel) ? data_out : 8'bz;
  
  initial begin
    ROM[4093] = 8'hf0;
    ROM[4092] = 8'h00;
    $readmemh("../test/roms/memtest.rom",ROM);
  end
  
  always @ ( posedge ph1 ) begin
    if ( read_write_sel ) begin
      if ( address[15:12] == 4'b0000 ) data_out = RAM[address[11:0]];
      else if ( address[15:12] == 4'b1111 ) data_out = ROM[address[11:0]];
           else data_out = 8'b0; // zero on undefined read
      end
    //memwrite
    else if ( address[15:12] == 4'b0000 ) RAM[address[11:0]] <= data;
  end
  
endmodule
