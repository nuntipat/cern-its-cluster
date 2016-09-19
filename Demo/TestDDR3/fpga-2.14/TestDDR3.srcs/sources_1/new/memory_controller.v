
module memory_controller(
    input fxclk,
    input reset_in, 
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
    // User interface
    output                  mem_clk,
    output reg              mem_rst,            // reset signal synchronize to mem_clk  
    input       [23:0]      mem_addr,
    input                   mem_rw,             // 0 - read, 1 - write
    input       [127:0]     mem_data_in,
    output reg  [127:0]     mem_data_out,
    output                  mem_busy,
    input                   mem_cmd_valid,
    output reg              mem_out_valid
    );
    
    // MIG's ports  
    reg [23:0] app_addr;
    reg [2:0] app_cmd;
    reg app_en, app_wdf_wren;
    wire app_rdy, app_wdf_rdy, app_rd_data_valid;
    reg [127:0] app_wdf_data;
    wire [127:0] app_rd_data;
    wire ui_clk, ui_clk_sync_rst, init_calib_complete;   

    // PLL instantiation
    wire pll_fb, clk200_in, clk400_in, clk200, clk400;
    
    BUFG clk200_buf (          // sometimes it is generated automatically, sometimes not ...
        .I(clk200_in),
        .O(clk200) 
    );

    BUFG clk400_buf (
        .I(clk400_in),
        .O(clk400) 
    );

    PLLE2_BASE #(
        .BANDWIDTH("LOW"),
          .CLKFBOUT_MULT(31),     // f_VCO = 806 MHz (valid: 800 .. 1600 MHz)
          .CLKFBOUT_PHASE(0.0),
          .CLKIN1_PERIOD(0.0),
          .CLKOUT0_DIVIDE(2),    // 403 Mz
          .CLKOUT1_DIVIDE(4),    // 201.5 MHz
          .CLKOUT2_DIVIDE(1),    // unused
          .CLKOUT3_DIVIDE(1),    // unused
          .CLKOUT4_DIVIDE(1),    // unused
          .CLKOUT5_DIVIDE(1),    // unused
          .CLKOUT0_DUTY_CYCLE(0.5),
          .CLKOUT1_DUTY_CYCLE(0.5),
          .CLKOUT2_DUTY_CYCLE(0.5),
          .CLKOUT3_DUTY_CYCLE(0.5),
          .CLKOUT4_DUTY_CYCLE(0.5),
          .CLKOUT5_DUTY_CYCLE(0.5),
          .CLKOUT0_PHASE(0.0),
          .CLKOUT1_PHASE(0.0),
          .CLKOUT2_PHASE(0.0),  // unused
          .CLKOUT3_PHASE(0.0),  // unused
          .CLKOUT4_PHASE(0.0),  // unused
          .CLKOUT5_PHASE(0.0),  // unused
          .DIVCLK_DIVIDE(1),
          .REF_JITTER1(0.0),
          .STARTUP_WAIT("FALSE")
    )
    dram_fifo_pll_inst (
          .CLKIN1(fxclk),
          .CLKOUT0(clk400_in),
          .CLKOUT1(clk200_in),   
          .CLKOUT2(),   
          .CLKOUT3(),   
          .CLKOUT4(),   
          .CLKOUT5(),   
          .CLKFBOUT(pll_fb),
          .CLKFBIN(pll_fb),
          .PWRDWN(1'b0),
          .RST(1'b0)
    );
    
    // MIG instantiation
    mig_7series_0 ddr3_memory (
        // Memory interface ports
        .ddr3_addr                      (ddr3_addr),  // output [13:0]        ddr3_addr
        .ddr3_ba                        (ddr3_ba),  // output [2:0]        ddr3_ba
        .ddr3_cas_n                     (ddr3_cas_n),  // output            ddr3_cas_n
        .ddr3_ck_n                      (ddr3_ck_n),  // output [0:0]        ddr3_ck_n
        .ddr3_ck_p                      (ddr3_ck_p),  // output [0:0]        ddr3_ck_p
        .ddr3_cke                       (ddr3_cke),  // output [0:0]        ddr3_cke
        .ddr3_ras_n                     (ddr3_ras_n),  // output            ddr3_ras_n
        .ddr3_reset_n                   (ddr3_reset_n),  // output            ddr3_reset_n
        .ddr3_we_n                      (ddr3_we_n),  // output            ddr3_we_n
        .ddr3_dq                        (ddr3_dq),  // inout [15:0]        ddr3_dq
        .ddr3_dqs_n                     (ddr3_dqs_n),  // inout [1:0]        ddr3_dqs_n
        .ddr3_dqs_p                     (ddr3_dqs_p),  // inout [1:0]        ddr3_dqs_p
        .init_calib_complete            (init_calib_complete),  // output            init_calib_complete
        
        .ddr3_dm                        (ddr3_dm),  // output [1:0]        ddr3_dm
        .ddr3_odt                       (ddr3_odt),  // output [0:0]        ddr3_odt
        // Application interface ports
        .app_addr                       ({1'b0, app_addr, 3'b000}),  // input [27:0]        app_addr
        .app_cmd                        (app_cmd),  // input [2:0]        app_cmd
        .app_en                         (app_en),  // input                app_en
        .app_wdf_data                   (app_wdf_data),  // input [127:0]        app_wdf_data
        .app_wdf_end                    (app_wdf_wren),  // input                app_wdf_end
        .app_wdf_wren                   (app_wdf_wren),  // input                app_wdf_wren
        .app_rd_data                    (app_rd_data),  // output [127:0]        app_rd_data
        .app_rd_data_end                (),  // output            app_rd_data_end
        .app_rd_data_valid              (app_rd_data_valid),  // output            app_rd_data_valid
        .app_rdy                        (app_rdy),  // output            app_rdy
        .app_wdf_rdy                    (app_wdf_rdy),  // output            app_wdf_rdy
        .app_sr_req                     (1'b0),  // input            app_sr_req
        .app_ref_req                    (1'b0),  // input            app_ref_req
        .app_zq_req                     (1'b0),  // input            app_zq_req
        .app_sr_active                  (),  // output            app_sr_active
        .app_ref_ack                    (),  // output            app_ref_ack
        .app_zq_ack                     (),  // output            app_zq_ack
        .ui_clk                         (ui_clk),  // output            ui_clk
        .ui_clk_sync_rst                (ui_clk_sync_rst),  // output            ui_clk_sync_rst
        .app_wdf_mask                   (16'b0),  // input [15:0]        app_wdf_mask
        // System Clock Ports
        .sys_clk_i                      (clk400),
        // Reference Clock Ports
        .clk_ref_i                      (clk200),
        .device_temp_i                  (),  // input [11:0]            device_temp_i
        .sys_rst                        (!reset_in) // input sys_rst
    );
    
    // Reset generation
    wire mem_reset_async;
    assign mem_reset_async = reset_in || ui_clk_sync_rst || !init_calib_complete; // also wait for MIG to become ready
    
    // User interface signals
    assign mem_clk = ui_clk;
    assign mem_busy = !app_rdy || !app_wdf_rdy || mem_reset_async;
    
    always @ (posedge ui_clk)
        begin
        mem_rst <= mem_reset_async;
        
        if (mem_reset_async)
            begin
            app_addr <= 24'b0;
            app_cmd <= 3'b0;
            app_en <= 1'b0;
            app_wdf_data <= 128'b0;
            app_wdf_wren <= 1'b0;
            mem_data_out <= 128'b0;
            mem_out_valid <= 1'b0;
            end
        else
            begin
            // if the command issued last clk cycle has been accepted, clear app_en
            if (app_rdy)
                app_en <= 1'b0;
            // if write data has been accepted, clear app_wdf_wren and app_wdf_end
            if (app_wdf_rdy)
                app_wdf_wren <= 1'b0;
            
            // Issue new command from user, if any, to MIG module
            if (app_rdy && app_wdf_rdy && mem_cmd_valid)
                begin
                app_addr <= mem_addr;    
                app_en <= 1'b1;
                
                if (mem_rw)
                    begin
                    app_cmd <= 3'b000;    // write command
                    app_wdf_data <= mem_data_in;
                    app_wdf_wren <= 1'b1;
                    end
                else
                    begin
                    app_cmd <= 3'b001;    // read command 
                    end
                end
            
            // if new data arrived
            if (app_rd_data_valid)
                begin
                mem_data_out <= app_rd_data;
                mem_out_valid <= 1'b1;
                end
            else
                begin
                mem_data_out <= 128'b0;
                mem_out_valid <= 1'b0;
                end
            end
        end
      
endmodule
