PlayMoonlightSonata:
	LD HL, MoonlightSonata
n96A2:
	LD A,(HL)		;Pick up the next byte of tune data from the table at 85FB
	CP $FF			;Has the tune finished?
	RET Z			;Return (with the zero flag set) if so
	LD BC,$0064		;B=0 (short note duration counter), C=100 (short note counter)
	XOR A			;A=0 (border colour and speaker state)
	LD E,(HL)		;Save the byte of tune data in E for retrieval during the short note loop
	LD D,E			;Initialise D (pitch delay counter)
n96AC:
	OUT ($FE),A		;Produce a short note (approximately 0.003s) whose pitch is determined by the value in E
	DEC D
	JR NZ,n96B4
	LD D,E
	XOR $18
n96B4:
	DJNZ n96AC
	EX AF,AF'		;Save A briefly
	LD A,C			;Is the short note counter in C (which starts off at 100) down to 50 yet?
	CP $32
	JR NZ,n96BE		;Jump if not
	RL E			;Otherwise double the value in E (which halves the note frequency)
n96BE:
	EX AF,AF'		; Restore the value of A
	DEC C			;Decrement the short note counter in C
	JR NZ,n96AC		;Jump back unless we've finished playing 50 short notes at the lower frequency
	CALL MCheck     ;Check whether M is being pressed
	RET NZ			;Return (with the zero flag reset) if it is
	CALL GCheck     ;Check whether G is pressed
	JP  NZ, runGreetz ; Jump to greetz screen if so.
	CALL SCheck
	JP  NZ, startGame
	INC HL			;Move HL along to the next byte of tune data
	JR n96A2		;Jump back to play the next batch of 100 short notes

MoonlightSonata:
	DEFB $51,$3C,$33,$51,$3C,$33,$51,$3C,$33,$51,$3C,$33,$51,$3C,$33,$51
	DEFB $3C,$33,$51,$3C,$33,$51,$3C,$33,$4C,$3C,$33,$4C,$3C,$33,$4C,$39
	DEFB $2D,$4C,$39,$2D,$51,$40,$2D,$51,$3C,$33,$51,$3C,$36,$5B,$40,$36
	DEFB $66,$51,$3C,$51,$3C,$33,$51,$3C,$33,$28,$3C,$28,$28,$36,$2D,$51
	DEFB $36,$2D,$51,$36,$2D,$28,$36,$28,$28,$3C,$33,$51,$3C,$33,$26,$3C
	DEFB $2D,$4C,$3C,$2D,$28,$40,$33,$51,$40,$33,$2D,$40,$36,$20,$40,$36
	DEFB $3D,$79,$3D,$FF

MCheck:
	LD BC,$7FFE	;Read keys B-N-M-Shift-Space
	IN A,(C)
	AND $04		;Keep only bit 0 of the result (ENTER, 0)
	CP $01		;Reset the zero flag if ENTER or 0 is being pressed
	RET
