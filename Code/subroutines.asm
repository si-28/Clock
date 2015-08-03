// take 4000 kills about 4000 clock cycles while sounding the buzzer if required
//			writes: scr		uses: timer0
take4000:
	mov scr,state			;get state
	cpi scr,4				;alarm sounding?
	brne nope				
	sbi portc,sp			;toggle speaker
    cbi portc,al_lite	    ;alarm light off
	bst ticks,2				;get bit that changes every 8th of a sec
    brtc nope
    sbi portc,al_lite       ;alarm light on
nope:
	clr scr					;clear scratch reg
	out tcnt0,scr			;clear timer0
wait0:
	in scr,tcnt0			;get timer0
	cpi scr,31				;done yet?
	brlo wait0
	cbi portc,sp			;toggle speaker
	clr scr					;clear scratch reg
	out tcnt0,scr			;clear timer0
wait1:
	in scr,tcnt0			;get timer0
	cpi scr,31				;done yet?
	brlo wait1
	ret

// kill 2000 kills about 2000 clock cycles
//			writes: scr		uses: timer0
kill2000:
	clr scr					;clear scratch reg
	out tcnt0,scr			;clear timer0
delay:
	in scr,tcnt0			;get timer0
	cpi scr,31				;done yet?
	brlo delay
	ret

//long delay waits for about half a million clocks
//			writes: temp			calls: kill2000
long_delay:	
	clr temp
ld_loop:
	rcall kill2000		;delay
	inc temp
	brne ld_loop
	ret

/*disp_chars takes segment data from the data space and displays them 
  on the LEDs. disp_chars takes about 128 ms. 
  q_disp_chars is a shorter verstion that takes about 4 ms
  sync_disp_chars takes about 12 ms 

 			writes: scr, temp, zl, zh		calls: kill2000  */
q_disp_chars:
	ldi scr,0x01
	mov temp,scr
	rjmp disp_loop
sync_disp_chars:
	ldi scr,0x03
	mov temp,scr
	rjmp disp_loop	
disp_chars:			
	ldi scr,0x20
	mov temp,scr
disp_loop:
	ldi zh,disp_table_h		;set up z register
	ldi zl,disp_table_l
	ld scr,z				;get first character
	out portd,scr			
	cbi portb,dig1			;turn on digit
	rcall kill2000			;wait a while 
	rcall kill2000
	rcall kill2000		
	rcall kill2000
	sbi portb,dig1
	ld scr,-z	
	out portd,scr			
	cbi portb,dig2			;turn on digit
	rcall kill2000			;wait a while 
	rcall kill2000
	rcall kill2000		
	rcall kill2000
	sbi portb,dig2
	ld scr,-z	
	out portd,scr			
	cbi portb,dig3			;turn on digit
	rcall kill2000			;wait a while 
	rcall kill2000
	rcall kill2000		
	rcall kill2000	
	sbi portb,dig3
	ld scr,-z	
	out portd,scr			
	cbi portb,dig4			;turn on digit
	rcall kill2000			;wait a while 
	rcall kill2000
	rcall kill2000		
	rcall kill2000	
	sbi portb,dig4	
	dec temp
	brne disp_loop		
	ret

/*flash_chars takes segment data from the data space and displays them 
  on the LEDs. Takes about 1ms.

 			writes: scr, zl, zh		  */
flash_chars:
	ldi scr,disp_table_h	;set up z register
	mov zh,scr
	ldi scr, disp_table_l
	mov zl,scr
	ld scr,z				;get first character
	out portd,scr			
	cbi portb,dig1			;turn on digit
    ldi scr,50
flash_d1:
    dec scr
    brne flash_d1
	sbi portb,dig1
	ld scr,-z	
	out portd,scr			
	cbi portb,dig2			;turn on digit
    ldi scr,50
flash_d2:
    dec scr
    brne flash_d2
	sbi portb,dig2
	ld scr,-z	
	out portd,scr			
	cbi portb,dig3			;turn on digit
    ldi scr,50
flash_d3:
    dec scr
    brne flash_d3
	sbi portb,dig3
	ld scr,-z	
	out portd,scr			
	cbi portb,dig4			;turn on digit
    ldi scr,50
flash_d4:
    dec scr
    brne flash_d4
	sbi portb,dig4			
	ret


/*get_segs_h takes an argument in scr and returns the most significant LED
  segments (segs_h) and least significant LED segment (segs_l). The scr 
  register is 0 to 24 for hours. 
  
  		writes: clr, temp, tens,zl, zh, segs_l, segs_h	*/
get_segs_h:
    sbrs clk_stat,civ_mode	;check time display mode (12 or 24 hours)
	rjmp disp_hrs
	cpi scr,13			;compare to 13 hours
	brlo check_zero		;no need to subtract
	subi scr,12			;subtract 12 hours
check_zero:    
    tst scr             ;is it 12:xx am?
    brne disp_hrs       ;no need to add
    mov temp,scr        ;add 12 to get civilian time
    ldi scr,12          
    add scr,temp
disp_hrs:
	clr tens			;clear tens register
div:
	cpi scr,10			;bigger than ten?		
	brlo done_div		;	no, done
	inc tens			;increment tens count
	subi scr,10			;subtract 10 from scr 
	rjmp div
done_div:
	sbrs clk_stat,civ_mode	;in 12 hour mode?
	rjmp ready_disp
	tst tens			;leading digit zero?
	brne ready_disp
	mov temp,scr		;save scr register
	ldi scr,10			;10 corresponds to a blank digit
	mov tens,scr		;blank digit
	mov scr,temp		;restore scr
ready_disp:
	ldi zh,high(seg_table<<1)	;load z register for indirect read
	ldi zl,low(seg_table<<1)
	add zl,tens			;compute offset into the table
	brcc nc1			;carry required?
	inc zh				;carry
nc1:
	lpm segs_h,z		;read segments from data table
	ldi zh,high(seg_table<<1)	;load z register for indirect read
	ldi zl,low(seg_table<<1)
	add zl,scr			;compute offset into the table
	brcc nc2			;carry required?
	inc zh				;carry
nc2:
	lpm segs_l,z		;read segments from data table
	ret

/*get_segs_m takes an argument in scr and returns the most significant LED
  segments (segs_h) and least significant LED segment (segs_l). The scr 
  register is 0 to 59 for minutes 
  
  		writes: clr, tens,zl, zh, segs_l, segs_h	*/
get_segs_m:
	clr tens			;clear tens register
div_m:
	cpi scr,10			;bigger than ten?		
	brlo done_div_m		;	no, done
	inc tens			;increment tens count
	subi scr,10			;subtract 10 from scr 
	rjmp div_m
done_div_m:
	ldi zh,high(seg_table<<1)	;load z register for indirect read
	ldi zl,low(seg_table<<1)
	add zl,tens			;compute offset into the table
	brcc nc1_m			;carry required?
	inc zh				;carry
nc1_m:
	lpm segs_h,z		;read segments from data table
	ldi zh,high(seg_table<<1)	;load z register for indirect read
	ldi zl,low(seg_table<<1)
	add zl,scr			;compute offset into the table
	brcc nc2_m			;carry required?
	inc zh				;carry
nc2_m:
	lpm segs_l,z		;read segments from data table
	ret


/*s_disp_hr computes the display in the hour set mode. Takes about 12ms. 

			writes: scr, do_count 			calls: take4000, get_segs_h  */
s_disp_hr:
	ldi scr,6			;six times around
	mov do_count,scr	;move to count register
