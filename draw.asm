runLoadingScreen:
;this is clear screen
	ld hl,$4000
	ld de,$4001
	ld bc,$17FF
	ld (hl),$00
	ldir
    ;   ld hl,23693         ; system variable for attributes.
    ;   ld (hl),36          ; want green background.

setLoadingDisplay:

;	ld	hl, $066b
;	ld	de, $0106
;	call	$03b5	; BEEPER in ROM
	;ret
	
;	ld hl, 1460
;	ld de, 294
;	call 949
;	ld hl, 715
;	ld de, 587
;	call 949
;	ld hl, 342
;	ld de, 1175
;	call 949
;	ld hl, 342
;	ld de, 1175
;	call 949
;	ld hl, 715
;	ld de, 587
;	call 949
;	ld hl, 1460
;	ld de, 294
;	call 949

	ld hl, TitleAttributes
	ld de, $5800
	ld bc, $0300
	ldir
	
	ld hl,TitleName
	ld de,$4000
	ld bc,$17FF
	ldir 



;ld b, boxWidth ; 7
;    ld hl, CSE_0175
;    ld de, 0
;    ld c, 20
;loop:
;    push bc
;    ld b, 10
;    call renderFrameWriteTile
;    pop bc
;    inc c
;    djnz loop



; Return character cell address of block at (b, c).
	ld  b, 10
	ld hl, CSE_0175
	ld c, 19
	;push bc
	
loop:
	push bc
	call char
    	;push bc
    	;ld b, 7
    	;ld de, 0
	;call char
	pop bc
	inc hl
	djnz loop
ret



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


;loop:
;    push bc
;    ld b, 7
;    ld de, 0
;exx;
;	ld hl, TitleAttributes
;	ld de, $5800
;	ld bc, $0300
;	ldir
;
;	ld hl,$4000
;	ld de,$4001
;	ld bc,$17FF
;	ld (hl),$00
;	ldir
;exx
 ;   call renderFrameWriteTile
;    pop bc
;    inc c
;    ld d, 0
;    ld e, 8
;    add hl, de
;    djnz loop


;	ld hl, CSE_0175
;	ld de, 0	
;	ld b, 10
;	ld c, 20 
;loop:
;	push bc
;	ld b, 7 
;	call renderFrameWriteTile
;	;inc hl
;	pop bc
;	inc c
;	djnz loop
ret

;intro:

;	ld ix, 
;	ld b, 7
;	ld c, 20
;loop:

;	ld ix, CONTROLS_TITLE
;	ld hl, 
;	ld ix, PLAYER_ONE
;	ld ix, CONTROLS_ONE
;	ld ix, PLAYER_TWO
;	ld ix, CONTROLS_TWO
;
;	ld ix, OPTIONS
;	ld ix, STARTS
;	ld ix, MUSIC
;	ld ix, CONTROLS
;	ld ix, GREETZ
	
;	ld ix, CSE_0175
;	
;	ld ix, PROFESSOR
;	ld ix, SHACHAM
;	
;endloop:


;	ld ix, THANKS
;	ld ix,
;	ld ix, WOS
;	ld ix, CAULDWELL
;	ld ix, DAVID
;	ld ix, CHUTNEY
;	
;	ld ix, DEVELOPERS
;	ld ix, HUAJIE
;	ld ix, CHRIS
;	ld ix, AMANDA
;	ld ix, JOHN
;	
;	ld ix, CONTROLS_TITLE
;	ld ix, 
;
 ; 	inc hl                         
 ; 	inc de
  ;	dec bc

;	endloop:



;	call renderFrameWriteTile


	
	;call PlayMoonlightSonata
	
;ret

setupGraphics:

clearFile:
	ld hl,$4000
	ld de,$4001
	ld bc,$17FF
	ld (hl),$00
	ldir

setAttributeFile:
	ld hl, MainScreen_Attributes
	ld de, $5800
	ld bc, $0300
	ldir

drawTopScreen:
  ld hl,MainScreen_Attributes_TOP
  ld de,$4000
  ld bc,256
  call drawScreen
drawMidScreen:
  ld hl,MainScreen_Attributes_MID
  ld de,$4800
  ld bc,256
  call drawScreen
drawBotScreen:
  ld hl,MainScreen_Attributes_BOT
  ld de,$5000
  ld bc,256
  call drawScreen

  RET
