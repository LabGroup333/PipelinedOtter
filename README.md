# PipelinedOtter
Source Files and Design Choices for Pipelined Version of the CPE 233 RISC-V OTTER

# Stages
1. Fetch
2. Decode
3. Execute
4. Memory
5. Writeback

# Pipeline Registers
1. FD (Fetch/Decode) $IR, PC, NextPC$ 
2. DE (Decode/Execute) $CTRL UNIT Signals, ALU SrcA and B, RdD$
3. EM (Execute/Memory) $CTRL UNIT Signals, minus the ALU ones$
4. MW (Memory/Writeback) $REG FILE Signals  MUX Control$


