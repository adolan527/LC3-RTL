`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/16/2024 05:59:21 PM
// Design Name: 
// Module Name: controller
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



module controller(
	input [15:0] PSR, //processor status register. PSR[15] = user/supervisor, [10:8] priority, [2:0] N Z P
	input [15:11] instruction, //opcode
	input INT, R, BEN, ACV, //Interrupt, ready to read memory, branch enable, access control violation
	input clk, reset_n,
	output reg LDMAR, LDMDR, LDIR, LDBEN, LDREG, LDCC, LDPC, LDPriv, LDPriority, LDSavedSSP, LDSavedUSP, LDACV, LDVector, //42 output bits
	output reg GatePC, GateMDR, GateALU, GateMARMUX, GateVector, GatePC1, GatePSR, GateSP,
	output reg [1:0] PCMUX, DRMUX, SR1MUX, ADDR2MUX, SPMUX, VectorMUX, ALUK,
	output reg ADDR1MUX, MARMUX, TableMUX, PSRMUX,
	output reg MIOEN, RW, SetPriv //memory IO enable, Read/Write enable, Set privelege
    );

	//6-bit State names.
	reg [5:0] currentState, nextState;

	
	localparam FETCH = 6'd18; //Main fetch state.
	localparam FETCHACV = 6'd33; //access control violation check after fetch
	localparam FETCHAWAIT = 6'd28; //await memory read
	localparam DECODE = 6'd30; //populate instruction register
	localparam DECODEMICRO = 6'd32; //decide which microinstruction to execute

	localparam START = 6'd0; // Debug start state
	
	localparam INTERRUPT = 6'd49;
	localparam ACCESSCONTROLVIOLATION = 6'd60;
	
	always@(*)begin //control signal assignment
		case(currentState)
			FETCH:begin // MAR <- PC, PC <- PC+1, set ACV, [INT]. note: Interrupt not implemented
				LDMAR <= 1; MARMUX <= 0; ADDR1MUX <= 0; ADDR2MUX <= 0; // MAR <- PC
				PCMUX <= 0; SetPriv <= 1; LDPC <= 1;
				if(INT) nextState<=INTERRUPT;
				else nextState <= FETCHACV;
			end
			FETCHACV: begin //check ACV
				LDMAR <= 0; LDPC <= 0;
				if(ACV) nextState<=ACCESSCONTROLVIOLATION;
				else nextState <= FETCHAWAIT;
			end
			FETCHAWAIT: begin // MDR<-M
				LDMDR <= 1; 
				if(R) nextState<=DECODE;
				else nextState<= FETCHAWAIT;
			end
			START: begin
				nextState<=FETCH;
			end
			default:begin
				LDMAR <= 0; LDMDR <= 0; LDIR <= 0; LDBEN <= 0; LDREG <= 0; LDCC <= 0; LDPC <= 0; 
				LDPriv <= 0; LDPriority <= 0; LDSavedSSP <= 0; LDSavedUSP <= 0; LDACV <= 0; LDVector <= 0; 
				GatePC <= 0; GateMDR <= 0; GateALU <= 0; GateMARMUX <= 0; GateVector <= 0; GatePC1 <= 0; GatePSR <= 0; GateSP <= 0; 
				PCMUX <= 0; DRMUX <= 0; SR1MUX <= 0; ADDR2MUX <= 0; SPMUX <= 0; VectorMUX <= 0; ALUK <= 0; ADDR1MUX <= 0; MARMUX <= 0; TableMUX <= 0; PSRMUX <= 0; 
				MIOEN <= 0; RW <= 0; SetPriv <= 0;
				nextState <= FETCH;
			end
		endcase
		
	end
	
	always@(posedge clk or negedge reset_n)begin //next state assignment
		if(!reset_n) begin
			currentState <= 0; 
			LDMAR <= 0; LDMAR <= 0; LDMDR <= 0; LDIR <= 0; LDBEN <= 0; LDREG <= 0; LDCC <= 0; LDPC <= 0; 
			LDPriv <= 0; LDPriority <= 0; LDSavedSSP <= 0; LDSavedUSP <= 0; LDACV <= 0; LDVector <= 0; 
			GatePC <= 0; GateMDR <= 0; GateALU <= 0; GateMARMUX <= 0; GateVector <= 0; GatePC1 <= 0; GatePSR <= 0; GateSP <= 0; 
			PCMUX <= 0; DRMUX <= 0; SR1MUX <= 0; ADDR2MUX <= 0; SPMUX <= 0; VectorMUX <= 0; ALUK <= 0; ADDR1MUX <= 0; MARMUX <= 0; TableMUX <= 0; PSRMUX <= 0; 
			MIOEN <= 0; RW <= 0; SetPriv <= 0;
		end else begin
			currentState <= nextState;
		end
		
	end
	
endmodule
 
 
