$MODDE2

CLK EQU 33333333
FREQ_0 EQU 100
FREQ_2 EQU 440
TIMER0_RELOAD EQU 65536-(CLK/(12*FREQ_0))
TIMER2_RELOAD EQU 65536-(CLK/(12*2*FREQ_2))
FREQ   EQU 33333333
BAUD   EQU 115200
T2LOAD EQU 65536-(FREQ/(32*BAUD))

FREQ_B EQU 493
FREQ_A EQU 440
FREQ_2a EQU 100
FREQ_G EQU 392
FREQ_D EQU 587
FREQ_C EQU 523
FREQ_F EQU 698
FREQ_E EQU 659

FREQ_G2 EQU 784

NOTE_A EQU 65536-(CLK/(12*2*FREQ_A))
NOTE_B EQU 65536-(CLK/(12*2*FREQ_B))
NOTE_G EQU 65536-(CLK/(12*2*FREQ_G))
NOTE_D EQU 65536-(CLK/(12*2*FREQ_D))
NOTE_C EQU 65536-(CLK/(12*2*FREQ_C))
NOTE_F EQU 65536-(CLK/(12*2*FREQ_F))
NOTE_E EQU 65536-(CLK/(12*2*FREQ_E))

NOTE_G2 EQU 65536-(CLK/(12*2*FREQ_G2))
CSEG
SCLK EQU P0.2
MOSI EQU P0.1
MISO EQU P0.0
CE_ADC EQU P0.3

org 0000H
	ljmp myProgram
	
org 000BH
	ljmp ISR_timer0

org 002BH
	ljmp ISR_timer2


DSEG at 30h
settemp: ds 1
settemp2: ds 1
settime: ds 1
temp: 	ds 1
sec: 	ds 1
pwm: 	ds 1
state: 	ds 1
Cnt_10ms: ds 1
x:   ds 4
y:   ds 4
n: ds 4
settime2: ds 1
m: ds 4
bcd: ds 5
adc_channel: ds 1
hot: ds 4
cold: ds 4
total: ds 4
buzzz: ds 1
buzzz2: ds 1
song: ds 1
time: ds 1
sound1: ds 1
start: ds 1
longbuzz: ds 1
seconds: ds 1
minutes: ds 1

BSEG
mf: dbit 1

$include(math32.asm)
$include(LCD-Andy.asm)
$include(functions.asm)
$include(Vivaldi-Andy.asm)
CSEG
myLUT:
    DB 0C0H, 0F9H, 0A4H, 0B0H, 099H
    DB 092H, 082H, 0F8H, 080H, 090H
ISR_timer0:	
 	lcall LCD_time
 	clr TF1
    mov TH0, #high(TIMER0_RELOAD)
    mov TL0, #low(TIMER0_RELOAD)
    push acc
    push psw 
    inc Cnt_10ms
    mov a, Cnt_10ms
    cjne a, #100, No_reset_Cnt_10ms
    mov Cnt_10ms, #0
    mov a, time
    cjne a, #0, no_reset_cnt_10ms 
    lcall Timer
No_reset_Cnt_10ms:
	mov a, Cnt_10ms
	clr c 
	subb a, pwm
	jc pwm_GT_Cnt_10ms
	clr P2.4
	sjmp Done_PWM
pwm_GT_Cnt_10ms:
	setb P2.4
Done_PWM:	
    pop psw
    pop acc
	reti
	
Timer:
	mov a, sec
	inc a
	mov sec, a
	mov a, seconds
	cjne a, #59H, not_60
	mov a, minutes
	add a, #1
	da a
	mov minutes, a
	mov seconds, #0
	ret
not_60:
	mov a, seconds
	add a, #1
	da a
	mov seconds, a
	ret

ISR_timer2:
    push acc
    push psw 
 	cpl P3.6
 	mov a, song
	cjne a, #0, play_song
	mov a, longbuzz
	cjne a, #0, play_longbuzz
    mov TH1, #high(TIMER2_RELOAD)
    mov TL1, #low(TIMER2_RELOAD)
    mov a, buzzz
    cjne a, #250, increment
    mov a, buzzz2
    cjne a, #250, increment2
	mov  buzzz, #0
	mov buzzz2, #0
	mov ledrc, #0000B
	setb et0
	clr ET1
	
Continue_int:	
    pop psw
    pop acc
    clr a
 	reti

increment:
	inc a
	mov buzzz, a	
	sjmp Continue_int
	
increment2:
	inc a
	mov buzzz2, a
	sjmp Continue_int

play_longbuzz:
	mov a, sound1
	mov TH1, #high(NOTE_C)
	mov TL1, #low(NOTE_C)
	pop psw
	pop acc
	reti

play_song:
	mov a, sound1
	cjne a, #0, buzz2 
    mov TH1, #high(NOTE_A)
    mov TL1, #low(NOTE_A)
    pop psw
    pop acc
    reti
buzz2:
	cjne a, #1, buzz3
	mov TH1, #high(NOTE_B)
    mov TL1, #low(NOTE_B)
    pop psw
    pop acc
	reti
buzz3:
	cjne a, #2, buzz4
	mov TH1, #high(NOTE_G)
    mov TL1, #low(NOTE_G)
    pop psw
    pop acc
	reti
buzz4:
	cjne a, #3, buzz5
	mov TH1, #high(NOTE_D)
    mov TL1, #low(NOTE_D)
    pop psw
    pop acc
	reti
buzz5:
	cjne a, #4, buzz6
	mov TH1, #high(NOTE_C)
    mov TL1, #low(NOTE_C)
    pop psw
    pop acc
	reti
buzz6:
	cjne a, #5, buzz7
	mov TH1, #high(NOTE_G2)
    mov TL1, #low(NOTE_G2)
    pop psw
    pop acc
	reti
buzz7:
	cjne a, #6, buzz8
	mov TH1, #high(NOTE_E)
    mov TL1, #low(NOTE_E)
    pop psw
    pop acc
	reti
buzz8:
	mov TH1, #high(NOTE_f)
    mov TL1, #low(NOTE_f)
    pop psw
    pop acc
 	reti	

myProgram:
	mov cnt_10ms, #0
	MOV SP, #7FH
	mov LEDRA, #0
	mov LEDRB, #0
	mov LEDRC, #0
	mov LEDG, #0
	mov state, #0	
	mov pwm, #0
	mov sec, #0
	mov temp, #0 
	mov adc_channel, #0
	mov buzzz, #0
	mov buzzz2, #0
	mov song, #0
	mov sound1, #0
	mov start, #0
	mov settime, #60
	mov settime2, #45
	mov settemp, #140
	mov settemp2, #220
	mov longbuzz, #0
	mov time, #1
	mov seconds, #0
	mov minutes, #0
	mov P0MOD, #00000001B ; P0.0, P0.1 are outputs.  P0.1 is used for testing Timer 2! 
	orl P0MOD, #00001000b
	mov P2MOD, #11111111B
	mov P3MOD, #11000000B
	mov TMOD,  #00010001B ; GATE=0, C/T*=0, M1=0, M0=1: 16-bit timer
	clr TR0 ; Disable timer 0
	clr TF0
    setb TR0 ; Enable timer 0
	clr ET0
	lcall Init_Timer1
	clr p3.7
	setb EA  ; Enable all interrupts 
	clr ET1
	setb LCD_ON
    clr LCD_EN  ; Default state of enable must be zero
    lcall Wait40us
    mov LCD_MOD, #0xff ; Use LCD_DATA as output port
    clr LCD_RW ;  Only writing to the LCD in this code.
    lcall cl
    lcall InitSerialPort
	lcall INIT_SPI
	ljmp forever

Init_Timer1:
	clr TR0 ; Disable timer 1
	clr TF0
    mov TH0, #high(TIMER0_RELOAD)
    mov TL0, #low(TIMER0_RELOAD)
    setb TR0 ; Enable timer 0
    setb ET0 ; Enable timer 0 interrupt
    clr TR1
    clr TF1
    setb TR1 ; Enable timer 0
    setb ET1 ; Enable timer 0 interrupt  
    clr p3.7  
    ret
   reset:
	mov LEDRA, #0
	mov LEDG, #0
	mov state, #0
	mov sec, #0
	mov seconds, #0
	mov minutes, #0
	mov HEX6, #11111111B
	mov HEX7, #11111111B
	lcall cl
	ljmp forever
forever:
	lcall coldtemp
	lcall hottemp
	lcall totaltemp
	mov a, state
	jnb KEY.2, reset 
	jnb swa.0, s1
	mov state, #0
	mov a, state
	ljmp state0
s1:	jnb swa.1, s2
	jnb swa.7, v1
	lcall lcd_set_soaktemp
	lcall set_soaktemp
	lcall reset
v1:	mov state, #1
	mov a, state
	ljmp state0
s2:	jnb swa.2, s3
	jnb swa.7, v2
	lcall lcd_set_soaktime
	lcall set_soaktime
	lcall reset
v2:	mov state, #2
	mov a, state
	ljmp state0
s3: jnb swa.3, s4
	jnb swa.7, v3
	lcall lcd_set_reflowtemp
	lcall set_reflowtemp
	lcall reset
