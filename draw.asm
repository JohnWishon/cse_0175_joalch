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
ld b, 10 ; 7
    ld hl, CSE_0175
    ld c, 20
loop:
    push bc
    ld b, 10
    ld de, 0
    call renderFrameWriteTile
    pop bc
    inc c
    ld d, 0
    ld e, 9
    add hl, de
    djnz loop

	
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
