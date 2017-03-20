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
    cp rightX
    jr z, canEscape
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
    cp floorSpawnTime
    jp z, activateMouse
noMaxCtr:
    ld a, (ix + 7)      ; load the counter for when to check spawning
    cp floorRndTime       ; compare against the random check timer
    jp nz, noSpawn      ; this should happen every sec (25 frames)

    ld (ix + 7), 0
    call random         ; get random number
    and 9               ; range 0-9
decisionCp:
    cp floorSpawnChance ; Change variable to change %
    jr nc, noSpawn      ; If the answer is 1 (01) then we init
activateMouse:
    call random         ; random call to see if spawning a floor mouse
    and 9
    cp 7
    jr c, noSpawn

    ld (ix + 5), 1      ; Activate mouse

    call random         ; get rng for direction
    and 9               ; 0 or 1 = right, 2 or 3 = left

    cp 5
    jr c, setMouseRight

    ld (ix), 3          ; 2 or 3 happened, mouse will start going left
    jr setMouseSpawn
setMouseRight:
    ld (ix), 1          ; 0 or 1 happened, mouse will start going right

setMouseSpawn:
    call random         ; Randomize mouse spawn
    and maxX
    cp holeX
    jr c, spawnHole     ; if carry, spawn at hole

    cp couchX
    jr c, spawnCouch    ; if carry, spawn at couch

    ld (ix + 2), rightX     ; spawn at right
    jr endActivateMouse
spawnHole:
    ld (ix + 2), holeX
    jr endActivateMouse
spawnCouch:
    ld (ix + 2), couchX
endActivateMouse:
    ret
noSpawn:
    inc (ix + 6)        ; increment the spawn counter
    inc (ix + 7)        ; increment the check counter
    ret


updateWall:
    ld ix, mouseWall1
    ld (ix + 7), 0
    ld (ix + 8), 0

    ld a, (ix + 2)      ; load active setting
    cp 1
    jr z, wall1Escape
activateWall1:
    ld a, (ix + 3)      ; load the counter for when to check spawning
    cp wallRndTime      ; compare against the random check timer
    jp nz, wall1End     ; rand timer hasn't reached max

    ld (ix + 3), 0      ; reset timer

    call random
    and 9
    cp wallSpawnChance    ; check if we should activate the wall mouse
    jp nc, wall1End

    ld (ix + 2), 1          ; active

    ld a, (ix)              ; load x tile into change x
    ld (ix + 4), a

    ld a, (ix + 1)          ; load y tile into change y
    ld (ix + 5), a

    ld (ix + 6), 0          ; reset despawn counter

    ld hl, mouseHoleActive  ; ptr to tile
    ld (ix + 7), h
    ld (ix + 8), l


    ld b, levelTileWidth
    ld c, (ix + 1)
    ld d, (ix)
    xor a

    call getGameLevelMouseAddr

    ld a, mouseHoleActive - dynamicTileInstanceBase             ; tile OR'd with health
    or 1
    ld (hl), a              ; add to gamelevel

    jp wall1End

wall1Escape:
    ld a, (ix + 3)          ; check if we should check this frame
    cp wallRndTime
    jp nz, wall1End

    ld (ix + 3), 0          ; reset timer

    inc (ix + 6)            ; Increment deactivate timer

    ld a, (ix + 6)
    cp wallSpawnTime
    jr z, deactivateWall1

    call random             ; does the mouse go away?
    and 9
    cp wallSpawnChance
    jr nc, wall1End         ; no - it stays

deactivateWall1:

    ld (ix + 2), 0          ; inactive

    ld a, (ix)              ; load x tile into change x
    ld (ix + 4), a

    ld a, (ix + 1)          ; load y tile into change y
    ld (ix + 5), a

    ld (ix + 6), 0          ; reset despawn timer

    ld hl, staticTileMouseHole               ; load change ptr with static mouse Hold
    ld (ix + 7), h
    ld (ix + 8), l

    ld b, levelTileWidth
    ld c, (ix + 1)
    ld d, (ix)
    xor a

    call getGameLevelMouseAddr

    ld a, tgaPassable                       ; load gameLevel with static mouse hole
    ld  (hl), a

wall1End:
    inc (ix + 3)

    ld ix, mouseWall2
    ld (ix + 7), 0
    ld (ix + 8), 0
    ld a, (ix + 2)      ; load active setting
    cp 1
    jr z, wall2Escape
activateWall2:
    ld a, (ix + 3)      ; load the counter for when to check spawning
    cp wallRndTime      ; compare against the random check timer
    jp nz, wall2End     ; rand timer hasn't reached max

    ld (ix + 3), 0      ; reset timer

    call random
    and 9
    cp wallSpawnChance      ; check if we should activate the wall mouse
    jr nc, wall2End

    ld (ix + 2), 1          ; active

    ld a, (ix)              ; load x tile into change x
    ld (ix + 4), a

    ld a, (ix + 1)          ; load y tile into change y
    ld (ix + 5), a

    ld (ix + 6), 0          ; reset despawn counter

    ld hl, mouseHoleActive  ; ptr to tile
    ld (ix + 7), h
    ld (ix + 8), l

    ld b, levelTileWidth
    ld c, (ix + 1)
    ld d, (ix)
    xor a

    call getGameLevelMouseAddr
    ld a, mouseHoleActive - dynamicTileInstanceBase     ; tile OR'd with health
    or 1

    ld (hl), a

    jp wall2End

