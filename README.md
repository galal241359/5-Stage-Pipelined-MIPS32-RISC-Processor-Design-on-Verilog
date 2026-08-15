# Design of 5 Stage Pipelined MIPS32 RISC Processor

This repository contains the details and the code for the MIPS32 ISA based RISC Processor, implemented in a 5-stage pipelined configuration.

## Table of Contents

- [Overview](#overview)
- [Addressing Modes](#addressing-modes)
- [Instructions Considered](#instructions-considered)
- [Instruction Encoding](#instruction-encoding)
- [Stages of Execution](#stages-of-execution)
- [Datapath Diagrams](#datapath-diagrams)
- [Files Structure](#files-structure)
- [EDAPlayground Link](#edaplayground-link)
- [Known Issues & Hazards](#known-issues--hazards)
- [References](#references)

---

## Overview

- **Registers:** 32 x 32-bit General Purpose Registers (`R0` to `R31`), where `R0` is hardwired to logic `0`.
- **Program Counter (PC):** 32-bit PC.
- **Memory:** Word-addressable (1024 x 32 memory). Only `Load` and `Store` instructions can access memory.

---

## Addressing Modes

- Register Direct
- Immediate
- Base / Indexed (for Load and Store)
- PC-Relative (for Branch instructions)

---

## Instructions Considered

- **Load/Store:** `LW`, `SW`
- **R-type ALU:** `ADD`, `SUB`, `AND`, `OR`, `MUL`, `SLT`
- **I-type ALU:** `ADDI`, `SUBI`, `SLTI`
- **Branch/Jump:** `BEQZ`, `BNEQZ`, `J`
- **Misc:** `HLT`

---

## Instruction Encoding

| Instruction Type | Format / Encoding Reference |
| :--- | :--- |
| **R-type** | ![R-type](https://user-images.githubusercontent.com/23178093-8d26-11eb-98c5-925fb6de036a.png) |
| **I-type** | ![I-type](https://user-images.githubusercontent.com/23178093-8d26-11eb-98c5-925fb6de0377.png) |
| **J-type** | ![J-type](https://user-images.githubusercontent.com/23178093-8d26-11eb-98c5-925fb6de037d.png) |

---

## Stages of Execution

1. **IF:** Instruction Fetch
2. **ID:** Instruction Decode / Register Fetch
3. **EX:** Execution / Effective Address Calculation
4. **MEM:** Memory Access / Branch Completion
5. **WB:** Register Write-back

---

## Datapath Diagrams

### Non-Pipelined Datapath
![Non-Pipelined Datapath](https://user-images.githubusercontent.com/23178093-8d26-11eb-98c5-925fb6de0381.png)

### Pipelined Datapath
![Pipelined Datapath](https://user-images.githubusercontent.com/23178093-8d26-11eb-98c5-925fb6de0386.png)

---

## Files Structure

- [`rtl/mips32.v`](rtl/mips32.v) — Contains the main 5-stage pipelined MIPS32 processor module.
- [`testbench/test_mips32.v`](testbench/test_mips32.v) — Contains the testbench, stimulus program, memory initialization, and clock generation.

---

## EDAPlayground Link

You can run and simulate this design directly online via EDA Playground:  
👉 [EDAPlayground Simulation Link](https://play.edaplayground.com/x/t8Vx)

---

## Known Issues & Hazards

- Structural Hazards due to shared hardware resources.
- Data Hazards due to instruction data dependencies.
- Control hazards due to branch instructions.

---

## References

- [NPTEL & IIT KGP 'Hardware Modeling using Verilog' - Prof. Indranil Sengupta](https://onlinecourses.nptel.ac.in/noc21_cs03/preview


  module pipe_MIPS32 (clk1, clk2);
  input clk1, clk2; // Two-phase clock
  reg [31:0] PC, IF_ID_IR, IF_ID_NPC;
  reg [31:0] ID_EX_IR, ID_EX_NPC, ID_EX_A, ID_EX_B, ID_EX_Imm;
  reg [2:0] ID_EX_type, EX_MEM_type, MEM_WB_type;
  reg [31:0] EX_MEM_IR, EX_MEM_ALUOut, EX_MEM_B;
  reg EX_MEM_cond;
  reg [31:0] MEM_WB_IR, MEM_WB_ALUOut, MEM_WB_LMD;
  reg [31:0] Reg [0:31]; // Register bank (32 x 32)
  reg [31:0] Mem [0:1023]; // 1024 x 32 memory
  parameter ADD=6'b000000, SUB=6'b000001, AND=6'b000010, OR=6'b000011,
            SLT=6'b000100, MUL=6'b000101, HLT=6'b111111, LW=6'b001000,
            SW=6'b001001, ADDI=6'b001010, SUBI=6'b001011,SLTI=6'b001100,
            BNEQZ=6'b001101, BEQZ=6'b001110;
  parameter RR_ALU=3'b000, RM_ALU=3'b001, LOAD=3'b010, STORE=3'b011,
            BRANCH=3'b100, HALT=3'b101;
  reg HALTED;
  // Set after HLT instruction is completed (in WB stage)
  reg TAKEN_BRANCH;
  // Required to disable instructions after branch
  
  
  always @(posedge clk1) // IF Stage
    if (HALTED == 0)
    begin
      if (((EX_MEM_IR[31:26] == BEQZ) && (EX_MEM_cond == 1)) ||
          ((EX_MEM_IR[31:26] == BNEQZ) && (EX_MEM_cond == 0)))
      begin
        IF_ID_IR <= #2 Mem[EX_MEM_ALUOut];
        TAKEN_BRANCH <= #2 1'b1;
        IF_ID_NPC <= #2 EX_MEM_ALUOut + 1;
        PC <= #2 EX_MEM_ALUOut + 1;
      end
      else
      begin
        IF_ID_IR <= #2 Mem[PC];
        IF_ID_NPC <= #2 PC + 1;
        PC <= #2 PC + 1;
      end
    end
  
  always @(posedge clk2) // ID Stage
    if (HALTED == 0)
    begin
      if (IF_ID_IR[25:21] == 5'b00000)
        ID_EX_A <= 0;
      else
        ID_EX_A <= #2 Reg[IF_ID_IR[25:21]]; // "rs"
      if (IF_ID_IR[20:16] == 5'b00000)
        ID_EX_B <= 0;
      else
        ID_EX_B <= #2 Reg[IF_ID_IR[20:16]]; // "rt"
      ID_EX_NPC <= #2 IF_ID_NPC;
      ID_EX_IR <= #2 IF_ID_IR;
      ID_EX_Imm <= #2 {{16{IF_ID_IR[15]}}, {IF_ID_IR[15:0]}};
      case (IF_ID_IR[31:26])
        ADD,SUB,AND,OR,SLT,MUL:
          ID_EX_type <= #2 RR_ALU;
        ADDI,SUBI,SLTI:
          ID_EX_type <= #2 RM_ALU;
        LW:
          ID_EX_type <= #2 LOAD;
        SW:
          ID_EX_type <= #2 STORE;
        BNEQZ,BEQZ:
          ID_EX_type <= #2 BRANCH;
        HLT:
          ID_EX_type <= #2 HALT;
        default:
          ID_EX_type <= #2 HALT;
        // Invalid opcode
      endcase
    end
  
  always @(posedge clk1) // EX Stage
    if (HALTED == 0)
    begin
      EX_MEM_type <= #2 ID_EX_type;
      EX_MEM_IR <= #2 ID_EX_IR;
      TAKEN_BRANCH <= #2 0;
      case (ID_EX_type)
        RR_ALU:
        begin
          case (ID_EX_IR[31:26]) // "opcode"
            ADD:
              EX_MEM_ALUOut <= #2 ID_EX_A + ID_EX_B;
            SUB:
              EX_MEM_ALUOut <= #2 ID_EX_A - ID_EX_B;
            AND:
              EX_MEM_ALUOut <= #2 ID_EX_A & ID_EX_B;
            OR:
              EX_MEM_ALUOut <= #2 ID_EX_A | ID_EX_B;
            SLT:
              EX_MEM_ALUOut <= #2 ID_EX_A < ID_EX_B;
            MUL:
              EX_MEM_ALUOut <= #2 ID_EX_A * ID_EX_B;
            default:
              EX_MEM_ALUOut <= #2 32'hxxxxxxxx;
          endcase
        end
        RM_ALU:
        begin
          case (ID_EX_IR[31:26]) // "opcode"
            ADDI:
              EX_MEM_ALUOut <= #2 ID_EX_A + ID_EX_Imm;
            SUBI:
              EX_MEM_ALUOut <= #2 ID_EX_A - ID_EX_Imm;
            SLTI:
              EX_MEM_ALUOut <= #2 ID_EX_A < ID_EX_Imm;
            default:
              EX_MEM_ALUOut <= #2 32'hxxxxxxxx;
          endcase
        end
        LOAD, STORE:
        begin
          EX_MEM_ALUOut <= #2 ID_EX_A + ID_EX_Imm;
          EX_MEM_B <= #2 ID_EX_B;
        end
        BRANCH:
        begin
          EX_MEM_ALUOut <= #2 ID_EX_NPC + ID_EX_Imm;
          EX_MEM_cond <= #2 (ID_EX_A == 0);
        end
      endcase
    end
  
  
  always @(posedge clk2) // MEM Stage
    if (HALTED == 0)
    begin
      MEM_WB_type <= EX_MEM_type;
      MEM_WB_IR <= #2 EX_MEM_IR;
      case (EX_MEM_type)
        RR_ALU, RM_ALU:
          MEM_WB_ALUOut <= #2 EX_MEM_ALUOut;
        LOAD:
          MEM_WB_LMD <= #2 Mem[EX_MEM_ALUOut];
        STORE:
          if (TAKEN_BRANCH == 0) // Disable write
            Mem[EX_MEM_ALUOut] <= #2 EX_MEM_B;
      endcase
    end
  
  
  always @(posedge clk1) // WB Stage
  begin
    if (TAKEN_BRANCH == 0) // Disable write if branch taken
    case (MEM_WB_type)
      RR_ALU:
        Reg[MEM_WB_IR[15:11]] <= #2 MEM_WB_ALUOut; // "rd"
      RM_ALU:
        Reg[MEM_WB_IR[20:16]] <= #2 MEM_WB_ALUOut; // "rt"
      LOAD:
        Reg[MEM_WB_IR[20:16]] <= #2 MEM_WB_LMD; // "rt"
      HALT:
        HALTED <= #2 1'b1;
    endcase
  end
endmodule
