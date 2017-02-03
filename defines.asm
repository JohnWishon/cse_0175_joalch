        ;; ---------------------------------------------------------------------
        ;; Functions
        ;; ---------------------------------------------------------------------
print:          equ $203c
openChannel:    equ $1601

        ;; ---------------------------------------------------------------------
        ;; Constants
        ;; ---------------------------------------------------------------------
newline:        equ 13

smLoadingScreen: equ %0000$0000
smGreetzChris:   equ %0000$0001
smGreetzJohn:    equ %0000$0010
smGreetzAmanda:  equ %0000$0011
smGreetzHuajie:  equ %0000$0100
smGreetzAll:     equ %0000$0101
smTitleScreen:   equ %0000$0110
smLevelIntro:    equ %0000$0111
smPlayableLevel: equ %0000$1000
smGameOver:      equ %0000$1001

        ;; ---------------------------------------------------------------------
        ;; Globals
        ;; ---------------------------------------------------------------------
stateMachine:   defb smLoadingScreen

        ;; define a constant foo = 12 --> foo: equ 12

        ;; create a single word variable: foo: defw 0
        ;; - the memory location at foo now contains 0
        ;; - this value can be overwritten with ld (foo),[reg/imm]

        ;; create an array of words: foo: defw 0, 0, ..., 0
        ;; - the m memory locations at foo now contain 0
        ;; - the nth location can be overwritten with ld (foo + n),[reg/imm]
