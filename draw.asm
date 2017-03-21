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
	ld b, 10
	ld c, 19
cseLoop:
	push bc
	ld b, 7
	ld de, 0
	push hl
	call renderFrameWriteTile
	pop hl
	pop bc
	inc c
	ld d, 0
	ld e, 9
	add hl, de
	djnz cseLoop

	;; Write Dev Line
	ld hl, DEVELOPERS
	ld b, 10
	ld c, 19
devLoop:
	push bc
	ld b, 9
	ld de, 0
	push hl
	call renderFrameWriteTile
	pop hl
	pop bc
	inc c
	ld d, 0
	ld e, 9
	add hl, de
	djnz devLoop

	;; Write Huajie
	ld hl, HUAJIE
	ld b, 10
	ld c, 19
huajieLoop:
	push bc
	ld b, 11
	ld de, 0
	push hl
	call renderFrameWriteTile
	pop hl
	pop bc

	inc c
	ld d, 0
	ld e, 9
	add hl, de
	djnz huajieLoop

	;; Write Chris
	ld hl, CHRIS
	ld b, 10
	ld c, 19
chrisLoop:
	push bc
	ld b, 12
	ld de, 0
	push hl
	call renderFrameWriteTile
	pop hl
	pop bc

	inc c
	ld d, 0
	ld e, 9
	add hl, de
	djnz chrisLoop

	;; Write Amanda
	ld hl, AMANDA
	ld b, 10
	ld c, 19
amandaLoop:
	push bc
	ld b, 13
	ld de, 0
	push hl
	call renderFrameWriteTile
	pop hl
	pop bc

	inc c
	ld d, 0
	ld e, 9
	add hl, de
	djnz amandaLoop

	;; Write John
	ld hl, JOHN
	ld b, 10
	ld c, 19
johnLoop:
	push bc
	ld b, 14
	ld de, 0
	push hl
	call renderFrameWriteTile
	pop hl
	pop bc

	inc c
	ld d, 0
	ld e, 9
	add hl, de
	djnz johnLoop

	;; Write Blank
	ld hl, BLANK
	ld b, 8
	ld c, 20
devBlankLoop:
	push bc
	ld b, 15
	ld de, 0
	push hl
	call renderFrameWriteTile
	pop hl
	pop bc

	inc c
	ld d, 0
	ld e, 9
	add hl, de
	djnz devBlankLoop

	call delay

	;; Write CSE 0175
	ld hl, CSE_0175
	ld b, 10
	ld c, 19
cseProfLoop:
	push bc
	ld b, 7
	ld de, 0
	push hl
	call renderFrameWriteTile
	pop hl
	pop bc
	inc c
	ld d, 0
	ld e, 9
	add hl, de
	djnz cseProfLoop

	;; Write CSE 0175
	ld hl, PROFESSOR
	ld b, 10
	ld c, 19
profLoop:
	push bc
	ld b, 9
	ld de, 0
	push hl
	call renderFrameWriteTile
	pop hl
	pop bc
	inc c
	ld d, 0
	ld e, 9
	add hl, de
	djnz profLoop

	;; Write CSE 0175
	ld hl, SHACHAM
	ld b, 10
	ld c, 19
shachamLoop:
	push bc
	ld b, 11
	ld de, 0
	push hl
	call renderFrameWriteTile
	pop hl
	pop bc
	inc c
	ld d, 0
	ld e, 9
	add hl, de
	djnz shachamLoop

	;; Write Blank
	ld hl, BLANK
	ld b, 8
	ld c, 20
profBlankLoop1:
	push bc
	ld b, 12
	ld de, 0
	push hl
	call renderFrameWriteTile
	pop hl
	pop bc

	inc c
	ld d, 0
	ld e, 9
	add hl, de
	djnz profBlankLoop1

	;; Write Blank
	ld hl, BLANK
	ld b, 8
	ld c, 20
profBlankLoop2:
	push bc
	ld b, 13
	ld de, 0
	push hl
	call renderFrameWriteTile
	pop hl
	pop bc

	inc c
	ld d, 0
	ld e, 9
	add hl, de
	djnz profBlankLoop2

	;; Write Blank
	ld hl, BLANK
	ld b, 8
	ld c, 20
profBlankLoop3:
	push bc
	ld b, 14
	ld de, 0
	push hl
	call renderFrameWriteTile
	pop hl
	pop bc

	inc c
	ld d, 0
	ld e, 9
	add hl, de
	djnz profBlankLoop3

	call delay

;; Thanks page
;; Write CSE 0175
	ld hl, CSE_0175
	ld b, 10
	ld c, 19
cseThanksLoop:
	push bc
	ld b, 7
	ld de, 0
	push hl
	call renderFrameWriteTile
	pop hl
	pop bc
	inc c
	ld d, 0
	ld e, 9
	add hl, de
	djnz cseThanksLoop

	ld hl, THANKS
	ld b, 10
	ld c, 19
thanksLoop:
	push bc
	ld b, 9
	ld de, 0
	push hl
	call renderFrameWriteTile
	pop hl
	pop bc
	inc c
	ld d, 0
	ld e, 9
	add hl, de
	djnz thanksLoop

	ld hl, WOS
	ld b, 10
	ld c, 19
wosLoop:
	push bc
	ld b, 11
	ld de, 0
	push hl
	call renderFrameWriteTile
	pop hl
	pop bc
	inc c
	ld d, 0
	ld e, 9
	add hl, de
	djnz wosLoop

	ld hl, CAULDWELL
	ld b, 10
	ld c, 19
