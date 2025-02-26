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
`include "../globalConstants.vh"

module instructionRegister(
    input[15:0] data,
    input clk, reset_n, enable,
    output reg[15:0] instruction
    );

    always@(posedge clk or negedge reset_n)begin
        if(!reset_n) instruction <= 0;
        else if(enable) instruction <= data;
		else instruction <= instruction;
    end
endmodule

module SR2mux(
    input[15:0] SR2premux,
    input[15:0] instruction,
    output reg[15:0] SR2
    );
    always@(*)begin
        if(instruction[5]) SR2<= $signed(instruction[4:0]);
        else SR2<=SR2premux;
    end
endmodule


module MARmux( //memory address register mux: controls what address goes into the databus 
    input[15:0] addressSum, //address result from the address Adder
    input[15:0] instruction, 
    input select, //select from controller. 0: addressSum, 1: 8 LSB from instruction
	input GateMARmux, // tristate buffer 
    output reg[15:0] result 
    );
	
	reg[15:0] temp;
    always@(*)begin
		case(select)
			`MARMUX_ADR_SUM: temp <= addressSum;
			`MARMUX_INSTR: temp <= {0,instruction[7:0]};
		endcase
    end
	
	always@(*) if(GateMARmux) result<=temp; else result<={16'bz};
endmodule

module accessControlViolation(
	input[15:0] PSR, dataBus,
	input clk, reset_n, LDACV,
	output reg ACV
	);
	always@(posedge clk or negedge reset_n) begin
		if(!reset_n) ACV <= 0;
		else if(LDACV) ACV <= PSR[15] & //user mode and
			(&dataBus[15:9] | &(~dataBus[15:14])); // Address >= 0xFF00 or Address < 0x3000
		else ACV <= ACV;
	end
	
endmodule

module programStatusRegister(
	input SETPRIV, priorityLevel, N, Z, P, clk, reset_n, GatePSR,
	output reg[15:0] PSR,
	output [15:0] dataBus
	);
	
	always@(posedge clk or negedge reset_n)begin
		if(!reset_n)begin
			PSR <= 0;
		end 
		else begin
			PSR <= {SETPRIV,4'b0000,priorityLevel,5'b00000,N,Z,P};
		end
	end
	
	assign dataBus = GatePSR ? PSR : {16'bz};
	
	
endmodule

module branchEnable(
	input[15:0] instruction,
	input N, Z, P,
	output BEN
	);
	assign BEN = (instruction[11] & N) | (instruction[10] & Z) | (instruction[9] & P);
endmodule

module SR1adrMux(
	input[1:0] SR1MUX,
	input[15:0] instruction,
	output reg[2:0] SR1adr
	);
	always@(*) begin
		case(SR1MUX)
			`SR1MUX_FIRST: SR1adr<=instruction[11:9];
			`SR1MUX_SECOND: SR1adr<=instruction[8:6]; //add, and, not, LDR, STR, JMP, JSRR
			`SR1MUX_SIX: SR1adr<=3'b110;
			`SR1MUX_ZERO: SR1adr<=0;
		endcase
	end
endmodule

module DRadrMux(
	input[1:0] DRMUX,
	input[15:0] instruction,
	output reg[2:0] DRadr
	);
	always@(*) begin
		case(DRMUX)
			`DRMUX_FIRST: DRadr<=instruction[11:9]; //add, 
			`DRMUX_SIX: DRadr<=3'b110;
			`DRMUX_SEVEN: DRadr<=3'b111;
			`DRMUX_ZERO: DRadr<=0;
		endcase
	end
endmodule