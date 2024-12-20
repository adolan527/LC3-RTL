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
	input clk, reset_n, GateALU, GateMARmux, GatePC,
	input[1:0] pcMux, operationSelect,
	output N, Z, P
    );
    wire[15:0] dataBus, instruction, PC, SR1, SR2, SR2muxOutput, addressResult;
	wire[1:0] pcMux, operationSelect;
	wire[2:0] SR1select, SR2select;
	
MARmux MARmux_inst(
	.addressResult(addressResult),.instruction(instruction),.result(dataBus),.select(0),.GateMARmux(GateMARmux));
SR2mux SR2mux_inst(
	.SR2(SR2),.instruction(instruction),.result(SR2muxOutput));
instructionRegister instructionRegister_inst(
	.data(dataBus),.clk(clk),.reset_n(reset_n),.instruction(instruction));

programCounter programCounter_inst(
	.pcMux(pcMux),.bus(dataBus),.adder(addressResult),.clk(clk),.reset_n(reset_n),.GatePC(GatePC),.result(PC));
	
ALU ALU_inst(
	.operand_A(SR1),.operand_B(SR2muxOutput),.operationSelect(operationSelect),.GateALU(GateALU),.result(dataBus));
	
address address_inst(
	.SR1(SR1),.PC(PC),.instruction(instruction),.result(addressResult));
	
conditionCode conditionCode_inst(
	.data(dataBus),.LDCC(LDCC),.clk(clk),.reset_n(reset_n),.N(N),.Z(Z),.P(P));
	
regFile regFile_inst(
	.data(dataBus),.DR(DR),.LDREG(LDREG),.SR1(SR1select),.SR2(SR2select),.clk(clk),.reset_n(reset_n),.SR1out(SR1),.SR2out(SR2));

    
endmodule
