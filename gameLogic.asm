logicAttribOffset:     equ 9
logicNextTileGXOffset: equ 10
logicNextTileGLOffset: equ 12

setupGameLogic:
        call initGroundMouse
        call initWallMouse

	call setupGameLogicInitialState

        ;; Flood the map with passable attr.
        ld  hl, gameLevel
        ld  (hl), tgaPassable
        ld  de, gameLevel + 1
        ld  bc, levelTileHeight * levelTileWidth - 1
        ldir

        ;; Fish tank is impassable
        ld  hl, gameLevel + 8 + (9 * levelTileWidth)
        ld  (hl), tgaNone

        inc hl
        ld  (hl), tgaNone

        ld  hl, gameLevel + 8 + (10 * levelTileWidth)
        ld  (hl), tgaNone
        inc hl
        ld  (hl), tgaNone

        ;; Refer to screen.PNG for what do we have in the map.

        ;; Shelves - passable/standable
        ;; Top shelf
        ld  hl, gameLevel + 8 + (3 * levelTileWidth)
        ld  (hl), tgaPassable | tgaStandable
        ld  de, gameLevel + 8 + (3 * levelTileWidth) + 1
        ld  bc, 13
        ldir

        ;; Left first shelf from top
        ld  hl, gameLevel + 3 + (7 * levelTileWidth)
        ld  (hl), tgaPassable | tgaStandable
        ld  de, gameLevel + 3 + (7 * levelTileWidth) + 1
        ld  bc, 5
        ldir

        ;; Fish tank shelf
        ld  hl, gameLevel + 7 + (11 * levelTileWidth)
        ld  (hl), tgaPassable | tgaStandable
        ld  de, gameLevel + 7 + (11 * levelTileWidth) + 1
        ld  bc, 5
        ldir

        ;; Right first shelf from top
        ld  hl, gameLevel + 21 + (7 * levelTileWidth)
        ld  (hl), tgaPassable | tgaStandable
        ld  de, gameLevel + 21 + (7 * levelTileWidth) + 1
        ld  bc, 5
        ldir

        ;; Right second shelf from top
        ld  hl, gameLevel + 18 + (11 * levelTileWidth)
        ld  (hl), tgaPassable | tgaStandable
        ld  de, gameLevel + 18 + (11 * levelTileWidth) + 1
        ld  bc, 5
        ldir

        ;; Couch
        ;; Couch top
        ld  hl, gameLevel + 10 + (14 * levelTileWidth)
        ld  (hl), LOW(couchTop - dynamicTileInstanceBase) | 1
        ld  de, gameLevel + 10 + (14 * levelTileWidth) + 1
        ld  bc, 10
        ldir
        ld  hl, gameLevel + 10 + (15 * levelTileWidth) - 1
        ld  (hl), LOW(couchSide - dynamicTileInstanceBase) | 1
        ld  hl, gameLevel + 10 + (14 * levelTileWidth)
        ld  de, gameLevel + 10 + (15 * levelTileWidth)
        ld  bc, 11
        ldir
        ;; At this point de should be pointing to the right side of the couch
        push    de
        pop hl
        ld  (hl), LOW(couchSide - dynamicTileInstanceBase) | 1

        ;; Couch cushion
        ld  hl, gameLevel + 10 + (16 * levelTileWidth) - 1
        ld  (hl), LOW(couchSide - dynamicTileInstanceBase) | 1
        inc hl
        ld  (hl), LOW(couchCushion - dynamicTileInstanceBase) | 1
        ld  de, gameLevel + 10 + (16 * levelTileWidth) + 1
        ld  bc, 10
        ldir
        ld  hl, gameLevel + 10 + (17 * levelTileWidth) - 1
        ld  (hl), LOW(couchSide - dynamicTileInstanceBase) | 1
        ld  hl, gameLevel + 10 + (16 * levelTileWidth)
        ld  de, gameLevel + 10 + (17 * levelTileWidth)
        ld  bc, 11
        ldir
        ;; At this point de should be pointing to the right side of the couch
        push    de
        pop hl
        ld  (hl), LOW(couchSide - dynamicTileInstanceBase) | 1

        ;; Media set impassable
        ld  hl, gameLevel + 0 + (14 * levelTileWidth)
        ld  (hl), tgaNone
        ld  de, gameLevel + 0 + (14 * levelTileWidth) + 1
        ld  bc, 3
        ldir
        ld  hl, gameLevel + 0 + (15 * levelTileWidth)
        ld  (hl), tgaNone
        ld  de, gameLevel + 0 + (15 * levelTileWidth) + 1
        ld  bc, 4
        ldir
        ld  hl, gameLevel + 0 + (15 * levelTileWidth)
        ld  de, gameLevel + 0 + (16 * levelTileWidth)
        ld  bc, 4
        ldir
        ld  hl, gameLevel + 0 + (15 * levelTileWidth)
        ld  de, gameLevel + 0 + (17 * levelTileWidth)
        ld  bc, 4
        ldir
        ld  hl, gameLevel + 0 + (15 * levelTileWidth)
        ld  de, gameLevel + 0 + (18 * levelTileWidth)
        ld  bc, 4
        ldir
        ld  hl, gameLevel + 0 + (15 * levelTileWidth)
        ld  de, gameLevel + 0 + (19 * levelTileWidth)
        ld  bc, 3
        ldir
        ld  hl, gameLevel + 0 + (15 * levelTileWidth)
        ld  de, gameLevel + 0 + (20 * levelTileWidth)
        ld  bc, 2
        ldir
        ld  hl, gameLevel + 0 + (15 * levelTileWidth)
        ld  de, gameLevel + 0 + (21 * levelTileWidth)
        ld  bc, 1
        ldir
        ret

setupGameLogicInitialState:
	ld a, 0
	ld (p1DirPressed), a
	ld (p1DirPressed+1), a
	ld (p1DirPressed+2), a
	ld (p1DirPressed+3), a
	ld (p1JPressed), a
	ld (p1PPressed), a
	ld (p1MovX), a
	ld (p1MovY), a
	ld (p1CollisionState), a
	ld (p1PunchX), a
	ld (p1PunchY), a
	ld a, playerMaxInterest - 8
	ld (p1Interest), a
	ld a, '0'
	ld (p1Score), a
	ld (p1Score+1), a
	ld (p1Score+2), a
	ld (p1Score+3), a
	ld (p1Score+4), a
	ld a, 0
	ld (p1PatrolMouseHit), a

	ld a, 4
	ld (fuP1UpdatesNewPosX), a
	ld a, 20
	ld (fuP1UpdatesNewPosY), a
	ld a, catPoseJump
	ld (fuP1UpdatesNewPose), a

	ld a, 0
	ld (p2DirPressed), a
	ld (p2DirPressed+1), a
	ld (p2DirPressed+2), a
	ld (p2DirPressed+3), a
	ld (p2JPressed), a
	ld (p2PPressed), a
	ld (p2MovX), a
	ld (p2MovY), a
	ld (p2CollisionState), a
	ld (p2PunchX), a
	ld (p2PunchY), a
	ld a, playerMaxInterest - 8
	ld (p2Interest), a
	ld a, '0'
	ld (p2Score), a
	ld (p2Score+1), a
	ld (p2Score+2), a
	ld (p2Score+3), a
	ld (p2Score+4), a
	ld a, 0
	ld (p2PatrolMouseHit), a

	ld a, levelPixelWidth - catPixelWidth - 4
	ld (fuP2UpdatesNewPosX), a
	ld a, 20
	ld (fuP2UpdatesNewPosY), a
	ld a, catPoseJump | catPoseFaceLeft
	ld (fuP2UpdatesNewPose), a

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

        ld  a,(interestDrainCounter)    ; Get the interest drain counter
        cp  25 * 4                      ; 25 * sec, 8 secs for now
        jp  c,logicNoDrainYet           ; If the counter is lower than the bar, no drain
        ld  a, 0
        ld  (interestDrainCounter),a    ; Reset the counter
        ld  a,(p1Interest)              ; Check if the interest value is high enough for draining
        cp  0
        jp  z,logicP1NoDrainInterest
        dec a
        ld  (p1Interest),a                ; If so, drain
logicP1NoDrainInterest:
        ld  a,(p2Interest)              ; Same here
        cp  0
        jp  z,logicNoDrainYet
        dec a
        ld  (p2Interest),a
logicNoDrainYet:
        ld  a,(interestDrainCounter)
        inc a
        ld  (interestDrainCounter),a

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
        ld  (iy+7), 0
        ld  (iy+8), 0
        ld  a,(ix+5)
        cp  playerNotPunch
        jp  z,logicUpdateMovementState  ; If punch is not pressed, no need to check punch

        ;; First check if the cat punches a patrolling mouse
        ld  a,(ix+18)
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

        ld  a,(hl)
        call logicGainScore  ; So destruction definitely happens, calc score gain first
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
        ld  a,(iy + logicAttribOffset)
        and tgaGiveInterest
        call    nz, logicGainInterest   ; punched a tile that gives interest, so gain interest
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

