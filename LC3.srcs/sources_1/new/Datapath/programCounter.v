`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/16/2024 07:25:04 PM
// Design Name: 
// Module Name: pc
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


module programCounter(//Stores the program counter, gated output to databus. PC selects from PC+1, address from bus, or address from adder (ex: using a LDR).
	input[1:0] pcMux,//selects where the next PC value should come from
	input[15:0] bus, adder, //data bus and address adder values
	input clk, reset_n, GatePC, LDPC, 
	output reg[15:0] result //the output towards the data bus
	);
	localparam PCINC = 2'b00;
	localparam BUS = 2'b01;
	localparam ADDER = 2'b10;
	localparam NONE = 2'b11;
	
	reg[15:0] PC;
	
	always@(posedge clk or negedge reset_n)begin
		if(!reset_n) PC <= 0;
		else if(LDPC) case(pcMux)
			PCINC: PC <= PC+1;
			BUS: PC <= bus;
			ADDER: PC <= adder;
			default: PC <= 0;
		endcase
		else PC <= PC;
	end
	
	always@(*) if(GatePC) result<=PC; else result<={16'bz};
	
endmodule

module programCounter_tb();//TODO run tb
	reg  clk, reset_n, GatePC, LDPC;
	reg[1:0]  pcMux;
	reg[15:0]  bus, adder;
	wire[15:0] result;

	programCounter programCounter_inst(
	 .pcMux(pcMux),.bus(bus),.adder(adder),.clk(clk),.reset_n(reset_n),.GatePC(GatePC),.LDPC(LDPC),.result(result));

	always #5 clk = ~clk;

	initial begin
		clk = 0; reset_n = 0; pcMux = 0; bus = 16'h8888; adder = 16'h9999; GatePC = 0; LDPC = 0; #50 //PC will remain 0, output is Z
		GatePC = 1; #10 //the result will be 0
		LDPC =1; #50 //Will increment 5 times and output as it increments
		pcMux = 1; #10//Will take input from bus, result will be 8888;
		pcMux = 2; #10//Will take adder value, 9999;
		pcMux = 3; #10//reset
		GatePC = 0 pcMux = 1; bus =  16'hFFF0 #10//no output, value set to FFF0
		pcMux = 0; #100 //inc 10  times
		GatePC = 1;#10
		LDPC = 0;#10
		reset_n = 0;
		
		
		
		
		
		
		
	end
	
endmodule
