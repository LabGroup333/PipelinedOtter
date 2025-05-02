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
<p>In <b>Fetch</b>, all we need to pass to <b>FD</b> is IR, nextPC, and PC</p>
<p>In <b>Decode</b>, all we need to pass to <b>DE</b> is the control unit signals, the alu signals, and some reg and mem file control</p>
<p>In <b>Execute</b>, all we need to pass to <b>EM</b> is the alu_result, and some reg control, and the mem control</p>
<p>In <b>Memory</b>, all we need to pass to <b>MW</b> is the reg mux data and control and writeback data</p>

# Steps for Success
1. Fetch Hardware - capture those values in FD
2. Decode Hardware - capture values in DE
3. Execute Hardware - capture values in EM
4. Memory Hardware - capture values in MW
5. Writeback Hardware - pass values to decode stage


