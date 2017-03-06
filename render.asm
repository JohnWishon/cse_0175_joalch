renderPNUpdatesTileX:   equ 6
renderPNUpdatesTileY:   equ 7
renderPNUpdatesTilePtr: equ 8

renderWriteTileX: equ 0
renderWriteTileY: equ 1
renderWriteTilePtr: equ 2

renderCatMouseNumShifts:  equ 4
renderCatMouseNumFacings: equ 2

renderBuffersBegin:
catOneSprites:
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

catTwoSprites:
catTwoWalkLeft: equ $CAE0
catTwoJumpLeft: equ $CC18
catTwoAttackHighLeft: equ $CD50
catTwoAttackLowLeft: equ $CE88
catTwoWalkRight: equ $CFC0
catTwoJumpRight: equ $D0F8
catTwoAttackHighRight: equ $D230
catTwoAttackLowRight: equ $D368

catTwoHandLeft: equ $D4A0
catTwoHandRight: equ $D530

mouseSprites:
mouseWalkLeft: equ $D5C0
mouseWalkRight: equ $D628

catOneBgCache: equ $D690
catTwoBgCache: equ $D6FC
mouseBgCache: equ $D768

catCanvas: equ $D783
mouseCanvas: equ $D7EF
renderBuffersEnd: equ $D80A

setupRenderer:
        call renderPrecomputeSprites
        ret

renderFrame:
        ;; TODO: delete me
        ;; manual create an update for testing purposes


        ld IX, fuP1UpdatesBase
        ld (IX + renderPNUpdatesTileX), 0
        ld (IX + renderPNUpdatesTileY), 0
        ld (IX + renderPNUpdatesTilePtr), HIGH(cat1SpritesWalk)
        ld (IX + renderPNUpdatesTilePtr + 1), LOW(cat1SpritesWalk)

        ld IX, fuP2UpdatesBase
        ld (IX + renderPNUpdatesTileX), 3
        ld (IX + renderPNUpdatesTileY), 0
        ld (IX + renderPNUpdatesTilePtr), HIGH(catOneWalkRight + (8 * 3))
        ld (IX + renderPNUpdatesTilePtr + 1), LOW(catOneWalkRight   + (8 * 3))

        ;; ld a,2              ; 2 is the code for red.
        ;; out (254),a         ; write to port 254.

        ld b, 100
wasteTimeLoop:
        nop
        nop
        nop
        djnz wasteTimeLoop

        ;; TODO: erase mouse
        ld hl, catCanvas
        ld c, 2
        ld b, 3
        ld e, 3
        ld d, 1
        call renderDrawRectangle

        ;; TODO: erase cat 2
        ld hl, catCanvas
        ld c, 2
        ld b, 3
        ld e, 4
        ld d, 3
        call renderDrawRectangle

        ;; TODO: erase cat 1
        ld hl, catCanvas
        ld c, 2
        ld b, 3
        ld e, 4
        ld d, 3
        call renderDrawRectangle

        ;; TODO: read area behind cat 1
        ld hl, catCanvas
        ld c, 0
        ld b, 0
        ld e, 4
        ld d, 3
        call renderReadRectangle

        ;; draw cat 1
        ld IX, fuP1UpdatesBase
        call renderFrameCat

        ;; TODO: draw cat 1
        ld hl, catCanvas
        ld c, 2
        ld b, 3
        ld e, 4
        ld d, 3
        call renderDrawRectangle


        ;; TODO: read area behind cat 2
        ld hl, catCanvas
        ld c, 0
        ld b, 0
        ld e, 4
        ld d, 3
        call renderReadRectangle

        ;; draw cat 2
        ld IX, fuP2UpdatesBase
        call renderFrameCat

        ;; TODO: draw cat 2
        ld hl, catCanvas
        ld c, 2
        ld b, 3
        ld e, 4
        ld d, 3
        call renderDrawRectangle

        ;; TODO: read area behind mouse
        ld hl, catCanvas
        ld c, 0
        ld b, 0
        ld e, 3
        ld d, 1
        call renderReadRectangle

        ;; TODO: draw mice

        ;; TODO: draw mouse
        ld hl, catCanvas
        ld c, 2
        ld b, 3
        ld e, 3
        ld d, 1
        call renderDrawRectangle

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
        ld ix, 0
        jp renderPrecomputeSpritesCopyLoopFirstIter
renderPrecomputeSpritesCopyLoop:
        ld de, 9 * 8
        add ix, de
