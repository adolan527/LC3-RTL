`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2/27/2025 
// Design Name: 
// Module Name: control store
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

module controlStore(
	input[5:0] index,
	
	//Micro sequencer signals
	output reg[5:0] J,
	output reg[2:0] COND,
	output reg IRD,
	
	output reg LDMAR, LDMDR, LDIR, LDBEN, LDREG, LDCC, LDPC, LDPriv, LDPriority, LDSavedSSP, LDSavedUSP, LDACV, LDVector, //42 output bits
	output reg GatePC, GateMDR, GateALU, GateMARMUX, GateVector, GatePC1, GatePSR, GateSP,
	output reg [1:0] PCMUX, DRMUX, SR1MUX, ADDR2MUX, SPMUX, VectorMUX,
	output reg ADDR1MUX, MARMUX, TableMUX, PSRMUX,
	output reg MIOEN, RW, SETPRIV //memory IO enable, Read/Write enable, Set privilege. PRIV = 0 -> S, PRIV = 1 -> U
	
	);
	
	
	localparam FETCH 			= 6'd18; //Main fetch state.
	localparam FETCH_CHECK_ACV 	= 6'd33; //access control violation check after fetch
	localparam FETCH_AWAIT 		= 6'd28; //await memory read
	localparam DECODE 			= 6'd30; //populate instruction register
	localparam DECODE_INSTR 	= 6'd32; //decide which instruction to execute
	
	//INSTRUCTIONS
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
	localparam LDI_LATTER 		= 6'd26; //LDI MAR = MDR	
	
	localparam LOAD_CHECK_ACV 	= 6'd35; //state inside lD, LDR, and LDI which checks for ACV
	localparam LOAD_READ_MEM 	= 6'd25; //LD, LDR, LDI, MDR = M[MAR]
	localparam LOAD_WRITE_REG 	= 6'd27; //LD, LDR, LDI, DR = M. Last LOAD state
	
	
	localparam STI_CHECK_ACV	= 6'd19; //STI first half
	localparam STI_READ_MEM		= 6'd29; //STI first half
	localparam STI_LATTER		= 6'd31; //STI MAR = MDR
	
	localparam STORE_CHECK_ACV 	= 6'd23; //ST, STR, STI, checks for ACV
	localparam STORE_WRITE_MEM 	= 6'd16; //ST, STR, STI, M[MAR] = MDR. Last STORE state
	
	localparam BRANCH_EXECUTE	= 6'd22; //PC = PC + off9
	
	localparam JSR_IMM			= 6'd21; //PC = PC + off11
	localparam JSR_REG			= 6'd20; //PC = SR
	
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
	localparam VECTOR_REF		= 6'd54; 
	localparam VECTOR_READ		= 6'd53; 
	localparam VECTOR_JUMP		= 6'd55; 
	
	localparam COND_ACV = 3'b110; 
	localparam COND_INT = 3'b101; 
	localparam COND_PSR = 3'b100; 
	localparam COND_BEN = 3'b010; 
	localparam COND_R = 3'b001;   
	localparam COND_INSTR = 3'b011;
	
	

	always@(*)begin //next state 
	//default everything to 0
	J = 0;
	LDMAR = 0; LDMDR = 0; LDIR = 0; LDBEN = 0; LDREG = 0; LDCC = 0; LDPC = 0; LDPriv = 0; LDPriority = 0;	 LDSavedSSP = 0;	 LDSavedUSP = 0;	 LDACV = 0; LDVector = 0;	 GatePC = 0; GateMDR = 0; GateALU = 0; GateMARMUX = 0;	 GateVector = 0;	 GatePC1 = 0; GatePSR = 0; GateSP = 0; PCMUX = 0; DRMUX = 0; SR1MUX = 0; ADDR2MUX = 0;	 SPMUX = 0; VectorMUX = 0;	 ADDR1MUX = 0;	 MARMUX = 0; TableMUX = 0;	 PSRMUX = 0; MIOEN = 0; RW = 0; SETPRIV = 0;	  
	COND = 0;
	IRD = 0;
		case(index)
			FETCH:begin // MAR <- PC, PC <- PC+1, set ACV, [INT]. note: Interrupt not implemented
				LDMAR = 1; MARMUX = `MARMUX_ADR_SUM; ADDR1MUX = `ADDR1MUX_PC; ADDR2MUX = `ADDR2MUX_OFFSET_0; GateMARMUX = 1; // MAR <- PC
				PCMUX = `PCMUX_INC; LDPC = 1; // PC <- PC+1
				LDACV = 1;
				J = FETCH_CHECK_ACV;
				
				COND = COND_INT;
				

			end
			FETCH_CHECK_ACV: begin //check ACV
				J = FETCH_AWAIT;
				COND = COND_ACV;
			end
			FETCH_AWAIT: begin // MDR<-M
				LDMDR = 1; MIOEN = 1; 
				J = DECODE;
				COND = COND_R;
				
			end
			DECODE: begin //IR <- instruction
				GateMDR = 1; LDIR = 1; 
				J = DECODE_INSTR;

			end
			DECODE_INSTR: begin //BEN<−IR[11] & N + IR[10] & Z + IR[9] & P[IR[15:12]]
				//BEN is continuously assigned from datapath.
				LDBEN = 1;
				IRD = 1;
				J = 0;
					
			end
			INSTR_ADD: begin
				DRMUX = `DRMUX_FIRST; SR1MUX = `SR1MUX_SECOND; LDREG = 1; LDCC=1; GateALU = 1; 
				J = FETCH;

			end
			INSTR_AND: begin 
				DRMUX = `DRMUX_FIRST; SR1MUX = `SR1MUX_SECOND; LDREG = 1; LDCC=1; GateALU = 1; 
				J = FETCH;

			end
			INSTR_NOT: begin 
				DRMUX = `DRMUX_FIRST; SR1MUX = `SR1MUX_SECOND; LDREG = 1; LDCC=1; GateALU = 1; 
				J = FETCH;

			end
			INSTR_LEA: begin //DR<−PC+off9
				//Use the MARMUX, and address adder
				DRMUX = `DRMUX_FIRST; ADDR1MUX = `ADDR1MUX_PC ; ADDR2MUX = `ADDR2MUX_OFFSET_9; MARMUX = `MARMUX_ADR_SUM; GateMARMUX = 1; LDREG = 1; 
				J = FETCH;

			end
			INSTR_LD: begin //MAR<−PC+off9 , set ACV
				ADDR1MUX = `ADDR1MUX_PC; ADDR2MUX = `ADDR2MUX_OFFSET_9; MARMUX = `MARMUX_ADR_SUM; GateMARMUX = 1; LDMAR = 1; LDACV = 1; 
				J = LOAD_CHECK_ACV;

			end
			
			INSTR_LDR: begin //MAR<-B+off6, set ACV
				ADDR1MUX = `ADDR1MUX_SR1 ; ADDR2MUX = `ADDR2MUX_OFFSET_6; SR1MUX = `SR1MUX_SECOND; MARMUX = `MARMUX_ADR_SUM; GateMARMUX = 1; LDMAR = 1; LDACV = 1; 
				J = LOAD_CHECK_ACV;

			end
			
			INSTR_LDI: begin //MAR <- PC+off9
				ADDR1MUX = `ADDR1MUX_PC; ADDR2MUX = `ADDR2MUX_OFFSET_9; MARMUX = `MARMUX_ADR_SUM; GateMARMUX = 1; LDMAR = 1; LDACV = 1; 
				J = LDI_CHECK_ACV;

			end
			
			LDI_CHECK_ACV: begin //check ACV
				J = LDI_READ_MEM;
				COND = COND_ACV;

			end
			
			LDI_READ_MEM: begin //MDR<-M[MAR]
				LDMDR = 1; MIOEN = 1; 
				J = LDI_LATTER;
				COND = COND_R;

			end		
			
			LDI_LATTER: begin //MAR <-MDR, set ACV
				LDMAR = 1; GateMDR = 1; LDACV = 1; 
				J = LOAD_CHECK_ACV;

			end

			LOAD_CHECK_ACV: begin // check ACV
				J = LOAD_READ_MEM;
				COND = COND_ACV;

			end
			
			LOAD_READ_MEM: begin //MDR<-M[MAR]
				LDMDR = 1; MIOEN = 1; 
				J = LOAD_WRITE_REG;
				COND = COND_R;

			end	
			
			LOAD_WRITE_REG: begin //DR<-MDR, set CC 
				GateMDR = 1; LDREG = 1; DRMUX = `DRMUX_FIRST; LDCC = 1; 
				J = FETCH;

			end
			
			INSTR_ST: begin // MAR <- PC + off9, set ACV
				ADDR1MUX = `ADDR1MUX_PC ; ADDR2MUX = `ADDR2MUX_OFFSET_9; MARMUX = `MARMUX_ADR_SUM; GateMARMUX = 1; LDMAR = 1; LDACV = 1; 
				J = STORE_CHECK_ACV;

			end
			
			INSTR_STR: begin //MAR <- B + off6
				ADDR1MUX = `ADDR1MUX_SR1 ; ADDR2MUX = `ADDR2MUX_OFFSET_6; SR1MUX = `SR1MUX_SECOND; MARMUX = `MARMUX_ADR_SUM; GateMARMUX = 1; LDMAR = 1; LDACV = 1; 
				J = STORE_CHECK_ACV;

			end
			
			INSTR_STI: begin // MAR<−PC+off9, set ACV
				ADDR1MUX = `ADDR1MUX_PC; ADDR2MUX = `ADDR2MUX_OFFSET_9; MARMUX = `MARMUX_ADR_SUM; GateMARMUX = 1; LDMAR = 1; LDACV = 1; 
				J = STI_CHECK_ACV;

			end
				
			STI_CHECK_ACV: begin //check ACV
				J = STI_READ_MEM;
 
				COND = COND_ACV;

			end
			
			STI_READ_MEM: begin //MDR <-M[MAR]
				LDMDR = 1; MIOEN = 1; 
				J = STI_LATTER;
				COND = COND_R;
			end
			
			STI_LATTER: begin // MAR<-MDR, set ACV
				LDMAR = 1; GateMDR = 1; LDACV = 1; 
				J = STORE_CHECK_ACV;

			end
			
			STORE_CHECK_ACV: begin // MDR <- SR, check ACV
				LDMDR = 1; MIOEN = 0; SR1MUX = `SR1MUX_FIRST; ADDR1MUX = `ADDR1MUX_SR1; ADDR2MUX = `ADDR2MUX_OFFSET_0; GateMARMUX = 1; 
				COND = COND_ACV;
				J = STORE_WRITE_MEM;
			end
			
			STORE_WRITE_MEM: begin //M[MAR]<-MDR
				RW = 1; 
				COND = COND_R;
				J = FETCH;
			end
			
			INSTR_BR: begin // check BEN
				COND = COND_BEN;
				J = BRANCH_EXECUTE;
			end
			
			BRANCH_EXECUTE: begin // PC = PC + off9
				LDPC = 1; PCMUX = `PCMUX_ADDR; ADDR1MUX = `ADDR1MUX_PC; ADDR2MUX = `ADDR2MUX_OFFSET_9; 
				J = FETCH;
			end
			
			INSTR_JMP: begin // PC = BaseR
				LDPC = 1; PCMUX = `PCMUX_ADDR; SR1MUX = `SR1MUX_SECOND; ADDR1MUX = `ADDR1MUX_SR1; ADDR2MUX = `ADDR2MUX_OFFSET_0; 
				J = FETCH;
			end
			
			INSTR_JSR: begin // JSR or JSRR (imm or reg)
				COND = COND_INSTR;
				J = JSR_REG;
			end
			
			JSR_REG: begin // R7 = PC. PC = PC + baseR
				DRMUX = `DRMUX_SEVEN; LDREG = 1; GatePC = 1; LDPC = 1; PCMUX = `PCMUX_ADDR; SR1MUX = `SR1MUX_SECOND; ADDR1MUX = `ADDR1MUX_SR1; ADDR2MUX = `ADDR2MUX_OFFSET_0; 
				J = FETCH;
			end
			
			JSR_IMM: begin // R7 = PC. PC = PC + off11
				DRMUX = `DRMUX_SEVEN; LDREG = 1; GatePC = 1; LDPC = 1; PCMUX = `PCMUX_ADDR; ADDR1MUX = `ADDR1MUX_PC; ADDR2MUX = `ADDR2MUX_OFFSET_11; 
				J = FETCH;
			end
			
			INSTR_RTI: begin // MAR <- SP. [PSR[15]]
				MARMUX = `MARMUX_ADR_SUM; LDMAR = 1; ADDR1MUX = `ADDR1MUX_SR1; ADDR2MUX = `ADDR2MUX_OFFSET_0; SR1MUX = `SR1MUX_SIX; 
				J = RTI_FETCH_PC;
				COND = COND_PSR;
			end
			
			RTI_FETCH_PC: begin // MDR <- M
				GateMARMUX = 1; LDMDR = 1; MIOEN = 1; 
				J = RTI_LOAD_PC;
				COND = COND_R;
			end
			
			RTI_LOAD_PC: begin //PC <- MDR
				LDPC = 1; PCMUX = `PCMUX_BUS; GateMDR = 1; 
				J = RTI_INC_R6;
			end
			
			RTI_INC_R6: begin // MAR <- SP + 1.  SP <- SP + 1
				DRMUX = `DRMUX_SIX; SR1MUX = `SR1MUX_SIX; SPMUX = `SPMUX_INC; LDREG = 1; GateSP = 1; 
				J = RTI_FETCH_PSR; 
			end
			
			RTI_FETCH_PSR: begin // MDR <- M
				GateMARMUX = 1; LDMDR = 1; MIOEN = 1; 
				J = RTI_LOAD_PSR;
				COND = COND_R;
			end
			
			RTI_LOAD_PSR: begin //PSR <- MDR				
				PSRMUX = `PSRMUX_Databus; GateMDR = 1; 
				J = RTI_CHECK_MODE;
			end
			
			RTI_CHECK_MODE: begin //SP <- SP + 1, [PSR[15]]
				DRMUX = `DRMUX_SIX; SR1MUX = `SR1MUX_SIX; SPMUX = `SPMUX_INC; LDREG = 1; GateSP = 1; 
				J = RTI_SUPER;
				COND = COND_PSR;
			end
			
			RTI_USER: begin //Saved_SSP <- SP. SP <- Saved_USP
				LDSavedSSP = 1; DRMUX = `DRMUX_SIX; SR1MUX = `SR1MUX_SIX; SPMUX = `SPMUX_USP; GateSP = 1; LDREG = 1; 
				J = FETCH;
			end
			
			RTI_SUPER: begin //nothing
				J = FETCH;
			end
			
			RTI_EXCEPTION: begin // Table = 1, Vector = 0, MDR = PSR, PSR[15] = 0
TableMUX = `TableMUX_1; LDVector = 1; VectorMUX = `VectorMUX_0; GatePSR = 1; LDMDR = 1; LDPriv = 1; SETPRIV = 0; PSRMUX = `PSRMUX_Databus; 
				J = SWITCH_SP;
			end
			
			INSTR_TRAP: begin //Table <- 0, PC +1, MDR <- PSR
TableMUX = `TableMUX_0; PCMUX = `PCMUX_INC; LDPC = 1; GatePSR = 1; LDMDR = 1; LDVector = 1; 
				J = TRAP_VECTOR;
			end
		
			
			TRAP_VECTOR: begin //Vector <- IR[7:0], Priv = 0, check priv.
SETPRIV = 0; LDPriv = 1; MARMUX = `MARMUX_INSTR; LDVector = 1; TableMUX = `TableMUX_0; 
				J = PUSH_PSR_0;
				COND = COND_PSR;
			end
			
			INSTR_RESERVED: begin // Table <- 1, Vector <- 1, MDR <- PSR, PSR[15] <- 0, [PSR[15]]
TableMUX = `TableMUX_1; VectorMUX = `VectorMUX_1; LDMDR = 1; GatePSR = 1; SETPRIV = 0; LDPriv = 1; PSRMUX = `PSRMUX_Individual; 
				J = PUSH_PSR_0;
				COND = COND_PSR;
			end
			
			INTERRUPT: begin  // Table <- 1, Vector <- INTV, PSR[10:8] <- Priority, MDR <- PSR, PSR[15] <- 0, [PSR[15]]
