`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/19/2024 10:54:10 AM
// Design Name: 
// Module Name: constants
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


`ifndef CONTROLLER_CONSTANTS
`define CONTROLLER_CONSTANTS


`define OPCODE_ADD 	4'b0001
`define OPCODE_AND 	4'b0101
`define OPCODE_BR 	4'b0000
`define OPCODE_JMP 	4'b1100
`define OPCODE_JSR 	4'b0100
`define OPCODE_LD 	4'b0010
`define OPCODE_LDI 	4'b1010
`define OPCODE_LDR 	4'b0110
`define OPCODE_LEA 	4'b1110
`define OPCODE_NOT 	4'b1001
`define OPCODE_RTI 	4'b1000
`define OPCODE_ST 	4'b0011
`define OPCODE_STI 	4'b1011
`define OPCODE_STR 	4'b0111
`define OPCODE_TRAP 4'b1111
`define OPCODE_RESERVED 	4'b1101



`endif


