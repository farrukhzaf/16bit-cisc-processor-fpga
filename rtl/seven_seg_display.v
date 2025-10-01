`timescale 1ns / 1ps

module seg7_control(
    input clk,
    input rst,
    input [15:0] result,
    
    output reg [6:0] seg,      // segment pattern (a-g)
    output reg [3:0] an       // digit select signals
);

    // Wires to hold the 4-bit value for each of the four hex digits
    wire [3:0] ones;
    wire [3:0] tens;
    wire [3:0] hundreds;
    wire [3:0] thousands;
    
    // CORRECTED: Assign parts of the input 'result' to the internal digit wires.
    // The source is on the right and the destination is on the left.
    assign ones      = result[3:0];
    assign tens      = result[7:4];
    assign hundreds  = result[11:8];
    assign thousands = result[15:12];

    // Parameters for segment patterns (Correct for Basys3 Common Anode)
    // A '0' turns a segment ON. {g,f,e,d,c,b,a}
    parameter ZERO    = 7'b1000000;  // 0
    parameter ONE     = 7'b1111001;  // 1
    parameter TWO     = 7'b0100100;  // 2 
    parameter THREE   = 7'b0110000;  // 3
    parameter FOUR    = 7'b0011001;  // 4
    parameter FIVE    = 7'b0010010;  // 5
    parameter SIX     = 7'b0000010;  // 6
    parameter SEVEN   = 7'b1111000;  // 7
    parameter EIGHT   = 7'b0000000;  // 8
    parameter NINE    = 7'b0010000;  // 9
    parameter A       = 7'b0001000;  // A
    parameter B       = 7'b0000011;  // B
    parameter C       = 7'b1000110;  // C
    parameter D       = 7'b0100001;  // D
    parameter E       = 7'b0000110;  // E
    parameter F       = 7'b0001110;  // F
    
    // Registers for multiplexing the display
    reg [1:0] digit_select;     // 2-bit counter for selecting each of 4 digits
    reg [16:0] digit_timer;     // Counter for digit refresh timing
    
    // Logic for controlling the refresh rate and cycling through digits
    always @(posedge clk) begin
        if(rst) begin
            digit_select <= 0;
            digit_timer <= 0; 
        end
        else begin                  
            // 1ms refresh time per digit
            if(digit_timer == 99_999) begin      // 100,000 cycles * 10ns (100MHz) = 1ms
                digit_timer <= 0;                
                digit_select <= digit_select + 1;
            end
            else begin
                digit_timer <= digit_timer + 1;
            end
        end
    end
    
    // Combinational logic for driving anodes and segments
    always @* begin
        case(digit_select) 
            // Select first digit
            2'b00 : begin
                an = 4'b1110; // Turn on AN0
                case(ones)
                    4'h0: seg = ZERO; 4'h1: seg = ONE; 4'h2: seg = TWO;   4'h3: seg = THREE;
                    4'h4: seg = FOUR; 4'h5: seg = FIVE; 4'h6: seg = SIX;   4'h7: seg = SEVEN;
                    4'h8: seg = EIGHT;4'h9: seg = NINE; 4'hA: seg = A;     4'hB: seg = B;
                    4'hC: seg = C;    4'hD: seg = D;    4'hE: seg = E;     4'hF: seg = F;
                    default: seg = 7'b1111111; // Blank
                endcase
            end
            // Select second digit
            2'b01 : begin
                an = 4'b1101; // Turn on AN1
                case(tens)
                    4'h0: seg = ZERO; 4'h1: seg = ONE; 4'h2: seg = TWO;   4'h3: seg = THREE;
                    4'h4: seg = FOUR; 4'h5: seg = FIVE; 4'h6: seg = SIX;   4'h7: seg = SEVEN;
                    4'h8: seg = EIGHT;4'h9: seg = NINE; 4'hA: seg = A;     4'hB: seg = B;
                    4'hC: seg = C;    4'hD: seg = D;    4'hE: seg = E;     4'hF: seg = F;
                    default: seg = 7'b1111111; // Blank
                endcase
            end
            // Select third digit
            2'b10 : begin
                an = 4'b1011; // Turn on AN2
                case(hundreds)
                    4'h0: seg = ZERO; 4'h1: seg = ONE; 4'h2: seg = TWO;   4'h3: seg = THREE;
                    4'h4: seg = FOUR; 4'h5: seg = FIVE; 4'h6: seg = SIX;   4'h7: seg = SEVEN;
                    4'h8: seg = EIGHT;4'h9: seg = NINE; 4'hA: seg = A;     4'hB: seg = B;
                    4'hC: seg = C;    4'hD: seg = D;    4'hE: seg = E;     4'hF: seg = F;
                    default: seg = 7'b1111111; // Blank
                endcase
            end
            // Select fourth digit
            2'b11 : begin
                an = 4'b0111; // Turn on AN3
                case(thousands)
                    4'h0: seg = ZERO; 4'h1: seg = ONE; 4'h2: seg = TWO;   4'h3: seg = THREE;
                    4'h4: seg = FOUR; 4'h5: seg = FIVE; 4'h6: seg = SIX;   4'h7: seg = SEVEN;
                    4'h8: seg = EIGHT;4'h9: seg = NINE; 4'hA: seg = A;     4'hB: seg = B;
                    4'hC: seg = C;    4'hD: seg = D;    4'hE: seg = E;     4'hF: seg = F;
                    default: seg = 7'b1111111; // Blank
                endcase
            end
            default: begin
                an = 4'b1111; // All anodes off
                seg = 7'b1111111; // Blank
            end
        endcase
    end

endmodule