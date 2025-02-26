`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/19/2024 01:18:31 AM
// Design Name: 
// Module Name: datapath
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


module datapath
#(parameter MEMORY_INIT_FILE = "")
(
	//DEBUG ports

	input clk, reset_n, 
	input GatePC, GateMDR, GateALU, GateMARMUX, GateVector, GatePC1, GatePSR, GateSP,
	input LDMAR, LDMDR, LDIR, LDBEN, LDREG, LDCC, LDPC, LDPriv, LDPriority, LDSavedSSP, LDSavedUSP, LDACV, LDVector,
	input[1:0] PCMUX, DRMUX, SR1MUX, ADDR2MUX, SPMMUX, VectorMUX,
	input ADDR1MUX, MARMUX, TableMUX, PSRMUX, MIOEN, RW, SETPRIV,
	input [15:0] foreignKeyboardInput,
	output BEN, ACV, R, //branch enable, Access Control Violation, memory read signal
	output [15:0] PSR, instruction, foreignDisplayOutput,
	
	output [16 * 8 -1:0] debugRegRead,
	output [16*`MEMORY_WORDCOUNT-1:0] debugMemoryRead
    );
    wire[15:0] dataBus, PC, SR1, SR2, SR2premux, addressSum; 
	wire[2:0] SR1adr, SR2adr, DRadr;
	wire[1:0] ALUK;
	wire N, Z, P;
	
	wire[3:0] priorityLevel;
	assign ALUK = instruction[15:14];
	assign PSR[15:0] = GatePSR ? {SETPRIV,4'b0000,priorityLevel,5'b00000,N,Z,P} : 16'bz; //TODO Fix PSR. Should always output to controller, gate to bus.
	assign SR2adr = instruction[2:0];
	
	//TODO finish implementing new PSR.
	/*
module programStatusRegister(
	input SETPRIV, priorityLevel, N, Z, P, clk, reset_n, GatePSR,
	output reg[15:0] PSR,
	output [15:0] dataBus
	);
	
programStatusRegister programStatusRegister_inst(
	.clk(clk),.reset_n(reset_n),
	.SETPRIV(SETPRIV),.
	*/
MARmux MARmux_inst(
	.addressSum(addressSum),
	.instruction(instruction),
	.result(dataBus),
	.select(MARMUX),
	.GateMARmux(GateMARMUX)
);
SR2mux SR2mux_inst(
	.SR2premux(SR2premux),
	.instruction(instruction),
	.SR2(SR2)
);
instructionRegister instructionRegister_inst(
	.data(dataBus),.clk(clk),.reset_n(reset_n),.instruction(instruction),.enable(LDIR));

programCounter programCounter_inst(
	.pcMux(PCMUX),.bus(dataBus),.adder(addressSum),.clk(clk),.reset_n(reset_n),.GatePC(GatePC),.result(dataBus),.addressAdder(PC),.LDPC(LDPC));
	
ALU ALU_inst(
	.operand_A(SR1),.operand_B(SR2),.operationSelect(ALUK),.GateALU(GateALU),.result(dataBus));
	
address address_inst(
	.SR1(SR1),.PC(PC),.instruction(instruction),.result(addressSum),.ADDR1MUX(ADDR1MUX),.ADDR2MUX(ADDR2MUX));
	
conditionCode conditionCode_inst(
	.data(dataBus),.LDCC(LDCC),.clk(clk),.reset_n(reset_n),.N(N),.Z(Z),.P(P));
	
regFile regFile_inst(
	.data(dataBus),.DRadr(DRadr),.LDREG(LDREG),.SR1adr(SR1adr),.SR2adr(SR2adr),.clk(clk),.reset_n(reset_n),.SR1out(SR1),.SR2out(SR2premux),.debugRegRead(debugRegRead));
	
accessControlViolation acv_inst(
	.ACV(ACV),.PSR(PSR),.dataBus(dataBus),.clk(clk),.reset_n(reset_n),.LDACV(LDACV));
	
branchEnable ben_inst(.BEN(BEN),.instruction(instruction),.N(N),.Z(Z),.P(P));
	
SR1adrMux SR1MUX_inst(
	.SR1adr(SR1adr),.SR1MUX(SR1MUX),.instruction(instruction));	
	
		
DRadrMux DRMUX_inst(
	.DRadr(DRadr),.DRMUX(DRMUX),.instruction(instruction));	



memory #(.MEMORY_INIT_FILE(MEMORY_INIT_FILE)) memory_inst(
 .data(dataBus),
 .foreignKeyboardInput(foreignKeyboardInput),
 .clk(clk),.reset_n(reset_n),.result(dataBus),
 .foreignDisplayOutput(foreignDisplayOutput),
 .LDMDR(LDMDR),.LDMAR(LDMAR),.MIOEN(MIOEN),
 .RW(RW),
 .GateMDR(GateMDR),
 .R(R),
 .debugMemoryRead(debugMemoryRead)
 );


endmodule

