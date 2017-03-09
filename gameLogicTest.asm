    org $8000

    jp  main
    include "defines.asm"
    include "testUtil.asm"

testGameLogic_dummyStaticTile: equ tgaStandable | tgaClimbable | tgaPassable

main:
    ;; ---------------------------------------------------------------------
    ;; Setup program state, interrupt handling scheme
    ;; ---------------------------------------------------------------------

    ld a,2                 ; upper screen
    call openChannel

    ;; I'm using a different approach to testing this time.
    ;; It's more like an unit testing, where I set up input vals for
    ;; updateGameLogic, and see what the output is. -- Huajie

testGameLogic1:
    ld  b,0
    ld  c,1
    call    test_print_testing_header_with_num
    ;============================================================
    ;; Test 1: punching static block
    ;============================================================
    ld  a,testGameLogic_dummyStaticTile
    ld  (gameLevel + 1*levelTileWidth + 10), a
    ; Put a static tile at <1, 10>
    ld  a,10
    ld  (p1PunchX),a      ; Set punch coordinates
    ld  a,1
    ld  (p1PunchY),a
    ld  a,playerHiPunch
    ld  (p1PPressed),a    ; Mark punch as pressed
    ld  a,10
    ld  (p1Interest),a    ; Set starting interest
    call    updateGameLogic

    ld  a,(gameLevel + 1*levelTileWidth + 10)    ; Grab the tile, the tile shouldn't change
    cp  testGameLogic_dummyStaticTile
    ld  b,0
    ld  c,1
    call    nz,testGameLogic_errorExit

    ld  d,0
    ld  hl, gameLevel       ; Need to check that we didn't change other tiles
    ld  b,levelTileHeight
testGameLogic_t1Loop1:
    push    bc
    ld  b,levelTileWidth
testGameLogic_t1Loop2:
    ld  a,(hl)
    cp  tgaPassable
    jp  z,testGameLogic_t1LoopCR
    inc d
testGameLogic_t1LoopCR:
    inc hl
    djnz testGameLogic_t1Loop2
    pop bc
    djnz testGameLogic_t1Loop1

    ld  a,d
    cp  1
    ld  b,0
    ld  c,2
    call    nz,testGameLogic_errorExit


    ld  a,(p1Interest)      ; Grab new interest val
    cp  10                  ; Check that no interest gained.
    ld  b,0
    ld  c,3
    call    nz,testGameLogic_errorExit

    call    test_print_test_passed

testGameLogic2:
    ld  b,0
    ld  c,2
    call    test_print_testing_header_with_num
    ;============================================================
    ;; Test 2: punching dyna block, not destroyed
    ;============================================================
    ld  a,$13               ; Second dyna tile, 3 HP
    ld  (gameLevel + 1*levelTileWidth + 10), a
    ; Put a static tile at <1, 10>
    ld  a,10
    ld  (p1PunchX),a      ; Set punch coordinates
    ld  a,1
    ld  (p1PunchY),a
    ld  a,playerHiPunch
    ld  (p1PPressed),a    ; Mark punch as pressed
    ld  a,10
    ld  (p1Interest),a    ; Set starting interest
    call    updateGameLogic

    ld  a,(gameLevel + 1*levelTileWidth + 10)    ; Grab the tile, the tile should have 1 less HP
    cp  $12
    ld  b,0
    ld  c,1
    call    nz,testGameLogic_errorExit

    ld  d,0
    ld  hl, gameLevel       ; Need to check that we didn't change other tiles
    ld  b,levelTileHeight
testGameLogic_t2Loop1:
    push    bc
    ld  b,levelTileWidth
testGameLogic_t2Loop2:
    ld  a,(hl)
    cp  tgaPassable
    jp  z,testGameLogic_t2LoopCR
    inc d
testGameLogic_t2LoopCR:
    inc hl
    djnz testGameLogic_t2Loop2
    pop bc
    djnz testGameLogic_t2Loop1

    ld  a,d
    cp  1
    ld  b,0
    ld  c,2
    call    nz,testGameLogic_errorExit


    ld  a,(p1Interest)      ; Grab new interest val
    cp  10+1                ; Check that interest is gained; change gained int val according to code
    ld  b,0
    ld  c,3
    call    nz,testGameLogic_errorExit

    call    test_print_test_passed

testGameLogic3:
    ld  b,0
    ld  c,3
    call    test_print_testing_header_with_num
    ;============================================================
    ;; Test 3: punching dyna block, destroyed
    ;============================================================
    ld  a,$11               ; Second dyna tile, 1 HP
    ld  (gameLevel + 1*levelTileWidth + 10), a
    ; Put a static tile at <1, 10>
    ld  a,10
    ld  (p1PunchX),a      ; Set punch coordinates
    ld  a,1
    ld  (p1PunchY),a
    ld  a,playerHiPunch
    ld  (p1PPressed),a    ; Mark punch as pressed
    ld  a,10
    ld  (p1Interest),a    ; Set starting interest
    call    updateGameLogic

    ld  a,(gameLevel + 1*levelTileWidth + 10)    ; Grab the tile, the tile should have become another tile
    cp  tgaStandable | tgaPassable
    ld  b,0
    ld  c,1
    call    nz,testGameLogic_errorExit

    ld  d,0
    ld  hl, gameLevel       ; Need to check that we didn't change other tiles
    ld  b,levelTileHeight
testGameLogic_t3Loop1:
    push    bc
    ld  b,levelTileWidth
testGameLogic_t3Loop2:
    ld  a,(hl)
    cp  tgaPassable
    jp  z,testGameLogic_t3LoopCR
    inc d
testGameLogic_t3LoopCR:
    inc hl
    djnz testGameLogic_t3Loop2
    pop bc
    djnz testGameLogic_t3Loop1

    ld  a,d
    cp  1
    ld  b,0
    ld  c,2
    call    nz,testGameLogic_errorExit


    ld  a,(p1Interest)      ; Grab new interest val
    cp  10+1                ; Check that interest is gained; change gained int val according to code
    ld  b,0
    ld  c,3
    call    nz,testGameLogic_errorExit

    call    test_print_test_passed

    ld  a,tgaPassable               ; Restore the tile.
    ld  (gameLevel + 1*levelTileWidth + 10), a

testGameLogic4:
    ld  b,0
    ld  c,4
    call    test_print_testing_header_with_num
    ;============================================================
    ;; Test 4: Cat punches patrolling mouse
    ;============================================================
    ld  a,1
    ld  (p1PatrolMouseHit),a
    ld  a,playerHiPunch
    ld  (p1PPressed),a    ; Mark punch as pressed
    ld  a,10
    ld  (p1Interest),a    ; Set starting interest
    call    updateGameLogic

    ld  a,(p1Interest)      ; Grab new interest val
    cp  10+1                ; Check that interest is gained; change gained int val according to code
    ld  b,0
    ld  c,1
    call    nz,testGameLogic_errorExit

    call    test_print_test_passed

    ;============================================================
    ;; Test 5: Reserved
    ;============================================================
testGameLogic6:
    ld  b,0
    ld  c,6
    call    test_print_testing_header_with_num
    ;============================================================
    ;; Test 6: Cat falling on ground
    ;============================================================
    ld  a,collisionStateBlockedDown ; Test falling, blocked down only.
    ld  (p1CollisionState),a
    ld  a,movementStateFalling
    ld  (p1MovementState),a
    call    updateGameLogic

    ld  a,(p1MovementState)
    cp  movementStateGround         ; Should stop at ground
    ld  b,0
    ld  c,1
    call    nz,testGameLogic_errorExit

    ld  a,$0F                       ; Test falling, blocked everywhere. Poor kitty.
    ld  (p1CollisionState),a
    ld  a,movementStateFalling
    ld  (p1MovementState),a
    call    updateGameLogic

    ld  a,(p1MovementState)
    cp  movementStateGround         ; Should stop at ground
    ld  b,0
    ld  c,2
    call    nz,testGameLogic_errorExit

    ld  a,$0D                       ; Test falling, blocked everywhere except down.
    ld  (p1CollisionState),a
    ld  a,movementStateFalling
    ld  (p1MovementState),a
    call    updateGameLogic

    ld  a,(p1MovementState)
    cp  movementStateFalling         ; Should NOT stop at ground
    ld  b,0
    ld  c,3
    call    nz,testGameLogic_errorExit

    ld  a,$0F                       ; Test NOT falling, blocked everywhere. 1
    ld  (p1CollisionState),a
    ld  a,movementStateClimbing
    ld  (p1MovementState),a
    call    updateGameLogic

    ld  a,(p1MovementState)
    cp  movementStateClimbing         ; Should stop at ground
    ld  b,0
    ld  c,4
    call    nz,testGameLogic_errorExit

    ld  a,$0F                       ; Test NOT falling, blocked everywhere. 2
    ld  (p1CollisionState),a
    ld  a,movementStateGround
    ld  (p1MovementState),a
    call    updateGameLogic

    ld  a,(p1MovementState)
    cp  movementStateGround         ; Should stop at ground
    ld  b,0
    ld  c,5
    call    nz,testGameLogic_errorExit

    ld  a,$0F                       ; Test NOT falling, blocked everywhere. 2
    ld  (p1CollisionState),a
    ld  a,movementStateJumping
    ld  (p1MovementState),a
    call    updateGameLogic

    ld  a,(p1MovementState)
    cp  movementStateJumping         ; Should stop at ground
    ld  b,0
    ld  c,6
    call    nz,testGameLogic_errorExit

    call    test_print_test_passed

testGameLogic7:
    ld  b,0
    ld  c,7
    call    test_print_testing_header_with_num
    ;============================================================
    ;; Test 7: Cat colliding left, left edge
    ;============================================================
    ld  a,0
    ld  (fuP1UpdatesNewPosX),a
    ld  a,16
    ld  (fuP1UpdatesNewPosY),a  ; Set the cat location
    ld  a,collisionStateBlockedLeft
    ld  (p1CollisionState),a    ; Indicate that the cat is moving to left but unable to do so
    ld  a,movementStateFalling
    ld  (p1MovementState),a     ; Set a not-on-ground mov state to (potentially) allow clipping to wall.
    ld  a, tgaPassable | tgaClimbable
    ld  (gameLevel + 3*levelTileWidth + 2),a  ; Making the tile to the cat's right climbable, but it
                                              ; shouldn't affects anything
    call    updateGameLogic

    ld  a,(p1MovementState)
    cp  movementStateFalling    ; mov state should not have changed.
    ld  b,0
    ld  c,1
    call    nz,testGameLogic_errorExit

    call    test_print_test_passed
    ld  a, tgaPassable
    ld  (gameLevel + 3*levelTileWidth + 2),a  ; restore tile
testGameLogic8:
    ld  b,0
    ld  c,8
    call    test_print_testing_header_with_num
    ;============================================================
    ;; Test 8: Cat colliding right, right edge; The test may be a
    ;;         self-fulfilling prophecy but w/e
    ;============================================================
    ld  a,8*(levelTileWidth - 2)    ; IS THIS A SERIOUS TEST? I just ctrl-c&v from gameLogic code.
                                    ; Need more robust test probably
    ld  (fuP1UpdatesNewPosX),a
    ld  a,16
    ld  (fuP1UpdatesNewPosY),a  ; Set the cat location
    ld  a,collisionStateBlockedRight
    ld  (p1CollisionState),a    ; Indicate that the cat is moving to right but unable to do so
    ld  a,movementStateFalling
    ld  (p1MovementState),a     ; Set a not-on-ground mov state to (potentially) allow clipping to wall.
    ld  a, tgaPassable | tgaClimbable
    ld  (gameLevel + 4*levelTileWidth - 3),a  ; Making the tile to the cat's left climbable, but it
                                              ; shouldn't affects anything
    call    updateGameLogic

    ld  a,(p1MovementState)
    cp  movementStateFalling    ; mov state should not have changed.
    ld  b,0
    ld  c,1
    call    nz,testGameLogic_errorExit

    call    test_print_test_passed
    ld  a, tgaPassable
    ld  (gameLevel + 4*levelTileWidth - 3),a  ; restore tile

testGameLogic9:
    ld  b,0
    ld  c,9
    call    test_print_testing_header_with_num
    ;============================================================
    ;; Test 9: Cat colliding left in air, latched to it if climbable
    ;============================================================
    ld  a,0+24
    ld  (fuP1UpdatesNewPosX),a
    ld  a,16
    ld  (fuP1UpdatesNewPosY),a  ; Set the cat location
    ld  a,collisionStateBlockedLeft
    ld  (p1CollisionState),a    ; Indicate that the cat is moving to left but unable to do so
    ld  a,movementStateFalling
    ld  (p1MovementState),a     ; Set a not-on-ground mov state to (potentially) allow clipping to wall.
    call    updateGameLogic     ; The tile to the left of the cat is not climbable rn.

    ld  a,(p1MovementState)
    cp  movementStateFalling    ; mov state should not change since the neighbor tile is not climbable
    ld  b,0
    ld  c,1
    call    nz,testGameLogic_errorExit

    ld  a, tgaPassable | tgaClimbable
    ld  (gameLevel + 3*levelTileWidth + 2),a  ; Making the tile to the cat's left climbable
    call    updateGameLogic

    ld  a,(p1MovementState)
    cp  movementStateClimbing    ; mov state should now be climbing
    ld  b,0
    ld  c,2
    call    nz,testGameLogic_errorExit

    call    test_print_test_passed
    ld  a, tgaPassable
    ld  (gameLevel + 3*levelTileWidth + 2),a  ; restore tile
testGameLogic10:
    ld  b,0
    ld  c,10
    call    test_print_testing_header_with_num
    ;============================================================
    ;; Test 10: Cat colliding right in air, latched to it if climbable
    ;============================================================
    ld  a,8*(levelTileWidth - 2)-24
    ld  (fuP1UpdatesNewPosX),a
    ld  a,16
    ld  (fuP1UpdatesNewPosY),a  ; Set the cat location
    ld  a,collisionStateBlockedRight
    ld  (p1CollisionState),a    ; Indicate that the cat is moving to left but unable to do so
    ld  a,movementStateFalling
    ld  (p1MovementState),a     ; Set a not-on-ground mov state to (potentially) allow clipping to wall.
    call    updateGameLogic     ; The tile to the right of the cat is not climbable rn.

    ld  a,(p1MovementState)
    cp  movementStateFalling    ; mov state should not change since the neighbor tile is not climbable
    ld  b,0
    ld  c,1
    call    nz,testGameLogic_errorExit

    ld  a, tgaPassable | tgaClimbable
    ld  (gameLevel + 4*levelTileWidth - 3),a  ; Making the tile to the cat's right climbable
    call    updateGameLogic

    ld  a,(p1MovementState)
    cp  movementStateClimbing    ; mov state should now be climbing
    ld  b,0
    ld  c,2
    call    nz,testGameLogic_errorExit

    call    test_print_test_passed
    ld  a, tgaPassable
    ld  (gameLevel + 4*levelTileWidth - 3),a  ; restore tile
testGameLogic11:
    ld  b,0
    ld  c,11
    call    test_print_testing_header_with_num
    ;============================================================
    ;; Test 11: Cat colliding left climbable on ground
    ;============================================================
    ld  a,0+24
    ld  (fuP1UpdatesNewPosX),a
    ld  a,16
    ld  (fuP1UpdatesNewPosY),a  ; Set the cat location
    ld  a,collisionStateBlockedLeft
    ld  (p1CollisionState),a    ; Indicate that the cat is moving to left but unable to do so
    ld  a,movementStateGround
    ld  (p1MovementState),a     ; Set a not-on-ground mov state to (potentially) allow clipping to wall.
    ld  a, tgaPassable | tgaClimbable
    ld  (gameLevel + 3*levelTileWidth + 2),a  ; Making the tile to the cat's left climbable
    ; Note that up is not pressed rn
    call    updateGameLogic

    ld  a,(p1MovementState)
    cp  movementStateGround    ; mov state should still be ground since not pressing up
    ld  b,0
    ld  c,1
    call    nz,testGameLogic_errorExit

    ld  a,1
    ld  (p1DirPressed+0),a  ; Set up to be pressed
    call    updateGameLogic

    ld  a,(p1MovementState)
    cp  movementStateClimbing   ; mov state should now be climbing since we pressed up.
    ld  b,0
    ld  c,2
    call    nz,testGameLogic_errorExit

    ld  a,movementStateGround
    ld  (p1MovementState),a     ; "Here comes the invisible hand, drag the cat back unto the land"
    ld  a, tgaPassable
    ld  (gameLevel + 3*levelTileWidth + 2),a  ; restore tile to non-climbable
    call    updateGameLogic

    ld  a,(p1MovementState)
    cp  movementStateGround    ; mov state should still be ground since the neighbor tile isn't climbable
    ld  b,0
    ld  c,3
    call    nz,testGameLogic_errorExit

    call    test_print_test_passed

    call    test_print_all_test_passed
endProg:
    nop
    jp endProg

testGameLogic_errorExit:
    call    test_print_error_with_num
    jp  endProg

    include "gameLogic.asm"

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

collisionGameplayAttrOffset:    equ 9
