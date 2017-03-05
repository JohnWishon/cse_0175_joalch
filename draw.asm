drawPNUpdatesTileX:   equ 6
drawPNUpdatesTileY:   equ 7
drawPNUpdatesTilePtr: equ 8

drawWriteTileX: equ 0
drawWriteTileY: equ 1
drawWriteTilePtr: equ 2

drawCatMouseNumShifts:  equ 4
drawCatMouseNumFacings: equ 2

drawCatNumPoses:        equ 4
drawCatHandNumPoses:    equ 1
drawCatPosesOffset:     equ drawCat1LeftSprites - drawCat1Base
drawCatHandPosesOffset: equ drawCat1HandLeftSprites - drawCat1HandBgCache

drawCat1Base:
drawCat1BgCache:          equ $C000
drawCat1SpriteBuf:        equ $C048
        ;; walk left, jump, attack high, attack low
drawCat1LeftSprites:      equ $C090
drawCat1RightSprites:     equ $C390
drawCat1HandBgCache:      equ $C690
drawCat1HandSpriteBuf:    equ $C6B0
drawCat1HandLeftSprites:  equ $C6D0
drawCat1HandRightSprites: equ $C710

drawCat2Base:
drawCat2BgCache:          equ $C750
drawCat2SpriteBuf:        equ $C798
        ;; walk left, jump, attack high, attack low
drawCat2LeftSprites:      equ $C7E0
drawCat2RightSprites:     equ $CAE0
drawCat2HandBgCache:      equ $CDE0
drawCat2HandSpriteBuf:    equ $CE00
drawCat2HandLeftSprites:  equ $CE00
drawCat2HandRightSprites: equ $CE60

drawMouseBgCache:         equ $CEA0
drawMouseSpriteBuf:       equ $CEB8
drawMouseLeftSprites:     equ $CED0
drawMouseRightSprites:    equ $CF30


setupGraphics:

clearFile:
	ld hl,$4000	
	ld de,$4001
	ld bc,$17FF
	ld (hl),$00
	ldir

setAttributeFile:
	ld hl, MainScreen_Attributes
	ld de, $5800
	ld bc, $0300
	ldir

drawTopScreen:
  ld hl,MainScreen_Attributes_TOP
  ld de,$4000
  ld bc,256
  call drawScreen
drawMidScreen:
  ld hl,MainScreen_Attributes_MID
  ld de,$4800
  ld bc,256
  call drawScreen
drawBotScreen:
  ld hl,MainScreen_Attributes_BOT
  ld de,$5000
  ld bc,256
  call drawScreen

  RET

;        ld a,2              ; 2 is the code for red.
;        out (254),a         ; write to port 254.

        ;; call drawPrecomputeSprites

;        ld b, screenTileHeight
;        ld hl, staticTileBackground
;setupGraphicsBackgroundYLoop:
;        ld c, screenTileWidth
;setupGraphicsBackgroundXLoop:
;        dec c
;        push bc
;        dec b
;        push hl
;        call drawFrameWriteTile
;        pop hl
;        pop bc
;        ld a, c
;        cp 0
;        jp nz, setupGraphicsBackgroundXLoop
;        djnz setupGraphicsBackgroundYLoop

        ;; background drawn, now draw level



;        ld b, levelTileHeight
;        ld hl, gameLevelEnd
;setupGraphicsLevelYLoop:
;        ld c, levelTileWidth
;setupGraphicsLevelXLoop:
;        dec c
;        dec hl
;        ld a, (HL)
;        and levelDummyTileMask
;        jp z, setupGraphicsLevelSkip
;        ld a, (HL)
;        and levelTileIndexMask
;        push hl
;        ld hl, dynamicTileInstanceBase
;        ld d, 0
;        ld e, a
;        add hl, de
;        push bc
;        dec b
;        ld a, levelLeftmostCol
;        add a, c
;        ld c, a
;        ld a, levelTopmostRow
;        add a, b
;        ld b, a
;        call drawFrameWriteTile
;        pop bc
;        pop hl
;setupGraphicsLevelSkip:
;        ld a, c
;        cp 0
;        jp nz, setupGraphicsLevelXLoop
;        djnz setupGraphicsLevelYLoop

