/* states:
			0: running, disp time, alarm mode on
			1: running, disp time, alarm mode off
			2: running, disp time, alarm off, inhibit
			3: running, disp time, alarm on, inhibit
			4: running, disp time, alarm sounding
			5: running, disp time, set delay
			6: running, disp time, alarm set delay
			7: running, alarm set hours
			8: running, alarm set hours delay
			9: running, alarm set mins
			10: running, alarm set mins delay
			11: running, alarm set inhibit
			12: running, alarm set inhibit after hours
			13: stopped, show 24 inhibit
			14: stopped, show 12
			15: stopped, set hours inhibit
			16: stopped, set hours
			17: stopped, set hours delay
			18: stopped, set mins inhibit
			19: stopped, set mins
			20: stopped, set mins delay
			21: stopped, show 24
			22: stopped, show 24 inhibit
			23: stopped, show 60 Hz
			24: stopped, show 50 Hz inhibit
			25: stopped, show 60 Hz inhibit
			26: stopped, show 50 Hz
*/

// load Z regsiter
	ldi zh,high(state_table)	;get state table address
	ldi zl,low(state_table)

// get present state 
	mov scr,state	
	lsl scr						;state must be <64 to avoid overflow 
	lsl scr
	lsl scr
	add zl,scr
	brcc no_carry0				;carry?
	inc zh
no_carry0:

//read switches	
	in scr,pinb					;get switch states
	andi scr,0b00111000			;mask out other bits
	lsr scr						;shift to lsbs
	lsr scr
	lsr scr
	add zl,scr					;add switch bits to table offset
	brcc no_carry1				;check for carry
	inc zh
no_carry1:
	ijmp						;indirect table jump

