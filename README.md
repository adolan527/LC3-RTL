# LC3
![LC3](https://github.com/adolan527/LC3-RTL/blob/master/LC3.png)
## Project Overview and Motivations
The LC3 micro-architecture is defined in the book "Introduction to Computing Systems" by Patt & Patel. 
This ISA is often used as a resource to teach computer engineers the fundamentals of assembly and CPU architecture.
This repository is an implementation of the design outlined in the aforementioned textbook, in Verilog using Vivado.
The goal of this project is to understand CPU microarchitecture and have a design to build upon for future projects. (ie. implementing pipelining, threads, etc)
The project's status is as follows: 
 - Datapath - Completed and mostly verified
 - Memory - Mostly completed and partially verified
 - Controller - Partially completed

## Project Structure
### LC3.src/
This directory contains all of the source files for the design.
**Controller/, Datapath/, and Memory/** all contain their respective files.
**sources_1/** contains the Vivado generated files corresponding to the IP. 
### LC3.sim/
This directory contains the testbenches which have been used to verify modules.
**DatapathModules/** contains some module specific testbenches for parts of the datapath. 
**SystemTests/** contains "end-to-end" tests of the design. Each test has the following components:
 - *main.asm* - Assembly code which is assembled before being loaded into the LC3
 - *main.bin, main.hex, main.obj* - Assembled code generated by ![LC3-EDIT](https://highered.mheducation.com/sites/0072467509/student_view0/lc-3_simulator.html)
 - *main.lst, main.sym* - Assembled code, memory view, and symbol table generated by LC3-EDIT.
 - *memDump.hex* - First 128 bytes of memory dumped from Verilog at the end of the testbench.
 - *state.csv* - Instruction, controller state, and register values of LC3, written from testbench. Logged during last state of each instruction.
 - *top.v* - Testbench verilog implementation.
**sim_1/** contains Vivado generated files corresponding to the IP.
### LC3.ip_user_files/ and LC3.gen
This directory contains the majority of the Vivado generated files corresponding to IP's used.
The only IP used for this project is a block memory generator. 
It is currently not used, as a custom implementation allows for easier debugging at the cost of limited size.

