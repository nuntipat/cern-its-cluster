
module memory_tester(
    input              mem_clk,
    input              mem_rst,                 // reset signal synchronize to mem_clk  
    output reg [23:0]  mem_addr,
    output reg         mem_rw,                  // 0 - read, 1 - write
    output [127:0]     mem_data_in,
    input  [127:0]     mem_data_out,
    input              mem_busy,
    output reg         mem_cmd_valid,
    input              mem_out_valid,
    // Debug
    output                  write,
    output                  read,
    output reg              done,
    output reg              error,
    output reg [127:0]      debug_random_data,  // last data retreive from random number generator when done or error
    output reg [127:0]      debug_mem_data      // last data read from memory when done or error
    );
    
    parameter  WRITE       = 3'd0,
               READ        = 3'd1,
               WAIT_DATA   = 3'd2,
               DONE        = 3'd3,
               ERROR       = 3'd4;
               
    parameter TEST_END_ADDR = 24'h0fffff;   // Test 16MB from 256MB available
    
    reg [2:0] state;
    
    // Instantiate a random number generator to generate a random sequence to test read and write to/from memory    
    wire [127:0] random_number;
    reg next, rng_rst;
    
    random_generator #(
       .SEED(128'h3a84_2f73_9184_a3b4_f67e_d4b7_a425_1b3d)
    ) rng1 (mem_clk, rng_rst || mem_rst, next || (!mem_busy && (state == WRITE)), random_number[127:64]);
    random_generator #(
       .SEED(128'h1b27_9ced_452a_36a5_7d21_78a3_68a7_32bc)
    ) rng2 (mem_clk, rng_rst || mem_rst, next || (!mem_busy && (state == WRITE)), random_number[63:0]);
   
    assign mem_data_in = random_number;
    
    assign write = !mem_rst && (state == WRITE);
    assign read = (state == READ) || (state == WAIT_DATA);
   
    // FSM to control the test process
    always @ (posedge mem_clk)
        begin
        rng_rst <= 1'b0;
        next <= 1'b0;
        
        if (mem_rst)
            begin
            mem_addr <= 24'hffffff;
            mem_rw <= 1'b0;
            mem_cmd_valid <= 1'b0;
            
            done <= 1'b0;
            error <= 1'b0;
            debug_random_data <= 128'b0;
            debug_mem_data <= 128'b0;
            
            next <= 1'b0;
            rng_rst <= 1'b1;
            state <= WRITE;
            end
        else
            begin
            if (state == WRITE)
                begin
                if (!mem_busy)
                    begin
                    mem_addr <= mem_addr + 1;
                    mem_rw <= 1'b1;
                    mem_cmd_valid <= 1'b1;
                    
                    if (mem_addr == TEST_END_ADDR)
                        begin
                        mem_addr <= 24'b0;
                        mem_rw <= 1'b0;
                        rng_rst <= 1'b1;
                        state <= READ;
                        end
                    end
                end
            else if (state == READ)
                begin
                if (!mem_busy)
                    begin
                    mem_cmd_valid <= 1'b0;
                    state <= WAIT_DATA;
                    end
                end
            else if (state == WAIT_DATA)
                begin
                if (mem_out_valid)
                    begin
                    if (random_number == mem_data_out)
                        begin
                        mem_addr <= mem_addr + 1;
                        mem_rw <= 1'b0;
                        mem_cmd_valid <= 1'b1;
                        next <= 1'b1;
                        state <= READ;
                        
                        if (mem_addr == TEST_END_ADDR)
                            begin
                            debug_random_data <= random_number;
                            debug_mem_data <= mem_data_out;
                            mem_cmd_valid <= 1'b0;
                            state <= DONE;
                            end
                        end
                    else
                        begin
                        debug_random_data <= random_number;
                        debug_mem_data <= mem_data_out;
                        state <= ERROR;
                        end
                    end
                end
            else if (state == DONE)
                begin
                done <= 1'b1;
                error <= 1'b0;
                end
            else if (state == ERROR)
                begin
                done <= 1'b1;
                error <= 1'b1;
                end
            end
        end
       
endmodule
