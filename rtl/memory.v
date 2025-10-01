`timescale 1ns / 1ps

module memory(
    input clk,
    input [4:0] addr,         // 5-bit address for 32 locations
    input [15:0] data_in,     // Data to write
    input mem_write,          // Memory write enable
    output [15:0] data_out    // Data read from memory
);

    // Instantiate the Distributed Memory Generator IP
    dist_mem_gen_0 mem_core (
        .a(addr),        // 5-bit address
        .d(data_in),     // 16-bit input data
        .clk(clk),       // clock
        .we(mem_write),  // write enable
        .spo(data_out)   // async 16-bit output data
    );

endmodule
