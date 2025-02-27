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

reg clk, reset_n;
/*
wire [16*`MEMORY_WORDCOUNT-1:0] debugMemoryRead;
wire [16 * 8 -1:0] debugRegRead;

wire [5:0] currentState, nextState;
reg[15:0] registers[7:0];
reg[15:0] mem[`MEMORY_WORDCOUNT-1:0];
reg[15:0] first32mem[31:0];
wire [15:0] instruction;
*/

lc3 (
.clk(clk),
.reset_n(reset_n) //,
/*
.debugMemoryRead(debugMemoryRead),
.debugRegRead(debugRegRead),
.debugInstruction(instruction),
.debugCurrentState(currentState),
.debugNextState(nextState)
*/
);

always #5 clk = ~clk;



initial begin
clk = 0; reset_n = 0; #10
reset_n = 1; #1900
reset_n = 0;
end

endmodule

