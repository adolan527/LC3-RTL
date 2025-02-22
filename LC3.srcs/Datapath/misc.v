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
        if(!select) temp <= addressSum;
        else temp<= {0,instruction[7:0]};
    end
	
	always@(*) if(GateMARmux) result<=temp; else result<={16'bz};
endmodule

module accessControlViolation(
	input[15:0] PSR, dataBus,
	output ACV
	);
	assign ACV = PSR[15] & (&dataBus[15:9] | &(~dataBus[15:14]));
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
			2'b00: SR1adr<=instruction[11:9];
			2'b01: SR1adr<=instruction[8:6]; //add, and, not, LDR, STR, JMP, JSRR
			2'b10: SR1adr<=3'b110;
			2'b11: SR1adr<=0;
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
			2'b00: DRadr<=instruction[11:9]; //add, 
			2'b01: DRadr<=3'b110;
			2'b10: DRadr<=3'b111;
			2'b11: DRadr<=0;
		endcase
	end
endmodule