logicGainScoreAndInterest:
        call    logicGainInterest
        call    logicGainScore
        ret

logicGainInterest:
        ld  a,(ix+12)
        cp playerMaxInterest
        ret z   ; z indicates that the interest is equal to max.
        ret p   ; p indicates that the interest is higher than max.
        inc a   ; Place holder interest inc val
        ld  (ix+12),a
        ret

logicGainScore:
        push    hl
        push    ix
        pop hl
        ld  a,l
        add a,16                ;; Since pXStates are away from a 2^8 byte boundary, add 16 to l is fine)
                                ; We are now looking at tens digit
        ld  l,a
        call    logicUpdateScoreDigit ; Attribute: chuntey
        pop hl
        ret
logicUpdateScoreDigit:
        ld  a,(hl)              ; current value of digit.
        add a,1                 ; add 1 to this digit.
        ld  (hl),a              ; place new digit back in string.
        cp  58                  ; more than ASCII value '9'?
        ret c                   ; no - relax.
        sub 10                  ; subtract 10.
        ld  (hl),a              ; put new character back in string.
logicUpdateScoreDigitCarry:
        dec hl                          ; previous character in string.
        inc (hl)                        ; up this by one.
        ld  a,(hl)                      ; what's the new value?
        cp  58                          ; gone past ASCII nine?
        ret c                           ; no, scoring done.
        sub 10                          ; down by ten.
        ld  (hl),a                      ; put it back
        jp  logicUpdateScoreDigitCarry  ; go round again.

;;  PRE: ix = pXStateX
;;       b  = the digit to look at
;;  return: hl = pointer to the graphic byte of the digit
;;
logicDigitNumVal:
        push    de
        push    af
        push    ix
        pop hl      ; hl = pXStateX
        ld  a,l
        add a,12
        add a,b
        ld  l,a     ; hl = pXStateX + 12 + b
        ld  a,(hl)  ; Load digit
        sub $30     ; Sub with ascii 0
        sll a
        sll a
        sll a       ; a *= 8
        ld  hl, statusBarZero
        ld  d,0
        ld  e,a     ; de = a
        add hl,de   ; hl = statusBarZero + val(digit) * 8
        ld de, -7
        add hl, de
        pop af
        pop de
        ret

initGroundMouse:
        ld ix, mouseUpdatesBase

        call random                 ; get rng for direction
        and 9                       ; 0 or 1 = right, 2 or 3 = left

        cp 5
        jr c, setGroundRight

        ld (ix), 3                  ; 2 or 3 happened, mouse will start going left
        jr endInitGroundMouse
setGroundRight:
        ld (ix), 1                  ; 0 or 1 happened, mouse will start going right
endInitGroundMouse:
        ret

initWallMouse:
        ld ix, mouseWall1
        ld (ix), 3                  ; wall 1 x
        ld (ix + 1), 4              ; wall 1 y
        ld (ix + 2), 0              ; set wall 1 inactive
        ld a, (ix)                  ; load x tile into change x
        ld (ix + 4), a
        ld a, (ix + 1)              ; load y tile into change y
        ld (ix + 5), a
        ld hl, staticTileMouseHole  ; load change ptr with static mouse Hold
        ld (ix + 7), h
        ld (ix + 8), l

        ld ix, mouseWall2
        ld (ix), 12                 ; wall 2 x
        ld (ix + 1), 7              ; wall 2 y
        ld (ix + 2), 0              ; set wall 2 inactive
        ld a, (ix)                  ; load x tile into change x
        ld (ix + 4), a
        ld a, (ix + 1)              ; load y tile into change y
        ld (ix + 5), a
        ld hl, staticTileMouseHole  ; load change ptr with static mouse Hold
        ld (ix + 7), h
        ld (ix + 8), l

        ld ix, mouseWall3
        ld (ix), 24                 ; wall 3 x
        ld (ix + 1), 2              ; wall 3 y
        ld (ix + 2), 0              ; set wall 3 inactive
        ld a, (ix)                  ; load x tile into change x
        ld (ix + 4), a
        ld a, (ix + 1)              ; load y tile into change y
        ld (ix + 5), a
        ld hl, staticTileMouseHole  ; load change ptr with static mouse Hold
        ld (ix + 7), h
        ld (ix + 8), l
        ret
