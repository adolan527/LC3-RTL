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
	output reg MIOEN, RW, SETPRIV, //memory IO enable, Read/Write enable, Set privilege. PRIV = 0 -> S, PRIV = 1 -> U
	
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
	localparam INSTR_TRAP		= 6'd15;	//TRAP - //Table <- 0, PC +1, MDR <- PSR
	localparam INSTR_RESERVED	= 6'd13; 	// Table <- 1, Vector <- 1, MDR <- PSR, PSR[15] <- 0, [PSR[15]]
	
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

	localparam RTI_EXCEPTION 	= 6'd44; //Handles privelege mode exception
	localparam RTI_FETCH_PC		= 6'd36; //MDR <- M
	localparam RTI_LOAD_PC		= 6'd38; //PC <- MDR
	localparam RTI_INC_R6		= 6'd39; //MAR, SP <- SP +1
	localparam RTI_FETCH_PSR	= 6'd40; //MDR <- M
	localparam RTI_LOAD_PSR		= 6'd42; //PSR <- MDR
	localparam RTI_CHECK_MODE	= 6'd34; //SP <- SP +1   [PSR[15]]
	localparam RTI_USER 		= 6'd59; //SSP <- SP, SP <- USP
	localparam RTI_SUPER		= 6'd51; //nothing

	localparam TRAP_VECTOR		= 6'd47; //Vector <- IR[7:0], Priv = 0, check priv.
	
	localparam SWITCH_SP		= 6'd45; // Saved_SSP<−SP, SP<−Saved_USP
	
	localparam PUSH_PSR_0 		= 6'd37; //MAR, SP <- SP-1
	localparam PUSH_PSR_1 		= 6'd41; 
	localparam PUSH_PC_0 		= 6'd43; 
	localparam PUSH_PC_1		= 6'd46; 
	localparam PUSH_PC_2 		= 6'd52; 
	localparam VECTOR_REFERENCE	= 6'd54; 
	localparam VECTOR_READ		= 6'd53; 
	localparam VECTOR_JUMP		= 6'd55; 
	
// TODO break into microsequencer, control store, and microinstruction
// TODO implement RTI, TRAP, Interrupt, ACV, 1101
	
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
/* Begin default assignments */
 MIOEN <= 0; GateMDR <= 0; LDMAR <= 0; GateALU <= 0; GatePSR <= 0; LDCC <= 0; PSRMUX <= 0; LDMDR <= 0; LDPC <= 0; GateMARMUX <= 0; LDPriority <= 0; LDREG <= 0; LDSavedUSP <= 0; GatePC1 <= 0; LDIR <= 0; GatePC <= 0; LDSavedSSP <= 0; GateVector <= 0; LDACV <= 0; GateSP <= 0; LDVector <= 0; LDPriv <= 0; LDBEN <= 0; 
 /* End default assignments*/
				if(ACV) nextState<=FETCH_ACV;
				else nextState <= FETCH_AWAIT;
			end
			FETCH_AWAIT: begin // MDR<-M
				LDMDR <= 1; MIOEN <= 1; 
 
/* Begin default assignments */
 GatePC1 <= 0; PSRMUX <= 0; GateMARMUX <= 0; GateMDR <= 0; LDMAR <= 0; LDCC <= 0; LDACV <= 0; GateVector <= 0; GateALU <= 0; GatePSR <= 0; LDPriority <= 0; GateSP <= 0; LDREG <= 0; LDSavedUSP <= 0; LDPC <= 0; GatePC <= 0; LDSavedSSP <= 0; LDPriv <= 0; LDIR <= 0; LDBEN <= 0; LDVector <= 0; 
 /* End default assignments*/

				if(R) nextState<=DECODE;
				else nextState<= FETCH_AWAIT;
			end
			DECODE: begin //IR <- instruction
				GateMDR <= 1; LDIR <= 1; 
 
/* Begin default assignments */
MIOEN <= 0;  GatePC1 <= 0; LDVector <= 0; GateMARMUX <= 0; GatePC <= 0; LDSavedSSP <= 0; LDPriority <= 0; LDBEN <= 0; GateALU <= 0; GateSP <= 0; LDCC <= 0; GateVector <= 0; LDMAR <= 0; LDACV <= 0; LDPriv <= 0; LDPC <= 0; LDSavedUSP <= 0; GatePSR <= 0; LDMDR <= 0; PSRMUX <= 0; LDREG <= 0; 
 /* End default assignments*/

				nextState<=DECODE_INSTR;
			end
			DECODE_INSTR: begin //BEN<−IR[11] & N + IR[10] & Z + IR[9] & P[IR[15:12]]
				//BEN is continuously assigned from datapath.
				LDBEN <= 1;
/* Begin default assignments */
 MIOEN <= 0; GatePC1 <= 0; GateSP <= 0; LDMDR <= 0; GateMDR <= 0; GatePC <= 0; LDSavedUSP <= 0; LDSavedSSP <= 0; LDPriv <= 0; LDPC <= 0; GatePSR <= 0; PSRMUX <= 0; LDCC <= 0; LDVector <= 0; GateMARMUX <= 0; LDIR <= 0; LDACV <= 0; LDMAR <= 0; LDPriority <= 0; LDREG <= 0; GateVector <= 0; GateALU <= 0; 
 /* End default assignments*/
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
					`OPCODE_RTI		: 	nextState<=INSTR_RTI;
					`OPCODE_ST		: 	nextState<=INSTR_ST;
					`OPCODE_STI		: 	nextState<=INSTR_STI;
					`OPCODE_STR 	: 	nextState<=INSTR_STR;
					`OPCODE_TRAP	: 	nextState<=INSTR_TRAP;
					`OPCODE_RESERVED: 	nextState<=INSTR_RESERVED;
					default			: 	nextState<=START;
				endcase
					
			end
			INSTR_ADD: begin
				DRMUX <= `DRMUX_FIRST; SR1MUX <= `SR1MUX_SECOND; LDREG <= 1; LDCC<=1; GateALU <= 1; 
 
/* Begin default assignments */
 MIOEN <= 0; GateMDR <= 0; GatePC <= 0; GateVector <= 0; LDACV <= 0; LDMAR <= 0; LDPriority <= 0; GatePC1 <= 0; LDSavedSSP <= 0; GateSP <= 0; GateMARMUX <= 0; PSRMUX <= 0; LDPriv <= 0; LDBEN <= 0; LDIR <= 0; LDVector <= 0; LDSavedUSP <= 0; LDPC <= 0; GatePSR <= 0; LDMDR <= 0; 
 /* End default assignments*/

				nextState<= FETCH;
			end
			INSTR_AND: begin 
				DRMUX <= `DRMUX_FIRST; SR1MUX <= `SR1MUX_SECOND; LDREG <= 1; LDCC<=1; GateALU <= 1; 
 
/* Begin default assignments */
MIOEN <= 0; LDMDR <= 0; LDVector <= 0; LDSavedSSP <= 0; GateVector <= 0; GateMDR <= 0; PSRMUX <= 0; GatePC1 <= 0; GatePSR <= 0; LDSavedUSP <= 0; LDACV <= 0; LDMAR <= 0; GateSP <= 0; LDPC <= 0; LDIR <= 0; LDBEN <= 0; GatePC <= 0; LDPriv <= 0; GateMARMUX <= 0; LDPriority <= 0; 
 /* End default assignments*/

				nextState<= FETCH;
			end
			INSTR_NOT: begin 
				DRMUX <= `DRMUX_FIRST; SR1MUX <= `SR1MUX_SECOND; LDREG <= 1; LDCC<=1; GateALU <= 1; 
 
/* Begin default assignments */
 MIOEN <= 0; GateVector <= 0; GatePSR <= 0; LDACV <= 0; LDVector <= 0; LDPriv <= 0; LDBEN <= 0; GateSP <= 0; LDMDR <= 0; LDPriority <= 0; PSRMUX <= 0; LDSavedUSP <= 0; LDIR <= 0; GateMDR <= 0; GatePC1 <= 0; LDSavedSSP <= 0; GateMARMUX <= 0; LDMAR <= 0; GatePC <= 0; LDPC <= 0; 
 /* End default assignments*/

				nextState<= FETCH;
			end
			INSTR_LEA: begin //DR<−PC+off9
				//Use the MARMUX, and address adder
				DRMUX <= `DRMUX_FIRST; ADDR1MUX <= `ADDR1MUX_PC ; ADDR2MUX <= `ADDR2MUX_OFFSET_9; MARMUX <= `MARMUX_ADR_SUM; GateMARMUX <= 1; LDREG <= 1; 
 
/* Begin default assignments */
MIOEN <= 0;  LDCC <= 0; GateSP <= 0; LDSavedUSP <= 0; GateMDR <= 0; LDPriority <= 0; LDBEN <= 0; GateVector <= 0; LDACV <= 0; GatePC <= 0; LDMDR <= 0; LDPriv <= 0; GatePSR <= 0; LDSavedSSP <= 0; GateALU <= 0; PSRMUX <= 0; LDMAR <= 0; LDPC <= 0; LDIR <= 0; LDVector <= 0; GatePC1 <= 0; 
 /* End default assignments*/

				nextState <= FETCH;
			end
			INSTR_LD: begin //MAR<−PC+off9 , set ACV
				ADDR1MUX <= `ADDR1MUX_PC; ADDR2MUX <= `ADDR2MUX_OFFSET_9; MARMUX <= `MARMUX_ADR_SUM; GateMARMUX <= 1; LDMAR <= 1; LDACV <= 1; 
 
/* Begin default assignments */
MIOEN <= 0;  LDPC <= 0; LDVector <= 0; LDPriv <= 0; GatePC1 <= 0; GatePC <= 0; GatePSR <= 0; LDMDR <= 0; LDPriority <= 0; LDSavedSSP <= 0; LDIR <= 0; GateSP <= 0; PSRMUX <= 0; LDREG <= 0; LDCC <= 0; LDSavedUSP <= 0; GateALU <= 0; GateMDR <= 0; GateVector <= 0; LDBEN <= 0; 
 /* End default assignments*/

				nextState <= LOAD_CHECK_ACV;
			end
			
			INSTR_LDR: begin //MAR<-B+off6, set ACV
				ADDR1MUX <= `ADDR1MUX_SR1 ; ADDR2MUX <= `ADDR2MUX_OFFSET_6; SR1MUX <= `SR1MUX_SECOND; MARMUX <= `MARMUX_ADR_SUM; GateMARMUX <= 1; LDMAR <= 1; LDACV <= 1; 
 
/* Begin default assignments */
MIOEN <= 0;  LDREG <= 0; LDIR <= 0; LDPC <= 0; LDCC <= 0; PSRMUX <= 0; GateVector <= 0; GatePC <= 0; GatePC1 <= 0; GateALU <= 0; LDPriv <= 0; LDSavedUSP <= 0; GateSP <= 0; LDVector <= 0; GatePSR <= 0; GateMDR <= 0; LDPriority <= 0; LDMDR <= 0; LDSavedSSP <= 0; LDBEN <= 0; 
 /* End default assignments*/

				nextState <= LOAD_CHECK_ACV;
			end
			
			INSTR_LDI: begin //MAR <- PC+off9
				ADDR1MUX <= `ADDR1MUX_PC; ADDR2MUX <= `ADDR2MUX_OFFSET_9; MARMUX <= `MARMUX_ADR_SUM; GateMARMUX <= 1; LDMAR <= 1; LDACV <= 1; 
 
/* Begin default assignments */
MIOEN <= 0;  LDSavedSSP <= 0; LDCC <= 0; PSRMUX <= 0; GateMDR <= 0; GatePC1 <= 0; GateVector <= 0; LDVector <= 0; LDPriority <= 0; GateSP <= 0; LDSavedUSP <= 0; LDPriv <= 0; GatePC <= 0; LDIR <= 0; GatePSR <= 0; LDREG <= 0; LDPC <= 0; LDMDR <= 0; LDBEN <= 0; GateALU <= 0; 
 /* End default assignments*/

				nextState <= LDI_CHECK_ACV;
			end
			
			LDI_CHECK_ACV: begin //check ACV
 
/* Begin default assignments */
MIOEN <= 0;  LDACV <= 0; GatePSR <= 0; LDPC <= 0; GatePC1 <= 0; LDMDR <= 0; LDIR <= 0; GateALU <= 0; GateMDR <= 0; LDBEN <= 0; LDVector <= 0; LDSavedSSP <= 0; LDPriv <= 0; GatePC <= 0; GateVector <= 0; PSRMUX <= 0; LDCC <= 0; LDREG <= 0; LDSavedUSP <= 0; LDMAR <= 0; GateSP <= 0; GateMARMUX <= 0; LDPriority <= 0; 
 /* End default assignments*/

				if(ACV) nextState<=LDI_ACV;
				else nextState <= LDI_READ_MEM;
			end
			
			LDI_READ_MEM: begin //MDR<-M[MAR]
				LDMDR <= 1; MIOEN <= 1; 
 
/* Begin default assignments */
 LDPC <= 0; LDREG <= 0; LDCC <= 0; GateALU <= 0; LDSavedUSP <= 0; GatePC <= 0; GateMARMUX <= 0; GatePSR <= 0; LDACV <= 0; LDBEN <= 0; LDPriv <= 0; LDVector <= 0; LDPriority <= 0; LDIR <= 0; GatePC1 <= 0; PSRMUX <= 0; LDSavedSSP <= 0; LDMAR <= 0; GateSP <= 0; GateVector <= 0; GateMDR <= 0; 
 /* End default assignments*/

				if(R) nextState<=LDI_LATTER;
				else nextState<= LDI_READ_MEM;
			end		
			
			LDI_LATTER: begin //MAR <-MDR, set ACV
				LDMAR <= 1; GateMDR <= 1; LDACV <= 1; 
 
