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


module controller(
	input [15:0] instruction,
	input N, Z, P,
	input R,//Ready to read memory
	output LDMAR, LDMDR, LDIR, LDBEN, LDREG, LDCC, LDPC, LDPC, LDPriv, LDPriority, LDSavedSSP, LDSavedUSP, LDACV, LDVector,
	output GatePC, GateMDR, GateALU, GateMARMUX, GateVector, GatePC1, GatePSR, GateSP,
	output[1:0] PCMUX, DRMUX, SR1MUX, ADDR2MUX, SPMUX, VectorMUX, ALUK,
	output ADDR1MUX, MARMUX, TableMUX, PSRMUX,
	output MIOEN, RW, SetPriv
    );
	
	always@(*)begin //control signal assignment
	end
	
endmodule
 