// Author: Sharon Pak

 setup:
	ldi r20,0b00000011			;1 for output pins, 0 for inputs
	out ddrc,r20				;program pc0 and pc1 as outputs
	ldi r20,0xff				;load 11111111 in r20
	out ddrd,r20				;program all of portd as outputs

//setup portb
	ldi r16,0xfe				;turn pnp transistors off, pullups on
	out portb,r16
	ldi r16,0b11000111
	out ddrb,r16

 .def ticks = r16				;renames r16 as 'ticks'
 .def secs  = r17				;renames r17 as 'secs'
 .def mins  = r18				;renames r18 as 'mins'
 .def hrs   = r19				;renames r19 as 'hrs'

 clr ticks					;clears ticks
 clr secs					;clears secs
 clr mins					;clears mins
 clr hrs					;clears hrs

tick:
	sbis pinc,7				;check pinc value
	rjmp tick				;if 0, jump back to tick
	inc ticks				;+1 tick
	cpi ticks,60				;compare ticks to 60
	brne tock				;if ticks!=60, skip to tock
	clr ticks				;clear ticks
	inc secs				;increments seconds
	cpi secs,60				;compares secs to 60
	brne tock				;if secs!=60, jump to tock
	clr sec					;clears secs
	inc mins				;+1 min
	cpi mins,60				;compares mins to 60
	brne tock				;if mins!=60, jump to tock
	clr mins				;clear minutes to zero
	inc hrs					;increases hours by 1
	cpi hrs,24				;compares hours to 24
	brne tock				;if hours!=24, jump to tock
	clr hrs					;clear hours to zero
	rjmp tock				;jump back to tock

tock:							
	com secs				;inverts secs
	out portd,secs				;copy secs to portd
	com secs				;inverts secs back to normal
	cbi portd,6				;enables colon LED
	cbi portd,7
	cbi portb,0				;enables 0 - 6LEDs
	rcall delay_21k				;waits a while (21000 clock cycles)
	sbi portb,0				;disables 0
	mov r20,hrs				;prepping for get_segs
	rcall get_segs				;converts binary to decimal for hours
	out portd,r21				;displays ones for hours
	cbi portb,1				;enables 1 - 6LEDs
	rcall delay_21k				;delays 21000 clock cycles
	sbi portb,1				;disables 1
	out portd,r22				;displaying tens for hours
	cbi portb,2				;enables 2 - 6LEDs
	rcall delay_21k				;delays 21000 clock cycles
	sbi portb,2				;disables 2
	mov r20,mins				;prepping for get_segs
	rcall get_segs				;converts binary to decimal for minutes
	out portd,r21				;displaying ones for minutes
	cbi portb,6				;enables 3 - 6LEDs
	rcall delay_21k				;delays 21000 clock cycles
	sbi portb,6				;disables 3
	out portd,r22				;displaying tens for minutes
	cbi portb,7				;enables 4 - 6LEDs
	rcall delay_21k				;delays 21000 clock cycles
	sbi portb,7				;disables 4
	sbic pinc,7				;waiting for 1 to 0
	rjmp tock				;if still 1, continue displaying/wait
	rjmp tick				;if zero, jumps back to tick

get_segs:
	clr r0					;clear tens register

div_m:
	cpi r20,10				;>10?		
	brlo done_div_m				;if no, done
	inc r0					;increment tens count
	subi r20,10				;subtract 10 from scr 
	rjmp div_	  			;repeat until r20 is less than 10

done_div_m:
	ldi zh,high(seg_table<<1)		;load z register for indirect read
	ldi zl,low(seg_table<<1)
	add zl,r0				;compute offset into the table
	brcc nc1_m				;carry required?
	inc zh					;carry

nc1_m:
	lpm r21,z				;read segments from data table
	ldi zh,high(seg_table<<1)		;load z register for indirect read
	ldi zl,low(seg_table<<1)
	add zl,r20				;compute offset into the table
	brcc nc2_m				;carry required?
	inc zh					;carry

nc2_m:
	lpm r22,z				;read segments from data table
	ret	        	       		;return

// delay_21k simply calls delay 21 times
delay_21k:
	rcall delay
	rcall delay
	rcall delay
	rcall delay
	rcall delay
	rcall delay
	rcall delay
	rcall delay
	rcall delay
	rcall delay
	rcall delay
	rcall delay
	rcall delay
	rcall delay
	rcall delay
	rcall delay
	rcall delay
	rcall delay
	rcall delay
	rcall delay
	rcall delay
	ret

//delay takes 1003 cycles to execute
delay:
    clr r31     		 		;initialize register 31

delay_loop:
    inc r31
    cpi r31,0xf9
    brne delay_loop
    ret

//keep seg_table at end
seg_table:					;initializes LED segment table
	.dw 0xeb09				;1,0
	.dw 0xc185				;3,2
	.dw	0x5163				;5,4
	.dw 0xcb11				;7,6
	.dw 0x4101				;9,8
	.dw 0x00ff				;on,off