/* Begin default assignments */
MIOEN <= 0;  GatePC1 <= 0; GateVector <= 0; LDSavedSSP <= 0; GatePC <= 0; LDIR <= 0; GateMARMUX <= 0; LDMDR <= 0; PSRMUX <= 0; LDVector <= 0; LDPriority <= 0; LDBEN <= 0; GatePSR <= 0; LDPriv <= 0; LDREG <= 0; LDCC <= 0; LDPC <= 0; GateALU <= 0; GateSP <= 0; LDSavedUSP <= 0; 
 /* End default assignments*/

				nextState <= LOAD_CHECK_ACV;
			end

			LOAD_CHECK_ACV: begin // check ACV

 
/* Begin default assignments */
MIOEN <= 0;  LDBEN <= 0; LDPriority <= 0; LDPriv <= 0; LDIR <= 0; LDMAR <= 0; GateSP <= 0; GateVector <= 0; GateMARMUX <= 0; GatePC <= 0; LDREG <= 0; LDPC <= 0; GatePSR <= 0; LDMDR <= 0; GateALU <= 0; GatePC1 <= 0; LDSavedUSP <= 0; GateMDR <= 0; LDACV <= 0; PSRMUX <= 0; LDSavedSSP <= 0; LDCC <= 0; LDVector <= 0; 
 /* End default assignments*/

				if(ACV) nextState<=LOAD_ACV;
				else nextState <= LOAD_READ_MEM;
			end
			
			LOAD_READ_MEM: begin //MDR<-M[MAR]
				LDMDR <= 1; MIOEN <= 1; 
 
/* Begin default assignments */
 LDACV <= 0; GateMDR <= 0; LDPriority <= 0; LDVector <= 0; GateVector <= 0; GateSP <= 0; GatePC <= 0; GatePC1 <= 0; LDBEN <= 0; GateALU <= 0; LDREG <= 0; LDCC <= 0; PSRMUX <= 0; LDMAR <= 0; LDPC <= 0; LDSavedUSP <= 0; LDPriv <= 0; LDIR <= 0; LDSavedSSP <= 0; GatePSR <= 0; GateMARMUX <= 0; 
 /* End default assignments*/

				if(R) nextState<=LOAD_WRITE_REG;
				else nextState<= LOAD_READ_MEM;
			end	
			
			LOAD_WRITE_REG: begin //DR<-MDR, set CC 
				GateMDR <= 1; LDREG <= 1; DRMUX <= `DRMUX_FIRST; LDCC <= 1; 
 
/* Begin default assignments */
MIOEN <= 0;  GatePSR <= 0; LDACV <= 0; LDIR <= 0; GatePC1 <= 0; GateSP <= 0; GatePC <= 0; LDSavedUSP <= 0; LDMDR <= 0; LDMAR <= 0; LDVector <= 0; GateVector <= 0; GateALU <= 0; GateMARMUX <= 0; LDPriority <= 0; LDPC <= 0; LDBEN <= 0; LDSavedSSP <= 0; LDPriv <= 0; PSRMUX <= 0; 
 /* End default assignments*/

				nextState <= FETCH;
			end
			
			INSTR_ST: begin // MAR <- PC + off9, set ACV
				ADDR1MUX <= `ADDR1MUX_PC ; ADDR2MUX <= `ADDR2MUX_OFFSET_9; MARMUX <= `MARMUX_ADR_SUM; GateMARMUX <= 1; LDMAR <= 1; LDACV <= 1; 
 
/* Begin default assignments */
MIOEN <= 0;  GateSP <= 0; LDVector <= 0; LDMDR <= 0; GateALU <= 0; LDIR <= 0; PSRMUX <= 0; LDPriv <= 0; LDREG <= 0; LDPriority <= 0; GatePSR <= 0; GateMDR <= 0; LDBEN <= 0; GatePC1 <= 0; LDCC <= 0; LDSavedUSP <= 0; GateVector <= 0; GatePC <= 0; LDSavedSSP <= 0; LDPC <= 0; 
 /* End default assignments*/

				nextState <= STORE_CHECK_ACV;
			end
			
			INSTR_STR: begin //MAR <- B + off6
				ADDR1MUX <= `ADDR1MUX_SR1 ; ADDR2MUX <= `ADDR2MUX_OFFSET_6; SR1MUX <= `SR1MUX_SECOND; MARMUX <= `MARMUX_ADR_SUM; GateMARMUX <= 1; LDMAR <= 1; LDACV <= 1; 
 
/* Begin default assignments */
MIOEN <= 0;  LDSavedSSP <= 0; GateSP <= 0; GatePSR <= 0; GatePC1 <= 0; LDCC <= 0; LDVector <= 0; LDPriority <= 0; GateALU <= 0; GatePC <= 0; LDPC <= 0; LDBEN <= 0; LDPriv <= 0; GateVector <= 0; PSRMUX <= 0; LDIR <= 0; LDSavedUSP <= 0; LDMDR <= 0; GateMDR <= 0; LDREG <= 0; 
 /* End default assignments*/

				nextState <= STORE_CHECK_ACV;
			end
			
			INSTR_STI: begin // MAR<−PC+off9, set ACV
				ADDR1MUX <= `ADDR1MUX_PC; ADDR2MUX <= `ADDR2MUX_OFFSET_9; MARMUX <= `MARMUX_ADR_SUM; GateMARMUX <= 1; LDMAR <= 1; LDACV <= 1; 
 
/* Begin default assignments */
MIOEN <= 0;  GatePC <= 0; LDPC <= 0; GateVector <= 0; GateSP <= 0; LDBEN <= 0; LDCC <= 0; LDMDR <= 0; LDREG <= 0; GateMDR <= 0; LDPriv <= 0; LDSavedUSP <= 0; GateALU <= 0; PSRMUX <= 0; LDIR <= 0; GatePSR <= 0; GatePC1 <= 0; LDPriority <= 0; LDSavedSSP <= 0; LDVector <= 0; 
 /* End default assignments*/

				nextState <= STI_CHECK_ACV;
			end
				
			STI_CHECK_ACV: begin //check ACV

 
/* Begin default assignments */
MIOEN <= 0;  LDMAR <= 0; LDPriority <= 0; GatePC <= 0; GateALU <= 0; GatePSR <= 0; LDMDR <= 0; LDPriv <= 0; LDREG <= 0; GateMARMUX <= 0; PSRMUX <= 0; LDBEN <= 0; LDSavedSSP <= 0; LDIR <= 0; GatePC1 <= 0; LDSavedUSP <= 0; LDACV <= 0; GateSP <= 0; LDVector <= 0; LDPC <= 0; GateVector <= 0; LDCC <= 0; GateMDR <= 0; 
 /* End default assignments*/

				if(ACV) nextState<=STI_ACV;
				else nextState <= STI_READ_MEM;
			end
			
			STI_READ_MEM: begin //MDR <-M[MAR]
				LDMDR <= 1; MIOEN <= 1; 
 
/* Begin default assignments */
 GateSP <= 0; LDMAR <= 0; LDSavedUSP <= 0; LDVector <= 0; GatePC <= 0; GatePSR <= 0; GateMARMUX <= 0; LDIR <= 0; GateALU <= 0; LDSavedSSP <= 0; LDCC <= 0; LDBEN <= 0; GatePC1 <= 0; GateVector <= 0; LDPC <= 0; LDPriority <= 0; PSRMUX <= 0; LDACV <= 0; LDREG <= 0; LDPriv <= 0; GateMDR <= 0; 
 /* End default assignments*/

				if(R) nextState<=STI_LATTER;
				else nextState<= STI_READ_MEM;
			end
			
			STI_LATTER: begin // MAR<-MDR, set ACV
				LDMAR <= 1; GateMDR <= 1; LDACV <= 1; 
 
/* Begin default assignments */
MIOEN <= 0;  LDREG <= 0; GatePSR <= 0; LDMDR <= 0; GateALU <= 0; PSRMUX <= 0; LDIR <= 0; GateVector <= 0; LDBEN <= 0; GatePC1 <= 0; GateSP <= 0; GateMARMUX <= 0; LDPriv <= 0; LDSavedUSP <= 0; LDSavedSSP <= 0; GatePC <= 0; LDVector <= 0; LDCC <= 0; LDPriority <= 0; LDPC <= 0; 
 /* End default assignments*/

				nextState <= STORE_CHECK_ACV;
			end
			
			STORE_CHECK_ACV: begin // MDR <- SR, check ACV
				LDMDR <= 1; MIOEN <= 0; SR1MUX <= `SR1MUX_FIRST; ADDR1MUX <= `ADDR1MUX_SR1; ADDR2MUX <= `ADDR2MUX_OFFSET_0; GateMARMUX <= 1; 
 
