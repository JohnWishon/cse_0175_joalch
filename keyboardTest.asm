    org $8000
    jp  main
    include "defines.asm"
main:
    ;; ---------------------------------------------------------------------
    ;; Setup program state, interrupt handling scheme
    ;; ---------------------------------------------------------------------

    ld a,2                 ; upper screen
    call openChannel

        ; Just a main loop. Easy enough to read
updateIteration:
    call updateKeystate

    call test_display_key_string

    halt
    jp updateIteration
    jp endProg

endProg:
    nop
    jp endProg

test_display_key_string:
    ld  a,(p1JPressed)
    add a,0                     ; Apparently ld doesn't set flags, so here we go
    call    nz,jump_tester      ; Test jump signal
    ld  a,(p1PPressed)
    add a,0
    call    nz,punch_tester     ; Test punch signal

    ld  ix,p1DirPressed         ; Figure out which direction keys are pressed.
    ; First check if exceeding signals were recorded.
    ld  a,(ix+0)
    add a,(ix+1)
    add a,(ix+2)
    add a,(ix+3)
    cp  3
    jp  z,error_print
    cp  4
    jp  z,error_print

    ; Then check conflicting key pairs (Up+Down, and Left+Right)
    xor a
    ld  a,(ix+0)
    add a,(ix+1)
    cp  2
    jp  z,error_print

    xor a
    ld  a,(ix+2)
    add a,(ix+3)
    cp  2
    jp  z,error_print

    ld  a,(ix+0)
    add a,0
    jp  z,test_not_w

    ld  a,(ix+2)
    add a,0
    jp  nz,wa_tester
    ld  a,(ix+3)
    add a,0
    jp  nz,wd_tester
    jp  w_tester
test_not_w:
    ld  a,(ix+1)
    add a,0
    jp  z,test_not_s

    ld  a,(ix+2)
    add a,0
    jp  nz,sa_tester
    ld  a,(ix+3)
    add a,0
    jp  nz,sd_tester
    jp  s_tester
test_not_s:
    ld  a,(ix+2)
    add a,0
    jp nz,a_tester
    ld  a,(ix+3)
    add a,0
    jp nz,d_tester
    ;call empty_print
test_closing_cycle:
        ret


jump_tester:
    ld  de,jumpstr          ; addr. of "Jump" string
    ld  bc,Xjumpstr-jumpstr
    call    print           ; print our string
    ret

punch_tester:
    ld  de,punchstr         ; addr. of "Punch " string
    ld  bc,Xpunchstr-punchstr
    call    print           ; print our string
    ret

d_tester:
    ld  de,estr             ; addr. of "East" string
    ld  bc,Xestr-estr
    call    print           ; print our string
    jp  test_closing_cycle

s_tester:
    ld  de,sstr             ; addr. of "South" string
    ld  bc,Xsstr-sstr
    call    print           ; print our string
    jp  test_closing_cycle

sd_tester:
    ld  de,sestr             ; addr. of "Southeast" string
    ld  bc,Xsestr-sestr
    call    print           ; print our string
    jp  test_closing_cycle

a_tester:
    ld  de,wstr             ; addr. of "West" string
    ld  bc,Xwstr-wstr
    call    print           ; print our string
    jp  test_closing_cycle

sa_tester:
    ld  de,swstr             ; addr. of "Southwest" string
    ld  bc,Xswstr-swstr
    call    print           ; print our string
    jp  test_closing_cycle

w_tester:
    ld  de,nstr             ; addr. of "North" string
    ld  bc,Xnstr-nstr
    call    print           ; print our string
    jp  test_closing_cycle

wd_tester:
    ld  de,nestr             ; addr. of "Northeast" string
    ld  bc,Xnestr-nestr
    call    print           ; print our string
    jp  test_closing_cycle

wa_tester:
    ld  de,nwstr             ; addr. of "Northwest" string
    ld  bc,Xnwstr-nwstr
    call    print           ; print our string
    jp  test_closing_cycle

error_print:
    call test_print_error
    jp  test_closing_cycle

    include "input.asm"
    include "testUtil.asm"
