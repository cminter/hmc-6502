// test13-specialflags.sv
// basic regression test
// tbarr at cs dot hmc dot edu

`timescale 1 ns / 1 ps

module optest;
  reg ph1, ph2, resetb;
  
  wire [7:0] data;
  
  top top(ph1, ph2, resetb);
  
  always begin
    ph1 <= 1; #8; ph1 <= 0; #12;
  end
  always begin
    ph2 <= 0; #10; ph2 <= 1; #8; ph2 <= 0; #2;
  end
  
  initial begin
    // for VCD file
    $dumpfile("test/VCD/outSuiteA-test13.vcd");
    $dumpvars;

    // init ROM
    top.mem.ROM[4093] = 8'hf0;
    top.mem.ROM[4092] = 8'h00;
    
    // path relative to this file.
    $readmemh("test/roms/SuiteA/test13-specialflags.rom", top.mem.ROM);
    
    // start test
    resetb = 0;
    #100;
    resetb = 1;
    #1200;
    assert (top.mem.RAM[33] == 8'h0C) $display ("PASSED Test 13 - special flags");
      else $error("FAILED Test 13 - special flags");
    $dumpflush;
    $stop;
  end
endmodule