time_warp_sd:
	mov scr,hrs			;get hours to scr
	rcall get_segs_h	;convert to segments
	out portd,segs_h	;show first digit
	cbi portb,dig1		;turn on first digit
	rcall take4000		;wait and sound buzzer
	sbi portb,dig1		;turn off first digit

	out portd,segs_l
	cbi portb,dig2
	rcall take4000		;wait and sound buzzer
	sbi portb,dig2		;turn off second digit

	sbrc clk_stat,civ_mode	;check time display mode
	rjmp digit4
	ldi scr,0b11110111	;-
	out portd,scr
	cbi portb,dig3		;turn on third digit
	rcall take4000		;wait and sound buzzer
	sbi portb,dig3		;turn off third digit

digit4:	
	ldi scr,0b11110111	;-
	sbrs clk_stat,civ_mode	;check time display mode
	rjmp early_riser
	ldi scr,0b00000011	;A
	cpi hrs,12
	brlo early_riser
	ldi scr,0b00000111	;P
early_riser:
	out portd,scr
	cbi portb,dig4		;turn on fourth digit
	rcall take4000		;wait and sound buzzer
	sbi portb,dig4		;turn off fourth digit
    dec do_count		;decrement loop counter
	brne time_warp_sd	;do it again?
	ret

/*s_disp_min shows the display in the minute set mode. Takes about 12ms.

			writes: scr, 			calls: take4000, get_segs_h, get_segs_m  */
s_disp_min:
    ldi scr,6			;six times around
	mov do_count,scr	;move to count register
time_warp_sdm:
	mov scr,hrs			;get hours to scr
	rcall get_segs_h	;convert to segments
	out portd,segs_h	;show first digit
	cbi portb,dig1		;turn on first digit
	rcall take4000		;wait and sound buzzer
	sbi portb,dig1		;turn off first digit

	out portd,segs_l
	cbi portb,dig2
	rcall take4000		;wait and sound buzzer
	sbi portb,dig2		;turn off second digit

    mov scr,mins         ;get minutes
    rcall get_segs_m
    out portd,segs_h
    cbi portb,dig3
    rcall take4000
    sbi portb,dig3

    out portd,segs_l
    cbi portb,dig4
    rcall take4000
    sbi portb,dig4
    dec do_count		;decrement loop counter
	brne time_warp_sdm	;do it again?
	ret

// disp_alarm displays the alarm time during alarm setting states
//      writes: scr, do_count        calls:get_segs_h, get_segs_m, take4000
disp_alarm:
    ldi scr,6			;six times around
	mov do_count,scr	;move to count register
time_warp_a:
    mov scr,alarm_hrs   ;get alarm hours
	rcall get_segs_h	;convert to segments
	out portd,segs_h	;show first digit
	cbi portb,dig1		;turn on first digit
	rcall take4000		;wait and sound buzzer
	sbi portb,dig1		;turn off first digit

	out portd,segs_l
	cbi portb,dig2
	rcall take4000		;wait and sound buzzer
	sbi portb,dig2		;turn off second digit

    mov scr,state       ;get state
    cpi scr,7           ;have minutes to display?
    breq no_mins
    cpi scr,8
    breq no_mins
    cpi scr,11
    brne get_mins          
no_mins:
    ldi segs_h,0b11110111;display a dash
    ldi segs_l,0b11110111;display a dash
    sbrs clk_stat,civ_mode	;check time display mode
	rjmp display_it
    ldi segs_h,0b11111111; blank out digit
	ldi segs_l,0b00000011	;A
    mov scr,alarm_hrs
	cpi scr,12
	brlo display_it
	ldi segs_l,0b00000111	;P
    rjmp display_it
get_mins:
    mov scr,alarm_mins   ;get minutes
    rcall get_segs_m
display_it:
    out portd,segs_h
    cbi portb,dig3
    rcall take4000
    sbi portb,dig3

    out portd,segs_l
    cbi portb,dig4
    rcall take4000
    sbi portb,dig4
	dec do_count		;decrement loop counter
	brne time_warp_a	;do it again?
	ret

