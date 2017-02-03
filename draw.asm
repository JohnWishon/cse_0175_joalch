drawFrame:
        ;; Draw Entity state

        ;; ld  de,drawStr
        ;; ld  bc,XdrawStr-drawStr
        ;; call    print
        ret

drawStr:
    defb    "drawFrame", newline
XdrawStr:
