$NOLIST
T_7seg:
    DB 0C0H, 0F9H, 0A4H, 0B0H, 099H
    DB 092H, 082H, 0F8H, 080H, 090H
    DB 088H, 083H

Display_BCD:
	
	mov dptr, #T_7seg
	
	mov a, bcd+2
	swap a
	anl a, #0FH
	movc a, @a+dptr
	mov HEX5, a
	
	mov a, bcd+2
	anl a, #0FH
	movc a, @a+dptr
	mov HEX4, a
	
	mov a, bcd+1
	swap a
	anl a, #0FH
	movc a, @a+dptr
	mov HEX3, a
	
	mov a, bcd+1
	anl a, #0FH
	movc a, @a+dptr
	mov HEX2, a

	mov a, bcd+0
	swap a
	anl a, #0FH
	movc a, @a+dptr
	mov HEX1, a
	
	mov a, bcd+0
	anl a, #0FH
	movc a, @a+dptr
	mov HEX0, a
	
	ret
Delay: 				; wait one second
	mov R2, #110
Loop3: mov R1, #250
Loop2: mov R0, #250
Loop1: djnz R0, Loop1
	djnz R1, Loop2
	djnz R2, Loop3
	ret
	
Delay2: 				; wait half second
	mov R2, #180
Loop6: mov R1, #250
Loop5: mov R0, #250
Loop4: djnz R0, Loop4
	djnz R1, Loop5
	djnz R2, Loop6
	ret
Delay3: 				; wait quarter second
	mov R2, #45
Loop9: mov R1, #250
Loop8: mov R0, #250
	Loop7: djnz R0, Loop7
	djnz R1, Loop8
	djnz R2, Loop9
	ret
putchar:
	jnb TI, putchar
	clr TI
	mov SBUF, a
	ret
InitSerialPort:
; Configure the serial port and baud rate using timer 2
	clr TR2 					; Disable timer 2
	mov T2CON, #30H 			; RCLK=1, TCLK=1
	mov RCAP2H, #high(T2LOAD)
	mov RCAP2L, #low(T2LOAD)
	setb TR2 					; Enable timer 2
	mov SCON, #52H
	ret
INIT_SPI:
	orl P0MOD, #00000110b 		; Set SCLK, MOSI as outputs
	anl P0MOD, #11111110b 		; Set MISO as input
	clr SCLK 					; For mode (0,0) SCLK is zero
	ret
DO_SPI_G:
	push acc
	clr EA
	mov R1, #0 					; Received byte stored in R1
	mov R2, #8 					; Loop counter (8-bits)
DO_SPI_G_LOOP:
	mov a, R0 					; Byte to write is in R0
	rlc a 						; Carry flag has bit to write
	mov R0, a
	mov MOSI, c
	setb SCLK 					; Transmit
	mov c, MISO 				; Read received bit
	mov a, R1 					; Save received bit in R1
	rlc a
	mov R1, a
	clr SCLK
	djnz R2, DO_SPI_G_LOOP
	setb EA
	pop acc
	ret
Read_ADC:
	clr CE_ADC
	mov R0, #00000001B		; Start bit:1
	lcall DO_SPI_G
	mov a, adc_channel
	swap a
	orl a, #10000000B
	mov R0,a
	lcall DO_SPI_G
	mov a, R1 				; R1 contains bits 8 and 9
	anl a, #03H 			; Make sure other bits are zero
	mov R4, a
	mov R0, #55H 			; It doesn't matter what we transmit...
	lcall DO_SPI_G
	mov a, R1
	mov R3, a
	setb CE_ADC
	lcall Delay3
	ret
	
END