v3:	mov state, #3
	mov a, state
	ljmp state0
s4: jnb swa.4, s5
	jnb swa.7, v4
	lcall lcd_set_reflowtime
	lcall set_reflowtime
	lcall reset
v4:	mov state, #4
	mov a, state
	ljmp state0
s5: jnb swa.5, s6
	mov state, #5
	mov a, state
	ljmp state0
s6: ljmp state0
	

	
;***************IDLE***************
State0:
	cjne a, #0, State1
	lcall LCD_idle
	mov LEDG,#00000001B
	mov pwm, #0 
	mov time, #1					;set power to 0%
	jb KEY.3, state0_done
	jnb KEY.3, $ 					;wait for key release					
	mov state, #1
	lcall cl
	mov sec, #0 
	mov time, #0
	clr et0
	lcall Buzzer_Go
State0_done:
	ljmp forever
	
;***************RAMP TO SOAK***************
state1:
	cjne a, #1, state2
	mov a, start
	cjne a, #0, begin
	mov a, #30H
	lcall putchar
	mov a, #'\r'
	lcall putchar
	mov a, #'\n'
	lcall putchar
begin:	
	inc sec
	lcall delay
	mov a, #50
	clr c
	subb a, temp
	jc no_error
	mov a, #60
	clr c
	subb a, sec
	jnc no_error
	lcall cl
	mov sec, #0
	clr et0
	setb ET1
	lcall error_buzz
	lcall error_buzz
	lcall error_buzz
	clr ET1
	setb et0
	lcall reset
no_error:
	mov start, #1
	lcall LCD_ramp_to_soak
	mov LEDG,#00000011B
	mov pwm, #100 					;set power to 100%
	mov a, settemp
	clr c
	subb a, temp
;	lcall compare150
	jnc state1_done
	lcall cl
	mov state, #2
	clr c 					;go to next state when temp is 150
	clr et0
	lcall Buzzer_Go
	mov sec, #0
state1_done:
	ljmp forever
	
;***************PREHEAT/SOAK***************
state2:
	
	cjne a, #2, state3
	mov LEDRA, sec
	lcall LCD_soak
	mov LEDG,#00000111B
	mov pwm, #20
	mov LEDRA, sec
;	lcall compare60
	mov a, sec
	cjne a, settime, state2_done		;go to state 3 after 60 seconds
	mov sec, #0
	lcall cl
	mov ledra, #00000000B
	mov state, #3	
	clr et0
	lcall Buzzer_Go
state2_done:
	ljmp forever	
	
;***************RAMP TO PEAK***************
state3:
	cjne a, #3, state4
	lcall LCD_ramp_to_peak
	mov LEDG,#00001111B
	mov pwm, #100 					;set power to 100%
	mov a, settemp2
	clr c
	subb a, temp
;	lcall compare150
	jnc state3_done					;go to next state when temp is 220
;	lcall compare220
	mov ledra, #00000000b
	mov state, #4
	lcall cl
	mov sec, #0
	clr et0
	lcall Buzzer_Go
state3_done:
	ljmp forever
	
;***************REFLOW***************
state4:
	mov LEDRA, sec
	cjne a, #4, state5
	lcall LCD_reflow
	mov LEDG,#00011111B
	mov pwm, #20 
;	lcall compare60
	mov a, sec
	cjne a, settime2, state4_done
	mov sec, #0
	lcall cl 				;next state after 45 seconds
	mov state, #5
	mov LEDRA, #00000000B
	mov longbuzz, #1
	clr et0
	setb ET1
	lcall long_buzz
	clr ET1
	setb et0
	mov longbuzz, #0
state4_done:
	ljmp forever
	
;***************COOLING***************
state5:
	lcall LCD_cooling
	mov LEDG,#00111111B
	mov pwm, #0 					;set power to 0%
	mov a, #60
	clr c
	subb a, temp
;	lcall compare60temp
	jc state5_done 				;next state when temp is 60
	mov state, #0
	lcall cl					;finish cycle, back to state 0 (idle)
	mov song, #1
	clr et0
	setb ET1
	lcall buzz
	clr ET1
	setb et0
	mov song, #0
state5_done:
	ljmp forever
coldtemp:
	push x
	mov adc_channel, #0
	lcall Read_ADC
	Load_x(5000)
	mov y+0, R3
	mov y+1, R4
	mov y+2, #0
	mov y+3, #0
	lcall mul32
	Load_y(1023)
	lcall div32
	Load_y(2730)
	lcall sub32
	Load_y(1000)
	lcall mul32
	mov n+0, x+0
	mov n+1, x+1
	mov n+2, x+2
	mov n+3, x+3
	pop x
	ret