cauldLoop:
	push bc
	ld b, 12
	ld de, 0
	push hl
	call renderFrameWriteTile
	pop hl
	pop bc
	inc c
	ld d, 0
	ld e, 9
	add hl, de
	djnz cauldLoop

	ld hl, DAVID
	ld b, 10
	ld c, 19
davidLoop:
	push bc
	ld b, 13
	ld de, 0
	push hl
	call renderFrameWriteTile
	pop hl
	pop bc
	inc c
	ld d, 0
	ld e, 9
	add hl, de
	djnz davidLoop

	ld hl, CHUTNEY
	ld b, 10
	ld c, 19
chutneyLoop:
	push bc
	ld b, 14
	ld de, 0
	push hl
	call renderFrameWriteTile
	pop hl
	pop bc
	inc c
	ld d, 0
	ld e, 9
	add hl, de
	djnz chutneyLoop
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
	ld b, 10
	ld c, 19
optionsLoop:
	push bc
	ld b, 7
	ld de, 0
	push hl
	call renderFrameWriteTile
	pop hl
	pop bc

	inc c
	ld d, 0
	ld e, 9
	add hl, de
	djnz optionsLoop

	;; Starts Title
	ld hl, STARTS
	ld b, 10
	ld c, 19
startsLoop:
	push bc
	ld b, 9
	ld de, 0
	push hl
	call renderFrameWriteTile
	pop hl
	pop bc

	inc c
	ld d, 0
	ld e, 9
	add hl, de
	djnz startsLoop

	;; Write Blank
	ld hl, BLANK
	ld b, 8
	ld c, 20
menuBlankLoop1:
	push bc
	ld b, 10
	ld de, 0
	push hl
	call renderFrameWriteTile
	pop hl
	pop bc

	inc c
	ld d, 0
	ld e, 9
	add hl, de
	djnz menuBlankLoop1

	;; Music Title
	ld hl, MUSIC
	ld b, 10
	ld c, 19
musicLoop:
	push bc
	ld b, 11
	ld de, 0
	push hl
	call renderFrameWriteTile
	pop hl
	pop bc

	inc c
	ld d, 0
	ld e, 9
	add hl, de
	djnz musicLoop

	;; Write Blank
	ld hl, BLANKCAULDWELL
	ld b, 10
	ld c, 19
menuBlankLoop2:
	push bc
	ld b, 12
	ld de, 0
	push hl
	call renderFrameWriteTile
	pop hl
	pop bc

	inc c
	ld d, 0
	ld e, 9
	add hl, de
	djnz menuBlankLoop2

	;; Controls
	ld hl, CONTROLS
	ld b, 10
	ld c, 19
contLoop:
	push bc
	ld b, 13
	ld de, 0
	push hl
	call renderFrameWriteTile
	pop hl
	pop bc

	inc c
	ld d, 0
	ld e, 9
	add hl, de
	djnz contLoop

	;; Write Blank
	ld hl, BLANKCHUTNEY
	ld b, 10
	ld c, 19
menuBlankLoop3:
	push bc
	ld b, 14
	ld de, 0
	push hl
	call renderFrameWriteTile
	pop hl
	pop bc

	inc c
	ld d, 0
	ld e, 9
	add hl, de
	djnz menuBlankLoop3

	;; Starts Title
	ld hl, GREETZ
	ld b, 10
	ld c, 19
greetzLoop:
	push bc
	ld b, 15
	ld de, 0
	push hl
	call renderFrameWriteTile
	pop hl
	pop bc

	inc c
	ld d, 0
	ld e, 9
	add hl, de
	djnz greetzLoop

	ret
; END menu


runInstruction:
	;; Control Title
	ld hl, CONTROLS_TITLE
	ld b, 10
	ld c, 19
controlLoop:
	push bc
	ld b, 7
	ld de, 0
	push hl
	call renderFrameWriteTile
	pop hl
	pop bc

	inc c
	ld d, 0
	ld e, 9
	add hl, de
	djnz controlLoop

	;; Write Player One Text
	ld hl, PLAYER_ONE
	ld b, 10
	ld c, 19
p1Loop:
	push bc
	ld b, 9
	ld de, 0
	push hl
	call renderFrameWriteTile
	pop hl
	pop bc

	inc c
	ld d, 0
	ld e, 9
	add hl, de
	djnz p1Loop

	;; Write Player One Text
	ld hl, CONTROLS_ONE
	ld b, 10
	ld c, 19
c1Loop:
	push bc
	ld b, 11
	ld de, 0
	push hl
	call renderFrameWriteTile
	pop hl
	pop bc

	inc c
	ld d, 0
	ld e, 9
	add hl, de
	djnz c1Loop

	;; Write Player One Text
	ld hl, PLAYER_TWO
	ld b, 10
	ld c, 19
p2Loop:
	push bc
	ld b, 13
	ld de, 0
	push hl
	call renderFrameWriteTile
	pop hl
	pop bc

	inc c
	ld d, 0
	ld e, 9
	add hl, de
	djnz p2Loop

	;; Write Player One Text
	ld hl, CONTROLS_TWO
	ld b, 10
	ld c, 19
c2Loop:
	push bc
	ld b, 15
	ld de, 0
	push hl
	call renderFrameWriteTile
	pop hl
	pop bc

	inc c
	ld d, 0
	ld e, 9
	add hl, de
	djnz c2Loop

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
