
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
  jp z,Finish
  
  ld a,$30                     
  cp (hl)                        
  jr z,Shelf            

  ld a,$28                     
  cp (hl)                        
  jr z,Curtain  

  ld a,$0B                     
  cp (hl)                        
  jr z,Fish   

  ld a,$0F                     
  cp (hl)                        
  jr z,Fish_Tank 

  ld a,$78                     
  cp (hl)                        
  jr z,Light_Socket 

  ld a,$53                     
  cp (hl)                        
  jr z,CouchP
  
  ld a,$13                     
  cp (hl)                        
  jr z,CouchP

  ld a,$20                     
  cp (hl)                        
  jp z,CouchLeg

  inc hl                         
  inc de
  dec bc

  ld a,b
  or c
  jp z, Finish

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

CouchP:
  
  ld a, c
  cp 246
  ld ix, couch246
  jp z, drawTile
  
  ld a, 241
  cp c
  ld ix, couchSingleLine
  jp c, drawTile

  ld a, c
  cp 241
  ld ix, couch241
  jp z, drawTile

  ld a, 236
  cp c
  ld ix, couchSingleLine
  jp c, drawTile

  ld a, c
  cp 236
  ld ix, couch236
  jp z, drawTile

  ld a, c
  cp 215
  ld ix, couch215
  jp z, drawTile

  ld a, c
  cp 209
  ld ix, couch209
  jp z, drawTile

  ld a, c
  cp 203
  ld ix, couch203
  jp z, drawTile

  ld a, c
  cp 183
  ld ix, couch183
  jp z, drawTile

  ld a, 177
  cp c
  ld ix, couchDoubleLine
  jp c, drawTile

  ld a, c
  cp 177
  ld ix, couch177
  jp z, drawTile

  ld a, 171
  cp c
  ld ix, couchDoubleLine
  jp c, drawTile

  ld a, c
  cp 171
  ld ix, couch171
  jp z, drawTile

  ld a, c
  cp 151
  ld ix, couch151
  jp z, drawTile

  ld a, 145
  cp c
  ld ix, couchDoubleLine
  jp c, drawTile

  ld a, c
  cp 145
  ld ix, couch145
  jp z, drawTile

  ld a, 139
  cp c
  ld ix, couchDoubleLine
  jp c, drawTile

  ld a, c
  cp 139
  ld ix, couch139
  jp z, drawTile

  inc hl                         
  inc de
  dec bc
  jp Repeat

CouchLeg:
  ld a, c
  cp 119
  ld ix, lpeg
  jp z, drawTile

  ld a, c
  cp 107
  ld ix, rpeg
  jp z, drawTile

  inc hl                         
  inc de
  dec bc
  jp Repeat

Finish:  
  RET


drawFrame:

        ret