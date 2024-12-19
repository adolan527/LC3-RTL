`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/17/2024 12:16:10 PM
// Design Name: 
// Module Name: misc
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


module instructionRegister(
    input[15:0] data,
    input clk, input reset_n,
    output reg[15:0] instruction
    );

    always@(posedge clk or negedge reset_n)begin
        if(!reset_n) instruction <= 0;
        else instruction <= data;
    end
endmodule

module SR2mux(
    input[15:0] SR2,
    input[15:0] instruction,
    output reg[15:0] result
    );
    always@(*)begin
        if(instruction[5]) result<= $signed(instruction[4:0]);
        else result<=SR2;
    end
endmodule

module MARmux(
    input[15:0] addressResult,
    input[15:0] instruction,
    input select,
	input GateMARmux,
    output reg[15:0] result
    );
	
	reg[15:0] temp;
    always@(*)begin
        if(select) temp <= addressResult;
        else temp<= {0,instruction[7:0]};
    end
	
	always@(*) if(GateMARmux) result<=temp; else result<={16'bz};
endmodule
