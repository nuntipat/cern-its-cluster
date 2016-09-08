
module testlsif (
    // control signals
	input fxclk_in,
	input reset_in,
    // hardware pins
	input lsi_clk,
    inout lsi_data,
	input lsi_stop
    );

    wire [7:0] in_addr, out_addr;
    wire [31:0] in_data;
    reg [31:0] out_data;
    wire in_strobe, out_strobe, fxclk;

    BUFG fxclk_buf (
        .I(fxclk_in),
	    .O(fxclk) 
        );
    
    ezusb_lsi lsi_inst (
        .clk(fxclk),
        .reset_in(reset_in),
        .reset(),
        .data_clk(lsi_clk),
        .data(lsi_data),
        .stop(lsi_stop),
        .in_addr(in_addr),
        .in_data(in_data),
        .in_strobe(in_strobe),
        .in_valid(),
        .out_addr(out_addr),
        .out_data(out_data),
        .out_strobe(out_strobe)
        );

    reg [31:0] num1, num2;

    always @ (posedge fxclk)
    begin
        if (in_strobe)
            begin
            if (in_addr == 8'b0)
                num1 <= in_data;
            else if (in_addr == 8'b1)
                num2 <= in_data;
            // TODO: indicate error if in_addr is not 0 or 1
            
            end
        else if (out_strobe)
            begin
            out_data <= num1 + num2;
            end
    end

endmodule
