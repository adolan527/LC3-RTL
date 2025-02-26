`timescale 1ns / 1ps

`define STATE_PATH "C:/Users/Aweso/Verilog/LC3/LC3.sim/SystemTests/memoryTest/state.csv"
`define MEMDUMP_PATH "C:/Users/Aweso/Verilog/LC3/LC3.sim/SystemTests/memoryTest/memDump.hex"

module top();

reg clk, reset_n;
wire [16*`MEMORY_WORDCOUNT-1:0] debugMemoryRead;
wire [16 * 8 -1:0] debugRegRead;

wire [5:0] currentState, nextState;
reg[15:0] registers[7:0];
reg[15:0] mem[`MEMORY_WORDCOUNT-1:0];
reg[15:0] first32mem[31:0];
wire [15:0] instruction;

lc3 lc3_inst( //instantiation
 .clk(clk),.reset_n(reset_n),.debugMemoryRead(debugMemoryRead),.debugRegRead(debugRegRead),.debugInstruction(instruction),.debugCurrentState(currentState),.debugNextState(nextState));

always #5 clk = ~clk; //clock


genvar j; // makes mem, registers, and first32mem equal to system values for easier debugging
generate
	for (j = 0; j < `MEMORY_WORDCOUNT; j = j + 1) begin
		always @(*) mem[j] <= debugMemoryRead[(j+1)*16 -1 : j*16];  
	end
	for(j=0; j < 8; j = j + 1)begin
		always @(*) registers[j] <= debugRegRead[(j+1)*16 -1 : 16 * j];
	end
	for(j=0; j < 32; j = j + 1)begin
		always @(*) first32mem[j] <= debugMemoryRead[(j+1)*16 -1 : 16 * j];
	end	
endgenerate


integer file;

// **Initial Task: Runs at the Beginning of Simulation**
task write_initial;
    begin
        file = $fopen(`STATE_PATH, "w"); // Open file in write mode (overwrite old content)
        
        if (file) begin
            $fwrite(file, "INSTRUCTION, CurrentState, NextState, R0, R1, R2, R3, R4, R5, R6, R7\n"); // Write header
            $fclose(file); // Close file after writing
        end
        else begin
            $display("Error: Could not open output.csv");
        end
    end
endtask

// **Update Task: Runs Periodically During Simulation**
task write_update;
    begin
        file = $fopen(`STATE_PATH, "a"); // Open file in append mode
        
        if (file) begin
            $fwrite(file, "%h, %h, %h, %h, %h, %h, %h, %h, %h, %h, %h\n",
                    instruction, currentState, nextState, registers[0], registers[1], registers[2], registers[3], 
                    registers[4], registers[5], registers[6], registers[7]);
            $fclose(file); // Close file after writing
        end
        else begin
            $display("Error: Could not open output.txt");
        end
    end
endtask

// **Final Task: Runs at the End of Simulation**
task write_final;
    begin
		$writememh(`MEMDUMP_PATH, mem);
    end
endtask

always@(*)begin //writes to file the program state every fetch command
	if(nextState == 6'd18) begin //FETCH
		write_update();
	end
end

initial begin
write_initial();
clk = 0; reset_n = 0; #10
reset_n = 1; #1900
reset_n = 0;
write_final();
end

endmodule

