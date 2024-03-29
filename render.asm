renderFrameTransferStackPtr: defw 0
renderFrameTransferSourceFirstColumn: defw 0
renderFrameTransferDestLastColumn: defw 0

renderPNUpdatesOldPosX: equ 0
renderPNUpdatesNewPosX: equ 1
renderPNUpdatesOldPosY: equ 2
renderPNUpdatesNewPosY: equ 3
renderPNUpdatesOldPose: equ 4
renderPNUpdatesNewPose: equ 5
renderPNUpdatesTileX:   equ 6
renderPNUpdatesTileY:   equ 7
renderPNUpdatesTilePtr: equ 8
renderPNUpdatesOldTilePosX: equ 10
renderPNUpdatesNewTilePosX: equ 11
renderPNUpdatesOldTilePosY: equ 12
renderPNUpdatesNewTilePosY: equ 13

renderWriteTileX: equ 0
renderWriteTileY: equ 1
renderWriteTilePtr: equ 2

renderCatMouseNumShifts:  equ 2
renderCatMouseNumFacings: equ 2

catLateralSpriteWidth: equ 24 + (72 * 4)
catNonLateralSpriteWidth: equ 74

mouseHoleXOffset:       equ mouseW1X - mouseWall1
mouseHoleYOffset:       equ mouseW1Y - mouseWall1
mouseHolePointerHigh:   equ mouseW1TileChangePtr - mouseWall1
mouseHolePointerLow:   equ mouseW1TileChangePtr - mouseWall1 + 1
mouseHoleStructSize:    equ mouseWall2 - mouseWall1

;;; Cat 1

catOneSprites: equ $DB20

catOneWalkLeft: equ $DB20
catOneJumpLeft: equ $DBC8
catOneAttackHighLeft: equ $DC70
catOneAttackLowLeft: equ $DD18
catOneStandLeft: equ $DDC0
catOneWalkRight: equ $DE68
catOneJumpRight: equ $DF10
catOneAttackHighRight: equ $DFB8
catOneAttackLowRight: equ $E060
catOneStandRight: equ $E108
catOneBgCache: equ $E1C8

catHandSprite: equ $E210
catOneHandBgCache: equ $E360
catTwoHandBgCache: equ catTwoSprites + catOneHandBgCache - catOneSprites

;;; Cat 2
catTwoSprites: equ $E380

catTwoWalkLeft: equ catTwoSprites + catOneWalkLeft - catOneSprites
catTwoJumpLeft: equ catTwoSprites + catOneJumpLeft - catOneSprites
catTwoAttackHighLeft: equ catTwoSprites + catOneAttackHighLeft - catOneSprites
catTwoAttackLowLeft: equ catTwoSprites + catOneAttackLowLeft - catOneSprites
catTwoStandLeft: equ catTwoSprites + catOneStandLeft - catOneSprites
catTwoWalkRight: equ catTwoSprites + catOneWalkRight - catOneSprites
catTwoJumpRight: equ catTwoSprites + catOneJumpRight - catOneSprites
catTwoAttackHighRight: equ catTwoSprites + catOneAttackHighRight - catOneSprites
catTwoAttackLowRight: equ catTwoSprites + catOneAttackLowRight - catOneSprites
catTwoStandRight: equ catTwoSprites + catOneStandRight- catOneSprites
catTwoBgCache: equ catTwoSprites + catOneBgCache - catOneSprites

;;; Mouse
mouseSprites: equ $EBE0
mouseWalkLeft: equ $EBE0
mouseWalkRight: equ $EC18
mouseBgCache: equ $EC58

;;; Canvi
catCanvas: equ $D800
catHandCanvas: equ $D848
mouseCanvas: equ $D868

secondFramebuffer: equ $C000

secondFramebufferScratchCat1Left: equ secondFramebuffer
secondFramebufferScratchCat1Right: equ secondFramebufferScratchCat1Left + (8*4)
secondFramebufferScratchCat2Left: equ secondFramebufferScratchCat1Right + (8*4)
secondFramebufferScratchCat2Right: equ secondFramebufferScratchCat2Left + (8*4)
secondFramebufferLowerBodyOffset: equ 8 * 2


;;; What to add to a pointer returned by renderFrameTileAddress to get an
;;; address into the second framebuffer
secondFramebufferLogicalOffset: equ secondFramebuffer - $4000

setupRenderer:

        ;; uses the second framebuffer as a scratch area.
        call renderPrecomputeSprites

        ;; second framebuffer is now off limits for anything but use as a
        ;; framebuffer
        ld de, secondFramebuffer
        ld hl, $4000
        ld bc, 32 * 24 * 8
        ldir



        ;; get the contents of the front buffer

        ld hl, catOneBgCache
        ld a, (fuP1UpdatesNewTilePosX)
        add a, levelLeftmostCol
        ld c, a
        ld a, (fuP1UpdatesNewTilePosY)
        add a, levelTopmostRow
        ld b, a
        ld e, 3
        ld d, 3
        call renderReadRectangle

        ld hl, catOneHandBgCache
        ld a, (fuP1UpdatesNewTilePosX)
        ld c, a
        ld a, (fuP1UpdatesNewTilePosY)
        ld b, a
        ld a, (fuP1UpdatesNewPose)
        ld d, a
        call renderFrameHandPos
        ld e, 2
        ld d, 2
        call renderReadRectangle

        ld hl, catTwoBgCache
        ld a, (fuP2UpdatesNewTilePosX)
        add a, levelLeftmostCol
        ld c, a
        ld a, (fuP2UpdatesNewTilePosY)
        add a, levelTopmostRow
        ld b, a
        ld e, 3
        ld d, 3
        call renderReadRectangle

        ld hl, catTwoHandBgCache
        ld a, (fuP2UpdatesNewTilePosX)
        ld c, a
        ld a, (fuP2UpdatesNewTilePosY)
        ld b, a
        ld a, (fuP2UpdatesNewPose)
        ld d, a
        call renderFrameHandPos
        ld e, 2
        ld d, 2
        call renderReadRectangle

	ld hl, mouseBgCache
	ld a, (mouseUpdatesNewTilePosX)
	add a, levelLeftmostCol
	ld c, a
	ld a, (mouseUpdatesNewTilePosY)
	add a, levelTopmostRow
	ld b, a
	ld e, 3
	ld d, 1
	call renderReadRectangle

        call statusBarSetup

        ret

renderFrame:
        ld a, 1
        call statusBarUpdateInterest
        ld a, 2
        call statusBarUpdateInterest

        ld ix, p1StateBase
        ld c, 1
        ld b, 0
        ld de, secondFramebufferLogicalOffset
        call statusBarUpdateScore

        ld c, 26
        ld b, 1
        ld ix, p2StateBase
        call statusBarUpdateScore


        ;; TODO: this stuff probably belongs in gameLogic
        ;; Save old tile positions
        ld a, (fuP1UpdatesNewTilePosX)
        ld (fuP1UpdatesOldTilePosX), a

        ld a, (fuP2UpdatesNewTilePosX)
        ld (fuP2UpdatesOldTilePosX), a

        ld a, (fuP1UpdatesNewTilePosY)
        ld (fuP1UpdatesOldTilePosY), a

        ld a, (fuP2UpdatesNewTilePosY)
        ld (fuP2UpdatesOldTilePosY), a

        ld a, (mouseUpdatesNewTilePosX)
        ld (mouseUpdatesOldTilePosX), a

        ld a, (mouseUpdatesNewTilePosY)
        ld (mouseUpdatesOldTilePosY), a

        ;;  calculate new tile positions
        ld a, (fuP1UpdatesNewPosX)
        srl a
        srl a
        srl a
        ld (fuP1UpdatesNewTilePosX), a

        ld a, (fuP1UpdatesNewPosY)
        srl a
        srl a
        srl a
        inc a
        ld (fuP1UpdatesNewTilePosY), a

        ld a, (fuP2UpdatesNewPosX)
        srl a
        srl a
        srl a
        ld (fuP2UpdatesNewTilePosX), a

        ld a, (fuP2UpdatesNewPosY)
        srl a
        srl a
        srl a
        inc a
        ld (fuP2UpdatesNewTilePosY), a

        ;;  calculate new mouse tile positions
        ld a, (mouseUpdatesNewPosX)
        srl a
        srl a
        srl a
        ld (mouseUpdatesNewTilePosX), a

        ld a, (mouseUpdatesNewPosY)
        srl a
        srl a
        srl a
        ld (mouseUpdatesNewTilePosY), a

        ;ld a,2              ; 2 is the code for red.
        ;out (254),a         ; write to port 254.



        ;; clear old sprites

        ;; erase mouse
        ld hl, mouseBgCache
        ld a, (mouseUpdatesOldTilePosX)
        add a, levelLeftmostCol
        ld c, a
        ld a, (mouseUpdatesOldTilePosY)
        add a, levelTopmostRow
        ld b, a
        ld e, 3
        ld d, 1
        call renderDrawRectangle

        ;; erase cat hand 2
        ld hl, catTwoHandBgCache
        ld a, (fuP2UpdatesOldTilePosX)
        ld c, a
        ld a, (fuP2UpdatesOldTilePosY)
        ld b, a
        ld a, (fuP2UpdatesOldPose)
        ld d, a
        call renderFrameHandPos
        ld e, 2
        ld d, 2
        call renderDrawRectangle

        ;; erase cat 2
        ld hl, catTwoBgCache
        ld a, (fuP2UpdatesOldTilePosX)
        add a, levelLeftmostCol
        ld c, a
        ld a, (fuP2UpdatesOldTilePosY)
        add a, levelTopmostRow
        ld b, a
        ld e, 3
        ld d, 3
        call renderDrawRectangle

        ;; erase cat hand 1
        ld hl, catOneHandBgCache
        ld a, (fuP1UpdatesOldTilePosX)
        ld c, a
        ld a, (fuP1UpdatesOldTilePosY)
        ld b, a
        ld a, (fuP1UpdatesOldPose)
        ld d, a
        call renderFrameHandPos
        ld e, 2
        ld d, 2
        call renderDrawRectangle

        ;; erase cat 1
        ld hl, catOneBgCache
        ld a, (fuP1UpdatesOldTilePosX)
        add a, levelLeftmostCol
        ld c, a
        ld a, (fuP1UpdatesOldTilePosY)
        add a, levelTopmostRow
        ld b, a
        ld e, 3
        ld d, 3
        call renderDrawRectangle

        ;; Tile updates

        ;; draw cat 1's tile updates
        ld hl, (fuP1UpdatesTileChangePtr)
        ld a, h
        or l
        jp z, renderFrameCat1NoTileUpdate

        ld a, (fuP1UpdatesTileChangeX)
        add a, levelLeftmostCol
        ld c, a
        ld a, (fuP1UpdatesTileChangeY)
        add a, levelTopmostRow
        ld b, a
        ld de, secondFramebufferLogicalOffset
        call renderFrameWriteTile
renderFrameCat1NoTileUpdate:

        ;; draw cat 2's tile updates
        ld hl, (fuP2UpdatesTileChangePtr)
        ld a, h
        or l
        jp z, renderFrameCat2NoTileUpdate

        ld a, (fuP2UpdatesTileChangeX)
        add a, levelLeftmostCol
        ld c, a
        ld a, (fuP2UpdatesTileChangeY)
        add a, levelTopmostRow
        ld b, a
        ld de, secondFramebufferLogicalOffset
        call renderFrameWriteTile
renderFrameCat2NoTileUpdate:

        ld b, mouseWallNumHoles
        ld ix, mouseWall1
renderFrameMouseHoleTileLoop:
        push bc
        ld h, (IX + mouseHolePointerHigh)
        ld l, (IX + mouseHolePointerLow)
        ld a, h
        or l
        jp z, renderFrameMouseHoleTileLoopSkip

        ld a, (IX + mouseHoleXOffset)
        add a, levelLeftmostCol
        ld c, a
        ld a, (IX + mouseHoleYOffset)
        add a, levelTopmostRow
        ld b, a
        ld de, secondFramebufferLogicalOffset
        call renderFrameWriteTile

renderFrameMouseHoleTileLoopSkip:
        ld bc, mouseHoleStructSize
        add ix, bc

        pop bc
        djnz renderFrameMouseHoleTileLoop

        ;; draw new sprites

        ;; read area behind cat 1
        ld hl, catOneBgCache
        ld a, (fuP1UpdatesNewTilePosX)
        add a, levelLeftmostCol
        ld c, a
        ld a, (fuP1UpdatesNewTilePosY)
        add a, levelTopmostRow
        ld b, a
        ld e, 3
        ld d, 3
        call renderReadRectangle

        ;; populate catCanvas
        ld ix, fuP1UpdatesBase
        ld de, catOneBgCache
        ld hl, catOneSprites
        call renderFrameBuildCat

        ;; draw cat 1
        ld hl, catCanvas
        ld a, (fuP1UpdatesNewTilePosX)
        add a, levelLeftmostCol
        ld c, a
        ld a, (fuP1UpdatesNewTilePosY)
        add a, levelTopmostRow
        ld b, a
        ld e, 3
        ld d, 3
        call renderDrawRectangle

        ;; read area behind cat hand 1
        ld hl, catOneHandBgCache
        ld a, (fuP1UpdatesNewTilePosX)
        ld c, a
        ld a, (fuP1UpdatesNewTilePosY)
        ld b, a
        ld a, (fuP1UpdatesNewPose)
        ld d, a
        call renderFrameHandPos
        ld e, 2
        ld d, 2
        call renderReadRectangle

        ;; TODO: blit stuff
        ld ix, fuP1UpdatesBase
        ld de, catOneHandBgCache
        call renderFrameBuildCatHand

        ;; draw cat hand 1
        ld hl, catHandCanvas
        ld a, (fuP1UpdatesNewTilePosX)
        ld c, a
        ld a, (fuP1UpdatesNewTilePosY)
        ld b, a
        ld a, (fuP1UpdatesNewPose)
        ld d, a
        call renderFrameHandPos
        ld e, 2
        ld d, 2
        call renderDrawRectangle

        ;; read area behind cat 2
        ld hl, catTwoBgCache
        ld a, (fuP2UpdatesNewTilePosX)
        add a, levelLeftmostCol
        ld c, a
        ld a, (fuP2UpdatesNewTilePosY)
        add a, levelTopmostRow
        ld b, a
        ld e, 3
        ld d, 3
        call renderReadRectangle

        ;; populate catCanvas
        ld ix, fuP2UpdatesBase
        ld de, catTwoBgCache
        ld hl, catTwoSprites
        call renderFrameBuildCat

        ;; draw cat 2
        ld hl, catCanvas
        ld a, (fuP2UpdatesNewTilePosX)
        add a, levelLeftmostCol
        ld c, a
        ld a, (fuP2UpdatesNewTilePosY)
        add a, levelTopmostRow
        ld b, a
        ld e, 3
        ld d, 3
        call renderDrawRectangle

        ;; read area behind cat hand 2
        ld hl, catTwoHandBgCache
        ld a, (fuP2UpdatesNewTilePosX)
        ld c, a
        ld a, (fuP2UpdatesNewTilePosY)
        ld b, a
        ld a, (fuP2UpdatesNewPose)
        ld d, a
        call renderFrameHandPos
        ld e, 2
        ld d, 2
        call renderReadRectangle

        ;; TODO: blit stuff
        ld ix, fuP2UpdatesBase
        ld de, catTwoHandBgCache
        call renderFrameBuildCatHand

        ;; draw cat hand 2
        ld hl, catHandCanvas
        ld a, (fuP2UpdatesNewTilePosX)
        ld c, a
        ld a, (fuP2UpdatesNewTilePosY)
        ld b, a
        ld a, (fuP2UpdatesNewPose)
        ld d, a
        call renderFrameHandPos
        ld e, 2
        ld d, 2
        call renderDrawRectangle

        ;; read area behind mouse
        ld hl, mouseBgCache
        ld a, (mouseUpdatesNewTilePosX)
        add a, levelLeftmostCol
        ld c, a
        ld a, (mouseUpdatesNewTilePosY)
        add a, levelTopmostRow
        ld b, a
        ld e, 3
        ld d, 1
        call renderReadRectangle

        ;; populate mouseCanvas
        call renderFrameBuildMouse

        ;; draw mouse
        ld hl, mouseCanvas
        ld a, (mouseUpdatesNewTilePosX)
        add a, levelLeftmostCol
        ld c, a
        ld a, (mouseUpdatesNewTilePosY)
        add a, levelTopmostRow
        ld b, a
        ld e, 3
        ld d, 1
        call renderDrawRectangle

        ;ld a,1              ; 1 is the code for blue.
        ;out (254),a         ; write to port 254.
        ret






        ;; ---------------------------------------------------------------------
        ;; precomputeSprites
        ;; ---------------------------------------------------------------------
        ;; POST: Sprite layout lookup table populated
renderPrecomputeSprites:
        ;; initialize cat 1 scratch area
        ld de, secondFramebufferScratchCat1Left
        ld hl, CAT_LEFT_UPPERBODY_PLAYER_1
        ld bc, 16
        ldir

        ld de, secondFramebufferScratchCat1Right
        ld hl, CAT_RIGHT_UPPERBODY_PLAYER_1
        ld bc, 16
        ldir


        ;; initialize cat 2 scratch area
        ld de, secondFramebufferScratchCat2Left
        ld hl, CAT_LEFT_UPPERBODY_PLAYER_2
        ld bc, 16
        ldir

        ld de, secondFramebufferScratchCat2Right
        ld hl, CAT_RIGHT_UPPERBODY_PLAYER_2
        ld bc, 16
        ldir

        ;; scratch area initialized

        ld b, renderCatMouseNumShifts
        ld ix, 24
        jp renderPrecomputeSpritesCatCopyLoopFirstIter
renderPrecomputeSpritesCatCopyLoop:
        ld de, 9 * 8
        add ix, de
renderPrecomputeSpritesCatCopyLoopFirstIter:
        push bc

        ld hl, CAT_STEP_ONE
        call renderPrecomputePrepareSymmetricScratchArea

        ;; Stand
        ld de, catOneStandLeft
        ld hl, catOneStandRight
        call renderPrecomputeCopySymmetricSprite

        ;; Jump
        ld hl, CAT_LEFT_LEAP_RIGHT_LAND_OUTWARD_STEP_OR_JUMP
        call renderPrecomputePrepareSymmetricScratchArea

        ld de, catOneJumpLeft
        ld hl, catOneJumpRight
        call renderPrecomputeCopySymmetricSprite

        ;; Attack High

        ld hl, CAT_RIGHT_LEAP_LEFT_LAND_OUTWARD_STEP_OR_JUMP
        call renderPrecomputePrepareSymmetricScratchArea

        ld de, catOneAttackHighLeft
        ld hl, catOneAttackHighRight
        call renderPrecomputeCopySymmetricSprite

        ;; Attack Low

        ld hl, CAT_RIGHT_LEAP_LEFT_LAND_OUTWARD_STEP_OR_JUMP
        call renderPrecomputePrepareSymmetricScratchArea

        ld de, catOneAttackLowLeft
        ld hl, catOneAttackLowRight
        call renderPrecomputeCopySymmetricSprite

        pop bc
        dec b

        jp nz, renderPrecomputeSpritesCatCopyLoop

        ;; Load special case walking sprites

        ;; Step zero offset

        ld hl, CAT_STEP_ONE
        call renderPrecomputePrepareSymmetricScratchArea

        ld ix, 24
        ld de, catOneWalkLeft
        ld hl, catOneWalkRight
        call renderPrecomputeCopySymmetricSprite

        ;; step four offset

        ld hl, CAT_STEP_TWO
        call renderPrecomputePrepareSymmetricScratchArea

        ld ix, 24 + (9 * 8)
        ld de, catOneWalkLeft
        ld hl, catOneWalkRight
        call renderPrecomputeCopySymmetricSprite

        ;; ---------------------------------------------------------------------
        ;; Cat hand copying
        ;; ---------------------------------------------------------------------

        ld b, renderCatMouseNumShifts
        ld ix, 16
        jp renderPrecomputeSpritesCatHandCopyLoopFirstIter
renderPrecomputeSpritesCatHandCopyLoop:
        ld de, 4 * 8
        add ix, de
renderPrecomputeSpritesCatHandCopyLoopFirstIter:
        push bc

        ld hl, CAT_CLAW
        ld de, catHandSprite
        call renderPrecomputeCopyCatHandSprite

        pop bc
        dec b

        jp nz, renderPrecomputeSpritesCatHandCopyLoop

        ;; ---------------------------------------------------------------------
        ;; Mouse copying
        ;; ---------------------------------------------------------------------

        ld ix, 8
        ld de, mouseWalkLeft
        ld hl, MOUSE_LEFT_ONE
        call renderPrecomputeCopyMouseSprite

        ld de, mouseWalkRight
        ld hl, MOUSE_RIGHT_ONE
        call renderPrecomputeCopyMouseSprite

        ld ix, 8 + 24
        ld de, mouseWalkLeft
        ld hl, MOUSE_LEFT_TWO
        call renderPrecomputeCopyMouseSprite

        ld de, mouseWalkRight
        ld hl, MOUSE_RIGHT_TWO
        call renderPrecomputeCopyMouseSprite

        ;; ---------------------------------------------------------------------
        ;; Prepare for shift loop
        ;; ---------------------------------------------------------------------
        ld b, 0
        ld hl, 24
renderPrecomputeSpritesCatShiftLoop:
        push bc
        ld bc, 9 * 8
        add hl, bc
        pop bc
        ld d, h
        ld e, l
        inc b
        inc b
        inc b
        inc b

        ld ix, catOneStandLeft
        add ix, de
        call renderPrecomputeShiftCatSprite

        ld ix, catOneStandRight
        add ix, de
        call renderPrecomputeShiftCatSprite

        ld ix, catTwoStandLeft
        add ix, de
        call renderPrecomputeShiftCatSprite

        ld ix, catTwoStandRight
        add ix, de
        call renderPrecomputeShiftCatSprite

        ld ix, catOneWalkLeft
        add ix, de
        call renderPrecomputeShiftCatSprite

        ld ix, catOneWalkRight
        add ix, de
        call renderPrecomputeShiftCatSprite

        ld ix, catTwoWalkLeft
        add ix, de
        call renderPrecomputeShiftCatSprite

        ld ix, catTwoWalkRight
        add ix, de
        call renderPrecomputeShiftCatSprite

        ld ix, catOneJumpLeft
        add ix, de
        call renderPrecomputeShiftCatSprite

        ld ix, catOneJumpRight
        add ix, de
        call renderPrecomputeShiftCatSprite

        ld ix, catTwoJumpLeft
        add ix, de
        call renderPrecomputeShiftCatSprite

        ld ix, catTwoJumpRight
        add ix, de
        call renderPrecomputeShiftCatSprite

        ld ix, catOneAttackHighLeft
        add ix, de
        call renderPrecomputeShiftCatSprite

        ld ix, catOneAttackHighRight
        add ix, de
        call renderPrecomputeShiftCatSprite

        ld ix, catTwoAttackHighLeft
        add ix, de
        call renderPrecomputeShiftCatSprite

        ld ix, catTwoAttackHighRight
        add ix, de
        call renderPrecomputeShiftCatSprite

        ld ix, catOneAttackLowLeft
        add ix, de
        call renderPrecomputeShiftCatSprite

        ld ix, catOneAttackLowRight
        add ix, de
        call renderPrecomputeShiftCatSprite

        ld ix, catTwoAttackLowLeft
        add ix, de
        call renderPrecomputeShiftCatSprite

        ld ix, catTwoAttackLowRight
        add ix, de
        call renderPrecomputeShiftCatSprite

        ld a, b
        cp (renderCatMouseNumShifts - 1) * 4
        jp z, renderPrecomputeSpritesCatShiftLoopEnd
        jp renderPrecomputeSpritesCatShiftLoop
renderPrecomputeSpritesCatShiftLoopEnd:

        ;; ---------------------------------------------------------------------
        ;; Shift cat hand
        ;; ---------------------------------------------------------------------
        ld b, 0
        ld hl, 16
renderPrecomputeSpritesCatHandShiftLoop:
        push bc
        ld bc, 4 * 8
        add hl, bc
        pop bc
        ld d, h
        ld e, l
        inc b
        inc b
        inc b
        inc b


        ld ix, catHandSprite
        add ix, de
        call renderPrecomputeShiftCatHandSprite


        ld a, b
        cp (renderCatMouseNumShifts - 1) * 4
        jp z, renderPrecomputeSpritesShiftCatHandLoopEnd
        jp renderPrecomputeSpritesCatHandShiftLoop
renderPrecomputeSpritesShiftCatHandLoopEnd:

        ;; ---------------------------------------------------------------------
        ;; Shift mouse
        ;; ---------------------------------------------------------------------

        ld b, 0
        ld hl, 8
renderPrecomputeSpritesMouseShiftLoop:
        push bc
        ld bc, 3 * 8
        add hl, bc
        pop bc
        ld d, h
        ld e, l
        inc b
        inc b
        inc b
        inc b

        ld ix, mouseWalkLeft
        add ix, de
        call renderPrecomputeShiftMouseSprite

        ld ix, mouseWalkRight
        add ix, de
        call renderPrecomputeShiftMouseSprite

        ld a, b
        cp (renderCatMouseNumShifts - 1) * 4
        jp z, renderPrecomputeSpritesMouseShiftLoopEnd
        jp renderPrecomputeSpritesMouseShiftLoop
renderPrecomputeSpritesMouseShiftLoopEnd:

        ret

        ;; ---------------------------------------------------------------------
        ;;  copyCatHandSprite
        ;; ---------------------------------------------------------------------
        ;; PRE: de contains destination of cat-hand-sized sprite
        ;;      hl contains source of cat-hand-sized sprite
        ;;      IX contains offset past de to write to
        ;; POST: sprite copied
renderPrecomputeCopyCatHandSprite:
        push hl

        push ix                 ; put value in IX on stack
        pop hl                  ; pull it back off into HL
        add hl, de
        ex de, hl

        pop hl

        ;; de contains de + ix (dest + dest offset)
        ;; hl contains original source value

        ;; blank
        push hl
        ld hl, zeroTile
        ld bc, 8
        ldir
        pop hl

        ;; hl contains tile 0
        ld bc, 8
        ldir

        ;; blank * 2
        ld hl, zeroTile
        ld bc, 8
        ldir

        ld hl, zeroTile
        ld bc, 8
        ldir

        ret

        ;; ---------------------------------------------------------------------
        ;; shiftCatHandSprite
        ;; ---------------------------------------------------------------------
        ;; PRE: IX contains a ptr to the beginning of a cat-hand-sized sprite
        ;;      b contains the shift level N
        ;; POST: the sprite in IX is shifted over N pixels
renderPrecomputeShiftCatHandSprite:
        push bc
renderPrecomputeShiftCatHandSpriteLoop:
        ;; bottom row
        srl (IX + 8)
        rr (IX + 8 + 16)

        srl (IX + 8 + 1)
        rr (IX + 8 + 16 + 1)

        srl (IX + 8 + 2)
        rr (IX + 8 + 16 + 2)

        srl (IX + 8 + 3)
        rr (IX + 8 + 16 + 3)

        srl (IX + 8 + 4)
        rr (IX + 8 + 16 + 4)

        srl (IX + 8 + 5)
        rr (IX + 8 + 16 + 5)

        srl (IX + 8 + 6)
        rr (IX + 8 + 16 + 6)

        srl (IX + 8 + 7)
        rr (IX + 8 + 16 + 7)
        dec b
        jp nz, renderPrecomputeShiftCatHandSpriteLoop
        pop bc
        ret

        ;; ---------------------------------------------------------------------
        ;;  copyCatSprite
        ;; ---------------------------------------------------------------------
        ;; PRE: de contains destination of cat-sized sprite
        ;;      hl contains source of cat-sized sprite
        ;;      IX contains offset past de to write to
        ;; POST: sprite copied
renderPrecomputeCopyCatSprite:
        push hl

        push ix                 ; put value in IX on stack
        pop hl                  ; pull it back off into HL
        add hl, de
        ex de, hl

        pop hl

        ;; de contains de + ix (dest + dest offset)
        ;; hl contains original source value

        ;; blank
        push hl
        ld hl, zeroTile
        ld bc, 8
        ldir
        pop hl

        ;; hl contains tile 0
        ld bc, 8
        ldir

        push hl
        ld bc, 8
        add hl, bc
        ;; hl contains tile 2
        ld bc, 8
        ldir

        ;; blank
        push hl
        ld hl, zeroTile
        ld bc, 8
        ldir
        pop hl

        pop hl
        ;; hl contains tile 1

        ld bc, 8
        ldir

        ld bc, 8
        add hl, bc
        ld bc, 8
        ;; hl contains tile 3
        ldir

        ld hl, zeroTile
        ld bc, 8
        ldir

        ld hl, zeroTile
        ld bc, 8
        ldir

        ld hl, zeroTile
        ld bc, 8
        ldir

        ret


        ;; ---------------------------------------------------------------------
        ;;  prepareSymmetricScratchArea
        ;; ---------------------------------------------------------------------
        ;; PRE: hl contains source of bottom half of cat-sized sprite
        ;; POST: scratch area prepared for cat sprite copy
renderPrecomputePrepareSymmetricScratchArea:
        push hl
        ld de, secondFramebufferScratchCat1Left + secondFramebufferLowerBodyOffset
        ld bc, 16
        ldir
        pop hl

        push hl
        ld de, secondFramebufferScratchCat1Right + secondFramebufferLowerBodyOffset
        ld bc, 16
        ldir
        pop hl

        push hl
        ld de, secondFramebufferScratchCat2Left + secondFramebufferLowerBodyOffset
        ld bc, 16
        ldir
        pop hl

        push hl
        ld de, secondFramebufferScratchCat2Right + secondFramebufferLowerBodyOffset
        ld bc, 16
        ldir
        pop hl

        ret

        ;; ---------------------------------------------------------------------
        ;; copySymmetricSprite
        ;; ---------------------------------------------------------------------
        ;; pre: de contains thingCat1Left
        ;;      hl contains thingCat1Right
        ;;      thingCat1Left - cat1Base + cat2Base = thingCat2Left
        ;;      thingCat1Right - cat1Base + cat2Base = thingCat2Right
        ;;      IX contains offset past DE that copyCatSprite needs
        ;; post: cat 1 and 2 both copied
renderPrecomputeCopySymmetricSprite:
        push de
        push hl

        ;; de contains thingCat1Left
        ld hl, secondFramebufferScratchCat1Left
        push de
        call renderPrecomputeCopyCatSprite
        pop de

        ld hl, catTwoSprites - catOneSprites
        add hl, de
        ex de, hl
        ;; de contains thingCat1Left - cat1Base + cat2Base = thingCat2Left
        ld hl, secondFramebufferScratchCat2Left
        call renderPrecomputeCopyCatSprite

        pop hl
        pop de

        ex de, hl

        ;; de contains thingCat1Right
        ld hl, secondFramebufferScratchCat1Right
        push de
        call renderPrecomputeCopyCatSprite
        pop de

        ld hl, catTwoSprites - catOneSprites
        add hl, de
        ex de, hl
        ;; de contains thingCat1Right - cat1Base + cat2Base = thingCat2Right
        ld hl, secondFramebufferScratchCat2Right
        call renderPrecomputeCopyCatSprite

        ret


        ;; ---------------------------------------------------------------------
        ;; shiftCatSprite
        ;; ---------------------------------------------------------------------
        ;; PRE: IX contains a pointer to the beginning of a cat-sized sprite
        ;;      b contains the shift level N
        ;; POST: the sprite in IX is shifted over N pixels
renderPrecomputeShiftCatSprite:
        push bc
renderPrecomputeShiftCatSpriteLoop:
        ;; middle row
        srl (IX + 8)
        rr (IX + 8 + 24)
        rr (IX + 8 + 48)

        srl (IX + 8 + 1)
        rr (IX + 8 + 24 + 1)
        rr (IX + 8 + 48 + 1)

        srl (IX + 8 + 2)
        rr (IX + 8 + 24 + 2)
        rr (IX + 8 + 48 + 2)

        srl (IX + 8 + 3)
        rr (IX + 8 + 24 + 3)
        rr (IX + 8 + 48 + 3)

        srl (IX + 8 + 4)
        rr (IX + 8 + 24 + 4)
        rr (IX + 8 + 48 + 4)

        srl (IX + 8 + 5)
        rr (IX + 8 + 24 + 5)
        rr (IX + 8 + 48 + 5)

        srl (IX + 8 + 6)
        rr (IX + 8 + 24 + 6)
        rr (IX + 8 + 48 + 6)

        srl (IX + 8 + 7)
        rr (IX + 8 + 24 + 7)
        rr (IX + 8 + 48 + 7)

        ;; bottom row
        srl (IX + 16)
        rr (IX + 16 + 24)
        rr (IX + 16 + 48)

        srl (IX + 16 + 1)
        rr (IX + 16 + 24 + 1)
        rr (IX + 16 + 48 + 1)

        srl (IX + 16 + 2)
        rr (IX + 16 + 24 + 2)
        rr (IX + 16 + 48 + 2)

        srl (IX + 16 + 3)
        rr (IX + 16 + 24 + 3)
        rr (IX + 16 + 48 + 3)

        srl (IX + 16 + 4)
        rr (IX + 16 + 24 + 4)
        rr (IX + 16 + 48 + 4)

        srl (IX + 16 + 5)
        rr (IX + 16 + 24 + 5)
        rr (IX + 16 + 48 + 5)

        srl (IX + 16 + 6)
        rr (IX + 16 + 24 + 6)
        rr (IX + 16 + 48 + 6)

        srl (IX + 16 + 7)
        rr (IX + 16 + 24 + 7)
        rr (IX + 16 + 48 + 7)
        dec b
        jp nz, renderPrecomputeShiftCatSpriteLoop
        pop bc
        ret

        ;; ---------------------------------------------------------------------
        ;;  copyMouseSprite
        ;; ---------------------------------------------------------------------
        ;; PRE: de contains destination of mouse-sized sprite
        ;;      hl contains source of mouse-sized sprite
        ;;      IX contains offset past de to write to
        ;; POST: sprite copied
renderPrecomputeCopyMouseSprite:
        push hl

        push ix                 ; put value in IX on stack
        pop hl                  ; pull it back off into HL
        add hl, de
        ex de, hl

        pop hl

        ;; de contains de + ix (dest + dest offset)
        ;; hl contains original source value

        ;; hl contains tile 0
        ld bc, 16
        ldir

        ld hl, zeroTile
        ld bc, 8
        ldir

        ret

        ;; ---------------------------------------------------------------------
        ;; shiftMouseSprite
        ;; ---------------------------------------------------------------------
        ;; PRE: IX contains a pointer to the beginning of a mouse-sized sprite
        ;;      b contains the shift level N
        ;; POST: the sprite in IX is shifted over N pixels
renderPrecomputeShiftMouseSprite:
        push bc
renderPrecomputeShiftMouseSpriteLoop:
        ;; bottom row
        srl (IX)
        rr (IX + 8)
        rr (IX + 16)

        srl (IX + 1)
        rr (IX + 8 + 1)
        rr (IX + 16 + 1)

        srl (IX + 2)
        rr (IX + 8 + 2)
        rr (IX + 16 + 2)

        srl (IX + 3)
        rr (IX + 8 + 3)
        rr (IX + 16 + 3)

        srl (IX + 4)
        rr (IX + 8 + 4)
        rr (IX + 16 + 4)

        srl (IX + 5)
        rr (IX + 8 + 5)
        rr (IX + 16 + 5)

        srl (IX + 6)
        rr (IX + 8 + 6)
        rr (IX + 16 + 6)

        srl (IX + 7)
        rr (IX + 8 + 7)
        rr (IX + 16 + 7)
        dec b
        jp nz, renderPrecomputeShiftMouseSpriteLoop
        pop bc
        ret

;;; ----------------------------------------------------------------------------
;;; Rectangle manipulation
;;; ----------------------------------------------------------------------------

        ;; ---------------------------------------------------------------------
        ;; drawRectangle
        ;; ---------------------------------------------------------------------
        ;; PRE: HL contains pointer to first tile of canvas to draw
        ;;      c contains x offset of top left corner
        ;;      b contains y offset of top left corner
        ;;      e contains width of rectangle
        ;;      d contains height of rectangle
        ;;      rectangle in range
        ;; POST: rectangle of tile pixel data at HL drawn to the screen
renderDrawRectangle:
        dec b
        ld a, e
        ld (renderDrawRectangleOriginalWidth), a
        ld a, c
        ld (renderDrawRectangleOriginalX), a
        jp renderDrawRectangleXLoop
renderDrawRectangleYLoop:
        ld a, (renderDrawRectangleOriginalWidth) ; a contains original width
        ld e, a                                  ; e contains original width
        ld a, (renderDrawRectangleOriginalX)     ; a contains original X
        ld c, a                                  ; c contains original X
        inc b                   ; b contains prevY + 1
renderDrawRectangleXLoop:
        ;; c contains current x
        ;; b contains current y
        ;; hl contains current tile
        push de
        push hl
        ld de, secondFramebufferLogicalOffset
        call renderFrameWriteTilePixels
        pop hl
        pop de

        push de
        ld de, 8
        add hl, de               ; advance to next tile
        pop de
        ;; hl contains hl + 8

        inc c
        dec e
        ld a, e
        cp 0
        jp nz, renderDrawRectangleXLoop

        dec d
        ld a, d
        cp 0
        jp nz, renderDrawRectangleYLoop

        ret

renderDrawRectangleOriginalWidth:    defb 0
renderDrawRectangleOriginalX:        defb 0

        ;; ---------------------------------------------------------------------
        ;; readRectangle
        ;; ---------------------------------------------------------------------
        ;; PRE: HL contains pointer to first tile of buffer to read into
        ;;      c contains x offset of top left corner
        ;;      b contains y offset of top left corner
        ;;      e contains width of rectangle
        ;;      d contains height of rectangle
        ;;      rectangle in range
        ;; POST: rectangle of tile pixel data at screen location
        ;;       ((x, y),(x + width, y + height)) written to HL
renderReadRectangle:
        dec b
        ld a, e
        ld (renderReadRectangleOriginalWidth), a
        ld a, c
        ld (renderReadRectangleOriginalX), a
        jp renderReadRectangleXLoop
renderReadRectangleYLoop:
        ld a, (renderReadRectangleOriginalWidth) ; a contains original width
        ld e, a                                  ; e contains original width
        ld a, (renderReadRectangleOriginalX)     ; a contains original X
        ld c, a                                  ; c contains original X
        inc b                   ; b contains prevY + 1
renderReadRectangleXLoop:
        ;; c contains current x
        ;; b contains current y
        ;; hl contains current tile
        push de
        push hl
        ld de, secondFramebufferLogicalOffset
        call renderFrameReadTilePixels
        pop hl
        pop de

        push de
        ld de, 8
        add hl, de               ; advance to next tile
        pop de
        ;; hl contains hl + 8

        inc c
        dec e
        ld a, e
        cp 0
        jp nz, renderReadRectangleXLoop

        dec d
        ld a, d
        cp 0
        jp nz, renderReadRectangleYLoop

        ret

renderReadRectangleOriginalWidth:    defb 0
renderReadRectangleOriginalX:        defb 0

;;; ----------------------------------------------------------------------------
;;; Tile manipulation
;;; ----------------------------------------------------------------------------

        ;; ---------------------------------------------------------------------
        ;; readTile
        ;; ---------------------------------------------------------------------
        ;; PRE: HL contains pointer to tile to read into
        ;;      DE contains an offset past the primary framebuffer
        ;;         to add to the pointer. Use 0 to just read from the
        ;;         primary framebuffer
        ;;      c contains x offset
        ;;      b contains y offset
        ;; POST: tile at screen position (x, y) written to address in HL
renderFrameReadTile:
        call renderFrameReadTilePixels
        call renderFrameReadTileAttribute
        ret

        ;; ---------------------------------------------------------------------
        ;; readTilePixels
        ;; ---------------------------------------------------------------------
        ;; PRE: HL contains pointer to tile to read into
        ;;      DE contains an offset past the primary framebuffer
        ;;         to add to the pointer. Use 0 to just read from the
        ;;         primary framebuffer
        ;;      c contains x offset
        ;;      b contains y offset
        ;; POST: tile pixel data at screen position (x, y) written to (HL)
renderFrameReadTilePixels:
        push bc
        push de

        call renderFrameTileAddress
        pop bc                  ; BC contains the value pushed from DE

        ex de, hl
        add hl, bc
        ex de, hl               ; hl contains pixel data address + offset

        ld b, 8
renderFrameReadTilePixelsLoop:
        ld a, (de)              ; screen data[i]
        ld (hl), a              ; copy to tile data[i]
        inc hl
        inc d
        djnz renderFrameReadTilePixelsLoop
        pop bc
        ret

        ;; ---------------------------------------------------------------------
        ;; readTileAttribute
        ;; ---------------------------------------------------------------------
        ;; PRE: HL contains pointer to tile to read into
        ;;      c contains x offset
        ;;      b contains y offset
        ;; POST: tile Attribute at screen position (x, y) written to (HL)
renderFrameReadTileAttribute:
        push hl
        call renderFrameTileAttrAddress
        ld a, (hl)              ; a contains attribute
        pop hl
        ld (hl), a              ; attribute stored in (hl)
        ret

        ;; ---------------------------------------------------------------------
        ;; writeTile
        ;; ---------------------------------------------------------------------
        ;; PRE: HL contains pointer to tile to draw
        ;;      DE contains an offset past the primary framebuffer
        ;;         to add to the pointer. Use 0 to just write to the
        ;;         primary framebuffer
        ;;      c contains x offset
        ;;      b contains y offset
        ;; POST: tile written to screen at (x, y)
        ;; https://chuntey.wordpress.com/2013/09/08/how-to-write-zx-spectrum-games-chapter-9/
renderFrameWriteTile:
        call renderFrameWriteTilePixels
        call renderFrameWriteTileAttribute
        ret

        ;; ---------------------------------------------------------------------
        ;; writeTilePixels
        ;; ---------------------------------------------------------------------
        ;; PRE: HL contains pointer to tile pixel data to draw
        ;;      DE contains an offset past the primary framebuffer
        ;;         to add to the pointer. Use 0 to just write to the
        ;;         primary framebuffer
        ;;      c contains x offset
        ;;      b contains y offset
        ;; POST: tile pixel data written to screen at (x, y)
        ;; https://chuntey.wordpress.com/2013/09/08/how-to-write-zx-spectrum-games-chapter-9/
renderFrameWriteTilePixels:
        push de
        push bc
        push de

        call renderFrameTileAddress ; DE contains pointer to top row of tile
        pop bc                  ; BC contains the value pushed from DE

        ex de, hl
        add hl, bc
        ex de, hl               ; hl contains pixel data address + offset

        ld b,8              ; number of pixels high.

renderFrameWriteTilePixelsLoop:
        ld a,(hl)           ; source graphic.
        ld (de),a           ; transfer to screen.
        inc hl              ; next piece of data.
        inc d               ; next pixel line.
        djnz renderFrameWriteTilePixelsLoop ; repeat

        pop bc
        pop de
        ret

        ;; ---------------------------------------------------------------------
        ;; writeTileAttribute
        ;; ---------------------------------------------------------------------
        ;; PRE: HL contains pointer to tile attribute to draw
        ;;      c contains x offset
        ;;      b contains y offset
        ;; POST: tile attribute written to screen at (x, y)
        ;; https://chuntey.wordpress.com/2013/09/08/how-to-write-zx-spectrum-games-chapter-9/
renderFrameWriteTileAttribute:
        ld a, (hl)              ; a contains attribute
        push af
        call renderFrameTileAttrAddress ; HL contains pointer to attribute
        pop af
        ld (hl), a
        ret

        ;; https://chuntey.wordpress.com/2013/09/08/how-to-write-zx-spectrum-games-chapter-9/
renderFrameTileAddress:
        ld a,b              ; vertical position.
        and 24              ; which segment, 0, 1 or 2?
        add a,64            ; 64*256 = 16384, Spectrum's screen memory.
        ld d,a              ; this is our high byte.
        ld a,b              ; what was that vertical position again?
        and 7               ; which row within segment?
        rrca                ; multiply row by 32.
        rrca
        rrca
        ld e,a              ; low byte.
        ld a,c              ; add on y coordinate.
        add a,e             ; mix with low byte.
        ld e,a              ; address of screen position in de.
        ret

        ;; https://chuntey.wordpress.com/2013/09/08/how-to-write-zx-spectrum-games-chapter-9/
renderFrameTileAttrAddress:
        ld a,b              ; x position.
        rrca                ; multiply by 32.
        rrca
        rrca
        ld l,a              ; store away in l.
        and 3               ; mask bits for high byte.
        add a,88            ; 88*256=22528, start of attributes.
        ld h,a              ; high byte done.
        ld a,l              ; get x*32 again.
        and 224             ; mask low byte.
        ld l,a              ; put in l.
        ld a,c              ; get y displacement.
        add a,l             ; add to low byte.
        ld l,a              ; hl=address of attributes.
        ret

;;; ----------------------------------------------------------------------------
;;; Canvas building
;;; ----------------------------------------------------------------------------

        ;; ---------------------------------------------------------------------
        ;; buildCat
        ;; ---------------------------------------------------------------------
        ;; PRE: IX contains fuPNUpdatesBase
        ;;      DE contains catNBgCache
        ;;      HL contains catNSprites
        ;;      N = 1 or 2
        ;; POST: catCanvas contains tile data suitable for drawRectangle
renderFrameBuildCat:
        push de
        ld a, (IX + renderPNUpdatesNewPose)
        and catPoseFaceLeft
        jp nz, renderFrameBuildCatFacingLeft
        ;; If we're here, cat facing right

        ld de, catOneWalkRight - catOneSprites ; de contains offset of right
        ;; right-facing sprites
        add hl, de              ; hl points to beginning of right-facing sprites
renderFrameBuildCatFacingLeft:

        ld a, (IX + renderPNUpdatesNewPose)
        and catPoseAttackLow
        jp nz, renderFrameBuildCatAttackLow

        ld a, (IX + renderPNUpdatesNewPose)
        and catPoseAttack
        jp nz, renderFrameBuildCatAttack

        ld a, (IX + renderPNUpdatesNewPose)
        and catPoseJump
        jp nz, renderFrameBuildCatJump

        ld a, (IX + renderPNUpdatesNewPose)
        and catPoseWalk
        jp nz, renderFrameBuildCatWalk

        jp renderFrameBuildCatStand

renderFrameBuildCatAttackLow:
        ld de, catOneAttackLowLeft - catOneSprites + 24
        add hl, de
        jp renderFrameBuildCatPoseSet
renderFrameBuildCatAttack:
        ld de, catOneAttackHighLeft - catOneSprites + 24
        add hl, de
        jp renderFrameBuildCatPoseSet
renderFrameBuildCatJump:
        ld de, catOneJumpLeft - catOneSprites + 24
        add hl, de
        jp renderFrameBuildCatPoseSet
renderFrameBuildCatWalk:
        ld de, catOneWalkLeft - catOneSprites + 24
        add hl, de
        jp renderFrameBuildCatPoseSet
renderFrameBuildCatStand:
        ld de, catOneStandLeft - catOneSprites + 24
        add hl, de

renderFrameBuildCatPoseSet:
        ;; At this point, HL points to the beginning of the sprite sequence
        ;; of the correct pose

        ld a, (IX + renderPNUpdatesNewPosX)
        and %0000$0100          ; posX can be X0 or X4

        jp z, renderFrameBuildCatSelectY ; if a == 0, then hl is on correct idx

        ;; Otherwise a must equal 4. After all, it's not like anybody
        ;; ever violated an invariant! That'd be madness!
        ld de, 9 * 8
        add hl, de

renderFrameBuildCatSelectY:
        ;; HL points to correct sprite in sequence

        ld a, (IX + renderPNUpdatesNewPosY)
        and %0000$0111

        ld bc, 0
        ld c, a
        ld a, %0000$1000
        sub c
        ld c, a
        add hl, bc              ; hl now points to correct sprite



        ;; top left
        push hl
        ld de, catCanvas
        ld bc, 8
        ldir
        pop hl

        ;; middle left
        push hl
        ld bc, 24
        add hl, bc
        ld bc, 8
        ldir
        pop hl

        ;; bottom left
        push hl
        ld bc, 48
        add hl, bc
        ld bc, 8
        ldir
        pop hl

        ;; top center
        push hl
        ld bc, 8
        add hl, bc
        ld bc, 8
        ldir
        pop hl

        ;; middle center
        push hl
        ld bc, 24 + 8
        add hl, bc
        ld bc, 8
        ldir
        pop hl

        ;; bottom center

        push hl
        ld bc, 48 + 8
        add hl, bc
        ld bc, 8
        ldir
        pop hl

        ;; top right
        push hl
        ld bc, 16
        add hl, bc
        ld bc, 8
        ldir
        pop hl

        ;; middle right
        push hl
        ld bc, 24 + 16
        add hl, bc
        ld bc, 8
        ldir
        pop hl

        ;; bottom right

        push hl
        ld bc, 48 + 16
        add hl, bc
        ld bc, 8
        ldir
        pop hl

        ;; prepare to copy data
        ld b, 8 * 9
        pop de
        ld IY, catCanvas
renderFrameBuildCatOrBGLoop:
        ld c, (IY)
        ld a, (DE)
        or c

        ld (IY), a
        inc hl
        inc de
        inc iy
        djnz renderFrameBuildCatOrBGLoop

        ret


        ;; ---------------------------------------------------------------------
        ;; buildCatHand
        ;; ---------------------------------------------------------------------
        ;; PRE: IX contains fuPNUpdatesBase
        ;;      DE contains catNBgCache
        ;;      HL contains catNSprites
        ;;      N = 1 or 2
        ;; POST: catCanvas contains tile data suitable for drawRectangle
renderFrameBuildCatHand:
        ld a, (IX + renderPNUpdatesNewPose)
        and catPoseAttack | catPoseAttackLow
        jp nz, renderFrameBuildCatHandIsAttackPose
        ;; If we're here, then we're not attacking. Just draw bg cache

        ld h, d
        ld l, e
        ld de, catHandCanvas
        ld bc, 8 * 4
        ldir
        ret

renderFrameBuildCatHandIsAttackPose:
        push de

        ;; all cat hands are the same
        ld hl, catHandSprite + 16

        ;; At this point, HL points to the beginning of the sprite sequence
        ;; of the correct pose

        ld a, (IX + renderPNUpdatesNewPosX)
        and %0000$0100          ; posX can be X0 or X4

        jp z, renderFrameBuildCatHandSelectY ; if a == 0, then hl is on correct idx

        ;; Otherwise a must equal 4. After all, it's not like anybody
        ;; ever violated an invariant! That'd be madness!
        ld de, 4 * 8
        add hl, de

renderFrameBuildCatHandSelectY:
        ;; HL points to correct sprite in sequence

        ld a, (IX + renderPNUpdatesNewPosY)
        and %0000$0111

        ld bc, 0
        ld c, a
        ld a, %0000$1000
        sub c
        ld c, a
        add hl, bc              ; hl now points to correct sprite

        ;; top left
        push hl
        ld de, catHandCanvas
        ld bc, 8
        ldir
        pop hl

        ;; top right
        push hl
        ld bc, 16
        add hl, bc
        ld bc, 8
        ldir
        pop hl

        ;; bottom left
        push hl
        ld bc, 8
        add hl, bc
        ld bc, 8
        ldir
        pop hl

        ;; bottom right
        push hl
        ld bc, 24
        add hl, bc
        ld bc, 8
        ldir
        pop hl

        ;; prepare to copy data
        ld b, 8 * 4
        pop de
        ld IY, catHandCanvas
renderFrameBuildCatHandOrBGLoop:
        ld c, (IY)
        ld a, (DE)
        or c

        ld (IY), a
        inc hl
        inc de
        inc iy
        djnz renderFrameBuildCatHandOrBGLoop

        ret


        ;; ---------------------------------------------------------------------
        ;; buildMouse
        ;; ---------------------------------------------------------------------
        ;; POST: mouseCanvas contains tile data suitable for drawRectangle
renderFrameBuildMouse:
        ld hl, mouseWalkLeft + 8
        ld a, (mouseUpdatesDirection)
        cp 3                    ; 3 is left
        jp nz, renderFrameBuildMouseFacingLeft
        ;; If we're here, mouse facing right

        ld hl, mouseWalkRight + 8 ; hl contains right
renderFrameBuildMouseFacingLeft:

        ld a, (mouseActive)
        cp 0
        jp nz, renderFrameBuildMousePoseSet
        ;; If we're here, then the mouse is not active. Just draw the bg cache
        ld hl, mouseBgCache
        ld de, mouseCanvas
        ld bc, 8 * 3
        ldir
        ret

renderFrameBuildMousePoseSet:
        ;; At this point, HL points to the beginning of the sprite sequence
        ;; of the correct pose

        ld a, (mouseUpdatesNewPosX)
        and %0000$0100          ; posX can be X0 or X4

        jp z, renderFrameBuildMouseSelectY ; if a == 0, then hl is on correct idx

        ;; Otherwise a must equal 4. After all, it's not like anybody
        ;; ever violated an invariant! That'd be madness!
        ld de, 3 * 8
        add hl, de

renderFrameBuildMouseSelectY:
        ;; HL points to correct sprite in sequence

        ;; Y = 0. Deal with it

        push hl
        ld de, mouseCanvas
        ld bc, 8 * 3
        ldir
        pop hl

renderFrameBuildMouseOrBGLoopPre:
        ;; prepare to copy data
        ld b, 3 * 9
        ld IY, mouseCanvas
        ld de, mouseBgCache
renderFrameBuildMouseOrBGLoop:
        ld c, (IY)
        ld a, (DE)
        or c

        ld (IY), a
        inc hl
        inc de
        inc iy
        djnz renderFrameBuildMouseOrBGLoop

        ret

renderFrameSwapBuffers:
	ld b, 0 ; b contains y offset
	ld c, 0 ; c contains x offset
	jp renderFrameSwapBuffersTileLoopFirst
renderFrameSwapBuffersTileLoop:
	inc b ; b contains y + 1
	ld c, 0 ; c contains x = 0
renderFrameSwapBuffersTileLoopFirst:
	push bc
	call renderFrameTileAddress

	;; de contains address into front buffer
	ld h, d
	ld l, e

	ld bc, secondFramebufferLogicalOffset
	add hl, bc
	ld a, 8

	; hl contains back buffer row
	; de contains front buffer row
	jp renderFrameSwapBuffersInnerLoopFirst

renderFrameSwapBuffersInnerLoop:
	pop de
	pop hl
	inc h
	inc d

renderFrameSwapBuffersInnerLoopFirst:
	push hl
	push de
	ld bc, 32

	; hl contains current pixel row of back buffer
	; de contains current pixel row of front buffer
	; bc contains 32

	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi

	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi

	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi

	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi

	dec a
	cp 0
	jp nz, renderFrameSwapBuffersInnerLoop
	; todo: back jump

	pop de
	pop hl
	pop bc

	ld a, b
	cp 23
	jp nz, renderFrameSwapBuffersTileLoop
	ret

;renderFrameSwapBuffers:
;
;        ;; TODO: massive 7000 line fast transfer function
;        ;;  https://chuntey.wordpress.com/tag/double-buffering/;
;
;        ld de, $4000             ; front buffer address
;        ld hl, secondFramebuffer ; back buffer address
;        ld bc, 32 * 24 * 8
;renderFrameSwapBuffersCopyLoop:
;        ;; try not to throw up
;        ;; 128 ldi's
;        ldi
;        ldi
;        ldi
;        ldi
;        ldi
;        ldi
;        ldi
;        ldi

;        ldi
;        ldi
;        ldi
;        ldi
;        ldi
;        ldi
;        ldi
;        ldi
;
;        ldi
;        ldi
;        ldi
;        ldi
;        ldi
;        ldi
;        ldi
;        ldi
;
;        ldi
;        ldi
;        ldi
;        ldi
;        ldi
;        ldi
;        ldi
;        ldi
;
;        ldi
;        ldi
;        ldi
;        ldi
;        ldi
;        ldi
;        ldi
;        ldi
;
;        ldi
;        ldi
;        ldi
;        ldi
;        ldi
;        ldi
;        ldi
;        ldi
;
;        ldi
;        ldi
;        ldi
;        ldi
;        ldi
;        ldi
;        ldi
;        ldi
;
;        ldi
;        ldi
;        ldi
;        ldi
;        ldi
;        ldi
;        ldi
;        ldi
;
;        ldi
;        ldi
;        ldi
;        ldi
;        ldi
;        ldi
;        ldi
;        ldi
;
;        ldi
;        ldi
;        ldi
;        ldi
;        ldi
;        ldi
;        ldi
;        ldi
;
;        ldi
;        ldi
;        ldi
;        ldi
;        ldi
;        ldi
;        ldi
;        ldi
;
;        ldi
;        ldi
;        ldi
;        ldi
;        ldi
;        ldi
;        ldi
;        ldi
;
;        ldi
;        ldi
;        ldi
;        ldi
;        ldi
;        ldi
;        ldi
;        ldi
;
;        ldi
;        ldi
;        ldi
;        ldi
;        ldi
;        ldi
;        ldi
;        ldi
;
;        ldi
;        ldi
;        ldi
;        ldi
;        ldi
;        ldi
;        ldi
;        ldi
;
;        ldi
;        ldi
;        ldi
;        ldi
;        ldi
;        ldi
;        ldi
;        ldi
;
;        ld a, b
;        or c
;        ;jp nz, renderFrameSwapBuffersCopyLoop
;        ret


;;; ----------------------------------------------------------------------------
;;; Misc utility stuff
;;; ----------------------------------------------------------------------------


        ;; ---------------------------------------------------------------------
        ;; handPos
        ;; Pre: c contains cat pos X
        ;;      b contains cat pos Y
        ;;      d contains cat pose
        ;;      Cat must be in an attack pose (will return a value even if
        ;;         it isn't)
        ;; Post: c contains hand tile pos X
        ;;       b contains hand tile pos Y
        ;; ---------------------------------------------------------------------
renderFrameHandPos:
        ld a, d
        and catPoseFaceLeft
        jp nz, renderFrameHandPosLeft
        ;; If we're here, cat is facing right
        ld a, c
        inc a
        inc a
        add a, levelLeftmostCol
        ld c, a
        jp renderFrameHandPosLeftRightEnd
renderFrameHandPosLeft:
        ld a, c
        dec a
        add a, levelLeftmostCol
        ld c, a
        ;; If we're here, cat is facing left
renderFrameHandPosLeftRightEnd:
        ld a, d
        and catPoseAttackLow
        jp nz, renderFrameIsLowPunch
        ;; If we're here, then it is not a low punch
        ld a, b
        jp renderFramePunchHeightEnd
renderFrameIsLowPunch:
        ld a, b
        inc a
renderFramePunchHeightEnd:
        ;; a contains Y value
        add a, levelTopmostRow
        ld b, a
        ret

;;; ----------------------------------------------------------------------------
;;; Status bar
;;; ----------------------------------------------------------------------------

statusBarTextAttr:      equ 0

statusBarCapitalP:      equ $3E80
statusBarL:             equ $3F60
statusBarA:             equ $3F08
statusBarY:             equ $3FC8
statusBarE:             equ $3F28
statusBarR:             equ $3F90

statusBarZero:          equ $3D80
statusBarOne:           equ statusBarZero + 8 * 1
statusBarTwo:           equ statusBarZero + 8 * 2
statusBarThree:         equ statusBarZero + 8 * 3
statusBarFour:          equ statusBarZero + 8 * 4
statusBarFive:          equ statusBarZero + 8 * 5
statusBarSix:           equ statusBarZero + 8 * 6
statusBarSeven:         equ statusBarZero + 8 * 7
statusBarEight:         equ statusBarZero + 8 * 8
statusBarNine:          equ statusBarZero + 8 * 9

mouseStretched: defb $00, $00, $FF, $00, $00, $00, $FF, $00

statusBarSetup:
        ld de, secondFramebufferLogicalOffset
        ld c, 1
        ld b, 0
        ld ix, p1StateBase
        call statusBarUpdateScore

        inc c
        inc c

        ld hl, CAT_CLAW
        call renderFrameWriteTilePixels

        inc c
        inc c

        ld hl, CAT_RIGHT_UPPERBODY_PLAYER_1
        call renderFrameWriteTilePixels

        inc c
        ld hl, CAT_RIGHT_UPPERBODY_PLAYER_1 + 8
        call renderFrameWriteTilePixels

        inc c
        inc c

        ld hl, CAT_CLAW
        call renderFrameWriteTilePixels

        ld c, 31
        ld b, 0
        ld hl, MOUSE_RIGHT_ONE + 8
        call renderFrameWriteTilePixels

        ld a, 1
        call statusBarUpdateInterest

        ;; cat 2
        ld c, 0
        ld b, 1
        ld hl, MOUSE_LEFT_ONE
        call renderFrameWriteTilePixels

        ld a, 2
        call statusBarUpdateInterest


        ld c, 19

        ld hl, CAT_CLAW
        call renderFrameWriteTilePixels

        inc c
        inc c

        ld hl, CAT_LEFT_UPPERBODY_PLAYER_2
        call renderFrameWriteTilePixels

        inc c
        ld hl, CAT_LEFT_UPPERBODY_PLAYER_2 + 8
        call renderFrameWriteTilePixels

        inc c
        inc c

        ld hl, CAT_CLAW
        call renderFrameWriteTilePixels

        inc c
        inc c

        ld ix, p2StateBase
        call statusBarUpdateScore

        ret

        ;; PRE a contains 1 or 2 for player 1 or player 2
statusBarUpdateInterest:
        push de
        cp 2
        jp z, statusBarUpdateInterestPlayer2
statusBarUpdateInterestPlayer1:
        ld c, 30
        ld b, 0
        ld a, (p1Interest)                 ;TODO: (p1Interest)
        ld d, a
        ld e, 0
        ld hl, mouseStretched
        ld a, d
        cp 0
        jp z, statusBarUpdateInterestPlayer1LoopEnd
statusBarUpdateInterestPlayer1Loop:
        push de
        ld de, secondFramebufferLogicalOffset
        ld hl, mouseStretched
        call renderFrameWriteTilePixels
        pop de

        dec c
        inc e
        ld a, e
        cp d
        jp nz, statusBarUpdateInterestPlayer1Loop
statusBarUpdateInterestPlayer1LoopEnd:
        ld de, secondFramebufferLogicalOffset
        ld hl, MOUSE_RIGHT_ONE
        call renderFrameWriteTilePixels


        dec c
        ld hl, zeroTile
        call renderFrameWriteTilePixels

        pop de
        ret
statusBarUpdateInterestPlayer2:
        ld c, 1
        ld b, 1
        ld a, (p2Interest)                 ; TODO: (p2Interest)
        ld d, a
        ld e, 0
        ld hl, mouseStretched
        ld a, d
        cp 0
        jp z, statusBarUpdateInterestPlayer2LoopEnd
statusBarUpdateInterestPlayer2Loop:
        push de
        ld de, secondFramebufferLogicalOffset
        ld hl, mouseStretched
        call renderFrameWriteTilePixels
        pop de

        inc c
        inc e
        ld a, e
        cp d
        jp nz, statusBarUpdateInterestPlayer2Loop

statusBarUpdateInterestPlayer2LoopEnd:
        ld de, secondFramebufferLogicalOffset
        ld hl, MOUSE_LEFT_ONE + 8
        call renderFrameWriteTilePixels

        inc c
        ld hl, zeroTile
        call renderFrameWriteTilePixels

        pop de
        ret

        ;; PRE: IX contains pNStateBase
        ;;      c contains x of first digit
        ;;      b contains y of first digit
statusBarUpdateScore:
        push ix
        push bc
        ld b, 1
        call logicDigitNumVal
        pop bc
        call renderFrameWriteTilePixels
        pop ix

        inc c

        push ix
        push bc
        ld b, 2
        call logicDigitNumVal
        pop bc
        call renderFrameWriteTilePixels
        pop ix

        inc c

        push ix
        push bc
        ld b, 3
        call logicDigitNumVal
        pop bc
        call renderFrameWriteTilePixels
        pop ix

        inc c

        push ix
        push bc
        ld b, 4
        call logicDigitNumVal
        pop bc
        call renderFrameWriteTilePixels
        pop ix

        inc c

        push ix
        push bc
        ld b, 5
        call logicDigitNumVal
        pop bc
        call renderFrameWriteTilePixels
        pop ix

        ret
