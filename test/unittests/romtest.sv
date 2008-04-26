// romtest.sv
// tests apple ii rom image
// tbarr at cs dot hmc dot edu

`timescale 1 ns / 1 ps

module romtest;
  reg ph1, ph2, resetb;
  
  logic [15:0] expected_values [4095:0];
  logic [11:0]  current_expectation;
  logic [7:0]  misses;
  
  wire [7:0] data;
  
  top top(ph1, ph2, resetb);
  
  always begin
    ph1 <= 1; #10; ph1 <= 0; #10;
  end
  always begin
    ph2 <= 0; #10; ph2 <= 1; #10;
  end
  
  // watch for expected address path
  always begin
    #10;
    // now, at the rising edge of ph2, compare value on address bus with
    // what we should have.
    if (top.address == expected_values[current_expectation]) begin
      $display("stepped correctly at %d (%h) after %d, moving on", 
                current_expectation, expected_values[current_expectation], misses);
      misses = 8'd0;
      current_expectation = current_expectation + 1;
    end
    else begin
      misses = misses + 1;
      // $display("missed expectation");
      if (misses > 8'd15) begin
        $display("clocked out, failed on step %d waiting for 0x%h", 
              current_expectation, expected_values[current_expectation]);
        $stop;
      end
    end
    #10;
  end
  
  initial begin
    // init variables for expectation system
    misses = 8'd0;
    current_expectation = 12'd0;
    $readmemh("test/paths/apple.path", expected_values);
    
    // path relative to this file.
    $readmemh("test/roms/a2p_traced.hrom", top.mem.ROM);
    
    // start test
    resetb = 0;
    #100;
    resetb = 1;

  end
endmodule
