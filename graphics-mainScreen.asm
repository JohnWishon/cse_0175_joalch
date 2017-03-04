MainScreen_EmptyCell:
  defb $00, $00, $00, $00, $00, $00, $00, $00

MainScreen_CurtainTile:
  ; line based output of pixel data:
  defb $9B, $AD, $C9, $AD, $9B, $AD, $C9, $AD

MainScreen_ShelfTile:
  ; line based output of pixel data:
  defb $FF, $FF, $00, $00, $00, $00, $00, $00

MainScreen_Fish_Tank_L:
  ; blocks at pixel positionn (y=0):
  defb $00, $00, $00, $00, $00, $00, $00, $00
  ; blocks at pixel positionn (y=8):
  defb $00, $00, $00, $B2, $49, $92, $45, $FF

MainScreen_Fish_Tank_R:
  ; blocks at pixel positionn (y=0):
  defb $00, $00, $18, $B4, $FE, $BC, $18, $00
  ; blocks at pixel positionn (y=8):
  defb $00, $00, $00, $B2, $4D, $92, $45, $FF

MainScreen_LightSocketTile:
  ; line based output of pixel data:
  defb $00, $00, $14, $14, $00, $08, $00, $00

MainScreen_WallHole_L:
  ; blocks at pixel positionn (y=0):
  defb $00, $00, $10, $10, $10, $10, $10, $08
  ; blocks at pixel positionn (y=8):
  defb $04, $02, $03, $06, $0A, $12, $27, $20
  ; blocks at pixel positionn (y=16):
  defb $10, $18, $1F, $12, $22, $52, $7F, $7F

MainScreen_WallHole_R:
  ; blocks at pixel positionn (y=0):
  defb $00, $00, $00, $00, $00, $00, $00, $00
  ; blocks at pixel positionn (y=8):
  defb $00, $00, $00, $80, $80, $40, $E0, $38
  ; blocks at pixel positionn (y=16):
  defb $24, $24, $FC, $02, $02, $01, $FF, $FF

MainScreen_TVStand_L:
  ; blocks at pixel positionn (y=0):
  defb $FF, $FF, $FE, $FC, $F9, $F0, $E0, $C0
  ; blocks at pixel positionn (y=8):
  defb $82, $81, $80, $FF, $FE, $80, $87, $FF
  ; blocks at pixel positionn (y=16):
  defb $FF, $FF, $FF, $FF, $FF, $FF, $EF, $FF
  ; blocks at pixel positionn (y=24):
  defb $FE, $FC, $F8, $FF, $E0, $C0, $80, $80
  ; blocks at pixel positionn (y=32):
  defb $80, $80, $81, $83, $87, $8F, $9F, $BF
  ; blocks at pixel positionn (y=40):
  defb $FF, $FF, $FE, $FC, $F8, $F0, $E0, $C0

MainScreen_TVStand_R:
  ; blocks at pixel positionn (y=0):
  defb $FF, $FF, $FF, $FD, $F9, $F1, $E1, $C1
  ; blocks at pixel positionn (y=8):
  defb $81, $01, $11, $09, $05, $81, $41, $21
  ; blocks at pixel positionn (y=16):
  defb $11, $09, $01, $F9, $19, $79, $F9, $F9
  ; blocks at pixel positionn (y=24):
  defb $FB, $FD, $F9, $F1, $E1, $C1, $81, $21
  ; blocks at pixel positionn (y=32):
  defb $11, $09, $01, $FF, $07, $0F, $1F, $3F
  ; blocks at pixel positionn (y=40):
  defb $FF, $FF, $FE, $FC, $F8, $F0, $E0, $C0

MainScreen_LSpeaker_L:
  ; blocks at pixel positionn (y=0):
  defb $07, $0F, $1F, $3F, $7F, $FF, $80, $80
  ; blocks at pixel positionn (y=8):
  defb $80, $80, $80, $80, $80, $80, $80, $80
  ; blocks at pixel positionn (y=16):
  defb $80, $80, $80, $80, $80, $80, $80, $80
  ; blocks at pixel positionn (y=24):
  defb $80, $80, $80, $80, $80, $80, $80, $FF
  ; blocks at pixel positionn (y=32):
  defb $FF, $FF, $FF, $FF, $FF, $FF, $00, $00

MainScreen_LSpeaker_R:
  ; blocks at pixel positionn (y=0):
  defb $FF, $FF, $FF, $FD, $FF, $F5, $FB, $D5
  ; blocks at pixel positionn (y=8):
  defb $EF, $D5, $BB, $D5, $EF, $D5, $BB, $D5
  ; blocks at pixel positionn (y=16):
  defb $BB, $D5, $EF, $D5, $BB, $D5, $EF, $D5
  ; blocks at pixel positionn (y=24):
  defb $BB, $D7, $EF, $DF, $BF, $FF, $FF, $FF
  ; blocks at pixel positionn (y=32):
  defb $FE, $FC, $F8, $F0, $E0, $C0, $00, $00

MainScreen_RSpeaker:
  ; blocks at pixel positionn (y=0):
  defb $FF, $FF, $FE, $FD, $FA, $F7, $EA, $5D
  ; blocks at pixel positionn (y=8):
  defb $6A, $77, $6A, $5D, $6A, $5D, $6A, $77
  ; blocks at pixel positionn (y=16):
  defb $6A, $5D, $6B, $77, $6F, $5F, $7F, $7F
  ; blocks at pixel positionn (y=24):
  defb $FE, $FC, $F8, $F0, $E0, $C0, $80, $00

MainScreen_Couch_LArm:
  ; blocks at pixel positionn (y=0):
  defb $FF, $C0, $80, $81, $83, $82, $FE, $82
  ; blocks at pixel positionn (y=8):
  defb $82, $82, $82, $82, $83, $83, $82, $83
  ; blocks at pixel positionn (y=16):
  defb $82, $82, $82, $81, $80, $80, $80, $FF
  ; blocks at pixel positionn (y=24):
  defb $78, $70, $70, $70, $70, $00, $00, $00

MainScreen_Couch_LCushion:
  ; blocks at pixel positionn (y=0):
  defb $FF, $E0, $80, $80, $80, $80, $80, $80
  ; blocks at pixel positionn (y=8):
  defb $80, $80, $80, $80, $80, $80, $80, $80
  ; blocks at pixel positionn (y=16):
  defb $80, $80, $C0, $FF, $00, $00, $00, $FF
  ; blocks at pixel positionn (y=24):
  defb $00, $00, $00, $FF, $00, $00, $00, $FF

MainScreen_Couch_RegCushion:
  ; blocks at pixel positionn (y=0):
  defb $FF, $00, $00, $00, $00, $00, $00, $00
  ; blocks at pixel positionn (y=8):
  defb $00, $00, $00, $00, $00, $00, $00, $00
  ; blocks at pixel positionn (y=16):
  defb $00, $00, $00, $FF, $00, $00, $00, $FF
  ; blocks at pixel positionn (y=24):
  defb $00, $00, $00, $FF, $00, $00, $00, $FF

MainScreen_Couch_MidCushion:
  ; blocks at pixel positionn (y=0):
  defb $FF, $38, $10, $10, $10, $10, $10, $10
  ; blocks at pixel positionn (y=8):
  defb $10, $10, $10, $10, $10, $10, $10, $10
  ; blocks at pixel positionn (y=16):
  defb $10, $10, $38, $FF, $10, $10, $10, $FF
  ; blocks at pixel positionn (y=24):
  defb $10, $10, $10, $FF, $00, $00, $00, $FF

MainScreen_Couch_RCushion:
  ; blocks at pixel positionn (y=0):
  defb $FF, $07, $01, $01, $01, $01, $01, $01
  ; blocks at pixel positionn (y=8):
  defb $01, $01, $01, $01, $01, $01, $01, $01
  ; blocks at pixel positionn (y=16):
  defb $01, $01, $03, $FF, $00, $00, $00, $FF
  ; blocks at pixel positionn (y=24):
  defb $00, $00, $00, $FF, $00, $00, $00, $FF

