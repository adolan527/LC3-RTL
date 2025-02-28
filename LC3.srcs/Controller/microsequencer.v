`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2/27/2025 
// Design Name: 
// Module Name: microsequencer
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

module microsequencer(
	input INT, R, BEN, PSR_MSB, ACV, IRD, //interrupt, read mem, branch enable, program status reg msb, access control violation, instruction register decode
	input[15:11] instruction, //5 msb of state
	input [5:0] J, //current state
	input[2:0] COND, //conditions from microinstruction
	output reg[5:0] control_store_index
	);
	
	// TODO microsequencer ~ next state logic. index into control store ~ output assignment.
	
	reg[5:0] nextState;
	
	always@(*)begin //next state 
		nextState[5] <=	J[5] | (~COND[0] & COND[1] & COND[2] & ACV);
		nextState[4] <=	J[4] | (COND[0] & ~COND[1] & COND[2] & INT);
		nextState[3] <=	J[3] | (~COND[0] & ~COND[1] & COND[2] & PSR_MSB);
		nextState[2] <=	J[2] | (~COND[0] & COND[1] & ~COND[2] & BEN);
		nextState[1] <=	J[1] | (COND[0] & ~COND[1] & ~COND[2] & R);
		nextState[0] <=	J[0] | (COND[0] & COND[1] & ~COND[2] & instruction[11]);
		
		control_store_index <= IRD ? {0,0,instruction[15:12] : nextState;
	end
	
end

