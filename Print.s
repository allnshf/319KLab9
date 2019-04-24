; Print.s
; Student names: change this to your names or look very silly
; Last modification date: change this to the last modification date or look very silly
; Runs on LM4F120 or TM4C123
; EE319K lab 7 device driver for any LCD
;
; As part of Lab 7, students need to implement these LCD_OutDec and LCD_OutFix
; This driver assumes two low-level LCD functions
; ST7735_OutChar   outputs a single 8-bit ASCII character
; ST7735_OutString outputs a null-terminated string 

    IMPORT   ST7735_OutChar
    IMPORT   ST7735_OutString
    EXPORT   LCD_OutDec
    EXPORT   LCD_OutFix

    AREA    |.text|, CODE, READONLY, ALIGN=2
    PRESERVE8
	THUMB
		
digits	EQU		0
num		EQU		4 
;-----------------------LCD_OutDec-----------------------
; Output a 32-bit number in unsigned decimal format
; Input: R0 (call by value) 32-bit unsigned number
; Output: none
; Invariables: This function must not permanently modify registers R4 to R11
LCD_OutDec
;; --UUU-- Complete this (copy from Lab7-8)
	PUSH{LR}
	MOV R2,#0	;# of digits = 0
check
	CMP R0,#10
	BLO	out
	MOV R1,#0	;count = 0
again
	SUB R0,#10	
	ADD R1,#1	;count++
	CMP R0,#10	
	BHS again
	PUSH{R0}
	ADD R2,#1
	MOV R0,R1
	B check
out	
	ADD R0,#0x30
	PUSH{R0-R3}
	BL ST7735_OutChar
	POP{R0-R3}
	CMP R2,#0
	BEQ done
	POP{R0}
	SUB R2,#1
	B out	
done
	POP{LR}
    BX LR
;* * * * * * * * End of LCD_OutDec * * * * * * * *

; -----------------------LCD _OutFix----------------------
; Output characters to LCD display in fixed-point format
; unsigned decimal, resolution 0.001, range 0.000 to 9.999
; Inputs:  R0 is an unsigned 32-bit number
; Outputs: none
; E.g., R0=0,    then output "0.000 "
;       R0=3,    then output "0.003 "
;       R0=89,   then output "0.089 "
;       R0=123,  then output "0.123 "
;       R0=9999, then output "9.999 "
;       R0>9999, then output "*.*** "
; Invariables: This function must not permanently modify registers R4 to R11
LCD_OutFix
;; --UUU-- Complete this (copy from Lab7-8)
	PUSH{LR}
;**Allocation**
	PUSH{R0}
	SUB SP,#4
;**Access**
clear					;clear frame
	MOV R1,#0
	STR R1,[SP]
	
	MOV R2,#3			;frame offset
	LDR R0,[SP,#num]	;Load input
look
	MOV R1,#0			;count = 0
loop
	CMP R0,#10
	BLO	store
	SUB R0,#10	
	ADD R1,#1			;count++
	B	loop
store
	ADD R3,SP,R2
	STRB R0,[R3]		;Store digit
	MOV R0,R1			;num = num / 10
	SUB R2,#1			
	CMP R2,#0			;if digits left, continue
	BGE look
	CMP R0,#0			;check if number is greater than 4 digits
	BHI	error
	LDRB R0,[SP]		;Display float
	ADD R0,#0x30
	BL ST7735_OutChar
	MOV R0,#0x2E
	BL ST7735_OutChar
	LDRB R0,[SP,#1]		
	ADD R0,#0x30
	BL ST7735_OutChar
	LDRB R0,[SP,#2]		
	ADD R0,#0x30
	BL ST7735_OutChar
	LDRB R0,[SP,#3]		
	ADD R0,#0x30
	BL ST7735_OutChar
	B	Deallo
error
	MOV R0,#0x2A
	BL ST7735_OutChar
	MOV R0,#0x2E
	BL ST7735_OutChar
	MOV R0,#0x2A
	BL ST7735_OutChar
	MOV R0,#0x2A
	BL ST7735_OutChar
	MOV R0,#0x2A
	BL ST7735_OutChar

;**Deallocation**
Deallo
	LDR R0,[SP]
	ADD SP,#8
	POP{LR}
     BX LR
;* * * * * * * * End of LCD_OutFix * * * * * * * *

    ALIGN                           ; make sure the end of this section is aligned
    END                             ; end of file
