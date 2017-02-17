collisionPNMovX:        equ 6
collisionPNMovY:        equ 7
collisionPNPosX:        equ 9
collisionPNPosY:        equ 10

collisionTileFirstMask:  equ %1111$1000
collisionTilePixelsMask: equ %0000$0111

collisionGameplayAttrOffset:    equ 10

updateCollision:
        ld ix, p1StateBase
        ld c, 1
        call updateCollisionBody
        ld c, 2
        ld ix, p2StateBase
        call updateCollisonBody
        ret

        ;; ---------------------------------------------------------------------
        ;; collisionBody
        ;; ---------------------------------------------------------------------
        ;; PRE: N is the player number
        ;;      pNStateBase is in IX register
        ;;      N is in C register
        ;; POST: collision detection done for player N including output writing
updateCollisionBody:
        ret


        ;; ---------------------------------------------------------------------
        ;; handleHorizontal
        ;; ---------------------------------------------------------------------
        ;; PRE: N is the player number
        ;;      pNStateBase is in IX register
        ;;      N is in C register
        ;; Post: x movement resolved
        ;;       c register preserved
        ;;       IX regester preserved
collisionHandleHorizontal:
        ;; did we even try to move?
        ld a, (IX + collisionPNMovX) ; load moveX
        cp 0
        jp z handleHorizontalNoMovement ; return if deltaX = 0

        ld a, (IX + collisionPNPosX)  ; a contains posX
        add a, (IX + collisionPNMovX) ; a contains posX + movX
        and collisionTileFirstMask    ; a contains the leftmost pixel column
                                      ; of the tile we would be in
        ld b, a                       ; save it into b

        ld a, (IX + collisionPNPosX) ; a contains posX
        and collisionTileFirstMask   ; a contains the leftmost pixel column
                                     ; of the tile we are in



        ;; Are we aligned to a tile boundary?
        ld a, (IX + collisionPNPosX) ; load posX
        and %0000$0111 ; We are tile aligned IFF the lower 3 bits are 0
        jp z handleHorizontalEndMovement ; If we aren't on a tile boundary, then
        ;; there is no possibility of a horizontal collision. Commit the move

        ;; Are we trying to move left or right?

        cp 0                             ; a contains moveX
        jp p handleHorizontalMovingRight ; if positive, we're moving right

        ;; If we're here, that means we're moving left

        ld a, (IX + collisionPNPosX) ; load posX
        cp levelLeftmostPixel        ; Is P1 in the leftmost pixel column?
        jp z handleHorizontalNoMovement ; If yes, do not move

        ld a, (IX + collisionPNPosY)
        ld b, a                      ; b contains pixel row we are in
        add (IX + collisionPNMovX) ; a contains pixel column we want to move to
        call collisionCalculateGameLevelPtr ; HL now contains pointer to tile
                                            ; index that we want to move to

        call collisionGetGameplayAttribute ; a now contains the gameplay
                                           ; attribute of the tile we want to
                                           ; move to



        jp handleHorizontalEndMovement ; unconditionally jump over handle right
handleHorizontalMovingRight:


handleHorizontalEndMovement:
        ret
handleHorizontalNoMovement:
        ret


        ;; ---------------------------------------------------------------------
        ;; Subroutines
        ;; ---------------------------------------------------------------------

        ;; ---------------------------------------------------------------------
        ;; getGameplayAttribute
        ;; ---------------------------------------------------------------------
        ;; PRE: HL contains a pointer into gameLevel to query
        ;; POST: a contains the gameplay attribute of the tile
        ;;       IX is preserved
        ;;       C is preserved
collisionGetGameplayAttribute:
        ld a, (HL)              ; a contains tile data
        and levelDummyTileMask  ; a contains 0 IFF this is a dummy tile

        jp nz, collisionGetGameplayAttributeDeref ; if a != 0, this is not
                                                  ; a dummy tile. We need to
                                                  ; dereference the index

        ;; If we're here, that means this is a dummy tile index
        ld a, (HL)              ; a contains gameplay attribute of this
                                ; dummy tile
        ret
collisionGetGameplayAttributeDeref:
        ld a, (HL)              ; restore tile data to a
        ld iy, dynamicTileInstanceBase ; IY contains pointer to start of dynamic
                                       ; instances area
        and a, levelTileIndexMask ; a contains an index into the dynamic
                                  ; instances area
        ld d, 0
        ld e, a
        add iy, hl              ; IY contains a pointer to a dynamic instance
        ld a, (iy + collisionGameplayAttrOffset) ; a contains gameplay attribute
                                                 ; of this dynamic tile
        ret

        ;; ---------------------------------------------------------------------
        ;; calculateGameLevelPtr
        ;; ---------------------------------------------------------------------
        ;; PRE: a contains the x pixel coordinate
        ;;      b contains the y pixel coordinate
        ;;      <x, y> is in range
        ;; POST: HL contains a pointer to the gameLevel index that
        ;;       <x, y> falls in
        ;;       IX preserved
        ;;       C preserved
collisionCalculateGameLevelPtr:
        sra
        sra
        sra                     ; a contains the tile column we want to move to
        ld d, 0
        ld e, a                 ; DE now contains column index

        ld a, b
        sra
        sra
        sra                     ; a contains the tile row we are in
        ld h, 0
        ld l, a                 ; HL now contains row index

        call multiply           ; HL now contains offset of the tile we want to
                                ; move to

        ld DE, gameLevel        ; DE now contains pointer to gameLevel[0][0]
        add HL, DE              ; HL now contains gameLevel + tile offset

        ret
