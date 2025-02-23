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
`include "../globalConstants.vh"

module address( //generates an address for the PCMUX and MARMUX
	input[15:0] SR1, PC, instruction, //sourceRegister1
	input ADDR1MUX,  //0: PC, 1: SR1
	input[1:0] ADDR2MUX, //offset select
	output reg[15:0] result
    );
		
	reg[15:0] mux1, mux2;
	
	always@(*)begin
		case(ADDR1MUX)
			`ADDR1MUX_PC: mux1 <= PC;
			`ADDR1MUX_SR1: mux1 <= SR1;
		endcase
		
		case(ADDR2MUX)
			`ADDR2MUX_OFFSET_0: mux2 <= 0;
			`ADDR2MUX_OFFSET_6: mux2 <= $signed(instruction[5:0]);
			`ADDR2MUX_OFFSET_9: mux2 <= $signed(instruction[8:0]);
			`ADDR2MUX_OFFSET_11: mux2 <= $signed(instruction[10:0]);
		endcase
		
		result <= mux1 + mux2;
	end
		
endmodule


	