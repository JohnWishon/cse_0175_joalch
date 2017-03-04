        org $8000

        include "defines.asm"

main:
        ;; ---------------------------------------------------------------------
        ;; Setup program state, interrupt handling scheme
        ;; ---------------------------------------------------------------------

        ld a,2                 ; upper screen
        call openChannel

        ld hl, gameLevel + (1 * levelColumnWidth) + 4
        ld (hl), 0

        call displayPos

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
        jp nz, displayAttemptedMoveDoIt
        ld hl, p1MovY
        ld a, (hl)
        cp 0
        ret z
displayAttemptedMoveDoIt:
        call displayMov
        ret

displayCollisionState:
        ld HL, fuP1UpdatesOldPosX
        ld a, (HL)
        ld HL, fuP1UpdatesNewPosX
        ld b, (HL)
        cp b
        jp nz, displayCollisionStateDoIt
        ld HL, fuP1UpdatesOldPosY
        ld a, (HL)
        ld HL, fuP1UpdatesNewPosY
        ld b, (HL)
        cp b
        ret z
displayCollisionStateDoIt:
        call displayPos

        ;; TODO: more as I get to them
        ret

printNumber:    equ 6683

displayMov:
        ld de, movStrPrelude
        ld bc, XmovStrPrelude - movStrPrelude
        call print

        ld de, movStrOpen
        ld bc, XmovStrOpen - movStrOpen
        call print

        ld b, 0
        ld hl, p1MovX
        ld c, (hl)
        call printNumber

        ld de, movStrMid
        ld bc, XmovStrMid - movStrMid
        call print

        ld b, 0
        ld hl, p1MovY
        ld c, (hl)
        call printNumber

        ld de, movStrEnd
        ld bc, XmovStrEnd - movStrEnd
        call print

        ret


movStrPrelude:         defb newline, "Movement = "
XmovStrPrelude:

movStrOpen:     defb "<"
XmovStrOpen:

movStrMid:      defb ", "
XmovStrMid:

movStrEnd:      defb ">", newline
XmovStrEnd:

displayPos:
        ld de, posStrPrelude
        ld bc, XposStrPrelude - posStrPrelude
        call print

        ;; top left corner

        ld de, posStrOpen
        ld bc, XposStrOpen - posStrOpen
        call print

        ld b, 0
        ld hl, fuP1UpdatesNewPosX
        ld c, (hl)
        call printNumber

        ld de, posStrMid
        ld bc, XposStrMid - posStrMid
        call print

        ld b, 0
        ld hl, fuP1UpdatesNewPosY
        ld c, (hl)
        call printNumber

        ld de, posStrEnd
        ld bc, XposStrEnd - posStrEnd
        call print

        ;; bottom right corner

        ld de, posStrOpen
        ld bc, XposStrOpen - posStrOpen
        call print

        ld b, 0
        ld hl, fuP1UpdatesNewPosX
        ld a, (hl)
        add a, catPixelWidth - 1
        ld c, a
        call printNumber

        ld de, posStrMid
        ld bc, XposStrMid - posStrMid
        call print

        ld b, 0
        ld hl, fuP1UpdatesNewPosY
        ld a, (hl)
        add a, catPixelHeight - 1
        ld c, a
        call printNumber

        ld de, posStrEnd
        ld bc, XposStrEnd - posStrEnd
        call print

        ret

posStrPrelude:         defb newline, "New position = "
XposStrPrelude:

posStrOpen:     defb "<"
XposStrOpen:

posStrMid:      defb ", "
XposStrMid:

posStrEnd:      defb ">", newline
XposStrEnd:

displayFailX:
        ld de, failXStr
        ld bc, XfailXStr - failXStr
        call print

        ld b, 0
        ld hl, fuP1UpdatesNewPosX
        ld c, (hl)
        call printNumber
        ret

failXStr:         defb newline, "Failed to move in X. Position:", newline
XfailXStr:


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