TableMUX = `TableMUX_1; VectorMUX = `VectorMUX_INTV; LDPriority = 1; LDMDR = 1; GatePSR = 1; SETPRIV = 0; LDPriv = 1; PSRMUX = `PSRMUX_Individual; 
				J = PUSH_PSR_0;
				COND = COND_PSR;
			end
			
			
			SWITCH_SP: begin //Saved_SSP <-sp, sp <- Saved_USP
LDSavedSSP = 1; DRMUX = `DRMUX_SIX; SR1MUX = `SR1MUX_SIX; SPMUX = `SPMUX_USP; GateSP = 1; LDREG = 1; 
				J = PUSH_PSR_0;
			end
			
			PUSH_PSR_0: begin //MAR, SP <- SP-1
SPMUX = `SPMUX_DEC; GateSP = 1; LDREG = 1; LDMAR = 1; 
				J = PUSH_PSR_1;
			end
			
			PUSH_PSR_1: begin // M[MAR] < MDR
MIOEN = 1; 
				J = PUSH_PC_0;
				COND = COND_R;
			end
			
			PUSH_PC_0: begin // MDR <- PC-1
GatePC1 = 1; LDMDR = 1; 
				J = PUSH_PC_1;
			end
			
			PUSH_PC_1: begin // MAR, SP <- SP-1	
DRMUX = `DRMUX_SIX; SR1MUX = `SR1MUX_SIX; SPMUX = `SPMUX_DEC; LDREG = 1; GateSP = 1; 
				J = PUSH_PC_2;
			end
			
			PUSH_PC_2: begin // M[MAR] < MDR
MIOEN = 1; 
				J = VECTOR_REF;
				COND = COND_R;

			end
			
			VECTOR_REF: begin //MAR <- table,Vector
GateVector = 1; LDMAR = 1; 
				J = VECTOR_READ;
			end
			
			VECTOR_READ: begin // MDR <- M
LDMDR = 1; MIOEN = 1; 
				J = VECTOR_JUMP;
				COND = COND_R;

			end
			
			VECTOR_JUMP: begin //PC <- MDR
LDPC = 1; GateMDR = 1; PCMUX = `PCMUX_BUS; 
				J = FETCH;
			end
			
			FETCH_ACV: begin // Table <- 1, Vector <- 2, MDR <- PSR, PSR[15] <- 0,
TableMUX = `TableMUX_1; VectorMUX = `VectorMUX_2; LDMDR = 1; GatePSR = 1; SETPRIV = 0; LDPriv = 1; PSRMUX = `PSRMUX_Individual; 
				J = SWITCH_SP;
			end
				
			LOAD_ACV: begin // Table <- 1, Vector <- 2, MDR <- PSR, PSR[15] <- 0,
TableMUX = `TableMUX_1; VectorMUX = `VectorMUX_2; LDMDR = 1; GatePSR = 1; SETPRIV = 0; LDPriv = 1; PSRMUX = `PSRMUX_Individual; 
 J = SWITCH_SP;
			end
			
			LDI_ACV: begin // Table <- 1, Vector <- 2, MDR <- PSR, PSR[15] <- 0,
TableMUX = `TableMUX_1; VectorMUX = `VectorMUX_2; LDMDR = 1; GatePSR = 1; SETPRIV = 0; LDPriv = 1; PSRMUX = `PSRMUX_Individual; 
 J = SWITCH_SP;
			end
			
			STORE_ACV: begin // Table <- 1, Vector <- 2, MDR <- PSR, PSR[15] <- 0,
TableMUX = `TableMUX_1; VectorMUX = `VectorMUX_2; LDMDR = 1; GatePSR = 1; SETPRIV = 0; LDPriv = 1; PSRMUX = `PSRMUX_Individual; 
 J = SWITCH_SP;
			end
			
			STI_ACV: begin // Table <- 1, Vector <- 2, MDR <- PSR, PSR[15] <- 0,
			J = SWITCH_SP;
TableMUX = `TableMUX_1; VectorMUX = `VectorMUX_2; LDMDR = 1; GatePSR = 1; SETPRIV = 0; LDPriv = 1; PSRMUX = `PSRMUX_Individual; 
 
			end
			
			default:begin
				J = FETCH;
			end
		endcase
		
	end

	
endmodule

//INSTR_BR = 0; INSTR_ADD = 0; INSTR_LD = 0; INSTR_ST = 0; INSTR_JSR = 0; INSTR_AND = 0; INSTR_LDR = 0; INSTR_STR = 0; INSTR_RTI = 0; INSTR_NOT = 0; INSTR_LDI = 0; INSTR_STI = 0; INSTR_JMP = 0; INSTR_RESERVED = 0; INSTR_LEA = 0; INSTR_TRAP = 0; STORE_WRITE_MEM = 0; LDI_CHECK_ACV = 0; FETCH = 0; STI_CHECK_ACV = 0; JSR_REG = 0; JSR_IMM = 0; BRANCH_EXECUTE = 0; STORE_CHECK_ACV = 0; LDI_READ_MEM = 0; LOAD_READ_MEM = 0; LDI_LATTER = 0; LOAD_WRITE_REG = 0; FETCH_AWAIT = 0; STI_READ_MEM = 0; DECODE = 0; STI_LATTER = 0; DECODE_INSTR = 0; FETCH_CHECK_ACV = 0; RTI_CHECK_MODE = 0; LOAD_CHECK_ACV = 0; RTI_FETCH_PC = 0; PUSH_PSR_0 = 0; RTI_LOAD_PC = 0; RTI_INC_R6 = 0; RTI_FETCH_PSR = 0; PUSH_PSR_1 = 0; RTI_LOAD_PSR = 0; PUSH_PC_0 = 0; RTI_EXCEPTION = 0; SWITCH_SP = 0; PUSH_PC_1 = 0; TRAP_VECTOR = 0; STORE_ACV = 0; INTERRUPT = 0; RTI_SUPER = 0; PUSH_PC_2 = 0; VECTOR_READ = 0; VECTOR_REF = 0; VECTOR_JUMP = 0; LDI_ACV = 0; LOAD_ACV = 0; RTI_USER = 0; FETCH_ACV = 0; STI_ACV = 0;





/*
INSTR_BR			 = 0;
INSTR_ADD		     = 0;
INSTR_LD			 = 0;
INSTR_ST			 = 0;
INSTR_JSR		     = 0;
INSTR_AND		     = 0;
INSTR_LDR		     = 0;
INSTR_STR		     = 0;
INSTR_RTI		     = 0;
INSTR_NOT		     = 0;
INSTR_LDI		     = 0;
INSTR_STI		     = 0;
INSTR_JMP		     = 0;
INSTR_RESERVED	     = 0;
INSTR_LEA		     = 0;
INSTR_TRAP		     = 0;
STORE_WRITE_MEM	     = 0;
LDI_CHECK_ACV	     = 0;
FETCH			     = 0;
STI_CHECK_ACV	     = 0;
JSR_REG			     = 0;
JSR_IMM			     = 0;
BRANCH_EXECUTE	     = 0;
STORE_CHECK_ACV	     = 0;
LDI_READ_MEM		 = 0;
LOAD_READ_MEM	     = 0;
LDI_LATTER		     = 0;
LOAD_WRITE_REG	     = 0;
FETCH_AWAIT		     = 0;
STI_READ_MEM		 = 0;
DECODE			     = 0;
STI_LATTER		     = 0;
DECODE_INSTR		 = 0;
FETCH_CHECK_ACV	     = 0;
RTI_CHECK_MODE	     = 0;
LOAD_CHECK_ACV	     = 0;
RTI_FETCH_PC		 = 0;
PUSH_PSR_0		     = 0;
RTI_LOAD_PC		     = 0;
RTI_INC_R6		     = 0;
RTI_FETCH_PSR	     = 0;
PUSH_PSR_1		     = 0;
RTI_LOAD_PSR		 = 0;
PUSH_PC_0		     = 0;
RTI_EXCEPTION	     = 0;
SWITCH_SP		     = 0;
PUSH_PC_1		     = 0;
TRAP_VECTOR		     = 0;
STORE_ACV		     = 0;
INTERRUPT		     = 0;
RTI_SUPER		     = 0;
PUSH_PC_2		     = 0;
VECTOR_READ		     = 0;
VECTOR_REF		     = 0;
VECTOR_JUMP		     = 0;
LDI_ACV			     = 0;
LOAD_ACV			 = 0;
RTI_USER             = 0;
FETCH_ACV            = 0;
STI_ACV              = 0;
*/

