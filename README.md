# 32-bit-MIPS-PIPELINE-VHDL

# Overview

This project implements a 32-bit pipelined MIPS processor in VHDL. It supports a subset of the MIPS instruction set and improves performance by utilizing a five-stage pipeline.

# Features 

Five-stage pipelined architecture. <br/> 

Implements key MIPS instructions (R-type, I-type, and basic J-type). <br/>  

32-bit data path. <br/>  

Hazard detection. <br/>  

Separate instruction and data memories. <br/>  

Support for ALU operations, memory access, and branching. <br/>  

# Supported Instructions 

R-Type, I-Type, J-type.  

# Pipeline Stages 

Instruction Fetch (IF): Fetches the instruction from memory. <br/>   

Instruction Decode (ID): Decodes the instruction and reads registers. <br/>   

Execution (EX): Performs ALU operations. <br/>   

Memory Access (MEM): Handles memory reads/writes. <br/>   

Write-back (WB): Writes results back to registers. <br/>   

# Architecture 

Program Counter (PC): Holds the address of the next instruction. <br/>  

Instruction Memory: Stores program instructions. <br/>  

Register File: Contains 32 registers for computation. <br/>  

ALU (Arithmetic Logic Unit): Performs arithmetic and logical operations. <br/> 

Data Memory: Handles memory load (lw) and store (sw) operations. <br/> 

Control Unit: Decodes instructions and generates control signals. <br/>  

Pipeline Registers: Hold intermediate values between stages. <br/> 

# Can be tested on any supported FPGA board. 
