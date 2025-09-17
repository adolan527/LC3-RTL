# LC3
![LC3](https://github.com/adolan527/LC3-RTL/blob/master/LC3.png)
## Project Overview and Motivations
The LC3 micro-architecture is defined in the book "Introduction to Computing Systems" by Patt & Patel. 
This ISA is often used as a resource to teach computer engineers the fundamentals of assembly and CPU architecture.
This repository is an implementation of the design outlined in the aforementioned textbook, in Verilog using Vivado.
The goal of this project is to understand CPU microarchitecture and have a design to build upon for future projects. (ie. implementing pipelining, threads, etc)

The LC3 functions properly in its current implementation, with the main limitation begin IO.
To properly implement memory-mapped IO would require using a dual-port RAM and creating an interface (most likely UART) to manage IO operations between the FPGA ports and microprocessor.

## Simulation
A skill that this project forced me to learn was the importance of automation in testing. Within the LC3.sim/ directory, one can find a guide on the simulation process.
This reduced the simulation process to a few simple scripts that minimize the marginal costs of testing features while providing full coverage.


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

