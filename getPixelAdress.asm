; ENTRY: B=LINE, C=COLUMN
; PRESERVED: BC, DE
; EXIT: HL=ADDRESS IN DISPLAY FILE, A=L

DF-LOC:
	LD		A,B
	AND		0F8H
	ADD 	A, 40H
	LD		H, A
	LD		A, B
	AND		7
	RRCA
	RRCA
	RRCA
	ADD		A,C
	LD		L,A
	
	LD		(5C84H), HL		; <- THIS MAKES IT A 'PRINT AT' BY
							; 	 LOADING SYS VAR 'DF-CC' TO BE 
							; 	 USED NEXT BY A PRINTING ROUTINE
	
	RET
	

	; Assembly Pixel Plotting Routine
			LD		ix,0
			ADD		ix,sp
			LD		C,(ix+2)
			LD		L,(ix+4) 
			LD		H,(ix+6)    
			
		PLOT:
			LD 		A,L
			AND 	0C0H
			RRA
			SCF
			RRA
			RRCA
			XOR 	L
			AND 	0F8H
			XOR 	L
			LD 		D,A
			LD 		A,H
			RLCA
			RLCA
			RLCA
			XOR 	L
			AND 	0C7H
			XOR 	L
			RLCA
			RLCA
			LD 		E,A
			PUSH 	DE 			;address is stored in DE
			
			; Find attribute address
			LD 		A,D
			RRCA
			RRCA
			RRCA
			AND 	3
			OR 		58H
			LD		D,A
			LD 		B,0
			
			; Change attribute
			LD  	A,(DE)
			XOR 	C
			AND 	B
			XOR  	C
			LD 		(DE),A
			
			; Retrieve D.F. address
			POP 	DE
			LD 		A,H
			AND 	7
			LD 		B,A
			INC 	B
			
			; B holds target bit number plus 1
			LD 		A,0FEH
			
			; Rotate a window to the target bit
		PLOOP:
			RRCA
			DJNZ	PLOOP
			LD  	B,A
			LD  	A,0
			LD  	C,A
			
			; Take byte from D.F
			LD  	A,(DE)
			
			; Check for over 1
			BIT  	1,C
			JR		NZ,OVER1
			AND		B
			
			; Check for inverse 1
		OVER1:
			BIT 	3,C
			JR 		NZ,INV1
			XOR		B
			CPL
		INV1:
			LD		(DE),A
			RET
	
	; Assembly Display File Clearing Routine
		CLSDF:
			LD		HL,4000H
			LD		BC,17FFH
			LD		(HL),L
			LD		D,H
			LD		E,1
			LDIR
			RET
			
			
	; Assembly Screen Attribute Clearing Routine -- clear screen to specified attribute
			LD		ix,0
			ADD		ix,sp
			LD		A,(ix+2)
		CLS:
			LD		HL,4000H
			LD		BC,1800H
			LD		(HL),L
			LD		D,H
			LD		E,1
			LDIR
			LD		(HL),A
			LD		BC,02FFH
			LDIR
			RET
	