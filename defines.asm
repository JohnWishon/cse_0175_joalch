        ;; Functions
print:          equ $203c
openChannel:    equ $1601

        ;; Constants
newline:        equ 13

        ;; Globals
test1:  defw 0
test2:  defw 0

        ;; define a constant foo = 12 --> foo: equ 12

        ;; create a single word variable: foo: defw 0
        ;; - the memory location at foo now contains 0
        ;; - this value can be overwritten with ld (foo),[reg/imm]

        ;; create an array of words: foo: defw 0, 0, ..., 0
        ;; - the m memory locations at foo now contain 0
        ;; - the nth location can be overwritten with ld (foo + n),[reg/imm]
