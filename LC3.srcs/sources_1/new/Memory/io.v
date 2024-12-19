`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/19/2024 01:32:23 AM
// Design Name: 
// Module Name: io
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


module io(
	input[15:0] data,
	input[15:0] foreignKeyboardInput,
	output[15:0] foreignDisplayOutput,
	output[15:0] KBDR, KBSR, DDR, DSR,
	input clk, reset_n,
	input KBSR_enable, DDR_enable, DSR_enable
    );
	
	io_input in(.data(data),.foreignData(foreignKeyboardInput),.clk(clk),.reset_n(reset_n),.KBSR_enable(KBSR_enable),.KBSR(KBSR),.KBDR(KBDR));
	io_output out(.data(data),.clk(clk),.reset_n(reset_n),.DDR(DDR),.DSR(DSR),.DDR_enable(DDR_enable),.DSR_enable(DSR_enable));
	
	assign foreignDisplayOutput = DDR;
	
endmodule


module io_input(
	input[15:0] foreignData,
	input[15:0] data,
	input clk, 
	input reset_n,
	input KBSR_enable,
	output reg[15:0] KBSR, //keyboard status register
	output reg[15:0] KBDR //keyboard data register
	);
	
	always@(posedge clk or negedge reset_n)begin
		if(!reset_n)begin
			KBSR <= 0;
			KBDR <= 0;
		end else begin
			if(KBSR_enable) KBSR <= data;
			else KBSR <= KBSR;
			KBDR <= foreignData;
		end
	end
endmodule

module io_output(
	input[15:0] data,
	input clk,
	input reset_n,
	input DDR_enable, DSR_enable,
	output reg[15:0] DDR, DSR //display data/status register
	);
	
	always@(posedge clk or negedge reset_n)begin
		if(!reset_n)begin
			DDR <= 0;
			DSR <= 0;
		end else begin
			if(DDR_enable) DDR <= data;
			else DDR <= DDR;
			if(DSR_enable) DSR <= data;
			else DSR <= DSR;
		end
	end
endmodule
