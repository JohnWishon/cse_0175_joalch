        ;; The global struct

        ;; ds.b -> byte
        ;; ds.w -> word
        ;; ds.p -> "3-byte pointer", whaterver that is
        ;; ds.l -> double-word

        ;; these lables are the *offsets* past global to be used. so to get a field
        ;; test1, I do (global + test1)

        defc globalAddr = global
        defvars globalAddr
        {
        test1 ds.p 1
        test2 ds.p 1
        }

        ;; Functions
        defc print = $203c
        defc openChannel = $1601

        ;; Constants
        defc newline = 13
