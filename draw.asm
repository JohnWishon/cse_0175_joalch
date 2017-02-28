

setupGraphics:

	;; TODO: John
	;; setup the initial screen.
	;call MainLevelPixels
	;call MainLevelAttributes
SET_DISPLAY_FILE:
	LD HL,MainLevelPixels	;Copy the graphic data at A000 to the top two-thirds of the display file
	LD DE,$4000
	LD BC,$2400 ;CHANGED FROM $1000 (16) TO (24)
	LDIR
	
SET_ATTRIBUTE_FILE:
	LD HL,MainLevelAttributes	;Copy the attribute bytes from FC00 to the top third of the attribute file
	LD DE,$5800
	LD BC,$0300
	LDIR

	ret


drawSprite:
;;Input
;;C	Drawing mode: 0 (overwrite) or 1 (blend)
;;DE	Address of sprite graphic data
;;HL	Address to draw at
;	LD C,0
	LD B,$10	;There are 16 rows of pixels to draw
;	BIT 0,C		;Set the zero flag if we're in overwrite mode
drawNextByte:
	LD A,(DE)	;Pick up a sprite graphic byte
;	JR Z,h8FFF	;Jump if we're in overwrite mode
	AND (HL)	;Return with the zero flag reset if any of the set bits in the sprite graphic byte collide with a set bit in the background (e.g. in Willy's sprite)
	RET NZ
	LD A,(DE)	;Pick up the sprite graphic byte again
	OR (HL)		;Blend it with the background byte
	LD (HL),A	;Copy the graphic byte to its destination cell ;;;h8FFF:
	INC L		;Move HL along to the next cell on the right
	INC DE		;Point DE at the next sprite graphic byte
	BIT 0,C		;Set the zero flag if we're in overwrite mode
	LD A,(DE)	;Pick up a sprite graphic byte
;	JR Z,h900B	;Jump if we're in overwrite mode
	AND (HL)	;Return with the zero flag reset if any of the set bits in the sprite graphic byte collide with a set bit in the background (e.g. in Willy's sprite)
	RET NZ
	LD A,(DE)	;Pick up the sprite graphic byte again
	OR (HL)		;Blend it with the background byte
	LD (HL),A	;Copy the graphic byte to its destination cell ;;;h900B:
	DEC L		;Move HL to the next pixel row down in the cell on the left
	INC H
	INC DE		;Point DE at the next sprite graphic byte
	LD A,H		;Have we drawn the bottom pixel row in this pair of cells yet?
	AND $07
	JR NZ,drawNextByteCheck	;Jump if not
	LD A,H		;Otherwise move HL to the top pixel row in the cell below
	SUB $08
	LD H,A
	LD A,L
	ADD A,$20
	LD L,A
	AND $E0		;Was the last pair of cells at y-coordinate 7 or 15?
	JR NZ,drawNextByteCheck	;Jump if not
	LD A,H		;Otherwise adjust HL to account for the movement from the top or middle third of the screen to the next one down
	ADD A,$08
	LD H,A
drawNextByteCheck:
	DJNZ drawNextByte	;Jump back until all 16 rows of pixels have been drawn
	XOR A		;Set the zero flag (to indicate no collision)
	RET	





drawFrame:
;	LD HL,MainLevelPixels	;Copy the graphic data at A000 to the top two-thirds of the display file
;	LD DE,$4000
;	LD BC,$2400 ;CHANGED FROM $1000 (16) TO (24)
;	LDIR

whichSprite:
	LD DE, CAT_RIGHT_STANDING ;;DE	Address of sprite graphic data

whereSpriteGoes:
	LD HL, $4806;;HL	Address to draw at

	call drawSprite;; 16 PIXELS HIGH!

;;	LD DE,CAT_LEFT_STANDING ;	Point DE at the graphic data for the boot (at BAE0)
;;;873A	LD C,$00	C=0 (overwrite mode)
;;	CALL $8FF4	Draw the boot at the bottom of the screen next to the remaining lives
	;call MainLevelPixels

        ;; ld  de,drawStr
        ;; ld  bc,XdrawStr-drawStr
        ;; call    print
		;;	Next, prepare the screen.
;CLEAR_DISPLAY_FILE:
;	LD HL,$4000	;Clear the entire display file
;	LD DE,$4001
;	LD BC,$17FF
;	LD (HL),$00
;	LDIR
	

;SET_DISPLAY_FILE:
;	LD HL,MainLevelPixels	;Copy the graphic data at A000 to the top two-thirds of the display file
;	LD DE,$4000
;	LD BC,$2400 ;CHANGED FROM $1000 (16) TO (24)
;	LDIR
	

;860F	LD BC,$0100
;8612	LDIR
;8614	LD HL,$9E00	Copy the attribute bytes from 9E00 to the bottom two-thirds of the attribute file
;8617	LD BC,$0200
;SET_ATTRIBUTE_FILE:
;	LD HL,MainLevelAttributes	;Copy the attribute bytes from FC00 to the top third of the attribute file
;	LD DE,$5800
;	LD BC,$0300
;	LDIR

	;; TODO: John

	;; read all data from fuP1UpdatesBase
	;; update screen based on data in fuP1UpdateBase


	;; read all data from fuMouseUpdate
	;; update screen based on data in fuMouseUpdates

        ret

drawStr:

	;call MainLevelPixels
	;call MainLevelAttributes

  ;;  defb    "drawFrame", newline
XdrawStr:
