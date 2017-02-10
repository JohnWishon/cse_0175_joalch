        ;; ---------------------------------------------------------------------
        ;; Functions
        ;; ---------------------------------------------------------------------
print:          equ $203c
openChannel:    equ $1601

        ;; ---------------------------------------------------------------------
        ;; Constants
        ;; ---------------------------------------------------------------------
newline:        equ 13

        ;; state machine states
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

        ;; air states
airStateGround:  equ %0000$0000
airStateJumping: equ %0000$0001
airStateFalling: equ %0000$0010

        ;; tile gameplay attributes
tgaNone:            equ %0000$0000
tgaPassable:        equ %0001$0000
tgaStandable:       equ %0010$0000
tgaClimbable:       equ %0100$0000
tgaDrainsInterest:  equ %1000$0000
tgaDestroyableMask: equ %0000$1111



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

p1DirPressed:   defb 0, 0, 0, 0 ; Directions: Up, Down, Left, Right
p1JPressed: defb 0
p1PPressed: defb 0

p1MovX:     defb 0
p1MovY:     defb 0
p1AirState: defb airStateGround

p2DirPressed:   defb 0, 0, 0, 0 ; Directions: Up, Down, Left, Right
p2JPressed: defb 0
p2PPressed: defb 0

p2MovX:     defb 0
p2MovY:     defb 0
p2AirState: defb airStateGround

        ;; Static tile data
        ;; TODO: add correct bitmap data
        ;; TODO: add all tile types
        ;; layout: |b0|b1|b2|b3|b4|b5|b6|b7|
        ;;         |attr|gameplay attribute|pad 0|pad 1|pad 2|pad 3|pad 4|pad 5|
tileEmpty:          defb 0, 0, 0, 0, 0, 0, 0, 0, 0, tgaPassable
                    defb 0, 0, 0, 0, 0, 0 ; Padding to 16 bytes
tileFloor:          defb 0, 0, 0, 0, 0, 0, 0, 0, 0, tgaStandable
                    defb 0, 0, 0, 0, 0, 0 ; Padding to 16 bytes
tileWall:           defb 0, 0, 0, 0, 0, 0, 0, 0, 0, tgaNone
                    defb 0, 0, 0, 0, 0, 0 ; Padding to 16 bytes
tileCouch:          defb 0, 0, 0, 0, 0, 0, 0, 0, 0, (tgaStandable | tgaClimbable | 1)
                    defb 0, 0, 0, 0, 0, 0 ; Padding to 16 bytes
tileCouchDamaged:   defb 0, 0, 0, 0, 0, 0, 0, 0, 0, (tgaStandable | tgaClimbable | 2)
                    defb 0, 0, 0, 0, 0, 0 ; Padding to 16 bytes
tileCouchDestroyed: defb 0, 0, 0, 0, 0, 0, 0, 0, 0, (tgaStandable | tgaClimbable)
                    defb 0, 0, 0, 0, 0, 0 ; Padding to 16 bytes
tileShelf:          defb 0, 0, 0, 0, 0, 0, 0, 0, 0, (tgaStandable | tgaPassable)
        ;; ... etc ...

        ;; Game state

        ;; - This is a 2 dimensional array of indices into the instances area.
        ;; state[n][m] is 1 byte, where the lower 4 bits represent the damage of
        ;; the tile at screen location <n, m>, and the upper 4 bits represent
        ;; an address of one of the tile instances. Tile instances are padded
        ;; to 16 bytes. This means that we can represent exactly 16 types of
        ;; tiles in the environment!

        ;; Less than the actual entire screen is represented here. The bottom
        ;; row of tiles is guaranteed to be "floor" and the left and right
        ;; columns are guaranteed to be "wall". The top 3 rows are guaranteed
        ;; to be UI area, which is outside the purview of our simulation,
        ;; and the 2 rows immediately beneath the UI are guaranteed to be
        ;; empty since the cats need to be able to get to the top of the
        ;; level. This means the array of interactable blocks needs to be
        ;; 20 * 18 tiles.

gameLevel:      defs (20 * 18)  ; should zero-fill 20 * 18 bytes
        ;; http://pasmo.speccy.org/pasmodoc.html#dirds
