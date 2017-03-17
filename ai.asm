updateAI:
    call updateFloor
    call updateWall
    ret

updateFloor:
    ld ix, mouseUpdatesBase     ; load mouse movement
    ld a, (ix + 5)              ; load if floor mouse is active
    cp 1                        ; 1 = active, 0 = not active
    jp nz, noMouse

;; ------------------------------------------
;;  Mouse is active.
;;      - Check its direction (left, right, up, down) - currently only using left/right
;;      - Check its X position to see if it is at the mouse hole or couch escape
;;      - If not at a hole, then continue moving
;;      - If at a hole, randomly choose to escape or keep moving
;; ------------------------------------------
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
    ; ld  de,checkStr
    ; ld  bc,XcheckStr-checkStr
    ; call    print
    call random
    and 1               ; range of 0 and 1
    cp 1
    jr nc, mouseStay    ; 1 is mouse escapes, 0 means it stays
    call mouseEscape
    jp canEscapeEnd
mouseStay:              ;; remove and change previous jr to canEscapeEnd if this part remains unneeded
    ; ld  de,stayStr
    ; ld  bc,XstayStr-stayStr
    ; call    print
canEscapeEnd:
    pop af
    ret

;; Mouse chooses to escape
mouseEscape:
    ; ld  de,escapeStr
    ; ld  bc,XescapeStr-escapeStr
    ; call    print
    ld (ix + 5), 0          ; set mouseActive to false
    ld (ix + 6), 0          ; reset spawn counter

    ret

;;---------------------------------
;;  No active mouse.
;;      - Check if the spawn counter reached the max time
;;      - If it has, then automatically activate the Mouse
;;      - If it hasn't, random roll to see if we activate or not
;;---------------------------------

noMouse:
    ld a, (ix + 6)
    cp spawnTime
    jp z, initMouse
noMaxCtr:
    ; ld  de,noMaxStr
    ; ld  bc,XnoMaxStr-noMaxStr
    ; call    print

    ; ld b, 0
    ; ld c, (ix + 7)
    ; call $2d2b
    ; call $2de3

    ld a, (ix + 7)      ; load the counter for when to check spawning
    cp randomTime       ; compare against the random check timer
    jp nz, noSpawn      ; this should happen every sec (25 frames)

    ld (ix + 7), 0
    call random         ; get random number
    and 9               ; range 0-9
    ;
    ; push af
    ; ld b, 0
    ; ld c, a
    ; call $2d2b
    ; call $2de3
    ; pop af
decisionCp:
    cp spawnChance      ; Change spawnChance variable to change %
    jr nc, noSpawn      ; If the answer is 1 (01) then we init
initMouse:
    ; ld  de,maxStr
    ; ld  bc,XmaxStr-maxStr
    ; call    print
    ld (ix + 5), 1      ; Activate mouse
    ret
noSpawn:
    ; ld  de,noMouseStr
    ; ld  bc,XnoMouseStr-noMouseStr
    ; call    print
    ; ld b, 0
    ; ld c, (ix + 6)
    ; call $2d2b
    ; call $2de3

    inc (ix + 6)        ; increment the spawn counter
    inc (ix + 7)        ; increment the check counter
    ret


updateWall:
    ld ix, mouseWall1
    ld a, (ix + 6)      ; load inactive setting
    cp 1
    jr z, wall1End
activateWall1:
    ld a, (ix + 7)      ; load the counter for when to check spawning
    cp wallTime         ; compare against the random check timer
    jp nz, wall1End     ; this should happen every sec (25 frames)

    ld (ix + 7), 0
    call random
    and 1

    ; push af
    ; ld b, 0
    ; ld c, a
    ; call $2d2b
    ; call $2de3
    ; pop af

    cp wallSpawn
    jr nc, wall1End
    ; ld  de,wall1Str
    ; ld  bc,Xwall1Str-wall1Str
    ; call    print
    ld (ix + 6), 1
wall1End:
    inc (ix + 7)
    ld ix, mouseWall2
    ld a, (ix + 6)      ; load inactive setting
    cp 1
    jr z, wall2End
activateWall2:
    ld a, (ix + 7)      ; load the counter for when to check spawning
    cp wallTime         ; compare against the random check timer
    jp nz, wall2End     ; this should happen every sec (25 frames)

    ld (ix + 7), 0
    call random
    and 1

    ; push af
    ; ld b, 0
    ; ld c, a
    ; call $2d2b
    ; call $2de3
    ; pop af

    cp wallSpawn
    jr nc, wall2End
    ; ld  de,wall2Str
    ; ld  bc,Xwall2Str-wall2Str
    ; call    print
    ld (ix + 6), 1
wall2End:
    inc (ix + 7)
    ld ix, mouseWall3
    ld a, (ix + 6)      ; load inactive setting
    cp 1
    jr z, wall3End
