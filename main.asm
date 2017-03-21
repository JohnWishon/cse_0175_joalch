        org $8000
        jp main
        include "defines.asm"

mainPlayer1WinPix:
        defb $f8, $fc, $cc, $cc, $fc, $f8, $c0, $c0 ; P
             ;$c0, $c0, $c0, $c0, $c0, $c0, $fc, $fc, ; L
             ;$78, $fc, $cc, $cc, $fc, $fc, $cc, $cc, ; A
             ;$cc, $cc, $cc, $fc, $78, $30, $30, $30, ; Y
             ;$fc, $fc, $c0, $fc, $fc, $c0, $fc, $fc, ; E
             ;$f8, $fc, $cc, $cc, $fc, $f8, $cd, $cc, ; R
        defb $30, $70, $f0, $30, $30, $30, $fc, $fc ; 1
        defb $00, $00, $00, $00, $00, $00, $00, $00 ; Space
        defb $84, $84, $84, $b4, $b4, $fc, $78, $48 ; W
        defb $fc, $fc, $30, $30, $30, $30, $fc, $fc ; I
        defb $cc, $cc, $ec, $fc, $fc, $cd, $cc, $cc ; N
        defb $7c, $fc, $c0, $f8, $7c, $0c, $fc, $f8 ; S
 mainPlayer2WinPix:
        defb $78, $fc, $cc, $cd, $38, $70, $fc, $fc ; 2

GCheck:
        LD BC,$FDFE	;Read keys G-F-D-S-A
        IN A,(C)
        AND $10		;Keep only bit 0 of the result (ENTER, 0)
        CP $10		;Reset the zero flag if ENTER or 0 is being pressed
        RET
SCheck:
        LD BC,$FDFE	;Read keys G-F-D-S-A
        IN A,(C)
        AND $02		;Keep only bit 0 of the result (ENTER, 0)
        CP $02		;Reset the zero flag if ENTER or 0 is being pressed
        RET
CCheck:
        LD BC,$FEFE	;Read keys V-C-X-Z-Shift
        IN A,(C)
        AND $08		;Keep only bit 0 of the result (ENTER, 0)
        CP $08		;Reset the zero flag if ENTER or 0 is being pressed
        RET

MCheck:
	LD BC,$7FFE	;Read keys B-N-M-Shift-Space
	IN A,(C)
	AND $04		;Keep only bit 0 of the result (ENTER, 0)
	CP $04		;Reset the zero flag if ENTER or 0 is being pressed
	RET

main:
        ;; ---------------------------------------------------------------------
        ;; Setup program state, interrupt handling scheme
        ;; ---------------------------------------------------------------------

        ld SP, $FFEE
        ;; TODO: do we need this?
        ld a,2                 ; upper screen
        call openChannel
        ;; TODO: do we need the above?
		;; TODO: should we keep this?

		call runLoadingScreen
mainLoadingScreenMusicPaused:
	    CALL GCheck     ;Check whether G is pressed
	    CALL NZ, runGreetz ; Jump to greetz screen if so.
	    CALL SCheck
	    JP  NZ, startGame
        CALL CCheck
        CALL NZ, runInstruction
	    jp  mainLoadingScreenMusicPaused
startGame:

        ld a, ($5c78)
        ld (seed), a

        call setupGraphics
	    call setupGameLogic
        call setupRenderer

        di                      ; disable interrupts
        ld hl, interrupt        ; interrupt handler addr
        ld ix, $fff0            ; addr to stick code
        ld (ix+04h), $c3        ; c3 = opcode for jp xx
        ld (ix+05h), l          ; where to jp to
        ld (ix+06h), h
        ld (ix+0fh), $18        ; 18 = opcode for jr x
        ld a, $39               ; high byte addr of vector table -- get the FF from $3900
        ld i, a                 ; set interrupt register
        im 2                    ; interrupt mode 2
        ei                      ; enable interrupts again

        jp endProg

