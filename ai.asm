updateAI:
        ;; ld  de,aiStr
        ;; ld  bc,XaiStr-aiStr
        ;; call    print
        ret

aiStr:
    defb    "updateAI", newline
XaiStr:
