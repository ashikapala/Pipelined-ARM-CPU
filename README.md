# Pipelined-ARM-CPU
64-bit, 5-stage pipelined CPU implementing a subset of the ARMv8 (LEGv8) instruction set in SystemVerilog. Includes hazard handling, ALU, and dual-read register file.

# 5-Stage Pipelined ARM CPU (LEGv8 Subset)

This project implements a 64-bit, 5-stage pipelined CPU in **SystemVerilog**, based on a subset of the ARMv8 (LEGv8) instruction set.  
The pipeline includes the following stages:
- Instruction Fetch (IF)
- Instruction Decode (ID)
- Execute (EX)
- Memory (MEM)
- Write-Back (WB)

## Features
- Dual-read, single-write register file
- ALU supporting arithmetic and logic operations
- Data forwarding units to resolve hazards
- Verified using asserts/Simulation in ModelSim

## Tools
- **Language**: SystemVerilog  
- **Simulation**: ModelSim  
