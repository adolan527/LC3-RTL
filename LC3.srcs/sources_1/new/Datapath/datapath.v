`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/19/2024 01:18:31 AM
// Design Name: 
// Module Name: datapath
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


module datapath(

    );
    
MARmux MARmux_inst();
SR2mux SR2mux_inst();
instructionRegister instructionRegister_inst();
programCounter programCounter_inst();
ALU ALU_inst();
address address_inst();
conditionCode conditionCode_inst();
regFile regFile_inst();
    
endmodule
