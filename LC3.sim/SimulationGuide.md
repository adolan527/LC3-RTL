
# Simulation Information

## System tests

The main directory where all simulation is done.
Contains individual test directories, along with scripts to aid in simulation.

### Test directories

Each test contains the following:

- NAME_tb.v
- NAME.wcfg
- main.asm, main.obj, main.sym, main.hex
- verilog_memDump.hex, pennSim_memDump.hex
- verilog_trace.hex, pennSim_trace.hex
- state.csv
- sim.log

### NAME_tb.v

The test bench which Vivado uses to run simulation. 
Copied from TEST_TEMPLATE/TEMPLATE_TB.V, this file instantiates LC3.v, and
probes it for multiple data points which are stored in the other files.

### NAME.wcfg

Used by Vivado to display the waveform. Copied from TEST_TEMPLATE/TEMPLATE.wcfg,
this file will be modified on a per test basis moreso than the tb.v

### main.asm, main.obj, main.sym, main.hex

Assembly source code written by the user is stored in main.asm. It is 
compiled by PennSim to create the main.obj and main.sym files. 
The main.hex file is used to load into the LC3 memory during testing.

### verilog_memDump.hex, pennSim_memDump.hex, verilog_trace.hex, pennSim_trace.hex

Memory dump from the verilog test, and the PennSim simulator. 
Trace files output the program's state in verilog and the simulator in the following format:
1. Program Counter
2. Instruction 
3. Register File Write Enable
4. Register File Data Input
5. Memory Write Enable
6. Memory Write Address
7. Memory Data Input 

These files should be identical. 
They are compared, with the results of the comparison being stored in sim.log.

### state.csv

Similar to the trace files, this outputs the program's state after every instruction.
It's data is in the format of:
1. Instruction
1. Next State 
1. Program Counter
1. Program Status Register
1. R0
1. R1
1. R2
1. R3
1. R4
1. R5
1. R6
1. R7

## How to use scripts

### Create test

Create a new test directory by running **newTest.bat**.
It will prompt you for a test name, then it will create a
directory with the template files renamed.

### Write assembly

Open the test directory you just created, and write in the main.asm file.
Then, run **pennSim.bat** with your test directory as an argument.
This can also be done by dragging the folder onto the pennSim.bat file.
This will run PennSim and create a main.hex file.

Note: the *pennSimScript* file is piped into PennSim. It has a breakpoint at 0x0020.

### Run simulation

Set the testbench in your test directory as the top module in Vivado or your simulator of choice.
It is recommended to use the .wcfg file that is created, but not required.
The testbench will create a state.csv, memDump.hex, and trace.hex file which can be viewed.

### Compare .hex files

Run **compare.bat** with your test directory as an argument, similar to the pennSim.bat file.
This will compare the hex files, then store the data in sim.log and print to the command line.


## Other Directories

### Module tests
	
Used to test individual modules. 
Currently is very sparse.
Some module testbenches are defined next to their module definitions in the source code.
This shoue be updated.

### Vivado files

Contains simulation sets created by Vivado upon simulation.

