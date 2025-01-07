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

module instructionRegister_tb();
	reg  clk, reset_n, enable;
	reg[15:0]  data;
	wire[15:0] instruction;

	instructionRegister instructionRegister_inst(
	 .data(data),.clk(clk),.reset_n(reset_n),.enable(enable),.instruction(instruction));

	always #5 clk = ~clk;


initial begin
	clk = 0; reset_n = 0; #10
	reset_n = 1;#10
	data = 16'd100;#10
	data = 16'd984;#10
	enable = 1; data = 16'd54;#10
	enable = 0; data = 0;#10
	enable = 1;#10
	data = 16'd50;#10
	reset_n = 0;#10
	reset_n = 1;
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

module SR2mux_tb(); //Confirms the sign extension works as intended
	reg[15:0]  SR2, instruction;
	wire[15:0] result;

	SR2mux SR2mux_inst(
	 .SR2(SR2),.instruction(instruction),.result(result));

initial begin
	SR2 = 16'hFFFF; instruction = 16'h0000;#10 //Expected output: SR2 FFFF
	instruction = 16'h0029; #10 //inst 0009
	instruction = 16'h0019; #10 //SR2 FFFF
	instruction = 16'h002F; #10 //inst 000f
	instruction = 16'h003F; #10 //inst FFFF
	instruction = 16'h0039;		//inst FFF9 
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
	output reg[2:0] SR1
	);
	always@(*) begin
		case(SR1MUX)
			2'b00: SR1<=instruction[11:9];
			2'b01: SR1<=instruction[8:6];
			2'b10: SR1<=3'b110;
			2'b11: SR1<=0;
		endcase
	end
endmodule

module DRadrMux(
	input[1:0] DRMUX,
	input[15:0] instruction,
	output reg[2:0] DR
	);
	always@(*) begin
		case(DRMUX)
			2'b00: DR<=instruction[11:9];
			2'b01: DR<=3'b110;
			2'b10: DR<=3'b111;
			2'b11: DR<=0;
		endcase
	end
endmodule