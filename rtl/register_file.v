`timescale 1ns / 1ps

module register_file(
    input clk,
    input reset,
    input [2:0] rf_addr,
    input R_L,         // Register Load: enables writing to the register
    input R_E,         // Register Enable: enables reading from the register
    input [15:0] data_in,
    output [15:0] data_out,
    output [15:0] result
);
    // Declare 8 registers, each 16 bits wide
    reg [15:0] RA, RB, RC, RD, RE, RF, RG, RH;
    
    assign result = RD;

    // Sequential block for register write
    always @(posedge clk) begin
        if (reset) begin
            // Reset all registers to 0
            RA <= 16'h0000;
            RB <= 16'h0000;
            RC <= 16'h0000;
            RD <= 16'h0000;
            RE <= 16'h0000;
            RF <= 16'h0000;
            RG <= 16'h0000;
            RH <= 16'h0000;
        end else if (R_L) begin // Only write on load enable
            case (rf_addr)
                3'b000: RA <= data_in;
                3'b001: RB <= data_in;
                3'b010: RC <= data_in;
                3'b011: RD <= data_in;
                3'b100: RE <= data_in;
                3'b101: RF <= data_in;
                3'b110: RG <= data_in;
                3'b111: RH <= data_in;
            endcase
        end
    end

    // Combinational block for register read
    assign data_out = (R_E) ? (
        (rf_addr == 3'b000) ? RA :
        (rf_addr == 3'b001) ? RB :
        (rf_addr == 3'b010) ? RC :
        (rf_addr == 3'b011) ? RD :
        (rf_addr == 3'b100) ? RE :
        (rf_addr == 3'b101) ? RF :
        (rf_addr == 3'b110) ? RG :
        (rf_addr == 3'b111) ? RH :
        16'h0000 // Default value if address is not matched
    ) : 16'h0000; // If read enable is low, output is 0
endmodule