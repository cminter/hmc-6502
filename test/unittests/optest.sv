// optest.sv
// tests selected instructions
// tbarr at cs dot hmc dot edu

`timescale 1 ns / 1 ps

module optest;
  reg ph1, ph2, reset;
  
  wire [7:0] data;
  
  top top(ph1, ph2, reset);
  
  always begin
    ph1 <= 1; #8; ph1 <= 0; #12;
  end
  always begin
    ph2 <= 0; #10; ph2 <= 1; #8; ph2 <= 0; #2;
  end
  
  initial begin
    // init ROM
    top.mem.ROM[4093] = 8'hf0;
    top.mem.ROM[4092] = 8'h00;
    top.mem.RAM[3] = 8'h22;
    
    // path relative to this file.
    $readmemh("test/roms/optest.rom", top.mem.ROM);
    
    // start test
    reset = 1;
    #100;
    // forcibly set up reset state.
    reset = 0;
    #1;
    top.cpu.con.state_flop.q = 8'd1; // just some last state to fetch opcodes
    top.cpu.dp.pc_high.latch.q = 8'hef;
    top.cpu.dp.pc_low.latch.q = 8'hff;
  end
endmodule
