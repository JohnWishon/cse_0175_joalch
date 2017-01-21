	module main.asm

_main:          			; z80asm doesn't like mixed label and code somehow
	ld	a,2			; upper screen
	call	$1601			; open channel

loop:					; (.cont) It also requires the colon.
	ld	de,pstring		; address of string
	ld	bc,eostr-pstring	; length of string to print
	call	$203c			; print our string
	jp	loop			; repeat until screen is full

pstring:
	defm	"(Name) is cool"	; defm is "define message"
	defb 13				; 13 for CR

eostr:
	xdef	_main			; if this isn't defined, z80asm complains