updateIteration:
        ;; Read state machine, jump to correct iteration type

        ;; TODO: this section
        ;; TODO: multiple update iteration types
        ;; Read input, update player state

        call updateKeystate

        ;; Update: physics simulation, ai, collision detection
        call updatePhysics
        call updateAI
        call updateCollision

        call updateGameLogic

        call renderFrameSwapBuffers

	call shouldGameEnd
	ld a, b
	cp 1
	jp z, startGame
        ;; End of iteration

        ret

drawIteration:

        ;; Draw the frame

        call renderFrame
        ret

interrupt:
        di                      ; disable interrupts
        push af                 ; save all registers
        push bc
        push de
        push hl
        push ix
        exx
        ex af, af'
        push af
        push bc
        push de
        push hl
        push iy

        ld hl, pretim           ; previous counter
        ld a, ($5c78)           ; frame counter
        sub (hl)                ; difference
        cp 2                    ; 2 frames?
        jr nc, drawSkip
        call updateIteration    ; call update
        jr endCheck
drawSkip:
        call drawIteration      ; call draw
        ld hl, pretim
        ld a, ($5c78)           ; current frame
        ld (hl), a              ; store counter
endCheck:
        ld hl, $5c78            ; increment frame counter
        inc (hl)

        pop iy                  ; restore all registers
        pop hl
        pop de
        pop bc
        pop af
        exx
        ex af, af'
        pop ix
        pop hl
        pop de
        pop bc
        pop af
        ei                      ; enable interrupts
        reti                    ; return from interrupt

endProg:
        nop
        jp endProg


pretim:
        defb 0

shouldGameEnd:
	ld b, 1
	ld a, (p1Interest)
	cp 0
	jp z,mainGameEnd
	ld a, (p2Interest)
	cp 0
	jp z,mainGameEnd
	ld b, 0
	ret

mainGameEnd:
    push    bc
    ld  hl,p1Score
    ld  de,p2Score
    ld  c,5
mainScoreCmpLoop:
    ld  a,(de)      ; a has p2 score
    ld  b,(hl)      ; b has p1 score
    cp  b           ; a - b
    jp  nz,mainScoreCmpLoopEnd
    inc e           ; p1Score and p2Score are away from 256 byte boundary.
    inc l           ; Thus inc e/l is just fine
    dec c
    cp  0
    jp  nz,mainScoreCmpLoop ; Keep looping
    ;; Same score, let P1 win
    cp  1           ; Let flag has S bit, p2_S - p1_S < 0
mainScoreCmpLoopEnd:
    ld  c,0         ; c contains winner, 0 based
    jp  m,mainScoreCmpP1Win
    ld  c,1
mainScoreCmpP1Win:
    push bc         ; Save c

    ld  hl, mainPlayer1WinPix
    ld  b,11
    ld  c,12
    ld  de,0
    call    renderFrameWriteTilePixels
    inc c
    call    renderFrameWriteTilePixels
    inc c
    call    renderFrameWriteTilePixels
    inc c
    call    renderFrameWriteTilePixels
    inc c
    call    renderFrameWriteTilePixels
    inc c
    call    renderFrameWriteTilePixels
    inc c
    call    renderFrameWriteTilePixels      ; Im feeling hacky
    pop bc
    ld  a,c
    cp  0
    jp  z,mainEndGameWait
    ld  hl,mainPlayer2WinPix                ; Change "P1 WINS" to "P2"
    ld  b,11
    ld  c,12+1
    ld  de,0
    call    renderFrameWriteTilePixels
mainEndGameWait:
    ld  b,255
mainEndGameWaitL1:
    push    bc
    ld  b,255
mainEndGameWaitL2:
    push    bc
    ld  b,20
mainEndGameWaitL3:
    djnz    mainEndGameWaitL3
    pop bc
    djnz    mainEndGameWaitL2
    pop bc
    djnz    mainEndGameWaitL1
    pop bc
    ret
        include "input.asm"
        include "physics.asm"
        include "ai.asm"
        include "collision.asm"
        include "gameLogic.asm"
        include "render.asm"
        include "draw.asm"
		include "utilities.asm"
		include "graphics-mainScreen.asm"
		include "graphics-loadingScreen.asm"
        include "graphics-sprites.asm"
		include "music-loadingScreen.asm"
        include "graphics-screens.asm"
