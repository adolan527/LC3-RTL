`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/06/2025 03:15:48 PM
// Design Name: 
// Module Name: lc3
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


module lc3
#(parameter MEMORY_INIT_FILE = "")
(
	//DEBUG ports
	output [16*`MEMORY_WORDCOUNT-1:0] debugMemoryRead,
	output [16 * 8 -1:0] debugRegRead,
	output [15:0] debugInstruction,
	output [5:0] debugCurrentState, debugNextState,
	output [15:0] debugPSR,
	output [15:0] debugPC,
	output [15:0] debugDatabus,
	output [15:0] debugMARRead,
	output [15:0] debugMDRRead,
	output debugLDREG,
	output debugMIOEN,
	output debugRW,
	


	
	input clk, reset_n,
	input[15:0] keyboardInput,
	input [2:0] interrupt_priority,
	input [7:0] INTV,
	output[15:0] consoleOutput
    );

wire  INT, R, BEN, ACV, clk, reset_n;
wire[15:0]  instruction;
assign debugInstruction = instruction;
assign debugPSR = PSR;
assign debugLDREG = LDREG;
assign debugMIOEN = MIOEN;
assign debugRW = RW;
wire[15:0]  PSR;
wire GatePC1, SetPriv, RW, MIOEN, PSRMUX, TableMUX, MARMUX, ADDR1MUX, GateSP, GatePSR, LDMAR, GateVector, GateMARMUX, GateALU, GatePC, LDMDR, LDIR, LDBEN, LDREG, LDCC, LDPC, LDPriv, LDPriority, LDSavedSSP, LDSavedUSP, LDACV, LDVector, GateMD, R;
wire[1:0] ADDR2MUX, SPMUX, VectorMUX, ALUK, SR1MUX, DRMUX, PCMUX;

controller controller_inst(
 .PSR(PSR),
 .instruction(instruction[15:11]),
 .INT(INT),
 .R(R),
 .BEN(BEN),
 .ACV(ACV),
 .clk(clk),
 .reset_n(reset_n),
 .LDMAR(LDMAR),
 .LDMDR(LDMDR),
 .LDIR(LDIR),
 .LDBEN(LDBEN),
 .LDREG(LDREG),
 .LDCC(LDCC),
 .LDPC(LDPC),
 .LDPriv(LDPriv),
 .LDPriority(LDPriority),
 .LDSavedSSP(LDSavedSSP),
 .LDSavedUSP(LDSavedUSP),
 .LDACV(LDACV),
 .LDVector(LDVector),
 .GatePC(GatePC),
 .GateMDR(GateMDR),
 .GateALU(GateALU),
 .GateMARMUX(GateMARMUX),
 .GateVector(GateVector),
 .GatePC1(GatePC1),
 .GatePSR(GatePSR),
 .GateSP(GateSP),
 .PCMUX(PCMUX),
 .DRMUX(DRMUX),
 .SR1MUX(SR1MUX),
 .ADDR2MUX(ADDR2MUX),
 .SPMUX(SPMUX),
 .VectorMUX(VectorMUX),
 .ADDR1MUX(ADDR1MUX),
 .MARMUX(MARMUX),
 .TableMUX(TableMUX),
 .PSRMUX(PSRMUX),
 .MIOEN(MIOEN),
 .RW(RW),
 .SETPRIV(SETPRIV),
 .debugCurrentState(debugCurrentState),
 .debugNextState(debugNextState)
 );

wire  LDPriority, SETPRIV, RW, MIOEN, PSRMUX, TableMUX, MARMUX, ADDR1MUX, LDVector, LDACV, LDSavedUSP, LDSavedSSP, clk, LDPriv, LDPC, LDREG, reset_n, GatePC, GateMDR, GateALU, GateMARMUX, GateVector, GatePC1, GatePSR, GateSP, LDMAR, LDMDR, LDIR, LDBEN, LDCC;
wire[1:0]  PCMUX, DRMUX, SR1MUX, ADDR2MUX, SPMMUX, VectorMUX, ALUK;
wire BEN, ACV;
wire[15:0] PSR;

datapath #(.MEMORY_INIT_FILE(MEMORY_INIT_FILE)) datapath_inst(
 .clk(clk),
 .reset_n(reset_n),
 .GatePC(GatePC),
 .GateMDR(GateMDR),
 .GateALU(GateALU),
 .GateMARMUX(GateMARMUX),
 .GateVector(GateVector),
 .GatePC1(GatePC1),
 .GatePSR(GatePSR),
 .GateSP(GateSP),
 .LDMAR(LDMAR),
 .LDMDR(LDMDR),
 .LDIR(LDIR),
 .LDBEN(LDBEN),
 .LDREG(LDREG),
 .LDCC(LDCC),
 .LDPC(LDPC),
 .LDPriv(LDPriv),
 .LDPriority(LDPriority),
 .LDSavedSSP(LDSavedSSP),
 .LDSavedUSP(LDSavedUSP),
 .LDACV(LDACV),
 .LDVector(LDVector),
 .PCMUX(PCMUX),
 .DRMUX(DRMUX),
 .SR1MUX(SR1MUX),
 .ADDR2MUX(ADDR2MUX),
 .SPMMUX(SPMMUX),
 .VectorMUX(VectorMUX),
 .SPMUX(SPMUX),
 .ADDR1MUX(ADDR1MUX),
 .MARMUX(MARMUX),
 .TableMUX(TableMUX),
 .PSRMUX(PSRMUX),
 .MIOEN(MIOEN),
 .RW(RW),
 .SETPRIV(SETPRIV),
 .BEN(BEN),
 .ACV(ACV),
 .R(R),
 .PSR(PSR),
 .INT(INT),
 .instruction(instruction),
 .foreignKeyboardInput(keyboardInput),
 .foreignConsoleOutput(consoleOutput),
 .interrupt_priority(interrupt_priority),
 .INTV(INTV),
 
 .debugMemoryRead(debugMemoryRead),
 .debugRegRead(debugRegRead),
 .debugPC(debugPC),
 .debugDatabus(debugDatabus),
 .debugMARRead(debugMARRead),
 .debugMDRRead(debugMDRRead)
 );


endmodule
