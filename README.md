# PipelinedOtter
Source Files and Design Choices for Pipelined Version of the CPE 233 RISC-V OTTER

# Stages
1. Fetch
2. Decode
3. Execute
4. Memory
5. Writeback

# Pipeline Registers
1. FD (Fetch/Decode) 
2. DE (Decode/Execute) 
3. EM (Execute/Memory) 
4. MW (Memory/Writeback)

<p>We need the pipeline registers to connect to one another, with some signals getting "eaten up" in each stage</p>
<p>In <b>Fetch</b>, all we need to pass to FD is IR, nextPC, and PC</p>
<p>In <b>Decode</b>, all we need to pass to DE is the control unit signals, the alu signals, and some reg and mem file control</p>
<p>In <b>Execute</b>, all we need to pass to EM is the alu_result, and some reg control, and the mem control</p>
<p>In <b>Memory</b>, all we need to pass to MW is the reg mux data and control and writeback data</p>

