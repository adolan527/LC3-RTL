`timescale 1ns / 1ps



module ALU(
	input[15:0] operand_A,
	input[15:0] operand_B,
	input[1:0] operationSelect,
	input GateALU,
	output reg [15:0] result
	);
	localparam ADD = 2'b00;
	localparam AND = 2'b01;
	localparam NOT = 2'b10;
	localparam NONE = 2'b11;
	reg [15:0]temp;
	always@(*)begin
		case(operationSelect)
			ADD: temp <= operand_A + operand_B;
			AND: temp <= operand_A & operand_B;
			NOT: temp <= ~operand_A;
			NONE: temp <= 2'b00;
			default: temp <= 2'b00;
		endcase
	end
	
	always@(*) if(GateALU) result<=temp; else result<={16'bz};
	
	
endmodule