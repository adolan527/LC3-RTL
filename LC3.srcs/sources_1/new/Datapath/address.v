`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/16/2024 07:57:32 PM
// Design Name: 
// Module Name: address
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


module address(
	input[15:0] SR1, PC,
	input[10:0] PCoffset11,
	input[8:0] PCoffset9,
	input[5:0] offset6,
	input ADDR1MUX,
	input[1:0] ADDR2MUX,
	output reg[15:0] result
    );
	
	localparam PCFLAG = 1'b0;
	localparam SR1FLAG = 1'b1;
	
	localparam ZERO = 2'b00;
	localparam OFF6 = 2'b01;
	localparam OFF9 = 2'b10;
	localparam OFF11 = 2'b11;
	
	reg[15:0] mux1, mux2;
	
	always@(*)begin
		case(ADDR1MUX)
			PCFLAG: mux1 <= PC;
			SR1FLAG: mux1 <= SR1;
		endcase
		
		case(ADDR2MUX)
			ZERO: mux2 <= 0;
			OFF6: mux2 <= $signed(offset6);
			OFF9: mux2 <= $signed(PCoffset9);
			OFF11: mux2 <= $signed(PCoffset11);
		endcase
		
		result <= mux1 + mux2;
	end
		
endmodule
