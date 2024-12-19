`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/16/2024 03:43:02 PM
// Design Name: 
// Module Name: regFile
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

//clk and reset_n are not explicity described in the textbook but can be assumed

module regFile(
	input[15:0] data, //databus input
	input[2:0] DR, //destination register. Address of the register to write to
	input LDREG, //active high write enable bit. 
	input[2:0] SR1, SR2, //source registers 1 and 2. Address of register to read from
	input clk, //clk
	input reset_n, //active low async reset.
	output reg[15:0] SR1out, SR2out //data from source registers 1 and 2
    );
	
	//each register is 1 word, 16 bits.
	//8 registers
	
	wire[7:0] regOut, regSelect, regEnable;
	
	decoder decode(.in(DR),.out(regSelect));
	
	genvar i;
	generate
	for(i = 0; i < 8; i = i + 1)begin
		register ri(.d(data),.enable(regEnable[i]),.clk(clk),.reset_n(reset_n),.q(regOut[i]));
		assign regEnable[i] = regSelect[i] & LDREG;
	end
	endgenerate
	
	always@(*)begin
		case(SR1)
			0: SR1out <= regOut[0];
			1: SR1out <= regOut[1];
			2: SR1out <= regOut[3];
			3: SR1out <= regOut[2];
			4: SR1out <= regOut[4];
			5: SR1out <= regOut[5];
			6: SR1out <= regOut[6];
			7: SR1out <= regOut[7];
		endcase
		case(SR2)
			0: SR2out <= regOut[0];
			1: SR2out <= regOut[1];
			2: SR2out <= regOut[3];
			3: SR2out <= regOut[2];
			4: SR2out <= regOut[4];
			5: SR2out <= regOut[5];
			6: SR2out <= regOut[6];
			7: SR2out <= regOut[7];
		endcase		
	end
		
		
endmodule

module decoder(
	input[2:0] in,
	output reg[7:0] out
	);
	always@(*)begin
		case(in)
			3'b000: out <= 8'd0;
			3'b001: out <= 8'd1;
			3'b010: out <= 8'd2;
			3'b011: out <= 8'd3;
			3'b100: out <= 8'd4;
			3'b101: out <= 8'd5;
			3'b110: out <= 8'd6;
			3'b111: out <= 8'd7;
		endcase
	end
endmodule

module register(
	input[15:0] d,
	input enable,
	input clk,
	input reset_n,
	output reg[15:0] q
	);
	
	always@(posedge clk or negedge reset_n)begin
		if(!reset_n) q <= 0;
		else if(enable) q <= d;
		else q <= q;
	end
		
endmodule