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

numCats:        equ 2
numMice:        equ 4           ; TODO: Amanda


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

IF (LOW($) & %0000$1111) != 0
        org (($ + 16) & %1111$0000)
ENDIF

tileInstanceBase:
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
        ;; the tile at level location <n + 1, m + 1>, and the upper 4 bits
        ;; represent an address of one of the tile instances. Tile instances are
        ;; paddedto 16 bytes. This means that we can represent exactly 16 types
        ;; of tiles in the environment!

        ;; Less than the actual entire screen is represented here. The bottom
        ;; row of tiles is guaranteed to be "floor" and the left and right
        ;; columns are guaranteed to be "wall". The top 3 rows are guaranteed
        ;; to be UI area, which is outside the purview of our simulation,
        ;; and the 2 rows immediately beneath the UI are guaranteed to be
        ;; empty since the cats need to be able to get to the top of the
        ;; level. This means the array of interactable blocks needs to be
        ;; 30 * 18 tiles.

        ;; - gameLevel[0][0] is the top-left corner of the interactable area.
        ;; So one tile from the left of the screen, and 5 tiles from the top.
        ;; - gameLevel[29][17] is the bottom-right corner of the interactable
        ;; area. So 30 + 1 tiles from the left of the screen, and 18 + 5 tiles
        ;; from the top.

gameLevel:      defs (30 * 18)  ; should zero-fill 30 * 18 bytes
        ;; http://pasmo.speccy.org/pasmodoc.html#dirds

fuNoUpdateB:    equ #FF
fuNoUpdateW:    equ #FFFF
        ;; - This is the updates array produced at the end of an update frame.
        ;; The data layout looks like this:
        ;; |cat1 new|cat2 new|mouse1 new|...|mouseN new|tile1 new|tile2 new|
        ;; |cat2 old|cat2 old|mouse1 old|...|mouseN old|tile1 old|tile2 old|

        ;; - For any frame, 1 .. 2 can move, 1 .. numMice can move, and since
        ;; each cat can attack 1 block per frame, up to 2 blocks can change in a
        ;; frame. To use this, one could load fuNewState into IX:

        ;; ld ix,fuNewState

        ;; To load the index tile2 idx:
        ;; ld a, (ix + (numCats + numMice + 1))

        ;; To load the old state of tile2:
        ;; ld a, (ix + (fuOldStateOffset + numCats + numMice + 1))

        ;; For Cats:
        ;; TODO: determine what new and old mean

        ;; For Mice:
        ;; TODO: determine what new and old mean

        ;; For Tiles:
        ;; - tileN new: This is an index into the gameLevel array. This index
        ;; tells you what <x,y> coordinate the block is at subject to the
        ;; constraints specified in the docuemnation for the gameLevel array.
        ;; The tile at that location can be found in the gameLevel array
        ;; - tileN old: This is an index into tileInstanceBase to get the
        ;; old tile if needed.

        ;; If any of these have the value fuNoUpdateB or fuNoUpdateW (for byte
        ;; or word) then there is no update and should be skipped


fuNewState: defs numCats
            defs numMice
            defs (numCats * 2) ; These need to be words because 30 * 18 > 255
                               ; and this is an index into gameLevel
fuOldState: defs numCats
            defs numMice
            defs (numCats) ; These do not need to be words because there are
                           ; only 16 kinds of tiles, and this is an index into
                           ; tileInstanceBase

fuOldStateOffset:       equ fuOldState - fuNewState
