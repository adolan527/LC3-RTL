; Testing the ADD, AND, and NOT instructions

.ORIG #0

; Assumes memory is zero-init
ADD R0 R0 #1 
ADD R1 R0 R1
ADD R0 R0 #4
ADD R0 R0 R1
ADD R2 R0 R1
AND R0 R0 #15
NOT R0 R0
NOT R1 R1

.END