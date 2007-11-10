// alutest.sv
// tests 6502 ALU
// tbarr at cs hmc edu

`timescale 1 ns / 1 ps

module alutest;
	logic [7:0] a, b, y;
	logic [3:0] op;
	logic c_in, bcd, zero, negative, overflow, c_out;
	
	alu alu(a, b, y, op, c_in, bcd, zero, negative, overflow, c_out);
	
	initial begin
    // test addition
    a = 8'd33; b = 8'd22; c_in = 0; op = 4'h0;
    #1;
    $display("%d + %d = %d", a, b, y);
    assert (y===8'd55) else $error("add failed");
    #1;
    
    // test carry
    a = 8'hff; b = 8'd00; c_in = 1; op = 4'h0;
    #1;
    $display("%h + %h + 1 = %h + %b", a, b, y, c_out);
    assert (y === 8'h00 & c_out === 1) else $error("carry failed");
    #1;
    
    // test or
    a = 8'hf0; b = 8'h1f; c_in = 1; op = 4'h2;
    #1;
    $display("0x%h or 0x%h = 0x%h", a, b, y);
    assert (y===8'hff) else $error("or failed");
    #1;
    
    // test and
    a = 8'hf0; b = 8'h1f; c_in = 1; op = 4'h3;
    #1;
    $display("0x%h and 0x%h = 0x%h", a, b, y);
    assert (y===8'h10) else $error("and failed");
    #1;
    
    // test eor
    a = 8'hf0; b = 8'h1f; c_in = 1; op = 4'h4;
    #1;
    $display("0x%h eor 0x%h = 0x%h", a, b, y);
    assert (y===8'hef) else $error("eor failed");
    #1;
    
    // test asl
    a = 8'hff; b = 8'h42; c_in = 0; op = 4'h7;
    #1;
    $display("0x%h asl c=0 => 0x%h, c=%b", a, y, c_out);
    assert (y === 8'hfe & c_out === 1) else $error("asl failed");
    #1;
    
    // test rol
    a = 8'hff; b = 8'h42; c_in = 0; op = 4'h8;
    #1;
    $display("0x%h rol c=0 => 0x%h, c=%b", a, y, c_out);
    assert (y === 8'hfe & c_out === 1) else $error("rol failed");
    #1;
    
    // test ror
    a = 8'hff; b = 8'h42; c_in = 0; op = 4'h9;
    #1;
    $display("%b rol c=0 => %b, c=%b", a, y, c_out);
    assert (y === 8'h7f & c_out === 1) else $error("ror failed");
    #1;
    
    // done
    $display("finished.");
  end
endmodule