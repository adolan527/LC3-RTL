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
`include "constants.vh"


module controller(
	input [15:0] PSR, //processor status register. PSR[15] = user/supervisor, [10:8] priority, [2:0] N Z P
	input [15:12] instruction, //opcode
	input INT, R, BEN, ACV, //Interrupt, ready to read memory, branch enable, access control violation
	input clk, reset_n,
	output reg LDMAR, LDMDR, LDIR, LDBEN, LDREG, LDCC, LDPC, LDPriv, LDPriority, LDSavedSSP, LDSavedUSP, LDACV, LDVector, //42 output bits
	output reg GatePC, GateMDR, GateALU, GateMARMUX, GateVector, GatePC1, GatePSR, GateSP,
	output reg [1:0] PCMUX, DRMUX, SR1MUX, ADDR2MUX, SPMUX, VectorMUX,
	output reg ADDR1MUX, MARMUX, TableMUX, PSRMUX,
	output reg MIOEN, RW, SetPriv //memory IO enable, Read/Write enable, Set privelege
    );
	
	

	//6-bit State names.
	reg [5:0] currentState, nextState;
	
	localparam FETCH = 6'd18; //Main fetch state.
	localparam FETCH_ACV = 6'd33; //access control violation check after fetch
	localparam FETCH_AWAIT = 6'd28; //await memory read
	localparam DECODE = 6'd30; //populate instruction register
	localparam DECODE_INSTR = 6'd32; //decide which instruction to execute
	
	//MICRO-INSTRUCTIONS
	localparam INSTR_ADD	=	6'd1;	//ADD 
	localparam INSTR_AND	=	6'd5;	//AND
	localparam INSTR_NOT	=	6'd9;	//NOT 
	localparam INSTR_LEA	=	6'd14;	//LEA 
	localparam INSTR_LD 	=	6'd2;	//LD  
	localparam INSTR_LDR	=	6'd6;	//LDR 
	localparam INSTR_LDI	=	6'd10;	//LDI 
	localparam INSTR_STI	=	6'd11;	//STI 
	localparam INSTR_STR	=	6'd7;	//STR 
	localparam INSTR_ST 	=	6'd3;	//ST  
	localparam INSTR_JSR	=	6'd4;	//JSR 
	localparam INSTR_JMP	=	6'd12;	//JMP 
	localparam INSTR_BR 	=	6'd0;	//BR  
	localparam INSTR_RTI	=	6'd8;	//RTI 
	localparam INSTR_TRAP	=	6'd15;	//TRAP 


	

	localparam START = 6'd0; // Debug start state
	
	localparam INTERRUPT = 6'd49;
	localparam ACCESS_CONTROL_VIOLATION = 6'd60;
	
	
	
	always@(*)begin //control signal assignment
		case(currentState)
			FETCH:begin // MAR <- PC, PC <- PC+1, set ACV, [INT]. note: Interrupt not implemented
				LDMAR <= 1; MARMUX <= 0; ADDR1MUX <= 0; ADDR2MUX <= 0; GateMARMUX <= 1; // MAR <- PC
				PCMUX <= 0; LDPC <= 1; // PC <- PC+1
				SetPriv <= 1;  //ACV
				if(INT) nextState<=INTERRUPT; //interrupt
				else nextState <= FETCH_ACV;
				
				//Reset everything not explicity set above
				LDMDR <= 0; LDIR <= 0; LDBEN <= 0; LDREG <= 0; LDCC <= 0;
				LDPriv <= 0; LDPriority <= 0; LDSavedSSP <= 0; LDSavedUSP <= 0; LDACV <= 0; LDVector <= 0; 
				GatePC <= 0; GateMDR <= 0; GateALU <= 0; GateVector <= 0; GatePC1 <= 0; GatePSR <= 0; GateSP <= 0; 
				DRMUX <= 0; SR1MUX <= 0; SPMUX <= 0; VectorMUX <= 0;  TableMUX <= 0; PSRMUX <= 0; 
				MIOEN <= 0; RW <= 0;

			end
			FETCH_ACV: begin //check ACV
				LDMAR <= 0; LDPC <= 0;
				GateMARMUX <= 0;
				if(ACV) nextState<=ACCESS_CONTROL_VIOLATION;
				else nextState <= FETCH_AWAIT;
			end
			FETCH_AWAIT: begin // MDR<-M
				LDMDR <= 1; MIOEN <= 1; 
				if(R) nextState<=DECODE;
				else nextState<= FETCH_AWAIT;
			end
			DECODE: begin //IR <- instruction
				LDMDR <= 0; MIOEN <= 0; 
				GateMDR <= 1; LDIR <= 1;	
				nextState<=DECODE_INSTR;
			end
			DECODE_INSTR: begin //BEN<−IR[11] & N + IR[10] & Z + IR[9] & P[IR[15:12]]
				//BEN is continuously assigned from datapath.
				GateMDR <= 0; LDIR<= 0;

				case(instruction)// TODO INSTR_X = OPCODE_X. case statement is unneccessary. Should Remove once all states are implemented
					`OPCODE_ADD		: 	nextState<=INSTR_ADD;
					`OPCODE_AND		: 	nextState<=INSTR_AND;
					`OPCODE_BR		: 	nextState<=START;
					`OPCODE_JMP		: 	nextState<=START;
					`OPCODE_JSR		: 	nextState<=START;
					`OPCODE_LD		: 	nextState<=START;
					`OPCODE_LDI		: 	nextState<=START;
					`OPCODE_LDR		: 	nextState<=START;
					`OPCODE_LEA		: 	nextState<=START;
					`OPCODE_NOT		: 	nextState<=INSTR_NOT;
					`OPCODE_RET		: 	nextState<=START;
					`OPCODE_RTI		: 	nextState<=START;
					`OPCODE_ST		: 	nextState<=START;
					`OPCODE_STI		: 	nextState<=START;
					`OPCODE_STR 	: 	nextState<=START;
					`OPCODE_TRAP	: 	nextState<=START;
					`OPCODE_RESERVED: 	nextState<=START;
					default			: 	nextState<=START;
				endcase
					
			end
			INSTR_ADD: begin
				DRMUX <= 2'b00; SR1MUX <= 2'b01;  LDREG <= 1;
				GateALU <= 1;
				nextState<= FETCH;
			end
			INSTR_AND: begin 
				DRMUX <= 2'b00; SR1MUX <= 2'b01;  LDREG <= 1;
				GateALU <= 1;
				nextState<= FETCH;
			end
			INSTR_NOT: begin 
				DRMUX <= 2'b00; SR1MUX <= 2'b01;  LDREG <= 1;
				GateALU <= 1;
				nextState<= FETCH;
			end
			
			START: begin
				nextState<=FETCH;
			end
			default:begin
				LDMAR <= 0; LDMDR <= 0; LDIR <= 0; LDBEN <= 0; LDREG <= 0; LDCC <= 0; LDPC <= 0; 
				LDPriv <= 0; LDPriority <= 0; LDSavedSSP <= 0; LDSavedUSP <= 0; LDACV <= 0; LDVector <= 0; 
				GatePC <= 0; GateMDR <= 0; GateALU <= 0; GateMARMUX <= 0; GateVector <= 0; GatePC1 <= 0; GatePSR <= 0; GateSP <= 0; 
				PCMUX <= 0; DRMUX <= 0; SR1MUX <= 0; ADDR2MUX <= 0; SPMUX <= 0; VectorMUX <= 0; ADDR1MUX <= 0; MARMUX <= 0; TableMUX <= 0; PSRMUX <= 0; 
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
			PCMUX <= 0; DRMUX <= 0; SR1MUX <= 0; ADDR2MUX <= 0; SPMUX <= 0; VectorMUX <= 0; ADDR1MUX <= 0; MARMUX <= 0; TableMUX <= 0; PSRMUX <= 0; 
			MIOEN <= 0; RW <= 0; SetPriv <= 0;
		end else begin
			currentState <= nextState;
		end
		
	end
	
endmodule
 
 
