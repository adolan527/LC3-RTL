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


`ifndef GLOBAL_CONSTANTS
`define GLOBAL_CONSTANTS

// Memory 
`define MEMORY_WORDCOUNT 128 // Number of words in memory. A smaller value is used for debugging. Real application will use IP RAM

// MUX select values that the Controller uses to control the Datapath.

// Values for ADDR1MUX. Selects the offset to add to Address 1 in the address adder
// Used in controller.v and address.v
`define ADDR1MUX_PC 1'b0
`define ADDR1MUX_SR1 1'b1

// Values for ADDR2MUX. Selects the offset to add to Address 2 in the address adder
// Used in controller.v and address.v
`define ADDR2MUX_OFFSET_0 2'b00
`define ADDR2MUX_OFFSET_6 2'b01
`define ADDR2MUX_OFFSET_9 2'b10
`define ADDR2MUX_OFFSET_11 2'b11

// Values used for SR1adrMUX. Selects the value to be used as the address of SR1 in the regFile.
// Used in controller.v and misc.v
`define SR1MUX_FIRST 2'b00
`define SR1MUX_SECOND 2'b01
`define SR1MUX_SIX 2'b10
`define SR1MUX_ZERO 2'b11

//Values used for DRmux. Selects the value to be used as the address of DR in the regFile.
// Used in controller.v and misc.v
`define DRMUX_FIRST 2'b00
`define DRMUX_SIX 2'b01
`define DRMUX_SEVEN 2'b10
`define DRMUX_ZERO 2'b11

// Values used for MARMUX. Selects address to be sent to databus
// Used in controller.v and misc.v
`define MARMUX_ADR_SUM 1'b0
`define MARMUX_INSTR 1'b1

// Values used for PCMUX. Selects the value for next PC
// Used in controller.v and programCounter.v
`define PCMUX_INC  2'b00
`define PCMUX_BUS  2'b01
`define PCMUX_ADDR 2'b10
`define PCMUX_ZERO 2'b11


//Interrupt
//Values used in stack pointer mux
`define SPMUX_INC	2'b00
`define SPMUX_DEC	2'b01
`define SPMUX_SSP	2'b10
`define SPMUX_USP	2'b11

//Values used in TRAPBLock
`define VectorMUX_INTV	2'b00
`define VectorMUX_0	2'b01
`define VectorMUX_1	2'b10
`define VectorMUX_2	2'b11

//Values used in PSRBloack
`define PSRMUX_Individual 1'b0
`define PSRMUX_Databus 1'b1

//Values used in TRAPBLock
`define TableMUX_0 1'b0
`define TableMUX_1 1'b1

`endif


