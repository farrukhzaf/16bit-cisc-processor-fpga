`timescale 1ns / 1ps

module processor(
    input clk,
    input reset,
    output [15:0] result
);

    // Internal wires - PC
    wire [4:0] pc_addr;
    wire PC_L, PC_I;
    
    // Internal wires - Memory
    wire [4:0] mem_addr;
    wire [15:0] mem_data_out;
    wire mem_write, mem_addr_sel;
    
    // Internal wires - Instruction
    wire [15:0] instruction;
    wire [4:0] opcode;
    wire [2:0] rd, rs1, rs2;
    wire [4:0] address;
    wire is_arithmetic, is_immediate, is_load, is_store, is_jump_unconditional, is_jump_conditional;
    wire IR_L;
    
    // Internal wires - Register File
    wire [2:0] rf_addr;
    wire [15:0] rf_data_out;
    wire R_L, R_E;
    
    // Internal wires - ALU
    wire [15:0] alu_result;
    wire [2:0] AL_S;
    wire alu_carry, alu_zero;
    
    // Internal wires - Temporary Registers
    wire [15:0] tr1_out, tr2_out;
    wire TR1_L, TR2_L;
    
    // Internal wires - Flags
    wire zero_flag, carry_flag;
    wire flag_load;
    
    // Internal wires - Data Bus
    wire [15:0] data_bus;
    wire [1:0] data_bus_sel;
    


    PC pc_inst (
        .clk(clk),
        .reset(reset),
        .data_in(address),       
        .PC_L(PC_L),
        .PC_I(PC_I),
        .A(pc_addr)
    );


    address_mux addr_mux (
        .pc_addr(pc_addr),
        .instr_addr(address),
        .mem_addr_sel(mem_addr_sel),
        .mem_addr(mem_addr)
    );


    memory mem_inst (
        .clk(clk),
        .addr(mem_addr),
        .data_in(data_bus),        // Data from data bus for writes
        .mem_write(mem_write),
        .data_out(mem_data_out)
    );


    IR ir_inst (
        .clk(clk),
        .reset(reset),
        .data_in(data_bus),        // Instruction from data bus
        .IR_L(IR_L),
        .data_out(instruction)
    );


    ID id_inst (
        .instruction(instruction),
        .opcode(opcode),
        .rd(rd),
        .rs1(rs1),
        .rs2(rs2),
        .address(address),
        .is_arithmetic(is_arithmetic),
        .is_immediate(is_immediate),
        .is_load(is_load),
        .is_store(is_store),
        .is_jump_unconditional(is_jump_unconditional),
        .is_jump_conditional(is_jump_conditional)
    );


    register_file rf_inst (
        .clk(clk),
        .reset(reset),
        .rf_addr(rf_addr),
        .R_L(R_L),
        .R_E(R_E),
        .data_in(data_bus),        
        .data_out(rf_data_out),
        .result(result)
    );


    TR1 tr1_inst (
        .clk(clk),
        .reset(reset),
        .data_in(data_bus),        // Data from data bus
        .TR1_L(TR1_L),
        .data_out(tr1_out)
    );


    TR2 tr2_inst (
        .clk(clk),
        .reset(reset),
        .data_in(data_bus),        // Data from data bus
        .TR2_L(TR2_L),
        .data_out(tr2_out)
    );


    ALU alu_inst (
        .A(tr1_out),    
        .B(tr2_out),             
        .AL_S(AL_S),
        .C_in(carry_flag),    
        .R(alu_result),
        .C(alu_carry),        
        .Z(alu_zero)             
    );


    flag_register flag_inst (
        .clk(clk),
        .reset(reset),
        .flag_load(flag_load),
        .carry_in(alu_carry),
        .zero_in(alu_zero),
        .carry_flag(carry_flag),
        .zero_flag(zero_flag)
    );


    data_bus_mux data_mux (
        .alu_data(alu_result),
        .memory_data(mem_data_out),
        .rf_data(rf_data_out),
        .data_bus_sel(data_bus_sel),
        .data_bus(data_bus)
    );

  
    controller ctrl_inst (
        .clk(clk),
        .reset(reset),
        .opcode(opcode),
        .rd(rd),
        .rs1(rs1),
        .rs2(rs2),
        .is_arithmetic(is_arithmetic),
        .is_immediate(is_immediate),
        .is_load(is_load),
        .is_store(is_store),
        .is_jump_unconditional(is_jump_unconditional),
        .is_jump_conditional(is_jump_conditional),
        .zero_flag(zero_flag),
        .carry_flag(carry_flag),
        .mem_write(mem_write),
        .mem_addr_sel(mem_addr_sel),
        .PC_L(PC_L),
        .PC_I(PC_I),
        .IR_L(IR_L),
        .rf_addr(rf_addr),
        .R_L(R_L),
        .R_E(R_E),
        .AL_S(AL_S),
        .TR1_L(TR1_L),
        .TR2_L(TR2_L),
        .flag_load(flag_load),
        .data_bus_sel(data_bus_sel)
    );

endmodule
