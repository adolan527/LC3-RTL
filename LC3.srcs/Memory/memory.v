`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/19/2024 01:19:10 AM
// Design Name: 
// Module Name: memory
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
`include "memoryConstants.vh"

	
module memory
#(parameter MEMORY_INIT_FILE = "")
(
	//DEBUG ports

	input[15:0] data, foreignKeyboardInput,
	input clk, reset_n,
	output [15:0] result, foreignDisplayOutput,
	input LDMDR, LDMAR, MIOEN, RW, GateMDR, //MIOEN = memory io enable
	output R,
	
	output [16*`MEMORY_WORDCOUNT-1:0] debugMemoryRead

    );
	
	wire[15:0] MDR, MAR, memoryRead;
	wire[1:0] inmuxSelect;
	wire[15:0] KBSR, KBDR, DSR, DDR;
	wire KBSR_enable, DSR_enable, DDR_enable;
	
	reg [15:0] inmux; // input mux : feeds data to the MDR. if MIOEN, MDR = inmux, else MDR = data

	
	memoryRegister memoryRegister_inst(.data(data),.inmux(inmux),.clk(clk),.reset_n(reset_n),.MAR(MAR),.LDMAR(LDMAR),.LDMDR(LDMDR),.MIOEN(MIOEN),.GateMDR(GateMDR),.MDR(MDR),.result(result));
	io io_inst(.data(data),.KBDR(KBDR),.KBSR(KBSR),.DSR(DSR),.clk(clk),.reset_n(reset_n),.KBSR_enable(KBSR_enable),.DDR_enable(DDR_enable),.DSR_enable(DSR_enable),.foreignKeyboardInput(foreignKeyboardInput),.foreignDisplayOutput(foreignDisplayOutput));
	RAM #(.MEMORY_INIT_FILE(MEMORY_INIT_FILE)) RAM_inst(
	.MDR(MDR),
	.address(MAR),
	.RW(RW),
	.MEMEN(MEMEN),
	.memoryRead(memoryRead),
	.clk(clk),
	.reset_n(reset_n),
	.R(R),
	.debugMemoryRead(debugMemoryRead)
	);
	addressControlLogic addressControlLogic_inst(.MAR(MAR),.RW(RW),.MIOEN(MIOEN),.MEMEN(MEMEN),.KBSR_enable(KBSR_enable),.DDR_enable(DDR_enable),.DSR_enable(DSR_enable),.inmuxSelect(inmuxSelect));
	
	
	always@(*)begin
		case(inmuxSelect) 
			`MEMORYREAD: inmux <= memoryRead;
			`DSRREAD: inmux <= DSR;
			`KBSRREAD: inmux <= KBSR;
			`KBDRREAD: inmux <= KBDR;
		endcase
	end
	
endmodule
