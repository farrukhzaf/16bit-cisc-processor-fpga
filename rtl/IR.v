`timescale 1ns / 1ps

module IR(
    input clk,
    input reset,
    input [15:0] data_in,
    input IR_L,
    output reg [15:0] data_out
    );
    
    
    always @(posedge clk) begin
        if (reset)
            data_out <= 16'h0000;
        else if (IR_L)
            data_out <= data_in;
   end
   
endmodule
