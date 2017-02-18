collisionPNMovX:        equ 6
collisionPNMovY:        equ 7

collisionTileFirstMask:  equ %1111$1000
collisionTilePixelsMask: equ %0000$0111

collisionGameplayAttrOffset:    equ 10

collisionPNUpdatesOldX:    equ 0
collisionPNUpdatesNewX:    equ 1
collisionPNUpdatesOldY:    equ 2
collisionPNUpdatesNewY:    equ 3
collisionPNUpdatesOldPose: equ 4
collisionPNUpdatesNewPose: equ 5
collisionPNUpdatesTileX:   equ 6
collisionPNUpdatesTileY:   equ 7
collisionPNUpdatesTilePtr: equ 8

updateCollision:
        push iy
        push ix
        ld ix, p1StateBase
        ld iy, fuP1UpdatesBase
        call collisionPrepareUpdates
        call updateCollisionBody
        ld ix, p2StateBase
        ld iy, fuP2UpdatesBase
        call collisionPrepareUpdates
        call updateCollisionBody
        pop ix
        pop iy
        ret

        ;; ---------------------------------------------------------------------
        ;; collisionBody
        ;; ---------------------------------------------------------------------
        ;; PRE: N is the player number
        ;;      pNStateBase is in IX register
        ;;      fuPNUpdatesBase in IY register
        ;; POST: collision detection done for player N including output writing
updateCollisionBody:
        call collisionHandleHorizontal
        ret

        ;; ---------------------------------------------------------------------
        ;; prepareUpdates
        ;; ---------------------------------------------------------------------
        ;; Pre: N is the player number
        ;;      fuPNUpdatesBase in IY register
        ;; POST: fuPNUpdatesBase cleared to 'no-updates' state
collisionPrepareUpdates:
        ld a, (iy + collisionPNUpdatesNewX)
        ld (iy + collisionPNUpdatesOldX), a

        ld a, (iy + collisionPNUpdatesNewY)
        ld (iy + collisionPNUpdatesOldY), a

        ld a, (iy + collisionPNUpdatesNewPose)
        ld (iy + collisionPNUpdatesOldPose), a

        ld (iy + collisionPNUpdatesTilePtr), 0
        ret

        ;; ---------------------------------------------------------------------
        ;; handleHorizontal
        ;; ---------------------------------------------------------------------
        ;; PRE: N is the player number
        ;;      pNStateBase is in IX register
        ;;      fuPNUpdatesBase in IY register
        ;; Post: x movement resolved
        ;;       new X position updated in frame updates
        ;;       IX regester preserved
        ;;       IY register preserved
collisionHandleHorizontal:
        ld a, (IY + collisionPNUpdatesOldX) ; a contains posX
        add a, (IX + collisionPNMovX)       ; a contains posX + movX
        ld e, a                 ; We're going to use this a lot,
                                ; save it in e

        ;; Did we even try to move?
        ld a, (IX + collisionPNMovX)
        cp 0
        ret z                   ; if movX == 0, return, do not move

        and collisionTileFirstMask ; Are we in the first column of this tile?
        cp (IX + collisionPNUpdatesOldX)
        jp z, collisionHandleHorizontalStepTwo ; If so, there's no move that is
                                               ; "safe". Jump to step two

;; collisionHandleHorizontalStepOne:
        ;; Did we move left or right?
        ;; ld a, (IX + collisionPNMovX)
        ;; cp 0
        jp p, collisionHandleHorizontalMovementPos ; did we move right?
        ;; if we're here, then movement was negative

        ld a, (IY + collisionPNUpdatesOldPose) ; a contains old cat pose
        or catPoseFaceLeft                     ; cat facing left
        ld (IY + collisionPNUpdatesOldPose), a ; new cat pose facing left

        ld a, (IY + collisionPNUpdatesOldX) ; a contains posX
        and collisionTileFirstMask          ; a contains the furthest left pixel
                                            ; column that we can move to safely
        cp e                                ; is canMove < wantToMove?
        jp p, collisionHandleHorizontalMovementPosNegEnd
        ;;  If we're here, then wantToMove < canMove
        ld a, e
        jp collisionHandleHorizontalMovementPosNegEnd
collisionHandleHorizontalMovementPos:
        ;; if we're here, then movement was positive

        ld a, (IY + collisionPNUpdatesOldPose) ; a contains old cat pose
        and catPoseFaceLeftClearMask           ; cat facing right
        ld (IY + collisionPNUpdatesOldPose), a ; new cat pose facing right

        ld a, (IY + collisionPNUpdatesOldX) ; a contains posX
        or collisionTilePixelsMask    ; a contains the furthest right pixel
                                      ; column that we can move to safely
        cp e                          ; is canMove < wantToMove?
        jp m, collisionHandleHorizontalMovementPosNegEnd
        ;;  If we're here, then wantToMove < canMove
        ld a, e
collisionHandleHorizontalMovementPosNegEnd:
        ;; a contains the furthest we can move in this tile

        ld (IY + collisionPNUpdatesNewX), a ; Go ahead and move to the edge of
                                            ; the tile
        sub (IY + collisionPNUpdatesOldX)   ; a contains dest - pos = deltaX
        ld b, a                              ; b contains deltaX
        ld a, (IX + collisionPNMovX)         ; a contains movX
        sub b                                ; a contains movX - deltaX
        ld (IX + collisionPNMovX), a          ; movX = movX - deltaX

        ;; Are we done?
        cp 0
        ret z                   ; If movX - deltaX = 0, then we're done

