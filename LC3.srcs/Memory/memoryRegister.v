`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/19/2024 10:18:00 AM
// Design Name: 
// Module Name: memoryRegister
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



module memoryRegister(
	input[15:0] data, inmux,
	input clk, reset_n,
	output reg[15:0] result,
	output reg[15:0] MAR,
	output reg[15:0] MDR,
	input LDMDR, LDMAR, MIOEN, GateMDR
    );
	
	always@(posedge clk or negedge reset_n)begin
		if(!reset_n)begin
			MAR <= 0;
			MDR <= 0;			
		end else begin
			if(LDMAR) MAR <= data;
			else MAR <= MAR;
			
			if(LDMDR) MDR <= MIOEN ? inmux : data;
			else MDR <= MDR;
		end
	end
	
	always@(*) if(GateMDR) result<=MDR; else result<={16'bz};
endmodule

