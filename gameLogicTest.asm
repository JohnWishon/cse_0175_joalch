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
    call updateGameLogic

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
    call updateGameLogic

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
    call updateGameLogic

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

    ;============================================================
    ;; Test 4: Reserved
    ;============================================================

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
    call updateGameLogic

    ld  a,(p1MovementState)
    cp  movementStateGround         ; Should stop at ground
    ld  b,0
    ld  c,1
    call    nz,testGameLogic_errorExit

    ld  a,$0F                       ; Test falling, blocked everywhere. Poor kitty.
    ld  (p1CollisionState),a
    ld  a,movementStateFalling
    ld  (p1MovementState),a
    call updateGameLogic

    ld  a,(p1MovementState)
    cp  movementStateGround         ; Should stop at ground
    ld  b,0
    ld  c,2
    call    nz,testGameLogic_errorExit

    ld  a,$0D                       ; Test falling, blocked everywhere except down.
    ld  (p1CollisionState),a
    ld  a,movementStateFalling
    ld  (p1MovementState),a
    call updateGameLogic

    ld  a,(p1MovementState)
    cp  movementStateFalling         ; Should NOT stop at ground
    ld  b,0
    ld  c,3
    call    nz,testGameLogic_errorExit

    ld  a,$0F                       ; Test NOT falling, blocked everywhere. 1
    ld  (p1CollisionState),a
    ld  a,movementStateClimbing
    ld  (p1MovementState),a
    call updateGameLogic

    ld  a,(p1MovementState)
    cp  movementStateClimbing         ; Should stop at ground
    ld  b,0
    ld  c,4
    call    nz,testGameLogic_errorExit

    ld  a,$0F                       ; Test NOT falling, blocked everywhere. 2
    ld  (p1CollisionState),a
    ld  a,movementStateGround
    ld  (p1MovementState),a
    call updateGameLogic

    ld  a,(p1MovementState)
    cp  movementStateGround         ; Should stop at ground
    ld  b,0
    ld  c,5
    call    nz,testGameLogic_errorExit

    ld  a,$0F                       ; Test NOT falling, blocked everywhere. 2
    ld  (p1CollisionState),a
    ld  a,movementStateJumping
    ld  (p1MovementState),a
    call updateGameLogic

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

testGameLogic8:
    ld  b,0
    ld  c,8
    call    test_print_testing_header_with_num
    ;============================================================
    ;; Test 8: Cat colliding right, right edge; The test may be a
    ;;         self-fulfilling prophecy but w/e
    ;============================================================

testGameLogic9:
    ld  b,0
    ld  c,9
    call    test_print_testing_header_with_num
    ;============================================================
    ;; Test 9: Cat colliding left in air, latched to it
    ;============================================================

testGameLogic10:
    ld  b,0
    ld  c,10
    call    test_print_testing_header_with_num
    ;============================================================
    ;; Test 10: Cat colliding right in air, latched to it
    ;============================================================

testGameLogic11:
    ld  b,0
    ld  c,11
    call    test_print_testing_header_with_num
    ;============================================================
    ;; Test 11: Cat colliding left on ground
    ;============================================================
endProg:
    nop
    jp endProg

testGameLogic_errorExit:
    call    test_print_error_with_num
    jp  endProg

    include "gameLogic.asm"
