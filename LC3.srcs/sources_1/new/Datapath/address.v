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


module address( //generates an address for the PCMUX and MARMUX
	input[15:0] SR1, PC, instruction,
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
			OFF6: mux2 <= $signed(instruction);
			OFF9: mux2 <= $signed(instruction);
			OFF11: mux2 <= $signed(instruction);
		endcase
		
		result <= mux1 + mux2;
	end
		
endmodule

module address_tb();
	reg  ADDR1MUX;
	reg[1:0]  ADDR2MUX;
	reg[15:0]  SR1, PC, instruction;
	wire[15:0] result;

	address address_inst(
	 .SR1(SR1),.PC(PC),.instruction(instruction),.ADDR1MUX(ADDR1MUX),.ADDR2MUX(ADDR2MUX),.result(result));

	initial begin
	//TODO Test address module
	
	end
	
endmodule

	