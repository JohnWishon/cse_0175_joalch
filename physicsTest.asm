    org $8000

    include "defines.asm"

main:
    ;; ---------------------------------------------------------------------
    ;; Setup program state, interrupt handling scheme
    ;; ---------------------------------------------------------------------

    ld a,2                 ; upper screen
    call openChannel

        ; Just a main loop. Easy enough to read
updateIteration:
    call updateKeystate
    call updatePhysics

    call test_display_physics_reg_values

    halt
    jp updateIteration
    jp endProg

endProg:
    nop
    jp endProg

test_display_physics_reg_values:
    ld  de,p1str ; addr. of "P1: " string
    ld  bc,Xp1str-p1str
    call    print

    ld  a,(p1MovX)
    ld  b,0
    ld  c,a
    call    6683    ; Print the number in BC

    ld  de,spacestr ; addr. of " " string
    ld  bc,1
    call    print

    ld  a,(p1MovY)
    ld  b,0
    ld  c,a
    call    6683

    ld  de,spacestr ; addr. of " " string
    ld  bc,1
    call    print

    ld  a,(p1MovementState)
    call    test_print_air_state


    ld  de,p2str ; addr. of "P2: " string
    ld  bc,Xp2str-p2str
    call    print

    ld  a,(p2MovX)
    ld  b,0
    ld  c,a
    call    6683    ; Print the number in BC

    ld  de,spacestr ; addr. of " " string
    ld  bc,1
    call    print

    ld  a,(p2MovY)
    ld  b,0
    ld  c,a
    call    6683

    ld  de,spacestr ; addr. of " " string
    ld  bc,1
    call    print

    ld  a,(p2MovementState)
    call    test_print_air_state

    ret

test_print_air_state:
    cp  movementStateGround
    jp  nz, test_phys_not_ground
    ld  de,grdstr;
    ld  bc,4
    call print
    ret
test_phys_not_ground:
    cp  movementStateJumping
    jp  nz, test_phys_not_jumping
    ld  de,jmpstr;
    ld  bc,4
    call print
    ret
test_phys_not_jumping:
    cp  movementStateFalling
    jp  nz, test_phys_not_falling
    ld  de,falstr
    ld  bc,4
    call print
    ret
test_phys_not_falling:
    ld  de,errorstr
    ld  bc,7
    call print
    ret

p1str:
    defb    "P1: "
Xp1str:
p2str:
    defb    "P2: "
Xp2str:
spacestr:
    defb    " "
grdstr:
    defb    "GRD", newline
jmpstr:
    defb    "JMP", newline
falstr:
    defb    "FAL", newline
errorstr:
    defb    "Error!", newline

        include "input.asm"
        include "physics.asm"
