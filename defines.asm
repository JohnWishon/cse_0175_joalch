        ;; ---------------------------------------------------------------------
        ;; Functions
        ;; ---------------------------------------------------------------------
print:          equ $203c
openChannel:    equ $1601
        ;; HL = HL * DE
multiply:       equ $30A9

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

        ;; movement states
movementStateGround:   equ %0000$0000
movementStateJumping:  equ %0000$0001
movementStateFalling:  equ %0000$0010
movementStateClimbing: equ %0000$0100

        ;; tile gameplay attributes
tgaNone:            equ %0000$0000
tgaPassable:        equ %0001$0000
tgaStandable:       equ %0010$0000
tgaClimbable:       equ %0100$0000
tgaDrainsInterest:  equ %1000$0000
tgaDestroyableMask: equ %0000$1111

numCats:        equ 2
numMice:        equ 4           ; TODO: Amanda

catWidth:       equ 2           ; in tiles
catPixelWidth:  equ (catWidth << 3)
catHeight:      equ 2           ; in tiles
catPixelHeight: equ (catHeight << 3)

catPoseFacingLeft:  equ %0000$0001
catPoseFacingRight: equ %0000$0010
catPoseHighPunch:   equ %0000$0100
catPoseLowPunch:    equ %0000$1000

levelLeftmostCol:     equ 1
levelRightmostPixel:  equ (levelRightmostCol << 3)
levelRightmostCol:    equ 30
levelRightmostPixel:  equ ((levelRightmostCol << 3) + 7)
levelTopmostRow:      equ 5
levelTopmostPixel:    equ (levelTopmostRow << 3)
levelBottommostRow:   equ 22
levelBottommostPixel: equ ((levelBottommostRow << 3) + 7)

levelDummyTileMask:   equ %0000$1111
levelTileIndexMask:   equ %1111$0000

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

p1StateBase:
p1DirPressed: defb 0, 0, 0, 0 ; Directions: Up, Down, Left, Right
p1JPressed: defb 0
p1PPressed: defb 0

p1MovX:     defb 0
p1MovY:     defb 0
p1MovementState: defb movementStateGround

p1PosX: defb 0
p1PosY: defb 0
p1Pose: defb catFacingRight

p2StateBase:
p2DirPressed: defb 0, 0, 0, 0 ; Directions: Up, Down, Left, Right
p2JPressed: defb 0
p2PPressed: defb 0

p2MovX:     defb 0
p2MovY:     defb 0
p2MovementState: defb movementStateGround

p2PosX: defb 0
p2PosY: defb 0
p2Pose: defb catFacingLeft