/* Begin default assignments */
 GateVector <= 0; LDSavedSSP <= 0; LDBEN <= 0; LDACV <= 0; LDVector <= 0; LDPriv <= 0; LDREG <= 0; LDCC <= 0; GatePSR <= 0; PSRMUX <= 0; GateSP <= 0; LDMAR <= 0; LDSavedUSP <= 0; LDPC <= 0; GatePC1 <= 0; LDPriority <= 0; LDIR <= 0; GateMDR <= 0; GatePC <= 0; GateALU <= 0; 
 /* End default assignments*/

				if(ACV) nextState<=STORE_ACV;
				else nextState<= STORE_WRITE_MEM;
			end
			
			STORE_WRITE_MEM: begin //M[MAR]<-MDR
				RW <= 1; 
 
/* Begin default assignments */
MIOEN <= 0;  GateMDR <= 0; GatePC <= 0; GateMARMUX <= 0; GatePSR <= 0; LDCC <= 0; LDIR <= 0; LDPriv <= 0; LDMDR <= 0; LDSavedSSP <= 0; LDACV <= 0; PSRMUX <= 0; LDMAR <= 0; GateSP <= 0; LDBEN <= 0; LDSavedUSP <= 0; LDPC <= 0; LDREG <= 0; GateALU <= 0; GatePC1 <= 0; GateVector <= 0; LDVector <= 0; LDPriority <= 0; 
 /* End default assignments*/

				if(R) nextState<= FETCH;
				else nextState<= STORE_WRITE_MEM;
			end
			
			INSTR_BR: begin // check BEN
				if(BEN) nextState <= BRANCH_EXECUTE;
				else nextState <= FETCH;
/* Begin default assignments */
MIOEN <= 0;  GatePC1 <= 0; LDSavedSSP <= 0; LDSavedUSP <= 0; PSRMUX <= 0; GatePSR <= 0; LDMAR <= 0; LDVector <= 0; LDMDR <= 0; LDPriv <= 0; GateSP <= 0; GateMDR <= 0; LDCC <= 0; LDBEN <= 0; GateMARMUX <= 0; LDPriority <= 0; LDACV <= 0; GateALU <= 0; LDIR <= 0; LDREG <= 0; GatePC <= 0; GateVector <= 0; 
 /* End default assignments*/
			end
			
			BRANCH_EXECUTE: begin // PC <= PC + off9
				LDPC <= 1; PCMUX <= `PCMUX_ADDR; ADDR1MUX <= `ADDR1MUX_PC; ADDR2MUX <= `ADDR2MUX_OFFSET_9; 
 
/* Begin default assignments */
MIOEN <= 0;  GatePC1 <= 0; LDSavedSSP <= 0; LDSavedUSP <= 0; PSRMUX <= 0; GatePSR <= 0; LDMAR <= 0; LDVector <= 0; LDMDR <= 0; LDPriv <= 0; GateSP <= 0; GateMDR <= 0; LDCC <= 0; LDBEN <= 0; GateMARMUX <= 0; LDPriority <= 0; LDACV <= 0; GateALU <= 0; LDIR <= 0; LDREG <= 0; GatePC <= 0; GateVector <= 0; 
 /* End default assignments*/

				nextState <= FETCH;
			end
			
			INSTR_JMP: begin // PC <= BaseR
				LDPC <= 1; PCMUX <= `PCMUX_ADDR; SR1MUX <= `SR1MUX_SECOND; ADDR1MUX <= `ADDR1MUX_SR1; ADDR2MUX <= `ADDR2MUX_OFFSET_0; 
 
/* Begin default assignments */
 MIOEN <= 0; LDPriority <= 0; GateMDR <= 0; GatePSR <= 0; LDSavedUSP <= 0; LDMAR <= 0; PSRMUX <= 0; LDCC <= 0; GatePC1 <= 0; LDIR <= 0; LDPriv <= 0; LDSavedSSP <= 0; LDMDR <= 0; LDACV <= 0; GateALU <= 0; GateSP <= 0; LDVector <= 0; LDREG <= 0; LDBEN <= 0; GatePC <= 0; GateVector <= 0; GateMARMUX <= 0; 
 /* End default assignments*/

				nextState <= FETCH;
			end
			
			INSTR_JSR: begin // JSR or JSRR (imm or reg)
				if(instruction[11]) nextState <= JSR_IMM;
				else nextState <= JSR_REG;
			end
			
			JSR_REG: begin // R7 <= PC. PC <= PC + baseR
				DRMUX <= `DRMUX_SEVEN; LDREG <= 1; GatePC <= 1; LDPC <= 1; PCMUX <= `PCMUX_ADDR; SR1MUX <= `SR1MUX_SECOND; ADDR1MUX <= `ADDR1MUX_SR1; ADDR2MUX <= `ADDR2MUX_OFFSET_0; 
 
