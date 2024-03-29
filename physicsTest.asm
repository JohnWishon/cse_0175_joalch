    org $8000

    jp  main
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
    call    test_print_num_and_space

    ld  a,(p1MovY)
    ld  b,0
    ld  c,a
    ld  a,(vertctr)
    add a,c
    ld  (vertctr),a
    call    test_print_num_and_space

    ld  a,(p1MovementState)
    call    test_phys_print_air_state

    ld  a,(vertctr) ; Print P1 vert counter
    ld  b,0
    ld  c,a
    call    test_print_num_and_space
    call    test_print_newline

test_phys_P2_line:
    ld  de,p2str ; addr. of "P2: " string
    ld  bc,Xp2str-p2str
    call    print

    ld  a,(p2MovX)
    ld  b,0
    ld  c,a
    call    test_print_num_and_space

    ld  a,(p2MovY)
    ld  b,0
    ld  c,a
    ld  a,(vertctr+1)
    add a,c
    ld  (vertctr+1),a
    call    test_print_num_and_space

    ld  a,(p2MovementState)
    call    test_phys_print_air_state

    ld  a,(vertctr+1) ; Print P2 vert counter
    ld  b,0
    ld  c,a
    call    test_print_num_and_space
    call    test_print_newline

    call    test_print_newline


    call    test_phys_border_check
    ret

test_phys_print_air_state:
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

    ;; This subroutine crudely simulates collision test so that we can test
     ; State transitions.
test_phys_border_check:
    ld  a,(vertctr)
    cp  218
    jp  z,test_phys_yes_vert_halt1
    cp  52
    jp  nz,test_phys_no_vert_halt1
test_phys_yes_vert_halt1:
    ld  a,0
    ld  (vertctr),a
    ld  a,movementStateGround
    ld  (p1MovementState),a
test_phys_no_vert_halt1:
    ld  a,(vertctr+1)
    cp  218
    jp  z,test_phys_yes_vert_halt2
    cp  52
    jp  nz,test_phys_no_vert_halt2
test_phys_yes_vert_halt2:
    ld  a,0
    ld  (vertctr+1),a
    ld  a,movementStateGround
    ld  (p2MovementState),a
test_phys_no_vert_halt2:
    ret

vertctr:
    defb    0,0

    include "input.asm"
    include "physics.asm"
    include "testUtil.asm"
