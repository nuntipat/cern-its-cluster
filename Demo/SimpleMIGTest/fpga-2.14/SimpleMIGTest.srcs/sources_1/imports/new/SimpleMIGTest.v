
module SimpleMIGTest(
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
    output [5:0] debug
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
        
    // Memory controller ports (currently unused)
    wire mem_reset;
    wire [23:0] addr;
    wire [127:0] data_in;
    wire [127:0] data_out;
    wire rw, busy, in_valid, out_valid;
    
    wire [127:0] debug_data;
    
    simple_mem_ctrl mem_ctrl (
        .fxclk              (fxclk),
        .reset_in           (reset || reset_usb),
        .reset_out          (mem_reset),
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
        // User interface (will be used in the next example)
        .sys_clk            (fxclk),
        .addr               (addr),
        .rw                 (rw), 
        .data_in            (data_in),
        .data_out           (data_out),
        .busy               (busy), 
        .in_valid           (in_valid),
        .out_valid          (out_valid),
        // Debug connections
        .done (debug[0]),   // 1 - done
        .error (debug[1]),  // 1 - error, 0 - ok
        .debug_state (debug[4:2]),  // internal state of memory controller
        .debug_data (debug_data)    // data read from memory which can be retrieve from host using the low speed interface of ztex's sdk
    );    
    
    always @ (posedge fxclk)
        begin
            if (out_strobe)
                begin
                // flag (1 - done)
                if (out_addr == 8'd0)
                    out_data <= {31'b0, debug[0]};
                // error (1 - error, 0 - ok)
                else if (out_addr == 8'd1)
                    out_data <= {31'b0, debug[1]};
                // register 2-5 for 128-bits data read from memory
                else if (out_addr == 8'd2)
                    out_data <= debug_data[31:0];
                else if (out_addr == 8'd3)
                    out_data <= debug_data[63:32];
                else if (out_addr == 8'd4)
                    out_data <= debug_data[95:64];
                else if (out_addr == 8'd5)
                    out_data <= debug_data[127:96];
                // other unused register will read 0xff                 
                else
                    out_data <= 32'hffffffff;
                end
        end
   
endmodule
