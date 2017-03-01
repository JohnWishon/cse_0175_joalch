;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			MOUSE SPRITES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; mouse moving left ;;

MOUSE_LEFT_ONE:
	defb $01, $00, $01, $01, $07, $C1, $D8, $21, $A8, $1E, $40, $10, $FF, $E0, $08, $40

MOUSE_LEFT_TWO:
	defb $02, $80, $01, $01, $07, $C1, $D8, $21, $A8, $1E, $40, $10, $FF, $E0, $08, $40

MOUSE_LEFT_THREE:
	defb $06, $C0, $01, $01, $07, $C1, $D8, $21, $A8, $1E, $40, $10, $FF, $E0, $08, $40


;; mouse moving right ;;

MOUSE_RIGHT_ONE:
	defb $00, $80, $80, $80, $83, $E0, $84, $1B, $78, $15, $08, $02, $07, $FF, $02, $10

MOUSE_RIGHT_TWO:
	defb $01, $40, $80, $80, $83, $E0, $84, $1B, $78, $15, $08, $02, $07, $FF, $02, $10

MOUSE_RIGHT_THREE:
	defb $03, $60, $80, $80, $83, $E0, $84, $1B, $78, $15, $08, $02, $07, $FF, $02, $10


;; mouse hole ;;

MOUSE_SHOWING_IN_HOLE: ;flashing
	; line based output of pixel data:
	defb $66, $99, $7E, $81, $A5, $81, $66, $18
	; line based output of attribute data:
	defb $F0

MOUSE_NOT_SHOWING_IN_HOLE:
	; line based output of pixel data:
	defb $FF, $87, $C1, $83, $C1, $81, $A9, $FF
	; line based output of attribute data:
	defb $70


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			CAT SPRITES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

LEFT_INWARD_STEP:
	defb $11, $38, $2A, $A4, $4E, $62, $80, $31, $B1, $A9, $84, $29, $8A, $39, $40, $41, $20, $81, $40, $02, $40, $02, $40, $02, $49, $22, $48, $C4, $2D, $48, $1A, $30

LEFT_OUTWARD_STEP:
	defb $11, $38, $2A, $A4, $4E, $62, $80, $31, $B1, $A9, $84, $29, $8A, $39, $40, $41, $20, $81, $40, $02, $40, $02, $40, $02, $88, $02, $91, $F1, $72, $49, $1C, $36

LEFT_NEUTRAL_STEP:
	defb $11, $38, $2A, $A4, $4E, $62, $80, $31, $B1, $A9, $84, $29, $8A, $39, $40, $41, $20, $81, $40, $02, $40, $02, $40, $02, $40, $02, $49, $F2, $49, $52, $36, $6C

LEFT_STANDING:
	defb $11, $38, $2A, $A4, $4E, $62, $80, $31, $B1, $A9, $84, $29, $8A, $39, $40, $41, $20, $81, $40, $02, $80, $02, $80, $02, $80, $32, $9F, $32, $91, $2C, $60, $C0

LEFT_HIGH_STRIKE: ; this is 2x3 for now
	defb $08, $11, $38, $14, $2A, $A4, $2E, $4E, $62, $19, $80, $31, $08, $B1, $A9, $04, $84, $29, $02, $8A, $39, $01, $40, $41, $00, $A0, $81, $00, $40, $02, $00, $20, $02, $00, $20, $02, $00, $40, $02, $00, $8F, $F2, $00, $90, $52, $00, $60, $6C

LEFT_LOW_STRIKE:
	defb $00, $11, $38, $00, $2A, $A4, $00, $4E, $62, $00, $80, $31, $00, $B1, $A9, $00, $84, $29, $00, $8A, $39, $00, $40, $41, $00, $20, $81, $14, $40, $02, $0B, $80, $02, $10, $10, $02, $10, $20, $02, $0B, $C7, $F2, $14, $48, $52, $00, $30, $6C



	