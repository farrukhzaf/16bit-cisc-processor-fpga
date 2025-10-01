
module top_module(
    input clk,              // 100MHz clock
    input btnC,             // Center button for reset
    output [6:0] seg,       // 7-segment display segments
    output [3:0] an         // 7-segment display anodes
);

    
    wire reset;
    (* DONT_TOUCH = "TRUE" *) wire [15:0] result;
    
    // Use center button as reset (active high)
    assign reset = btnC;
    
    
    
    (* DONT_TOUCH = "TRUE" *) processor cpu (
        .clk(clk),
        .reset(reset),
        .result(result)
    );
    
    
    (* DONT_TOUCH = "TRUE" *) seg7_control display (
        .clk(clk),
        .rst(reset),
        .result(result),
        .seg(seg),
        .an(an)
    );

endmodule