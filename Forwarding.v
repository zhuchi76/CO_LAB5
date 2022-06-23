`timescale 1ns / 1ps
//0819823
//Subject:     CO project 4 - Pipe Register
//--------------------------------------------------------------------------------
//Version:     1
//--------------------------------------------------------------------------------
//Writer:      
//----------------------------------------------
//Date:        
//----------------------------------------------
//Description: 
//--------------------------------------------------------------------------------
module Forwarding(
	EX_Rs,
	EX_Rt,
	MEM_Rd,
	MEM_RegWrite,
	WB_Rd,
	WB_RegWrite,
	Forward_A,
	Forward_B
    );

input 	[4:0]	EX_Rs;
input 	[4:0]	EX_Rt;
input 	[4:0]	MEM_Rd;
input 			MEM_RegWrite;
input 	[4:0]	WB_Rd;
input 			WB_RegWrite;
output	[1:0]	Forward_A;
output	[1:0]	Forward_B;

reg 	[1:0]	result_A = 2'd0;
reg 	[1:0]	result_B = 2'd0;

always@(*)begin
	if((MEM_RegWrite) && (MEM_Rd != 0) && (MEM_Rd == EX_Rs)) result_A = 2'd1;
	else if((WB_RegWrite) && (WB_Rd != 0) && (!((MEM_RegWrite) && (MEM_Rd != 0) && (MEM_Rd == EX_Rs))) && (WB_Rd == EX_Rs)) result_A = 2'd2;
	else result_A = 2'd0;
	if((MEM_RegWrite) && (MEM_Rd != 0) && (MEM_Rd == EX_Rt)) result_B = 2'd1;
	else if((WB_RegWrite) && (WB_Rd != 0) && (!((MEM_RegWrite) && (MEM_Rd != 0) && (MEM_Rd == EX_Rt))) && (WB_Rd == EX_Rt)) result_B = 2'd2;
	else result_B = 2'd0;
end

assign Forward_A = result_A;
assign Forward_B = result_B;

endmodule	