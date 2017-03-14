collisionHandleVerticalMovY: defb 0

collisionPNMovX:           equ 6
collisionPNMovY:           equ 7
collisionPNMoveState:      equ 8
collisionPNCollisionState: equ 9

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
        call collisionHandleVertical
        ret

        ;; ---------------------------------------------------------------------
        ;; prepareUpdates
        ;; ---------------------------------------------------------------------
        ;; Pre: N is the player number
        ;;      fuPNUpdatesBase in IY register
        ;;      pNStateBase is in the IX register
        ;; POST: fuPNUpdatesBase cleared to 'no-updates' state
        ;;       pNCollisionState cleared to 0
collisionPrepareUpdates:
        ld a, (iy + collisionPNUpdatesNewX)
        ld (iy + collisionPNUpdatesOldX), a

        ld a, (iy + collisionPNUpdatesNewY)
        ld (iy + collisionPNUpdatesOldY), a

        ld a, (iy + collisionPNUpdatesNewPose)
        ld (iy + collisionPNUpdatesOldPose), a

        ld (iy + collisionPNUpdatesTilePtr), 0

        ld (ix + collisionPNCollisionState), 0
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

        ;; Did we even try to move?
        ld a, (IX + collisionPNMovX)
        cp 0
        ret z                   ; if movX == 0, return, do not move

        ;; attempt to move to the edge of the tile

        ;; ld c, (IY + collisionPNUpdatesOldX) ; c contains posX
        ;; ld d, (IX + collisionPNMovX)        ; d contains movX
        ;; call collisionCalculateSubtileMovement ; calculate the distance to move
        ;; ;; the player to the next or previous first tile column

        ;; ;; a contains the distance to we can move in this step
        ;; ;; b contains the distance remaining to move

        ;; ;; c contains the distance we can move
        ;; ;; b contains remaining distance

        ;; ld a, (IY + collisionPNUpdatesOldX) ; a contains the old position
        ;; add a, c                            ; a contains old pos + d_can
        ;; ld (IY + collisionPNUpdatesNewX), a ; move the cat by d_can

        ;; ld a, b                 ; a contains d_remain
        ;; cp 0
        ;; ret z                   ; if d_remain = 0, we're done.

        ;; enter collision loop
        ld b, (IX + collisionPNMovX) ; b contains d_remain

collisionHandleHorizontalLoop:
        ;; test collisions against level edges

        ld a, b                 ; a contains d_remain
        jp p, collisionHandleHorizontalLoopScreenRight
        ;; If we're here, then we want to move left
        ;; load H with correct offset since we're here
        ld h, -1

        ld a, (IY + collisionPNUpdatesNewX) ; a contains current x pos
        cp 0                                ; is this the leftmost pixel?
        jp z, collisionHandleHorizontalCollisionLeft ; if so, collide left
        jp collisionHandleHorizontalLoopScreenLeftRightEnd
collisionHandleHorizontalLoopScreenRight:
        ;; If we're here, then we want to move right

        ;; load H with correct offset since we're here
        ld h, catWidth

        ld a, (IY + collisionPNUpdatesNewX) ; a contains current x pos
        cp levelPixelWidth - catPixelWidth + 1  ; is this the rightmost pixel?
        jp z, collisionHandleHorizontalCollisionRight ; if so, collide Right
collisionHandleHorizontalLoopScreenLeftRightEnd:

        ;; Enter cat height inner loop

        ld e, catHeight     ; e contains cat height
        ;; b contains d_remain
collisionHandleHorizontalCatHeightLoop:
        dec e                   ; e contains next row to check (1 -> 0 -> break)
        push bc
        push de
        push hl
        ld c, (IY + collisionPNUpdatesNewX) ; c contains current X position
        ld d, (IY + collisionPNUpdatesOldY) ; c contains Y position
        ;; h contains catWidth or -1 already
        ld l, e                 ; l contains current row to test

        call collisionCalculateGameLevelPtr

        ;; hl contains pointer to gameLevel index

        call collisionGetGameplayAttribute

        ;; a contains gameplay attribute

        pop hl
        pop de
        pop bc

        and tgaPassable         ; a contains 0 IFF passable bit is not set
        jp z, collisionHandleHorizontalCollision ; if not passable, then collide

        ld a, e                 ; a contains current row
        cp 0
        jp nz, collisionHandleHorizontalCatHeightLoop ; iterate if not on row 0

        ;; If we're here, then we are clear to move up to 1 tile
        ld c, (IY + collisionPNUpdatesNewX) ; c contains current X position
        ld d, b                             ; d contains d_remain
        call collisionCalculateSubtileMovement

        ;; c contains new d_can
        ;; b contains new d_remain



        ld a, (IY + collisionPNUpdatesNewX) ; a contains current X position
        add a, c                            ; advance X position
        ld (IY + collisionPNUpdatesNewX), a ; posX += d_can

        ld a, b                 ; a contains d_remain
        cp 0
        ret z                   ; if d_remain = 0, we're done



        jp collisionHandleHorizontalLoop ; Otherwise iterate until we either
        ;; collide or move the whole distance

collisionHandleHorizontalCollision:
        jp 0
        ;; If we're here, then we bumped into something. Set the collision
        ;; state and return without moving any further
        ld a, (IX + collisionPNMovX) ; a contains movement vector
        cp 0                         ; left or right
        jp p, collisionHandleHorizontalCollisionRight
collisionHandleHorizontalCollisionLeft:
        ;; If we're here, then we're moving left
        ld a, (IX + collisionPNCollisionState) ; a contains collision state
        or collisionStateBlockedLeft           ; collide left
        ld (IX + collisionPNCollisionState), a ; update collision state
        ret                                    ; return, do not move
collisionHandleHorizontalCollisionRight:
        ld a, (IX + collisionPNCollisionState) ; a contains collision state
        or collisionStateBlockedRight          ; collide right
        ld (IX + collisionPNCollisionState), a ; update collision state
        ret                                    ; return, do not move

        ;; ---------------------------------------------------------------------
        ;; handleVertical
        ;; ---------------------------------------------------------------------
        ;; PRE: N is the player number
        ;;      pNStateBase is in IX register
        ;;      fuPNUpdatesBase in IY register
        ;; Post: y movement resolved
        ;;       new Y position updated in frame updates
        ;;       IX regester preserved
        ;;       IY register preserved
collisionHandleVertical:
        ret
        ;; Did we even try to move?
        ld a, (IX + collisionPNMovY)
        cp 0
        jp nz, collisionHandleVerticalYesWereMoving ; if not zero, then yes
        ;; If we're here, then we're not moving in Y. Verify there are no
        ;; wile-e-coyote situations occuring
        ld a, (IX + collisionPNMoveState)           ; a contains movement state
        cp movementStateGround                      ; are we on the "ground"?
        ret nz                                      ; if not on ground, return
                                                    ; let physics do its thing
        ld (IX + collisionPNMoveState), movementStateFalling
        ld a, -1
        ld (IX + collisionPNMovY), a ; Try to slowly fall, let ground
        ;;  stop us if really it's there. This prevents wile-e-coyote situations
collisionHandleVerticalYesWereMoving:

        ld a, (IY + collisionPNUpdatesOldY) ; a contains posY
        add a, (IX + collisionPNMovY)       ; a contains posY + movY
        ld e, a                 ; We're going to use this a lot,
                                ; save it in e
        ld a, (IX + collisionPNMovY)
        ld (collisionHandleVerticalMovY), a ; localMovY contains MovY


        ld a, (IY + collisionPNUpdatesOldY)
        and collisionTileFirstMask ; Are we in the first row of this tile?
        cp (IY + collisionPNUpdatesOldY)
        jp z, collisionHandleVerticalStepTwo ; If so, there's no move that is
                                             ; "safe". Jump to step two

        ;; Did we move up or down?

        jp p, collisionHandleVerticalMovementPos ; did we move up?
        ;; if we're here, then movement was negative

        ld a, (IY + collisionPNUpdatesOldY) ; a contains posY
        and collisionTileFirstMask          ; a contains the furthest down pixel
                                            ; row that we can move to safely
        cp e                                ; is canMove < wantToMove?
        jp p, collisionHandleVerticalMovementPosNegEnd
        ;;  If we're here, then wantToMove < canMove
        ld a, e
        jp collisionHandleVerticalMovementPosNegEnd
collisionHandleVerticalMovementPos:
        ;; if we're here, then movement was positive

        ld a, (IY + collisionPNUpdatesOldY) ; a contains posY
        or collisionTilePixelsMask    ; a contains the furthest up pixel
                                      ; row that we can move to safely
        cp e                          ; is canMove < wantToMove?
        jp m, collisionHandleVerticalMovementPosNegEnd
        ;;  If we're here, then wantToMove < canMove
        ld a, e
collisionHandleVerticalMovementPosNegEnd:
        ;; a contains the furthest we can move in this tile, or the desired
        ;; move itself it is in the safe range

        ld (IY + collisionPNUpdatesNewY), a ; Go ahead and move to the edge of
                                            ; the tile
        sub (IY + collisionPNUpdatesOldY)   ; a contains dest - pos = deltaY
        ld b, a                              ; b contains deltaY
        ld a, (collisionHandleVerticalMovY)  ; a contains movY
        sub b                                ; a contains movY - deltaY
        ld (collisionHandleVerticalMovY), a  ; movY = movY - deltaY

        ;; Are we done?
        cp 0
        ret z                   ; If movY - deltaY = 0, then we're done

collisionHandleVerticalStepTwo:
        ;; Make sure we aren't trying to move off the screen
        ld a, (collisionHandleVerticalMovY) ; a contains movY
        cp 0                                ; are we going up or down?
        jp P, collisionHandleVerticalTopEdge
        ;; If we're here, then we're moving down

        ld a, (IY + collisionPNUpdatesNewY) ; a contains Y position

        cp levelBottommostPixel + catPixelHeight ; Are we in the bottommost pixel?
        jp z, collisionHandleVerticalCollisionDown ; If we are, collide down
        jp collisionHandleVerticalTopBottomEdgeEnd
collisionHandleVerticalTopEdge:
        ;; If we're here, then we're moving up
        ld a, (IY + collisionPNUpdatesNewY) ; a contains Y position
        add a, catPixelHeight               ; a contains Y + cat height

        cp levelPixelHeight      ; Are we in the topmost pixel?
        jp z, collisionHandleVerticalCollisionUp ; If we are, collide up
collisionHandleVerticalTopBottomEdgeEnd:
        ;; prepare to loop and check each col of the player N for collisions
        ld b, catWidth                      ; b contains the cat's width

collisionHandleVerticalCollisionLoop:

        ld c, (IY + collisionPNUpdatesNewX) ; a contains X position
                                            ; X has already been resolved at
                                            ; this point
        ld a, (IY + collisionPNUpdatesNewY) ; d contains Y position
        ld hl, collisionHandleVerticalMovY
        add a, (hl)                         ; a contains desired Y position
        ld d, a                             ; d contains desired Y position

        ld l, 0
        ld a, (collisionHandleVerticalMovY) ; a contains movY
        cp 0                                ; are we going up or down?
        jp M, collisionHandleVerticalCatHeightEnd
        ld l, catHeight         ; If moving up, compensate for cat height
collisionHandleVerticalCatHeightEnd:
        ;; l contains 0 if moving down, catHeight if moving up
        ld a, catWidth                      ; a contains the width of the cat
        sub b                               ; a contains current col - catwidth
                                            ; 2-2 = 0, 2-1 = 1, etc...
        ld h, a                             ; l contains the row of the cat to
                                            ; check

        call collisionCalculateGameLevelPtr ; HL now contains pointer to tile
                                            ; index that we want to move to

        call collisionGetGameplayAttribute ; a now contains the gameplay
                                           ; attribute of the tile we want to
                                           ; move to

        and tgaStandable                   ; a contains 0 IFF passable bit is
                                           ; not set

        jp z, collisionHandleVerticalCollision ; handle potential collision

        djnz collisionHandleVerticalCollisionLoop ; iterate if cols remain

        ;; If we made it this far, then no tiles blocked us. Commit the move

        ld a, (IY + collisionPNUpdatesNewY) ; a contains the current new posY
        ld hl, collisionHandleVerticalMovY
        add a, (hl)                         ; add remaining movement distance
        ld (IY + collisionPNUpdatesNewY), a ; y movement complete
        ret
