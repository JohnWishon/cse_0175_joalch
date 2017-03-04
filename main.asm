        org $8000
        jp main
        include "defines.asm"

main:
        ;; ---------------------------------------------------------------------
        ;; Setup program state, interrupt handling scheme
        ;; ---------------------------------------------------------------------

        ld a,2                 ; upper screen
        call openChannel

        call setupGameLogic

	call setupGraphics

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
        call updateKeystate    ; TODO: real key update routine

        ;; Update: physics simulation, ai, collision detection
        call updatePhysics
        call updateAI
        call updateCollision

        call updateGameLogic

        ;; End of iteration
        ;; Transition the sate machine if needed, halt

        ; halt
        ; jp drawIteration        ; TODO: interrupt handler should handle this
        ; jp endProg              ; Never return to basic
        ret

drawIteration:
        ;; Read state machine, jump to correct iteration type

        ;; TODO: this section
        ;; TODO: potentially multiple draw iteration types (with/without music)


        ;; Draw the frame
        call drawFrame

        ;; End of iteration
        ; halt
        ; jp updateIteration      ; TODO: interrupt handler should handle this
        ; jp endProg              ; Never return to basic
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
        include "draw.asm"
