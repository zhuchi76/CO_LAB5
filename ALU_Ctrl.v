//0819823
//Subject:     CO project 4 - ALU Controller
//--------------------------------------------------------------------------------
//Version:     1
//--------------------------------------------------------------------------------
//Writer:      
//----------------------------------------------
//Date:        
//----------------------------------------------
//Description: 
//--------------------------------------------------------------------------------

module ALU_Ctrl(
	funct_i,
	ALUOp_i,
	ALUCtrl_o
);
//I/O ports 
input      [6-1:0] funct_i;
input      [3-1:0] ALUOp_i;

output     [4-1:0] ALUCtrl_o;    
     
//Internal Signals
reg        [4-1:0] ALUCtrl;

//Parameter

//Select exact operation

always@(*)begin
    case(ALUOp_i)
        3'd0: begin
            case(funct_i)
                6'd32: ALUCtrl = 4'd2;
                6'd34: ALUCtrl = 4'd6;
                6'd36: ALUCtrl = 4'd0;
                6'd37: ALUCtrl = 4'd1;
                6'd42: ALUCtrl = 4'd7;
                6'd24: ALUCtrl = 4'd3;
                default: ALUCtrl = 4'd0;
            endcase
		end
	    3'd1: ALUCtrl = 4'd2;
        3'd2: ALUCtrl = 4'd6;
        3'd3: ALUCtrl = 4'd2;
		3'd4: ALUCtrl = 4'd7;
		3'd5: ALUCtrl = 4'd0;
	endcase
end

assign ALUCtrl_o = ALUCtrl;

endmodule