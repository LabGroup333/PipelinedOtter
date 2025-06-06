`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/29/2025 04:52:21 PM
// Design Name: 
// Module Name: OTTER_MCU
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module OTTER_MCU(
    input CLK,
    input RST
    );
    logic [31:0] pc, nextPC; // wire from PC to Memory for instruction grabbing
    logic [31:0] ir;
    logic [31:0] alu_srcA_D1;
    logic [31:0] alu_srcB_D1, alu_srcB_D2;
    logic alu_srcA_sel;
    logic [1:0] alu_srcB_sel;
    logic [31:0] rs1_wire, rs2_wire;
    logic zero_E;
    logic [31:0] alu_result_wire;
    logic [31:0] data;
    logic [31:0] wdata;
    logic reg_write, mem_write, mem_rd2;

    
    
    typedef struct packed {
        logic [31:0] IR;
        logic [31:0] nextPC, PC;
        logic RegWrite, MemWrite, MemRead2;
        logic Jump, Branch;
        logic [1:0] RF_Sel, ImmSrc;
        logic [3:0] ALUControl;
        logic [31:0]SrcA_Out, SrcB_Out;
        logic [31:0] R1Data, R2Data;
        logic [4:0] RdD;
        logic [31:0] MemData;
        logic [31:0] ALUResult;    
    } pipeline_reg_t;
    
    pipeline_reg_t FD, DE, EM, MW;
    
    
    REG_FILE OTTER_REG_FILE(
        .CLK(CLK),
        .EN(EM.RegWrite),
        .ADR1(FD.IR[19:15]),
        .ADR2(FD.IR[24:20]),
        .WA(EM.RdD),    //micah-changed from EM to MW
        .WD(wdata),
        .RS1(rs1_wire),
        .RS2(rs2_wire)
    ); 
    
    OTTER_mem_dualport OTTER_MEM(
        .MEM_ADDR1(pc),     //Instruction Memory Port
        .MEM_ADDR2(EM.ALUResult),     //Data Memory Port
        .MEM_CLK(CLK),
        .MEM_DIN2(EM.R2Data),
        .MEM_WRITE2(EM.MemWrite),
        .MEM_READ1(1'b1),
        .MEM_READ2(EM.MemRead2),
        //input [1:0] MEM_BYTE_EN1;
        //input [1:0] MEM_BYTE_EN2;
        .IO_IN(32'b0),
        .ERR(),
        //.MEM_SIZE(),
        //.MEM_SIGN(),
        .MEM_DOUT1(ir),
        .MEM_DOUT2(data),
        .IO_WR()
    );
    

////////////////////////////////////////////////////////////////
// FETCH Stage Hardware
    PC OTTER_PC(
        .CLK(CLK),
        .RST(RST),
        .PC_WRITE(1'b1), // Should always be on
        .PC_SOURCE(3'd0),    // PC MUX SEL
        .JALR(32'd0),       
        .JAL(32'd0),
        .BRANCH(32'd0),
        .MTVEC(32'd0),        // I.S.R. address
        .MEPC(32'd0),         // I.S.R. return address
        .PC_OUT(pc),
        .PC_OUT_INC(nextPC)
     );
    
////////////////////////////////////////////////////////////////////
// Decode Stage Hardware
   IG IMMED_GEN(
        .IR(FD.IR[31:7]),
        .U_TYPE(alu_srcA_D1),
        .I_TYPE(alu_srcB_D1),
        .S_TYPE(alu_srcB_D2),
        .B_TYPE(),
        .J_TYPE()
    ); 
    
   CTRL_UNIT OTTER_CU(
        // INPUTS
        .OPCODE(FD.IR[6:0]),
        .FUNC3(FD.IR[14:12]),
        .FUNC7(FD.IR[30]),
        
        // OUTPUTS
        .REG_WRITE(reg_write),
        .MEM_WRITE(mem_write),
        .MEM_READ2(mem_rd2),
        //.JUMP(jump_D),
        //.BRANCH(branch_D),
        .RF_SEL(DE.RF_Sel),
        .ALU_FUN(DE.ALUControl),
        .ALU_SRCA(alu_srcA_sel),
        .ALU_SRCB(alu_srcB_sel)
   ); 
    
       // 2T1 MUX
    TwoMux ALU_Src_A(
        .SEL(alu_srcA_sel),
        .ZERO(DE.R1Data),
        .ONE(alu_srcA_D1),
        .OUT(DE.SrcA_Out)
    ); 


    // 4T1 MUX
    FourMux ALU_Src_B(
        .SEL(alu_srcB_sel),
        .ZERO(DE.R2Data),
        .ONE(alu_srcB_D1),
        .TWO(alu_srcB_D2),
        .THREE(FD.PC),
        .OUT(DE.SrcB_Out)
    ); 
    
//////////////////////////////////////////////////////////////////
// Execute Stage Hardware

 
    
    ALU OTTER_ALU(
    .SRC_A(DE.SrcA_Out),
    .SRC_B(DE.SrcB_Out),
    .ALU_CTRL(DE.ALUControl),
    .RESULT(alu_result_wire),
    .ZERO(zero_E)
    );
    // BCG 
    
    // BAG 
//////////////////////////////////////////////////////////////////
// EX/MEM Pipeline Registers
  /*  logic RegWrite_EM, MemWrite_EM;
    logic [1:0] ResultSrc_EM;
    logic [31:0] WData_EM;
    logic [31:0] ALUResult_EM;
    logic zero_EM;
    logic [4:0] RdD_EM;
    logic [31:0] nextPC_EM; */
//////////////////////////////////////////////////////////////////



//////////////////////////////////////////////////////////////////
// Memory Stage 

    
////////////////////////////////////////////////////////////////////
// MEM/WB Pipeline Register
  /*  logic RegWrite_MW;
    logic [1:0] ResultSrc_MW;
    logic [31:0] ALUResult_MW;
    logic [4:0] RdD_MW;
    logic [31:0] Reg_Data_MW;
    logic [31:0] nextPC_MW; */
    
////////////////////////////////////////////////////////////////////



/////////////////////////////////////////////////////////////////
// Writeback Stage

    FourMux REG_FILE_MUX(
        .SEL(MW.RF_Sel),
        .ZERO(MW.nextPC),
        .ONE(32'd0),
        .TWO(MW.MemData),
        .THREE(MW.ALUResult),
        .OUT(wdata)
    ); 
// Reg F
   
   
///////////////////////////////////////////////////////////////////
// Engine 
always_ff @(posedge CLK or posedge RST) begin
    if (RST) begin
        FD.IR <= 32'b0;
        FD.PC <= 32'b0;
        FD.nextPC <= 32'b0;
    end else begin
        FD.IR <= ir;
        FD.PC <= pc;
        FD.nextPC <= nextPC;
    end
end
// Update IF/ID Pipeline Reg
always_ff@(negedge CLK) begin
    if(RST) begin
        DE.PC <= 'b0;
        DE.nextPC <= 'b0;
        DE.IR <= 'b0;
        DE.R1Data <= 'b0;
        DE.R2Data <= 'b0;
        DE.RdD <= 'b0;
    end
    else begin
        DE.PC <= FD.PC;
        DE.nextPC <= FD.nextPC;
        DE.IR <= FD.IR;
        DE.R1Data <= rs1_wire;
        DE.R2Data <= rs2_wire;
        DE.RdD <= FD.IR[11:7];
        DE.MemRead2 <= mem_rd2;
        DE.MemWrite <= mem_write;
        DE.RegWrite <= reg_write;
    end
end


always_ff@(posedge CLK) begin
    if(RST) begin
        EM.RegWrite <= 'b0;
        EM.MemWrite <= 'b0;
        EM.MemRead2 <= 'b0;
        //DE.Jump <= 'b0;
        //DE.Branch <= 'b0;
        EM.RF_Sel <= 'b0;
        EM.ALUControl <= 'b0;
        EM.R1Data <= 'b0;
        EM.R2Data <= 'b0;
        EM.PC <= 'b0;
        EM.nextPC <= 'b0;
        EM.RdD <= 'b0;
        EM.SrcA_Out <= 'b0;
        EM.SrcB_Out <= 'b0;
        EM.ALUResult <= 'b0;
    end
    else begin
        EM.RegWrite <= DE.RegWrite;
        EM.MemWrite <= DE.MemWrite;
        EM.MemRead2 <= DE.MemRead2;
        //DE.Jump <= jump_D;
        //DE.Branch <=
        EM.RF_Sel <= DE.RF_Sel;
        EM.ALUControl <= DE.ALUControl;
        EM.R1Data <= DE.R1Data;
        EM.R2Data <= DE.R2Data;
        EM.PC <= DE.PC;
        EM.nextPC <= DE.nextPC;
        EM.RdD <= DE.RdD;
        EM.SrcA_Out <= DE.SrcA_Out;
        EM.SrcB_Out <= DE.SrcB_Out;
        EM.ALUResult <= alu_result_wire;
    end
end 


// Update ME/WB Pipeline Reg
always_ff@(negedge CLK) begin
    if(RST) begin
        MW.RegWrite <= 'b0;
        MW.RF_Sel <= 'b0;
        MW.ALUResult <= 'b0;
        MW.RdD <= 'b0;
        MW.nextPC <= 'b0;
    end
    else begin
        MW.RegWrite <= EM.RegWrite;
        MW.RF_Sel <= EM.RF_Sel;
        MW.ALUResult <= EM.ALUResult;
        MW.RdD <= EM.RdD;
        MW.nextPC <= EM.nextPC;
        MW.MemData <= data;
    end
end 


// struct is just a type, use it where you want
// its an interface

endmodule
