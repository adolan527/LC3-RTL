`timescale 1ns / 1ps



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
