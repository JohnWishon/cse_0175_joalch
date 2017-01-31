;org $8000
pmain:
    ld  a,2                 ; upper screen
    call    $1601           ; open channel
ploop:
    xor a                   ; clear a
    ld  bc,64510            ; load port number of W
    in  e,(c)               ; read port value

    rr  e
    rr  e                   ; Shifted W value to carry bit
    jp  c,w_not_pressed     ; 1 = key not pressed

    or 8                    ; mark 4th bit of a
w_not_pressed:
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
    ; start processing keyboard signals to strings.
    dec a                   ; a--
    call    z,d_pressed     ; if original a = 1, only d pressed

    dec a
    call    z,s_pressed     ; if original a = 2, only s pressed

    dec a
    call    z,sd_pressed    ; if original a = 3, s and d pressed

    dec a
    call    z,a_pressed     ; if original a = 4, only a pressed

    sub 2
    call    z,as_pressed    ; if original a = 6, a and s pressed
    ; subroutines before this line optimized for early termination
    sub 2
    call    z,w_pressed     ; if original a = 8, only w pressed

    dec a
    call    z,wd_pressed    ; if original a = 9, w and d pressed;

    sub 3
    call    z,wa_pressed    ; if original a = 12, w and a pressed

cycle_closing:
    halt
    jp  ploop                ; repeat

d_pressed:
    ld  de,estr             ; addr. of "East" string
    ld  bc,Xestr-estr
    call    $203c           ; print our string
    pop hl
    ld  hl,cycle_closing
    push    hl              ; Modify return addr. for early termination.
    ret

s_pressed:
    ld  de,sstr             ; addr. of "South" string
    ld  bc,Xsstr-sstr
    call    $203c           ; print our string
    pop hl
    ld  hl,cycle_closing
    push    hl              ; Modify return addr. for early termination.
    ret

sd_pressed:
    ld  de,sestr             ; addr. of "Southeast" string
    ld  bc,Xsestr-sestr
    call    $203c           ; print our string
    pop hl
    ld  hl,cycle_closing
    push    hl              ; Modify return addr. for early termination.
    ret

a_pressed:
    ld  de,wstr             ; addr. of "West" string
    ld  bc,Xwstr-wstr
    call    $203c           ; print our string
    pop hl
    ld  hl,cycle_closing
    push    hl              ; Modify return addr. for early termination.
    ret

as_pressed:
    ld  de,swstr             ; addr. of "Southwest" string
    ld  bc,Xswstr-swstr
    call    $203c           ; print our string
    pop hl
    ld  hl,cycle_closing
    push    hl              ; Modify return addr. for early termination.
    ret

w_pressed:
    ld  de,nstr             ; addr. of "North" string
    ld  bc,Xnstr-nstr
    call    $203c           ; print our string
    ret

wd_pressed:
    ld  de,nestr             ; addr. of "Northeast" string
    ld  bc,Xnestr-nestr
    call    $203c           ; print our string
    ret

wa_pressed:
    ld  de,nwstr             ; addr. of "Northwest" string
    ld  bc,Xnwstr-nwstr
    call    $203c           ; print our string
    ret

nstr:
    defb    "North", 13
Xnstr:
estr:
    defb    "East", 13
Xestr:
wstr:
    defb    "West", 13
Xwstr:
sstr:
    defb    "South", 13
Xsstr:

nestr:
    defb    "Northeast", 13
Xnestr:
sestr:
    defb    "Southeast", 13
Xsestr:
nwstr:
    defb    "Northwest", 13
Xnwstr:
swstr:
    defb    "Southwest", 13
Xswstr:
    ;xdef    pmain
.end