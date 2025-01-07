`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/16/2024 03:21:28 PM
// Design Name: 
// Module Name: top
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


module top();

	reg LDREG, clk, reset_n;
	reg[2:0]  DR, SR1, SR2;
	reg[15:0]  data;
	wire[15:0] SR1out, SR2out;

	regFile regFile_inst(
	 .data(data),.DR(DR),.LDREG(LDREG),.SR1(SR1),.SR2(SR2),.clk(clk),.reset_n(reset_n),.SR1out(SR1out),.SR2out(SR2out));

	always #5 clk = ~clk;
	always #10 data = $random;
	always #10 DR = DR + 1;

initial begin
	clk = 0; reset_n = 0; #10
	reset_n = 1; DR = 0; SR1 =0; SR2 = 1; data = 0; LDREG = 0;  #80;
	LDREG = 1; #80;
	reset_n = 0;
	
end
endmodule