IF (LOW($) & %0000$1111) != 0
        org (($ + 16) & #FFF0)
ENDIF

        ;; Instances of changable tiles
        ;; TODO: all bitmap data
        ;; layout:
        ;;   |b0|b1|b2|b3|b4|b5|b6|b7| -> graphics pixel data
        ;;   |attr| -> graphics attribute
        ;;   |gameplay attribute| -> gameplay attribute
        ;;   |next tile|next tile| -> tile to transition to if this one is
        ;;                            destroyed. This should be placed in the
        ;;                            graphics update array
        ;;   |next game level index| -> next gameLevel index, to be placed in
        ;;                              the gameLevel array. This is potentially
        ;;                              not the same as next tile.
        ;;   |pad 1|pad 2|pad3| -> padding to ensure word alignment

dynamicTileInstanceBase:
couchTop: defb 0, 0, 0, 0, 0, 0, 0, 0, 0   ; Graphics data
        defb tgaStandable | tgaPassable| 1 ; Gameplay attribute
        defw couchTopDamaged               ; graphics tile next
        defb HIGH(couchTopDamaged)         ; gameLevel index next
        defb 0, 0, 0                       ; Padding to 16 bytes
couchTopDamaged: defb 0, 0, 0, 0, 0, 0, 0, 0, 0
        defb tgaStandable | tgaPassable | 3
        defw couchTopDestroyed
        defb tgaStandable | tgaPassable
        defb 0, 0, 0
couchCushion: defb 0, 0, 0, 0, 0, 0, 0, 0, 0
        defb tgaStandable | tgaPassable | 1
        defw couchCushionDamaged
        defb HIGH(couchCushionDamaged)
        defb 0, 0, 0
couchCushionDamaged: defb 0, 0, 0, 0, 0, 0, 0, 0, 0
        defb tgaStandable | tgaPassable | 3
        defw couchCushionDestroyed
        defb tgaStandable | tgaPassable
        defb 0, 0, 0
couchSide: defb 0, 0, 0, 0, 0, 0, 0, 0, 0
        defb tgaStandable | tgaClimbable | tgaPassable | 1
        defw couchCushionDamaged
        defb HIGH(couchCushionDamaged)
        defb 0, 0, 0
couchSideDamaged: defb 0, 0, 0, 0, 0, 0, 0, 0, 0
        defb tgaStandable | tgaClimbable | tgaPassable | 3
        defw couchCushionDestroyed
        defb tgaStandable | tgaClimbable | tgaPassable
        defb 0, 0, 0

        ;; ... etc ...

        ;; Static tiles

        ;; Static tile data that needs to be available to draw, but doesn't
        ;; represent a tile that can be changed
        ;;   |b0|b1|b2|b3|b4|b5|b6|b7| -> graphics pixel data
        ;;   |attr| -> graphics attribute
staticTileInstanceBase:
couchTopDestroyed: defb 0, 0, 0, 0, 0, 0, 0, 0, 0
couchCushionDestroyed: defb 0, 0, 0, 0, 0, 0, 0, 0, 0
couchSideDestroyed: defb 0, 0, 0, 0, 0, 0, 0, 0, 0

        ;; Game state

        ;; This is a 2 dimensional array of indices into the instances area.
        ;; state[x][y] is 1 byte, and can represent one of two things:

        ;; - If the lower four bits are not all zero, then this tile can be
        ;; damaged. In this case, the lower 4 bits represent the damage of
        ;; the tile at level location <x, y>, and the upper 4 bits represent
        ;; an address of one of the tile instances. Tile instances are padded
        ;; to 16 bytes. This means that we can represent exactly 16 types of
        ;; damageable tiles in the environment!

        ;; - If the lower four bits are all zero, then this tile cannot be
        ;; damaged. In this case, there is no reason to store any graphics
        ;; data as what is at this screen location will stay there for the
        ;; rest of the life of this level. In this case, the upper four
        ;; bits are the gameplay attributes of this tile. This tile can
        ;; never appear in the frame updates array. The entire range of
        ;; possible gameplay attributes can be represented here

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

gameLevel: defs ((levelRightmostCol - levelLeftmostCol)
                 * (levelBottommostRow - levelTopmostRow))
        ;; define and zero-fill width * height bytes
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

        ;; To load the address of tile2:
        ;; ld a, (ix + (numCats + numMice + 1))

        ;; To load the old state of tile2:
        ;; ld a, (ix + (fuOldStateOffset + numCats + numMice + 1))

        ;; For Cats:
        ;; TODO: determine what new and old mean

        ;; For Mice:
        ;; TODO: determine what new and old mean

        ;; For Tiles:
        ;; - tileN new: This is a pointer to tile data.
        ;; - tileN old: This is an index into tileInstanceBase to get the
        ;; old tile if needed.

        ;; If any of these have the value fuNoUpdateB or fuNoUpdateW (for byte
        ;; or word) then there is no update and should be skipped


fuNewState: defs numCats
            defs numMice
            defs (numCats * 4) ; layout: | tile ptr high byte |
                               ;         | tile ptr low byte  |
                               ;         | x coord | y coord  |


fuOldState: defs numCats
            defs numMice
            defs (numCats) ; These do not need to be words because there are
                           ; only 16 kinds of tiles, and this is an index into
                           ; tileInstanceBase

fuOldStateOffset:       equ fuOldState - fuNewState
