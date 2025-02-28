`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2/27/2025
// Design Name: 
// Module Name: interruptStuff
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


/*
module stackPointer( //registers + mux + gate
	input[1:0] SPMUX,
	input LDSavedUSP, LDSavedSSP, //user/super stack pointer
	input GateSP,
	input clk, reset_n,
	input[15:0] SR1
	output reg [15:0] dataBus
	);
	reg[15:0] SavedUSP, SavedSSP, result; //saved user/super stack pointer
	
	always@(posedge clk or negedge reset_n)begin
		if(!reset_n)begin
			SavedUSP<=0;
			SavedSSP<=0;
		end else begin
			if(LDSavedSSP) SavedSSP <= SR1;
			else SavedSSP <= SavedSSP;
			if(LDSavedUSP) LDSavedUSP <= SR1;
			else LDSavedUSP <= LDSavedUSP;
		end
	end
	
	always@(*)begin
		dataBus <= GateSP ? result : {16'bz};
		case(SPMUX)begin
			`SPMUX_SSP: result <= SavedSSP;
			`SPMUX_DEC: result <= SR1 - 1'b1;
			`SPMUX_INC: result <= SR1 + 1'b1;
			`SPMUX_USP: result <= SavedUSP;
		endcase
	end
	
end

module TRAPBlock(
	input clk, reset_n,
	input[15:0] dataBusIn,
	input GateVector, LDVector, TableMUX,
	input [1:0] VectorMux,
	output[15:0] dataBusOut
	);
	
	reg[7:0] tableReg, vectorReg;
	reg[7:0] vectorMuxResult, tableMuxResult, doubleMuxResult;
	
	always@(posedge clk or negedge reset_n)begin
		if(!reset_n)begin
			vectorReg<=0;
			tableReg<=0;
		end else begin
			if(LDVector) begin
				vectorReg <= ;
				tableReg <= ;
			end else begin
				vectorReg <= vectorReg;
				tableReg <= tableReg;
			end
		end
	end
	
	always@(*)begin
		case(VectorMux)begin
			`VectorMux_INTV: vectorMuxResult<=`INTV;
			`VectorMux_0: vectorMuxResult<= 16'b0;
			`VectorMux_1: vectorMuxResult<= 16'b1;
			`VectorMux_2: vectorMuxResult<= 16'b2;
		endcase
		
		doubleMuxResult <= 

endmodule*/