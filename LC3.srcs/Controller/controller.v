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
`include "../globalConstants.vh"
`include "controllerConstants.vh"

module controller(
	input [15:0] PSR, //processor status register. PSR[15] = user/supervisor, [10:8] priority, [2:0] N Z P
	input [15:11] instruction, //opcode + 1
	input INT, R, BEN, ACV, //Interrupt, ready to read memory, branch enable, access control violation
	input clk, reset_n,
	output reg LDMAR, LDMDR, LDIR, LDBEN, LDREG, LDCC, LDPC, LDPriv, LDPriority, LDSavedSSP, LDSavedUSP, LDACV, LDVector, //42 output bits
	output reg GatePC, GateMDR, GateALU, GateMARMUX, GateVector, GatePC1, GatePSR, GateSP,
	output reg [1:0] PCMUX, DRMUX, SR1MUX, ADDR2MUX, SPMUX, VectorMUX,
	output reg ADDR1MUX, MARMUX, TableMUX, PSRMUX,
	output reg MIOEN, RW, SetPriv, //memory IO enable, Read/Write enable, Set privilege. PRIV = 0 -> S, PRIV = 1 -> U
	
	output wire[5:0] debugCurrentState, debugNextState
    );
	

	//6-bit State names.
	reg [5:0] currentState, nextState;
	
	assign debugCurrentState = currentState;
	assign debugNextState = nextState;

	
	localparam FETCH 			= 6'd18; //Main fetch state.
	localparam FETCH_CHECK_ACV 	= 6'd33; //access control violation check after fetch
	localparam FETCH_AWAIT 		= 6'd28; //await memory read
	localparam DECODE 			= 6'd30; //populate instruction register
	localparam DECODE_INSTR 	= 6'd32; //decide which instruction to execute
	
	//MICRO-INSTRUCTIONS
	localparam INSTR_ADD		= 6'd1 ;		//ADD 
	localparam INSTR_AND		= 6'd5 ;		//AND
	localparam INSTR_NOT		= 6'd9 ;		//NOT 
	localparam INSTR_LEA		= 6'd14;	//LEA 
	localparam INSTR_LD 		= 6'd2 ;		//LD  
	localparam INSTR_LDR		= 6'd6 ;		//LDR 
	localparam INSTR_LDI		= 6'd10;	//LDI 
	localparam INSTR_STI		= 6'd11;	//STI 
	localparam INSTR_STR		= 6'd7 ;		//STR 
	localparam INSTR_ST 		= 6'd3 ;		//ST  
	localparam INSTR_JSR		= 6'd4 ;		//JSR 
	localparam INSTR_JMP		= 6'd12;	//JMP 
	localparam INSTR_BR 		= 6'd0 ;		//BR  
	localparam INSTR_RTI		= 6'd8 ;		//RTI 
	localparam INSTR_TRAP		= 6'd15;	//TRAP 
	
	localparam LDI_CHECK_ACV 	= 6'd17; //LDI first half
	localparam LDI_READ_MEM 	= 6'd24; //LDI first half
	localparam LDI_LATTER 		= 6'd26; //LDI MAR <= MDR	
	
	localparam LOAD_CHECK_ACV 	= 6'd35; //state inside lD, LDR, and LDI which checks for ACV
	localparam LOAD_READ_MEM 	= 6'd25; //LD, LDR, LDI, MDR <= M[MAR]
	localparam LOAD_WRITE_REG 	= 6'd27; //LD, LDR, LDI, DR <= M. Last LOAD state
	
	
	localparam STI_CHECK_ACV	= 6'd19; //STI first half
	localparam STI_READ_MEM		= 6'd29; //STI first half
	localparam STI_LATTER		= 6'd31; //STI MAR <= MDR
	
	localparam STORE_CHECK_ACV 	= 6'd23; //ST, STR, STI, checks for ACV
	localparam STORE_WRITE_MEM 	= 6'd16; //ST, STR, STI, M[MAR] <= MDR. Last STORE state
	
	localparam BRANCH_EXECUTE	= 6'd22; //PC <= PC + off9
	
	localparam JSR_IMM			= 6'd21; //PC <= PC + off11
	localparam JSR_REG			= 6'd20; //PC <= SR
	
	

	localparam START 			= 6'b0 ; // Debug start state
	
	localparam INTERRUPT 		= 6'd49;// Not implemented
	
	localparam FETCH_ACV 		= 6'd60; //Handles ACV in Fetch
	localparam LOAD_ACV 		= 6'd57; //Handles ACV in LD, LDR, LDI
	localparam LDI_ACV 			= 6'd56; //Handles ACV in LDI
	localparam STORE_ACV 		= 6'd48; //Handles ACV in ST, STR, STI
	localparam STI_ACV 			= 6'd61; //Handles ACV in STI
	
	
