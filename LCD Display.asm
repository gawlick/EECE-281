$NOLIST

Ascii:
	DB '0', '1', '2', '3', '4', '5', '6', '7', '8', '9'
	
CSEG
Wait40us:
	mov R0, #149
X1: 
	nop
	nop
	nop
	nop
	nop
	nop
	djnz R0, X1 ; 9 machine cycles-> 9*30ns*149=40us
    ret

LCD_command:
	mov	LCD_DATA, A
	clr	LCD_RS
	nop
	nop
	setb LCD_EN ; Enable pulse should be at least 230 ns
	nop
	nop
	nop
	nop
	nop
	nop
	clr	LCD_EN
	ljmp Wait40us

LCD_put:
	mov	LCD_DATA, A
	setb LCD_RS
	nop
	nop
	setb LCD_EN ; Enable pulse should be at least 230 ns
	nop
	nop
	nop
	nop
	nop
	nop
	clr	LCD_EN
	ljmp Wait40us
	    
	
cl:	mov a, #0ch ; Display on command
	lcall LCD_command
	mov a, #38H ; 8-bits interface, 2 lines, 5x7 characters
	lcall LCD_command
	mov a, #01H ; Clear screen (Warning, very slow command!)
	lcall LCD_command
    mov R1, #40
    ; Delay loop needed for 'clear screen' command above (1.6ms at least!)
Clr_loop:
 
	lcall Wait40us
	djnz R1, Clr_loop

	; Move to first column of first row	
	mov a, #80H
	lcall LCD_command
 	ret

LCD_ramp_to_peak:
	lcall Wait40us
	mov a, #80H
	lcall LCD_command
	mov a, #'R'
	lcall LCD_put
	mov a, #'a'
	lcall LCD_put
	mov a, #'m'
	lcall LCD_put
	mov a, #'p'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'t'
	lcall LCD_put
	mov a, #'o'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'P'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #'a'
	lcall LCD_put
	mov a, #'k'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	ret
LCD_cooling:
	lcall Wait40us
	mov a, #80H
	lcall LCD_command	
	mov a, #'C'
	lcall LCD_put
	mov a, #'o'
	lcall LCD_put
	mov a, #'o'
	lcall LCD_put
	mov a, #'l'
	lcall LCD_put
	mov a, #'i'
	lcall LCD_put
	mov a, #'n'
	lcall LCD_put
	mov a, #'g'
	lcall LCD_put
	ret

LCD_reflow:
	lcall Wait40us
	mov a, #80H
	lcall LCD_command
	mov a, #'R'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #'f'
	lcall LCD_put
	mov a, #'l'
	lcall LCD_put
	mov a, #'o'
	lcall LCD_put
	mov a, #'w'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	ret
LCD_idle:
	lcall Wait40us
	mov a, #80H
	lcall LCD_command
	mov a, #'I'
	lcall LCD_put
	mov a, #'d'
	lcall LCD_put
	mov a, #'l'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	ret
LCD_ramp_to_soak:
	lcall Wait40us
	mov a, #80H
	lcall LCD_command
	mov a, #'R'
	lcall LCD_put
	mov a, #'a'
	lcall LCD_put
	mov a, #'m'
	lcall LCD_put
	mov a, #'p'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'t'
	lcall LCD_put
	mov a, #'o'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'S'
	lcall LCD_put
	mov a, #'o'
	lcall LCD_put
	mov a, #'a'
	lcall LCD_put
	mov a, #'k'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	ret
LCD_soak:
	lcall Wait40us
	mov a, #80H
	lcall LCD_command
	mov a, #'S'
	lcall LCD_put
	mov a, #'o'
	lcall LCD_put
	mov a, #'a'
	lcall LCD_put
	mov a, #'k'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	ret
	
LCD_Time:
	mov dptr, #Ascii
	lcall Wait40us
	mov a, #0a8H
	lcall LCD_command
	mov a, #'T'
	lcall LCD_put
	mov a, #'i'
	lcall LCD_put
	mov a, #'m'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #':'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, minutes
	swap a
	anl a, #00001111B
	movc a, @a+dptr 
	lcall LCD_put
	mov a, minutes
	anl a, #00001111B
	movc a, @a+dptr
	lcall LCD_put
	mov a, #':'
	lcall LCD_put
	mov a, seconds
	swap a
	anl a, #00001111B
	movc a, @a+dptr 
	lcall LCD_put
	mov a, seconds
	anl a, #00001111B
	movc a, @a+dptr 
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	ret
LCD_set_reflowtemp:
	lcall Wait40us
	mov a, #80H
	lcall LCD_command
	mov a, #'S'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #'t'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'R'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #'f'
	lcall LCD_put
	mov a, #'l'
	lcall LCD_put
	mov a, #'o'
	lcall LCD_put
	mov a, #'w'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'T'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #'m'
	lcall LCD_put
	mov a, #'p'
	lcall LCD_put
	ret
LCD_set_soaktemp:
	lcall Wait40us
	mov a, #80H
	lcall LCD_command
	mov a, #'S'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #'t'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'S'
	lcall LCD_put
	mov a, #'o'
	lcall LCD_put
	mov a, #'a'
	lcall LCD_put
	mov a, #'k'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'T'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #'m'
	lcall LCD_put
	mov a, #'p'
	lcall LCD_put
	ret
LCD_set_soaktime:
	lcall Wait40us
	mov a, #80H
	lcall LCD_command
	mov a, #'S'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #'t'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'S'
	lcall LCD_put
	mov a, #'o'
	lcall LCD_put
	mov a, #'a'
	lcall LCD_put
	mov a, #'k'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'T'
	lcall LCD_put
	mov a, #'i'
	lcall LCD_put
	mov a, #'m'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	ret
LCD_set_reflowtime:
	lcall Wait40us
	mov a, #80H
	lcall LCD_command
	mov a, #'S'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #'t'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'R'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #'f'
	lcall LCD_put
	mov a, #'l'
	lcall LCD_put
	mov a, #'o'
	lcall LCD_put
	mov a, #'w'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'T'
	lcall LCD_put
	mov a, #'i'
	lcall LCD_put
	mov a, #'m'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	ret
LCD_pizza_time:
	lcall Wait40us
	mov a, #80H
	lcall LCD_command
	mov a, #'P'
	lcall LCD_put
	mov a, #'I'
	lcall LCD_put
	mov a, #'Z'
	lcall LCD_put
	mov a, #'Z'
	lcall LCD_put
	mov a, #'A'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'T'
	lcall LCD_put
	mov a, #'I'
	lcall LCD_put
	mov a, #'M'
	lcall LCD_put
	mov a, #'E'
	lcall LCD_put
	ret
LCD_set_pizzatime:
	lcall Wait40us
	mov a, #0A8H
	lcall LCD_command
	mov a, #'S'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #'t'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'P'
	lcall LCD_put
	mov a, #'i'
	lcall LCD_put
	mov a, #'z'
	lcall LCD_put
	mov a, #'z'
	lcall LCD_put
	mov a, #'a'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'T'
	lcall LCD_put
	mov a, #'i'
	lcall LCD_put
	mov a, #'m'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	ret	
LCD_set_pizzatemp:
	lcall Wait40us
	mov a, #0A8H
	lcall LCD_command
	mov a, #'S'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #'t'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'P'
	lcall LCD_put
	mov a, #'i'
	lcall LCD_put
	mov a, #'z'
	lcall LCD_put
	mov a, #'z'
	lcall LCD_put
	mov a, #'a'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'T'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #'m'
	lcall LCD_put
	mov a, #'p'
	lcall LCD_put
	ret	
end
