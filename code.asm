;Traffic lights project
;Tilaveridis Iordanis-Migioudis, 7993
;Vasilios Bletsos, 8687
;GroupE

.INCLUDE "m16def.inc"

.EQU BEred_ADgreen = 0b00001010
.EQU BEred_ADyellow = 0b00000101
.EQU BEred_ADred = 0b00000000
.EQU BEyellow_ADred = 0b01010000
.EQU BEgreen_ADred = 0b10100000
.EQU BEyellow_ADyellow = 0b01010101
.EQU Fred_Cred = 0b00000000
.EQU Fyellow_Cred = 0b00010000
.EQU Fred_Cyellow = 0b01000000
.EQU Fred_Cgreen = 0b10000000
.EQU Fgreen_Cred = 0b00100000

.def temp = r16
.def counter1s = r17
.def counterMs = r18
.def flag = r19		;to check if either of F1, C1 were pressed

.org 0x0000
rjmp reset 

.org 0x0012
rjmp TIM0_OVF


reset:
	ldi flag, 0		;initializing flag
	SER temp
	OUT DDRC, temp   ;PORTC - out port
	LDI temp, 0b11110000 
	OUT DDRA, temp ; setting PA4-7 as output ports and PA0-3 as input ports
	LDI temp, 0b11000000
	OUT DDRB, temp ; setting PB6-7 as output ports and PA0-5 as input ports
	LDI temp, 0b11111000
	OUT DDRD, temp ; setting PD4-7 as output ports and PD0-3 as input ports (PD7 is not used)

	LDI temp, HIGH(RAMEND) ; initializing the stack
	OUT SPH, temp
	LDI temp, LOW(RAMEND)
	OUT SPL, temp

	sei		; in order to enable global interrupts
	
	ldi temp, (1<<CS02)|(1<<CS00)	; initialization of timer
	out TCCR0, temp 	; Timer clock = system clock / 1024
	ldi temp, 1<<TOV0
	out TIFR, temp 		; Clear TOV0/ Clear pending interrupts
	ldi temp, 1<<TOIE0
	out TIMSK, temp 	; Enable Timer/Counter0 Overflow Interrupt
	;rjmp exit



flow1A:
	
State1fa:
   	ldi counter1s, 15   ;in order to count 1 sec at 4MHz
	ldi counterMs, 20

	ldi temp, Fred_Cred		
	out PORTA, temp
	ldi temp, BEgreen_ADred
	out PORTC, temp
	
label1fa:
	in temp, PINA
	sbrc temp, 1	; checking if switch B was pressed (if it wasn't skip next instruction)
	ldi counterMs, 3
	
	sbrc temp, 2
	ori flag, 0b00000001		;checking if C1 switch was pressed
	sbrc temp, 3
	ori flag, 0b00000010		;checking if F1 switch was pressed 

	cpi counterMs, 0
	brne label1fa

//----------------------------------------------------//

State2fa: 
	ldi counter1s, 15   ;in order to count 1 sec at 4MHz
	ldi counterMs, 3

	ldi temp, Fred_Cred		
	out PORTA, temp
	ldi temp, BEyellow_ADred
	out PORTC, temp
	
label2fa:
	in temp, PINA
	sbrc temp, 2
	ori flag, 0b00000001		;checking if C1 switch was pressed
	sbrc temp, 3
	ori flag, 0b00000010		;checking if F1 switch was pressed

	cpi counterMs, 0
	brne label2fa

//----------------------------------------------------//

State3fa:
	ldi counter1s, 15   ;in order to count 1 sec at 4MHz
	ldi counterMs, 2

	ldi temp, Fred_Cred		
	out PORTA, temp
	ldi temp, BEred_ADred
	out PORTC, temp
	
label3fa:
	in temp, PINA
	sbrc temp, 2
	ori flag, 0b00000001		;checking if C1 switch was pressed
	sbrc temp, 3
	ori flag, 0b00000010		;checking if F1 switch was pressed

	cpi counterMs, 0
	brne label3fa

//----------------------------------------------------//

State4fa:
    ldi counter1s, 15   ;in order to count 1 sec at 4MHz
	ldi counterMs, 3

	ldi temp, Fred_Cred		
	out PORTA, temp
	ldi temp, BEred_ADyellow
	out PORTC, temp
	
label4fa:	
	in temp, PINA
	sbrc temp, 2
	ori flag, 1		;checking if C1 switch was pressed
	sbrc temp, 3
	ori flag, 2		;checking if F1 switch was pressed

	cpi counterMs, 0
	brne label4fa

//----------------------------------------------------//

State5fa:
    ldi counter1s, 15   ;in order to count 1 sec at 4MHz
	ldi counterMs, 5

	ldi temp, Fred_Cred		
	out PORTA, temp
	ldi temp, BEred_ADgreen
	out PORTC, temp
	
label5fa:
	in temp, PINA
	sbrc temp, 2
	ori flag, 1		;checking if C1 switch was pressed
	sbrc temp, 3
	ori flag, 2		;checking if F1 switch was pressed

	in temp, PINA
	sbrc temp, 0	;switch A
	ldi counterMs, 3

	cpi counterMs, 0
	brne label5fa

//----------------------------------------------------//

State6fa:
    ldi counter1s, 15   ;in order to count 1 sec at 4MHz
	ldi counterMs, 3

	ldi temp, Fred_Cred		
	out PORTA, temp
	ldi temp, BEyellow_ADyellow
	out PORTC, temp


label6fa:
	in temp, PINA
	sbrc temp, 2
	ori flag, 1		;checking if C1 switch was pressed
	sbrc temp, 3
	ori flag, 2		;checking if F1 switch was pressed

	cpi counterMs, 0
	brne label6fa
	


//----------------------------------------------------//



	sbrc flag, 0
	breq C1_green

	sbrc flag, 1
	breq F1_green

	rjmp flow1A








C1_green:
    ldi counter1s, 15   ;in order to count 1 sec at 4MHz
	ldi counterMs, 6

	ldi temp, BEred_ADred
	out PORTC, temp
	ldi temp, Fred_Cgreen
	out PORTA, temp

labelC1:
	cpi counterMs, 0
	brne labelC1
	


C1_yellow:
    ldi counter1s, 15   ;in order to count 1 sec at 4MHz
	ldi counterMs, 3

	ldi temp, BEred_ADred
	out PORTC, temp
	ldi temp, Fred_Cyellow
	out PORTA, temp

labelC1yellow:
	cpi counterMs, 0
	brne labelC1yellow	

	reti

//----------------------------------------------------//

F1_green:
    ldi counter1s, 15   ;in order to count 1 sec at 4MHz
	ldi counterMs, 6

	ldi temp, BEred_ADred
	out PORTC, temp
	ldi temp, Fgreen_Cred
	out PORTA, temp

labelF1:
	cpi counterMs, 0
	brne labelF1


F1_yellow:
    ldi counter1s, 15   ;in order to count 1 sec at 4MHz
	ldi counterMs, 3

	ldi temp, BEred_ADred
	out PORTC, temp
	ldi temp, Fyellow_Cred
	out PORTA, temp

labelF1yellow:
	cpi counterMs, 0
	brne labelF1yellow

	reti


//----------------------------------------------------//


TIM0_OVF:		;the interrupt handler	
    push temp		
	in temp, SREG
	push temp

	dec counter1s
	cpi counter1s, 0
	brne not_yet
	dec counterMs

not_yet:		

	pop temp
	out SREG, temp
	pop temp
	reti


exit:
