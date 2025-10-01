`timescale 1ns / 1ps

module controller(
    input clk,
    input reset,
    
    // From instruction decoder
    input [4:0] opcode,
    input [2:0] rd,
    input [2:0] rs1,
    input [2:0] rs2,
    input is_arithmetic,
    input is_immediate,
    input is_load,
    input is_store,
    input is_jump_unconditional,
    input is_jump_conditional,
    
    // Flag inputs
    input zero_flag,
    input carry_flag,
    
    // Memory control signals
    output reg mem_write,
    output reg mem_addr_sel,    // 0=PC, 1=instruction address field
    
    // PC control signals
    output reg PC_L,    // Load PC
    output reg PC_I,    // Increment PC
    
    // IR control
    output reg IR_L,    // Load instruction register
    
    // Register file control
    output reg [2:0] rf_addr,   // Register address
    output reg R_L,             // Register load
    output reg R_E,             // Register enable
    
    // ALU control
    output reg [2:0] AL_S,
    
    // Temporary register control
    output reg TR1_L,
    output reg TR2_L,
    
    // Flag control
    output reg flag_load,
    
    // Data bus control
    output reg [1:0] data_bus_sel   // 00=ALU, 01=Memory, 10=Register File
);

    // State definitions
    localparam FETCH        = 4'b0000,
               DECODE       = 4'b0001,
               ARITH_READ1  = 4'b0010,  // Read rs1 → TR1
               ARITH_READ2  = 4'b0011,  // Read rs2 → TR2
               ARITH_EXEC   = 4'b0100,  // Execute and write result
               IMM_READ     = 4'b0101,  // Read rd → TR1
               IMM_EXEC     = 4'b0110,  // Execute and write result
               LOAD_WRITE   = 4'b0111,  // Write to register
               STORE_EXEC   = 4'b1000,  // Execute store operation
               JUMP_EXEC    = 4'b1001;  // Execute jump

    reg [3:0] state, next_state;

    // State register
    always @(posedge clk) begin
        if (reset)
            state <= FETCH;
        else
            state <= next_state;
    end

    // Next state logic
    always @(*) begin
        case (state)
            FETCH: 
                next_state = DECODE;
                
            DECODE: begin
                if (is_arithmetic)
                    next_state = ARITH_READ1;
                else if (is_immediate)
                    next_state = IMM_READ;
                else if (is_load)
                    next_state = LOAD_WRITE;
                else if (is_store)
                    next_state = STORE_EXEC;
                else if (is_jump_unconditional || is_jump_conditional)
                    next_state = JUMP_EXEC;
                else
                    next_state = FETCH; // Default/error case
            end
            
            ARITH_READ1:
                next_state = ARITH_READ2;
                
            ARITH_READ2:
                next_state = ARITH_EXEC;
                
            ARITH_EXEC:
                next_state = FETCH;
                
            IMM_READ:
                next_state = IMM_EXEC;
                
            IMM_EXEC:
                next_state = FETCH;
                
                
            LOAD_WRITE:
                next_state = FETCH;
                
            STORE_EXEC:
                next_state = FETCH;
                
            JUMP_EXEC:
                next_state = FETCH;
                
            default:
                next_state = FETCH;
        endcase
    end

    // Control signal generation
    always @(*) begin
        // Default values for all control signals
        mem_write = 0;
        mem_addr_sel = 0;    // Default to PC addressing
        PC_L = 0;
        PC_I = 0;
        IR_L = 0;
        rf_addr = 3'b000;
        R_L = 0;
        R_E = 0;
        AL_S = 3'b000;
        TR1_L = 0;
        TR2_L = 0;
        flag_load = 0;
        data_bus_sel = 2'b00; // Default to ALU

        case (state)
            FETCH: begin
                // Read instruction from memory at PC address
                mem_addr_sel = 0;      // Use PC as address
                IR_L = 1;              // Load instruction into IR
                PC_I = 1;              // Increment PC for next instruction
                data_bus_sel = 2'b01;  // Memory drives data bus (for IR)
            end

            DECODE: begin
                // No operations needed, just transition to appropriate execute state
            end

            ARITH_READ1: begin // Read rs1 for arithmetic operations
                rf_addr = rs1;
                R_E = 1;
                TR1_L = 1;
                data_bus_sel = 2'b10;  // Register file drives data bus
            end
            
            ARITH_READ2: begin // Read rs2 for arithmetic operations
                rf_addr = rs2;
                R_E = 1;
                TR2_L = 1;
                data_bus_sel = 2'b10;  // Register file drives data bus
            end

            ARITH_EXEC: begin // Execute arithmetic and write result
                // Configure ALU
                if (opcode == 5'b01000)      // ADD
                    AL_S = 3'b000;
                else if (opcode == 5'b01001) // SUB
                    AL_S = 3'b001;
                    
                // Write result to destination register
                rf_addr = rd;
                R_L = 1;               // Load result into register
                flag_load = 1;         // Update flags
                data_bus_sel = 2'b00;  // ALU drives data bus
            end

            IMM_READ: begin // Read register for immediate operations
                rf_addr = rd;
                R_E = 1;
                TR1_L = 1;
                data_bus_sel = 2'b10;  // Register file drives data bus
            end

            IMM_EXEC: begin // Execute immediate operation and write result
                // Configure ALU based on operation
                case (opcode)
                    5'b01100: AL_S = 3'b010; // INCR
                    5'b01101: AL_S = 3'b011; // DECR  
                    5'b01110: AL_S = 3'b100; // SHL
                    5'b01111: AL_S = 3'b101; // RRC
                    default:  AL_S = 3'b010; // Default to INCR operation
                endcase
                
                // Write result back to same register
                rf_addr = rd;
                R_L = 1;               // Load result into register
                flag_load = 1;         // Update flags
                data_bus_sel = 2'b00;  // ALU drives data bus
            end


            LOAD_WRITE: begin // Write memory data to register
                mem_addr_sel = 1;      // Use instruction address field
                
                rf_addr = rd;
                R_L = 1;               // Load data into register
                data_bus_sel = 2'b01;  // Memory drives data bus
            end

            STORE_EXEC: begin // Execute store operation
                // Put store address on address bus
                mem_write = 1;          // Write to memory
                mem_addr_sel = 1;      // Use instruction address field
                // Put register data on data bus  
                rf_addr = rs2;         // Source register for store
                R_E = 1;               // Enable register read
                data_bus_sel = 2'b10;  // Register file drives data bus
            end

            JUMP_EXEC: begin // Handle jump operations
                if (is_jump_unconditional) begin
                    // Unconditional jump
                    PC_L = 1;
                end
                else if (is_jump_conditional) begin
                    // Conditional jumps
                    case (opcode)
                        5'b10101: begin // JZ - jump if zero
                            if (zero_flag) begin
                                PC_L = 1;
                            end
                        end
                        5'b10110: begin // JNZ - jump if not zero  
                            if (~zero_flag) begin
                                PC_L = 1;
                            end
                        end
                        5'b10111: begin // JC - jump if carry
                            if (carry_flag) begin
                                PC_L = 1;
                            end
                        end
                        5'b10100: begin // JNC - jump if no carry
                            if (~carry_flag) begin
                                PC_L = 1;
                            end
                        end
                        default: begin
                            // Unknown conditional jump opcode - do not jump
                            PC_L = 1'b0;
                        end
                    endcase
                end
            end

            default: begin
                // Default state - do nothing
            end
        endcase
    end

endmodule