// datapathtest.sv
// tests datapath
// tbarr at cs dot hmc dot edu

`timescale 1 ns / 1 ps

module dpathtest;
  logic ph1, ph2, reset, read_write_sel;
  logic [15:0] address;
  logic [7:0] data_write, data_read;
  
  wire [7:0] data;
  
  // controls list from ucodeasm
  logic th_in_en;
  logic th_out_en;
  logic tl_in_en;
  logic tl_out_en;
  logic [7:0] p_in_en;
  logic p_out_en;
  logic p_sel;
  logic reg_write_en;
  logic [1:0] reg_read_addr_a;
  logic [1:0] reg_read_addr_b;
  logic [1:0] reg_write_addr;
  logic reg_a_en;
  logic pch_in_en;
  logic pch_out_en;
  logic pcl_in_en;
  logic pcl_out_en;
  logic pc_inc_en;
  logic pc_sel;
  logic d_in_en;
  logic d_out_sel;
  logic [1:0] ah_sel;
  logic al_sel;
  logic [3:0] alu_op;
  logic c_temp_en;
  logic carry_sel;
  
  mem mem(ph1, ph2, reset, address, data, read_write_sel);
  datapath dp(data_read, data_write, address, ph1, ph2, reset,
              th_in_en,
              th_out_en,
              tl_in_en,
              tl_out_en,
              p_in_en,
              p_out_en,
              p_sel,
              reg_write_en,
              reg_read_addr_a,
              reg_read_addr_b,
              reg_write_addr,
              reg_a_en,
              pch_in_en,
              pch_out_en,
              pcl_in_en,
              pcl_out_en,
              pc_inc_en,
              pc_sel,
              d_in_en,
              d_out_sel,
              ah_sel,
              al_sel,
              alu_op,
              c_temp_en,
              carry_sel);
              
  assign data = (read_write_sel) ? 8'bz : data_write;
  // assign data_read = (read_write_sel) ? data : 8'b0;
  
  always begin
    ph1 <= 1; #1; ph1 <= 0; #1;
  end
    always begin
    ph2 <= 0; #1; ph2 <= 1; #1;
  end
  
  initial begin
    // init ROM
    mem.ROM[4093] = 8'hf0;
    mem.ROM[4092] = 8'h00;
    
    // path relative to this file.
    // $readmemh("../roms/memtest.rom", mem.ROM);
    
    // reset everything
    th_in_en = 0;
    th_out_en = 0;
    tl_in_en = 0;
    tl_out_en = 0;
    p_in_en = 8'b0;
    p_out_en = 0;
    p_sel = 0;
    reg_write_en = 0;
    reg_read_addr_a = 2'b0;
    reg_read_addr_b = 2'b0;
    reg_write_addr = 2'b0;
    reg_a_en = 0;
    pch_in_en = 0;
    pch_out_en = 0;
    pcl_in_en = 0;
    pcl_out_en = 0;
    pc_inc_en = 0;
    pc_sel = 0;
    d_in_en = 0;
    d_out_sel = 0;
    ah_sel = 2'b0;
    al_sel = 0;
    alu_op = 4'b0;
    c_temp_en = 0;
    carry_sel = 0;
    reset = 1;
    read_write_sel = 1;
    #10;
    
    reset = 0;
    
    // start test
    
    // pc testing
    pch_in_en = 1; pcl_in_en = 1; pc_inc_en = 1; #10;
    $display("pcl: %h", dp.pc_low.value);
    assert (dp.pc_low.value === 8'h5) else $error("invalid pc");
    
    // arithmetic test
    reg_read_addr_b = 2'b01;
    reg_write_addr = 2'b01;
    data_read = 8'b1;
    d_in_en = 1;
    #1;
    reg_write_en = 1;
    #9;
    
    // temp latch test
    th_in_en = 1;
    tl_in_en = 1;
    ah_sel = 2'b01;
    al_sel = 1;
  end
endmodule
