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


; 	ld hl, DEVELOPERS
; 	ld b, 10
; 	ld c, 19
; devLoop:
; 	push bc
; 	ld b, 9
; 	ld de, 0
; 	push hl
; 	call renderFrameWriteTile
; 	pop hl
; 	pop bc
;
; 	inc c
; 	ld d, 0
; 	ld e, 9
; 	add hl, de
; 	djnz devLoop


runGreetz:
; Greetz drawing code
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
	ret
; runMenu:
    ;; Menu drawing code
    ; call    CCheck
    ; JP  nz, runInstruction
    ; call    SCheck
    ; JP  nz, startGame
runInstruction:
	ld hl, CSE_0175
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
