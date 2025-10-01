`timescale 1ns / 1ps

module flag_register(
    input clk,
    input reset,
    input flag_load,        // Control signal from controller
    input carry_in,         // Carry output from ALU
    input zero_in,          // Zero output from ALU
    output reg carry_flag,  // Stored carry flag
    output reg zero_flag    // Stored zero flag
);

    always @(posedge clk) begin
        if (reset) begin
            carry_flag <= 1'b0;
            zero_flag <= 1'b0;
        end
        else if (flag_load) begin
            carry_flag <= carry_in;
            zero_flag <= zero_in;
        end
    end

endmodule