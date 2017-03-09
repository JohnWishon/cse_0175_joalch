logicNextTileGXOffset: equ 10
logicNextTileGLOffset: equ 12

setupGameLogic:
        ;; TODO: setup the level
        ld b, levelTileHeight
        ld hl, gameLevel
setupGameLogicYLoop:
        ld c, levelTileWidth
setupGameLogicXLoop:
        dec c
        ;; ld (hl), (dynamicTileTestImpassableOneHealth - dynamicTileInstanceBase) | 1
        inc hl
        ld a, c
        cp 0
        jp nz, setupGameLogicXLoop
        djnz setupGameLogicYLoop
        ret

updateGameLogic:
        ;; TODO: score, interest, RNG, etc...

        ;; TODO: Roadmap:
        ;;*  Get punch coordinate
        ;;*  Check what tile is there
        ;;*    If destroyable
        ;;*      inc interest gauge / score
        ;;*      decrease HP by one
        ;;*      If HP = 0
        ;;*        load gameplay attr of next tile
        ;;*        graph of next tile to update array
        ;;-    If mouse
        ;;-      inc interest gauge / score
        ;;-      signal mouse kill
        ;;*  Updates climbing state.
        ld  d,2     ; Counter for # of players processed
        push    iy  ; Save iy, to be restored before ret.
                    ; otherwise the BASIC loader freaks out.
        push    de
logicP1Init:
        ld  ix,p1DirPressed
        ld  iy,fuP1UpdatesNewPosX
        jp  logicBody
logicP2Init:
        ld  ix,p2DirPressed
        ld  iy,fuP2UpdatesNewPosX
logicBody:
        ld  a,(ix+5)
        cp  playerNotPunch
        jp  z,logicUpdateMovementState  ; If punch is not pressed, no need to check punch

        ;; First check if the cat punches a patrolling mouse
        ld  a,(ix+15)
        cp  1
        call    z,logicGainInterest ; Interest or score?

        ;; Get punch coordinates. The X, Y here are in tiles, so use a
        ;; condensed version of collisionCalculateGameLevelPtr
        ld  h,0
        ld  l,levelTileWidth
        ld  d,0
        ld  e,(ix+11)    ; Y
        ld  (iy+6), e   ; Also put Y in graphix update buffer
        call multiply

        ld  b,0
        ld  c,(ix+10)    ; X
        ld  (iy+5), c   ; Couple lines above, read the comment
        ld  de,gameLevel
        add hl,bc
        add hl,de   ; hl = gl + Y*w + X

        ld  a,(hl)  ; Get gameLevel raw data
        and levelDummyTileMask
        jp  z,logicUpdateMovementState   ; 0 = static tile, no destruction happens to it.
        ;; CAVEAT: not sure how the running mouse is implemented (does it have a dyna tile,
        ;; for example), talk with Amanda.
        ;; The whack-a-mole is conceptually lesser of an issue for this line
        call logicGainInterest  ; So destruction definitely happens, calc interest gain first
        ld  a,(hl)  ; reload raw data
        dec a       ; -1 to raw data, dec the HP by 1
        ld  (hl),a
        and levelDummyTileMask
        jp  nz,logicUpdateMovementState  ; If the HP > 0, the state update is finished for the tile

        push    iy                ; Save fuPXUpdatesNewPosX for later
        ld  a,(hl)                ; restore tile data to a
        ld  iy,dynamicTileInstanceBase
        and levelTileIndexMask    ; a contains an index into the dynamic
                                  ; instances area
        ld  d,0
        ld  e,a
        add iy,de                 ; iy contains a pointer to the base of a dyna tile template
        ld  a,(iy + logicNextTileGLOffset)
                                  ; a contains the next tile gameLevel value
        ld  (hl),a                ; Write down the next tile gLv into gameLevel array
        ld  b,(iy + logicNextTileGXOffset)
        ld  c,(iy + (logicNextTileGXOffset + 1)) ; Get the next graphic pointer
        pop iy          ; iy now contains fuP1UpdatesNewPosX
        ld  (iy+7), b
        ld  (iy+8), c   ; ChangePtr now contains the correct ptr, hopefully.

logicUpdateMovementState:
        ld  a,(ix+9)    ; a has collision state
        and  collisionStateBlockedDown
        call    nz,logicCheckStopFall ; Call the fall to ground routine
        ld  a,(ix+9)    ; a has collision state again
        and $0C         ; Check either collideR or L
        jp  z,logicEndUpdateMovementState   ; If neither, no climbing state update needed
        ld  d,(iy+2)    ; cat new Y in pixels
        ld  c,(iy+0)    ; cat new X

        ;ld  a,(ix+9)                    ; collision state
        and collisionStateBlockedLeft   ; If not blocked on left
        jp  z,logicCheckBlockedRight    ; it must be on right
        ld  a,c                         ; Load a with catNewX
        cp  0                           ; WHAT VAL?
        jp  z,logicEndUpdateMovementState   ; If we are at leftmost interactive tile, skip.
        sub 8                         ; get a pixel point in the tile to the left
        ld  c,a                         ; write back the X
        jp  logicCheckNeighborTileClimbable
logicCheckBlockedRight:
        ld  a,c                         ; Load a with catNewX
        cp  8*(levelTileWidth - 2)      ; SERIOUS ATTENTION when debugging, look for index out of bound (Or reading incorrect tile
        jp  z,logicEndUpdateMovementState ; If we are at the rightmost interactive tile, skip.
        add a,2*8                       ; get a pixel point in the tile to the right of the cat, which is
                                        ; 2 tiles away from top left point of cat.
        ; I'm assuming that the collision always happens on the edge of tiles,
        ; so I don't have to compensate for half tile
        ld  c,a                         ; write back the X
logicCheckNeighborTileClimbable:
        ld  a,d
        add a,2*8-1                     ; get a pixel point in the tile below the cat, which is
                                        ; 2 tiles away from top left point of cat.
        ; Again, assume collision only on tile edge
        ; Also assume the bottom of the cat never leaves the interactive area,
        ; thus no boundary check here.
        ld  d,a
        ld  hl,0                        ; I could have used hl for tile offsets but I think
                                        ; the way I had it is more clear to me so w/e - Huajie
        call collisionCalculateGameLevelPtr
        call collisionGetGameplayAttribute  ; After call, a has gameplayAttribute of the colliding tile.
        and tgaClimbable
        jp  z,logicEndUpdateMovementState   ; If not climbale, all done

        ld  a,(ix+8)                        ; a has movement state
        cp  movementStateGround
        jp  nz,logicMovementStateToClimbing ; If not ground, directly go change movmnt state
        ld  a,(ix+0)                        ; a has UpPressed
        cp  0
        jp  z, logicEndUpdateMovementState  ; if up is not pressed, don't climb
logicMovementStateToClimbing:
        ld  (ix+8), movementStateClimbing
logicEndUpdateMovementState:
        pop de  ; Retrieve player counter
        pop iy
        dec d
        ret z
        push    iy
        push    de
        jp  logicP2Init

logicCheckStopFall:
        ld  a,(ix+8)    ; a has movement state
        cp  movementStateFalling
        ret nz
        ld  (ix+8), movementStateGround ; Just change the state; speed handled in physics
        ret

logicGainInterest:
        ld  a,(ix+12)
        cp playerMaxInterest
        ret z   ; z indicates that the interest is equal to max.
        ret nc  ; nc indicates that the interest is higher than max.
        inc a   ; Place holder interest inc val
                ; We need to at least check for exceeding max interest val
        ld  (ix+12),a
        ret