drawFrame:
        ;; TODO: delete me
        ;; manual create an update for testing purposes

        ld IX, fuP1UpdatesBase
        ld (IX + drawPNUpdatesTileX), 0
        ld (IX + drawPNUpdatesTileY), 0
        ld (IX + drawPNUpdatesTilePtr), HIGH(MOUSE_LEFT_ONE)
        ld (IX + drawPNUpdatesTilePtr + 1), LOW(MOUSE_LEFT_ONE)

        ld IX, fuP2UpdatesBase
        ld (IX + drawPNUpdatesTileX), 1
        ld (IX + drawPNUpdatesTileY), 4
        ld (IX + drawPNUpdatesTilePtr), HIGH(staticTileTestImpassableDestroyed)
        ld (IX + drawPNUpdatesTilePtr + 1), LOW(staticTileTestImpassableDestroyed)

        ;; draw cat 1
        ld IX, fuP1UpdatesBase
        call drawFrameCat
        ;; draw cat 2
        ld IX, fuP2UpdatesBase
        call drawFrameCat
        ;; TODO: draw mice
        ret

drawFrameCat:
        ;; first update tiles

        ld a, (IX + drawPNUpdatesTileX)
        add a, levelLeftmostCol
        ld c, a
        ld a, (IX + drawPNUpdatesTileY)
        add a, levelTopmostRow
        ld b, a
        ld h, (IX + drawPNUpdatesTilePtr)
        ld l, (IX + drawPNUpdatesTilePtr + 1)
        call drawFrameWriteTile


        ;; TODO: sprite stuff
        ret

        ;; ---------------------------------------------------------------------
        ;; writeTile
        ;; ---------------------------------------------------------------------
        ;; PRE: HL contains pointer to tile to draw
        ;;      c contains x offset
        ;;      b contains y offset
        ;; POST: tile written to screen at (x + offsetX, y + offsetY)
        ;; https://chuntey.wordpress.com/2013/09/08/how-to-write-zx-spectrum-games-chapter-9/
drawFrameWriteTile:
        call drawFrameTileAddress ; DE contains pointer to top row of tile

        push bc
        ld b,8              ; number of pixels high.

char0:  ld a,(hl)           ; source graphic.
        ld (de),a           ; transfer to screen.
        inc hl              ; next piece of data.
        inc d               ; next pixel line.
        djnz char0          ; repeat

        pop bc

        ld a, (hl)              ; a contains attribute
        push af
        call drawFrameTileAttrAddress ; HL contains pointer to attribute
        pop af
        ld (hl), a
        ret



        ;; https://chuntey.wordpress.com/2013/09/08/how-to-write-zx-spectrum-games-chapter-9/
drawFrameTileAddress:
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
drawFrameTileAttrAddress:
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
drawTempMouse:
        defb $C0, $FF, $EE, $EE, $C0, $FF, $EE, $EE
        defb $C0, $FF, $EE, $EE, $C0, $FF, $EE, $EE

        ;; ---------------------------------------------------------------------
        ;; precomputeSprites
        ;; ---------------------------------------------------------------------
        ;; TODO: real precomputation that depends on finalized binary sprite
        ;;       layout
        ;; POST: Sprite layout lookup table populated
drawPrecomputeSprites:
        ld DE, drawCat1Base
        ld HL, cat1SpritesBase
        call drawPrecomputeCatSprite
        ld DE, drawCat2Base
        ld HL, cat2SpritesBase
        call drawPrecomputeCatSprite

        ;; TODO: mice

        ret

        ;; ---------------------------------------------------------------------
        ;; precomputeCatSprites
        ;; ---------------------------------------------------------------------
        ;; TODO: real precomputation that depends on finalized binary sprite
        ;;       layout
        ;; PRE:  DE contains destination drawCatNBase for N = 1 or 2
        ;;       HL contains source catNSpritesBase for N = 1 or 2
        ;; POST: Sprite layout lookup table populated for cat N
drawPrecomputeCatSprite:
        ;; skip bg cache and sprite buffer
        push hl
        ld hl, drawCatPosesOffset
        add hl, de
        ld d, h
        ld e, l
        pop hl

        ;; foreach facing
        ;; TODO: right now we just copy the left facing twice
        ;; for the right facing, we need to mirror the sprite
        ;; easiest thing to do would probably write a mirrorSprite
        ;; function and do a conditional call
        ld b, drawCatMouseNumFacings
