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


`define INTV 16'b0

module stackPointer( //TODO verify
//registers + mux + gate
	input[1:0] SPMUX,
	input LDSavedUSP, LDSavedSSP, //user/super stack pointer
	input GateSP,
	input clk, reset_n,
	input[15:0] SR1,
	output reg [15:0] dataBus
	);
	reg[15:0] SavedUSP, SavedSSP, result; //saved user/super stack pointer
	
	always@(posedge clk or negedge reset_n) begin
		if(!reset_n)begin
			SavedUSP<=0;
			SavedSSP<=0;
		end else begin
			if(LDSavedSSP) SavedSSP <= SR1;
			else SavedSSP <= SavedSSP;
			if(LDSavedUSP) SavedUSP <= SR1;
			else SavedUSP <= SavedUSP;
		end
	end
	
	always@(*) begin
		dataBus <= GateSP ? result : {16'bz};
		case(SPMUX) 
			`SPMUX_INC: result <= SR1 + 1'b1;
			`SPMUX_DEC: result <= SR1 - 1'b1;
			`SPMUX_SSP: result <= SavedSSP;
			`SPMUX_USP: result <= SavedUSP;
		endcase
	end
	
endmodule



module TRAPBlock(//TODO verify
	input clk, reset_n,
	input [7:0] INTV, //interrupt vector provided by foreign device
	input[15:0] dataBusIn,
	input GateVector, LDVector, TableMUX,
	input [1:0] VectorMUX,
	output reg[15:0] dataBusOut
	);
	
	reg[7:0] tableReg, vectorReg;
	reg[7:0] vectorMuxResult, tableMuxResult, doubleMuxResult;
	
	always@(posedge clk or negedge reset_n)begin
		if(!reset_n)begin
			vectorReg<=0;
			tableReg<=0;
		end else begin
			if(LDVector) begin
				vectorReg <= doubleMuxResult;
				tableReg <= tableMuxResult;
			end else begin
				vectorReg <= vectorReg;
				tableReg <= tableReg;
			end
		end
	end
	
	always@(*)begin
		case(VectorMUX)
			`VectorMUX_INTV: vectorMuxResult<=`INTV; //TODO define INTV
			`VectorMUX_0: vectorMuxResult<= 16'b0;
			`VectorMUX_1: vectorMuxResult<= 16'b1;
			`VectorMUX_2: vectorMuxResult<= 16'b10;
		endcase
		
		case(TableMUX)
			`TableMUX_0: begin
				doubleMuxResult <= dataBusIn[15:0];
				tableMuxResult <= 0;
			end
			`TableMUX_1: begin
				doubleMuxResult <= vectorMuxResult;
				tableMuxResult <= 1;
			end
		endcase
		
		dataBusOut <= GateVector ? {tableReg,vectorReg} : {16'bz};
	end

endmodule


module PSRBlock(//TODO complete
	input PSRMUX, SETPRIV,
	input LDPriv, LDACV, LDPriority, LDCC,
	input GatePSR,
	input[2:0] interrupt_priority,
	input clk, reset_n,
	input[15:0] dataBusIn,
	output reg[15:0] dataBusOut, PSR,
	output reg ACV, INT //access control violation, interrupt flag
	);
	
localparam N = 2;
localparam Z = 1;
localparam P = 0;
localparam PRIV = 15;
localparam PRIO_S = 10;
localparam PRIO_E = 8;


	reg next_ACV;
	
	
	always@(*)begin
		dataBusOut <= GatePSR ? PSR : {16'bz};
		
		next_ACV <= PSR[15] & //user mode and
			(&dataBusIn[15:9] | &(~dataBusIn[15:14])); // Address >= 0xFF00 or Address < 0x3000

		if(interrupt_priority > PSR[PRIO_S:PRIO_E]) INT <= 1;
		else INT <= 0;


	end
	
	always@(posedge clk or negedge reset_n) begin
		if(!reset_n) begin
			PSR <= 0;
			ACV <= 0;
		end else begin
			if(LDACV) ACV <= next_ACV;
			else ACV <= ACV;
			

		
			case(PSRMUX)
				`PSRMUX_Individual: begin
					if(LDCC) begin
						PSR[N] <= dataBusIn[15]; 
						PSR[Z] <= !(|dataBusIn); 
						PSR[P] <= !dataBusIn[15] && |dataBusIn[14:0];
					end
					else PSR[N:P] <= PSR[N:P];
					
					if(LDPriv) PSR[PRIV] <= SETPRIV;
					else PSR[PRIV] <= PSR[PRIV];
					
					if(LDPriority) PSR[PRIO_S:PRIO_E] <= interrupt_priority;
					else PSR[PRIO_S:PRIO_E] <= PSR[PRIO_S:PRIO_E];
					
					PSR[14:11] <= 0;//unused
					PSR[7:3] <= 0;//unused
				end
				`PSRMUX_Databus: begin
					PSR <= dataBusIn;
				end
			endcase
		end
	end
		
		
	
	
endmodule
	