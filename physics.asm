updatePhysics:
phys_p1_entry_point:
    ld  ix,(p1DirPressed)
    ld  hl,p1MovX
phys_p2_entry_point:
    ; TODO - Save p1/2MovX to some where so that we can move it to ix
    ;        when needed and use offset to access all move states.
    ;
    ;        We can sacrifice code size if it proves too cycle costly.
phys_routine_body:
        ;; left/right
    xor a
    add a,(ix+2)
    call nz,phys_setNegX   ; Left pressed
    xor a                  ; no need for if/then/else since left and right
    add a,(ix+3)           ; should cancel each other
    call nz,phys_setPosX   ; Right pressed
        ;; punch
    ld  a,(p1PPressed)
    add a,0                     ; ld doesn't set flag
    call nz,phys_setPunch    ; Punch pressed.
        ;; jump
    ld  ix,p1MovY
    ld  a,(p1JPressed)
    add a,0                     ; ld doesn't set flag
    call nz,phys_handle_jump  ; Jump pressed.
        ;; down
    ld  ix,(p1DirPressed)
    xor a
    add a,(ix+1)
    ld  ix,p1MovY
    call nz,phys_handle_fall  ; Down pressed
        ;; jumping?
    ld  a,(p1AirState)
    cp  airStateJumping
    jp nz,not_jumping
    call phys_handle_jumpstate  ; Since the handler would potentially change the
                                ; air state, strictly PROHIBITED to return to
                                ; this line from the handler.
    ret
        ;; falling?
not_jumping:
    cp  airStateFalling
    call z,phys_handle_fallstate
    ret

;; BEFORE call, hl shall contain the addr. of P*MovX
phys_setPosX:
    ld  (hl),1
    ret

;; BEFORE call, hl shall contain the addr. of P*MovX
phys_setNegX:
    ld  (hl),-1
    ret

;; BEFORE call, ix shall contain the addr. of P*MovY
phys_handle_jump:
    ld  a,(ix+1)    ; Read air state
    cp  airStateGround
    ret nz,phys_pdown   ; If not on the ground, jump is NOP

    ld  (ix+0),8    ; Set initial upward speed.
    ld  (ix+1),airStateJumping
    ret

;; BEFORE call, ix shall contain the addr. of P*MovY
phys_handle_fall:
    ld  a,(ix+1)                ; Read air state
    cp  airStateGround
    ret nz,phys_airstate        ; If not on the ground, fall is NOP

    ld  (ix+0),0                ; Set initial downward speed
    ld  (ix+1),airStateFalling
    ret

;; BEFORE call, ix shall contain the addr. of P*MovY
phys_handle_jumpstate:
    dec (ix+0)                  ; Decelerate the cat vertically
    ret nz,phys_js_nochange     ; Change to falling state if v-speed hits 0
    ld  (ix+1),airStateFalling
    ret

;; BEFORE call, ix shall contain the addr. of P*MovY
phys_handle_fallstate:
    dec (ix+0)                  ; Just decelerate the cat vertically
    ret

phys_setPunch:
    ;ld  (hl),0
    ; Last line TBD by whether we want in-air flying punch
    ret
