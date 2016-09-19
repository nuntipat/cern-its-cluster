
module simple_mem_ctrl(
    input fxclk,
    input reset_in,
    output reset_out,   
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
    input                   sys_clk,
    input       [23:0]      addr,
    input                   rw,         // 0 - read, 1 - write
    input       [127:0]     data_in,
    output reg  [127:0]     data_out,
    output                  busy,
    input                   in_valid,
    output reg              out_valid,
    // Debug
    output reg done,
    output reg error,
    output [2:0] debug_state,
    output reg [127:0] debug_data
    );
    
    // MIG's ports  
    reg [23:0] app_addr;
    reg [2:0] app_cmd;
    reg app_en, app_wdf_wren;
    wire app_rdy, app_wdf_rdy, app_rd_data_valid;
    reg [127:0] app_wdf_data;
    wire [127:0] app_rd_data;
    wire ui_clk, ui_clk_sync_rst, init_calib_complete;   

    // PLL and MIG instantiation
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
        .sys_rst                        (!reset) // input sys_rst
    );
    
    // Reset generation
    wire mem_reset;
    reg reset_buf;
    
    assign mem_reset = reset || ui_clk_sync_rst || !init_calib_complete; // also wait for MIG to become ready
    assign reset_out = reset_buf;
    
    parameter   IDLE = 3'd0,
                WRITE = 3'd1,
                WAIT_WRITE = 3'd2,
                READ = 3'd3,
                WAIT_READ = 3'd4,
                DONE = 3'd5,
                ERROR =3'd6;
                
    parameter   WRITE_ADDR = 24'd10;
    parameter   WRITE_DATA = 128'h918273645abcdef5647382819fedcba1;
                
    reg [2:0] state;
    
    assign debug_state = state;
                
    always @ (posedge ui_clk)
    begin
        reset_buf <= mem_reset;
        
        done <= 1'b0;
        error <= 1'b0;
    
        if (mem_reset)
            begin
            state <= IDLE;
            end
        else
            begin
            if (state == IDLE)
                begin
                state <= WRITE;
                end
            else if (state == WRITE)
                begin
                app_cmd <= 3'b000;
                app_addr <= WRITE_ADDR;
                app_en <= 1'b1;
                
                app_wdf_data <= WRITE_DATA;
                app_wdf_wren <= 1'b1;
                
                state <= WAIT_WRITE;
                end
            else if (state == WAIT_WRITE)
                begin
                if (app_rdy)
                    app_en <= 1'b0;
                    
                if (app_wdf_rdy)
                    app_wdf_wren <= 1'b0;
                    
                if (app_rdy && app_wdf_rdy)
                    state <= READ;
                end
            else if (state == READ)
                begin
                app_cmd <= 3'b001;
                app_addr <= WRITE_ADDR;
                app_en <= 1'b1;
                
                state <= WAIT_READ;
                end
            else if (state == WAIT_READ)
                begin
                if (app_rdy)
                    app_en <= 1'b0;
                    
                if (app_rd_data_valid)
                    begin
                    debug_data <= app_rd_data;
                    if (app_rd_data == WRITE_DATA)
                        state <= DONE;
                    else
                        state <= ERROR;
                    end
                end
            else if (state == DONE)
                begin
                done <= 1'b1;
                error <= 1'b0;
                
                state <= DONE;
                end
            else if (state == ERROR)
                begin
                done <= 1'b1;
                error <= 1'b1;
                
                state <= ERROR;
                end
            end
    end
    
    
    
    /*assign busy = !app_rdy || !app_wdf_rdy || reset || ui_clk_sync_rst || !init_calib_complete; 

    always @ (posedge ui_clk)
    begin
        // default value for MIG user interface signal
        //app_addr <= 28'b0;
        //app_cmd <= 3'b0;
        //app_en <= 1'b0;
        //app_wdf_data <= 128'b0;
        //app_wdf_end <= 1'b0;
        //app_wdf_wren <= 1'b0;
        // MIG's unused signals -> always zero
        app_sr_req <= 1'b0;
        app_ref_req <= 1'b0;
        app_zq_req <= 1'b0;
        app_wdf_mask <= 16'b0; 
        // default value for user interface
        data_out <= 128'b0;
        out_valid <= 1'b0;
        
        if (reset || ui_clk_sync_rst || !init_calib_complete)   // also wait for MIG to become ready
        begin
            app_addr <= 28'b0;
            app_cmd <= 3'b0;
            app_en <= 1'b0;
            app_wdf_data <= 128'b0;
            app_wdf_end <= 1'b0;
            app_wdf_wren <= 1'b0;
            //busy <= 1'b1;
        end
        else
        begin
            //busy <= !app_rdy || !app_wdf_rdy;
        
            // if the command issued last clk cycle has been accepted, clear app_en
            if (app_rdy)
                app_en <= 1'b0;
            // if write data has been accepted, clear app_wdf_wren and app_wdf_end
            if (app_wdf_rdy)
            begin
                app_wdf_wren <= 1'b0;
                app_wdf_end <= 1'b0;
            end
            
            // Issue new command from user, if any, to MIG module
            if (in_valid)
            begin
                app_addr <= {1'b0, addr, 3'b000};    
                app_en <= 1'b1;
                
                if (rw)
                begin
                    app_cmd <= 3'b000;    // write command
                    app_wdf_data <= data_in;
                    app_wdf_wren <= 1'b1;
                    app_wdf_end <= 1'b1; 
                end
                else
                begin
                    app_cmd <= 3'b001;    // read command 
                end
            end
            
            // if new data arrived
            if (app_rd_data_valid)
            begin
                data_out <= app_rd_data;
                out_valid <= 1'b1;
            end
        end
    end*/

    /*parameter   IDLE                        =   6'b000001,
                WAIT_WRITE_COMMAND_ACCEPT   =   6'b000010,
                WAIT_WRITE_DATA_ACCEPT      =   6'b000100,
                WAIT_WRITE_COM_DAT_ACCEPT   =   6'b001000,
                WAIT_READ_ACCEPT            =   6'b010000,
                READING                     =   6'b100000;
                
    reg [5:0] state = IDLE;
    
    always @ (posedge ui_clk)
      begin
        // default value
        app_addr <= 28'b0;
        app_cmd <= 3'b0;
        app_en <= 1'b0;
        app_wdf_data <= 128'b0;
        app_wdf_end <= 1'b0;
        app_wdf_wren <= 1'b0;
        app_sr_req <= 1'b0;
        app_ref_req <= 1'b0;
        app_zq_req <= 1'b0;
        app_wdf_mask <= 16'b0; 
      
        data_out <= 128'b0;
        busy <= 1'b0;
        out_valid <= 1'b0;
      
        if (reset || ui_clk_sync_rst || !init_calib_complete)   // also wait for MIG to become ready
          begin
            state <= IDLE;
            busy <= 1'b1;   // don't accept command until the MIG module is ready
          end
        else
          begin
            if (state == IDLE)
              begin
                if (in_valid)
                  begin
                    if (rw)
                      begin                      
                        app_cmd <= 3'b000;    // write command
                        app_addr <= {1'b0, addr, 3'b000};
                        app_en <= 1'b1;
                        
                        app_wdf_data <= data_in;    // write data
                        app_wdf_wren <= 1'b1;
                        app_wdf_end <= 1'b1;
                        
                        if (app_rdy && app_wdf_rdy)         // command and data has been accepted
                          state <= IDLE;
                        else if (!app_rdy && app_wdf_rdy)   // wait until command is accepted
                          state <= WAIT_WRITE_COMMAND_ACCEPT;
                        else if (app_rdy && !app_wdf_rdy)   // wait until data is accepted
                          state <= WAIT_WRITE_DATA_ACCEPT;
                        else
                          state <= WAIT_WRITE_COM_DAT_ACCEPT;
                      end
                    else
                      begin
                        state <= WAIT_READ_ACCEPT;
                      
                        app_cmd <= 3'b001;    // read command 
                        app_addr <= {1'b0, addr, 3'b000};
                        app_en <= 1'b1;
                        
                        if (app_rdy && app_rd_data_valid)   // command is accepted and data has been read
                          begin
                            data_out <= app_rd_data;
                            out_valid <= 1'b1;
                          end
                        else if (!app_rdy)                  // wait until command is accepted
                          state <= WAIT_READ_ACCEPT;
                        else                                // wait until data is read
                          state <= READING; 
                      end
                  end
              end
            else if (state == WAIT_WRITE_COMMAND_ACCEPT)
              begin
                busy <= 1'b1;
              
                app_cmd <= 3'b000;    // hold command
                app_addr <= app_addr;
                app_en <= 1'b1;
              
                if (!app_rdy)               // wait until command is accepted
                  state <= WAIT_WRITE_COMMAND_ACCEPT;
                else                       
                  state <= IDLE;
              end
            else if (state == WAIT_WRITE_DATA_ACCEPT)
                begin
                  busy <= 1'b1;
                  
                  app_wdf_data <= app_wdf_data;
                  app_wdf_wren <= 1'b1;
                  app_wdf_end <= 1'b1;
                
                  if (!app_wdf_rdy)   // hold data if it hasn't been accepted
                      state <= WAIT_WRITE_DATA_ACCEPT;
                  else
                      state <= IDLE;
                end
            else if (state == WAIT_WRITE_COM_DAT_ACCEPT)
              begin
                  busy <= 1'b1;
              
                  app_cmd <= 3'b000;    // write command
                  app_addr <= app_addr;
                  app_en <= 1'b1;
                  
                  app_wdf_data <= app_wdf_data;    // write data
                  app_wdf_wren <= 1'b1;
                  app_wdf_end <= 1'b1;
                  
                  if (app_rdy && app_wdf_rdy)         // command and data has been accepted
                    state <= IDLE;
                  else if (!app_rdy && app_wdf_rdy)   // wait until command is accepted
                    state <= WAIT_WRITE_COMMAND_ACCEPT;
                  else if (app_rdy && !app_wdf_rdy)   // wait until data is accepted
                    state <= WAIT_WRITE_DATA_ACCEPT;
                  else
                    state <= WAIT_WRITE_COM_DAT_ACCEPT;
              end
            else if (state == WAIT_READ_ACCEPT)
              begin
                busy <= 1'b1;
              
                app_cmd <= 3'b001;      // hold command 
                app_addr <= app_addr;   // hold address until accepted
                app_en <= 1'b1;
              
                if (app_rdy && app_rd_data_valid)   // command is accepted and data has been read
                  begin
                    data_out <= app_rd_data;
                    out_valid <= 1'b1;
                    state <= IDLE;
                  end
                else if (!app_rdy)                  // wait until command is accepted
                  state <= WAIT_READ_ACCEPT;
                else                                // wait until data is read
                  state <= READING; 
              end
            else if (state == READING)
              begin
                busy <= 1'b1;
              
                if (app_rd_data_valid)   // data has been read
                  begin
                    data_out <= app_rd_data;
                    out_valid <= 1'b1;
                    state <= IDLE;
                  end
              end  
          end
      end*/
      
endmodule

