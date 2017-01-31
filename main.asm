        org $8000

        include "defines.asm"

        ;; defvars 0
        ;; {
        ;; test1 ds.p 1
        ;; test2 ds.p 1
        ;; }



main:
        ld  a,2                 ; upper screen
        call    $1601           ; open channel

        ld de,banner
        ld bc,Xbanner-banner
        call print

        call pmain

        ld de,footer
        ld bc,Xfooter-footer
        call print

endProg:
        nop
        jp endProg

banner:
        defb "Start of main", newline
Xbanner:

footer:
        defb "Should never see this", newline
Xfooter:
        include "keyboarddisp.asm"
