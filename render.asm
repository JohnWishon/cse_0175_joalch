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

renderCatMouseNumShifts:  equ 4
renderCatMouseNumFacings: equ 2

renderBuffersBegin:
catOneSprites: equ $C000
catOneWalkLeft: equ $C000
catOneJumpLeft: equ $C138
catOneAttackHighLeft: equ $C270
catOneAttackLowLeft: equ $C3A8
catOneWalkRight: equ $C4E0
catOneJumpRight: equ $C618
catOneAttackHighRight: equ $C750
catOneAttackLowRight: equ $C888
catOneHandLeft: equ $C9C0
catOneHandRight: equ $CA50
catOneBgCache: equ $CAE0

catTwoSprites:
catTwoWalkLeft: equ $CB40
catTwoJumpLeft: equ $CC78
catTwoAttackHighLeft: equ $CDB0
catTwoAttackLowLeft: equ $CEE8
catTwoWalkRight: equ $D020
catTwoJumpRight: equ $D158
catTwoAttackHighRight: equ $D290
catTwoAttackLowRight: equ $D3C8
catTwoHandLeft: equ $D500
catTwoHandRight: equ $D590
catTwoBgCache: equ $D620

mouseSprites:
mouseWalkLeft: equ $D680
mouseWalkRight: equ $D6E8
mouseBgCache: equ $D750

catCanvas: equ $D768
mouseCanvas: equ $D7C8
renderBuffersEnd: equ $D7E0

setupRenderer:
        call renderPrecomputeSprites
        ret

renderFrame:
        ;; TODO: delete me
        ;; manual create an update for testing purposes


        ;; ld IX, fuP1UpdatesBase
        ;; ld (IX + renderPNUpdatesTileX), 0
        ;; ld (IX + renderPNUpdatesTileY), 0
        ;; ld (IX + renderPNUpdatesTilePtr), HIGH(cat1SpritesWalk)
        ;; ld (IX + renderPNUpdatesTilePtr + 1), LOW(cat1SpritesWalk)

        ;; ld IX, fuP2UpdatesBase
        ;; ld (IX + renderPNUpdatesTileX), 3
        ;; ld (IX + renderPNUpdatesTileY), 0
        ;; ld (IX + renderPNUpdatesTilePtr), HIGH(catOneWalkRight + (8 * 3))
        ;; ld (IX + renderPNUpdatesTilePtr + 1), LOW(catOneWalkRight   + (8 * 3))

        ;; ld a,2              ; 2 is the code for red.
        ;; out (254),a         ; write to port 254.

        ;; clear old sprites

        ;; erase mouse
        ;; ld hl, mouseBgCache
        ;; ld a, (mouseUpdatesOldTilePosX)
        ;; add a, levelLeftmostCol
        ;; ld c, a
        ;; ld a, (mouseUpdatesOldTilePosY)
        ;; add a, levelTopmostRow
        ;; ld b, a
        ;; ld e, 3
        ;; ld d, 1
        ;; call renderDrawRectangle

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
        call renderFrameWriteTile
renderFrameCat2NoTileUpdate:

        ;; draw new sprites

        ;; TODO: read area behind cat 1
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

        ;; TODO: populate catCanvas
        ld ix, fuP1UpdatesBase
        ld de, catOneBgCache
        ld hl, catOneSprites
        call renderFrameBuildCat

        ;; TODO: draw cat 1
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


        ;; TODO: read area behind cat 2
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

        ;; TODO: populate catCanvas
        ld ix, fuP2UpdatesBase
        ld de, catTwoBgCache
        ld hl, catTwoSprites
        call renderFrameBuildCat

        ;; TODO: draw cat 2
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

        ;; TODO: read area behind mouse
        ;; ld hl, mouseBgCache
        ;; ld a, (mouseUpdatesNewTilePosX)
        ;; add a, levelLeftmostCol
        ;; ld c, a
        ;; ld a, (mouseUpdatesNewTilePosY)
        ;; add a, levelTopmostRow
        ;; ld b, a
        ;; ld e, 3
        ;; ld d, 1
        ;; call renderReadRectangle

        ;; ;; TODO: draw mice

        ;; ;; TODO: draw mouse
        ;; ld hl, mouseCanvas
        ;; ld a, (mouseUpdatesNewTilePosX)
        ;; add a, levelLeftmostCol
        ;; ld c, a
        ;; ld a, (mouseUpdatesNewTilePosY)
        ;; add a, levelTopmostRow
        ;; ld b, a
        ;; ld e, 3
        ;; ld d, 1
        ;; call renderDrawRectangle

        ;; ld a,1              ; 1 is the code for blue.
        ;; out (254),a         ; write to port 254.
        ret

renderFrameCat:
        ;; first update tiles

        ld a, (IX + renderPNUpdatesTileX)
        add a, levelLeftmostCol
        ld c, a
        ld a, (IX + renderPNUpdatesTileY)
        add a, levelTopmostRow
        ld b, a
        ld h, (IX + renderPNUpdatesTilePtr)
        ld l, (IX + renderPNUpdatesTilePtr + 1)
        call renderFrameWriteTile


        ;; TODO: sprite stuff
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
        ;; TODO: real precomputation that depends on finalized binary sprite
        ;;       layout
        ;; POST: Sprite layout lookup table populated
renderPrecomputeSprites:
        ld b, renderCatMouseNumShifts
        ld ix, 24
        jp renderPrecomputeSpritesCopyLoopFirstIter
renderPrecomputeSpritesCopyLoop:
        ld de, 9 * 8
        add ix, de
renderPrecomputeSpritesCopyLoopFirstIter:
        push bc
        ;; Walk
        ld de, catOneWalkLeft
        ld hl, cat1SpritesWalk
        call renderPrecomputeCopyCatSprite

        ld de, catOneWalkRight
        ld hl, cat1SpritesWalk
        call renderPrecomputeCopyCatSprite

        ld de, catTwoWalkLeft
        ld hl, cat2SpritesWalk
        call renderPrecomputeCopyCatSprite

        ld de, catTwoWalkRight
        ld hl, cat2SpritesWalk
        call renderPrecomputeCopyCatSprite

        ;; Jump
        ld de, catOneJumpLeft
        ld hl, cat1SpritesJump
        call renderPrecomputeCopyCatSprite

        ld de, catOneJumpRight
        ld hl, cat1SpritesJump
        call renderPrecomputeCopyCatSprite

        ld de, catTwoJumpLeft
        ld hl, cat2SpritesJump
        call renderPrecomputeCopyCatSprite

        ld de, catTwoJumpRight
        ld hl, cat2SpritesJump
        call renderPrecomputeCopyCatSprite

        ;; Attack High
        ld de, catOneAttackHighLeft
        ld hl, cat1SpritesAttackHigh
        call renderPrecomputeCopyCatSprite

        ld de, catOneAttackHighRight
        ld hl, cat1SpritesAttackHigh
        call renderPrecomputeCopyCatSprite

        ld de, catTwoAttackHighLeft
        ld hl, cat2SpritesAttackHigh
        call renderPrecomputeCopyCatSprite

        ld de, catTwoAttackHighRight
        ld hl, cat2SpritesAttackHigh
        call renderPrecomputeCopyCatSprite

        ;; Attack Low
        ld de, catOneAttackLowLeft
        ld hl, cat1SpritesAttackLow
        call renderPrecomputeCopyCatSprite

        ld de, catOneAttackLowRight
        ld hl, cat1SpritesAttackLow
        call renderPrecomputeCopyCatSprite

        ld de, catTwoAttackLowLeft
        ld hl, cat2SpritesAttackLow
        call renderPrecomputeCopyCatSprite

        ld de, catTwoAttackLowRight
        ld hl, cat2SpritesAttackLow
        call renderPrecomputeCopyCatSprite

        pop bc
        dec b

        jp nz, renderPrecomputeSpritesCopyLoop
        ld b, 0
        ld hl, 24
renderPrecomputeSpritesShiftLoop:
        push bc
        ld bc, 9 * 8
        add hl, bc
        pop bc
        ld d, h
        ld e, l
        inc b
        inc b

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
        cp renderCatMouseNumShifts / 2
        jp z, renderPrecomputeSpritesShiftLoopEnd
        jp renderPrecomputeSpritesShiftLoop
renderPrecomputeSpritesShiftLoopEnd:


        ;; TODO: mice

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
        ;;      c contains x offset
        ;;      b contains y offset
        ;; POST: tile pixel data at screen position (x, y) written to (HL)
renderFrameReadTilePixels:
        call renderFrameTileAddress
        push bc
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
        ;;      c contains x offset
        ;;      b contains y offset
        ;; POST: tile pixel data written to screen at (x, y)
        ;; https://chuntey.wordpress.com/2013/09/08/how-to-write-zx-spectrum-games-chapter-9/
renderFrameWriteTilePixels:
        call renderFrameTileAddress ; DE contains pointer to top row of tile

        push bc
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
        and catPoseClimb
        jp nz, renderFrameBuildCatClimb

        jp renderFrameBuildCatWalk

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
renderFrameBuildCatClimb:
        ;; TODO
renderFrameBuildCatWalk:
        ld de, catOneWalkLeft - catOneSprites + 24
        add hl, de

renderFrameBuildCatPoseSet:
        ;; At this point, HL points to the beginning of the sprite sequence
        ;; of the correct pose

        ld a, (IX + renderPNUpdatesNewPosX)
        and %0000$0110          ; posX can be X0, X2, X4, or X6

        jp z, renderFrameBuildCatSelectY ; if a == 0, then hl is on correct idx

        srl a                    ; a contains 0, 1, 2, or 3
        ld b, a                 ; b contains 0 .. 4
renderFrameBuildCatSelectXLoop:
        ld de, 9 * 8
        add hl, de
        djnz renderFrameBuildCatSelectXLoop

renderFrameBuildCatSelectY:
        ;; HL points to correct sprite in sequence

        ld a, (IX + renderPNUpdatesNewPosY)
        and %0000$0111
        ld bc, 0
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
