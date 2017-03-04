
drawPNUpdatesTileX:   equ 6
drawPNUpdatesTileY:   equ 7
drawPNUpdatesTilePtr: equ 8

drawWriteTileX: equ 0
drawWriteTileY: equ 1
drawWriteTilePtr: equ 2

screenAddress: equ $4000
;screenCellsLength: equ 768
;screenAttributes: equ MainScreen_Attributes
;screenAttributesLength: equ 768

setupGraphics:

clearFile:
	ld hl,$4000	; Clear the entire display file
	ld de,$4001
	ld bc,$17FF
	ld (hl),$00
	ldir

setAttributeFile:
	ld hl, MainScreen_Attributes	;Copy the attribute bytes from FC00 to the top third of the attribute file
	ld de, $5800
	ld bc, $0300
	ldir

drawTopScreen:
  ld hl,MainScreen_Attributes_TOP
  ld de,$4000
  ld bc,256
  call drawScreen
drawMidScreen:
  ld hl,MainScreen_Attributes_MID
  ld de,$4800
  ld bc,256
  call drawScreen
drawBotScreen:
  ld hl,MainScreen_Attributes_BOT
  ld de,$5000
  ld bc,256
  call drawScreen

  RET

drawScreen: 
Repeat:     
  ld a,b
  or c
  jr z,Finish
  
  ld a,$30                     
  cp (hl)                        
  jr z,Shelf            

  ld a,$28                     
  cp (hl)                        
  jr z,Curtain  

  ld a,$4B                     
  cp (hl)                        
  jr z,Fish   

  ld a,$0F                     
  cp (hl)                        
  jr z,Fish_Tank 



  ld a,$30                     
  cp (hl)                        
  jr z,Shelf 

  inc hl                         
  inc de
  dec bc

  ld a,b
  or c
  jr z, Finish

  jr Repeat

drawTile:
  ld a, (ix)
  ld (de),a
  inc d
  ld a, (ix+1)
  ld (de),a
  inc d
  ld a, (ix+2)
  ld (de),a
  inc d
  ld a, (ix+3)
  ld (de),a
  inc d
  ld a, (ix+4)
  ld (de),a
  inc d
  ld a, (ix+5)
  ld (de),a
  inc d
  ld a, (ix+6)
  ld (de),a
  inc d
  ld a, (ix+7)
  ld (de),a

  ld a, d
  and %11111000
  ld d, a

  inc hl                         
  inc de
  dec bc

  jr Repeat

Curtain:
  ld ix, MainScreen_CurtainTile
  jr drawTile	

Shelf:
  ld ix, MainScreen_ShelfTile
  jr drawTile	

Fish:
  ld ix, MainScreen_Fish
  jr drawTile	

Fish_Tank:
  ld ix, MainScreen_Fish_Tank
  jr drawTile	

Light_Socket:
  ld ix, MainScreen_LightSocketTile
  jr drawTile	



Finish:  
  RET


drawFrame:

        ret