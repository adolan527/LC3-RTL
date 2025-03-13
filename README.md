# LC3
![LC3](https://github.com/adolan527/LC3-RTL/blob/master/LC3.png)
## Project Overview and Motivations
The LC3 micro-architecture is defined in the book "Introduction to Computing Systems" by Patt & Patel. 
This ISA is often used as a resource to teach computer engineers the fundamentals of assembly and CPU architecture.
This repository is an implementation of the design outlined in the aforementioned textbook, in Verilog using Vivado.
The goal of this project is to understand CPU microarchitecture and have a design to build upon for future projects. (ie. implementing pipelining, threads, etc)

The LC3 functions properly in its current implementation, with the only limitation being memory size.
It is currently limited to 128 words of memory. The next step in this project 
is expanding the  memory and verifying functionality with the OS.

Additionally, optimizations can be made to the controller to allow for faster clock speeds and
easier verification. The main improvement is separating the control structure into a 
microsequencer and control store, as opposed to an FSM and mux model.

Lastly, implementation onto an FPGA and integration in a larger system, ie. with IO, 
is the long-term goal of this project.

## Project Structure
### LC3.src/
This directory contains all of the source files for the design.
**Controller/, Datapath/, and Memory/** all contain their respective files.
**sources_1/** contains the Vivado generated files corresponding to the IP. 
### LC3.sim/
This directory contains the testbenches which have been used to verify and the system as a whole.
Read LC3.sim/SimulationGuide.md for more details.
Makes use of [PennSim](https://acg.cis.upenn.edu/milom/cse240-Fall06/pennsim/pennsim-guide.html)
### LC3.ip_user_files/
This directory contains the majority of the Vivado generated files corresponding to IP's used.
The only IP used for this project is a block memory generator. 
It is currently not used, as a custom implementation allows for easier debugging at the cost of limited size.

