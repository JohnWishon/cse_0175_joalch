setupGameLogic:
        ;; TODO: setup the level
        ld b, levelTileHeight
        ld hl, gameLevel
setupGameLogicYLoop:
        ld c, levelTileWidth
setupGameLogicXLoop:
        dec c
        ld (hl), (dynamicTileTestImpassableOneHealth - dynamicTileInstanceBase) | 1
        inc hl
        ld a, c
        cp 0
        jp nz, setupGameLogicXLoop
        djnz setupGameLogicYLoop
        ret

updateGameLogic:
        ;; TODO: score, interest, RNG, etc...
        ret
