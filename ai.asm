updateAI:
        ld  de,aiStr
        ld  bc,XaiStr-aiStr
        call    print

        ld ix, mouseMove    ; load mouse movement

        ld b, 0
        ld c, (ix)
        call $2d2b              ; print number
        call $2de3

        ld a, (ix)          ; Load direction
        rra                 ; rotate lsb into carry
        jr nc, mouseVert    ; no carry = 0 or 2 - vertical movement

        ; direction is 1 or 3 - horizontal
        rra                 ; rotate lsb into carry
        jr nc, mouseRight   ; no carry = 1 - move right

; move mouse left
mouseLeft:
        ld  de,leftStr
        ld  bc,XleftStr-leftStr
        call    print

        ld a, (ix + 1)      ; Load current x coord
        ld (ix + 3), a      ; Save current x into old x
        sub 4               ; Move left by 4
        ld (ix + 1), a      ; Save new x into current x
        cp 0                ; reached min x?
        jr z, mouseChange   ; yes - turn around
        jr c, mouseChange   ; went past min
        ret

; move mouse right
mouseRight:
        ld  de,rightStr
        ld  bc,XrightStr-rightStr
        call    print

        ld b, 0
        ld c, (ix + 1)
        call $2d2b              ; print number
        call $2de3

        ld a, (ix + 1)      ; Load current x coord
        ld (ix + 3), a      ; Save current x into old x
        add a, 4            ; Move right by 4
        ld (ix + 1), a      ; Save new x into current x
        cp 230              ; reached max x?
        jr nc, mouseChange  ; yes - turn around
        ret

;move mouse vertically
mouseVert:
        rra                 ; rotate lsb into carry
        jr c, mouseDown     ; carry = 2 - move down

; move mouse up
mouseUp:
        ld  de,upStr
        ld  bc,XupStr-upStr
        call    print

        ld a, (ix + 2)      ; Load current y coord
        ld (ix + 4), a      ; Save current y into old y
        add a, 4            ; Move up by 4
        ld (ix + 2), a      ; Save new y into current y
        cp 192              ; reached max y?
        jr nc, mouseChange  ; yes - turn around
        ret

; move mouse down
mouseDown:
        ld  de,downStr
        ld  bc,XdownStr-downStr
        call    print

        ld a, (ix + 2)      ; Load current y coord
        ld (ix + 4), a      ; Save current y into old y
        sub 4               ; move down
        ld (ix + 2), a       ; Save new y into current y
        cp 0                ; reached min y?
        jr z, mouseChange   ; yes - turn around
        ret

;change mouse direction
mouseChange:
        ld a, (ix)          ; Load direction
        xor 2               ; swap direction left <-> right, up <-> down
        ld (ix), a          ; Save new direction
        ret

aiStr:
    defb    "updateAI", newline
XaiStr:

leftStr:
    defb    "left", newline
XleftStr:

rightStr:
    defb    "right", newline
XrightStr:

upStr:
    defb    "up", newline
XupStr:

downStr:
    defb    "down", newline
XdownStr:
