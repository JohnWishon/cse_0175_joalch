updateAI:
        ld ix, mouseUpdatesBase    ; load mouse movement
        ld a, (ix)          ; Load direction
        rra                 ; rotate lsb into carry
        jr nc, mouseVert    ; no carry = 0 or 2 - vertical movement

        ; direction is 1 or 3 - horizontal
        rra                 ; rotate lsb into carry
        jr nc, mouseRight   ; no carry = 1 - move right

; move mouse left
mouseLeft:
        ld a, (ix + 2)      ; Load current x coord
        ld (ix + 1), a      ; Save current x into old x
        sub mousePace       ; Move left by 4
        ld (ix + 2), a      ; Save new x into current x
        cp minX                ; reached min x?
        jr z, mouseChange   ; yes - turn around
        jr c, mouseChange   ; went past min
        ret

; move mouse right
mouseRight:
        ld a, (ix + 2)      ; Load current x coord
        ld (ix + 1), a      ; Save current x into old x
        add a, mousePace    ; Move right by 4
        ld (ix + 2), a      ; Save new x into current x
        cp maxX             ; reached max x?
        jr nc, mouseChange  ; yes - turn around
        ret

;move mouse vertically
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

mousePace:  equ 4
maxY:       equ levelBottommostPixel
minY:       equ levelTopmostPixel
maxX:       equ levelRightmostPixel
minX:       equ levelLeftmostPixel
