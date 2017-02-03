        org $8000

        include "defines.asm"

main:
        ld a,2                 ; upper screen
        call openChannel

        ld de,footer
        ld (test1),de
        ld bc,Xfooter-footer
        ld (test1 + 2),bc

        ld de,banner
        ld bc,Xbanner-banner
        call print

        ld de,(test1)
        ld bc,(test1 + 2)
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
	include "update.asm"
        include "keyboarddisp.asm"
