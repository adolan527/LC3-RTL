`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/16/2024 07:25:04 PM
// Design Name: 
// Module Name: pc
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


module programCounter(
	input[1:0] pcMux,
	input[15:0] bus,
	input [15:0] adder,
	input clk,
	input reset_n,
	input GatePC,
	output reg[15:0] result
	);
	localparam PCINC = 2'b00;
	localparam BUS = 2'b01;
	localparam ADDER = 2'b10;
	localparam NONE = 2'b11;
	
	reg[15:0] PC;
	
	always@(posedge clk or negedge reset_n)begin
		if(!reset_n) PC <= 0;
		else 
		case(pcMux)
			PCINC: PC <= PC+1;
			BUS: PC <= bus;
			ADDER: PC <= adder;
			default: PC <= 0;
		endcase
	end
	
	always@(*) if(GatePC) result<=PC; else result<={16'bz};
	
endmodule
