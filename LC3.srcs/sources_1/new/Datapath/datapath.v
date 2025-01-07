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


module datapath(
	input clk, reset_n, 
	input GatePC, GateMDR, GateALU, GateMARMUX, GateVector, GatePC1, GatePSR, GateSP,
	input LDMAR, LDMDR, LDIR, LDBEN, LDREG, LDCC, LDPC, LDPriv, LDPriority, LDSavedSSP, LDSavedUSP, LDACV, LDVector,
	input[1:0] PCMUX, DRMUX, SR1MUX, ADDR2MUX, SPMMUX, VectorMUX, ALUK,
	input ADDR1MUX, MARMUX, TableMUX, PSRMUX, MIOEN, RW, SETPRIV,
	output BEN, ACV, //branch enable, Access Control Violation 
	output [15:0] PSR
    );
    wire[15:0] dataBus, instruction, PC, SR1, SR2, SR2muxOutput, addressResult;
	wire[2:0] SR1select, SR2select, DR;
	wire N, Z, P;
	
	wire[3:0] priorityLevel;
	assign PSR[15:0] = GatePSR ? {SETPRIV,4*{0},priorityLevel,5*{0},N,Z,P} : 16'bz;
	
	// TODO: ensure every control signal inputted is used where necessary.wd
	
MARmux MARmux_inst(
	.addressResult(addressResult),.instruction(instruction),.result(dataBus),.select(0),.GateMARmux(GateMARMUX));
SR2mux SR2mux_inst(
	.SR2(SR2),.instruction(instruction),.result(SR2muxOutput));
instructionRegister instructionRegister_inst(
	.data(dataBus),.clk(clk),.reset_n(reset_n),.instruction(instruction),.enable(LDIR));

programCounter programCounter_inst(
	.pcMux(PCMUX),.bus(dataBus),.adder(addressResult),.clk(clk),.reset_n(reset_n),.GatePC(GatePC),.result(PC),.enable(LDPC));
	
ALU ALU_inst(
	.operand_A(SR1),.operand_B(SR2muxOutput),.operationSelect(ALUK),.GateALU(GateALU),.result(dataBus));
	
address address_inst(
	.SR1(SR1),.PC(PC),.instruction(instruction),.result(addressResult),.ADDR1MUX(ADDR1MUX),.ADDR2MUX(ADDR2MUX));
	
conditionCode conditionCode_inst(
	.data(dataBus),.LDCC(LDCC),.clk(clk),.reset_n(reset_n),.N(N),.Z(Z),.P(P));
	
regFile regFile_inst(
	.data(dataBus),.DR(DR),.LDREG(LDREG),.SR1(SR1select),.SR2(SR2select),.clk(clk),.reset_n(reset_n),.SR1out(SR1),.SR2out(SR2));
	
accessControlViolation acv_inst(
	.ACV(ACV),.PSR(PSR),.dataBus(dataBus));
	
branchEnable ben_inst(.BEN(BEN),.instruction(instruction),.N(N),.Z(Z),.P(P));
	
SR1adrMux SR1MUX_inst(
	.SR1(SR1),.SR1MUX(SR1MUX),.instruction(instruction));	
	
		
DRadrMux DRMUX_inst(
	.DR(DR),.DRMUX(DRMUX),.instruction(instruction));	

// TODO: Write tb for each module individually, better commenting, visually verify schematic, connect IO of modules to datapath module IO.    
endmodule