activateWall3:
    ld a, (ix + 7)      ; load the counter for when to check spawning
    cp wallTime         ; compare against the random check timer
    jp nz, wall3End     ; this should happen every sec (25 frames)

    ld (ix + 7), 0
    call random
    and 1

    ; push af
    ; ld b, 0
    ; ld c, a
    ; call $2d2b
    ; call $2de3
    ; pop af

    cp wallSpawn
    jr nc, wall3End
    ; ld  de,wall3Str
    ; ld  bc,Xwall3Str-wall3Str
    ; call    print
    ld (ix + 6), 1
wall3End:
    inc (ix + 7)
    ret

;;---------------------------------------
;; random number generator
;;      - leaves the number in A
;;      - save A before using this function if you will need A after
;;      - TODO: elsewhere - load seed with frame counter after a keypress on load screen??
;;---------------------------------------
random:
        ; ld  hl,0xA280   ; xz -> yw
        ; ld  de,0xC0DE   ; yw -> zt
        ; ld  (random+1),de  ; x = y, z = w
        ; ld  a,e         ; w = w ^ ( w << 3 )
        ; add a,a
        ; add a,a
        ; add a,a
        ; xor e
        ; ld  e,a
        ; ld  a,h         ; t = x ^ (x << 1)
        ; add a,a
        ; xor h
        ; ld  d,a
        ; rra             ; t = t ^ (t >> 1) ^ w
        ; xor d
        ; xor e
        ; ld  h,l         ; y = z
        ; ld  l,a         ; w = t
        ; ld  (random+4),hl
        ; ret
    ld hl, (seed)       ; Load pointer to rom
    res 5, h            ; stay in first 8k of rom
    ld a, (hl)          ; Get the number
    inc hl              ; Incr pointer
    ld (seed), hl
    ret

wall1Str:
    defb    "1"
Xwall1Str:

wall2Str:
    defb    "2"
Xwall2Str:

wall3Str:
    defb    "3"
Xwall3Str:

checkStr:
    defb    "C"
XcheckStr:

escapeStr:
    defb    "E"
XescapeStr:

stayStr:
    defb    "S"
XstayStr:

updateEndStr:
    defb    "D"
XupdatEndStr:

maxStr:
    defb    "M"
XmaxStr:

noMaxStr:
    defb    "N"
XnoMaxStr:

noMouseStr:
    defb    "A"
XnoMouseStr:

seed:       defw 0

mousePace:  equ 4
maxY:       equ levelBottommostPixel - mousePixelHeight
minY:       equ levelTopmostPixel
maxX:       equ levelRightmostPixel - mousePixelWidth - 3
minX:       equ levelLeftmostPixel
couchX:     equ 200
holeX:      equ 100
spawnTime:  equ 125
randomTime: equ 25
wallTime:   equ 20
spawnChance:    equ 4
wallSpawn:  equ 1

; cp 1
; jr z, firstOne
; firstZero:
; call random
; and 1
;
; push af
; ld b, 0
; ld c, a
; call $2d2b
; call $2de3
; pop af
;
; cp 1
; jr z, zeroOne
; zeroZero:
; ld a, 0
; jr decisionCp
; zeroOne:
; ld a, 1
; jr decisionCp
; firstOne:
; call random
; and 1
;
; push af
; ld b, 0
; ld c, a
; call $2d2b
; call $2de3
; pop af
;
; cp 1
; jr z, oneOne
; oneZero:
; ld a, 2
; jr decisionCp
; oneOne:
; ld a, 3






; cp 1
; jr z, firstOne
; firstZero:
; call random         ; get random number
; and 1             ; range 0-99
;
; push af
; ld b, 0
; ld c, a
; call $2d2b
; call $2de3
; pop af
;
; cp 1
; jr z, zeroOne
; zeroZero:
; call random         ; get random number
; and 1             ; range 0-99
;
; push af
; ld b, 0
; ld c, a
; call $2d2b
; call $2de3
; pop af
;
; cp 1
; jr z, zero2One
; zero3:
; ld a, 0
; jr decisionCp
; zero2One:
; ld a, 1
; jr decisionCp
; zeroOne:
; call random         ; get random number
; and 1             ; range 0-99
;
; push af
; ld b, 0
; ld c, a
; call $2d2b
; call $2de3
; pop af
;
; cp 1
; jr z, zeroOne2
; zeroOneZero:
; ld a, 2
; jr decisionCp
; zeroOne2:
; ld a, 3
; jr decisionCp
; firstOne:
; call random         ; get random number
; and 1             ; range 0-99
;
; push af
; ld b, 0
; ld c, a
; call $2d2b
; call $2de3
; pop af
;
; cp 1
; jr z, oneOne
; oneZero:
; call random         ; get random number
; and 1             ; range 0-99
;
; push af
; ld b, 0
; ld c, a
; call $2d2b
; call $2de3
; pop af
;
; cp 1
; jr z, oneZeroOne
; oneZero2:
; ld a, 4
; jr decisionCp
; oneZeroOne:
; ld a, 5
; jr decisionCp
; oneOne:
; call random         ; get random number
; and 1             ; range 0-99
;
; push af
; ld b, 0
; ld c, a
; call $2d2b
; call $2de3
; pop af
;
; cp 1
; jr z, one3
; one2Zero:
; ld a, 6
; jr decisionCp
; one3:
; ld a, 7