/* Begin default assignments */
MIOEN <= 0;  LDVector <= 0; LDBEN <= 0; LDCC <= 0; LDPriv <= 0; GateALU <= 0; LDMAR <= 0; GatePC1 <= 0; PSRMUX <= 0; LDIR <= 0; GatePSR <= 0; GateMDR <= 0; LDMDR <= 0; LDPriority <= 0; GateVector <= 0; GateSP <= 0; LDSavedSSP <= 0; GateMARMUX <= 0; LDSavedUSP <= 0; LDACV <= 0; 
 /* End default assignments*/

				nextState <= FETCH;
			end
			
			JSR_IMM: begin // R7 <= PC. PC <= PC + off11
				DRMUX <= `DRMUX_SEVEN; LDREG <= 1; GatePC <= 1; LDPC <= 1; PCMUX <= `PCMUX_ADDR; ADDR1MUX <= `ADDR1MUX_PC; ADDR2MUX <= `ADDR2MUX_OFFSET_11; 
 
/* Begin default assignments */
MIOEN <= 0;  LDIR <= 0; LDSavedSSP <= 0; PSRMUX <= 0; LDCC <= 0; GatePSR <= 0; LDMAR <= 0; LDBEN <= 0; GatePC1 <= 0; LDPriv <= 0; GateALU <= 0; GateSP <= 0; LDMDR <= 0; LDSavedUSP <= 0; GateVector <= 0; LDVector <= 0; GateMARMUX <= 0; LDACV <= 0; GateMDR <= 0; LDPriority <= 0; 
 /* End default assignments*/

				nextState <= FETCH;
			end
			
			INSTR_RTI: begin // MAR <- SP. [PSR[15]]
				MARMUX <= `MARMUX_ADR_SUM; LDMAR <= 1; ADDR1MUX <= `ADDR1MUX_SR1; ADDR2MUX <= `ADDR2MUX_OFFSET_0; SR1MUX <= `SR1MUX_SIX; 
 
/* Begin default assignments */
MIOEN <= 0;  PSRMUX <= 0; LDMDR <= 0; LDIR <= 0; GateVector <= 0; LDREG <= 0; LDCC <= 0; LDPriority <= 0; GateSP <= 0; GatePSR <= 0; LDPC <= 0; GateMARMUX <= 0; GatePC1 <= 0; LDSavedUSP <= 0; GateMDR <= 0; LDPriv <= 0; GateALU <= 0; LDBEN <= 0; LDSavedSSP <= 0; LDACV <= 0; GatePC <= 0; LDVector <= 0; 
 /* End default assignments*/

				if(PSR[15]) nextState <= RTI_EXCEPTION;
				else nextState <= RTI_FETCH_PC;
			end
			
			RTI_FETCH_PC: begin // MDR <- M
				GateMARMUX <= 1; LDMDR <= 1; MIOEN <= 1; 
 
/* Begin default assignments */
 LDACV <= 0; LDCC <= 0; LDVector <= 0; GateVector <= 0; GatePC1 <= 0; LDSavedUSP <= 0; GateALU <= 0; LDPC <= 0; LDBEN <= 0; GatePC <= 0; GatePSR <= 0; LDIR <= 0; LDMAR <= 0; LDREG <= 0; GateSP <= 0; GateMDR <= 0; LDPriority <= 0; PSRMUX <= 0; LDPriv <= 0; LDSavedSSP <= 0; 
 /* End default assignments*/

				if(R) nextState<=RTI_LOAD_PC;
				else nextState<= RTI_FETCH_PC;
			end
			
			RTI_LOAD_PC: begin //PC <- MDR
				GateMARMUX <= 0; LDMDR <= 0; MIOEN <= 0; //Disable
				LDPC <= 1; PCMUX <= `PCMUX_BUS; GateMDR <= 1; 
				nextState <= RTI_INC_R6;
/* Begin default assignments */
 LDACV <= 0; LDCC <= 0; LDVector <= 0; GateVector <= 0; GatePC1 <= 0; LDSavedUSP <= 0; GateALU <= 0; LDPC <= 0; LDBEN <= 0; GatePC <= 0; GatePSR <= 0; LDIR <= 0; LDMAR <= 0; LDREG <= 0; GateSP <= 0; GateMDR <= 0; LDPriority <= 0; PSRMUX <= 0; LDPriv <= 0; LDSavedSSP <= 0; 
 /* End default assignments*/				
			end
			
			RTI_INC_R6: begin // MAR <- SP + 1.  SP <- SP + 1
				DRMUX <= `DRMUX_SIX; SR1MUX <= `SR1MUX_SIX; SPMUX <= `SPMUX_INC; LDREG <= 1; GateSP <= 1; 
 
/* Begin default assignments */
 MIOEN <= 0;GatePC <= 0; LDSavedUSP <= 0; GatePC1 <= 0; LDBEN <= 0; GateMDR <= 0; LDPriv <= 0; LDPriority <= 0; GatePSR <= 0; LDMDR <= 0; LDVector <= 0; LDMAR <= 0; GateALU <= 0; LDPC <= 0; GateMARMUX <= 0; LDACV <= 0; PSRMUX <= 0; LDCC <= 0; LDSavedSSP <= 0; GateVector <= 0; LDIR <= 0; 
 /* End default assignments*/

				nextState <= RTI_FETCH_PSR;
			end
			
			RTI_FETCH_PSR: begin // MDR <- M
				GateMARMUX <= 1; LDMDR <= 1; MIOEN <= 1; 
 
/* Begin default assignments */
 GatePC1 <= 0; GateMDR <= 0; LDSavedSSP <= 0; LDVector <= 0; LDPC <= 0; LDSavedUSP <= 0; LDMAR <= 0; GateVector <= 0; LDPriv <= 0; GateSP <= 0; LDACV <= 0; LDIR <= 0; LDREG <= 0; GateALU <= 0; PSRMUX <= 0; LDCC <= 0; LDBEN <= 0; GatePC <= 0; LDPriority <= 0; GatePSR <= 0; 
 /* End default assignments*/

				if(R) nextState<=RTI_LOAD_PSR;
				else nextState<= RTI_FETCH_PSR;
			end
			
			RTI_LOAD_PSR: begin //PSR <- MDR				
				PSRMUX <= `PSRMUX_Databus; GateMDR <= 1; 
 
/* Begin default assignments */
MIOEN <= 0; LDIR <= 0; LDPC <= 0; LDBEN <= 0; GateMARMUX <= 0; LDPriority <= 0; GateSP <= 0; LDMAR <= 0; LDVector <= 0; LDSavedUSP <= 0; GatePSR <= 0; LDACV <= 0; LDMDR <= 0; LDREG <= 0; LDCC <= 0; LDPriv <= 0; LDSavedSSP <= 0; GateVector <= 0; GatePC <= 0; GatePC1 <= 0; GateALU <= 0; 
 /* End default assignments*/

				nextState <= RTI_CHECK_MODE;
			end
			
			RTI_CHECK_MODE: begin //SP <- SP + 1, [PSR[15]]
				DRMUX <= `DRMUX_SIX; SR1MUX <= `SR1MUX_SIX; SPMUX <= `SPMUX_INC; LDREG <= 1; GateSP <= 1; 
 
