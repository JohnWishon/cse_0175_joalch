updatePhysics:
        ;; ld  de,physicsStr
        ;; ld  bc,XphysicsStr-physicsStr
        ;; call    print
        ret

physicsStr:
    defb    "updatePhysics", newline
XphysicsStr:
