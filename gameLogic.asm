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
        ld (hl), tgaPassable

        inc hl
        ld a, c
        cp 0
        jp nz, setupGameLogicXLoop
        djnz setupGameLogicYLoop

        ;; Fish tank is impassable
        ld hl, gameLevel
        ld bc, 8 + (9 * levelTileWidth)
        add hl, bc
        ld (hl), tgaNone

        inc hl
        ld (hl), tgaNone

        ld hl, gameLevel
        ld bc, 8 + (10 * levelTileWidth)
        add hl, bc
        ld (hl), tgaNone

        inc hl
        ld (hl), tgaNone

        ;;  Fish tank shelf is passable/standable
        ld hl, gameLevel
        ld bc, 7 + (11 * levelTileWidth)
        add hl, bc
        ld (hl), tgaPassable | tgaStandable

        inc hl
        ld (hl), tgaPassable | tgaStandable

        inc hl
        ld (hl), tgaPassable | tgaStandable

        inc hl
        ld (hl), tgaPassable | tgaStandable

        inc hl
        ld (hl), tgaPassable | tgaStandable

        inc hl
        ld (hl), tgaPassable | tgaStandable

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
        ;;*    If mouse
        ;;*      inc interest gauge / score
        ;;*      signal mouse kill
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
        call    z,logicGainScoreAndInterest

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

        ;; TODO: Mouse hole attrib?

        ;; The whack-a-mole scoring will be implemented here.
        call logicGainScore  ; So destruction definitely happens, calc interest gain first
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
        jp  z, logicEndUpdateMovementState  ; If not block on bottom, no need to stop fall.
        ld  a,(ix+8)    ; a has movement state
        cp  movementStateFalling
        jp  nz, logicEndUpdateMovementState  ; If the cat is not really falling, then no need to change
                                             ; movement state.
        ld  (ix+8), movementStateGround ; Just change the state; speed handled in physics
logicEndUpdateMovementState:
        ;; Before moving on, we need to update the cat's pose for rendering
        ;; new pose = iy + 4
        ld a, (ix + 8)          ; a contains movement state
        and movementStateGround
        jp nz, logicUpdateNotFallingPose
        ;; If we're here, then movement state is jumping or falling

        ld a, catPoseJump
        or (iy + 4)
        ld (iy + 4), a
        jp logicUpdatePoseEnd
logicUpdateNotFallingPose:
        ;; If we're here, then movement state is ground. Pose might be
        ;; walking or standing

        ld a, (iy + 0)          ; a contains new pos X
        cp (iy - 1)             ; is new pos X same as old pos X?
        jp z, logicUpdatePoseEnd ; if they are, we're standing
        ;; If we're here, then we are walking
        ld a, catPoseWalk
        or (iy + 4)
        ld (iy + 4), a

logicUpdatePoseEnd:
        ;; Pose set
        pop de  ; Retrieve player counter
        pop iy
        dec d
        ret z
        push    iy
        push    de
        jp  logicP2Init

logicGainInterest:
        ld  a,(ix+12)
        cp playerMaxInterest
        ret z   ; z indicates that the interest is equal to max.
        ret nc  ; nc indicates that the interest is higher than max.
        inc a   ; Place holder interest inc val
        ld  (ix+12),a
        ret

logicGainScore:
        ld  a,(ix+13)
        add a,10
        ld  (ix+13),a
        ret nc
        ld  a,(ix+14)
        inc a
        ld  (ix+14),a
        ret

logicGainScoreAndInterest:
        call    logicGainInterest
        call    logicGainScore
        ret
