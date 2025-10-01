`timescale 1ns / 1ps


module PC(
    input clk,
    input reset,
    input [4:0] data_in,
    input PC_L,
    input PC_I,
    output reg [4:0] A
    );
    
    always @(posedge clk) begin
        if (reset)
            A <= 5'b00000; 
        else if (PC_L) 
            A <= data_in;
        else if (PC_I) 
            A <= A + 1;
            
    end 
       
endmodule