/* Begin default assignments */
MIOEN <= 0; LDSavedSSP <= 0; GateALU <= 0; GateVector <= 0; LDCC <= 0; LDMAR <= 0; LDPC <= 0; GateMDR <= 0; LDMDR <= 0; LDPriority <= 0; GateMARMUX <= 0; GatePSR <= 0; LDBEN <= 0; GatePC <= 0; LDIR <= 0; LDVector <= 0; PSRMUX <= 0; LDACV <= 0; LDPriv <= 0; GatePC1 <= 0; LDSavedUSP <= 0; 
 /* End default assignments*/

				if(PSR[15]) nextState <= RTI_USER;
				else nextState <= RTI_SUPER;
			end
			
			RTI_USER: begin //Saved_SSP <- SP. SP <- Saved_USP
				LDSavedSSP <= 1; DRMUX <= `DRMUX_SIX; SR1MUX <= `SR1MUX_SIX; SPMUX <= `SPMUX_USP; GateSP <= 1; LDREG <= 1; 
 
/* Begin default assignments */
 MIOEN <= 0;LDSavedUSP <= 0; LDVector <= 0; GatePC1 <= 0; GatePC <= 0; LDACV <= 0; PSRMUX <= 0; GateVector <= 0; LDPriv <= 0; LDCC <= 0; GateALU <= 0; LDPriority <= 0; LDPC <= 0; LDMAR <= 0; GateMARMUX <= 0; LDMDR <= 0; LDBEN <= 0; LDIR <= 0; GateMDR <= 0; GatePSR <= 0; 
 /* End default assignments*/

				nextState <= FETCH;
			end
			
			RTI_SUPER: begin //nothing

 
/* Begin default assignments */
MIOEN <= 0; LDMAR <= 0; GatePSR <= 0; LDMDR <= 0; GateMARMUX <= 0; LDSavedUSP <= 0; GateMDR <= 0; GatePC <= 0; LDPriv <= 0; LDSavedSSP <= 0; GateVector <= 0; GatePC1 <= 0; LDIR <= 0; LDPC <= 0; LDACV <= 0; LDCC <= 0; LDPriority <= 0; GateALU <= 0; LDBEN <= 0; LDVector <= 0; PSRMUX <= 0; GateSP <= 0; LDREG <= 0; 
 /* End default assignments*/

				nextState <= FETCH;
			end
			
			RTI_EXCEPTION: begin // Table = 1, Vector = 0, MDR = PSR, PSR[15] = 0
TableMUX <= `TableMUX_1; LDVector <= 1; VectorMUX <= `VectorMUX_0; GatePSR <= 1; LDMDR <= 1; LDPriv <= 1; SETPRIV <= 0; PSRMUX <= `PSRMUX_Databus; 
 
/* Begin default assignments */
MIOEN <= 0; LDPriority <= 0; GateALU <= 0; GateVector <= 0; GateMDR <= 0; GatePC1 <= 0; LDIR <= 0; LDSavedSSP <= 0; LDBEN <= 0; LDSavedUSP <= 0; LDMAR <= 0; GateSP <= 0; GatePC <= 0; LDCC <= 0; GateMARMUX <= 0; LDACV <= 0; LDPC <= 0; LDREG <= 0; 
 /* End default assignments*/

				nextState <= SWITCH_SP;
				
			end
			
			INSTR_TRAP: begin //Table <- 0, PC +1, MDR <- PSR
TableMUX <= `TableMUX_0; PCMUX <= `PCMUX_INC; LDPC <= 1; GatePSR <= 1; LDMDR <= 1; LDVector <= 1; 
 
/* Begin default assignments */
MIOEN <= 0; LDCC <= 0; LDIR <= 0; PSRMUX <= 0; GateSP <= 0; LDSavedUSP <= 0; LDPriority <= 0; GatePC <= 0; GateVector <= 0; GatePC1 <= 0; LDREG <= 0; LDMAR <= 0; GateMARMUX <= 0; LDACV <= 0; LDPriv <= 0; LDBEN <= 0; GateMDR <= 0; GateALU <= 0; LDSavedSSP <= 0; 
 /* End default assignments*/

				nextState <= TRAP_VECTOR;
			end
		
			
			TRAP_VECTOR: begin //Vector <- IR[7:0], Priv = 0, check priv.
SETPRIV <= 0; LDPriv <= 1; MARMUX <= `MARMUX_INSTR; LDVector <= 1; TableMUX <= `TableMUX_0; 
 
/* Begin default assignments */
MIOEN <= 0; GateSP <= 0; PSRMUX <= 0; LDMAR <= 0; LDBEN <= 0; LDIR <= 0; GatePC <= 0; LDMDR <= 0; GateMARMUX <= 0; GateALU <= 0; LDPC <= 0; LDSavedSSP <= 0; GatePSR <= 0; GateMDR <= 0; LDREG <= 0; GatePC1 <= 0; LDACV <= 0; LDCC <= 0; GateVector <= 0; LDPriority <= 0; LDSavedUSP <= 0; 
 /* End default assignments*/

				if(PSR[15]) nextState <= SWITCH_SP;
				else nextState <= PUSH_PSR_0;
			end
			
			INSTR_RESERVED: begin // Table <- 1, Vector <- 1, MDR <- PSR, PSR[15] <- 0, [PSR[15]]
TableMUX <= `TableMUX_1; VectorMUX <= `VectorMUX_1; LDMDR <= 1; GatePSR <= 1; SETPRIV <= 0; LDPriv <= 1; PSRMUX <= `PSRMUX_Individual; 
 
/* Begin default assignments */
MIOEN <= 0; LDACV <= 0; GateMARMUX <= 0; LDCC <= 0; LDVector <= 0; LDSavedSSP <= 0; LDSavedUSP <= 0; GatePC1 <= 0; LDMAR <= 0; LDPriority <= 0; GateMDR <= 0; LDBEN <= 0; GateALU <= 0; LDPC <= 0; GateVector <= 0; LDIR <= 0; GatePC <= 0; LDREG <= 0; GateSP <= 0; 
 /* End default assignments*/
				if(PSR[15]) nextState <= SWITCH_SP;
				else nextState <= PUSH_PSR_0;
			end
			
			INTERRUPT: begin  // Table <- 1, Vector <- INTV, PSR[10:8] <- Priority, MDR <- PSR, PSR[15] <- 0, [PSR[15]]
TableMUX <= `TableMUX_1; VectorMUX <= `VectorMUX_INTV; LDPriority <= 1; LDMDR <= 1; GatePSR <= 1; SETPRIV <= 0; LDPriv <= 1; PSRMUX <= `PSRMUX_Individual; 
 
/* Begin default assignments */
MIOEN <= 0; LDSavedSSP <= 0; GatePC1 <= 0; LDMAR <= 0; GateSP <= 0; LDSavedUSP <= 0; LDPC <= 0; LDBEN <= 0; LDIR <= 0; GateMARMUX <= 0; LDVector <= 0; GateVector <= 0; GateALU <= 0; GateMDR <= 0; LDCC <= 0; LDACV <= 0; LDREG <= 0; GatePC <= 0; 
 /* End default assignments*/
				if(PSR[15]) nextState <= SWITCH_SP;
				else nextState <= PUSH_PSR_0;
			end
			
			
			SWITCH_SP: begin //Saved_SSP <-sp, sp <- Saved_USP