/*
LDMAR			= 0;
LDMDR			= 0;
LDIR			= 0;
LDBEN			= 0;
LDREG			= 0;
LDCC			= 0;
LDPC			= 0;
LDPriv			= 0;
LDPriority		= 0;	
LDSavedSSP		= 0;	
LDSavedUSP		= 0;	
LDACV			= 0;
LDVector		= 0;	
GatePC			= 0;
GateMDR			= 0;
GateALU			= 0;
GateMARMUX		= 0;	
GateVector		= 0;	
GatePC1			= 0;
GatePSR			= 0;
GateSP			= 0;
PCMUX			= 0;
DRMUX			= 0;
SR1MUX			= 0;
ADDR2MUX		= 0;	
SPMUX			= 0;
VectorMUX		= 0;	
ADDR1MUX		= 0;	
MARMUX			= 0;
TableMUX		= 0;	
PSRMUX			= 0;
MIOEN			= 0;
RW			    = 0;
SETPRIV 		= 0;	

LDMAR = 0; LDMDR = 0; LDIR = 0; LDBEN = 0; LDREG = 0; LDCC = 0; LDPC = 0; LDPriv = 0; LDPriority = 0;	 LDSavedSSP = 0;	 LDSavedUSP = 0;	 LDACV = 0; LDVector = 0;	 GatePC = 0; GateMDR = 0; GateALU = 0; GateMARMUX = 0;	 GateVector = 0;	 GatePC1 = 0; GatePSR = 0; GateSP = 0; PCMUX = 0; DRMUX = 0; SR1MUX = 0; ADDR2MUX = 0;	 SPMUX = 0; VectorMUX = 0;	 ADDR1MUX = 0;	 MARMUX = 0; TableMUX = 0;	 PSRMUX = 0; MIOEN = 0; RW = 0; SETPRIV = 0;	  
*/

