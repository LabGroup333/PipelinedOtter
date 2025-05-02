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
2. DE (Decode/Execute) $CTRL_UNIT Signals, ALU_SrcA and B, RdD$
3. EM (Execute/Memory) $CTRL_UNIT Signals, minus the ALU ones$
4. MW (Memory/Writeback) $REG_FILE Signals  MUX Control$


