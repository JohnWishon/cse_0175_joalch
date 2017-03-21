runLoadingScreen:

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

	call PlayMoonlightSonata
	ret


runGreetz:

	;; Write CSE 0175
	ld hl, CSE_0175
	ld a, 7
	ld b, 10
	ld c, 19
	call    drawRenderLine
	;; Write Dev Line
	ld hl, DEVELOPERS
	ld a, 9
	ld b, 10
	ld c, 19
	call    drawRenderLine
	;; Write Huajie
	ld hl, HUAJIE
	ld a, 11
	ld b, 10
	ld c, 19
	call    drawRenderLine
	;; Write Chris
	ld hl, CHRIS
	ld a, 12
	ld b, 10
	ld c, 19
	call    drawRenderLine
	;; Write Amanda
	ld hl, AMANDA
	ld a, 13
	ld b, 10
	ld c, 19
	call    drawRenderLine
	;; Write John
	ld hl, JOHN
	ld a, 14
	ld b, 10
	ld c, 19
	call    drawRenderLine
	;; Write Blank
	ld hl, BLANK
	ld a, 15
	ld b, 8
	ld c, 20
	call    drawRenderLine
	call delay

	;; Write CSE 0175
	ld hl, CSE_0175
	ld a, 7
	ld b, 10
	ld c, 19
	call    drawRenderLine
	;; Write CSE 0175
	ld hl, PROFESSOR
	ld a, 9
	ld b, 10
	ld c, 19
	call    drawRenderLine
	;; Write CSE 0175
	ld hl, SHACHAM
	ld a, 11
	ld b, 10
	ld c, 19
	call    drawRenderLine
	;; Write Blank
	ld hl, BLANK
	ld a, 12
	ld b, 8
	ld c, 20
	call    drawRenderLine
	;; Write Blank
	ld hl, BLANK
	ld a, 13
	ld b, 8
	ld c, 20
	call    drawRenderLine
	;; Write Blank
	ld hl, BLANK
	ld a, 14
	ld b, 8
	ld c, 20
	call    drawRenderLine
	call delay

;; Thanks page
;; Write CSE 0175
	ld hl, CSE_0175
	ld a, 7
	ld b, 10
	ld c, 19
	call    drawRenderLine
	ld hl, THANKS
	ld a, 9
	ld b, 10
	ld c, 19
	call    drawRenderLine
	ld hl, WOS
	ld a, 11
	ld b, 10
	ld c, 19
	call    drawRenderLine
	ld hl, CAULDWELL
	ld a, 12
	ld b, 10
	ld c, 19
	call    drawRenderLine
	ld hl, DAVID
	ld a, 13
	ld b, 10
	ld c, 19
	call    drawRenderLine
	ld hl, CHUTNEY
	ld a, 14
	ld b, 10
	ld c, 19
	call    drawRenderLine
	ret

delay:
	ld b,50         ; length of delay.
delay0:
 	halt            ; wait for an interrupt.
	djnz delay0     ; loop.
	ret
; END GREETZ

runMenu:
	;; Options Title
	ld hl, OPTIONS
	ld a, 7
	ld b, 10
	ld c, 19
	call    drawRenderLine
	;; Starts Title
	ld hl, STARTS
	ld a, 9
	ld b, 10
	ld c, 19
	call    drawRenderLine
	;; Write Blank
	ld hl, BLANK
	ld a, 10
	ld b, 8
	ld c, 20
	call    drawRenderLine
	;; Music Title
	ld hl, MUSIC
	ld a, 11
	ld b, 10
	ld c, 19
	call    drawRenderLine
	;; Write Blank
	ld hl, BLANKCAULDWELL
	ld a, 12
	ld b, 10
	ld c, 19
	call    drawRenderLine
	;; Controls
	ld hl, CONTROLS
	ld a, 13
	ld b, 10
	ld c, 19
	call    drawRenderLine
	;; Write Blank
	ld hl, BLANKCHUTNEY
	ld a, 14
	ld b, 10
	ld c, 19
	call    drawRenderLine
	;; Starts Title
	ld hl, GREETZ
	ld a, 15
	ld b, 10
	ld c, 19
	call    drawRenderLine
	ret
; END menu


runInstruction:
	;; Control Title
	ld hl, CONTROLS_TITLE
	ld a, 7
	ld b, 10
	ld c, 19
	call    drawRenderLine
	;; Write Player One Text
	ld hl, PLAYER_ONE
	ld a, 9
	ld b, 10
	ld c, 19
	call    drawRenderLine
	;; Write Player One Text
	ld hl, CONTROLS_ONE
	ld a, 11
	ld b, 10
	ld c, 19
	call    drawRenderLine
	;; Write Player One Text
	ld hl, PLAYER_TWO
	ld a, 13
	ld b, 10
	ld c, 19
	call    drawRenderLine
	;; Write Player One Text
	ld hl, CONTROLS_TWO
	ld a, 15
	ld b, 10
	ld c, 19
	call    drawRenderLine
	ret
;     ;; Instruction drawing code
;     call    SCheck
;     JP  nz, startGame
;
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

;;  Input:
;;      HL: points to the first tile to print
;;      b:  # of tiles to print
;;      a:  y of tile to print
;;      b:  x of tile to print
drawRenderLine:
    push af
	push bc
	ld b, a
	ld de, 0
	push hl
	call renderFrameWriteTile
	pop hl
	pop bc
	inc c
	ld d, 0
	ld e, 9
	add hl, de
	pop af
	djnz drawRenderLine
	ret
