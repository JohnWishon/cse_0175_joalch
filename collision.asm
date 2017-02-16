collisionPNMovX:        equ 6
collisionPNPosX:        equ 9

updateCollision:
        ;; ld  de,collisionStr
        ;; ld  bc,XcollisionStr-collisionStr
        ;; call    print
        ld ix, p1StateBase
        call updateCollisionBody
        ld ix, p2StateBase
        call updateCollisonBody
        ret

        ;; PRE: N is the player number
        ;;      pNStateBase is in IX register
        ;;      N is in D register
updateCollisionBody:


        ret
        ;; POST: collision detection done for player N including output writing

        ;; PRE: N is the player number
        ;;      pNStateBase is in IX register
        ;;      N is in D register
collisionHandleHorizontal:
        ;; read moveX and posX
        ld e, (IX + collisionPNPosX) ; e <- posX
        ld c, (IX + collisionPNMovX) ; c <- moveX

        ;; did we even try to move?
        ld a, c                 ; load moveX
        cp 0
        ret z                   ; return if deltaX = 0

        ;; Are we trying to move past the right edge?

        cp 0                    ; a contains moveX
        jp P handleHorizontalMovingRight ; if positive, we're moving right

        ;; If we're here, that means we're moving left

        ld a, e                 ; load posX
        cp (levelRightmostCol)  ; Is P1 in the rightmost column?
        ret z                   ; If yes, return, do not move

        ld a, c                 ; put moveX back in a

        jp handleHorizontalEndMovement ; unconditionally jump over handle right
handleHorizontalMovingRight:


handleHorizontalEndMovement:
        ret
        ;; Post: x movement resolved
        ;;       e register clobbered
        ;;       c register clobbered

collisionStr:
    defb    "updateCollision", newline
XcollisionStr:
