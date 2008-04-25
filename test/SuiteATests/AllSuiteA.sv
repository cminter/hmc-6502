// AllSuiteA.sv

`timescale 1 ns / 1 ps

module optest;
  reg ph1, ph2, resetb;

  reg [7:0] aresult;
  
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
    $dumpfile("test/VCD/outAllSuiteA.vcd");
    $dumpvars;

    // init ROM
    top.mem.ROM[4093] = 8'hf0;
    top.mem.ROM[4092] = 8'h00;
    
    // BRK Interrupt Vector
    top.mem.ROM[4095] = 8'hf5;
    top.mem.ROM[4094] = 8'ha4;

    // path relative to this file.
    $readmemh("test/roms/AllSuiteA.rom", top.mem.ROM);
    
    // start test
    resetb = 0;
    #100;
    resetb = 1;
    #45000;
    assign aresult = top.mem.RAM[528];
    assert (aresult == 8'hFF) $display ("SUCCESS! PASSED SUITE A.");
        else $error("FAILURE: Suite A failed at test%d.", aresult);
    //assert (top.mem.RAM[528] == 8'hFF) $display ("PASSED");
    //  else $error("FAILED");
    $dumpflush;
    $stop;
  end
endmodule
