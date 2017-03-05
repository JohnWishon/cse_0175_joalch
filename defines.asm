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

        ;; 8 contiguous bytes of %0000$0000
zeroTile:       equ $3D00

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
movementStateGround:   equ %0000$0001
movementStateJumping:  equ %0000$0010
movementStateFalling:  equ %0000$0100
movementStateClimbing: equ %0000$1000

        ;; collision states
collisionStateBlockedUp:        equ %0000$0001
collisionStateBlockedDown:      equ %0000$0010
collisionStateBlockedLeft:      equ %0000$0100
collisionStateBlockedRight:     equ %0000$1000

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


levelLeftmostCol:     equ 0
levelLeftmostPixel:   equ (levelLeftmostCol << 3)
levelRightmostCol:    equ 32
levelRightmostPixel:  equ ((levelRightmostCol << 3) + 7)
levelTopmostRow:      equ 2
levelTopmostPixel:    equ (levelTopmostRow << 3)
levelBottommostRow:   equ 23
levelBottommostPixel: equ ((levelBottommostRow << 3) + 7)
levelPixelWidth:      equ levelRightmostPixel - levelLeftmostPixel
levelPixelHeight:     equ levelBottommostPixel - levelTopmostPixel
levelTileWidth:     equ levelRightmostCol - levelLeftmostCol
levelTileHeight:    equ levelBottommostRow - levelTopmostRow

levelDummyTileMask:   equ %0000$1111
levelTileIndexMask:   equ %1111$0000

screenTileWidth:    equ 32
screenTileHeight:   equ 24

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
p1CollisionState: defb 0

p2StateBase:
p2DirPressed: defb 0, 0, 0, 0 ; Directions: Up, Down, Left, Right
p2JPressed: defb 0
p2PPressed: defb 0

p2MovX:     defb 0
p2MovY:     defb 0
p2MovementState: defb movementStateGround
p2CollisionState: defb 0

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
        defb HIGH(couchTopDamaged) | 3     ; gameLevel index next
        defb 0, 0, 0                       ; Padding to 16 bytes
couchTopDamaged: defb 0, 0, 0, 0, 0, 0, 0, 0, 0
        defb tgaStandable | tgaPassable | 3
        defw staticTileCouchTopDestroyed
        defb tgaStandable | tgaPassable
        defb 0, 0, 0
couchCushion: defb 0, 0, 0, 0, 0, 0, 0, 0, 0
        defb tgaStandable | tgaPassable | 1
        defw couchCushionDamaged
        defb HIGH(couchCushionDamaged) | 3
        defb 0, 0, 0
couchCushionDamaged: defb 0, 0, 0, 0, 0, 0, 0, 0, 0
        defb tgaStandable | tgaPassable | 3
        defw staticTileCouchCushionDestroyed
        defb tgaStandable | tgaPassable
        defb 0, 0, 0
couchSide: defb 0, 0, 0, 0, 0, 0, 0, 0, 0
        defb tgaStandable | tgaClimbable | tgaPassable | 1
        defw couchCushionDamaged
        defb HIGH(couchCushionDamaged) | 3
        defb 0, 0, 0
couchSideDamaged: defb $CA, $FE, 0, 0, $BA, $BE, 0, 0, %10$100$001
        defb tgaStandable | tgaClimbable | tgaPassable | 3
        defw staticTileCouchCushionDestroyed
        defb tgaStandable | tgaClimbable | tgaPassable
        defb 0, 0, 0
dynamicTileTestImpassableOneHealth: defb 255, 127, 63, 31, 15, 7, 3, 1, %00$100$010
        defb tgaStandable | 1
        defw staticTileTestImpassableDestroyed
        defb tgaStandable
        defb 0, 0, 0

        ;; ... etc ...

        ;; Static tiles

        ;; Static tile data that needs to be available to draw, but doesn't
        ;; represent a tile that can be changed
        ;;   |b0|b1|b2|b3|b4|b5|b6|b7| -> graphics pixel data
        ;;   |attr| -> graphics attribute
staticTileInstanceBase:
staticTileCouchTopDestroyed: defb 0, 0, 0, 0, 0, 0, 0, 0, 0
staticTileCouchCushionDestroyed: defb 0, 0, 0, 0, 0, 0, 0, 0, 0
staticTileCouchSideDestroyed: defb 0, 0, 0, 0, 0, 0, 0, 0, 0
staticTileBackground: defb 0, 0, 0, 0, 0, 0, 0, 0, %01$111$111
staticTileTestImpassableDestroyed: defb $DE, 0, $AD, 0, $BE, 0, $EF, $0F, %00$010$001

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

gameLevel: defs (levelTileWidth * levelTileHeight), tgaPassable
gameLevelEnd:
        ;; define and zero-fill width * height bytes
        ;; http://pasmo.speccy.org/pasmodoc.html#dirds


        ;; Frame updates produced by the update frame. In a frame, a cat can:
        ;; - move: For players 1 and 2, an old/new x and y position are given
        ;;         in pixels. If old == new, then no movement happened
        ;; - change its pose: Based on things like air state and if the cat
        ;;                    is violencing something, its pose may change.
        ;;                    Values this bitfield can take on are in
        ;;                    catPose*. If the catPoseFaceLeft bit is not
        ;;                    set then it is facing right. If old == new,
        ;;                    then the pose is unchanged from last frame
        ;; - damage a block: if a cat damages a block, then the tile pointer
        ;;                   will not be 0. In this case, tileChangeX/Y are in
        ;;                   units of screen tiles

                ;; cat poses
catPoseJump:      equ %0000$0001
catPoseClimb:     equ %0000$0010
catPoseWalk:      equ %0000$0100
catPoseAttack:    equ %0000$1000
catPoseAttackLow: equ %0001$0000
        ;; ...
catPoseFaceLeft: equ %1000$0000
catPoseFaceLeftClearMask: equ %0111$1111

fuP1UpdatesBase:
fuP1UpdatesOldPosX:       defb 0
fuP1UpdatesNewPosX:       defb 0
fuP1UpdatesOldPosY:       defb 0
fuP1UpdatesNewPosY:       defb 0
fuP1UpdatesOldPose:       defb 0
fuP1UpdatesNewPose:       defb 0
fuP1UpdatesTileChangeX:   defb 0
fuP1UpdatesTileChangeY:   defb 0
fuP1UpdatesTileChangePtr: defw 0

fuP2UpdatesBase:
fuP2UpdatesOldPosX:       defb 0
fuP2UpdatesNewPosX:       defb 0
fuP2UpdatesOldPosY:       defb 0
fuP2UpdatesNewPosY:       defb 0
fuP2UpdatesOldPose:       defb 0
fuP2UpdatesNewPose:       defb 0
fuP2UpdatesTileChangeX:   defb 0
fuP2UpdatesTileChangeY:   defb 0
fuP2UpdatesTileChangePtr: defw 0

        ;; In a frame, a mouse can:
        ;; TODO: amanda

mouseUpdatesBase:
; Mouse data tables
; direction - 0 = up, 1 = right, 2 = down, 3 = left
mouseUpdatesDirection:  defb 2      ; ix
mouseUpdatesOldPosX:    defb 0      ; ix + 1
mouseUpdatesNewPosX:    defb levelRightmostPixel - 4    ; ix + 2
mouseUpdatesOldPosY:    defb 0      ; ix + 3
mouseUpdatesNewPosY:    defb levelBottommostPixel - 4      ; ix + 4

; 3 mouse poses
; 3 exit paths -- door on right, below couch middle (maybe any part under couch), mouse hole on left
; if cat gets close enough- move 8 pixels/s ?
; mouse holes spawn randomly on wall - change x y position on wall - lasts x seconds
