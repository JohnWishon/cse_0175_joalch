displayKeystate:
loop:
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
    or 4                    ; mark 3th bit
a_not_pressed:
    rr  e                   ; S value -> carry
    jp  c,s_not_pressed
    or 2                    ; mark 2th bit
s_not_pressed:
    rr  e                   ; D value -> carry
    jp  c,d_not_pressed
    or 1                    ; mark 1th bit
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

    call    punch_handler
process_movement:
    pop af                  ; retrieve a
    and $0f
    dec a                   ; a--
    call    z,d_handler     ; if original a = 1, only d pressed

    dec a
    call    z,s_handler     ; if original a = 2, only s pressed

    dec a
    call    z,sd_handler    ; if original a = 3, s and d pressed

    dec a
    call    z,a_handler     ; if original a = 4, only a pressed

    sub 2
    call    z,as_handler    ; if original a = 6, a and s pressed
    ; subroutines before this line optimized for early termination
    sub 2
    call    z,w_handler     ; if original a = 8, only w pressed

    dec a
    call    z,wd_handler    ; if original a = 9, w and d pressed;

    sub 3
    call    z,wa_handler    ; if original a = 12, w and a pressed

cycle_closing:
    ret

jump_handler:
    ld  de,jumpstr          ; addr. of "Jump" string
    ld  bc,Xjumpstr-jumpstr
    call    print           ; print our string
    pop hl
    ld  hl,cycle_closing
    push    hl              ; Modify return addr. for early termination.
    ret

punch_handler:
    ld  de,punchstr         ; addr. of "Punch " string
    ld  bc,Xpunchstr-punchstr
    call    print           ; print our string
    ret

d_handler:
    ld  de,estr             ; addr. of "East" string
    ld  bc,Xestr-estr
    call    print           ; print our string
    pop hl
    ld  hl,cycle_closing
    push    hl              ; Modify return addr. for early termination.
    ret

s_handler:
    ld  de,sstr             ; addr. of "South" string
    ld  bc,Xsstr-sstr
    call    print           ; print our string
    pop hl
    ld  hl,cycle_closing
    push    hl              ; Modify return addr. for early termination.
    ret

sd_handler:
    ld  de,sestr             ; addr. of "Southeast" string
    ld  bc,Xsestr-sestr
    call    print           ; print our string
    pop hl
    ld  hl,cycle_closing
    push    hl              ; Modify return addr. for early termination.
    ret

a_handler:
    ld  de,wstr             ; addr. of "West" string
    ld  bc,Xwstr-wstr
    call    print           ; print our string
    pop hl
    ld  hl,cycle_closing
    push    hl              ; Modify return addr. for early termination.
    ret

as_handler:
    ld  de,swstr             ; addr. of "Southwest" string
    ld  bc,Xswstr-swstr
    call    print           ; print our string
    pop hl
    ld  hl,cycle_closing
    push    hl              ; Modify return addr. for early termination.
    ret

w_handler:
    ld  de,nstr             ; addr. of "North" string
    ld  bc,Xnstr-nstr
    call    print           ; print our string
    ret

wd_handler:
    ld  de,nestr             ; addr. of "Northeast" string
    ld  bc,Xnestr-nestr
    call    print           ; print our string
    ret

wa_handler:
    ld  de,nwstr             ; addr. of "Northwest" string
    ld  bc,Xnwstr-nwstr
    call    print           ; print our string
    ret

punchstr:
    defb    "Punch "
Xpunchstr:
jumpstr:
    defb    "Jump", newline
Xjumpstr:

nstr:
    defb    "North", newline
Xnstr:
estr:
    defb    "East", newline
Xestr:
wstr:
    defb    "West", newline
Xwstr:
sstr:
    defb    "South", newline
Xsstr:

nestr:
    defb    "Northeast", newline
Xnestr:
sestr:
    defb    "Southeast", newline
Xsestr:
nwstr:
    defb    "Northwest", newline
Xnwstr:
swstr:
    defb    "Southwest", newline
Xswstr:
