`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/16/2024 03:43:02 PM
// Design Name: 
// Module Name: regFile
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


module regFile(
	input[15:0] data, //databus input
	input[2:0] DRadr, //destination register. Address of the register to write to
	input LDREG, //active high write enable bit. 
	input[2:0] SR1adr, SR2adr, //source registers 1 and 2. Address of register to read from
	input clk, //clk
	input reset_n, //active low async reset.
	output reg[15:0] SR1out, SR2out, //data from source registers 1 and 2
	output reg[16 * 8 -1:0] debugRegRead
    );
	
	reg[15:0] registers[7:0];
	reg[7:0] enable;
	integer i;
	always@(posedge clk or negedge reset_n)begin
		for(i=0;i<8;i=i+1) begin
			if (!reset_n) begin
				registers[i] <= 0;
			end
			else if(enable[i]) registers[i] <= data;
			else registers[i] <= registers[i];
		end
	end	
	
	
	
	always@(*)begin
		enable = 0;
		enable[DRadr] = LDREG;
		SR1out = registers[SR1adr];
		SR2out = registers[SR2adr];
	end
	
	genvar j;
    generate
        for (j = 0; j < 8; j = j + 1) begin
            always @(*) begin
                debugRegRead[(j+1)*16 -1 : j*16] = registers[j]; 
            end
        end
    endgenerate
	
endmodule
	
	
/*
module regFile_tb(); //Outdated due to variable name changes
	reg LDREG, clk, reset_n;
	reg[2:0]  DR, SR1, SR2;
	reg[15:0]  data;
	wire[15:0] SR1out, SR2out;

	regFile regFile_inst(
	 .data(data),.DR(DR),.LDREG(LDREG),.SR1(SR1),.SR2(SR2),.clk(clk),.reset_n(reset_n),.SR1out(SR1out),.SR2out(SR2out));

	always #5 clk = ~clk;
	always #10 data = $random;
	always #10 DR = DR + 1;

initial begin
	clk = 0; reset_n = 0; #10
	reset_n = 1; DR = 0; SR1 =0; SR2 = 1; data = 0; LDREG = 0;  #80;
	LDREG = 1; #80;
	reset_n = 0;
	
end

endmodule*/


/*
module regFile_structural( 
	input[15:0] data, //databus input
	input[2:0] DR, //destination register. Address of the register to write to
	input LDREG, //active high write enable bit. 
	input[2:0] SR1, SR2, //source registers 1 and 2. Address of register to read from
	input clk, //clk
	input reset_n, //active low async reset.
	output reg[15:0] SR1out, SR2out //data from source registers 1 and 2
    );
	
	//each register is 1 word, 16 bits.
	//8 registers
	
	wire[7:0] regSelect, regEnable;
	wire[15:0] regOut[7:0];
	
	decoder decode(.in(DR),.out(regSelect));
	
	genvar i;
	generate
	for(i = 0; i < 8; i = i + 1)begin
		register ri(.d(data),.enable(regEnable[i]),.clk(clk),.reset_n(reset_n),.q(regOut[i]));
		assign regEnable[i] = regSelect[i] & LDREG;
	end
	endgenerate
	
	always@(*)begin
		SR1out <= regOut[SR1];
		SR2out <= regOut[SR2];
	end
		
endmodule




module decoder(
	input[2:0] in,
	output reg[7:0] out
	);
	always@(*)begin
		case(in)
			3'b000: out <= 8'd0;
			3'b001: out <= 8'd1;
			3'b010: out <= 8'd2;
			3'b011: out <= 8'd3;
			3'b100: out <= 8'd4;
			3'b101: out <= 8'd5;
			3'b110: out <= 8'd6;
			3'b111: out <= 8'd7;
		endcase
	end
endmodule

module register(
	input[15:0] d,
	input enable,
	input clk,
	input reset_n,
	output reg[15:0] q
	);
	
	always@(posedge clk or negedge reset_n)begin
		if(!reset_n) q <= 0;
		else if(enable) q <= d;
		else q <= q;
	end
		
endmodule

*/

