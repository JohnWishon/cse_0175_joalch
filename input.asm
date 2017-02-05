displayKeystate:
    ;   Reset keypress globals
    ld  hl,p1DirPressed
    ld  (hl),0
    inc hl
    ld  (hl),0
    inc hl
    ld  (hl),0
    inc hl
    ld  (hl),0
    inc hl
    ld  (hl),0
    inc hl
    ld  (hl),0

    ; Use register a to store what keys are pressed
    ; from bit 5 to 1: Jump/Punch, Up, Down, Left, Right
    xor a                   ; clear a
    ld  bc,64510            ; load port number of W and R
    in  e,(c)               ; read port value

    rr  e
    rr  e                   ; Shifted W value to carry bit
    jp  c,w_not_pressed     ; 1 = key not pressed
    or  8                   ; mark 4th bit of a
w_not_pressed:
    rr  e
    rr  e                   ; R value to carry bit
    jp  c,r_not_pressed
    or  16                  ; mark 5th bit of a
r_not_pressed:
    ld  bc,65022            ; load port number of A, S, D
    in  e,(c)               ; read val

    rr  e                   ; A value -> carry
    jp  c,a_not_pressed
    or  2                   ; mark 3th bit
a_not_pressed:
    rr  e                   ; S value -> carry
    jp  c,s_not_pressed
    or  4                   ; mark 2th bit
s_not_pressed:
    rr  e                   ; D value -> carry
    jp  c,d_not_pressed
    or  1                   ; mark 1th bit
d_not_pressed:

process_signals:
    ; start processing keyboard signals to strings.
    push    af              ; save a to stack
    and $10                 ; mask out bit for Space
    jp  z,process_movement  ; process case where r is not pressed.
punch_pressed:
    pop af
    push    af
    and $0f
    call    z,jump_handler

handle_punch:

    ld  hl,p1PPressed
    ld  (hl), 1

process_movement:
    pop af                  ; retrieve a
    and $0f
    ld  ix,p1DirPressed     ; Preload addr. of state array

    dec a                   ; a--
    jp  z,d_handler         ; if original a = 1, only d pressed

    dec a
    jp  z,a_handler         ; if original a = 2, only a pressed

    sub 2
    jp  z,s_handler         ; if original a = 4, only s pressed

    dec a
    jp  z,sd_handler        ; if original a = 5, s and d pressed

    dec a
    jp  z,as_handler        ; if original a = 6, a and s pressed

    sub 2
    jp  z,w_handler         ; if original a = 8, only w pressed

    dec a
    jp  z,wd_handler        ; if original a = 9, w and d pressed

    dec a
    jp  z,wa_handler        ; if original a = 10, w and a pressed

cycle_closing:
    ret

jump_handler:
    ld  hl,p1JPressed
    ld  (hl),1
    jp  cycle_closing

d_handler:
    ld  (ix+3),1
    jp  cycle_closing

s_handler:
    ld  (ix+1),1
    jp  cycle_closing

sd_handler:
    ld  (ix+1),1
    ld  (ix+3),1
    jp  cycle_closing

a_handler:
    ld  (ix+2),1
    jp  cycle_closing

as_handler:
    ld  (ix+1),1
    ld  (ix+2),1
    jp  cycle_closing

w_handler:
    ld  (ix+0),1
    jp  cycle_closing

wd_handler:
    ld  (ix+0),1
    ld  (ix+3),1
    jp  cycle_closing

wa_handler:
    ld  (ix+0),1
    ld  (ix+2),1
    jp  cycle_closing
