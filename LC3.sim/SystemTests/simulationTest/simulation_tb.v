`timescale 1ns / 1ps

`define STATE_PATH "C:/Users/Aweso/Verilog/LC3/LC3.sim/SystemTests/simulationTest/state.csv" // write program state every instruction
`define MEMDUMP_PATH "C:/Users/Aweso/Verilog/LC3/LC3.sim/SystemTests/simulationTest/verilog_memDump.hex" // dump memory after test
`define MEMLOAD_PATH "C:/Users/Aweso/Verilog/LC3/LC3.sim/SystemTests/simulationTest/main.hex" // load hex-ified obj file
`define TRACE_PATH "C:/Users/Aweso/Verilog/LC3/LC3.sim/SystemTests/simulationTest/verilog_trace.hex" // pennsim style trace


module simulation_tb();

reg clk, reset_n;
wire [16*`MEMORY_WORDCOUNT-1:0] debugMemoryRead;
wire [16 * 8 -1:0] debugRegRead;

wire [5:0] currentState, nextState;
reg[15:0] registers[7:0];
reg[15:0] mem[`MEMORY_WORDCOUNT-1:0];
reg[15:0] first32mem[31:0];
wire [15:0] instruction;
wire [15:0] PSR, PC, dataBus, MAR, MDR;
wire LDREG, MIOEN, RW;

lc3 #(.MEMORY_INIT_FILE(`MEMLOAD_PATH)) lc3_inst( //instantiation 
 .clk(clk),.reset_n(reset_n),
 .debugMemoryRead(debugMemoryRead),
 .debugRegRead(debugRegRead),
 .debugInstruction(instruction),
 .debugCurrentState(currentState),
 .debugNextState(nextState),
 .debugPSR(PSR),
 .debugPC(PC),
 .debugDatabus(dataBus),
 .debugMARRead(MAR),
 .debugMDRRead(MDR),
 .debugLDREG(LDREG),
 .debugMIOEN(MIOEN),
 .debugRW(RW)
 );

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



integer state_file;
integer pennsim_trace_file;

// **Initial Task: Runs at the Beginning of Simulation**
task write_initial;
    begin
        state_file = $fopen(`STATE_PATH, "w"); // Open file in write mode (overwrite old content)
        
        if (state_file) begin
            $fwrite(state_file, "INSTRUCTION, NextState, PC, PSR, R0, R1, R2, R3, R4, R5, R6, R7\n"); // Write header
            $fclose(state_file); // Close file after writing
        end
        else begin
            $display("Error: Could not open output.csv");
        end
    end
endtask

// **Update Task: Runs before each fetch During Simulation**
task write_update;
    begin
        state_file = $fopen(`STATE_PATH, "a"); // Open file in append mode
        
        if (state_file) begin
            $fwrite(state_file, "%h, %h, %h, %h, %h, %h, %h, %h, %h, %h, %h, %h\n",
                    instruction, nextState, PC, PSR,registers[0], registers[1], registers[2], registers[3], 
                    registers[4], registers[5], registers[6], registers[7]);
            $fclose(state_file); // Close file after writing
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



task pennsim_trace_initial;
	begin
	pennsim_trace_file = $fopen(`TRACE_PATH, "w"); // Open file in write mode, clear it
	$fclose(pennsim_trace_file);	
	end
endtask

reg[15:0] PCdec;
reg [15:0] lastRegisterInput, didRegisterWrite, lastMemoryInput, lastMemoryAddress, didMemoryWrite; //stores the last input to the regfile/memory during this instruction

task pennsim_trace;
	begin
	PCdec = PC - 1;
	pennsim_trace_file = $fopen(`TRACE_PATH, "a"); // Open file in append mode		
	$fwrite(pennsim_trace_file, "%h %h %h %h %h %h %h\n",
                    PCdec, instruction, didRegisterWrite, lastRegisterInput, didMemoryWrite, lastMemoryAddress, lastMemoryInput);
	lastRegisterInput = 0;
	didRegisterWrite = 0;
	lastMemoryInput = 0;
	lastMemoryAddress = 0;
	didMemoryWrite = 0;
	$fclose(pennsim_trace_file);	
	end
endtask


integer doLog;
always@(*)begin //writes to file the program state every fetch command

	if(instruction == 16'hFFFF)begin
		write_final();
		$stop;
	end

	if(LDREG) lastRegisterInput = dataBus;
	if(LDREG) didRegisterWrite = 1;
	if(RW) lastMemoryInput = MDR;
	if(RW) lastMemoryAddress = MAR;	
	if(RW) didMemoryWrite = 1;
	if(nextState == 6'd18) begin //FETCH
		doLog = 1;
	end
	else if(currentState == 6'd18 && doLog == 1) begin
		write_update();
		if(instruction != 0 && instruction) pennsim_trace();
		doLog = 0;
	end
	
	
end

initial begin
write_initial();
pennsim_trace_initial();
doLog = 0;
clk = 0; reset_n = 0; #10
reset_n = 1; #1900
reset_n = 0;
write_final();
end

endmodule

