// PowerTest.sv
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
    // init ROM
    top.mem.ROM[4093] = 8'hf0;
    top.mem.ROM[4092] = 8'h00;
    
    // path relative to this file.
    $readmemh("test/roms/PowerTest.rom", top.mem.ROM);
    
    // start test
    reset = 1;
    #100;
    reset = 0;
    #1000;
    assert (top.mem.RAM[66] == 8'hCF) $display ("PASSED Power Test");
      else $error("FAILED Power Test");
  end
endmodule
