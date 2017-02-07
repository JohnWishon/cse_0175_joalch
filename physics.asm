updatePhysics:
phys_p1_entry_point:
    ld  ix,p1DirPressed
    jp  phys_routine_body
phys_p2_entry_point:
    ; TODO - Save p1/2MovX to some where so that we can move it to ix
    ;        when needed and use offset to access all move states.
    ;
    ;        We can sacrifice code size if it proves too cycle costly.
phys_routine_body:
    ;; left/right
    ld  (ix+6),0            ; First clear horizontal speed
    xor a
    add a,(ix+2)
    call nz,phys_setNegX    ; Left pressed
    xor a                   ; no need for if/then/else since left and right
    add a,(ix+3)            ; should cancel each other
    call nz,phys_setPosX    ; Right pressed
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
    call nz,phys_handle_fall  ; Down pressed
    ;; jumping?
    ld  a,(ix+8)
    cp  airStateJumping
    jp  nz,not_in_jumping_state
    call phys_handle_jumpstate
    ret
    ;; falling?
not_in_jumping_state:
    cp  airStateFalling
    call z,phys_handle_fallstate
    ret

;;==== SUBROUTINES ====
;; BEFORE call, ix shall contain the addr. of P*DirPressed

phys_setPosX:
    ld  (ix+6),1
    ret

phys_setNegX:
    ld  (ix+6),-1
    ret

phys_handle_jump:
    ld  a,(ix+8)    ; Read air state
    cp  airStateGround
    ret nz          ; If not on the ground, jump is NOP

    ld  (ix+7),8    ; Set initial upward speed.
    ld  (ix+8),airStateJumping
    ret

phys_handle_fall:
    ld  a,(ix+8)                ; Read air state
    cp  airStateGround
    ret nz                      ; If not on the ground, fall is NOP

    ld  (ix+7),0                ; Set initial downward speed
    ld  (ix+8),airStateFalling
    ret

phys_handle_jumpstate:
    dec (ix+7)                  ; Decelerate the cat vertically
    ret nz                      ; Change to falling state if v-speed hits 0
    ld  (ix+8),airStateFalling
    ret

phys_handle_fallstate:
    dec (ix+7)                  ; Just decelerate the cat vertically
    ret

phys_setPunch:
    ;ld  (hl),0
    ; Last line TBD by whether we want in-air flying punch
    ret
