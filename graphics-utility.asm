;; SEARCH ALGORITHM  ;;

;Start:
;  ld hl,(TextAddress)
;  ld de,(StringAddress)
;  ld bc,(StringLength)
;Repeat:                          ; This loop verifies if the text from the current byte
;  ld a,(de)                      ; matches the string given, character by character. If
;  cp (hl)                        ; it does, then the zero flag is set. Execution is
;  jr nz,EndRepeat                ; continued from EndRepeat, regardless of the success of
;  inc hl                         ; the search.
;  inc de
;  dec bc
;  ld a,b
;  or c
;  jr nz,Repeat
;EndRepeat:
;  ld hl,(TextAddress)            ; Note that LD preserves the flags
;  jr z,Finish
;  inc hl                         ; The text pointer is advanced
;  ld (TextAddress),hl
;  ld bc,(TextLength)
;  dec bc                         ; Total byte count is decreased
;  ld (TextLength),bc
;  ld a,b
;  or c
;  jr nz,Start
;  ld hl,0                        ; This part is executed in case of failure (BC=0)
;Finish:
;  ...                            ; There should be some code following here, otherwise
                                 ; execution would continue in the data part...
;TextAddress:
;  .word $1000
;TextLength:
;  .word 500
;StringAddress:
;  .word $2000
;StringLength:
;  .word 20







; Return character cell address of block at (b, c).

chadd  ld a,b              ; vertical position.
       and 24              ; which segment, 0, 1 or 2?
       add a,64            ; 64*256 = 16384, Spectrum's screen memory.
       ld d,a              ; this is our high byte.
       ld a,b              ; what was that vertical position again?
       and 7               ; which row within segment?
       rrca                ; multiply row by 32.
       rrca
       rrca
       ld e,a              ; low byte.
       ld a,c              ; add on y coordinate.
       add a,e             ; mix with low byte.
       ld e,a              ; address of screen position in de.
       ret

; Display character hl at (b, c).

char   call chadd          ; find screen address for char.
       ld b,8              ; number of pixels high.
char0  ld a,(hl)           ; source graphic.
       ld (de),a           ; transfer to screen.
       inc hl              ; next piece of data.
       inc d               ; next pixel line.
       djnz char0          ; repeat
       ret








; Get screen address
; B = Y pixel position
; C = X pixel position
; Returns address in HL
GET_PIXEL_ADDRESS:	
	LD A,B		; Calculate Y2,Y1,Y0
	AND %00000111	; Mask out unwanted bits
	OR %01000000	; Set base address of screen
	LD H,A		; Store in H
	LD A,B		; Calculate Y7,Y6
	RRA		; Shift to position
	RRA
	RRA
	AND %00011000	; Mask out unwanted bits
	OR H		; OR with Y2,Y1,Y0
	LD H,A		; Store in H
	LD A,B		; Calculate Y5,Y4,Y3
	RLA		; Shift to position
	RLA
	AND %11100000	; Mask out unwanted bits
	LD L,A		; Store in L
	LD A,C		; Calculate X4,X3,X2,X1,X0
	RRA		; Shift into position
	RRA
	RRA
	AND %00011111	; Mask out unwanted bits
	OR L		; OR with Y5,Y4,Y3
	LD L,A		; Store in L
	RET

; Calculate address of attribute for character at (b, c).

atadd  ld a,b              ; x position.
       rrca                ; multiply by 32.
       rrca
       rrca
       ld l,a              ; store away in l.
       and 3               ; mask bits for high byte.
       add a,88            ; 88*256=22528, start of attributes.
       ld h,a              ; high byte done.
       ld a,l              ; get x*32 again.
       and 224             ; mask low byte.
       ld l,a              ; put in l.
       ld a,c              ; get y displacement.
       add a,l             ; add to low byte.
       ld l,a              ; hl=address of attributes.
       ld a,(hl)           ; return attribute in a.
       ret

; Here is a routine which returns a screen address for (xcoord, ycoord) in the de register pair.
; It could easily be modified to return the address in the hl or bc registers if desired.

scadd  ld a,(xcoord)       ; fetch vertical coordinate.
       ld e,a              ; store that in e.

; Find line within cell.

       and 7               ; line 0-7 within character square.
       add a,64            ; 64 * 256 = 16384 = start of screen display.
       ld d,a              ; line * 256.

; Find which third of the screen we're in.

       ld a,e              ; restore the vertical.
       and 192             ; segment 0, 1 or 2 multiplied by 64.
       rrca                ; divide this by 8.
       rrca
       rrca                ; segment 0-2 multiplied by 8.
       add a,d             ; add to d give segment start address.
       ld d,a

; Find character cell within segment.

       ld a,e              ; 8 character squares per segment.
       rlca                ; divide x by 8 and multiply by 32,
       rlca                ; net calculation: multiply by 4.
       and 224             ; mask off bits we don't want.
       ld e,a              ; vertical coordinate calculation done.

; Add the horizontal element.

       ld a,(ycoord)       ; y coordinate.
       rrca                ; only need to divide by 8.
       rrca
       rrca
       and 31              ; squares 0 - 31 across screen.
       add a,e             ; add to total so far.
       ld e,a              ; de = address of screen.
       ret


CLEAR_DISPLAY_FILE:
	LD HL,$4000	; Clear the entire display file
	LD DE,$4001
	LD BC,$17FF
	LD (HL),$00
	LDIR
	RET
