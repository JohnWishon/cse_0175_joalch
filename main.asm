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
        call displayKeystate    ; TODO: real key update routine


        ;; Update: physics simulation, ai, collision detection
        call updatePhysics

        call updateAI

        call updateCollision

        ;; End of iteration
        ;; Transition the sate machine if needed, halt

        halt
        jp drawIteration        ; TODO: interrupt handler should handle this
        jp endProg              ; Never return to basic

drawIteration:
        ;; Read state machine, jump to correct iteration type

        ;; TODO: this section
        ;; TODO: potentially multiple draw iteration types (with/without music)


        ;; Draw the frame
        call drawFrame

        ;; End of iteration
        halt
        jp updateIteration      ; TODO: interrupt handler should handle this
        jp endProg              ; Never return to basic




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
