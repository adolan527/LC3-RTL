`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/19/2024 10:20:10 AM
// Design Name: 
// Module Name: addressControlLogic
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



module addressControlLogic(
	input[15:0] MAR,
	input RW, MIOEN,
	output reg MEMEN, KBSR_enable, DDR_enable, DSR_enable,
	output reg [1:0] inmuxSelect
	);

	wire is_kbsr = (MAR == `KBSR_ADDRESS);
	wire is_kbdr = (MAR == `KBDR_ADDRESS);
	wire is_dsr  = (MAR == `DSR_ADDRESS);

	always @(*) begin
		KBSR_enable <= is_kbsr;
		DSR_enable  <= is_dsr;
		DDR_enable  <= 0;
		MEMEN       <= !(is_kbsr || is_kbdr || is_dsr); // Default memory enable
		inmuxSelect <= (is_kbsr) ? `KBSRREAD :
					   (is_kbdr) ? `KBDRREAD :
					   (is_dsr)  ? `DSRREAD  :
								   `MEMORYREAD;
	end
		
endmodule

