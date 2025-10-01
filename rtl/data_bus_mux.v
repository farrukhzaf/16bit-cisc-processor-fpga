`timescale 1ns / 1ps


// Data Bus Multiplexer (3-to-1)
module data_bus_mux(
    input [15:0] alu_data,      // ALU output
    input [15:0] memory_data,   // Memory output
    input [15:0] rf_data,       // Register file output
    input [1:0] data_bus_sel,   // 00=ALU, 01=Memory, 10=Register File
    output [15:0] data_bus      // Shared data bus
);
    
    assign data_bus = (data_bus_sel == 2'b00) ? alu_data :
                      (data_bus_sel == 2'b01) ? memory_data :
                      (data_bus_sel == 2'b10) ? rf_data :
                      16'h0000; // Default case
    
endmodule
