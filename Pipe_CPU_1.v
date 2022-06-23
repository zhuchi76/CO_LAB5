//0819823
//Subject:     CO project 4 - Pipe CPU 1
//--------------------------------------------------------------------------------
//Version:     1
//--------------------------------------------------------------------------------
//Writer:      Perry
//----------------------------------------------
//Date:        2019/6/24
//----------------------------------------------
//Description: 
//--------------------------------------------------------------------------------
module Pipe_CPU_1(
    clk_i,
    rst_i
    );
    
/****************************************
I/O ports
****************************************/
input clk_i;
input rst_i;

/****************************************
Internal signal
****************************************/
/**** IF stage ****/
wire	[31:0]	pc_in_IF, pc_out_IF, pc_next_IF, instr_IF;

/**** ID stage ****/
wire	[31:0]	pc_next_ID, instr_ID, extend_ID, RSdata_ID, RDdata_ID;
//control signal
wire[2:0]	ALU_op_ID;
wire        Branch_ID, MemToReg_ID, MemRead_ID, MemWrite_ID, ALUSrc_ID, RegWrite_ID, RegDst_ID; 

/**** EX stage ****/
wire	[31:0]	result_EX, RSdata_EX, RTdata_EX, pc_next_EX, extend_EX, shifted_EX, ALUSource1_EX, ALUSource2_EX, pc_branch_EX;
wire	[4:0]	Src_EX, Dst0_EX, Dst1_EX, RDaddr_EX;

//control signal
wire	[3:0]	ALUCtrl_EX;
wire[2:0]	ALU_op_EX;
wire        Branch_EX, MemToReg_EX, MemRead_EX, MemWrite_EX, ALUSrc_EX, RegWrite_EX, RegDst_EX, zero_EX;

/**** MEM stage ****/
wire	[31:0]	result_MEM, pc_branch_MEM, RTdata_MEM, Memdata_MEM;
wire	[4:0]	RDaddr_MEM;
wire 		PCSrc_MEM;

//control signal
wire        Branch_MEM, MemToReg_MEM, MemRead_MEM, MemWrite_MEM, RegWrite_MEM, zero_MEM;

/**** WB stage ****/
wire	[31:0]	Memdata_WB, RDdata_WB, result_WB;
//control signal
wire	[4:0]	RDaddr_WB;
wire			RegWrite_WB;
wire			MemToReg_WB;

// Adding signal
wire			PC_Write, IF_ID_Write, IF_Flush, ID_Flush, EX_Flush;
wire	[1:0]	BranchType_ID, BranchType_EX, BranchType_MEM;
wire	[1:0]	Forward_A, Forward_B;
wire	[31:0]	MuxB_o;
wire			MUX4_1_o;

/****************************************
Instantiate modules
****************************************/
//Instantiate the components in IF stage
MUX_2to1 #(.size(32)) Mux0(
	.data0_i(pc_next_IF),
	.data1_i(pc_branch_MEM),
	.select_i(PCSrc_MEM), 
    .data_o(pc_in_IF)
);

ProgramCounter PC(
	.clk_i(clk_i),
	.rst_i(rst_i),
	.pc_write(PC_Write),
	.pc_in_i(pc_in_IF),
	.pc_out_o(pc_out_IF)
);

Instruction_Memory IM(
	.addr_i(pc_out_IF),
    .instr_o(instr_IF)
);

Adder Add_pc(
	.src1_i(pc_out_IF),
	.src2_i(32'd4),
	.sum_o(pc_next_IF)
);

Pipe_Reg #(.size(32)) IF_ID_PC_Next(
	.clk_i(clk_i),
    .rst_i(rst_i),
	.write(IF_ID_Write),
	.flush(IF_Flush),
    .data_i(pc_next_IF),
    .data_o(pc_next_ID)
);

Pipe_Reg #(.size(32)) IF_ID_instr(
	.clk_i(clk_i),
    .rst_i(rst_i),
	.write(IF_ID_Write),
	.flush(IF_Flush),
    .data_i(instr_IF),
    .data_o(instr_ID)
);
//Instantiate the components in ID stage
Reg_File RF(
	.clk_i(clk_i),
    .rst_i(rst_i),
    .RSaddr_i(instr_ID[25:21]),
    .RTaddr_i(instr_ID[20:16]),
    .RDaddr_i(RDaddr_WB),
    .RDdata_i(RDdata_WB),
    .RegWrite_i(RegWrite_WB),
    .RSdata_o(RSdata_ID),
    .RTdata_o(RDdata_ID)
);

Decoder Control(
	.instr_op_i(instr_ID[31:26]),
    .Branch(Branch_ID),
	.MemToReg(MemToReg_ID),
	.MemRead(MemRead_ID),
	.MemWrite(MemWrite_ID),
	.ALUOp(ALU_op_ID),
	.ALUSrc(ALUSrc_ID),
	.RegWrite(RegWrite_ID),
	.RegDest(RegDst_ID),
	.BranchType(BranchType_ID)
);

HazardDetection Hazard_Detection_unit(
	.EX_MemRead(MemRead_EX),
	.EX_Rt(Dst0_EX),
	.ID_Rs(instr_ID[25:21]),
	.ID_Rt(instr_ID[20:16]),
	.PCSrc(PCSrc_MEM), 
	.PC_Write(PC_Write),
	.IF_ID_Write(IF_ID_Write),
	.IF_Flush(IF_Flush),
	.ID_Flush(ID_Flush),
	.EX_Flush(EX_Flush)
);

Sign_Extend Extend(
    .data_i(instr_ID[15:0]),
    .data_o(extend_ID)
);	

Pipe_Reg #(.size(64)) ID_EX_ReadData(
	.clk_i(clk_i),
    .rst_i(rst_i),
	.write(1'b1),
	.flush(1'b0),
    .data_i({RSdata_ID, RDdata_ID}),
    .data_o({RSdata_EX, RTdata_EX})
);

Pipe_Reg #(.size(1+1+1+1+3+1+1+1+2)) ID_EX_Control(
	.clk_i(clk_i),
    .rst_i(rst_i),
	.write(1'b1),
	.flush(ID_Flush),
    .data_i({Branch_ID, MemToReg_ID, MemRead_ID, MemWrite_ID, ALU_op_ID, ALUSrc_ID, RegWrite_ID, RegDst_ID, BranchType_ID}),
    .data_o({Branch_EX, MemToReg_EX, MemRead_EX, MemWrite_EX, ALU_op_EX, ALUSrc_EX, RegWrite_EX, RegDst_EX, BranchType_EX})
);

Pipe_Reg #(.size(32+32+5+5+5)) ID_EX_other_signal(
	.clk_i(clk_i),
    .rst_i(rst_i),
	.write(1'b1),
	.flush(1'b0),
    .data_i({pc_next_ID, extend_ID, instr_ID[25:11]}),
    .data_o({pc_next_EX, extend_EX, Src_EX, Dst0_EX, Dst1_EX})
);

//Instantiate the components in EX stage	   
Shift_Left_Two_32 #(.size(32)) Shifter(
    .data_i(extend_EX),
    .data_o(shifted_EX)
);

Forwarding Forwarding_Unit(
	.EX_Rs(Src_EX),
	.EX_Rt(Dst0_EX),
	.MEM_Rd(RDaddr_MEM),
	.MEM_RegWrite(RegWrite_MEM),
	.WB_Rd(RDaddr_WB),
	.WB_RegWrite(RegWrite_WB),
	.Forward_A(Forward_A),
	.Forward_B(Forward_B)
    );

MUX_3to1 #(.size(32)) MuxA(
	.data0_i(RSdata_EX),
	.data1_i(result_MEM),
	.data2_i(RDdata_WB),
	.select_i(Forward_A),
    .data_o(ALUSource1_EX)
);

MUX_3to1 #(.size(32)) MuxB(
	.data0_i(RTdata_EX),
	.data1_i(result_MEM),
	.data2_i(RDdata_WB),
	.select_i(Forward_B),
    .data_o(MuxB_o)
);

MUX_2to1 #(.size(32)) Mux_ALUS2(
	.data0_i(MuxB_o),
	.data1_i(extend_EX),
	.select_i(ALUSrc_EX),
    .data_o(ALUSource2_EX)
);
	
ALU ALU(
    .src1_i(ALUSource1_EX),
	.src2_i(ALUSource2_EX),
	.ctrl_i(ALUCtrl_EX),
	.result_o(result_EX),
	.zero_o(zero_EX)
);
		
ALU_Ctrl ALU_Control(
	.funct_i(extend_EX[5:0]),
	.ALUOp_i(ALU_op_EX),
	.ALUCtrl_o(ALUCtrl_EX)
);

MUX_2to1 #(.size(5)) Mux_Dst_RS_RT(
	.data0_i(Dst0_EX),
	.data1_i(Dst1_EX),
	.select_i(RegDst_EX),
    .data_o(RDaddr_EX)
);

Adder Add_pc_branch(
	.src1_i(pc_next_EX),
	.src2_i(shifted_EX),
	.sum_o(pc_branch_EX)
);

Pipe_Reg #(.size(1+1+1+1+1)) EX_MEM_Control(
	.clk_i(clk_i),
    .rst_i(rst_i),
	.write(1'b1),
	.flush(EX_Flush),
    .data_i({RegWrite_EX, Branch_EX, MemToReg_EX, MemRead_EX, MemWrite_EX} ),
    .data_o({RegWrite_MEM, Branch_MEM, MemToReg_MEM, MemRead_MEM, MemWrite_MEM} )
);

Pipe_Reg #(.size(1)) EX_MEM_Zero(
	.clk_i(clk_i),
    .rst_i(rst_i),
	.write(1'b1),
	.flush(EX_Flush),
    .data_i(zero_EX),
    .data_o(zero_MEM)
);

Pipe_Reg #(.size(32+32+32+5+2)) EX_MEM_other_signal(
	.clk_i(clk_i),
    .rst_i(rst_i),
	.write(1'b1),
	.flush(1'b0),
    .data_i({pc_branch_EX, result_EX, MuxB_o, RDaddr_EX, BranchType_EX}),
    .data_o({pc_branch_MEM, result_MEM, RTdata_MEM, RDaddr_MEM, BranchType_MEM})
);

//Instantiate the components in MEM stage
Data_Memory DM(
    .clk_i(clk_i),
    .addr_i(result_MEM),
    .data_i(RTdata_MEM),
    .MemRead_i(MemRead_MEM),
    .MemWrite_i(MemWrite_MEM),
    .data_o(Memdata_MEM)
);

MUX_4to1 #(.size(1)) Mux_Branch_Type(
	.data0_i(zero_MEM),
	.data1_i(~( zero_MEM | result_MEM[31] )), //.data1_i(MUX4_1_i),
	.data2_i(~result_MEM[31]),
	.data3_i(~zero_MEM),
	.select_i(BranchType_MEM),
    .data_o(MUX4_1_o)
);

and MEMPCSrc (PCSrc_MEM, MUX4_1_o, Branch_MEM);

Pipe_Reg #(.size(1+1)) MEM_WB_Control(
	.clk_i(clk_i),
    .rst_i(rst_i),
	.write(1'b1),
	.flush(1'b0),
    .data_i({RegWrite_MEM, MemToReg_MEM}),
    .data_o({RegWrite_WB, MemToReg_WB})
);

Pipe_Reg #(.size(32+32+5)) MEM_WB_other_signal(
	.clk_i(clk_i),
    .rst_i(rst_i),
	.write(1'b1),
	.flush(1'b0),
    .data_i({Memdata_MEM, result_MEM, RDaddr_MEM}),
    .data_o({Memdata_WB, result_WB, RDaddr_WB})
);

//Instantiate the components in WB stage
MUX_2to1 #(.size(32)) Mux_WB(
	.data0_i(Memdata_WB),
	.data1_i(result_WB),
	.select_i(MemToReg_WB),
    .data_o(RDdata_WB)
);

/****************************************
signal assignment
****************************************/

endmodule