// TODO break into microsequencer, control store, and microinstruction
	
	always@(*)begin //control signal assignment
		case(currentState)
			FETCH:begin // MAR <- PC, PC <- PC+1, set ACV, [INT]. note: Interrupt not implemented
				LDMAR <= 1; MARMUX <= `MARMUX_ADR_SUM; ADDR1MUX <= `ADDR1MUX_PC; ADDR2MUX <= `ADDR2MUX_OFFSET_0; GateMARMUX <= 1; // MAR <- PC
				PCMUX <= `PCMUX_INC; LDPC <= 1; // PC <- PC+1
				LDACV <= 1;
				
				if(INT) nextState<=INTERRUPT; //interrupt
				else nextState <= FETCH_CHECK_ACV;
				
				//Reset everything not explicity set above
				LDMDR <= 0; LDIR <= 0; LDBEN <= 0; LDREG <= 0; LDCC <= 0;
				LDPriv <= 0; LDPriority <= 0; LDSavedSSP <= 0; LDSavedUSP <= 0; LDVector <= 0; 
				GatePC <= 0; GateMDR <= 0; GateALU <= 0; GateVector <= 0; GatePC1 <= 0; GatePSR <= 0; GateSP <= 0; 
				DRMUX <= 0; SR1MUX <= 0; SPMUX <= 0; VectorMUX <= 0;  TableMUX <= 0; PSRMUX <= 0; 
				MIOEN <= 0; RW <= 0;

			end
			FETCH_CHECK_ACV: begin //check ACV
				LDMAR <= 0; LDPC <= 0;
				GateMARMUX <= 0; LDACV <= 0;
				
				if(ACV) nextState<=FETCH_ACV;
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

				case(instruction[15:12])// TODO INSTR_X = OPCODE_X. case statement is unneccessary. Should Remove once all states are implemented
					`OPCODE_ADD		: 	nextState<=INSTR_ADD;
					`OPCODE_AND		: 	nextState<=INSTR_AND;
					`OPCODE_BR		: 	nextState<=INSTR_BR;
					`OPCODE_JMP		: 	nextState<=INSTR_JMP;
					`OPCODE_JSR		: 	nextState<=INSTR_JSR;
					`OPCODE_LD		: 	nextState<=INSTR_LD;
					`OPCODE_LDI		: 	nextState<=INSTR_LDI;
					`OPCODE_LDR		: 	nextState<=INSTR_LDR;
					`OPCODE_LEA		: 	nextState<=INSTR_LEA;
					`OPCODE_NOT		: 	nextState<=INSTR_NOT;
					`OPCODE_RTI		: 	nextState<=START;
					`OPCODE_ST		: 	nextState<=INSTR_ST;
					`OPCODE_STI		: 	nextState<=INSTR_STI;
					`OPCODE_STR 	: 	nextState<=INSTR_STR;
					`OPCODE_TRAP	: 	nextState<=START;
					`OPCODE_RESERVED: 	nextState<=START;
					default			: 	nextState<=START;
				endcase
					
			end
			INSTR_ADD: begin
				DRMUX <= `DRMUX_FIRST; SR1MUX <= `SR1MUX_SECOND;  LDREG <= 1; LDCC<=1;
				GateALU <= 1;
				nextState<= FETCH;
			end
			INSTR_AND: begin 
				DRMUX <= `DRMUX_FIRST; SR1MUX <= `SR1MUX_SECOND;  LDREG <= 1; LDCC<=1;
				GateALU <= 1;
				nextState<= FETCH;
			end
			INSTR_NOT: begin 
				DRMUX <= `DRMUX_FIRST; SR1MUX <= `SR1MUX_SECOND;  LDREG <= 1; LDCC<=1;
				GateALU <= 1;
				nextState<= FETCH;
			end
			INSTR_LEA: begin //DR<−PC+off9
				//Use the MARMUX, and address adder
				DRMUX <= `DRMUX_FIRST; ADDR1MUX <= `ADDR1MUX_PC ; ADDR2MUX <= `ADDR2MUX_OFFSET_9; // PC + 9 bit offset
				MARMUX <= `MARMUX_ADR_SUM; GateMARMUX <= 1; //Use address sum, output to databus. Does not load MAR
				LDREG <= 1; //Loads into regfile
				nextState <= FETCH;
			end
			INSTR_LD: begin //MAR<−PC+off9 , set ACV
				ADDR1MUX <= `ADDR1MUX_PC; ADDR2MUX <= `ADDR2MUX_OFFSET_9; // PC + 9 bit offset
				MARMUX <= `MARMUX_ADR_SUM; GateMARMUX <= 1; LDMAR <= 1; //Use address sum, output to databus. LD MAR.
				LDACV <= 1;
				nextState <= LOAD_CHECK_ACV;
			end
			
			INSTR_LDR: begin //MAR<-B+off6, set ACV
				ADDR1MUX <= `ADDR1MUX_SR1 ; ADDR2MUX <= `ADDR2MUX_OFFSET_6; SR1MUX <= `SR1MUX_SECOND; // SR1 + 6 bit offset
				MARMUX <= `MARMUX_ADR_SUM; GateMARMUX <= 1; LDMAR <= 1; //Use address sum, output to databus. LD MAR.
				LDACV <= 1;
				nextState <= LOAD_CHECK_ACV;
			end
			
			INSTR_LDI: begin //MAR <- PC+off9
				ADDR1MUX <= `ADDR1MUX_PC; ADDR2MUX <= `ADDR2MUX_OFFSET_9; // PC + 9 bit offset
				MARMUX <= `MARMUX_ADR_SUM; GateMARMUX <= 1; LDMAR <= 1; //Use address sum, output to databus. LD MAR.				
				LDACV <= 1;
				nextState <= LDI_CHECK_ACV;
			end
			
			LDI_CHECK_ACV: begin //check ACV
				ADDR1MUX <= 0; ADDR2MUX <= 2'b00; SR1MUX <= 2'b00; // Disable
				MARMUX <= 0; GateMARMUX <= 0; LDMAR <= 0; LDACV <= 0;//Disable
				if(ACV) nextState<=LDI_ACV;
				else nextState <= LDI_READ_MEM;
			end
			
			LDI_READ_MEM: begin //MDR<-M[MAR]
				LDMDR <= 1; MIOEN <= 1;
				if(R) nextState<=LDI_LATTER;
				else nextState<= LDI_READ_MEM;
			end		
			
			LDI_LATTER: begin //MAR <-MDR, set ACV
				LDMDR <= 0; MIOEN <= 0;//disable
				LDMAR <= 1; GateMDR <= 1;
				LDACV <= 1;
				nextState <= LOAD_CHECK_ACV;
			end

			LOAD_CHECK_ACV: begin // check ACV
				ADDR1MUX <= 0; ADDR2MUX <= 2'b00;  SR1MUX <= 2'b00; // Disable
				MARMUX <= 0; GateMARMUX <= 0; LDMAR <= 0; //Disable
				GateMDR <= 0; LDACV <= 0; // Disable
				if(ACV) nextState<=LOAD_ACV;
				else nextState <= LOAD_READ_MEM;
			end
			
			LOAD_READ_MEM: begin //MDR<-M[MAR]
				LDMDR <= 1; MIOEN <= 1;
				if(R) nextState<=LOAD_WRITE_REG;
				else nextState<= LOAD_READ_MEM;
			end	
			
			LOAD_WRITE_REG: begin //DR<-MDR, set CC 
				LDMDR <= 0; MIOEN <= 0;//disable
				GateMDR <= 1; LDREG <= 1; DRMUX <= `DRMUX_FIRST;
				LDCC <= 1;
				nextState <= FETCH;
			end
			
			INSTR_ST: begin // MAR <- PC + off9, set ACV
				ADDR1MUX <= `ADDR1MUX_PC ; ADDR2MUX <= `ADDR2MUX_OFFSET_9; // PC + 9 bit offset
				MARMUX <= `MARMUX_ADR_SUM; GateMARMUX <= 1; LDMAR <= 1; //Use address sum, output to databus. LD MAR.
				LDACV <= 1;
				nextState <= STORE_CHECK_ACV;
			end
			
			INSTR_STR: begin //MAR <- B + off6
				ADDR1MUX <= `ADDR1MUX_SR1 ; ADDR2MUX <= `ADDR2MUX_OFFSET_6; SR1MUX <= `SR1MUX_SECOND; // SR1 + 6 bit offset
				MARMUX <= `MARMUX_ADR_SUM; GateMARMUX <= 1; LDMAR <= 1; //Use address sum, output to databus. LD MAR.
				LDACV <= 1;
				nextState <= STORE_CHECK_ACV;
			end
			
			INSTR_STI: begin // MAR<−PC+off9, set ACV
				ADDR1MUX <= `ADDR1MUX_PC; ADDR2MUX <= `ADDR2MUX_OFFSET_9; // PC + 9 bit offset
				MARMUX <= `MARMUX_ADR_SUM; GateMARMUX <= 1; LDMAR <= 1; //Use address sum, output to databus. LD MAR.
				LDACV <= 1;
				nextState <= STI_CHECK_ACV;
			end
				
			STI_CHECK_ACV: begin //check ACV
				ADDR1MUX <= 0; ADDR2MUX <= 2'b00; SR1MUX <= 2'b00; // Disable
				MARMUX <= 0; GateMARMUX <= 0; LDMAR <= 0; LDACV <= 0; //Disable
				if(ACV) nextState<=STI_ACV;
				else nextState <= STI_READ_MEM;
			end
			
			STI_READ_MEM: begin //MDR <-M[MAR]
				LDMDR <= 1; MIOEN <= 1;
				if(R) nextState<=STI_LATTER;
				else nextState<= STI_READ_MEM;
			end
			
			STI_LATTER: begin // MAR<-MDR, set ACV
				LDMDR <= 0; MIOEN <= 0;//disable
				LDMAR <= 1; GateMDR <= 1;
				LDACV <= 1;
				nextState <= STORE_CHECK_ACV;
			end
			
			STORE_CHECK_ACV: begin // MDR <- SR, check ACV
				ADDR1MUX <= 0; ADDR2MUX <= 2'b00; // disable
				MARMUX <= 0; GateMARMUX <= 0; LDMAR <= 0; //disable
				GateMDR <= 0; LDACV <= 0; // Disable
				LDMDR <= 1; MIOEN <= 0; 
				SR1MUX <= `SR1MUX_FIRST; ADDR1MUX <= `ADDR1MUX_SR1; ADDR2MUX <= `ADDR2MUX_OFFSET_0; GateMARMUX <= 1; // Send data through MARMUX
				if(ACV) nextState<=STORE_ACV;
				else nextState<= STORE_WRITE_MEM;
			end
			
			STORE_WRITE_MEM: begin //M[MAR]<-MDR
				LDMDR <= 0; RW <= 1; //write to memory
				if(R) nextState<= FETCH;
				else nextState<= STORE_WRITE_MEM;
			end
			
			INSTR_BR: begin // check BEN
				if(BEN) nextState <= BRANCH_EXECUTE;
				else nextState <= FETCH;
			end
			
			BRANCH_EXECUTE: begin // PC <= PC + off9
				LDPC <= 1; PCMUX <= `PCMUX_ADDR; 
				ADDR1MUX <= `ADDR1MUX_PC; ADDR2MUX <= `ADDR2MUX_OFFSET_9;
				nextState <= FETCH;
			end
			
			INSTR_JMP: begin // PC <= BaseR
				LDPC <= 1; PCMUX <= `PCMUX_ADDR; 
				SR1MUX <= `SR1MUX_SECOND;
				ADDR1MUX <= `ADDR1MUX_SR1; ADDR2MUX <= `ADDR2MUX_OFFSET_0;
				nextState <= FETCH;
			end
			
			INSTR_JSR: begin // JSR or JSRR (imm or reg)
				if(instruction[11]) nextState <= JSR_IMM;
				else nextState <= JSR_REG;
			end
			
			JSR_REG: begin // R7 <= PC. PC <= PC + baseR
				DRMUX <= `DRMUX_SEVEN; LDREG <= 1; GatePC <= 1;
				LDPC <= 1; PCMUX <= `PCMUX_ADDR; 
				SR1MUX <= `SR1MUX_SECOND;
				ADDR1MUX <= `ADDR1MUX_SR1; ADDR2MUX <= `ADDR2MUX_OFFSET_0;
				nextState <= FETCH;
			end
			
			JSR_IMM: begin // R7 <= PC. PC <= PC + off11
				DRMUX <= `DRMUX_SEVEN; LDREG <= 1; GatePC <= 1;
				LDPC <= 1; PCMUX <= `PCMUX_ADDR; 
				ADDR1MUX <= `ADDR1MUX_PC; ADDR2MUX <= `ADDR2MUX_OFFSET_11;
				nextState <= FETCH;
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
 
 
