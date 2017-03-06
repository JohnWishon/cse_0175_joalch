        include "graphics-sprites.asm"

setupGraphics:
        ld b, screenTileHeight
        ld hl, staticTileBackground
setupGraphicsBackgroundYLoop:
        ld c, screenTileWidth
setupGraphicsBackgroundXLoop:
        dec c
        push bc
        dec b
        push hl
        call renderFrameWriteTile
        pop hl
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
        push bc
        dec b
        ld a, levelLeftmostCol
        add a, c
        ld c, a
        ld a, levelTopmostRow
        add a, b
        ld b, a
        call renderFrameWriteTile
        pop bc
        pop hl
setupGraphicsLevelSkip:
        ld a, c
        cp 0
        jp nz, setupGraphicsLevelXLoop
        djnz setupGraphicsLevelYLoop

        ret
