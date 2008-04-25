// branchoptions.sv
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
    $dumpfile("test/VCD/branchoptions.vcd");
    $dumpvars(1, top.chip.address, top.chip.data_in, top.chip.address, top.chip.data_out,
                 top.chip.ph0, top.chip.resetb, top.chip.read_en, top.chip.razor_error);

    // init ROM
    top.mem.ROM[4093] = 8'hf0;
    top.mem.ROM[4092] = 8'h00;
    
    // path relative to this file.
    $readmemh("test/roms/branchoptions.rom", top.mem.ROM);
    
    // start test
    resetb = 0;
    #100;
    resetb = 1;
    #5000;
    assert (top.mem.RAM[80] == 8'h88) $display ("PASSED branch options test");
      else $error("FAILED branch options test");
    $dumpflush;
    $stop;
  end
endmodule
