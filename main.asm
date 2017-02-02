        org $8000

        include "defines.asm"

main:
        ld a,2                 ; upper screen
        call openChannel

        ld de,footer
        ld (global + test1),de
        ld bc,Xfooter-footer
        ld (global + test2),bc

        ld de,banner
        ld bc,Xbanner-banner
        call print

        ld de,(global + test1)
        ld bc,(global + test2)
        call print

        call keyboard_main

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


global:
