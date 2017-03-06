updatePhysics:
    ld  d,2
phys_p1_entry_point:
    ld  ix,p1DirPressed
    jp  phys_routine_body
phys_p2_entry_point:
    ld  ix,p2DirPressed

phys_routine_body:
    ;; left/right
    ld  (ix+6),0            ; First clear horizontal speed

    ld  a,(ix+8)            ; Read movement state
    cp  movementStateClimbing   ; If the cat is climbing
    jp  z,phys_may_process_vert_mov ; Then don't process horizontal movement
                                    ; jump directly to processing vertical movement
    cp  movementStateGround ; If the cat is not the ground
    jp  nz,phys_not_clear_vert_speed    ; Don't clear vertical speed. Climbing handles
                                        ; its own case
    ld  (ix+7),0
phys_not_clear_vert_speed
    xor a
    add a,(ix+2)
    call nz,phys_setNegX    ; Left pressed
    xor a                   ; no need for if/then/else since left and right
    add a,(ix+3)            ; should cancel each other
    call nz,phys_setPosX    ; Right pressed
    jp  phys_basic_mov_processed
phys_may_process_vert_mov:  ; Entered only if movementState = climbing
    ld  (ix+7),0            ; Clear vert. speed. We are climbing on frictional surface, baby!
    xor a
    add a,(ix+0)
    call nz,phys_setPosY    ; Up pressed
    xor a
    add a,(ix+1)
    call nz,phys_setNegY    ; Down pressed
    ;; Fall through
phys_basic_mov_processed:
    ;; punch
    ld  a,(ix+5)            ; Punch = DirPressed + 5
    add a,0                 ; ld doesn't set flag
    call nz,phys_setPunch   ; Punch pressed.
    ;; jump
    ld  a,(ix+4)                ; Jump = DirPressed + 4
    add a,0                     ; ld doesn't set flag
    call nz,phys_handle_jump    ; Jump pressed.
    ;; down
    xor a
    add a,(ix+1)
    call nz,phys_handle_fall    ; Down pressed
    ;; jumping?
    ld  a,(ix+8)
    cp  movementStateJumping
    jp  nz,phys_not_in_jumping_state
    call phys_handle_jumpstate
    jp  phys_cycle_closing      ; Jumping may change to falling in handle_jumpstate,
                                ; thus skip handle_fallstate for this frame.
    ;; falling?
phys_not_in_jumping_state:
    cp  movementStateFalling
    call z,phys_handle_fallstate
phys_cycle_closing:
    dec d
    ret z
    jp  phys_p2_entry_point

;;==== SUBROUTINES ====
;; BEFORE call, ix shall contain the addr. of P*DirPressed

phys_setPosX:
    ld  (ix+6),phys_cat_hori_speed
    ret
phys_setNegX:
    ld  (ix+6),-phys_cat_hori_speed
    ret

phys_setPosY:
    ld  (ix+7),phys_cat_vert_speed
    ret
phys_setNegY:
    ld  (ix+7),-phys_cat_vert_speed
    ret

phys_handle_jump:
    ld  a,(ix+8)    ; Read movement state
    cp  movementStateGround
    jp  z,phys_set_jumping_state
    cp  movementStateClimbing
    ret nz          ; If not on the ground, nor climbing, jump is NOP
phys_set_jumping_state:
    ld  (ix+7),phys_jump_init_speed    ; Set initial upward speed.
    ld  (ix+8),movementStateJumping
    ret

phys_handle_fall:
    ld  a,(ix+8)                ; Read movement state
    cp  movementStateGround
    ret nz                      ; If not on the ground, fall is NOP

    ld  (ix+7),0                ; Set initial downward speed
    ld  (ix+8),movementStateFalling
    ret

phys_handle_jumpstate:
    dec (ix+7)                  ; Decelerate the cat vertically
    ret nz                      ; Change to falling state if v-speed hits 0
    ld  (ix+8),movementStateFalling
    ret

phys_handle_fallstate:
    ld  a,(ix+7)
    cp  phys_fall_max_speed
    ret z
    dec (ix+7)                  ; Just decelerate the cat vertically
    ret

phys_setPunch:
    ;ld  (hl),0
    ; Last line TBD by whether we want in-air flying punch
    ret
phys_jump_init_speed:   equ 8
phys_fall_max_speed:    equ -12
phys_cat_hori_speed:    equ 1
phys_cat_vert_speed:    equ 1
