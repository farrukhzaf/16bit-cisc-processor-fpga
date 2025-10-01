`timescale 1ns / 1ps

module processor_tb();

    // Testbench signals
    reg clk, reset;
    wire result;

    // Instantiate the processor
    processor uut (
        .clk(clk),
        .reset(reset),
        .result(result)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns period = 100MHz
    end

    // Test sequence
    initial begin
        // Initialize
        reset = 1;
        #20;
        
        // Release reset
        reset = 0;
        
        // Let the processor run for several cycles
        #200;
        
        
        $finish;
    end

   

endmodule