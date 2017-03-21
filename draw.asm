runLoadingScreen:

	ld hl,$4000
	ld de,$4001
	ld bc,$17FF
	ld (hl),$00
	ldir
    ;   ld hl,23693         ; system variable for attributes.
    ;   ld (hl),36          ; want green background.

setLoadingDisplay:

	;	;; Write CSE 0175
	ld hl, LINEZERO
	ld b, 31
	ld c, 0
lineZeroLoop:
	push bc
	ld b, 0
	ld de, 0
	push hl
	call renderFrameWriteTilePixels
	pop hl
	pop bc
	inc c
	ld d, 0
	ld e, 8
	add hl, de
	djnz lineZeroLoop

	;; Write CSE 0175
	ld hl, LINEONE
	ld b, 31
	ld c, 0
lineOneLoop:
	push bc
	ld b, 1
	ld de, 0
	push hl
	call renderFrameWriteTilePixels
	pop hl
	pop bc
	inc c
	ld d, 0
	ld e, 8
	add hl, de
	djnz lineOneLoop

	;; Write CSE 0175
	ld hl, LINETWO
	ld b, 31
	ld c, 0
lineTwoLoop:
	push bc
	ld b, 2
	ld de, 0
	push hl
	call renderFrameWriteTilePixels
	pop hl
	pop bc
	inc c
	ld d, 0
	ld e, 8
	add hl, de
	djnz lineTwoLoop

	;; Write CSE 0175
	ld hl, menu0
	ld b, 10
	ld c, 19
menu0Loop:
	push bc
	ld b, 6
	ld de, 0
	push hl
	call renderFrameWriteTilePixels
	pop hl
	pop bc
	inc c
	ld d, 0
	ld e, 8
	add hl, de
	djnz menu0Loop

	;; Write CSE 0175
	ld hl, menu1
	ld b, 10
	ld c, 19
menu1Loop:
	push bc
	ld b, 7
	ld de, 0
	push hl
	call renderFrameWriteTilePixels
	pop hl
	pop bc
	inc c
	ld d, 0
	ld e, 8
	add hl, de
	djnz menu1Loop

	;; Write CSE 0175
	ld hl, menu2
	ld b, 11
	ld c, 19
menu2Loop:
	push bc
	ld b, 8
	ld de, 0
	push hl
	call renderFrameWriteTilePixels
	pop hl
	pop bc
	inc c
	ld d, 0
	ld e, 8
	add hl, de
	djnz menu2Loop

	;; Write CSE 0175
	ld hl, menu3
	ld b, 10
	ld c, 19
menu3Loop:
	push bc
	ld b, 9
	ld de, 0
	push hl
	call renderFrameWriteTilePixels
	pop hl
	pop bc
	inc c
	ld d, 0
	ld e, 8
	add hl, de
	djnz menu3Loop

	;; Write CSE 0175
	ld hl, menu4
	ld b, 10
	ld c, 19
menu4Loop:
	push bc
	ld b, 10
	ld de, 0
	push hl
	call renderFrameWriteTilePixels
	pop hl
	pop bc
	inc c
	ld d, 0
	ld e, 8
	add hl, de
	djnz menu4Loop

	;; Write CSE 0175
	ld hl, menu5
	ld b, 10
	ld c, 19
menu5Loop:
	push bc
	ld b, 11
	ld de, 0
	push hl
	call renderFrameWriteTilePixels
	pop hl
	pop bc
	inc c
	ld d, 0
	ld e, 8
	add hl, de
	djnz menu5Loop

	;; Write CSE 0175
	ld hl, menu6
	ld b, 10
	ld c, 19
menu6Loop:
	push bc
	ld b, 12
	ld de, 0
	push hl
	call renderFrameWriteTilePixels
	pop hl
	pop bc
	inc c
	ld d, 0
	ld e, 8
	add hl, de
	djnz menu6Loop

	;; Write CSE 0175
	ld hl, menu7
	ld b, 10
	ld c, 19
menu7Loop:
	push bc
	ld b, 13
	ld de, 0
	push hl
	call renderFrameWriteTilePixels
	pop hl
	pop bc
	inc c
	ld d, 0
	ld e, 8
	add hl, de
	djnz menu7Loop

	;; Write CSE 0175
	ld hl, menu8
	ld b, 10
	ld c, 19
menu8Loop:
	push bc
	ld b, 14
	ld de, 0
	push hl
	call renderFrameWriteTilePixels
	pop hl
	pop bc
	inc c
	ld d, 0
	ld e, 8
	add hl, de
	djnz menu8Loop

	;; Write CSE 0175
	ld hl, menu9
	ld b, 10
	ld c, 19
menu9Loop:
	push bc
	ld b, 15
	ld de, 0
	push hl
	call renderFrameWriteTilePixels
	pop hl
	pop bc
	inc c
	ld d, 0
	ld e, 8
	add hl, de
	djnz menu9Loop

	;; Write CSE 0175
	ld hl, menu10
	ld b, 10
	ld c, 19
menu10Loop:
	push bc
	ld b, 16
	ld de, 0
	push hl
	call renderFrameWriteTilePixels
	pop hl
	pop bc
	inc c
	ld d, 0
	ld e, 8
	add hl, de
	djnz menu10Loop

	;; Write CSE 0175
	ld hl, menu11
	ld b, 10
	ld c, 19
