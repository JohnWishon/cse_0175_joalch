org 33000

main:
	
LD BC,&FEFE        ; Load BC with the row port address: <shft>, z,x,c,v
IN A,(C)           ; Read the port into the accumulator
AND %00000001      ; Mask out the key we are interested in
JR Z,Q_KEY_PRESSED ; If the result is zero, then the key has been pressed...




q_is_pressed:



