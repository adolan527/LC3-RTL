; Test: branch 
; Created: 20250226

.ORIG x0000
                LD    R0 VALA
                LD    R1 VALB
                ADD   R2 R0 R1
                BRP   POSITIVE
NEGATIVE        LD    R3 NEG
                BRNZP AFTER
POSITIVE        LD    R3 POS
AFTER           JSR   ADDTWICE
                LEA   R4 ADDTWICE
                JSRR  R4
ADDTWICE        ADD   R2 R1 R1
                ADD   R2 R1 R1
                RET   
VALA            .FILL x000A
VALB            .FILL x0014
POS             .FILL xFFFF
NEG             .FILL x8888

.END