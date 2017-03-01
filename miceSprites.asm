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
	