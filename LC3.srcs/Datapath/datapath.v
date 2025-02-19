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
	input [15:0] foreignKeyboardInput,
	output BEN, ACV, R, //branch enable, Access Control Violation, memory read signal
	output [15:0] PSR, instruction, foreignDisplayOutput
    );
    wire[15:0] dataBus, PC, SR1, SR2, SR2premux, addressSum; 
	wire[2:0] SR1adr, SR2adr, DRadr;
	wire N, Z, P;
	
	wire[3:0] priorityLevel;
	assign PSR[15:0] = GatePSR ? {SETPRIV,4*{0},priorityLevel,5*{0},N,Z,P} : 16'bz;
	assign SR2adr = instruction[2:0];
	
MARmux MARmux_inst(
	.addressSum(addressSum),
	.instruction(instruction),
	.result(dataBus),
	.select(0),
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
	.data(dataBus),.DRadr(DRadr),.LDREG(LDREG),.SR1adr(SR1adr),.SR2adr(SR2adr),.clk(clk),.reset_n(reset_n),.SR1out(SR1),.SR2out(SR2premux));
	
accessControlViolation acv_inst(
	.ACV(ACV),.PSR(PSR),.dataBus(dataBus));
	
branchEnable ben_inst(.BEN(BEN),.instruction(instruction),.N(N),.Z(Z),.P(P));
	
SR1adrMux SR1MUX_inst(
	.SR1adr(SR1adr),.SR1MUX(SR1MUX),.instruction(instruction));	
	
		
DRadrMux DRMUX_inst(
	.DRadr(DRadr),.DRMUX(DRMUX),.instruction(instruction));	



memory memory_inst(
 .data(dataBus),
 .foreignKeyboardInput(foreignKeyboardInput),
 .clk(clk),.reset_n(reset_n),.result(dataBus),
 .foreignDisplayOutput(foreignDisplayOutput),
 .LDMDR(LDMDR),.LDMAR(LDMAR),.MIOEN(MIOEN),
 .RW(RW),
 .GateMDR(GateMDR),
 .R(R)
 );


endmodule

