
drawScreen: 
ld a, 0  
out (254),a ; black border
Repeat:     
  ld a,b
  or c
  jp z,Finish
  
  ld a,$30                     
  cp (hl)                        
  jp z,Shelf            

  ld a,$79                     
  cp (hl)                        
  jp z,Curtain  
  
  ld a,$28                     
  cp (hl)                        
  jp z,Spider 

  ld a,$3D                     
  cp (hl)                        
  jp z,SpiderWeb   

  ld a,$0B                     
  cp (hl)                        
  jp z,Fish   

  ld a,$0F                     
  cp (hl)                        
  jp z,Fish_Tank 

  ld a,$78                     
  cp (hl)                        
  jp z,Light_Socket 

  ld a,$10                     
  cp (hl)                        
  jp z,CouchP

  ld a,$20                     
  cp (hl)                        
  jp z,CouchLeg

  ld a, $38
  cp (hl)
  jp z,TVCenter

  ld a, $60
  cp (hl)
  jp z,TVCenterBase

  ld a, $82
  cp (hl)
  jp z,TVCenterBlinker
  
  ld a, $40
  cp d
  jp z,botf
  ld a, $48
  cp d
  jp z,botf
  ld a, $70
  cp (hl)
  jp z,WallHole
  botf
  inc hl                         
  inc de
  dec bc

  ld a,b
  or c
  jp z, Finish

  jp Repeat

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

  jp Repeat

Curtain:
  ld ix, MainScreen_CurtainTile
  jp drawTile	
  
Spider:
  ld ix, MainScreen_SpiderTile
  jp drawTile

SpiderWeb:
  ld ix, MainScreen_SpiderWebTile
  jp drawTile  

Shelf:
  ld ix, MainScreen_ShelfTile
  jp drawTile	

Fish:
  ld ix, MainScreen_Fish
  jp drawTile	

Fish_Tank:
  ld ix, MainScreen_Fish_Tank
  jp drawTile	

Light_Socket:
  ld ix, MainScreen_LightSocketTile
  jp drawTile	

CouchP:
  
  ld a, c
  cp 214
  jp z, continueStmt
  ld a, c
  cp 213
  jp z, continueStmt
  ld a, c
  cp 212
  jp z, continueStmt
  ld a, c
  cp 211
  jp z, continueStmt
  ld a, c
  cp 210
  jp z, continueStmt
  ld a, c
  cp 208
  jp z, continueStmt
  ld a, c
  cp 207
  jp z, continueStmt
  ld a, c
  cp 206
  jp z, continueStmt
  ld a, c
  cp 205
  jp z, continueStmt
  ld a, c
  cp 204
  jp z, continueStmt

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

  continueStmt
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

  TVCenter:

  ld a, c
  cp 253
  ld ix, tv253
  jp z, drawTile

  ld a, c
  cp 222
  ld ix, tv222
  jp z, drawTile

  ld a, c
  cp 221
  ld ix, tv221
  jp z, drawTile

  ld a, c
  cp 220
  ld ix, tv220
  jp z, drawTile

  ld a, c
  cp 190
  ld ix, tv190
  jp z, drawTile

  ld a, c
  cp 189
  ld ix, tv189
  jp z, drawTile

  ld a, c
  cp 188
  ld ix, tv188
  jp z, drawTile

  ld a, c
  cp 160
  ld ix, tv160
  jp z, drawTile

  ld a, c
  cp 159
  ld ix, tv159
  jp z, drawTile

  ld a, c
  cp 157
  ld ix, tv157
  jp z, drawTile

  ld a, c
  cp 156
  ld ix, tv156
  jp z, drawTile

  ld a, c
  cp 128
  ld ix, tv128
  jp z, drawTile

  ld a, c
  cp 127
  ld ix, tv127
  jp z, drawTile

  ld a, c
  cp 126
  ld ix, tv126
  jp z, drawTile

  ld a, c
  cp 125
  ld ix, tv125
  jp z, drawTile

  ld a, c
  cp 96
  ld ix, tv96
  jp z, drawTile

  ld a, c
  cp 95
  ld ix, tv95
  jp z, drawTile

  ld a, c
  cp 94
  ld ix, tv94
  jp z, drawTile

  ld a, c
  cp 93
  ld ix, tv93
  jp z, drawTile

  ld a, c
  cp 64
  ld ix, tv64
  jp z, drawTile

  ld a, c
  cp 63
  ld ix, tv63
  jp z, drawTile

  inc hl                         
  inc de
  dec bc
  jp Repeat

TVCenterBase:

  ld a, c
  cp 124
  ld ix, tv124
  jp z, drawTile

  ld a, c
  cp 93
  ld ix, tv93
  jp z, drawTile

  ld a, c
  cp 62
  ld ix, tv62
  jp z, drawTile

  ld a, c
  cp 61
  ld ix, tv61
  jp z, drawTile

  ld a, c
  cp 32
  ld ix, tv32
  jp z, drawTile

  ld a, c
  cp 31
  ld ix, tv31
  jp z, drawTile


  inc hl                         
  inc de
  dec bc
  jp Repeat

TVCenterBlinker:

  ld a, c
  cp 158
  ld ix, tv158
  jp z, drawTile


  inc hl                         
  inc de
  dec bc
  jp Repeat

WallHole:

  ld a, c
  cp 250
  ld ix, mh250
  jp z, drawTile

  cp 218
  ld ix, mh218
  jp z, drawTile
  ld a, c

  ld a, c
  cp 217
  ld ix, mh217
  jp z, drawTile

  ld a, c
  cp 186
  ld ix, mh186
  jp z, drawTile
  
  ld a, c
  cp 185
  ld ix, mh185
  jp z, drawTile

  inc hl                         
  inc de
  dec bc
  jp Repeat

Finish:  
  RET