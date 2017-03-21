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

	ld hl, MOUSE_RIGHT_TWO
	ld de, $4000
	ld b, 5
	ld c, 9


	call renderFrameWriteTile


	
	call PlayMoonlightSonata
	
ret

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
