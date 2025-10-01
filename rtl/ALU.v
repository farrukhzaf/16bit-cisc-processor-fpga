`timescale 1ns / 1ps

module ALU(
    input [15:0] A,
    input [15:0] B,
    input [2:0] AL_S,
    input C_in,           // Carry input for RRC operation
    output reg [15:0] R,
    output reg C,         // Carry output
    output reg Z          // Zero flag
);
    
    always @(*) begin
        case (AL_S)
            3'b000: begin  // ADD
                {C, R} = A + B;
            end
            
            3'b001: begin  // SUB
                {C, R} = A - B;
            end
            
            3'b010: begin  // INCR
                {C, R} = A + 16'h0001;
            end
            
            3'b011: begin  // DECR
                {C, R} = A - 16'h0001;
            end
            
            3'b100: begin  // SHL (Shift Left)
                {C, R} = {A[15], A[14:0], 1'b0};
            end
            
            3'b101: begin  // RRC (Rotate Right with Carry)
                C = A[0];          // LSB goes to carry output
                R = {C_in, A[15:1]}; // Carry input goes to MSB, shift right
            end
            
            default: begin
                R = 16'h0000;
                C = 1'b0;
            end
        endcase
        
        // Zero flag: set if result is zero
        Z = (R == 16'h0000) ? 1'b1 : 1'b0;
    end
                
endmodule