state_table:
							;state 0
	rjmp go_home				;all pressed
	rjmp go_home				;set & inc pressed		
	rjmp go_home				;set & alr pressed
	rjmp go_6					;set pressed
	rjmp go_home				;inc & alr pressed
	rjmp go_home				;inc pressed
	rjmp go_2					;alr pressed
	rjmp go_home				;none pressed

							;state 1
	rjmp go_home				;all pressed
	rjmp go_home				;set & inc pressed		
	rjmp go_home				;set & alr pressed
	rjmp go_5					;set pressed
	rjmp go_home				;inc & alr pressed
	rjmp go_home				;inc pressed
	rjmp go_3					;alr pressed
	rjmp go_home				;none pressed

							;state 2
	rjmp go_home				;all pressed
	rjmp go_home				;set & inc pressed		
	rjmp go_home				;set & alr pressed
	rjmp go_home				;set pressed
	rjmp go_home				;inc & alr pressed
	rjmp go_home				;inc pressed
	rjmp go_home				;alr pressed
	rjmp go_1					;none pressed
	
							;state 3
	rjmp go_home				;all pressed
	rjmp go_home				;set & inc pressed		
	rjmp go_home				;set & alr pressed
	rjmp go_home				;set pressed
	rjmp go_home				;inc & alr pressed
	rjmp go_home				;inc pressed
	rjmp go_home				;alr pressed
	rjmp go_0					;none pressed

							;state 4
	rjmp go_3					;all pressed
	rjmp go_3					;set & inc pressed		
	rjmp go_3					;set & alr pressed
	rjmp go_3					;set pressed
	rjmp go_3					;inc & alr pressed
	rjmp go_3					;inc pressed
	rjmp go_3					;alr pressed
	rjmp go_home				;none pressed

							;state 5
	rjmp go_1					;all pressed
	rjmp go_1					;set & inc pressed		
	rjmp go_1					;set & alr pressed
	rjmp process_5				;set pressed
	rjmp go_1					;inc & alr pressed
	rjmp go_1					;inc pressed
	rjmp go_1					;alr pressed
	rjmp go_1					;none pressed

							;state 6
	rjmp go_0					;all pressed
	rjmp go_0					;set & inc pressed		
	rjmp go_0					;set & alr pressed
	rjmp process_6				;set pressed
	rjmp go_0					;inc & alr pressed
	rjmp go_0					;inc pressed
	rjmp go_0					;alr pressed
	rjmp go_0					;none pressed

							;state 7
	rjmp go_home				;all pressed
	rjmp go_home				;set & inc pressed		
	rjmp go_home				;set & alr pressed
	rjmp go_12					;set pressed
	rjmp go_home				;inc & alr pressed
	rjmp go_8					;inc pressed
	rjmp go_home				;alr pressed
	rjmp go_home				;none pressed

							;state 8
	rjmp go_home				;all pressed
	rjmp go_home				;set & inc pressed		
	rjmp go_home				;set & alr pressed
	rjmp go_home				;set pressed
	rjmp go_home				;inc & alr pressed
	rjmp process_8				;inc pressed
	rjmp go_home				;alr pressed
	rjmp go_7					;none pressed

							;state 9
	rjmp go_home				;all pressed
	rjmp go_home				;set & inc pressed		
	rjmp go_home				;set & alr pressed
	rjmp go_0					;set pressed
	rjmp go_home				;inc & alr pressed
	rjmp go_10					;inc pressed
	rjmp go_home				;alr pressed
	rjmp go_home				;none pressed

							;state 10
	rjmp go_home				;all pressed
	rjmp go_home				;set & inc pressed		
	rjmp go_home				;set & alr pressed
	rjmp go_home				;set pressed
	rjmp go_home				;inc & alr pressed
	rjmp process_10				;inc pressed
	rjmp go_home				;alr pressed
	rjmp go_9					;none pressed

							;state 11
	rjmp go_home				;all pressed
	rjmp go_home				;set & inc pressed		
	rjmp go_home				;set & alr pressed
	rjmp go_home				;set pressed
	rjmp go_home				;inc & alr pressed
	rjmp go_home				;inc pressed
	rjmp go_home				;alr pressed
	rjmp go_7					;none pressed

							;state 12
	rjmp go_home				;all pressed
	rjmp go_home				;set & inc pressed		
	rjmp go_home				;set & alr pressed
	rjmp go_home				;set pressed
	rjmp go_home				;inc & alr pressed
	rjmp go_home				;inc pressed
	rjmp go_home				;alr pressed
	rjmp go_9					;none pressed

							;state 13
	rjmp stable_disp			;all pressed
	rjmp stable_disp			;set & inc pressed		
	rjmp stable_disp			;set & alr pressed
	rjmp stable_disp			;set pressed
	rjmp stable_disp			;inc & alr pressed
	rjmp stable_disp			;inc pressed
	rjmp stable_disp			;alr pressed
	rjmp go_21					;none pressed

							;state 14
	rjmp stable_disp			;all pressed
	rjmp stable_disp			;set & inc pressed		
	rjmp stable_disp			;set & alr pressed
	rjmp go_15					;set pressed
	rjmp stable_disp			;inc & alr pressed
	rjmp go_13					;inc pressed
	rjmp stable_disp			;alr pressed
	rjmp stable_disp			;none pressed

							;state 15
	rjmp process_15				;all pressed
	rjmp process_15				;set & inc pressed		
	rjmp process_15				;set & alr pressed
	rjmp process_15				;set pressed
	rjmp process_15				;inc & alr pressed
	rjmp process_15				;inc pressed
	rjmp process_15				;alr pressed
	rjmp go_16					;none pressed

							;state 16
	rjmp process_16				;all pressed
	rjmp process_16				;set & inc pressed		
	rjmp process_16				;set & alr pressed
	rjmp go_18					;set pressed
	rjmp process_16				;inc & alr pressed
	rjmp go_17					;inc pressed
	rjmp process_16				;alr pressed
	rjmp process_16				;none pressed

							;state 17
	rjmp process_17				;all pressed
	rjmp process_17				;set & inc pressed		
	rjmp process_17				;set & alr pressed
	rjmp process_17				;set pressed
	rjmp process_17				;inc & alr pressed
	rjmp process_17_inc			;inc pressed
	rjmp process_17				;alr pressed
	rjmp go_16					;none pressed

							;state 18
	rjmp process_18				;all pressed
	rjmp process_18				;set & inc pressed		
	rjmp process_18				;set & alr pressed
	rjmp process_18				;set pressed
	rjmp process_18				;inc & alr pressed
	rjmp process_18				;inc pressed
	rjmp process_18				;alr pressed
	rjmp go_19					;none pressed

							;state 19
	rjmp process_19				;all pressed
	rjmp process_19				;set & inc pressed		
	rjmp process_19				;set & alr pressed
	rjmp go_1_reset				;set pressed
	rjmp process_19				;inc & alr pressed
	rjmp go_20					;inc pressed
	rjmp process_19				;alr pressed
	rjmp process_19				;none pressed

							;state 20
	rjmp process_20				;all pressed
	rjmp process_20				;set & inc pressed		
	rjmp process_20				;set & alr pressed
	rjmp process_20				;set pressed
	rjmp process_20				;inc & alr pressed
	rjmp process_20_inc			;inc pressed
	rjmp process_20				;alr pressed
	rjmp go_19					;none pressed

							;state 21
	rjmp stable_disp			;all pressed
	rjmp stable_disp			;set & inc pressed		
	rjmp stable_disp			;set & alr pressed
	rjmp go_15					;set pressed
	rjmp stable_disp			;inc & alr pressed
	rjmp go_22					;inc pressed
	rjmp stable_disp			;alr pressed
	rjmp stable_disp			;none pressed

							;state 22
	rjmp stable_disp			;all pressed
	rjmp stable_disp			;set & inc pressed		
	rjmp stable_disp			;set & alr pressed
	rjmp stable_disp			;set pressed
	rjmp stable_disp			;inc & alr pressed
	rjmp stable_disp			;inc pressed
	rjmp stable_disp			;alr pressed
	rjmp go_14					;none pressed

							;state 23
	rjmp stable_disp			;all pressed
	rjmp stable_disp			;set & inc pressed		
	rjmp stable_disp			;set & alr pressed
	rjmp go_13					;set pressed
	rjmp stable_disp			;inc & alr pressed
	rjmp go_24					;inc pressed
	rjmp stable_disp			;alr pressed
	rjmp stable_disp			;none pressed

							;state 24
	rjmp stable_disp			;all pressed
	rjmp stable_disp			;set & inc pressed		
	rjmp stable_disp			;set & alr pressed
	rjmp stable_disp			;set pressed
	rjmp stable_disp			;inc & alr pressed
	rjmp stable_disp			;inc pressed
	rjmp stable_disp			;alr pressed
	rjmp go_26					;none pressed

							;state 25
	rjmp stable_disp			;all pressed
	rjmp stable_disp			;set & inc pressed		
	rjmp stable_disp			;set & alr pressed
	rjmp stable_disp			;set pressed
	rjmp stable_disp			;inc & alr pressed
	rjmp stable_disp			;inc pressed
	rjmp stable_disp			;alr pressed
	rjmp go_23					;none pressed

							;state 26
	rjmp stable_disp			;all pressed
	rjmp stable_disp			;set & inc pressed		
	rjmp stable_disp			;set & alr pressed
	rjmp go_13					;set pressed
	rjmp stable_disp			;inc & alr pressed
	rjmp go_25					;inc pressed
	rjmp stable_disp			;alr pressed
	rjmp stable_disp			;none pressed



go_0:
	clr scr
	rjmp sc

go_1_reset:
	clr secs
	clr ticks
go_1:
	ldi scr,1
	rjmp sc

go_2:
	cbi portc,al_lite		;turn off the alarm light
	ldi scr,2
	rjmp sc

go_3:
	sbi portc,al_lite		;turn on the alarm light
	ldi scr,3
	rjmp sc

go_5:
	clr b_cnt				;reset button counter
	ldi scr,5
	rjmp sc

go_6:
	clr b_cnt				;reset button counter
	ldi scr,6
	rjmp sc

go_7:
	ldi scr,7
	rjmp sc

go_8:
	clr b_cnt				;reset button counter
    inc alarm_hrs		
    mov scr,alarm_hrs
    cpi scr,24				;check for wrap around
    brne no_wrap
	clr alarm_hrs			;wrap around
no_wrap:
    ldi scr,8
	rjmp sc

go_9:
	ldi scr,9
	rjmp sc

go_10:
	clr b_cnt				;reset button counter
    inc alarm_mins
    mov scr,alarm_mins
    cpi scr,60				;check for wrap around
    brne no_wrap_m
    clr alarm_mins 			;wrap around
no_wrap_m:
	ldi scr,10
	rjmp sc

go_11:
	ldi scr,11
	rjmp sc

go_12:
    ldi scr,12
    rjmp sc

go_13: 
	ldi zh,disp_table_h
	ldi zl,disp_table_l	
	ldi scr,0b10000101		;2
	st z,scr
	ldi scr,0b01100011		;4
	st -z,scr
	ldi scr,0b00110011		;h
	st -z,scr
	ldi scr,0b10110110		;r
	st -z,scr
	cbr clk_stat,0x01   	;clear 12 hour mode
	ldi scr,13
	rjmp sc_notime

go_14:
	ldi scr,14
	rjmp sc_notime

go_15:
	rcall s_disp_hr			;display hours
	ldi scr,15
	rjmp sc_stopped

go_16:
	rcall s_disp_hr			;display hours
	ldi scr,16
	rjmp sc_stopped

go_17:
	clr b_cnt				;reset button count
	inc hrs					;increment hours
	mov scr,hrs
	cpi scr,24				;check for wrap
	brne no_wrap_sh
	clr hrs
no_wrap_sh:
	rcall s_disp_hr			;display hoursv
	ldi scr,17
	rjmp sc_stopped

go_18:
	rcall s_disp_min		;display minutes
	ldi scr,18
	rjmp sc_stopped

go_19:
	rcall s_disp_min		;display minutes
	ldi scr,19
	rjmp sc_stopped

go_20:
	clr b_cnt				;reset button count
	inc mins				;increment minutes
	mov scr,mins
	cpi scr,60				;check for wrap
	brne no_wrap_sm
	clr mins
no_wrap_sm:
	rcall s_disp_min
	ldi scr,20
	rjmp sc_stopped

go_21:
	ldi scr,21
	rjmp sc_notime

go_22: 
	ldi zh,disp_table_h
	ldi zl,disp_table_l	
	ldi scr,0b11101011		;1
	st z,scr
	ldi scr,0b10000101		;2
	st -z,scr
	ldi scr,0b00110011		;h
	st -z,scr
	ldi scr,0b10110110		;r
	st -z,scr
	sbr clk_stat,0x01	    ;set 12 hour mode
	ldi scr,22
	rjmp sc_notime

go_23:
	ldi scr,23
	rjmp sc_notime

go_24:
	ldi zh,disp_table_h
	ldi zl,disp_table_l	
	ldi scr,0b01010001		;5
	st z,scr
	ldi scr,0b00001001		;0
	st -z,scr
	ldi scr,0b11111111		;
	st -z,scr
	ldi scr,0b00100011		;H
	st -z,scr
	sbr clk_stat,0x02	    ;set 50Hz mode
	ldi scr,24
	rjmp sc_notime

go_25:
	ldi zh,disp_table_h
	ldi zl,disp_table_l	
	ldi scr,0b00010001		;6
	st z,scr
	ldi scr,0b00001001		;0
	st -z,scr
	ldi scr,0b11111111		;
	st -z,scr
	ldi scr,0b00100011		;H
	st -z,scr
	cbr clk_stat,0x02   	;clear 50 Hz mode
	ldi scr,25
	rjmp sc_notime

go_26:
	ldi scr,26
	rjmp sc_notime

process_5:
	inc b_cnt				;increment button count
	mov scr,b_cnt
	cpi scr,b_long			;done yet?
	brne go_home
	rjmp go_13

process_6:
	inc b_cnt				;increment button count
	mov scr,b_cnt
	cpi scr,b_long			;done yet?
	brne go_home
	rjmp go_11

process_8:		
	inc b_cnt				;increment button count
	mov scr,b_cnt 		
	cpi scr,b_delay			;done yet?
	brne go_home		
	rjmp go_7

process_10:	
	inc b_cnt				;increment button count	
	mov scr,b_cnt 		
	cpi scr,b_delay			;done yet?
	brne go_home			
	rjmp go_9

process_15:
process_16:
process_17:
	rcall s_disp_hr			;display hours
	rjmp tock

process_17_inc:
    inc b_cnt               ;increment button count
    mov scr,b_cnt
    cpi scr,b_delay 
	brne process_17      	
    rjmp go_16				;button has been down awhile, return to state 16

process_18:
process_19:
process_20:
	rcall s_disp_min		;display minutes
	rjmp tock

process_20_inc:
    inc b_cnt               ;increment button count
    mov scr,b_cnt
    cpi scr,b_delay
	brne process_20
	rjmp go_19				;button has been down awhile, return to state 19

sc_notime:
	mov state,scr

stable_disp:
	rcall sync_disp_chars	;display characters for 12 ms
	rjmp tock				;finished

sc_stopped:
	mov state,scr
	rjmp tock

sc: 
	mov state,scr			;save new state
go_home:
	

