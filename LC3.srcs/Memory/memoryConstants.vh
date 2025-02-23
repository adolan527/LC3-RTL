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


`ifndef MEMORY_CONSTANTS
`define MEMORY_CONSTANTS

// inmuxSelect values
// Used by addressControlLogic.v and memory.v
`define MEMORYREAD  2'b00
`define DSRREAD     2'b01
`define KBSRREAD    2'b10
`define KBDRREAD    2'b11

// IO addresses
// Used by addressControlLogic.v
`define KBSR_ADDRESS    16'hFE00
`define KBDR_ADDRESS    16'hFE02
`define DSR_ADDRESS     16'hFE04
`define DDR_ADDRESS     16'hFE06




`endif


