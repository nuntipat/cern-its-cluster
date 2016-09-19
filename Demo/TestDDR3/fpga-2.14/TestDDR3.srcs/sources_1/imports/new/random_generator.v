
// Random number generator based on xorshift+
module random_generator(
    input clk,
    input rst,
    // user interface
    input next,                 // 1 - generate new number, 0 - hold latest value
    output reg [63:0] number    // output
    );
    
    parameter SEED = 128'h3a84_2f73_9184_a3b4_f67e_d4b7_a425_1b3d;
    
    reg [127:0] s;  // s[127:64] is s[0] and s[63:0] is s[1]
    
    wire [63:0] x, tmp;
    assign x = s[127:64] ^ (s[127:64] << 23);
    assign tmp = x ^ s[63:0] ^ (x >> 17) ^ (s[63:0] >> 26);
    
    // compute initial randon number for the given seed at compile time
    localparam x_rst = SEED[127:64] ^ (SEED[127:64] << 23);
    localparam tmp_rst = x_rst ^ SEED[63:0] ^ (x_rst >> 17) ^ (SEED[63:0] >> 26);
    localparam rst_value = tmp_rst + SEED[63:0]; 
    
    always @ (posedge clk)
    begin
      if (rst)
        begin
          s[127:64] <= SEED[63:0];
          s[63:0] <= tmp_rst;
          number <= rst_value;      // after reset number should be the first number instead of 0
        end
      else if (next)
        begin
                                        // uint64_t x = s[0];
                                        // uint64_t const y = s[1];
          s[127:64] <= s[63:0];         // s[0] = y;
                                        // x ^= x << 23; 
          s[63:0] <= tmp;               // s[1] = x ^ y ^ (x >> 17) ^ (y >> 26); 
          number <= tmp + s[63:0];      // return s[1] + y;
        end
    end

endmodule