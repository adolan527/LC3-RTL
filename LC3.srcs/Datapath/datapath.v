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
	input[1:0] PCMUX, DRMUX, SR1MUX, ADDR2MUX, SPMMUX, VectorMUX, SPMUX,
	input ADDR1MUX, MARMUX, TableMUX, PSRMUX, MIOEN, RW, SETPRIV,
	input [15:0] foreignKeyboardInput,
	input [2:0] interrupt_priority,
	input [7:0] INTV,
	output BEN, ACV, R, INT, //branch enable, Access Control Violation, memory read signal, interrupt signal
	output [15:0] PSR, instruction, foreignDisplayOutput,
	
	output [16 * 8 -1:0] debugRegRead,
	output [16*`MEMORY_WORDCOUNT-1:0] debugMemoryRead,
	output [15:0] debugPC,
	output [15:0] debugDatabus,
	output [15:0] debugMARRead,
	output [15:0] debugMDRRead
    );
	assign debugPC = PC;
	assign debugDatabus = dataBus;
    wire[15:0] dataBus, PC, SR1, SR2, SR2premux, addressSum; 
	wire[2:0] SR1adr, SR2adr, DRadr;
	wire[1:0] ALUK;
	wire N, Z, P;
	assign N = PSR[2];
	assign Z = PSR[1];
	assign P = PSR[0];
	
	wire[3:0] priorityLevel;
	assign ALUK = instruction[15:14];
	assign SR2adr = instruction[2:0];
	

	
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
	.pcMux(PCMUX),.bus(dataBus),.adder(addressSum),.clk(clk),.reset_n(reset_n),.GatePC(GatePC),.result(dataBus),.addressAdder(PC),.LDPC(LDPC),.GatePC1(GatePC1));
	
ALU ALU_inst(
	.operand_A(SR1),.operand_B(SR2),.operationSelect(ALUK),.GateALU(GateALU),.result(dataBus));
	
address address_inst(
	.SR1(SR1),.PC(PC),.instruction(instruction),.result(addressSum),.ADDR1MUX(ADDR1MUX),.ADDR2MUX(ADDR2MUX));
	
regFile regFile_inst(
	.data(dataBus),
	.DRadr(DRadr),
	.LDREG(LDREG),
	.SR1adr(SR1adr),
	.SR2adr(SR2adr),
	.clk(clk),
	.reset_n(reset_n),
	.SR1out(SR1),
	.SR2out(SR2premux),
	.debugRegRead(debugRegRead)
	);
	
branchEnable ben_inst(
.BEN(BEN),
.instruction(instruction),
.N(N),
.Z(Z),
.P(P),
.clk(clk),
.reset_n(reset_n),
.LDBEN(LDBEN)
);
	
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
 .debugMemoryRead(debugMemoryRead),
 .debugMARRead(debugMARRead),
 .debugMDRRead(debugMDRRead)
 );


	
TRAPBlock TRAPBlock_inst(
.clk(clk),
.reset_n(reset_n),
.dataBusIn(dataBus),
.dataBusOut(dataBus),
.GateVector(GateVector),
.LDVector(LDVector),
.TableMUX(TableMUX),
.VectorMUX(VectorMUX),
.INTV(INTV)
);

	
stackPointer stackPointer_inst(
.clk(clk),
.reset_n(reset_n),
.SPMUX(SPMUX),
.LDSavedSSP(LDSavedSSP),
.LDSavedUSP(LDSavedUSP),
.GateSP(GateSP),
.SR1(SR1),
.dataBus(dataBus)
);


PSRBlock PSRBlock_inst(
	.clk(clk),
	.reset_n(reset_n),
	.SETPRIV(SETPRIV),
	.PSRMUX(PSRMUX),
	.LDACV(LDACV),
	.LDPriority(LDPriority),
	.LDPriv(LDPriv),
	.LDCC(LDCC),
	.GatePSR(GatePSR),
	.dataBusIn(dataBus),
	.dataBusOut(dataBus),
	.PSR(PSR),
	.ACV(ACV),
	.INT(INT),
	.interrupt_priority(3'bz)
);


endmodule

