updateCollision:
        ;; ld  de,collisionStr
        ;; ld  bc,XcollisionStr-collisionStr
        ;; call    print
        ret

collisionStr:
    defb    "updateCollision", newline
XcollisionStr:
