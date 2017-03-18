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
catOneBgCache: equ $E1B0

catOneHandLeft: equ $E1F8
catOneHandLowLeft: equ $E248
catOneHandRight: equ $E298
catOneHandLowRight: equ $E2E8
catOneHandBgCache: equ $E338

;;; Cat 2
catTwoSprites: equ $E358

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

catTwoHandLeft: equ catTwoSprites + catOneHandLeft - catOneSprites
catTwoHandLowLeft: equ catTwoSprites + catOneHandLowLeft - catOneSprites
catTwoHandRight: equ catTwoSprites + catOneHandRight - catOneSprites
catTwoHandLowRight: equ catTwoSprites + catOneHandLowRight - catOneSprites
catTwoHandBgCache: equ catTwoSprites + catOneHandBgCache - catOneSprites

;;; Mouse
mouseSprites: equ $EB90
mouseWalkLeft: equ $EB90
mouseWalkRight: equ $EBC8
mouseBgCache: equ $EC00

;;; Canvi
catCanvas: equ $D800
catHandCanvas: equ $D848
mouseCanvas: equ $D868

secondFramebuffer: equ $C000

;;; What to add to a pointer returned by renderFrameTileAddress to get an
;;; address into the second framebuffer
secondFramebufferLogicalOffset: equ secondFramebuffer - $4000

setupRenderer:
        ;; get the contents of the front buffer


        ld de, secondFramebuffer
        ld hl, $4000
        ld bc, 32 * 24 * 8
        ldir

        call renderPrecomputeSprites

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

        ret

renderFrame:
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

        ;;  calculate new tile positions
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

        call renderFrameSwapBuffers

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




        ;; Some random blocks, used for testing
cat1SpritesBase:
cat1SpritesWalk:
        defb $DE, $AD, $BE, $EF, $DE, $AD, $BE, $EF
        defb $DE, $AD, $BE, $EF, $DE, $AD, $BE, $EF
        defb $DE, $AD, $BE, $EF, $DE, $AD, $BE, $EF
        defb $DE, $AD, $BE, $EF, $DE, $AD, $BE, $EF
cat1SpritesJump:
        defb $DE, $AD, $BE, $EF, $DE, $AD, $BE, $EF
        defb $DE, $AD, $BE, $EF, $DE, $AD, $BE, $EF
        defb $DE, $AD, $BE, $EF, $DE, $AD, $BE, $EF
        defb $DE, $AD, $BE, $EF, $DE, $AD, $BE, $EF
cat1SpritesAttackHigh:
        defb $DE, $AD, $BE, $EF, $DE, $AD, $BE, $EF
        defb $DE, $AD, $BE, $EF, $DE, $AD, $BE, $EF
        defb $DE, $AD, $BE, $EF, $DE, $AD, $BE, $EF
        defb $DE, $AD, $BE, $EF, $DE, $AD, $BE, $EF
cat1SpritesAttackLow:
        defb $DE, $AD, $BE, $EF, $DE, $AD, $BE, $EF
        defb $DE, $AD, $BE, $EF, $DE, $AD, $BE, $EF
        defb $DE, $AD, $BE, $EF, $DE, $AD, $BE, $EF
        defb $DE, $AD, $BE, $EF, $DE, $AD, $BE, $EF
cat1SpritesHand:
        defb $DE, $AD, $BE, $EF, $DE, $AD, $BE, $EF

cat2SpritesBase:
cat2SpritesWalk:
        defb $EF, $BE, $AD, $DE, $EF, $BE, $AD, $DE
        defb $EF, $BE, $AD, $DE, $EF, $BE, $AD, $DE
        defb $EF, $BE, $AD, $DE, $EF, $BE, $AD, $DE
        defb $EF, $BE, $AD, $DE, $EF, $BE, $AD, $DE
cat2SpritesJump:
        defb $EF, $BE, $AD, $DE, $EF, $BE, $AD, $DE
        defb $EF, $BE, $AD, $DE, $EF, $BE, $AD, $DE
        defb $EF, $BE, $AD, $DE, $EF, $BE, $AD, $DE
        defb $EF, $BE, $AD, $DE, $EF, $BE, $AD, $DE
cat2SpritesAttackHigh:
        defb $EF, $BE, $AD, $DE, $EF, $BE, $AD, $DE
        defb $EF, $BE, $AD, $DE, $EF, $BE, $AD, $DE
        defb $EF, $BE, $AD, $DE, $EF, $BE, $AD, $DE
        defb $EF, $BE, $AD, $DE, $EF, $BE, $AD, $DE
cat2SpritesAttackLow:
        defb $EF, $BE, $AD, $DE, $EF, $BE, $AD, $DE
        defb $EF, $BE, $AD, $DE, $EF, $BE, $AD, $DE
        defb $EF, $BE, $AD, $DE, $EF, $BE, $AD, $DE
        defb $EF, $BE, $AD, $DE, $EF, $BE, $AD, $DE
cat2SpritesHand:
        defb $EF, $BE, $AD, $DE, $EF, $BE, $AD, $DE

mouseSpritesBase:
renderTempMouse:
        defb $C0, $FF, $EE, $EE, $C0, $FF, $EE, $EE
        defb $C0, $FF, $EE, $EE, $C0, $FF, $EE, $EE

        ;; ---------------------------------------------------------------------
        ;; precomputeSprites
        ;; ---------------------------------------------------------------------
        ;; POST: Sprite layout lookup table populated
renderPrecomputeSprites:
        ld b, renderCatMouseNumShifts
        ld ix, 24
        jp renderPrecomputeSpritesCatCopyLoopFirstIter
renderPrecomputeSpritesCatCopyLoop:
        ld de, 9 * 8
        add ix, de
renderPrecomputeSpritesCatCopyLoopFirstIter:
        push bc
        ;; Stand
        ld de, catOneStandLeft
        ld hl, CAT_LEFT_STANDING
        call renderPrecomputeCopyCatSprite

        ld de, catOneStandRight
        ld hl, CAT_RIGHT_STANDING
        call renderPrecomputeCopyCatSprite

        ld de, catTwoStandLeft
        ld hl, CAT_LEFT_STANDING
        call renderPrecomputeCopyCatSprite

        ld de, catTwoStandRight
        ld hl, CAT_RIGHT_STANDING
        call renderPrecomputeCopyCatSprite

        ;; Jump
        ld de, catOneJumpLeft
        ld hl, CAT_LEFT_OUTWARD_STEP_OR_JUMP
        call renderPrecomputeCopyCatSprite

        ld de, catOneJumpRight
        ld hl, CAT_RIGHT_OUTWARD_STEP_OR_JUMP
        call renderPrecomputeCopyCatSprite

        ld de, catTwoJumpLeft
        ld hl, CAT_LEFT_OUTWARD_STEP_OR_JUMP
        call renderPrecomputeCopyCatSprite

        ld de, catTwoJumpRight
        ld hl, CAT_RIGHT_OUTWARD_STEP_OR_JUMP
        call renderPrecomputeCopyCatSprite

        ;; Attack High
        ld de, catOneAttackHighLeft
        ld hl, CAT_LEFT_HIGH_STRIKE
        call renderPrecomputeCopyCatSprite

        ld de, catOneAttackHighRight
        ld hl, CAT_RIGHT_HIGH_STRIKE
        call renderPrecomputeCopyCatSprite

        ld de, catTwoAttackHighLeft
        ld hl, CAT_LEFT_HIGH_STRIKE
        call renderPrecomputeCopyCatSprite

        ld de, catTwoAttackHighRight
        ld hl, CAT_RIGHT_HIGH_STRIKE
        call renderPrecomputeCopyCatSprite

        ;; Attack Low
        ld de, catOneAttackLowLeft
        ld hl, CAT_LEFT_LOW_STRIKE
        call renderPrecomputeCopyCatSprite

        ld de, catOneAttackLowRight
        ld hl, CAT_RIGHT_LOW_STRIKE
        call renderPrecomputeCopyCatSprite

        ld de, catTwoAttackLowLeft
        ld hl, CAT_LEFT_LOW_STRIKE
        call renderPrecomputeCopyCatSprite

        ld de, catTwoAttackLowRight
        ld hl, CAT_RIGHT_LOW_STRIKE
        call renderPrecomputeCopyCatSprite

        pop bc
        dec b

        jp nz, renderPrecomputeSpritesCatCopyLoop

        ;; Load special case walking sprites

        ld ix, 24
        ld de, catOneWalkLeft
        ld hl, CAT_LEFT_NEUTRAL_STEP
        call renderPrecomputeCopyCatSprite

        ld de, catOneWalkRight
        ld hl, CAT_RIGHT_NEUTRAL_STEP
        call renderPrecomputeCopyCatSprite

        ld de, catTwoWalkLeft
        ld hl, CAT_LEFT_NEUTRAL_STEP
        call renderPrecomputeCopyCatSprite

        ld de, catTwoWalkRight
        ld hl, CAT_LEFT_NEUTRAL_STEP
        call renderPrecomputeCopyCatSprite

        ld ix, 24 + (9 * 8)
        ld de, catOneWalkLeft
        ld hl, CAT_LEFT_INWARD_STEP
        call renderPrecomputeCopyCatSprite

        ld de, catOneWalkRight
        ld hl, CAT_RIGHT_INWARD_STEP
        call renderPrecomputeCopyCatSprite

        ld de, catTwoWalkLeft
        ld hl, CAT_LEFT_INWARD_STEP
        call renderPrecomputeCopyCatSprite

        ld de, catTwoWalkRight
        ld hl, CAT_LEFT_INWARD_STEP
        call renderPrecomputeCopyCatSprite

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

        ld hl, CAT_LEFT_HIGH_STRIKE
        ld de, catOneHandLeft
        call renderPrecomputeCopyCatHandSprite

        ld hl, CAT_LEFT_HIGH_STRIKE
        ld de, catTwoHandLeft
        call renderPrecomputeCopyCatHandSprite

        ld hl, CAT_LEFT_LOW_STRIKE + (8 * 3)
        ld de, catOneHandLowLeft
        call renderPrecomputeCopyCatHandSprite

        ld hl, CAT_LEFT_LOW_STRIKE + (8 * 3)
        ld de, catTwoHandLowLeft
        call renderPrecomputeCopyCatHandSprite

        ld hl, CAT_RIGHT_HIGH_STRIKE + (8 * 2)
        ld de, catOneHandRight
        call renderPrecomputeCopyCatHandSprite

        ld hl, CAT_RIGHT_HIGH_STRIKE + (8 * 2)
        ld de, catTwoHandRight
        call renderPrecomputeCopyCatHandSprite

        ld hl, CAT_RIGHT_LOW_STRIKE + (8 * 3) + (8 * 2)
        ld de, catOneHandLowRight
        call renderPrecomputeCopyCatHandSprite

        ld hl, CAT_RIGHT_LOW_STRIKE + (8 * 3) + (8 * 2)
        ld de, catTwoHandLowRight
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
        ld hl, MOUSE_LEFT_ONE
        call renderPrecomputeCopyMouseSprite

        ld de, mouseWalkRight
        ld hl, MOUSE_RIGHT_ONE
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


        ld ix, catOneHandLeft
        add ix, de
        call renderPrecomputeShiftCatHandSprite

        ld ix, catOneHandRight
        add ix, de
        call renderPrecomputeShiftCatHandSprite

        ld ix, catOneHandLowLeft
        add ix, de
        call renderPrecomputeShiftCatHandSprite

        ld ix, catOneHandLowRight
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

        ;; TODO: mice

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

        ld bc, 16
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

        ;; top left
        ;; push hl
        ;; ld de, mouseCanvas
        ;; ld bc, 8
        ;; ldir
        ;; pop hl

        ;; ;; top center
        ;; push hl
        ;; ld bc, 8
        ;; add hl, bc
        ;; ld bc, 8
        ;; ldir
        ;; pop hl

        ;; ;; top right
        ;; push hl
        ;; ld bc, 16
        ;; add hl, bc
        ;; ld bc, 8
        ;; ldir
        ;; pop hl

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

        ;; TODO: massive 7000 line fast transfer function
        ;;  https://chuntey.wordpress.com/tag/double-buffering/

        ld de, $4000             ; front buffer address
        ld hl, secondFramebuffer ; back buffer address
        ld bc, 32 * 24 * 8
renderFrameSwapBuffersCopyLoop:
        ;; try not to throw up
        ;; 128 ldi's
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

        ld a, b
        or c
        jp nz, renderFrameSwapBuffersCopyLoop
        ret

renderFrameSwapBuffersStackPtr: defw 0

        ;; ---------------------------------------------------------------------
        ;; transferCat
        ;; ---------------------------------------------------------------------
        ;; PRE: c contains x offset
        ;;      b contains y offset
        ;; INVARIANT: interrupts disabled during transfer. Any iterrupt that
        ;;            fires will be lost
        ;; POST: specified 4x3 region of back buffer transferred to front buffer
renderFrameTransferCat:
        di                      ; Disable interrupts during transfer
        dec b

        call renderFrameTransferCatRow

        inc b
        call renderFrameTransferCatRow

        inc b
        call renderFrameTransferCatRow

        ei                                   ; Re-enable interrupts
        ret

        ;; ---------------------------------------------------------------------
        ;; transferCatRow
        ;; ---------------------------------------------------------------------
        ;; PRE: c contains x offset
        ;;      b contains y offset
        ;;      interrupts are disabled
        ;; POST: specified 6x1 region of back buffer transferred to front buffer
renderFrameTransferCatRow:
        push bc
        call renderFrameTileAddress
        ex de, hl
        push hl
        ld de, 6
        add hl, de
        ld (renderFrameTransferDestLastColumn), hl
        ;; transferDestLastColumn contains pointer to the first pixel row of
        ;; the top right tile of the front buffer

        pop hl
        ld de, secondFramebufferLogicalOffset
        add hl, de
        ld (renderFrameTransferSourceFirstColumn), hl
        ;; transferSourceFirstColumn contains pointer to the first pixel row of
        ;; the top left tile of the back buffer

        ld (renderFrameTransferStackPtr), sp ; save the stack pointer
        ;; pixel row 0


        ld sp, (renderFrameTransferSourceFirstColumn)
        pop af
        pop bc
        pop de

        ld sp, (renderFrameTransferDestLastColumn)
        push de
        push bc
        push af

        ;; pixel row 1

        ld ix, (renderFrameTransferSourceFirstColumn)
        ld de, 255
        add ix, de
        ld sp, ix

        pop af
        pop bc
        pop hl

        ld ix, (renderFrameTransferDestLastColumn)
        ld de, 255
        add ix, de
        ld sp, ix

        push hl
        push bc
        push af

        ;; pixel row 2

        ld ix, (renderFrameTransferSourceFirstColumn)
        ld de, 511
        add ix, de
        ld sp, ix

        pop af
        pop bc
        pop hl

        ld ix, (renderFrameTransferDestLastColumn)
        ld de, 511
        add ix, de
        ld sp, ix

        push hl
        push bc
        push af

        ;; pixel row 3

        ld ix, (renderFrameTransferSourceFirstColumn)
        ld de, 767
        add ix, de
        ld sp, ix

        pop af
        pop bc
        pop hl

        ld ix, (renderFrameTransferDestLastColumn)
        ld de, 767
        add ix, de
        ld sp, ix

        push hl
        push bc
        push af

        ;; pixel row 4

        ld ix, (renderFrameTransferSourceFirstColumn)
        ld de, 1023
        add ix, de
        ld sp, ix

        pop af
        pop bc
        pop hl

        ld ix, (renderFrameTransferDestLastColumn)
        ld de, 1023
        add ix, de
        ld sp, ix

        push hl
        push bc
        push af

        ;; pixel row 5

        ld ix, (renderFrameTransferSourceFirstColumn)
        ld de, 1279
        add ix, de
        ld sp, ix

        pop af
        pop bc
        pop hl

        ld ix, (renderFrameTransferDestLastColumn)
        ld de, 1279
        add ix, de
        ld sp, ix

        push hl
        push bc
        push af

        ;; pixel row 6

        ld ix, (renderFrameTransferSourceFirstColumn)
        ld de, 1535
        add ix, de
        ld sp, ix

        pop af
        pop bc
        pop hl

        ld ix, (renderFrameTransferDestLastColumn)
        ld de, 1535
        add ix, de
        ld sp, ix

        push hl
        push bc
        push af

        ;; pixel row 7

        ld ix, (renderFrameTransferSourceFirstColumn)
        ld de, 1791
        add ix, de
        ld sp, ix

        pop af
        pop bc
        pop hl

        ld ix, (renderFrameTransferDestLastColumn)
        ld de, 1791
        add ix, de
        ld sp, ix

        push hl
        push bc
        push af

        ld sp, (renderFrameTransferStackPtr) ; restore the stack pointer
        pop bc
        ret
