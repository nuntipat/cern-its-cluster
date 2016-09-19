
module TestDDR3(
    input fxclk_in,     // 26MHz
    input ifclk_in,     // 104MHz
    input reset,
    inout [3:0] gpio_n,
    // ddr3 
    inout [15:0] ddr3_dq,
    inout [1:0] ddr3_dqs_n,
    inout [1:0] ddr3_dqs_p,
    output [13:0] ddr3_addr,
    output [2:0] ddr3_ba,
    output ddr3_ras_n,
    output ddr3_cas_n,
    output ddr3_we_n,
    output ddr3_reset_n,
    output [0:0] ddr3_ck_p,
    output [0:0] ddr3_ck_n,
    output [0:0] ddr3_cke,
    output [1:0] ddr3_dm,
    output [0:0] ddr3_odt,
    // ez-usb
    input lsi_clk,
    inout lsi_data,
    input lsi_stop,
    // debug
    output [5:0] debug  // debug[0] : write, debug[1] : read, debug[2] : test done, debug[3] : error 
    );
    
    // Clock's buffer
    wire fxclk;
    
    BUFG fxclk_buf (
        .I(fxclk_in),
        .O(fxclk) 
    );
    
    // EZ-USB low speed interface
    wire [7:0] in_addr, out_addr;
    wire [31:0] in_data;
    reg [31:0] out_data;
    wire in_strobe, out_strobe;
    wire reset_usb;

    ezusb_lsi lsi_inst (
        .clk(fxclk),
        .reset_in(reset),   // Asynchronous reset input
        .reset(reset_usb),  // Synchronous reset
        // HW's port
        .data_clk(lsi_clk),
        .data(lsi_data),
        .stop(lsi_stop),
        // User interface
        .in_addr(in_addr),
        .in_data(in_data),
        .in_strobe(in_strobe),
        .in_valid(),
        .out_addr(out_addr),
        .out_data(out_data),
        .out_strobe(out_strobe)
        );
        
    // Memory controller
    wire mem_clk, mem_rst;
    wire [23:0] mem_addr;
    wire [127:0] mem_data_in;
    wire [127:0] mem_data_out;
    wire mem_rw, mem_busy, mem_cmd_valid, mem_out_valid;
    
    memory_controller mem_ctrl (
        .fxclk              (fxclk),
        .reset_in           (reset || reset_usb),
        // DDR3
        .ddr3_dq            (ddr3_dq),
        .ddr3_dqs_n         (ddr3_dqs_n),    
        .ddr3_dqs_p         (ddr3_dqs_p),    
        .ddr3_addr          (ddr3_addr),
        .ddr3_ba            (ddr3_ba),   
        .ddr3_ras_n         (ddr3_ras_n),
        .ddr3_cas_n         (ddr3_cas_n),
        .ddr3_we_n          (ddr3_we_n),
        .ddr3_reset_n       (ddr3_reset_n),
        .ddr3_ck_p          (ddr3_ck_p),
        .ddr3_ck_n          (ddr3_ck_n),
        .ddr3_cke           (ddr3_cke),
        .ddr3_dm            (ddr3_dm),
        .ddr3_odt           (ddr3_odt),
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
        
    // Memory tester
    wire [127:0] debug_random_data;
    wire [127:0] debug_mem_data;
    
    memory_tester mem_test (
        // User interface
        .mem_clk            (mem_clk),
        .mem_rst            (mem_rst),
        .mem_addr           (mem_addr),
        .mem_rw             (mem_rw), 
        .mem_data_in        (mem_data_in),
        .mem_data_out       (mem_data_out),
        .mem_busy           (mem_busy), 
        .mem_cmd_valid      (mem_cmd_valid),
        .mem_out_valid      (mem_out_valid),
        // Debug
        .write              (debug[0]),
        .read               (debug[1]),
        .done               (debug[2]),
        .error              (debug[3]),
        .debug_random_data  (debug_random_data),
        .debug_mem_data     (debug_mem_data)
        );    
    
    always @ (posedge fxclk)
        begin
            if (out_strobe)
                begin
                // flag (1 - done)
                if (out_addr == 8'd0)
                    out_data <= {31'b0, debug[2]};
                // error (1 - error, 0 - ok)
                else if (out_addr == 8'd1)
                    out_data <= {31'b0, debug[3]};
                // register 2-5 for 128-bits last data retreive from random number generator
                else if (out_addr == 8'd2)
                    out_data <= debug_random_data[31:0];
                else if (out_addr == 8'd3)
                    out_data <= debug_random_data[63:32];
                else if (out_addr == 8'd4)
                    out_data <= debug_random_data[95:64];
                else if (out_addr == 8'd5)
                    out_data <= debug_random_data[127:96];
                // register 6-9 for 128-bits last data read from memory
                else if (out_addr == 8'd6)
                    out_data <= debug_mem_data[31:0];
                else if (out_addr == 8'd7)
                    out_data <= debug_mem_data[63:32];
                else if (out_addr == 8'd8)
                    out_data <= debug_mem_data[95:64];
                else if (out_addr == 8'd9)
                    out_data <= debug_mem_data[127:96]; 
                // other unused register will read 0xff                 
                else
                    out_data <= 32'hffffffff;
                end
        end
   
endmodule
