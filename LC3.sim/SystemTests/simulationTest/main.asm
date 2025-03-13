; Test: simulation 
; Created: 20250312

.ORIG x0000 
	; Start code here 
	ADD R0 R0 #1 ; R0 = 1
	LD R1 CAR ; R1 = car
	ADD R1 R1 R0 ; R1 = car +1
	LEA R2 TRUCK ;R2 = &truck
	LDR R3 R2 #0 ; R3 = truck
	STR R1 R2 #-1 ;car = car + 1
END 	.FILL xFFFF ;Temporary end command
	; Define constants here 	 
CAR 	.FILL x4040
TRUCK 	.FILL x8080
.END 

