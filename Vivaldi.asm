$NOLIST

WaitSec:
	mov R2, #250
K3: mov R1, #250
K2: mov R0, #250
K1: djnz R0, K1
	djnz R1, K2
	djnz R2, K3
	clr et1
	ret

WaitHalfSec:
	mov R2, #90
L3: mov R1, #250
L2: mov R0, #100
L1: djnz R0, L1
	djnz R1, L2
	djnz R2, L3
	ret
	
WaitQuartSec:
	mov R2, #90
Q3: mov R1, #250
Q2: mov R0, #50
Q1: djnz R0, Q1
	djnz R1, Q2
	djnz R2, Q3
	ret

WaitEighthSec:
	mov R2, #90
E3: mov R1, #250
E2: mov R0, #25
E1: djnz R0, E1
	djnz R1, E2
	djnz R2, E3
	ret
	
Wait16thSec:
	mov R2, #90
D3: mov R1, #125
D2: mov R0, #25
D1: djnz R0, D1
	djnz R1, D2
	djnz R2, D3
	ret
	
buzz: ; A = 0, 
	;	B = 1, 
	;	G = 2, 
	;	D = 3
	;	C = 4
	;	G2 = 5
	lcall play_C
	lcall halfnote
	lcall play_E
	lcall halfnote
	lcall play_E
	lcall halfnote
	lcall play_E
	lcall halfnote
	lcall play_D
	lcall quartnote
	lcall play_C
	lcall quartnote
	lcall play_g2
	lcall wholenote
	;
	lcall play_g2
	lcall quartnote
	lcall play_f
	lcall quartnote
	lcall play_E
	lcall halfnote
	lcall play_E
	lcall halfnote
	lcall play_E
	lcall halfnote
	lcall play_D
	lcall quartnote
	lcall play_C
	lcall quartnote
	lcall play_g2
	lcall wholenote
	lcall play_g2
	lcall quartnote
	lcall play_f
	lcall quartnote
	lcall play_e
	lcall halfnote
	lcall play_f
	lcall quartnote
	lcall play_g2
	lcall quartnote
	lcall play_f
	lcall halfnote
	lcall play_e
	lcall halfnote
	lcall play_d
	lcall halfnote
	lcall play_g
	lcall halfnote
	lcall play_g
	lcall halfnote
    mov TH0, #high(TIMER0_RELOAD)
    mov TL0, #low(TIMER0_RELOAD)
	ret
play_A:
	lcall wait16thsec
	mov sound1, #0 
	setb ET1
	;lcall waithalfsec
	;clr ET0
	ret
play_B:
	lcall wait16thsec
	mov sound1, #1 
	setb ET1
	;lcall waithalfsec
	;clr ET0
	ret
play_G:
	lcall wait16thsec
	mov sound1, #2 
	setb ET1
	;lcall waithalfsec
	;clr ET0
	ret
play_D:
	lcall wait16thsec
	mov sound1, #3 
	setb ET1
	;lcall waithalfsec
	;clr ET0
	ret
play_C:
	lcall wait16thsec
	mov sound1, #4 
	setb ET1
	;lcall waithalfsec
	;clr ET0
	ret
play_E:
	lcall wait16thsec
	mov sound1, #6 
	setb ET1
	;lcall waithalfsec
	;clr ET0
	ret
play_G2:
	lcall wait16thsec
	mov sound1, #5 
	setb ET1
	;lcall waithalfsec
	;clr ET0
	ret
play_f:
	lcall wait16thsec
	mov sound1, #7 
	setb ET1
	;lcall waithalfsec
	;clr ET0
	ret
play_cooling:
	lcall wait16thsec
	mov sound1, #4 
	setb ET1
	;lcall waithalfsec
	;clr ET0
	ret
wholenote:
	lcall waithalfsec
	lcall waithalfsec
	clr et1
	ret
halfnote:
	lcall waithalfsec
	clr et1
	ret
quartnote:
	lcall waitquartsec
	clr et1
	ret
eighthnote:
	lcall waiteighthsec
	clr et1
	ret
halfrest:
	clr et1
	lcall waithalfsec
	ret
	
error_buzz:
	lcall play_c
	lcall quartnote
	lcall play_c
	lcall quartnote
	lcall play_c
	lcall quartnote
	lcall play_c
	lcall quartnote
	lcall play_c
	lcall quartnote	
	ret
long_buzz:
	lcall play_cooling
	lcall WaitHalfSec
	lcall WaitHalfSec
	lcall WaitHalfSec
	lcall WaitHalfSec
	lcall WaitHalfSec
	lcall WaitHalfSec
	lcall WaitHalfSec
	lcall WaitHalfSec
	lcall WaitHalfSec
	lcall WaitHalfSec
	lcall WaitHalfSec
	lcall WaitHalfSec	
	lcall WaitHalfSec
	lcall WaitHalfSec
	lcall WaitHalfSec
	lcall WaitHalfSec
	lcall WaitHalfSec
	lcall WaitHalfSec
	lcall WaitHalfSec
	lcall WaitHalfSec
	lcall WaitHalfSec
	lcall WaitHalfSec
	lcall WaitHalfSec
	lcall WaitHalfSec
	ret
END

