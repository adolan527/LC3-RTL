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

//TODO test new implementation

module controller(
	input [15:0] PSR, //processor status register. PSR[15] = user/supervisor, [10:8] priority, [2:0] N Z P
	input [15:11] instruction, //opcode + 1
	input INT, R, BEN, ACV, //Interrupt, ready to read memory, branch enable, access control violation
	input clk, reset_n,
	output LDMAR, LDMDR, LDIR, LDBEN, LDREG, LDCC, LDPC, LDPriv, LDPriority, LDSavedSSP, LDSavedUSP, LDACV, LDVector, //42 output bits
	output GatePC, GateMDR, GateALU, GateMARMUX, GateVector, GatePC1, GatePSR, GateSP,
	output [1:0] PCMUX, DRMUX, SR1MUX, ADDR2MUX, SPMUX, VectorMUX,
	output ADDR1MUX, MARMUX, TableMUX, PSRMUX,
	output MIOEN, RW, SETPRIV, //memory IO enable, Read/Write enable, Set privilege. PRIV = 0 -> S, PRIV = 1 -> U
	
	output wire[5:0] debugCurrentState, debugNextState
    );
	

wire[5:0]  index;
wire IRD;
wire[2:0] COND;
wire[5:0] J;

controlStore controlStore_inst(
 .index(index),
 .J(J),
 .COND(COND),
 .IRD(IRD),
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
 .SETPRIV(SETPRIV)
);



microsequencer microsequencer_inst(
 .INT(INT),
 .R(R),
 .BEN(BEN),
 .PSR_MSB(PSR[15]),
 .ACV(ACV),
 .IRD(IRD),
 .instruction(instruction),
 .J(J),
 .COND(COND),
 .control_store_index(index),
 .clk(clk),
 .reset_n(reset_n),
 .debugCurrentState(debugCurrentState),
 .debugNextState(debugNextState)
);


endmodule
 
 

				