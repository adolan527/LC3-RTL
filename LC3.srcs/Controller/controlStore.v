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
	
	
	);
	
	reg[51:0] microinstruction;
	always@(*)begin

	
	always@(*)begin //next state 
		case(index)begin
			FETCH:begin // MAR <- PC, PC <- PC+1, set ACV, [INT]. note: Interrupt not implemented
				LDMAR <= 1; MARMUX <= `MARMUX_ADR_SUM; ADDR1MUX <= `ADDR1MUX_PC; ADDR2MUX <= `ADDR2MUX_OFFSET_0; GateMARMUX <= 1; // MAR <- PC
				PCMUX <= `PCMUX_INC; LDPC <= 1; // PC <- PC+1
				LDACV <= 1;
				
				microinstruction<={
				
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
				
			end
			FETCH_AWAIT: begin // MDR<-M
				LDMDR <= 1; MIOEN <= 1; 

			end
			DECODE: begin //IR <- instruction
				LDMDR <= 0; MIOEN <= 0; 
				GateMDR <= 1; LDIR <= 1;	

			end
			DECODE_INSTR: begin //BEN<−IR[11] & N + IR[10] & Z + IR[9] & P[IR[15:12]]
				//BEN is continuously assigned from datapath.
				GateMDR <= 0; LDIR<= 0;
					
			end
			INSTR_ADD: begin
				DRMUX <= `DRMUX_FIRST; SR1MUX <= `SR1MUX_SECOND;  LDREG <= 1; LDCC<=1;
				GateALU <= 1;

			end
			INSTR_AND: begin 
				DRMUX <= `DRMUX_FIRST; SR1MUX <= `SR1MUX_SECOND;  LDREG <= 1; LDCC<=1;
				GateALU <= 1;
			end
			INSTR_NOT: begin 
				DRMUX <= `DRMUX_FIRST; SR1MUX <= `SR1MUX_SECOND;  LDREG <= 1; LDCC<=1;
				GateALU <= 1;
			end
			INSTR_LEA: begin //DR<−PC+off9
				//Use the MARMUX, and address adder
				DRMUX <= `DRMUX_FIRST; ADDR1MUX <= `ADDR1MUX_PC ; ADDR2MUX <= `ADDR2MUX_OFFSET_9; // PC + 9 bit offset
				MARMUX <= `MARMUX_ADR_SUM; GateMARMUX <= 1; //Use address sum, output to databus. Does not load MAR
				LDREG <= 1; //Loads into regfile

			end
			INSTR_LD: begin //MAR<−PC+off9 , set ACV
				ADDR1MUX <= `ADDR1MUX_PC; ADDR2MUX <= `ADDR2MUX_OFFSET_9; // PC + 9 bit offset
				MARMUX <= `MARMUX_ADR_SUM; GateMARMUX <= 1; LDMAR <= 1; //Use address sum, output to databus. LD MAR.
				LDACV <= 1;

			end
			
			INSTR_LDR: begin //MAR<-B+off6, set ACV
				ADDR1MUX <= `ADDR1MUX_SR1 ; ADDR2MUX <= `ADDR2MUX_OFFSET_6; SR1MUX <= `SR1MUX_SECOND; // SR1 + 6 bit offset
				MARMUX <= `MARMUX_ADR_SUM; GateMARMUX <= 1; LDMAR <= 1; //Use address sum, output to databus. LD MAR.
				LDACV <= 1;

			end
			
			INSTR_LDI: begin //MAR <- PC+off9
				ADDR1MUX <= `ADDR1MUX_PC; ADDR2MUX <= `ADDR2MUX_OFFSET_9; // PC + 9 bit offset
				MARMUX <= `MARMUX_ADR_SUM; GateMARMUX <= 1; LDMAR <= 1; //Use address sum, output to databus. LD MAR.				
				LDACV <= 1;

			end
			
			LDI_CHECK_ACV: begin //check ACV
				ADDR1MUX <= 0; ADDR2MUX <= 2'b00; SR1MUX <= 2'b00; // Disable
				MARMUX <= 0; GateMARMUX <= 0; LDMAR <= 0; LDACV <= 0;//Disable

			end
			
			LDI_READ_MEM: begin //MDR<-M[MAR]
				LDMDR <= 1; MIOEN <= 1;

			end		
			
			LDI_LATTER: begin //MAR <-MDR, set ACV
				LDMDR <= 0; MIOEN <= 0;//disable
				LDMAR <= 1; GateMDR <= 1;
				LDACV <= 1;

			end

			LOAD_CHECK_ACV: begin // check ACV
				ADDR1MUX <= 0; ADDR2MUX <= 2'b00;  SR1MUX <= 2'b00; // Disable
				MARMUX <= 0; GateMARMUX <= 0; LDMAR <= 0; //Disable
				GateMDR <= 0; LDACV <= 0; // Disable

			end
			
			LOAD_READ_MEM: begin //MDR<-M[MAR]
				LDMDR <= 1; MIOEN <= 1;

			end	
			
			LOAD_WRITE_REG: begin //DR<-MDR, set CC 
				LDMDR <= 0; MIOEN <= 0;//disable
				GateMDR <= 1; LDREG <= 1; DRMUX <= `DRMUX_FIRST;
				LDCC <= 1;

			end
			
			INSTR_ST: begin // MAR <- PC + off9, set ACV
				ADDR1MUX <= `ADDR1MUX_PC ; ADDR2MUX <= `ADDR2MUX_OFFSET_9; // PC + 9 bit offset
				MARMUX <= `MARMUX_ADR_SUM; GateMARMUX <= 1; LDMAR <= 1; //Use address sum, output to databus. LD MAR.
				LDACV <= 1;

			end
			
			INSTR_STR: begin //MAR <- B + off6
				ADDR1MUX <= `ADDR1MUX_SR1 ; ADDR2MUX <= `ADDR2MUX_OFFSET_6; SR1MUX <= `SR1MUX_SECOND; // SR1 + 6 bit offset
				MARMUX <= `MARMUX_ADR_SUM; GateMARMUX <= 1; LDMAR <= 1; //Use address sum, output to databus. LD MAR.
				LDACV <= 1;

			end
			
			INSTR_STI: begin // MAR<−PC+off9, set ACV
				ADDR1MUX <= `ADDR1MUX_PC; ADDR2MUX <= `ADDR2MUX_OFFSET_9; // PC + 9 bit offset
				MARMUX <= `MARMUX_ADR_SUM; GateMARMUX <= 1; LDMAR <= 1; //Use address sum, output to databus. LD MAR.
				LDACV <= 1;

			end
				
			STI_CHECK_ACV: begin //check ACV
				ADDR1MUX <= 0; ADDR2MUX <= 2'b00; SR1MUX <= 2'b00; // Disable
				MARMUX <= 0; GateMARMUX <= 0; LDMAR <= 0; LDACV <= 0; //Disable

			end
			
			STI_READ_MEM: begin //MDR <-M[MAR]
				LDMDR <= 1; MIOEN <= 1;

			end
			
			STI_LATTER: begin // MAR<-MDR, set ACV
				LDMDR <= 0; MIOEN <= 0;//disable
				LDMAR <= 1; GateMDR <= 1;
				LDACV <= 1;
			end
			
			STORE_CHECK_ACV: begin // MDR <- SR, check ACV
				ADDR1MUX <= 0; ADDR2MUX <= 2'b00; // disable
				MARMUX <= 0; GateMARMUX <= 0; LDMAR <= 0; //disable
				GateMDR <= 0; LDACV <= 0; // Disable
				LDMDR <= 1; MIOEN <= 0; 
				SR1MUX <= `SR1MUX_FIRST; ADDR1MUX <= `ADDR1MUX_SR1; ADDR2MUX <= `ADDR2MUX_OFFSET_0; GateMARMUX <= 1; // Send data through MARMUX

			end
			
			STORE_WRITE_MEM: begin //M[MAR]<-MDR
				LDMDR <= 0; RW <= 1; //write to memory

			end
			
			INSTR_BR: begin // check BEN

			end
			
			BRANCH_EXECUTE: begin // PC <= PC + off9
				LDPC <= 1; PCMUX <= `PCMUX_ADDR; 
				ADDR1MUX <= `ADDR1MUX_PC; ADDR2MUX <= `ADDR2MUX_OFFSET_9;

			end
			
			INSTR_JMP: begin // PC <= BaseR
				LDPC <= 1; PCMUX <= `PCMUX_ADDR; 
				SR1MUX <= `SR1MUX_SECOND;
				ADDR1MUX <= `ADDR1MUX_SR1; ADDR2MUX <= `ADDR2MUX_OFFSET_0;

			end
			
			INSTR_JSR: begin // JSR or JSRR (imm or reg)

			
			JSR_REG: begin // R7 <= PC. PC <= PC + baseR
				DRMUX <= `DRMUX_SEVEN; LDREG <= 1; GatePC <= 1;
				LDPC <= 1; PCMUX <= `PCMUX_ADDR; 
				SR1MUX <= `SR1MUX_SECOND;
				ADDR1MUX <= `ADDR1MUX_SR1; ADDR2MUX <= `ADDR2MUX_OFFSET_0;

			end
			
			JSR_IMM: begin // R7 <= PC. PC <= PC + off11
				DRMUX <= `DRMUX_SEVEN; LDREG <= 1; GatePC <= 1;
				LDPC <= 1; PCMUX <= `PCMUX_ADDR; 
				ADDR1MUX <= `ADDR1MUX_PC; ADDR2MUX <= `ADDR2MUX_OFFSET_11;

			end

			default:begin
				LDMAR <= 0; LDMDR <= 0; LDIR <= 0; LDBEN <= 0; LDREG <= 0; LDCC <= 0; LDPC <= 0; 
				LDPriv <= 0; LDPriority <= 0; LDSavedSSP <= 0; LDSavedUSP <= 0; LDACV <= 0; LDVector <= 0; 
				GatePC <= 0; GateMDR <= 0; GateALU <= 0; GateMARMUX <= 0; GateVector <= 0; GatePC1 <= 0; GatePSR <= 0; GateSP <= 0; 
				PCMUX <= 0; DRMUX <= 0; SR1MUX <= 0; ADDR2MUX <= 0; SPMUX <= 0; VectorMUX <= 0; ADDR1MUX <= 0; MARMUX <= 0; TableMUX <= 0; PSRMUX <= 0; 
				MIOEN <= 0; RW <= 0; SetPriv <= 0;
			end
		endcase
		
	end
	end
	
end