collisionHandleVerticalCollision:
        ;; If we're here, then we bumped into something. Set the collision
        ;; state, update the movement vector, and return without moving
        ld a, (IX + collisionPNMovX) ; a contains movement vector
        cp 0                         ; up or down
        jp p, collisionHandleVerticalCollisionUp
collisionHandleVerticalCollisionDown:
        ;; If we're here, then we're moving down
        ld a, (IX + collisionPNCollisionState) ; a contains collision state
        or collisionStateBlockedDown           ; collide down
        ld (IX + collisionPNCollisionState), a ; update collision state
        ld (IX + collisionPNMovY), 0           ; Set vertical movement = 0
        ld (IX + collisionPNMoveState), movementStateGround ; set ground state
        ret                                    ; return, do not move
collisionHandleVerticalCollisionUp:
        ld a, (IX + collisionPNCollisionState) ; a contains collision state
        or collisionStateBlockedUp             ; collide up
        ld (IX + collisionPNCollisionState), a ; update collision state
        ld (IX + collisionPNMovY), 0           ; Set vertical movement = 0
        ret                                    ; return, do not move



        ;; ---------------------------------------------------------------------
        ;; Subroutines
        ;; ---------------------------------------------------------------------

        ;; ---------------------------------------------------------------------
        ;; calculateSubtileMovement
        ;; ---------------------------------------------------------------------
        ;; PRE: c contains the current X or Y position
        ;;      d contains the distance to move
        ;; POST: c contains the furthest we can move and travel at most to the
        ;;          next zero row/column boundary (d_can)
        ;;       b contains the remaining distance that we still want to move
        ;;       IX is preserved
        ;;       IY is preserved
collisionCalculateSubtileMovement:
        ld a, d                 ; a contains distance to move
        cp 0
        jp p, collisionCalculateSubtileMovementMovingRight
        ;; If we're here, then we want to move left
        ld a, c                   ; a contains pos
        and collisionTileFirstMask ; a contains the first row/col of this tile

        cp c                    ; are we in the first pixel row?
        jp nz, collisionCalculateSubtileMovementMovingLeftInThisTile
        sub 8                      ; a contains the first row/col of next
collisionCalculateSubtileMovementMovingLeftInThisTile:
        sub c                      ; a contains pos_can - pos = d_can
        cp d                    ; is d_can < d_want?
        jp p, collisionCalculateSubtileMovementFinish

        ;;  if we're here, then d_can >= d_want. In this case d_can = d_want
        ld c, d                 ; a contains d_can = d_want
        ld b, 0                 ; if d_can = d_want, then d_remain = 0
        ret
collisionCalculateSubtileMovementMovingRight:
        ;; If we're here, then we want to move right or not at all
        ld a, c                    ; a contains pos
        or collisionTilePixelsMask ; a contains the last row/col of this tile
        inc a                      ; a contains the first row/col of next tile
        sub c                      ; a contains pos_can - pos = d_can

        cp d                    ; is d_can > d_want?
        jp m, collisionCalculateSubtileMovementFinish
        ;;  if we're here, then d_can <= d_want. In this case, d_can = d_want
        ld c, d                 ; a contains d_can = d_want
        ld b, 0                 ; if d_can = d_want, then d_remain = 0
        ret
collisionCalculateSubtileMovementFinish:
        ;; a contains pos_can
        ld e, a                    ; e contains d_can

        ld a, d                    ; a contains d_want
        sub e                      ; a contains d_want - d_can = d_remain

        ld b, a                    ; b contains d_remain
        ld c, e                    ; a contains d_can
        ret

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
        ld l, levelTileWidth  ; HL now contains the column width

        call multiply           ; HL now contains column Width * row Index



        ld DE, gameLevel        ; DE now contains pointer to gameLevel[0][0]
        add HL, BC              ; HL now contains columnIndex + rowIndex * columnWidth
        add HL, DE              ; HL now contains gameLevel + tile offset

        pop bc
        ret
