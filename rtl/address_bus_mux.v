`timescale 1ns / 1ps

// Address Bus Multiplexer (2-to-1)
module address_mux(
    input [4:0] pc_addr,        // PC address
    input [4:0] instr_addr,     // Instruction address field
    input mem_addr_sel,         // 0=PC, 1=instruction address
    output [4:0] mem_addr       // Output to memory
);
    
    assign mem_addr = (mem_addr_sel) ? instr_addr : pc_addr;
    
endmodule