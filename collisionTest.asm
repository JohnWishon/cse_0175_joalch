        org $8000

        include "defines.asm"

main:
        ;; ---------------------------------------------------------------------
        ;; Setup program state, interrupt handling scheme
        ;; ---------------------------------------------------------------------

        ld a,2                 ; upper screen
        call openChannel


updateIteration:
        ;; Read state machine, jump to correct iteration type

        ;; TODO: this section
        ;; TODO: multiple update iteration types


        ;; Read input, update player state
        call updateKeystate


        ;; Update: physics simulation, ai, collision detection
        call updatePhysics

        call updateAI

        call displayAttemptedMove
        call updateCollision
        call displayCollisionState

        ;; End of iteration
        ;; Transition the sate machine if needed, halt

        halt
        jp updateIteration
        jp endProg              ; Never return to basic

displayAttemptedMove:
        ld hl, p1MovX
        ld a, (hl)
        cp 0
        call nz, displayMovX

displayCollisionState:
        ld HL, fuP1UpdatesOldPosX
        ld a, (HL)
        ld HL, fuP1UpdatesNewPosX
        ld a, (HL)
        cp b
        call nz, displayPosX

        ;; TODO: more as I get to them
        ret

printNumber:    equ 6683

displayMovX:
        ld de, movXStr
        ld bc, XmovXStr - movXStr
        call print

        ld b, 0
        ld hl, p1MovX
        ld c, (hl)
        call printNumber

movXStr:         defb newline, "Player wants to move:", newline
XmovXStr:

displayPosX:
        ld de, posXStr
        ld bc, XposXStr - posXStr
        call print

        ld b, 0
        ld hl, fuP1UpdatesNewPosX
        ld c, (hl)
        call printNumber

posXStr:         defb newline, "New X position:", newline
XposXStr:


        ;; ---------------------------------------------------------------------
        ;; We never return to basic. If execution gets here, just spin forever
        ;; ---------------------------------------------------------------------
endProg:
        nop
        jp endProg



	include "input.asm"
        include "physics.asm"
        include "ai.asm"
        include "collision.asm"
        include "draw.asm"
