// definitions

.include "tn48def.inc"

.def tens = r0
.def set_count = r1
.def alarm_mins = r2
.def alarm_hrs = r3
.def state = r4
.def temp = r5
.def do_count = r6
.def b_cnt = r7

.def ticks = r16
.def secs = r17
.def mins = r18
.def hrs = r19
.def scr = r20
.def segs_h = r21
.def segs_l = r22
.def clk_stat = r23

//clk_stat register
.equ civ_mode = 0x0
.equ f50Hz = 0x1

//portb digit drivers
.equ dig0 = 0x0
.equ dig1 = 0x1
.equ dig2 = 0x2
.equ dig3 = 0x6
.equ dig4 = 0x7

//portb buttons
.equ alrmd = 0x30	;alarm button down, others up
.equ incd = 0x28	;inc button down, others up
.equ setd = 0x18	;set button down, others up
.equ null = 0x38	;all buttons up

//portc 
.equ al_lite = 0x0	;alarm button light
.equ sp = 0x1
.equ tap = 0x7

//ramtables
.equ ram_table_h = 0x01
.equ ram_table_l = 0x0f
.equ disp_table_h = 0x01
.equ disp_table_l = 0x1f

//general
.equ b_delay = 15	;button delay, measured in 60Hz cycles
.equ b_long	= 60	;long button delay
.equ sec_brt = 1	;seconds display brightness: 1 for off up to 6 for max

// setup microcontroller
.include "setup.asm"

// main code starts here

tick:
	sbis pinc,tap			;check the rectifier voltage
	rjmp tick				;go back to tick_tock if voltage is low

// check for button press
.include "newstate.asm"

// increment time
count_t:
	inc ticks			;increment ticks counter
    ldi scr,50          ;50Hz mode
    sbrs clk_stat,f50Hz ;check 50Hz mode active
    ldi scr,60          ;60Hz mode
	cp ticks,scr		;compare ticks to 60
	brne check_state	;branch to show_time if ticks is not 60

//increment seconds
	clr ticks			;reset tick counter
	inc secs			;increment seconds counter
	cpi secs,60			;compare seconds to 60
	brne check_state	;branch to show_time if seconds is not 60

//increment minutes					
	clr secs			;reset seconds counter
	inc mins			;increment minutes counter
	cpi mins,60			;compare minutes to 60
	brne check_alarm	;branch if minutes is not 60
				
//increment hours
	clr mins			;reset minutes counter
	inc hrs				;increment hours counter
	cpi hrs,24			;compare hours to 24
	brne check_alarm	;branch if hours is not 24

//increment days				
	clr hrs				;reset hours counter

// check to see if the alarm should go off
check_alarm:
	mov scr,state			;check current state
	cpi scr,4				;is alarm currently sounding?
	brne not_now			;jump, alarm is not on now
	ldi scr,0
	mov state,scr			;alarm has been sounding for a minute, turn it off
	sbi portc,al_lite	    ;turn on the alarm light (it had been flashing)
not_now:
	cp hrs,alarm_hrs	
	brne show_time
	cp mins,alarm_mins
	brne check_state
	tst state				;state 0 is 'running/alarm on'
	brne check_state		;branch if alarm is not set
	ldi scr,4
	mov state,scr			;enter alarm-on state

// display time
check_state:

// check state register to see if time or alarm setting is to be displayed
    mov scr,state
    cpi scr, 0  
    breq show_time
    cpi scr,1
    breq show_time
    cpi scr,2
    breq show_time
    cpi scr,3
    breq show_alarm
    cpi scr,4
    breq show_time
    cpi scr,5
    breq show_time
    cpi scr,6
    breq show_time
    rjmp show_alarm

show_alarm:    
    rcall disp_alarm
    rjmp tock
show_time:
	ldi scr,5			;five times around
	mov do_count,scr	;move to count register
time_warp:
	mov scr,do_count	;get do_count
	cpi scr,sec_brt		;check brightness constant 
	mov scr,secs		;put seconds in scratch register
	brlo display_sec	
	clr scr				;clear scr
display_sec:
	com scr				;invert
	andi scr,0b00111111	;set bits for colon 
	out portd,scr		;show seconds
	cbi portb,dig0		;enable seconds display
	rcall take4000		;wait and sound buzzer	
	sbi portb,dig0		;turn off seconds display
	mov scr,hrs			;get hours to scr

	rcall get_segs_h	;convert to segments
	out portd,segs_h	;show first digit
	cbi portb,dig1		;turn on first digit
	rcall take4000		;wait and sound buzzer
	sbi portb,dig1		;turn off first digit

	out portd,segs_l
	cbi portb,dig2
	rcall take4000		;wait and sound buzzer
	sbi portb,dig2
	
	mov scr,mins		;get minutes to scr
	rcall get_segs_m	;convert to segments
	out portd,segs_h	;show first digit
	cbi portb,dig3		;turn on third digit
	rcall take4000		;wait and sound buzzer
	sbi portb,dig3		;turn off third digit

	out portd,segs_l
	cbi portb,dig4
	rcall take4000		;wait and sound buzzer
	sbi portb,dig4
	dec do_count		;decrement loop counter
	brne time_warp		;do it again?
tock:
	sbic pinc,tap
	rjmp tock			;done, wait for the next low phase
	rjmp tick

.include "subroutines.asm"