collisionHandleHorizontalStepTwo:

        ;; Make sure we aren't trying to walk off the screen
        ld a, (IX + collisionPNMovX)        ; a contains movX
        cp 0                                ; are we going left or right?
        jp P, collisionHandleHorizontalRightEdge
        ;; If we're here, then we're walking left

        ld a, (IY + collisionPNUpdatesNewX) ; a contains X position
        ;; TODO: get rid of this?
        ;; add a, (IX + collisionPNMovX)       ; a contains desired X position
        cp 0                                ; Are we in the leftmost pixel?
        ret z                               ; If we are, return, do not move
        jp collisionHandleHorizontalLeftRightEdgeEnd
collisionHandleHorizontalRightEdge:
        ;; If we're here, then we're walking right
        ld a, (IY + collisionPNUpdatesNewX) ; a contains X position
        ;; TODO: get rid of this?
        ;; add a, (IX + collisionPNMovX)       ; a contains desired X position
        add a, catPixelWidth                ; a contains X + cat width

        ;; TODO: pixelWidth or pixelWidth - 1?
        cp levelPixelWidth      ; Are we in the rightmost pixel?
        ret z                   ; If we are, return, do not move

collisionHandleHorizontalLeftRightEdgeEnd:
        ;; prepare to loop and check each row of the player N for collisions
        ld b, catHeight                      ; b contains the cat's height

collisionHandleHorizontalCollisionLoop:

        ld a, (IY + collisionPNUpdatesNewX) ; a contains X position
        ld d, (IY + collisionPNUpdatesOldY) ; d contains Y position
        add a, (IX + collisionPNMovX)       ; a contains desired X position
        ld c, a                             ; c contains desired X position

        ld h, 0
        ld a, (IX + collisionPNMovX)        ; a contains movX
        cp 0                                ; are we going left or right?
        jp M, collisionHandleHorizontalCatWidthEnd
        ld h, catWidth         ; If moving right, compensate for cat width
collisionHandleHorizontalCatWidthEnd:
        ;; h contains 0 if moving left, catWidth if moving right
        ld a, catHeight                     ; a contains the height of the cat
        sub b                               ; a contains current row - catheight
                                            ; 2-2 = 0, 2-1 = 1, etc...
        ld l, a                             ; l contains the row of the cat to
                                            ; check


        call collisionCalculateGameLevelPtr ; HL now contains pointer to tile
                                            ; index that we want to move to

        call collisionGetGameplayAttribute ; a now contains the gameplay
                                           ; attribute of the tile we want to
                                           ; move to

        and tgaPassable                    ; a contains 0 IFF passable bit is
                                           ; not set

        ret z                   ; if tile we are trying to move into is not
                                ; passable, then do not move

        djnz collisionHandleHorizontalCollisionLoop ; iterate if rows remain

        ;; If we made it this far, then no tiles blocked us. Commit the move

        ld a, (IY + collisionPNUpdatesNewX) ; a contains the current new posX
        add a, (IX + collisionPNMovX)       ; add remaining movement distance
        ld (IY + collisionPNUpdatesNewX), a ; x movement complete
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
        ;;       IY is preserved
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
        ld hl, dynamicTileInstanceBase ; IY contains pointer to start of dynamic
                                       ; instances area
        and levelTileIndexMask    ; a contains an index into the dynamic
                                  ; instances area
        add a, collisionGameplayAttrOffset ; a contains index into the dynamic
                                           ; instances area offset to the
                                           ; gameplay attribute
        ld d, 0
        ld e, a
        add hl, de              ; hl contains a pointer to a gameplay attribute
        ld a, (hl)              ; a contains gameplay attribute
                                ; of this dynamic tile
        ret

        ;; ---------------------------------------------------------------------
        ;; calculateGameLevelPtr
        ;; ---------------------------------------------------------------------
        ;; PRE: c contains the x pixel coordinate
        ;;      d contains the y pixel coordinate
        ;;      h contains a tile offset to add to x
        ;;      l contains a tile offset to add to y
        ;;      <x, y> is in range
        ;; POST: HL contains a pointer to the gameLevel index that
        ;;       <x, y> falls in
        ;;       b is preserved
        ;;       IX preserved
        ;;       IY is preserved
collisionCalculateGameLevelPtr:
        ld a, c
        srl a
        srl a
        srl a

        add a, h                ; a contains the tile column we want to move to

        push bc

        ld b, 0
        ld c, a                 ; c now contains column index

        ld a, d
        srl a
        srl a
        srl a
        add a, l                ; a contains the tile row we are in

        ld d, 0
        ld e, a                 ; DE now contains row index
        ld h, 0
        ld l, levelColumnWidth  ; HL now contains the column width

        call multiply           ; HL now contains column Width * row Index



        ld DE, gameLevel        ; DE now contains pointer to gameLevel[0][0]
        add HL, BC              ; HL now contains columnIndex + rowIndex * columnWidth
        add HL, DE              ; HL now contains gameLevel + tile offset

        pop bc
        ret
