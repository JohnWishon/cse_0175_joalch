
drawPNUpdatesTileX:   equ 6
drawPNUpdatesTileY:   equ 7
drawPNUpdatesTilePtr: equ 8

drawWriteTileX: equ 0
drawWriteTileY: equ 1
drawWriteTilePtr: equ 2


setupGraphics:
        ld a,2              ; 2 is the code for red.
        out (254),a         ; write to port 254.

        ld b, screenTileHeight
        ld IX, fuP1UpdatesBase
        ld (IX + drawPNUpdatesTileX), 0
        ld (IX + drawPNUpdatesTileY), 0
        ld (IX + drawPNUpdatesTilePtr), HIGH(staticTileBackground)
        ld (IX + drawPNUpdatesTilePtr + 1), LOW(staticTileBackground)
setupGraphicsBackgroundYLoop:
        ld c, screenTileWidth
setupGraphicsBackgroundXLoop:
        dec c
        push bc
        dec b
        call drawFrameWriteTile
        pop bc
        ld a, c
        cp 0
        jp nz, setupGraphicsBackgroundXLoop
        djnz setupGraphicsBackgroundYLoop

        ;; background drawn, now draw level

        ld b, levelTileHeight
        ld hl, gameLevelEnd
setupGraphicsLevelYLoop:
        ld c, levelTileWidth
setupGraphicsLevelXLoop:
        dec c
        dec hl
        ld a, (HL)
        and levelDummyTileMask
        jp z, setupGraphicsLevelSkip
        ld a, (HL)
        and levelTileIndexMask
        push hl
        ld hl, dynamicTileInstanceBase
        ld d, 0
        ld e, a
        add hl, de
        ld (IX + drawPNUpdatesTilePtr), h
        ld (IX + drawPNUpdatesTilePtr + 1), l
        push bc
        ld (IX + drawPNUpdatesTileX), c
        dec b
        ld (IX + drawPNUpdatesTileY), b
        ld c, levelLeftmostCol
        ld b, levelTopmostRow
        call drawFrameWriteTile
        pop bc
        pop hl
setupGraphicsLevelSkip:
        ld a, c
        cp 0
        jp nz, setupGraphicsLevelXLoop
        djnz setupGraphicsLevelYLoop

drawFrame:
        ;; TODO: delete me
        ;; manual create an update for testing purposes

        ld IX, fuP1UpdatesBase
        ld (IX + drawPNUpdatesTileX), 0
        ld (IX + drawPNUpdatesTileY), 0
        ld (IX + drawPNUpdatesTilePtr), HIGH(couchSideDamaged)
        ld (IX + drawPNUpdatesTilePtr + 1), LOW(couchSideDamaged)

        ld IX, fuP2UpdatesBase
        ld (IX + drawPNUpdatesTileX), 1
        ld (IX + drawPNUpdatesTileY), 1
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

        ld c, levelLeftmostCol
        ld b, levelTopmostRow
        call drawFrameWriteTile


        ;; TODO: sprite stuff
        ret

        ;; ---------------------------------------------------------------------
        ;; writeTile
        ;; ---------------------------------------------------------------------
        ;; PRE: IX contains pointer to updateBase
        ;;      c contains x offset
        ;;      b contains y offset
        ;; POST: tile written to screen at (x + offsetX, y + offsetY)
        ;; https://chuntey.wordpress.com/2013/09/08/how-to-write-zx-spectrum-games-chapter-9/
drawFrameWriteTile:
        ld a, (IX + drawPNUpdatesTileY)
        add a, b
        ld b, a
        ld a, (IX + drawPNUpdatesTileX)
        add a, c
        ld c, a
        call drawFrameTileAddress ; DE contains pointer to top row of tile

        push bc
        ld b,8              ; number of pixels high.

        ld h, (IX + drawPNUpdatesTilePtr)
        ld l, (IX + (drawPNUpdatesTilePtr + 1))
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

