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
This directory will populate further as the project nears completion.
### LC3.ip_user_files/
This directory contains the majority of the Vivado generated files corresponding to IP's used.