wall2Escape:
    ld a, (ix + 3)          ; check if we should check this frame
    cp wallRndTime
    jp nz, wall2End

    ld (ix + 3), 0          ; reset timer

    inc (ix + 6)            ; Increment deactivate timer

    ld a, (ix + 6)
    cp wallSpawnTime
    jr z, deactivateWall2

    call random             ; does the mouse go away?
    and 9
    cp wallSpawnChance
    jr nc, wall2End         ; no - it stays

deactivateWall2:
    ld (ix + 2), 0          ; inactive

    ld a, (ix)              ; load x tile into change x
    ld (ix + 4), a

    ld a, (ix + 1)          ; load y tile into change y
    ld (ix + 5), a

    ld (ix + 6), 0          ; reset despawn timer

    ld hl, staticTileMouseHole               ; load change ptr with static mouse Hold
    ld (ix + 7), h
    ld (ix + 8), l

    ld b, levelTileWidth
    ld c, (ix + 1)
    ld d, (ix)
    xor a

    call getGameLevelMouseAddr

    ld a, tgaPassable                       ; load gameLevel with static mouse hole
    ld  (hl), a

wall2End:
    inc (ix + 3)

    ld ix, mouseWall3
    ld (ix + 7), 0
    ld (ix + 8), 0
    ld a, (ix + 2)      ; load active setting
    cp 1
    jr z, wall3Escape

activateWall3:
    ld a, (ix + 3)      ; load the counter for when to check spawning
    cp wallRndTime      ; compare against the random check timer
    jp nz, wall3End     ; rand timer hasn't reached max

    ld (ix + 3), 0      ; reset timer

    call random
    and 9
    cp wallSpawnChance      ; check if we should activate the wall mouse
    jr nc, wall3End

    ld (ix + 2), 1          ; active

    ld a, (ix)              ; load x tile into change x
    ld (ix + 4), a

    ld a, (ix + 1)          ; load y tile into change y
    ld (ix + 5), a

    ld (ix + 6), 0          ; reset despawn counter

    ld hl, mouseHoleActive  ; ptr to tile
    ld (ix + 7), h
    ld (ix + 8), l

    ld b, levelTileWidth
    ld c, (ix + 1)
    ld d, (ix)
    xor a

    call getGameLevelMouseAddr
    ld a, mouseHoleActive - dynamicTileInstanceBase             ; tile OR'd with health
    or 1
    ld (hl), a              ; add to gamelevel

    jp wall3End

wall3Escape:
    ld a, (ix + 3)          ; check if we should check this frame
    cp wallRndTime
    jp nz, wall3End

    ld (ix + 3), 0          ; reset timer

    inc (ix + 6)            ; Increment deactivate timer

    ld a, (ix + 6)
    cp wallSpawnTime
    jr z, deactivateWall3

    call random             ; does the mouse go away?
    and 9
    cp wallSpawnChance
    jr nc, wall3End         ; no - it stays

deactivateWall3:
    ld (ix + 2), 0          ; inactive

    ld a, (ix)              ; load x tile into change x
    ld (ix + 4), a

    ld a, (ix + 1)          ; load y tile into change y
    ld (ix + 5), a

    ld (ix + 6), 0          ; reset despawn timer

    ld hl, staticTileMouseHole               ; load change ptr with static mouse Hold
    ld (ix + 7), h
    ld (ix + 8), l

    ld b, levelTileWidth
    ld c, (ix + 1)
    ld d, (ix)
    xor a

    call getGameLevelMouseAddr

    ld a, tgaPassable                       ; load gameLevel with static mouse hole
    ld  (hl), a

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

; b = tileWidth
; c = mouseY
; d = mouseX
; hl -> return addr into gameLevel
getGameLevelMouseAddr:
    add a, c
    djnz getGameLevelMouseAddr      ; a = tile width * mouseY

    add a, d                        ; a = (tileWidth * mouseY) + mouseX

    ld c, a
    ld hl, gameLevel
    add hl,bc

    ret

mousePace:      equ 4
couchX:         equ 120
holeX:          equ 44
rightX:         equ 180
maxY:           equ levelBottommostPixel - mousePixelHeight
minY:           equ levelTopmostPixel
maxX:           equ levelRightmostPixel - 3 - mousePixelWidth
minX:           equ 32

floorSpawnTime:     equ 125     ; spawn time (in frames) to force floor mouse to spawn
floorRndTime:       equ 25      ; # of frames to wait for random call for floor mouse
floorSpawnChance:   equ 4       ; % (out of 10) for floor mice to spawn

wallSpawnTime:      equ 2       ; spawn time (in seconds) to force wall mouse to despawn
wallRndTime:        equ 25      ; # of frames to wait for random call for wallk mice
wallSpawnChance:    equ 1       ; % (out of 10) for wall mice to spawn