MainScreen_Couch_RArm:
  ; blocks at pixel positionn (y=0):
  defb $FF, $03, $01, $81, $C1, $41, $7F, $41
  ; blocks at pixel positionn (y=8):
  defb $41, $41, $41, $41, $C1, $C1, $41, $C1
  ; blocks at pixel positionn (y=16):
  defb $41, $41, $41, $81, $01, $01, $01, $FF
  ; blocks at pixel positionn (y=24):
  defb $1E, $0E, $0E, $0E, $0E, $00, $00, $00

MainScreen_Attributes:
  ; TOP: 0x4000, 16384;  BC for 1/3: 07FF, BC for 2/3: 0FFF BC for 3/3: 17FF
  defb $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30
  defb $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30
  defb $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70
  defb $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70
  defb $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $28, $28, $28
  defb $70, $70, $70, $70, $70, $70, $70, $70, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $70, $70, $70, $70, $70, $70, $70, $28, $68, $68
  defb $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $28, $68, $68
  defb $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $28, $68, $68
  ; MID: 0x4800, 18432
  defb $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $28, $68, $68
  defb $70, $70, $70, $30, $30, $30, $30, $30, $30, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $30, $30, $30, $30, $30, $30, $70, $70, $28, $68, $68
  defb $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $28, $68, $68
  defb $70, $70, $70, $70, $70, $70, $70, $70, $4B, $4B, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $28, $68, $68
  defb $70, $70, $70, $70, $70, $70, $70, $70, $0F, $0F, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $28, $68, $68
  defb $70, $70, $70, $70, $70, $70, $70, $30, $30, $30, $30, $30, $30, $70, $70, $70, $70, $70, $30, $30, $30, $30, $30, $30, $70, $70, $70, $70, $70, $28, $6F, $6F
  defb $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $28, $70, $70
  defb $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70
  ; BOT: 0x5000, 20480
  defb $00, $00, $00, $38, $70, $70, $70, $70, $70, $70, $53, $53, $53, $53, $53, $53, $53, $53, $53, $53, $53, $70, $70, $70, $70, $78, $70, $70, $70, $70, $70, $70
  defb $00, $00, $38, $38, $38, $70, $70, $70, $70, $53, $53, $53, $53, $53, $53, $53, $53, $53, $53, $53, $53, $53, $70, $70, $70, $78, $70, $70, $70, $70, $70, $70
  defb $38, $38, $38, $38, $38, $70, $70, $70, $70, $13, $53, $53, $53, $53, $53, $53, $53, $53, $53, $53, $53, $13, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70
  defb $38, $38, $82, $38, $38, $60, $60, $60, $60, $13, $13, $13, $13, $13, $13, $13, $13, $13, $13, $13, $13, $13, $60, $60, $60, $60, $60, $60, $60, $60, $60, $60
  defb $38, $38, $38, $38, $60, $60, $60, $60, $60, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $60, $60, $60, $60, $60, $60, $60, $60, $60, $60
  defb $38, $38, $38, $60, $60, $60, $60, $60, $60, $60, $60, $60, $60, $60, $60, $60, $60, $60, $60, $60, $60, $60, $60, $60, $60, $60, $60, $60, $60, $60, $60, $60
  defb $38, $38, $60, $60, $60, $60, $60, $60, $60, $60, $60, $60, $60, $60, $60, $60, $60, $60, $60, $60, $60, $60, $60, $60, $60, $60, $60, $60, $60, $60, $60, $60
  defb $60, $60, $60, $60, $60, $60, $60, $60, $60, $60, $60, $60, $60, $60, $60, $60, $60, $60, $60, $60, $60, $60, $60, $60, $60, $60, $60, $60, $60, $60, $60, $60