menu11Loop:
	push bc
	ld b, 17
	ld de, 0
	push hl
	call renderFrameWriteTilePixels
	pop hl
	pop bc
	inc c
	ld d, 0
	ld e, 8
	add hl, de
	djnz menu11Loop

	;; Write CSE 0175
	ld hl, menu12
	ld b, 10
	ld c, 19
menu12Loop:
	push bc
	ld b, 18
	ld de, 0
	push hl
	call renderFrameWriteTilePixels
	pop hl
	pop bc
	inc c
	ld d, 0
	ld e, 8
	add hl, de
	djnz menu12Loop

	;; Write CSE 0175
	ld hl, cat0
	ld b, 12
	ld c, 3
cat0Loop:
	push bc
	ld b, 9
	ld de, 0
	push hl
	call renderFrameWriteTilePixels
	pop hl
	pop bc
	inc c
	ld d, 0
	ld e, 8
	add hl, de
	djnz cat0Loop

	;; Write CSE 0175
	ld hl, cat1
	ld b, 12
	ld c, 3
cat1Loop:
	push bc
	ld b, 10
	ld de, 0
	push hl
	call renderFrameWriteTilePixels
	pop hl
	pop bc
	inc c
	ld d, 0
	ld e, 8
	add hl, de
	djnz cat1Loop

	;; Write CSE 0175
	ld hl, cat2
	ld b, 12
	ld c, 3
cat2Loop:
	push bc
	ld b, 11
	ld de, 0
	push hl
	call renderFrameWriteTilePixels
	pop hl
	pop bc
	inc c
	ld d, 0
	ld e, 8
	add hl, de
	djnz cat2Loop

	;; Write CSE 0175
	ld hl, cat3
	ld b, 12
	ld c, 3
cat3Loop:
	push bc
	ld b, 12
	ld de, 0
	push hl
	call renderFrameWriteTilePixels
	pop hl
	pop bc
	inc c
	ld d, 0
	ld e, 8
	add hl, de
	djnz cat3Loop

	;; Write CSE 0175
	ld hl, cat4
	ld b, 12
	ld c, 3
cat4Loop:
	push bc
	ld b, 13
	ld de, 0
	push hl
	call renderFrameWriteTilePixels
	pop hl
	pop bc
	inc c
	ld d, 0
	ld e, 8
	add hl, de
	djnz cat4Loop

	;; Write CSE 0175
	ld hl, cat5
	ld b, 12
	ld c, 3
cat5Loop:
	push bc
	ld b, 14
	ld de, 0
	push hl
	call renderFrameWriteTilePixels
	pop hl
	pop bc
	inc c
	ld d, 0
	ld e, 8
	add hl, de
	djnz cat5Loop

	;; Write CSE 0175
	ld hl, cat6
	ld b, 12
	ld c, 3
cat6Loop:
	push bc
	ld b, 15
	ld de, 0
	push hl
	call renderFrameWriteTilePixels
	pop hl
	pop bc
	inc c
	ld d, 0
	ld e, 8
	add hl, de
	djnz cat6Loop


	ld hl, TitleAttributes
	ld de, $5800
	ld bc, $0300
	ldir
	;
	; ld hl,TitleName
	; ld de,$4000
	; ld bc,$17FF
	; ldir

	call PlayMoonlightSonata
	ret


runGreetz:

	;; Write CSE 0175
	; ld hl, CSE_0175
	; ld a, 7
	; ld b, 10
	; ld c, 19
	; call    drawRenderLine
	; ;; Write Dev Line
	; ld hl, DEVELOPERS
	; ld a, 9
	; ld b, 10
	; ld c, 19
	; call    drawRenderLine
	; ;; Write Huajie
	; ld hl, HUAJIE
	; ld a, 11
	; ld b, 10
	; ld c, 19
	; call    drawRenderLine
	; ;; Write Chris
	; ld hl, CHRIS
	; ld a, 12
	; ld b, 10
	; ld c, 19
	; call    drawRenderLine
	; ;; Write Amanda
	; ld hl, AMANDA
	; ld a, 13
	; ld b, 10
	; ld c, 19
	; call    drawRenderLine
	; ;; Write John
	; ld hl, JOHN
	; ld a, 14
	; ld b, 10
	; ld c, 19
	; call    drawRenderLine
	; ;; Write Blank
	; ld hl, BLANK
	; ld a, 15
	; ld b, 8
	; ld c, 20
	; call    drawRenderLine
	; call delay
	;
	; ;; Write CSE 0175
	; ld hl, CSE_0175
	; ld a, 7
	; ld b, 10
	; ld c, 19
	; call    drawRenderLine
	; ;; Write CSE 0175
	; ld hl, PROFESSOR
	; ld a, 9
	; ld b, 10
	; ld c, 19
	; call    drawRenderLine
	; ;; Write CSE 0175
	; ld hl, SHACHAM
	; ld a, 11
	; ld b, 10
	; ld c, 19
	; call    drawRenderLine
	; ;; Write Blank
	; ld hl, BLANK
	; ld a, 12
	; ld b, 8
	; ld c, 20
	; call    drawRenderLine
	; ;; Write Blank
	; ld hl, BLANK
	; ld a, 13
	; ld b, 8
	; ld c, 20
	; call    drawRenderLine
	; ;; Write Blank
	; ld hl, BLANK
	; ld a, 14
	; ld b, 8
	; ld c, 20
	; call    drawRenderLine
	; call delay

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
	;; Write Blank
	ld hl, BLANK
	ld a, 15
	ld b, 8
	ld c, 20
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
