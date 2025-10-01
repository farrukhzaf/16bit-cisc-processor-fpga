`timescale 1ns / 1ps

module top__module_tb();
    // Testbench signals
    reg clk, btnC;
    wire [6:0] seg;
    wire [3:0] an;
    
    // Instantiate the top module
    top_module uut (
        .clk(clk),
        .btnC(btnC),
        .seg(seg),
        .an(an)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns period = 100MHz
    end
    
    // Test sequence
    initial begin
        // Initialize
        btnC = 1; // Assert reset
        #20;
        
        // Release reset
        btnC = 0;
        
        // Let the processor run for several cycles
        #5000;
        
        
        $finish;
    end
    

endmodule
