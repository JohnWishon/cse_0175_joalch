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

        ;; In order to ensure that we fall through platforms correctly,
        ;; we need to apply a constant downward force if ground & speed = 0
        ld a, (ix + collisionPNMoveState)
        and movementStateGround
        ret z                   ; not on the ground, can return early
        ld a, (ix + collisionPNMovY)
        cp 0
        ret nz             ; We have vertical movement already, can return early
        ld (ix + collisionPNMovY), -1 ; constant force of gravity

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

        ld a, (IX + collisionPNMovX) ; a contains pos x
        cp 0                         ; are we moving right?
        jp p, collisionHandleHorizontalLoopRightEntrypoint ; if so, enter loop

        ;; if moving left, move to edge of tile, then loop
        ld c, (IY + collisionPNUpdatesOldX) ; c contains pos x
        ld d, a                             ; d contains mov x
        call collisionCalculateSubtileMovement ; move to edge of tile

        jp collisionHandleHorizontalLoopLeftEntrypoint

        ;; enter collision loop
collisionHandleHorizontalLoopRightEntrypoint:
        ld b, (IX + collisionPNMovX)
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
        cp levelPixelWidth - catPixelWidth + 1 ; is this the rightmost pixel?
        jp z, collisionHandleHorizontalCollisionRight ; if so, collide Right
collisionHandleHorizontalLoopScreenLeftRightEnd:

        ;; Enter cat height inner loop

        ld e, catHeight     ; e contains cat height
        ;; b contains d_remain
collisionHandleHorizontalCatHeightLoop:
        dec e                   ; e contains next row to check (1 -> 0 -> -1 -> break)
        push bc
        push de
        push hl
        ld c, (IY + collisionPNUpdatesNewX) ; c contains current X position

        ld d, (IY + collisionPNUpdatesOldY) ; c contains Y position
        ;; h contains catWidth or -1 already
        ld l, e                 ; l contains current row to test

        ;; TODO: off by one when moving left
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
        cp -1
        jp nz, collisionHandleHorizontalCatHeightLoop ; iterate if not on row 0

        ;; If we're here, then we are clear to move up to 1 tile
        ld c, (IY + collisionPNUpdatesNewX) ; c contains current X position
        ld d, b                             ; d contains d_remain
        call collisionCalculateNextTileMovement

        ;; c contains new d_can
        ;; b contains new d_remain

collisionHandleHorizontalLoopLeftEntrypoint:

        ld a, (IY + collisionPNUpdatesNewX) ; a contains current X position
        add a, c                            ; advance X position
        ld (IY + collisionPNUpdatesNewX), a ; posX += d_can

        ld a, b                 ; a contains d_remain
        cp 0
        ret z                   ; if d_remain = 0, we're done



        jp collisionHandleHorizontalLoop ; Otherwise iterate until we either
        ;; collide or move the whole distance

collisionHandleHorizontalCollision:
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
        ;; Did we even try to move?
        ld a, (IX + collisionPNMovY)
        cp 0
        ret z                   ; if movY == 0, return, do not move

        ld a, (IX + collisionPNMovY) ; a contains pos y
        cp 0                         ; are we moving down?
        jp p, collisionHandleVerticalLoopDownEntrypoint ; if so, enter loop

        ;; if moving up, move to edge of tile, then loop
        ld c, (IY + collisionPNUpdatesOldY) ; c contains pos y
        ld d, a                             ; d contains mov y
        call collisionCalculateSubtileMovement ; move to edge of tile

        jp collisionHandleVerticalLoopUpEntrypoint

        ;; enter collision loop
collisionHandleVerticalLoopDownEntrypoint:
        ld b, (IX + collisionPNMovY)
collisionHandleVerticalLoop:
        ;; test collisions against level edges

        ld a, b                 ; a contains d_remain
        jp p, collisionHandleVerticalLoopScreenDown
        ;; If we're here, then we want to move up
        ;; load L with correct offset since we're here
        ld l, -2

        ld a, (IY + collisionPNUpdatesNewY) ; a contains current Y pos
        ;; TODO: this leaves an unused pixel at the top. Why?
        cp levelTopmostPixel - 8            ; is this the topmost pixel?
        jp z, collisionHandleVerticalCollisionUp ; if so, collide up
        jp collisionHandleVerticalLoopScreenUpDownEnd
collisionHandleVerticalLoopScreenDown:
        ;; If we're here, then we want to move down

        ;; load L with correct offset since we're here
        ld l, catHeight - 1

        ld a, (IY + collisionPNUpdatesNewY) ; a contains current y pos
        cp levelPixelHeight - catHeight - 8 ; is this the bottommost pixel?
        jp z, collisionHandleVerticalCollisionDown ; if so, collide Down
collisionHandleVerticalLoopScreenUpDownEnd:

        ;; Enter cat height inner loop

        ld e, catHeight    ; e contains cat height

        ld a, (IY + collisionPNUpdatesNewY)
        and collisionTilePixelsMask
        cp 0                    ; Are we on a Y tile boundary?
        jp nz, collisionHandleVerticalCatWidthLoop ; if not, no problem
        ld a, (IY + collisionPNUpdatesNewX)
        and collisionTilePixelsMask
        cp 0                    ; Are we also on an X tile boundary?
        jp z, collisionHandleVerticalCatWidthLoop ; If so, no problem
        inc e                   ; Otherwise, check 3 columns instead of 2
        ;; b contains d_remain
collisionHandleVerticalCatWidthLoop:
        dec e                   ; e contains next col to check (1 -> 0 -> break)
        push bc
        push de
        push hl
        ld c, (IY + collisionPNUpdatesNewX) ; c contains X position

        ld d, (IY + collisionPNUpdatesNewY) ; c contains current Y position
        inc d
        ;; l contains catWidth or -1 already
        ld h, e                 ; h contains current col to test


        call collisionCalculateGameLevelPtr

        ;; hl contains pointer to gameLevel index

        call collisionGetGameplayAttribute

        ;; a contains gameplay attribute

        pop hl
        pop de
        pop bc

        and tgaPassable         ; a contains 0 IFF passable bit is not set
        jp z, collisionHandleVerticalCollision ; if not passable, then collide

        ld a, e                 ; a contains current col
        cp 0
        jp nz, collisionHandleVerticalCatWidthLoop ; iterate if not on col 0

        ;; If we're here, then we are clear to move up to 1 tile
        ld c, (IY + collisionPNUpdatesNewY) ; c contains current Y position
        ld d, b                             ; d contains d_remain

        call collisionCalculateNextTileMovement

        ;; c contains new d_can
        ;; b contains new d_remain

collisionHandleVerticalLoopUpEntrypoint:

        ld a, (IY + collisionPNUpdatesNewY) ; a contains current Y position
        add a, c                            ; advance Y position
        ld (IY + collisionPNUpdatesNewY), a ; posY += d_can

        ld a, b                 ; a contains d_remain
        cp 0
        ret z                   ; if d_remain = 0, we're done



        jp collisionHandleVerticalLoop ; Otherwise iterate until we either
        ;; collide or move the whole distance

collisionHandleVerticalCollision:
        ;; If we're here, then we bumped into something. Set the collision
        ;; state and return without moving any further
        ld a, (IX + collisionPNMovY) ; a contains movement vector
        cp 0                         ; up or down
        jp p, collisionHandleVerticalCollisionDown
collisionHandleVerticalCollisionUp:
        ;; If we're here, then we're moving up
        ld a, (IX + collisionPNCollisionState) ; a contains collision state
        or collisionStateBlockedUp             ; collide up
        ld (IX + collisionPNCollisionState), a ; update collision state
        ret                                    ; return, do not move
collisionHandleVerticalCollisionDown:
        ld a, (IX + collisionPNCollisionState) ; a contains collision state
        or collisionStateBlockedDown           ; collide down
        ld (IX + collisionPNCollisionState), a ; update collision state
        ret                                    ; return, do not move


        ;; ---------------------------------------------------------------------
        ;; Subroutines
        ;; ---------------------------------------------------------------------


        ;; ---------------------------------------------------------------------
        ;; calculateNextTileMovement
        ;; ---------------------------------------------------------------------
        ;; PRE: c contains the current X or Y position
        ;;      d contains the distance to move
        ;; POST: c contains the furthest we can move and travel at most to the
        ;;          next zero row/column boundary (d_can)
        ;;       b contains the remaining distance that we still want to move
        ;;       IX is preserved
        ;;       IY is preserved
collisionCalculateNextTileMovement:
        ld b, 8                 ; non-in tile movement will subtract 8
        jp collisionCalculateSubtileNextTileEntrypoint
        ;; ---------------------------------------------------------------------
        ;; calculateSubtileMovement
        ;; ---------------------------------------------------------------------
        ;; PRE: c contains the current X or Y position
        ;;      d contains the distance to move
        ;; POST: c contains the furthest we can move and not cross a
        ;;          row/column boundary (d_can)
        ;;       b contains the remaining distance that we still want to move
        ;;       IX is preserved
        ;;       IY is preserved
collisionCalculateSubtileMovement:
        ld b, 0                 ; in tile movement will subtract 0
collisionCalculateSubtileNextTileEntrypoint:
        ld a, d                 ; a contains distance to move
        cp 0
        jp p, collisionCalculateSubtileMovementMovingRight
        ;; If we're here, then we want to move left
        ld a, c                   ; a contains pos
        and collisionTileFirstMask ; a contains the first row/col of this tile

        cp c                    ; are we in the first pixel row?
        jp nz, collisionCalculateSubtileMovementMovingLeftInThisTile
        sub b                      ; a contains the first row/col of next
collisionCalculateSubtileMovementMovingLeftInThisTile:
        sub c                      ; a contains pos_can - pos = d_can
        cp d                       ; is d_can < d_want?
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
