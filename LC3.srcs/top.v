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

lc3 lc3_inst(
 .clk(clk),.reset_n(reset_n));

always #5 clk = ~clk;

initial begin
clk = 0; reset_n = 0; #10
reset_n = 1; #1000
reset_n=0;
end

endmodule

