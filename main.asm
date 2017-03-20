        org $8000
        jp main
        include "defines.asm"
GCheck:
        LD BC,$FDFE	;Read keys G-F-D-S-A
        IN A,(C)
        AND $10		;Keep only bit 0 of the result (ENTER, 0)
        CP $01		;Reset the zero flag if ENTER or 0 is being pressed
        RET
SCheck:
        LD BC,$FDFE	;Read keys G-F-D-S-A
        IN A,(C)
        AND $02		;Keep only bit 0 of the result (ENTER, 0)
        CP $01		;Reset the zero flag if ENTER or 0 is being pressed
        RET
ICheck:
        LD BC,$DFFE	;Read keys Y-U-I-O-P
        IN A,(C)
        AND $04		;Keep only bit 0 of the result (ENTER, 0)
        CP $01		;Reset the zero flag if ENTER or 0 is being pressed
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
	    JP  NZ, runGreetz ; Jump to greetz screen if so.
	    CALL SCheck
	    JP  NZ, startGame
	    jp  mainLoadingScreenMusicPaused
waitSpaceKey:
		ld a,(23560)        ; read keyboard.
		cp 32               ; is SPACE pressed?
		jr nz,waitSpaceKey  ; no, wait.
		call startGame      ; play the game.
		jr waitSpaceKey     ; SPACE to restart game.
startGame:
        ld a, ($5c78)
        ld (seed), a

        call setupGameLogic
        call setupGraphics
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
