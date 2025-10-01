`timescale 1ns / 1ps


module ID(
    input [15:0] instruction,
    
    output [4:0] opcode,
    output [2:0] rd,
    output [2:0] rs1, 
    output [2:0] rs2,
    output [4:0] address,
    
    output is_arithmetic,
    output is_immediate,
    output is_load,
    output is_store,
    output is_jump_unconditional,
    output is_jump_conditional
    );
    
    
    // Extract opcode (always bits [15:11])
    assign opcode = instruction[15:11];
    
    assign rd = instruction[10:8];   
    assign rs1 = instruction[4:2];   
    assign rs2 = instruction[7:5];   
    
    
    assign address = instruction[4:0];
    
    
    
    
    
    assign is_arithmetic = (instruction[15:13] == 3'b010);
    
    assign is_immediate = (instruction[15:13] == 3'b011);
    
    assign is_load = (instruction[15:13] == 3'b000);
    assign is_store = (instruction[15:13] == 3'b001);
    
    assign is_jump_unconditional = (instruction[15:13] == 3'b100);
    assign is_jump_conditional = (instruction[15:13] == 3'b101);
    
    
        
endmodule
