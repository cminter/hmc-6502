// test03-bitshifts.sv
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
    
    top.chip.core.dp.regfile.reg_file[0] = 8'h0;
    top.chip.core.dp.regfile.reg_file[1] = 8'h0;
    top.chip.core.dp.regfile.reg_file[2] = 8'h0;
    top.chip.core.dp.regfile.reg_file[3] = 8'h0;
    
    top.chip.core.dp.flaglatch.latch0.q = 0;
    top.chip.core.dp.flaglatch.latch1.q = 0;
    top.chip.core.dp.flaglatch.latch2.q = 0;
    top.chip.core.dp.flaglatch.latch3.q = 0;
    top.chip.core.dp.flaglatch.latch4.q = 0;
    top.chip.core.dp.flaglatch.latch5.q = 0;
    top.chip.core.dp.flaglatch.latch6.q = 0;
    top.chip.core.dp.flaglatch.latch7.q = 0;
    
    // path relative to this file.
    $readmemh("test/roms/SuiteA/test03-bitshifts.rom", top.mem.ROM);
    
    // start test
    reset = 1;
    #100;
    reset = 0;
    #500;
    assert (top.mem.RAM[477] == 8'h6E) $display ("PASSED Test 03 - bitshifts");
      else $error("FAILED Test 03 - bit shifts");
  end
endmodule