LDSavedSSP <= 1; DRMUX <= `DRMUX_SIX; SR1MUX <= `SR1MUX_SIX; SPMUX <= `SPMUX_USP; GateSP <= 1; LDREG <= 1; 
 
/* Begin default assignments */
MIOEN <= 0; LDACV <= 0; GateMDR <= 0; PSRMUX <= 0; GatePC1 <= 0; GatePSR <= 0; GateMARMUX <= 0; LDCC <= 0; GatePC <= 0; LDBEN <= 0; LDPC <= 0; LDPriv <= 0; LDMAR <= 0; LDVector <= 0; LDPriority <= 0; GateALU <= 0; LDMDR <= 0; LDIR <= 0; GateVector <= 0; LDSavedUSP <= 0; 
 /* End default assignments*/

				nextState <= PUSH_PSR_0;
			end
			
			PUSH_PSR_0: begin //MAR, SP <- SP-1
SPMUX <= `SPMUX_DEC; GateSP <= 1; LDREG <= 1; LDMAR <= 1; 
 
/* Begin default assignments */
 MIOEN <= 0;LDSavedUSP <= 0; LDCC <= 0; LDBEN <= 0; PSRMUX <= 0; GatePC <= 0; GateMDR <= 0; GatePSR <= 0; GatePC1 <= 0; LDPriv <= 0; LDMDR <= 0; GateALU <= 0; LDPC <= 0; LDPriority <= 0; GateVector <= 0; LDACV <= 0; LDVector <= 0; LDIR <= 0; LDSavedSSP <= 0; GateMARMUX <= 0; 
 /* End default assignments*/
				nextState <= PUSH_PSR_1	;
			end
			
			PUSH_PSR_1: begin // M[MAR] < MDR
MIOEN <= 1; 
 
/* Begin default assignments */
 PSRMUX <= 0; LDBEN <= 0; LDCC <= 0; LDMAR <= 0; LDSavedUSP <= 0; GatePSR <= 0; GateMDR <= 0; GateALU <= 0; GateVector <= 0; LDPriority <= 0; GatePC <= 0; GateSP <= 0; LDMDR <= 0; LDACV <= 0; GateMARMUX <= 0; LDREG <= 0; LDIR <= 0; LDPriv <= 0; LDVector <= 0; GatePC1 <= 0; LDSavedSSP <= 0; LDPC <= 0; 
 /* End default assignments*/
				if(R) nextState <= PUSH_PC_0;
				else nextState <= PUSH_PSR_1;
			end
			
			PUSH_PC_0: begin // MDR <- PC-1
GatePC1 <= 1; LDMDR <= 1; 
 
/* Begin default assignments */
MIOEN <= 0; PSRMUX <= 0; LDBEN <= 0; LDPC <= 0; LDSavedUSP <= 0; GateSP <= 0; LDREG <= 0; GateVector <= 0; LDSavedSSP <= 0; GateMDR <= 0; LDVector <= 0; LDCC <= 0; LDPriority <= 0; GatePSR <= 0; LDACV <= 0; LDIR <= 0; LDPriv <= 0; GatePC <= 0; GateALU <= 0; GateMARMUX <= 0; LDMAR <= 0; 
 /* End default assignments*/
				nextState <= PUSH_PC_1;
			end
			
			PUSH_PC_1: begin // MAR, SP <- SP-1	
DRMUX <= `DRMUX_SIX; SR1MUX <= `SR1MUX_SIX; SPMUX <= `SPMUX_DEC; LDREG <= 1; GateSP <= 1; 
 
/* Begin default assignments */
MIOEN <= 0; LDBEN <= 0; GatePC1 <= 0; PSRMUX <= 0; LDACV <= 0; LDCC <= 0; LDMDR <= 0; LDPriority <= 0; LDMAR <= 0; GateMDR <= 0; GateVector <= 0; LDVector <= 0; GatePSR <= 0; LDSavedUSP <= 0; GateMARMUX <= 0; GatePC <= 0; LDPriv <= 0; LDPC <= 0; LDIR <= 0; GateALU <= 0; LDSavedSSP <= 0; 
 /* End default assignments*/
				nextState <= PUSH_PC_2;
			end
			
			PUSH_PC_2: begin // M[MAR] < MDR
MIOEN <= 1; 
 
/* Begin default assignments */
 LDIR <= 0; LDMAR <= 0; GateMARMUX <= 0; GatePC <= 0; GatePC1 <= 0; LDMDR <= 0; LDVector <= 0; GateMDR <= 0; LDBEN <= 0; LDSavedUSP <= 0; LDREG <= 0; LDACV <= 0; GateVector <= 0; GateSP <= 0; GateALU <= 0; LDPC <= 0; LDSavedSSP <= 0; LDPriority <= 0; PSRMUX <= 0; LDCC <= 0; GatePSR <= 0; LDPriv <= 0; 
 /* End default assignments*/
				if(R) nextState <= VECTOR_REFERENCE;
				else nextState <= PUSH_PC_2;
			end
			
			VECTOR_REFERENCE: begin //MAR <- table,Vector
GateVector <= 1; LDMAR <= 1; 
 
/* Begin default assignments */
 MIOEN <= 0;GateMDR <= 0; LDIR <= 0; GateMARMUX <= 0; LDSavedSSP <= 0; GateSP <= 0; LDBEN <= 0; LDACV <= 0; LDSavedUSP <= 0; LDPC <= 0; LDPriv <= 0; LDREG <= 0; GatePSR <= 0; GateALU <= 0; PSRMUX <= 0; LDPriority <= 0; LDCC <= 0; LDMDR <= 0; LDVector <= 0; GatePC1 <= 0; GatePC <= 0; 
 /* End default assignments*/
				nextState <= VECTOR_READ;
			end
			
			VECTOR_READ: begin // MDR <- M
LDMDR <= 1; MIOEN <= 1; 
 
/* Begin default assignments */
 GatePSR <= 0; LDVector <= 0; LDPriv <= 0; GateVector <= 0; LDCC <= 0; GatePC <= 0; LDMAR <= 0; GateMARMUX <= 0; LDREG <= 0; LDSavedSSP <= 0; LDBEN <= 0; LDPC <= 0; LDIR <= 0; PSRMUX <= 0; LDPriority <= 0; GateMDR <= 0; GatePC1 <= 0; LDACV <= 0; GateSP <= 0; GateALU <= 0; LDSavedUSP <= 0; 
 /* End default assignments*/
				if(R) nextState <= VECTOR_JUMP;
				else nextState <= VECTOR_READ;
			end
			
			VECTOR_READ: begin //PC <- MDR
LDPC <= 1; GateMDR <= 1; PCMUX <= `PCMUX_BUS; 
 