hottemp:
	push x
	mov adc_channel ,#1
	lcall Read_ADC
    Load_x(5000)
	mov y+0, R3
	mov y+1, R4
	mov y+2, #0
	mov y+3, #0
	lcall mul32
	Load_y(1023)
	lcall div32
	Load_y(15)
	lcall div32
	Load_y(10000)
	lcall mul32
	mov m+0, x+0
	mov m+1, x+1
	mov m+2, x+2
	mov m+3, x+3
	pop x
	ret
totaltemp:
	push x
	push acc
	mov x+0, n+0
	mov x+1, n+1
	mov x+2, n+2
	mov x+3, n+3
	mov y+0, m+0
	mov y+1, m+1
	mov y+2, m+2
	mov y+3, m+3
	lcall add32
	load_y(10000)
	lcall div32
	lcall hex2bcd
	lcall Display_BCD
	clr EA
	mov a, bcd+1
	anl a, #0FH
	orl a, #30H
	lcall putchar
	mov a, bcd+0
	swap a
	anl a, #0FH
	orl a, #30H
	lcall putchar
	mov a, bcd+0
	anl a, #0FH
	orl a, #30H
	lcall putchar
	mov a, #'\r'
	lcall putchar
	mov a, #'\n'
	lcall putchar
	setb EA
	lcall bcd2hex
	mov temp, x
	pop acc
	pop x
	ret
Buzzer_go:
	setb ET1
	ret
set_soaktime:
	push x
	mov pwm, #0
	mov settime, #0
	mov HEX0, #0C0H
	mov HEX1, #0C0H
	mov HEX2, #0C0H
	mov HEX3, #0C0H
	mov HEX4, #0C0H
	mov HEX5, #0C0H
soak1:
	jb KEY.3, dont_inc_time
	jnb KEY.3, $
	mov a, settime
	add a, #5
	mov settime, a
	mov x, settime
	lcall hex2bcd
	lcall display_bcd
dont_inc_time:
	jnb SWA.7, returnsoak
	ljmp soak1
returnsoak:
	jnb SWA.2, returnsoak1
	ljmp soak1
returnsoak1:
	pop x
	ret
set_reflowtime:
	push x
	mov pwm, #0
	mov settime2, #0
	mov HEX0, #0C0H
	mov HEX1, #0C0H
	mov HEX2, #0C0H
	mov HEX3, #0C0H
	mov HEX4, #0C0H
	mov HEX5, #0C0H
reflow1:
	jb KEY.3, dont_inc_time2
	jnb KEY.3, $
	mov a, settime2
	add a, #5
	mov settime2, a
	mov x, settime2
	lcall hex2bcd
	lcall display_bcd
dont_inc_time2:
	jnb SWA.7, returnreflow
	ljmp reflow1
returnreflow:
	jnb SWA.4, returnreflow1
	ljmp reflow1
returnreflow1:
	pop x
	ret
set_soaktemp:
	push x
	mov HEX0, #0C0H
	mov HEX1, #0C0H
	mov HEX2, #0C0H
	mov HEX3, #0C0H
	mov HEX4, #0C0H
	mov HEX5, #0C0H
	mov pwm, #0
	mov settemp, #0
setsoak1:
	jb KEY.3, dont_inc_temp
	jnb KEY.3, $
	mov a, settemp
	add a, #5
	mov settemp, a
	mov x, settemp
	lcall hex2bcd
	lcall display_bcd
	mov LEDRA, settemp
dont_inc_temp:
	jnb SWA.7, returnsoaktemp
	ljmp setsoak1
returnsoaktemp:
	jnb SWA.4, returnsoaktemp1
	ljmp setsoak1
returnsoaktemp1:
	pop x
	ret
set_reflowtemp:
	push x
	mov HEX0, #0C0H
	mov HEX1, #0C0H
	mov HEX2, #0C0H
	mov HEX3, #0C0H
	mov HEX4, #0C0H
	mov HEX5, #0C0H
	mov pwm, #0
	mov settemp2, #0
setsoak2:
	jb KEY.3, dont_inc_temp2
	jnb KEY.3, $
	mov a, settemp2
	add a, #5
	mov settemp2, a
	mov x, settemp2
	lcall hex2bcd
	lcall display_bcd
	mov LEDRA, settemp2
dont_inc_temp2:
	jnb SWA.7, returnsoaktemp2
	ljmp setsoak2
returnsoaktemp2:
	jnb SWA.4, returnsoaktemp3
	ljmp setsoak2
returnsoaktemp3:
	pop x
	ret				
END
