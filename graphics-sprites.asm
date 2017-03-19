;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;			MOUSE SPRITES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; mouse moving left ;;

MOUSE_LEFT_ONE:
	defb $01, $01, $07, $D8, $A8, $40, $FF, $08
	defb $00, $01, $C1, $21, $1E, $10, $E0, $40

MOUSE_LEFT_TWO:
	defb $02, $01, $07, $D8, $A8, $40, $FF, $08
	defb $80, $01, $C1, $21, $1E, $10, $E0, $40

MOUSE_LEFT_THREE:
	defb $06, $01, $07, $D8, $A8, $40, $FF, $08
	defb $C0, $01, $C1, $21, $1E, $10, $E0, $40

;; mouse moving right ;;

MOUSE_RIGHT_ONE:
	defb $00, $80, $83, $84, $78, $08, $07, $02
	defb $80, $80, $E0, $1B, $15, $02, $FF, $10

MOUSE_RIGHT_TWO:
	defb $01, $80, $83, $84, $78, $08, $07, $02
	defb $40, $80, $E0, $1B, $15, $02, $FF, $10


MOUSE_RIGHT_THREE:
	defb $03, $80, $83, $84, $78, $08, $07, $02
	defb $60, $80, $E0, $1B, $15, $02, $FF, $10

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
;			CAT SPRITES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; cat left ;;
; ASM data file from a ZX-Paintbrush picture with 16 x 8 pixels (= 2 x 1 characters)
; and an attribute area of 2 bytes

; block based output of pixel data - each block contains 8 x 8 pixels

; blocks at pixel positionn (y=0):

CAT_CLAW:
	defb $00, $00, $28, $F0, $F8, $F0, $08, $00

CAT_STEP_ONE:
	defb $3F, $3F, $3F, $3F, $3F, $38, $5C, $6C
	defb $FC, $FC, $FC, $FC, $FC, $1C, $2E, $36

CAT_SETP_TWO:
	defb $3F, $3F, $3F, $3F, $3F, $38, $74, $6C
	defb $FC, $FC, $FC, $FC, $FC, $1C, $3A, $36


CAT_LEFT_UPPERBODY_PLAYER_1:
	defb $11, $31, $7F, $4E, $7B, $75, $3F, $1F
	defb $30, $B8, $DC, $4E, $C6, $C6, $86, $7E


CAT_LEFT_LEAP_RIGHT_LAND_OUTWARD_STEP_OR_JUMP:
	defb $3F, $3F, $3F, $3F, $77, $EE, $DC, $18
	defb $FC, $FC, $FC, $FC, $FC, $6E, $37, $1B

;CAT_LEFT_NEUTRAL_STEP:
;	defb $3F, $3F, $3F, $3F, $3F, $36, $76, $0E
;	defb $FC, $FC, $FC, $FC, $FC, $6C, $EC, $1C

;CAT_LEFT_HIGH_STRIKE:	; this is 2x3 for now
	; line based output of pixel data:
;	defb $08, $11, $38, $14, $2A, $A4, $2E, $4E, $62, $19, $80, $31, $08, $B1, $A9, $04, $84, $29, $02, $8A, $39, $01, $40, $41, $00, $A0, $81, $00, $40, $02, $00, $20, $02, $00, $20, $02, $00, $40, $02, $00, $8F, $F2, $00, $90, $52, $00, $60, $6C
;CAT_LEFT_LOW_STRIKE:	; this is 2x3 for now
	; line based output of pixel data:
;	defb $00, $11, $38, $00, $2A, $A4, $00, $4E, $62, $00, $80, $31, $00, $B1, $A9, $00, $84, $29, $00, $8A, $39, $00, $40, $41, $00, $20, $81, $14, $40, $02, $0B, $80, $02, $10, $10, $02, $10, $20, $02, $0B, $C7, $F2, $14, $48, $52, $00, $30, $6C

CAT_RIGHT_UPPERBODY_PLAYER_1:
	defb $0C, $1D, $3B, $72, $63, $63, $61, $7E
	defb $88, $8C, $FE, $72, $DE, $AE, $FC, $F8
;;CAT_RIGHT_INWARD_STEP:;;
	; line based output of pixel data:
;;	defb $1C, $88, $25, $54, $46, $72, $8C, $01, $95, $8D, $94, $21, $9C, $51, $82, $02, $81, $04, $40, $02, $40, $02, $40, $02, $44, $92, $23, $12, $12, $B4, $0C, $58

CAT_RIGHT_LEAP_LEFT_LAND_OUTWARD_STEP_OR_JUMP::
	defb $3F, $3F, $3F, $3F, $3F, $76, $EC, $D8
	defb $FC, $FC, $FC, $FC, $EE, $77, $3B, $18

;;CAT_RIGHT_NEUTRAL_STEP:
;;	defb $3F, $3F, $3F, $3F, $3F, $36, $37, $38
;;	defb $FC, $FC, $FC, $FC, $FC, $6C, $6E, $70

;;CAT_RIGHT_HIGH_STRIKE:	; this is 2x3 for now
	; line based output of pixel data:
;;	defb $08, $11, $38, $14, $2A, $A4, $2E, $4E, $62, $19, $80, $31, $08, $B1, $A9, $04, $84, $29, $02, $8A, $39, $01, $40, $41, $00, $A0, $81, $00, $40, $02, $00, $20, $02, $00, $20, $02, $00, $40, $02, $00, $8F, $F2, $00, $90, $52, $00, $60, $6C
;;CAT_RIGHT_LOW_STRIKE:	; this is 2x3 for now
	; line based output of pixel data:
;;	defb $00, $11, $38, $00, $2A, $A4, $00, $4E, $62, $00, $80, $31, $00, $B1, $A9, $00, $84, $29, $00, $8A, $39, $00, $40, $41, $00, $20, $81, $14, $40, $02, $0B, $80, $02, $10, $10, $02, $10, $20, $02, $0B, $C7, $F2, $14, $48, $52, $00, $30, $6C
	