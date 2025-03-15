`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/16/2024 05:51:00 PM
// Design Name: 
// Module Name: conditionCode
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

/*
module conditionCode(
	input[15:0] data,
	input LDCC, //should the condition codes be update
	input clk,
	input reset_n,
	output reg N, Z, P
    );
	always@(posedge clk or negedge reset_n)begin
		if(!reset_n)begin
			N<=0;
			Z<=0;
			P<=0;
		end
		else if(LDCC)begin
			//the controller will make sure that LDCC is enable at the right time
			N <= data[15]; //data[15] is the "sign" bit in 2's
			Z <= !(|data); //ROOM for optimization by "reusing" the reduction OR here
			P <= !data[15] && |data[14:0];
		end
	end
	
endmodule
*/
//ConditionCode tb
module cctb();

	reg[15:0] data;
	reg LDCC, clk, reset_n;
	wire N, Z, P;

	conditionCode dut(.data(data),.LDCC(LDCC),.clk(clk),.reset_n(reset_n),.N(N),.Z(Z),.P(P));
	
	initial begin
		clk = 0;
		reset_n = 0;
		data = 0;
		LDCC = 0;
	end
	
	always #5 clk = ~clk;
	
	initial begin
		reset_n = 0;#10
		reset_n = 1; LDCC = 1; #10
		data = 16'hFFFF;#10
		data = 16'h0FFF;#10
		data = 16'h0000;#10
		reset_n = 0;
	end
endmodule