/* Begin default assignments */
 MIOEN <= 0;LDPriv <= 0; LDMDR <= 0; LDSavedSSP <= 0; GatePC1 <= 0; LDBEN <= 0; GateMARMUX <= 0; GateALU <= 0; PSRMUX <= 0; LDACV <= 0; LDREG <= 0; LDVector <= 0; GateSP <= 0; GatePSR <= 0; LDIR <= 0; LDSavedUSP <= 0; GatePC <= 0; LDMAR <= 0; LDPriority <= 0; GateVector <= 0; LDCC <= 0; 
 /* End default assignments*/
				nextState <= FETCH;
			end
			
			FETCH_ACV: begin // Table <- 1, Vector <- 2, MDR <- PSR, PSR[15] <- 0,
TableMUX <= `TableMUX_1; VectorMUX <= `VectorMUX_2; LDMDR <= 1; GatePSR <= 1; SETPRIV <= 0; LDPriv <= 1; PSRMUX <= `PSRMUX_Individual; 
 
/* Begin default assignments */
 MIOEN <= 0;GateALU <= 0; GateVector <= 0; LDBEN <= 0; LDCC <= 0; GatePC <= 0; LDIR <= 0; LDSavedUSP <= 0; LDREG <= 0; GateMDR <= 0; GatePC1 <= 0; LDPriority <= 0; LDSavedSSP <= 0; LDPC <= 0; LDVector <= 0; LDMAR <= 0; LDACV <= 0; GateSP <= 0; GateMARMUX <= 0; 
 /* End default assignments*/
				nextState <= SWITCH_SP;
			end
				
			LOAD_ACV: begin // Table <- 1, Vector <- 2, MDR <- PSR, PSR[15] <- 0,
TableMUX <= `TableMUX_1; VectorMUX <= `VectorMUX_2; LDMDR <= 1; GatePSR <= 1; SETPRIV <= 0; LDPriv <= 1; PSRMUX <= `PSRMUX_Individual; 
 
/* Begin default assignments */
MIOEN <= 0; GateMARMUX <= 0; GateVector <= 0; LDVector <= 0; LDPC <= 0; LDREG <= 0; LDIR <= 0; LDSavedSSP <= 0; GateSP <= 0; GateALU <= 0; LDMAR <= 0; LDACV <= 0; LDPriority <= 0; GatePC <= 0; LDSavedUSP <= 0; GatePC1 <= 0; GateMDR <= 0; LDBEN <= 0; LDCC <= 0; 
 /* End default assignments*/
				nextState <= SWITCH_SP;
			end
			
			LDI_ACV: begin // Table <- 1, Vector <- 2, MDR <- PSR, PSR[15] <- 0,
TableMUX <= `TableMUX_1; VectorMUX <= `VectorMUX_2; LDMDR <= 1; GatePSR <= 1; SETPRIV <= 0; LDPriv <= 1; PSRMUX <= `PSRMUX_Individual; 
 
/* Begin default assignments */
MIOEN <= 0; GatePC1 <= 0; GateMDR <= 0; LDMAR <= 0; LDBEN <= 0; GatePC <= 0; LDREG <= 0; LDPC <= 0; GateSP <= 0; GateALU <= 0; LDIR <= 0; LDCC <= 0; LDVector <= 0; LDPriority <= 0; GateVector <= 0; GateMARMUX <= 0; LDACV <= 0; LDSavedUSP <= 0; LDSavedSSP <= 0; 
 /* End default assignments*/
				nextState <= SWITCH_SP;
			end
			
			STORE_ACV: begin // Table <- 1, Vector <- 2, MDR <- PSR, PSR[15] <- 0,
TableMUX <= `TableMUX_1; VectorMUX <= `VectorMUX_2; LDMDR <= 1; GatePSR <= 1; SETPRIV <= 0; LDPriv <= 1; PSRMUX <= `PSRMUX_Individual; 
 
/* Begin default assignments */
 LDSavedSSP <= 0; GatePC <= 0; GateMARMUX <= 0; LDSavedUSP <= 0; GateVector <= 0; GateALU <= 0; LDPriority <= 0; LDPC <= 0; GatePC1 <= 0; LDVector <= 0; LDBEN <= 0; LDCC <= 0; LDACV <= 0; LDREG <= 0; LDIR <= 0; GateSP <= 0; LDMAR <= 0; GateMDR <= 0; 
MIOEN <= 0; /* End default assignments*/
				nextState <= SWITCH_SP;
			end
			
			STI_ACV: begin // Table <- 1, Vector <- 2, MDR <- PSR, PSR[15] <- 0,
			
TableMUX <= `TableMUX_1; VectorMUX <= `VectorMUX_2; LDMDR <= 1; GatePSR <= 1; SETPRIV <= 0; LDPriv <= 1; PSRMUX <= `PSRMUX_Individual; 
 
/* Begin default assignments */
MIOEN <= 0; LDMAR <= 0; LDSavedSSP <= 0; GatePC <= 0; LDIR <= 0; GateSP <= 0; GateALU <= 0; LDVector <= 0; GateMARMUX <= 0; LDREG <= 0; LDPC <= 0; LDBEN <= 0; LDSavedUSP <= 0; LDCC <= 0; GateMDR <= 0; GatePC1 <= 0; LDACV <= 0; LDPriority <= 0; GateVector <= 0; 
 /* End default assignments*/
				nextState <= SWITCH_SP;
			end
			
			START: begin
				nextState<=FETCH;
			end
			
			default:begin
				LDMAR <= 0; LDMDR <= 0; LDIR <= 0; LDBEN <= 0; LDREG <= 0; LDCC <= 0; LDPC <= 0; 
				LDPriv <= 0; LDPriority <= 0; LDSavedSSP <= 0; LDSavedUSP <= 0; LDACV <= 0; LDVector <= 0; 
				GatePC <= 0; GateMDR <= 0; GateALU <= 0; GateMARMUX <= 0; GateVector <= 0; GatePC1 <= 0; GatePSR <= 0; GateSP <= 0; 
				PCMUX <= 0; DRMUX <= 0; SR1MUX <= 0; ADDR2MUX <= 0; SPMUX <= 0; VectorMUX <= 0; ADDR1MUX <= 0; MARMUX <= 0; TableMUX <= 0; PSRMUX <= 0; 
				MIOEN <= 0; RW <= 0; SETPRIV <= 0;
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
			MIOEN <= 0; RW <= 0; SETPRIV <= 0;
		end else begin
			currentState <= nextState;
		end
		
	end
	
//"LDMAR",  "LDMAR",  "LDMDR",  "LDIR",  "LDBEN",  "LDREG",  "LDCC",  "LDPC",  "LDPriv",  "LDPriority",  "LDSavedSSP",  "LDSavedUSP",  "LDACV", "LDVector",  "GatePC",  "GateMDR",  "GateALU", "GateMARMUX",  "GateVector",  "GatePC1",  "GatePSR",  "GateSP",  "PSRMUX"	
	
	
endmodule
 
 

				