updateAI:
    call updateFloor
    call updateWall
    ret

updateFloor:
    ld ix, mouseUpdatesBase     ; load mouse movement
    ld a, (ix + 5)              ; load if floor mouse is active
    cp 1                        ; 1 = active, 0 = not active
    jp nz, noMouse

;; ------------------------------------------------------------
;;  Mouse is active.
;;      - Check its direction (left, right, up, down) - currently only using left/right
;;      - Check its X position to see if it is at the mouse hole or couch escape
;;      - If not at a hole, then continue moving
;;      - If at a hole, randomly choose to escape or keep moving
;; ------------------------------------------------------------
activeMouse:
    ld a, (ix)                  ; Load direction
    rra                         ; rotate lsb into carry
    jr nc, mouseVert            ; no carry = 0 or 2 - vertical movement

    ; direction is 1 or 3 - horizontal
    rra                 ; rotate lsb into carry
    jr nc, mouseRight   ; no carry = 1 - move right

; move mouse left
mouseLeft:
    ld a, (ix + 2)      ; Load current x coord
    ld (ix + 1), a      ; Save current x into old x
    sub mousePace       ; Move left by 4
    ld (ix + 2), a      ; Save new x into current x

    ;; check if at the couch or hole and make random decision to go into it
    call checkMouseX

    cp minX             ; reached min x?
    jr z, mouseChange   ; yes - turn around
    jr c, mouseChange   ; went past min
    ret

; move mouse right
mouseRight:
    ld a, (ix + 2)      ; Load current x coord
    ld (ix + 1), a      ; Save current x into old x
    add a, mousePace    ; Move right by 4
    ld (ix + 2), a      ; Save new x into current x

    ;; check if at the couch or hole and make random decision to go into it
    call checkMouseX

    cp maxX             ; reached max x?
    jr nc, mouseChange  ; yes - turn around
    ret

;move mouse vertically - currently unneeded - talk with Chris?
mouseVert:
    rra                 ; rotate lsb into carry
    jr c, mouseDown     ; carry = 2 - move down

; move mouse up
mouseUp:
    ld a, (ix + 4)      ; Load current y coord
    ld (ix + 3), a      ; Save current y into old y
    sub mousePace       ; move up
    ld (ix + 4), a      ; Save new y into current y
    cp minY             ; reached min y?
    jr z, mouseChange   ; yes - turn around
    ret

; move mouse down
mouseDown:
    ld a, (ix + 4)      ; Load current y coord
    ld (ix + 3), a      ; Save current y into old y
    add a, mousePace    ; Move down by 4
    ld (ix + 4), a      ; Save new y into current y
    cp maxY             ; reached max y?
    jr nc, mouseChange  ; yes - turn around
    ret

;change mouse direction
mouseChange:
    ld a, (ix)          ; Load direction
    xor 2               ; swap direction left <-> right, up <-> down
    ld (ix), a          ; Save new direction
    ret

checkMouseX:
    ;; a should be current x position - don't change it or save it
    cp couchX           ; is the mouse at the couch midpoint
    jr z, canEscape     ; if yes, random roll escape
    cp holeX            ; is the mouse at the mouse hole
    jr z, canEscape     ; if yes, random roll escape
    ret                 ; otherwise can't escape so keep moving

canEscape:
    push af
    call random
    and 1               ; range of 0 and 1
    cp 1
    jr nc, mouseStay    ; 1 is mouse escapes, 0 means it stays
    call mouseEscape
    jp canEscapeEnd
mouseStay:              ;; remove and change previous jr to canEscapeEnd if this part remains unneeded
canEscapeEnd:
    pop af
    ret

;; Mouse chooses to escape
mouseEscape:
    ld (ix + 5), 0          ; set mouseActive to false
    ld (ix + 6), 0          ; reset spawn counter

    ret

;;---------------------------------------------------
;;  No active mouse.
;;      - Check if the spawn counter reached the max time
;;      - If it has, then automatically activate the Mouse
;;      - If it hasn't, random roll to see if we activate or not
;;---------------------------------------------------

noMouse:
    ld a, (ix + 6)
    cp spawnTime
    jp z, initMouse
noMaxCtr:
    ld a, (ix + 7)      ; load the counter for when to check spawning
    cp floorTime       ; compare against the random check timer
    jp nz, noSpawn      ; this should happen every sec (25 frames)

    ld (ix + 7), 0
    call random         ; get random number
    and 9               ; range 0-9
decisionCp:
    cp spawnChance      ; Change spawnChance variable to change %
    jr nc, noSpawn      ; If the answer is 1 (01) then we init
initMouse:
    ld (ix + 5), 1      ; Activate mouse
    ret
noSpawn:

    inc (ix + 6)        ; increment the spawn counter
    inc (ix + 7)        ; increment the check counter
    ret


updateWall:
    ld ix, mouseWall1
    ld a, (ix + 2)      ; load active setting
    cp 1
    jr z, wall1Escape
activateWall1:
    ld a, (ix + 3)      ; load the counter for when to check spawning
    cp wallTime         ; compare against the random check timer
    jp nz, wall1End     ; rand timer hasn't reached max

    call random
    and 1
    cp wallSpawn        ; check if we should activate the wall mouse
    jr nc, wall1End

    ld (ix + 2), 1      ; active
    ld (ix + 3), 0      ; reset timer

    ld a, (ix)              ; load x tile into change x
    ld (ix + 4), a

    ld a, (ix + 1)          ; load y tile into change y
    ld (ix + 5), a

    ld hl, mouseHoleActive  ; ptr to tile
    ld (ix + 6), h
    ld (ix + 7), l

    ld a, mouseHoleActive - dynamicTileInstanceBase             ; tile OR'd with health
    or 00000001
    ld (gameLevel + ((mouseW1Y*levelTileWidth) + mouseW1X)), a  ; add to gamelevel

    jp wall1End

wall1Escape:
    ld a, (ix + 3)          ; check if we should check this frame
    cp wallTime
    jp nz, wall1End

    call random             ; does the mouse go away?
    and 1
    cp wallSpawn
    jr nc, wall1End         ; no - it stays

    ld (ix + 2), 0          ; inactive
    ld (ix + 3), 0          ; reset timer

    ld a, (ix)              ; load x tile into change x
    ld (ix + 4), a

    ld a, (ix + 1)          ; load y tile into change y
    ld (ix + 5), a

    ld hl, staticTileMouseHole               ; load change ptr with static mouse Hold
    ld (ix + 6), h
    ld (ix + 7), l

    ld a, tgaPassable                       ; load gameLevel with static mouse hole
    ld  (gameLevel + ((mouseW1Y*levelTileWidth) + mouseW1X)), a

wall1End:
    inc (ix + 3)
    ld ix, mouseWall2
    ld a, (ix + 2)      ; load active setting
    cp 1
    jr z, wall2Escape
activateWall2:
    ld a, (ix + 3)      ; load the counter for when to check spawning
    cp wallTime         ; compare against the random check timer
    jp nz, wall2End     ; rand timer hasn't reached max

    call random
    and 1
    cp wallSpawn        ; check if we should activate the wall mouse
    jr nc, wall2End

    ld (ix + 2), 1      ; active
    ld (ix + 3), 0      ; reset timer

    ld a, (ix)              ; load x tile into change x
    ld (ix + 4), a

    ld a, (ix + 1)          ; load y tile into change y
    ld (ix + 5), a

    ld hl, mouseHoleActive  ; ptr to tile
    ld (ix + 6), h
    ld (ix + 7), l

    ld a, mouseHoleActive - dynamicTileInstanceBase             ; tile OR'd with health
    or 00000001
    ld (gameLevel + ((mouseW2Y*levelTileWidth) + mouseW2X)), a  ; add to gamelevel

    jp wall2End

wall2Escape:
    ld a, (ix + 3)          ; check if we should check this frame
    cp wallTime
    jp nz, wall2End

    call random             ; does the mouse go away?
    and 1
    cp wallSpawn
    jr nc, wall2End         ; no - it stays

    ld (ix + 2), 0          ; inactive
    ld (ix + 3), 0          ; reset timer

    ld a, (ix)              ; load x tile into change x
    ld (ix + 4), a

    ld a, (ix + 1)          ; load y tile into change y
    ld (ix + 5), a

    ld hl, staticTileMouseHole               ; load change ptr with static mouse Hold
    ld (ix + 6), h
    ld (ix + 7), l

    ld a, tgaPassable                       ; load gameLevel with static mouse hole
    ld  (gameLevel + ((mouseW2Y*levelTileWidth) + mouseW2X)), a

wall2End:
    inc (ix + 3)
    ld ix, mouseWall3
    ld a, (ix + 2)      ; load active setting
    cp 1
    jr z, wall3Escape
activateWall3:
    ld a, (ix + 3)      ; load the counter for when to check spawning
    cp wallTime         ; compare against the random check timer
    jp nz, wall3End     ; rand timer hasn't reached max

    call random
    and 1
    cp wallSpawn        ; check if we should activate the wall mouse
    jr nc, wall3End

    ld (ix + 2), 1      ; active
    ld (ix + 3), 0      ; reset timer

    ld a, (ix)              ; load x tile into change x
    ld (ix + 4), a

    ld a, (ix + 1)          ; load y tile into change y
    ld (ix + 5), a

    ld hl, mouseHoleActive  ; ptr to tile
    ld (ix + 6), h
    ld (ix + 7), l

    ld a, mouseHoleActive - dynamicTileInstanceBase             ; tile OR'd with health
    or 1
    ld (gameLevel + ((mouseW3Y*levelTileWidth) + mouseW3X)), a  ; add to gamelevel

    jp wall3End

wall3Escape:
    ld a, (ix + 3)          ; check if we should check this frame
    cp wallTime
    jp nz, wall3End

    call random             ; does the mouse go away?
    and 1
    cp wallSpawn
    jr nc, wall3End         ; no - it stays

    ld (ix + 2), 0          ; inactive
    ld (ix + 3), 0          ; reset timer

    ld a, (ix)              ; load x tile into change x
    ld (ix + 4), a

    ld a, (ix + 1)          ; load y tile into change y
    ld (ix + 5), a

    ld hl, staticTileMouseHole               ; load change ptr with static mouse Hold
    ld (ix + 6), h
    ld (ix + 7), l

    ld a, tgaPassable                       ; load gameLevel with static mouse hole
    ld  (gameLevel + ((mouseW3Y*levelTileWidth) + mouseW3X)), a
wall3End:
    inc (ix + 3)
    ret

;;---------------------------------------------------------
;; random number generator
;;      - leaves the number in A
;;      - save A before using this function if you will need A after
;;      - TODO: elsewhere - load seed with frame counter after a keypress on load screen??
;;---------------------------------------------------------
random:
    ld hl, (seed)       ; Load pointer to rom
    res 5, h            ; stay in first 8k of rom
    ld a, (hl)          ; Get the number
    xor l               ; more randomness
    inc hl              ; Incr pointer
    ld (seed), hl
    ret


mousePace:  equ 4
maxY:       equ levelBottommostPixel
minY:       equ levelTopmostPixel
maxX:       equ levelRightmostPixel - 3
minX:       equ levelLeftmostPixel
couchX:     equ 120
holeX:      equ 40
spawnTime:  equ 125
floorTime:  equ 25
wallTime:   equ 25
spawnChance:    equ 4
wallSpawn:  equ 1
