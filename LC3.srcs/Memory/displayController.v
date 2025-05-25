`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/19/2024 01:32:23 AM
// Design Name: 
// Module Name: io
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
`include "memoryConstants.vh"


//Controls the io of the Keyboard, Console, and importantly the Display

module displayController(
	input clk, reset_n,
	
	input[15:0] foreignKeyboardInput,
	input keyboardValid,
	output[15:0] KBDR,
	output KBSR,
	
	input[15:0] DDR,
	input DSR,
	output[15:0] foreignConsoleOutput,
	output consoleValid,
	
	input[15:0] memoryRead,
	output[15:0] address,
	output[15:0] displayData,
	output displayValid
	);
	
	
	
endmodule