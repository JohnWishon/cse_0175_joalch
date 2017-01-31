ORG 32768

INCLUDE "./loadingScreen.asm"
INCLUDE "./keyboarddisp.asm"

MAIN:
;	DI
;	LD A,38h
;	CALL Clear_Screen
;	LD HL,Text_Scores
;	CALL Print_String
;	CALL Initialise_Sprites
;	LD HL,Interrupt
;	LD IX,&FFF0
;	LD (IX+04h),&C3            ; Opcode for JP
;	LD (IX+05h),L
;	LD (IX+06h),H
;	LD (IX+0Fh),&18            ; Opcode for JR; this will do JR to FFF4h
;	LD A,&39
;	LD I,A
;	IM 2
;	EI

LOOP:			
	HALT
	Call pmain
	JR LOOP
	
; clear the screen

; set the border color







