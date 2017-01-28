; GETTING STARTED:
;	$ z80asm -b file.asm 
;	$ appmake +zx --org 32768 -o file.tap -b file.bin
;
; FACTS: 
;	Spectrum display has 24 LINES, each line having 8 ROWS of PIXELS,
;		rather than 24 rows of 8 pixel lines, thus 24 x 8 = 192 rows.
;
; 		6144 bytes of pixel display. (* 17FF+1)
;		768 bytes of attribute data.
;		
;		COLUMN: 32 bytes (columns); 8 bits per column.
;		
;
;	CELLS: 768 ( 24 x 32 )
;
;	In terms of CPU address space this begins at 0x4000 (16384) in the
;		memory map; (?)and ends at 0x57FF (22527).(?)
;
;		TOP: 	4000h 	(16384) ( row - 0 ; line - 0 ) 	BC(1/3)07FFH:
;		MIDDLE: 4800h 	(18432)							
;		BOTTOM:	5000h	(20480)
;
;		* To save the bottom two thirds of screen:
;		* 	SAVE "(NAME)"CODE 18432, 40966
;
;		** row (0-7) of line 0, then row (0-7) of line 1
;		** at row 7, line 7 2K has been mapped
;		
;
;	However, the video controller only has acess to this 16K region of
;		momeory, thus.
;	
;	DISPLAY FILE ADDRESS:
;		Hi-Lo Byte: 010 00000 000{row 0-7} (line 0-23) 00000 (col 0-31)
;
;	