renderPrecomputeSpritesCopyLoopFirstIter:
        push bc
        ;; Walk
        ld de, catOneWalkLeft
        ld hl, cat1SpritesWalk
        call renderPrecomputeCopyLeftCatSprite

        ld de, catOneWalkRight
        ld hl, cat1SpritesWalk
        call renderPrecomputeCopyRightCatSprite

        ld de, catTwoWalkLeft
        ld hl, cat2SpritesWalk
        call renderPrecomputeCopyLeftCatSprite

        ld de, catTwoWalkRight
        ld hl, cat2SpritesWalk
        call renderPrecomputeCopyRightCatSprite

        ;; Jump
        ld de, catOneJumpLeft
        ld hl, cat1SpritesJump
        call renderPrecomputeCopyLeftCatSprite

        ld de, catOneJumpRight
        ld hl, cat1SpritesJump
        call renderPrecomputeCopyRightCatSprite

        ld de, catTwoJumpLeft
        ld hl, cat2SpritesJump
        call renderPrecomputeCopyLeftCatSprite

        ld de, catTwoJumpRight
        ld hl, cat2SpritesJump
        call renderPrecomputeCopyRightCatSprite

        ;; Attack High
        ld de, catOneAttackHighLeft
        ld hl, cat1SpritesAttackHigh
        call renderPrecomputeCopyLeftCatSprite

        ld de, catOneAttackHighRight
        ld hl, cat1SpritesAttackHigh
        call renderPrecomputeCopyRightCatSprite

        ld de, catTwoAttackHighLeft
        ld hl, cat2SpritesAttackHigh
        call renderPrecomputeCopyLeftCatSprite

        ld de, catTwoAttackHighRight
        ld hl, cat2SpritesAttackHigh
        call renderPrecomputeCopyRightCatSprite

        ;; Attack Low
        ld de, catOneAttackLowLeft
        ld hl, cat1SpritesAttackLow
        call renderPrecomputeCopyLeftCatSprite

        ld de, catOneAttackLowRight
        ld hl, cat1SpritesAttackLow
        call renderPrecomputeCopyRightCatSprite

        ld de, catTwoAttackLowLeft
        ld hl, cat2SpritesAttackLow
        call renderPrecomputeCopyLeftCatSprite

        ld de, catTwoAttackLowRight
        ld hl, cat2SpritesAttackLow
        call renderPrecomputeCopyRightCatSprite

        pop bc
        dec b

        jp nz, renderPrecomputeSpritesCopyLoop
        ld b, 0
        ld hl, 0
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
        ;;  copyRightCatSprite
        ;; ---------------------------------------------------------------------
        ;; PRE: de contains destination of right facing cat-sized sprite
        ;;      hl contains source of left facing cat-sized sprite
        ;;      location at de is zero-filled
        ;;      IX contains offset past de to write to
        ;; POST: sprite copied and mirrored renderCatMouseNumShifts times
renderPrecomputeCopyRightCatSprite:
        push hl

        push ix                 ; put value in IX on stack
        pop hl                  ; pull it back off into HL
        add hl, de
        ex de, hl

        pop hl

        ;; de contains de + ix (dest + dest offset)
        ;; hl contains original source value

        push hl
        ld b, 3
renderPrecomputeCopyRightCatSpriteTopRowLoop:
        push bc
        ld hl, zeroTile
        ld bc, 8
        ldir
        pop bc
        djnz renderPrecomputeCopyRightCatSpriteTopRowLoop
        pop hl
        ;; hl contains pointer to first byte of source tile 1
        ;; de contains pointer to first byte of destination tile 4

        ld bc, 15
        add hl, bc
        ex de, hl
        ;; hl contains pointer to first byte of destination tile 4
        ;; de contains pointer to last byte of source tile 2
        ld b, 16
renderPrecomputeCopyRightCatSpriteMiddleRowLoop:
        ld a, (de)
        ld (hl), a
        dec de
        inc hl
        djnz renderPrecomputeCopyRightCatSpriteMiddleRowLoop

        ;; hl contains pointer to first byte of destination tile 6
        ;; de contains pointer to byte prior to first byte of source

        ex de, hl
        ld bc, 32
        add hl, bc

        ;; de contains pointer to first byte of destination tile 6
        ;; hl contains pointer to last byte of source tile 4

        push hl
        ld hl, zeroTile
        ld bc, 8
        ldir
        pop hl

        ex de, hl

        ;; hl contains pointer to first byte of destination tile 7
        ;; de contains pointer to last byte of source tile 4

        ld b, 16
renderPrecomputeCopyRightCatSpriteBottomRowLoop:
        ld a, (de)
        ld (hl), a
        dec de
        inc hl
        djnz renderPrecomputeCopyRightCatSpriteBottomRowLoop

        ex de, hl

        ld hl, zeroTile
        ld bc, 8
        ldir

        ret

        ;; ---------------------------------------------------------------------
        ;;  copyLeftCatSprite
        ;; ---------------------------------------------------------------------
        ;; PRE: de contains destination of left facing cat-sized sprite
        ;;      hl contains source of left facing cat-sized sprite
        ;;      location at de is zero-filled
        ;;      IX contains offset past de to write to
        ;; POST: sprite copied renderCatMouseNumShifts times
renderPrecomputeCopyLeftCatSprite:
        push hl

        push ix                 ; put value in IX on stack
        pop hl                  ; pull it back off into HL
        add hl, de
        ex de, hl

        pop hl

        ;; de contains de + ix (dest + dest offset)
        ;; hl contains original source value

        push hl
        ld b, 3
renderPrecomputeCopyLeftCatSpriteTopRowLoop:
        push bc
        ld hl, zeroTile
        ld bc, 8
        ldir
        pop bc
        djnz renderPrecomputeCopyLeftCatSpriteTopRowLoop
        pop hl

        ld bc, 8 * 2
        ldir

        push hl
        ld hl, zeroTile
        ld bc, 8
        ldir
        pop hl

        ld bc, 8 * 2
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
        srl (IX + 0)
        rr (IX + 8)
        rr (IX + 16)

        srl (IX + 0 + 1)
        rr (IX + 8 + 1)
        rr (IX + 16 + 1)

        srl (IX + 0 + 2)
        rr (IX + 8 + 2)
        rr (IX + 16 + 2)

        srl (IX + 0 + 3)
        rr (IX + 8 + 3)
        rr (IX + 16 + 3)

        srl (IX + 0 + 4)
        rr (IX + 8 + 4)
        rr (IX + 16 + 4)

        srl (IX + 0 + 5)
        rr (IX + 8 + 5)
        rr (IX + 16 + 5)

        srl (IX + 0 + 6)
        rr (IX + 8 + 6)
        rr (IX + 16 + 6)

        srl (IX + 0 + 7)
        rr (IX + 8 + 7)
        rr (IX + 16 + 7)
        djnz renderPrecomputeShiftCatSpriteLoop
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
