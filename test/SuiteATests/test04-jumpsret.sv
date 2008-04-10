// test04-jumpsret.sv
// basic regression test
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
    // for VCD file
    $dumpfile("test/VCD/outSuiteA-test04.vcd");
    $dumpvars;

    // init ROM
    top.mem.ROM[4093] = 8'hf0;
    top.mem.ROM[4092] = 8'h00;

    // init SP to top of memory
    top.chip.core.dp.regfile.reg_file[3] = 8'hFF;
    
    // path relative to this file.
    $readmemh("test/roms/SuiteA/test04-jumpsret.rom", top.mem.ROM);
    
    // start test
    reset = 1;
    #100;
    reset = 0;
    #1200;
    assert (top.mem.RAM[64] == 8'h42) $display ("PASSED Test 04 - jumps & returns");
      else $error("FAILED Test 04 - jumps & returns");
    $dumpflush;
    $stop;
  end
endmodule
