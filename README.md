# Design of 5 Stage Pipelined MIPS32 RISC Processor

This repository contains the details and the code for the MIPS32 ISA based RISC Processor, which is implemented in 5 stage pipelined configuration.

## Table of contents
- [MIPS32](#mips32)
- [Addressing Modes](#addressing-modes)
- [Instructions Considered](#instructions-considered)
- [Instruction Encoding](#instruction-encoding)
- [Stages of Execution](#stages-of-execution)
- [Verilog Design Code](#verilog-design-code)
- [Example Program Testbench Code](#example-program-testbench-code)
- [Known issues and problems](#known-issues-and-problems)
- [References](#references)

---

## MIPS32
- 32 x 32 bit GPRs (R0 to R31)
- R0 hardwired to logic0
- 32 bit Program Counter (PC)
- No flag registers

---

## Addressing Modes

| Addressing Mode | Example Instruction |
| :--- | :--- |
| Register addressing | ADD R1,R2,R3 |
| Immediate addressing | ADDI R1,R2, 200 |
| Base addressing | LW R5, 150(R7) |

---

## Stages of Execution
The instruction execution cycle contains the 5 stages in order:
1. **IF**: Instruction Fetch
2. **ID**: Instruction Decode / Register Fetch
3. **EX**: Execution / Effective Address Calculation
4. **MEM**: Memory Access / Branch Completion
5. **WB**: Register Write-back

---

## Verilog Design Code
```verilog
// ضع كود الـ Verilog هنا
module pipe_mips32 (input clk1, clk2);
    // ...
endmodule