drawPrecomputeCatSpriteFacingLoop:
        push bc

        ;; foreach pose
        ld b, drawCatNumPoses
drawPrecomputeCatSpritePoseLoop:
        push bc

        ;; foreach shift depth
        ld b, drawCatMouseNumShifts
        ld a, 0                 ; a contains the current amount to shift by
        push hl                 ; save our location
drawPrecomputeCatSpritePoseShiftLoop:
        pop hl                  ; for each shift depth, we'll copy the same
        ;; sprite, copy it to the new destination, and shift it

        ;; foreach cat tile row
        ld b, catHeight
drawPrecomputeCatSpritePoseShiftHeightLoop:
        push bc
        ld bc, catPixelHeight * catWidth

        ldir

        ;; copy an empty tile
        push hl                 ; save current HL
        ld hl, zeroTile         ; set hl to the address of the zero tile
        ld bc, 8                ; the zero tile is 8 wide
        ldir                    ; copy the zero tile
        pop hl                  ; restore hl so that it points at the next row

        ;; ---------------------------------------------------------------------
        ;; TODO: begin shift the row over
        ;; ---------------------------------------------------------------------

        ;; a contains the amout to shift by + 1
        push bc
        ld b, a                 ; b contains amount to shift by + 1
drawPrecomputeCatSpritePoseShiftHeightCommitShiftLoop:
        ;; TODO: do the shift here
        djnz drawPrecomputeCatSpritePoseShiftHeightCommitShiftLoop
        pop bc

        ;; ---------------------------------------------------------------------
        ;; TODO: end shift the row over
        ;; ---------------------------------------------------------------------

        pop bc
        djnz drawPrecomputeCatSpritePoseShiftHeightLoop
        ;; end foreach cat tile row

        pop bc
        djnz drawPrecomputeCatSpritePoseShiftLoop
        ;; end foreach shift depth

        pop bc
        djnz drawPrecomputeCatSpritePoseLoop
        ;; end foreach pose

        ;; skip hand bg cache and sprite buffers
        push hl
        ld hl, drawCatHandPosesOffset
        add hl, de
        ld d, h
        ld e, l
        pop hl

        ;; ---------------------------------------------------------------------
        ;; At this point, HL should point to catNSpritesHand and DE should point
        ;; to drawCatNHandLeftSprites.
        ;; ---------------------------------------------------------------------

        ;; foreach hand pose
        ;; TODO: remove this if we end up going with 1 hand pose
        ld b, drawCatHandNumPoses
drawPrecomputeCatSpriteHandPoseLoop:
        push bc


        ;; foreach shift depth
        ld b, drawCatMouseNumShifts
        ld a, 0                 ; a contains the current amount to shift by
        push hl                 ; save our location
drawPrecomputeCatSpriteHandPoseShiftLoop:
        pop hl                  ; for each shift depth, we'll copy the same
        ;; sprite, copy it to the new destination, and shift it
        push bc

        ld bc, 8                ; a fist is 8 pixels wide
        ldir

        ;; copy an empty tile
        push hl                 ; save current HL
        ld hl, zeroTile         ; set hl to the address of the zero tile
        ld bc, 8                ; the zero tile is 8 wide
        ldir                    ; copy the zero tile
        pop hl                  ; restore hl

        ;; ---------------------------------------------------------------------
        ;; TODO: begin shift the row over
        ;; ---------------------------------------------------------------------

        ;; a contains the amout to shift by + 1
        push bc
        ld b, a                 ; b contains amount to shift by + 1
drawPrecomputeCatSpriteHandPoseShiftCommitShiftLoop:
        ;; TODO: do the shift here
        djnz drawPrecomputeCatSpriteHandPoseShiftCommitShiftLoop
        pop bc

        ;; ---------------------------------------------------------------------
        ;; TODO: end shift the row over
        ;; ---------------------------------------------------------------------

        pop bc
        djnz drawPrecomputeCatSpriteHandPoseShiftLoop
        ;; end foreach shift depth

        pop bc
        djnz drawPrecomputeCatSpriteHandPoseLoop
        ;; end foreach hand pose

        pop bc
        djnz drawPrecomputeCatSpriteFacingLoop
        ;; end foreach facing
        ret
>>>>>>> master
