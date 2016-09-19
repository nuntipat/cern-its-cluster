`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/17/2016 08:14:21 PM
// Design Name: 
// Module Name: test_mem_ctrl
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module test_mem_ctrl;

    reg mem_clk, mem_rst;
    wire [23:0] mem_addr;
    wire [127:0] mem_data_in;
    reg [127:0] mem_data_out;
    wire mem_rw, mem_cmd_valid;
    reg mem_busy, mem_out_valid;

    memory_tester uut (
        // User interface
        .mem_clk            (mem_clk),
        .mem_rst            (mem_rst),
        .mem_addr           (mem_addr),
        .mem_rw             (mem_rw), 
        .mem_data_in        (mem_data_in),
        .mem_data_out       (mem_data_out),
        .mem_busy           (mem_busy), 
        .mem_cmd_valid      (mem_cmd_valid),
        .mem_out_valid      (mem_out_valid)
        );    
    
    always #5 mem_clk = !mem_clk;
    
    initial begin
        mem_clk = 1;
        mem_rst = 1;
        mem_data_out = 0;
        mem_busy = 1;
        mem_out_valid = 0;
        #10
        mem_rst = 0;
        mem_busy = 0;
        #130
        mem_data_out = 128'h6bb14cc5aaaacbdf8dc5c02c1c4f59d2;
        mem_out_valid = 1'b1;
        #10
        mem_out_valid = 1'b0;
    end

endmodule
