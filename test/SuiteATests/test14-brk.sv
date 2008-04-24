// test14-brk.sv
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
    $dumpfile("test/VCD/outSuiteA-test14.vcd");
    $dumpvars;

    // init ROM
    top.mem.ROM[4093] = 8'hf0;
    top.mem.ROM[4092] = 8'h00;

    // BRK Interrupt Vector
    top.mem.ROM[4095] = 8'hf0;
    top.mem.ROM[4094] = 8'h05;
    
    // path relative to this file.
    $readmemh("test/roms/SuiteA/test14-brk.rom", top.mem.ROM);
    
    // start test
    resetb = 0;
    #100;
    resetb = 1;
    #1900;
    assert (top.mem.RAM[96] == 8'h42) $display ("PASSED Test 14 - brk");
      else $error("FAILED Test 14 - brk");
    $dumpflush;
    $stop;
  end
endmodule
