`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/19/2024 10:18:00 AM
// Design Name: 
// Module Name: RAM
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


module RAM(
	input[15:0] MDR, address,
	input RW, MEMEN, //RW - 0 read, 1 write. 
	input clk, reset_n,
	output [15:0] memoryRead,
	output R
	);
	localparam WORDS = 127; //should be 2^ 16 -1, but that is too big.
	reg[15:0] mem[WORDS:0];
	wire[7:0] limitedAddress;
	assign limitedAddress = address[7:0];
	assign memoryRead = mem[address];
	assign R = 1;
	
	integer i;
	always@(posedge clk or negedge reset_n)begin
		if(!reset_n)begin
			for(i=0; i < WORDS; i = i + 1)begin
				mem[i] <= 0;
			end
		end else 
			for(i=0; i < WORDS; i = i + 1)begin
				if(limitedAddress == i && MEMEN && RW) mem[i] <= MDR;
				else mem[i]<=mem[i];
			end
	end
	
	
endmodule

module RAM_DEBUG( //preloaded with data
	input[15:0] MDR, address,
	input RW, MEMEN, //RW - 0 read, 1 write. 
	input clk, reset_n,
	output [15:0] memoryRead,
	output R
	);
	localparam WORDS = 127; //should be 2^ 16 -1, but that is too big.
	reg[15:0] mem[WORDS:0];
	wire[7:0] limitedAddress;
	assign limitedAddress = address[7:0];
	assign memoryRead = mem[address];
	assign R = 1;
	
	initial begin
        $readmemh("C:/Users/Aweso/Verilog/LC3/LC3.sim/memory/aluTest/main.hex", mem); 
    end
	
	integer i;
	always@(posedge clk or negedge reset_n)begin
		if(!reset_n)begin
			$writememh("C:/Users/Aweso/Verilog/LC3/LC3.sim/memory/aluTest/memDump.hex", mem);
		end else 
			for(i=0; i < WORDS; i = i + 1)begin
				if(limitedAddress == i && MEMEN && RW) mem[i] <= MDR;
				else mem[i]<=mem[i];
			end
	end
	
	
endmodule



/*

module RAM_tb();

	reg[15:0] MDR, address;
	reg clk, reset_n, RW, MEMEN;
	wire[15:0] read;

	RAM dut(.MDR(MDR),.address(address),.RW(RW),.MEMEN(MEMEN),.clk(clk),.reset_n(reset_n),.memoryRead(read));

	initial begin
		clk = 0;
		reset_n = 0;
		MDR = 0;
		RW = 0;
		MEMEN = 0;
		address = 0;
	end
		
	always #5 clk = ~clk;

		
	initial begin
		reset_n = 0;#10
		reset_n = 1;#10
		MDR = 20; address = 1; #10
		RW = 1; #10
		MEMEN = 1; RW = 0; #10
		RW = 1; #10
		RW = 0; address = 2; MDR = 30; #10
		RW = 1; #10
		RW = 0; #10
		address = 1;
		
	end
endmodule*/	