// PowerTest.sv
// basic regression test
// tbarr at cs dot hmc dot edu

`timescale 1 ns / 1 ps

module optest;
  reg ph1, ph2, resetb;
  
  wire [7:0] data;
  
  top top(ph1, ph2, resetb);
  
  always begin
    ph1 <= 1; #10; ph1 <= 0; #10;
  end
  always begin
    ph2 <= 0; #10; ph2 <= 1; #10;// ph2 <= 0; #2;
  end
  
  initial begin
    // for VCD file
    // the file that's actually under subversion is test/VCD/SuiteP.vcd, 
    // however it currently has a dummy name so that people can use this 
    // testbench without clobbering the working copy of the vcd file
    $dumpfile("test/VCD/outSuiteP.vcd");
    $dumpvars(1, top.chip.address, top.chip.data_in, top.chip.address, top.chip.data_out,
                 top.chip.ph1, top.chip.ph2, top.chip.resetb, top.chip.read_en, top.chip.razor_error);

    // init ROM
    top.mem.ROM[4093] = 8'hf0;
    top.mem.ROM[4092] = 8'h00;
    
    // path relative to this file.
    $readmemh("test/roms/PowerTest.rom", top.mem.ROM);
    
    // start test
    resetb = 0;
    #100;
    resetb = 1;
    #1000;
    assert (top.mem.RAM[66] == 8'hCF) $display ("PASSED Power Test");
      else $error("FAILED Power Test");
    $dumpflush;
    $stop;
  end
endmodule
