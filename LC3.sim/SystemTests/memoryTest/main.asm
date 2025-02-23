; Testing the LD, LDR, LEA, ST, and STR instructions

.ORIG #0

; Assumes memory is zero-init
AND R0 R0 #0 	;clear R0
AND R1 R1 #0 	;clear R1

LD R0 VAL1 		;Load VAL1 into R0
LEA R1 VAL2 	;Load address of VAL2 into R1
LDR R0 R1 #0 	;Load the data pointed to by R1 into R0 (VAL2)

ST R0 VAL3		;Store the data from R0 into VAL3
LEA R1 VAL4		;Store the address of VAl4 into R1
STR R0 R1 #0	;Store the data in R0 into the data pointed to by R1 (VAL4)

AND R0 R0 #0 	;clear R0
AND R1 R1 #0 	;clear R1

LEA R0 PTR		;Load PTR adr into R0
LEA R1 FAR		;Load FAR adr into R1
STR R1 R0 #0	;Store adr of FAR into PTR
LDI R2 PTR		;Loads the value of FAR into R2 through PTR
ADD R2 R2 #10	;Adds 10 to R2
STI R2 PTR		;Stores data back into FAR


VAL1: .FILL x1234
VAL2: .FILL x8888
VAL3: .FILL xFFFF
VAL4: .FILL x0001
PTR: .FILL x0000
FAR: .FILL x9090
.END

