`timescale 1ns / 1ps

module TR2(
    input clk,
    input reset,
    input [15:0] data_in,
    input TR2_L,
    output reg [15:0] data_out
    );
    
    
    always @(posedge clk) begin
        if (reset)
            data_out <= 16'h0000;
        else if (TR2_L)
            data_out <= data_in;
   end
   
endmodule
