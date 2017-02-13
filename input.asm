updateKeystate:
    ld  d,2
p1_init:
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
    ld  ix,p1DirPressed

    ; Use register a to store what keys are pressed
    ; from bit 5 to 1: Jump, Punch, Up, Down, Left, Right
    xor a                   ; clear a
    ld  bc,$fdfe            ; load port number of A, S, D
    in  e,(c)               ; read port value

    rr  e                     ; Shifted A value to carry bit
    jp  c,p1_jmp_not_pressed  ; 1 = key not pressed
    or  $20                   ; mark 6th bit
p1_jmp_not_pressed:
    rr  e                     ; Shifted S value to carry bit
    jp  c,p1_up_not_pressed   ; 1 = key not pressed
    or  $08                   ; mark 4th bit
p1_up_not_pressed:
    rr  e                     ; D value to carry bit
    jp  c,p1_pch_not_pressed
    or  $10                   ; mark 5th bit of a
p1_pch_not_pressed:
    ld  bc,$fefe            ; load port number of A, S, D
    in  e,(c)               ; read val
    rr  e

    rr  e                       ; Z value -> carry
    jp  c,p1_left_not_pressed
    or  $02                     ; mark 2th bit
p1_left_not_pressed:
    rr  e                   ; X value -> carry
    jp  c,p1_down_not_pressed
    or  $04                 ; mark 3th bit
p1_down_not_pressed:
    rr  e                   ; C value -> carry
    jp  c,p1_right_not_pressed
    or  $01                 ; mark 1th bit
p1_right_not_pressed:
    jp  process_signals

p2_init:
    ;   Reset keypress globals
    ld  hl,p2DirPressed
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
    ld  ix,p2DirPressed

    ; Use register a to store what keys are pressed
    ; from bit 5 to 1: Jump, Punch, Up, Down, Left, Right
    xor a                   ; clear a
    ld  bc,$effe            ; load port number of Alpha0, Alpha9, Alpha8
    in  e,(c)               ; read port value

    rr  e                     ; Shifted Alpha0 value to carry bit
    jp  c,p2_pch_not_pressed
    or  $10                   ; mark 5th bit
p2_pch_not_pressed:
    rr  e                     ; Shifted Alpha9 value to carry bit
    jp  c,p2_up_not_pressed
    or  $08                   ; mark 4th bit
p2_up_not_pressed:
    rr  e                     ; Alpha8 value to carry bit
    jp  c,p2_jmp_not_pressed
    or  $20                   ; mark 6th bit
p2_jmp_not_pressed:
    ld  bc,$dffe              ; load port number of P, O, I
    in  e,(c)                 ; read val

    rr  e                     ; P value -> carry
    jp  c,p2_right_not_pressed
    or  $01                   ; mark 1th bit
p2_right_not_pressed:
    rr  e                     ; O value -> carry
    jp  c,p2_down_not_pressed
    or  $04                   ; mark 3th bit
p2_down_not_pressed:
    rr  e                     ; I value -> carry
    jp  c,p2_left_not_pressed
    or  $02                   ; mark 2th bit
p2_left_not_pressed:

process_signals:
    ; start translating keyboard signals to state machine entries.
    ld  e,a                     ; Save a
    and $20                     ; mask out bit for Jump
    call    nz,jump_handler     ; process case where Jump is pressed.
    ld  a,e
    and $10                     ; mask out bit for Punch
    call    nz,punch_handler    ; process case where Punch is pressed.

    ld  a,e
    and $0f

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

input_cycle_closing:
    dec d
    ret z
    jp  p2_init

jump_handler:
    ld  (ix+4),1
    ret

punch_handler:
    ld  (ix+5),1
    ret

d_handler:
    ld  (ix+3),1
    jp  input_cycle_closing

s_handler:
    ld  (ix+1),1
    jp  input_cycle_closing

sd_handler:
    ld  (ix+1),1
    ld  (ix+3),1
    jp  input_cycle_closing

a_handler:
    ld  (ix+2),1
    jp  input_cycle_closing

as_handler:
    ld  (ix+1),1
    ld  (ix+2),1
    jp  input_cycle_closing

w_handler:
    ld  (ix+0),1
    jp  input_cycle_closing

wd_handler:
    ld  (ix+0),1
    ld  (ix+3),1
    jp  input_cycle_closing

wa_handler:
    ld  (ix+0),1
    ld  (ix+2),1
    jp  input_cycle_closing
