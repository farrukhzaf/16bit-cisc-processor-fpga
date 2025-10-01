# 16-bit Multicycle CISC Processor

A complete 16-bit CISC processor implementation on Basys3 FPGA (Xilinx Artix-7 XC7A35T) with comprehensive instruction support and hardware multiplication demonstration.

## Overview

This project implements a fully functional 16-bit multicycle CISC processor featuring an 8-register file, unified memory architecture, and complete instruction set support including arithmetic, memory access, shift/rotate, and conditional branching operations.

**Key Features:**
- 16-bit datapath with shared bus architecture
- 8 × 16-bit general-purpose register file
- 32 × 16-bit unified instruction/data memory
- FSM-based multicycle control unit
- Comprehensive instruction set (13 instructions)
- Hardware tested on Basys3 FPGA
- 7-segment display output interface

## Architecture

### Processor Block Diagram

![Processor Block Diagram](docs/CPU_diagram.svg)

The processor features a shared 16-bit data bus connecting all major components with multiplexer-based arbitration.

### Controller FSM

![Controller FSM Diagram](docs/Controller_FSM_diagram.png)

The FSM-based controller implements 10 states to manage instruction execution phases.
```

### Major Components
- **Program Counter (PC)**: 5-bit counter for instruction addressing
- **Instruction Register (IR)**: Stores current instruction
- **Register File**: 8 × 16-bit registers (RA-RH)
- **ALU**: Supports ADD, SUB, INCR, DECR, SHL, RRC operations
- **Memory**: 32 × 16-bit distributed RAM
- **Controller**: FSM with 10 states for instruction execution
- **Temporary Registers**: TR1, TR2 for intermediate storage

## Instruction Set Architecture

### Instruction Formats

| Type | Opcode (5) | Rd (3) | Rs1 (3) | Rs2/Addr (5) |
|------|------------|--------|---------|--------------|
| Arithmetic | opcode | Rd | Rs1 | Rs2 + xx |
| Immediate | opcode | Rd | xxx | xxxxx |
| Memory | opcode | Rd/Rs | xxx | Address |
| Branch | opcode | xxx | xxx | Address |

### Supported Instructions

| Mnemonic | Opcode | Description |
|----------|--------|-------------|
| LOAD | 00000 | Load from memory to register |
| STORE | 00100 | Store register to memory |
| ADD | 01000 | Add two registers |
| SUB | 01001 | Subtract two registers |
| INCR | 01100 | Increment register |
| DECR | 01101 | Decrement register |
| SHL | 01110 | Shift left |
| RRC | 01111 | Rotate right with carry |
| JMP | 10000 | Unconditional jump |
| JZ | 10101 | Jump if zero |
| JNZ | 10110 | Jump if not zero |
| JC | 10111 | Jump if carry |
| JNC | 10100 | Jump if no carry |

## Getting Started

### Prerequisites
- Xilinx Vivado (2018.3 or later)
- Basys3 FPGA board
- Basic knowledge of Verilog and FPGA development

### Project Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/cisc-processor-basys3.git
   cd cisc-processor-basys3
   ```

2. **Open in Vivado**
   - Create new project targeting Basys3 (xc7a35tcpg236-1)
   - Add all files from `rtl/` as design sources
   - Add files from `tb/` as simulation sources
   - Add `constraints/constraints.xdc` as constraints
   - Add `programs/program.coe` to the project

3. **Configure Distributed Memory**
   - Add IP: Distributed Memory Generator
   - Configuration:
     - Depth: 32
     - Width: 16
     - Memory Type: Single Port RAM
     - Load Init File: `program.coe`
     - Instance name: `dist_mem_gen_0`

4. **Synthesize and Implement**
   ```tcl
   launch_runs synth_1
   wait_on_run synth_1
   launch_runs impl_1 -to_step write_bitstream
   wait_on_run impl_1
   ```

5. **Program the FPGA**
   - Connect Basys3 board
   - Program device with generated bitstream
   - Press center button (btnC) to reset
   - View result on 7-segment display

## Demonstration Program

The included program implements 8-bit unsigned multiplication using shift-and-add algorithm:

**Example: 255 × 245 = 62,475 (0xF40B)**

### Algorithm
1. Load multiplicand (255) and multiplier (245)
2. Initialize accumulator to 0
3. For each bit in multiplier:
   - Check LSB via rotate right
   - If LSB = 1, add multiplicand to accumulator
   - Shift multiplicand left (multiply by 2)
   - Decrement counter and repeat
4. Store final result

### Memory Map
- Address 0x00-0x0B: Program instructions
- Address 0x1C (28): Multiplicand (0x00FF)
- Address 0x1D (29): Multiplier (0x00F5)
- Address 0x1E (30): Loop counter (0x0008)
- Address 0x1F (31): Result storage

## Simulation

### Run Behavioral Simulation
```tcl
launch_simulation
run 2000 ns
```

### Expected Results
- Computation completes in ~1,847 ns (after reset)
- Final result: 0xF40B (62,475 decimal)
- Display shows F40B on 7-segment display

## Performance Metrics

| Metric | Value |
|--------|-------|
| **Maximum Frequency** | 138 MHz |
| **LUT Utilization** | 271 (1.30%) |
| **FF Utilization** | 206 (0.50%) |
| **LUTRAM** | 16 (0.17%) |
| **IO** | 13 (12.26%) |
| **Setup Slack (WNS)** | 2.751 ns |
| **Hold Slack (WHS)** | 0.201 ns |
| **Total Power** | 0.077 W |
| **Dynamic Power** | 0.006 W |
| **Static Power** | 0.072 W |

## File Structure

```
cisc-processor-basys3/
├── rtl/                    # RTL design files
│   ├── processor.v         # Top-level processor module
│   ├── controller.v        # FSM controller
│   ├── ALU.v              # Arithmetic Logic Unit
│   ├── register_file.v    # 8-register file
│   └── ...                # Other components
├── tb/                    # Testbenches
├── constraints/           # FPGA constraints
├── programs/              # Assembly programs (COE format)
├── fpga/                  # FPGA-specific modules
└── docs/                  # Documentation and images
```

## Controller FSM States

1. **FETCH (0000)**: Fetch instruction from memory
2. **DECODE (0001)**: Decode instruction and determine path
3. **ARITH_READ1 (0010)**: Read first operand for arithmetic
4. **ARITH_READ2 (0011)**: Read second operand
5. **ARITH_EXEC (0100)**: Execute arithmetic and write result
6. **IMM_READ (0101)**: Read register for immediate operations
7. **IMM_EXEC (0110)**: Execute immediate operation
8. **LOAD_WRITE (0111)**: Complete memory load
9. **STORE_EXEC (1000)**: Execute memory store
10. **JUMP_EXEC (1001)**: Handle jump operations

## Writing Custom Programs

### Assembly Format
```assembly
LOAD  RA, [addr]    // Load from memory
ADD   RD, RA, RB    // Add registers
STORE RD, [addr]    // Store to memory
JZ    label         // Conditional jump
```

### Creating COE Files
```
memory_initialization_radix=16;
memory_initialization_vector=
001C,  // Instruction 1
011D,  // Instruction 2
...
```

### Instruction Encoding Tool
Use the Python script in `tools/assembler.py` (if available) or encode manually using the ISA specification.

## Hardware Testing

1. Program the Basys3 FPGA
2. Press center button (btnC) to reset
3. Observe 7-segment display showing result
4. For the multiplication demo: display shows `F40B` (hex)

## Known Limitations

- Memory has asynchronous read (combinational output)
- Almost-full/empty flag calculations add combinational delay
- No overflow/underflow error detection
- Limited to 32 memory locations (5-bit addressing)

## Future Enhancements

- [ ] Expand memory to 64 or 128 locations
- [ ] Add overflow/underflow detection
- [ ] Implement data counter for occupancy monitoring
- [ ] Add UART interface for I/O
- [ ] Implement interrupt support
- [ ] Add more ALU operations (AND, OR, XOR)
- [ ] Pipeline the datapath for higher throughput

## Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues for bugs and feature requests.

### Development Guidelines
- Follow existing code style
- Add testbenches for new features
- Update documentation
- Test on hardware before submitting

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Developed as part of Processor System Design course (AUG-DEC 2025)
- Department of Electronic Systems Engineering, IISc Bangalore

## References

- Basys3 FPGA Reference Manual
- Xilinx Vivado Design Suite User Guide

## Contact

For questions or feedback, please open an issue on GitHub or contact through the repository.

---

**Note**: This processor is designed for educational purposes and demonstrates fundamental concepts in computer architecture and digital design.
