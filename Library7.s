	AREA lib, CODE, READWRITE
	
	EXPORT uart_init
	EXPORT pin_connect_block_setup_for_uart0	
	
	EXPORT read_string
	EXPORT read_loop
	EXPORT read_character
	EXPORT read_char
	
	EXPORT output_string
	EXPORT output_loop
	EXPORT output_character
	EXPORT output_char
		
	EXPORT illuminate_LEDs
	;EXTERN main_menu
	
	
	EXPORT illuminate_RGB_LED
		
	EXPORT read_from_push_buttons	
	EXPORT display_digit_on_7_seg 
	EXPORT pin_connect_block_7_seg
	
	EXPORT interrupt_init
	EXPORT FIQ_Handler	

	EXTERN begin_strobe
	EXTERN user_string	
	EXPORT seven_seg_status	
		
	EXTERN formfeed
	EXTERN playerLocation
	EXTERN board
			
	

illuminateLED_menu = "\n\rEnter a single hexadecimal value to be displayed on the LED's\n\r(use capital letters for A-F)\n\rPress m to return to main menu when done\n\r",0
illuminateRGB_menu = "\n\rPlease select one of the following colors to be illuminated\n\r1 - red\n\r2 - green\n\r3 - blue\n\r4 - purple\n\r5 - yellow\n\r6 - white\n\r7 - turn off\n\rm - to return to menu\n\rq - to quit\n\r",0
illuminateRGB_menu_loop = "\n\rPlease enter another color, or enter m to return to main menu, or q to quit\n\r1 - red\n\r2 - green\n\r3 - blue\n\r4 - purple\n\r5 - yellow\n\r6 - white\n\r7 - turn off\n\r",0

push_button_menu = "\n\rPress push buttons you wish to see the hexadecimal value for\n\r",0
button0_str = "\n\rThe value entered is:0\n\r", 0
button1_str = "\n\rThe value entered is:1\n\r", 0
button2_str = "\n\rThe value entered is:2\n\r", 0
button3_str = "\n\rThe value entered is:3\n\r", 0
button4_str = "\n\rThe value entered is:4\n\r", 0
button5_str = "\n\rThe value entered is:5\n\r", 0
button6_str = "\n\rThe value entered is:6\n\r", 0
button7_str = "\n\rThe value entered is:7\n\r", 0
button8_str = "\n\rThe value entered is:8\n\r", 0
buttonA_str = "\n\rThe value entered is:10\n\r", 0
button9_str = "\n\rThe value entered is:9\n\r", 0
buttonB_str = "\n\rThe value entered is:11\n\r", 0
buttonC_str = "\n\rThe value entered is:12\n\r", 0
buttonD_str = "\n\rThe value entered is:13\n\r", 0
buttonE_str = "\n\rThe value entered is:14\n\r", 0
buttonF_str = "\n\rThe value entered is:15\n\r", 0
button_continue = "\n\rPress m to return to menu, q to quit\n\r",0


seven_seg_menu = "\n\rWhich display would you like to illuminate\n\r1 - The leftmost display\n\r2 - 2nd from the Left\n\r3 - 3rd from the left\n\r4 - Rightmost display\n\r",0
seven_seg_menu_number = "\n\rPlease enter the hexadecimal digit you want to display \n\rm to return to menu or q to quit\n\r",0
seven_seg_menu_loop = "\n\rEnter another hexadecimal number or enter m to return to the main menu, or q to quit the program\n\r",0

timer = "\n\rThe timer was reached"
seven_seg_status = "7",0 ;7 used to flag on

	ALIGN

uart_init
	STMFD sp!, {r0, r1, lr}
	LDR r0, =0xE000C00C ;
	MOV r1, #131
	STR r1, [r0]
	LDR r0, =0xE000C000 ;U0DLL = 10 for 115200 baud, 120 for 9600
	MOV r1, #10 ; 
	STR r1, [r0]
	LDR r0, =0xE000C004 ;U0DLM
	MOV r1, #0
	STR r1, [r0]
	LDR r0, =0xE000C00C
	MOV r1, #3
	STR r1, [r0]
	LDMFD sp!, {r0, r1, lr}	
	BX lr
	
pin_connect_block_setup_for_uart0
	STMFD sp!, {r0, r1, lr}
	LDR r0, =0xE002C000 ; PINSEL0
	LDR r1, [r0]
	ORR r1, r1, #5
	BIC r1, r1, #0xA
	STR r1, [r0]
	LDMFD sp!, {r0, r1, lr}
	BX lr

;----------------------------READ CHARACTER STUFF-----------------------------	

read_string
	STMFD sp!, {lr}
read_loop
	BL read_character
	BL output_character
	;STRB r1,[r4] ;store value in r1 to memory
	ADD r4, r4, #0x01 ; increment address by 1
	CMP r1, #0x0D ; check if enter was pressed
	BEQ read_done
	MOV r5, r1 ; move the character to r5
	
	STRB r5, [r7] ; r7 holds address of user_string
	ADD r7, r7, #1
	BNE read_loop
	
	
read_done
	MOV r1, #0xA ;move newline to be printed
	BL output_character	
	
	LDMFD sp!, {lr}
	BX lr
	

read_character
	STMFD sp!, {lr}
read_char	
	LDR r0, =0xE000C000 ; Load r0 with UART0 address (0xE000C000)
	LDRB r1, [r0, #0x14] ;Load a byte from r0 into r1
	AND r2, r1, #0x1  
	CMP r2, #0x1  	;Check if the first bit(RDR) of r1 is a 1
	BNE read_char ;loop back to read_character if no input was received
	LDRB r1, [r0]	;load character from UART(r0) into r1
	CMP r1, #0x71
	BEQ done
	LDMFD sp!, {lr}
	BX lr
	
;----------------------------END OF READ CHARACTER STUFF-----------------------------





;----------------------------OUTPUT CHARACTER STUFF-----------------------------


output_string
	STMFD sp!, {lr}
output_loop
	LDRB r1, [r4] ; load the byte from r4 into r1
	BL output_character
	CMP r1, #0 ; check if r1 is 0
	BEQ here
	ADD r4,r4,#1 ; increment address
	B output_loop
	
here
	LDMFD sp!, {lr}
	BX lr
	

output_character
	STMFD sp!, {lr}
output_char
	LDR r0, =0xE000C000 ; Load r0 with UART0 address
	LDRB r3, [r0, #0x14] ; load a byte from UART address into r1
	AND r2, r3, #0x20
	CMP r2, #0x20 ;Check if the 6th bit of UART address is set to 1
	BNE output_char
	STRB r1, [r0]	;Store input into memory
		
	LDMFD sp!, {lr}
	BX lr
	
;----------------------------END OUTPUT CHARACTER STUFF-----------------------------	
	
	
	
	
	
	
;---------------------Beginning of interrupt init--------------------------	
interrupt_init       
		STMFD SP!, {r0-r1, lr}   ; Save registers 
		
;--------------------- PUSH BUTTON setup----------------------------------		 
		LDR r0, =0xE002C000 ; pin select0 address
		LDR r1, [r0]
		ORR r1, r1, #0x20000000
		BIC r1, r1, #0x10000000
		STR r1, [r0]  ; PINSEL0 bits 29:28 = 10

		; Classify sources as IRQ or FIQ
		LDR r0, =0xFFFFF000  
		LDR r1, [r0, #0xC]
		ORR r1, r1, #0x8000 ; External Interrupt 1
		STR r1, [r0, #0xC]
		

		; Enable Interrupts
		LDR r0, =0xFFFFF000
		LDR r1, [r0, #0x10] ;offset to interrupt enable register
		;LDR r2, =0x8000 ;select pins 6(UART0) & pin 15(EXT INT 1)
		ORR r1, r1, #0x8000; External Interrupt 1 & UART0
		STR r1, [r0, #0x10] ; store result to interrupt enable register

		; External Interrupt 1 setup for edge sensitive
		LDR r0, =0xE01FC148
		LDR r1, [r0]
		ORR r1, r1, #2  ; EINT1 = Edge Sensitive
		STR r1, [r0]
;------------------------END OF PUSH BUTTON SETUP----------------------------------		


;------------------------UARTO INTERRUPT SETUP---------------------------------------
		;classify UART0 as FIQ 
		LDR r0, =0xFFFFF000  
		LDR r1, [r0, #0xC] ;offset to Interrupt Select Register
		ORR r1, r1, #0x40 ;pin 6 for UART0
		STR r1, [r0,#0xC] ;store result to interrupt select register
		
		;enable UART0 as interrupt source
		LDR r0, =0xFFFFF000 ;interrupt enable register
		LDR r1, [r0,#0x10]
		ORR r1,r1, #0x40 ;pin 6 for UART0
		STR r1, [r0,#0x10]
		
		
		;set up UART to interrupt processor when data is received
		LDR r0, =0xE000C004 ;UART0 interrupt enable register
		LDR r1, [r0]
		ORR r1, r1, #1 ; set bit 0 to a 1 to enable RDA
		STR r1, [r0] ;store result to UART0 interrupt enable register
		
;-------------------------END UART0 INTERRUPT SETUP---------------------------------




;--------------------------BEGIN TIMER INTERRUPT SETUP--------------------------------
				
		;Classify in interrupt select register
		LDR r0, =0xFFFFF000
		LDR r1, [r0, #0xC] ;offset to interrupt enable register
		ORR r1, r1, #0x10 ; set bits 4,5
		STR r1, [r0, #0xC] ;timer0 & timer1 set in interrupt select register
		
		;set up timers as FIQ's
		LDR r0, =0xFFFFF000
		LDR r1, [r0, #0x10] ;offset to interrupt enable register
		ORR r1, r1, #0x10 ;set bit 4,5 for timer0 & timer1
		STR r1, [r0, #0x10]
		
		;set up Match control register
		LDR r0, =0xE0004014 ;T0MCR
		LDR r1, [r0]
		ORR r1, r1, #0x18 ; set bit 3 to allow match register to interrupt, set bit 4 to reset TC to 0
		;BIC r1, r1, #0x20
		STR r1, [r0]
		
		
		
		; Enable FIQ's, Disable IRQ's
		MRS r0, CPSR
		BIC r0, r0, #0x40
		ORR r0, r0, #0x80
		MSR CPSR_c, r0
		

;------------------------------END TIMER SETUP------------------------------------------


		LDMFD SP!, {r0-r1, lr} ; Restore registers
		BX lr             	   ; Return



;---------------------END of interrupt init---------------------------------------





;-------------------------------BEGIN FIQ_HANDLER--------------------------------------

FIQ_Handler
		
		STMFD SP!, {r0-r12, lr}   ; Save registers 
		
;-----------------CHECK INTERRUPT SOURCE-----------------------------------------		
T0IR	
		;timer0 interrupt register
		LDR r0, =0xE0004000
		LDRB r1, [r0]
		AND r1, #2
		CMP r1, #2
		BEQ timer_handling
EINT1			; Check for EINT1 interrupt
		LDR r0, =0xE01FC140 ;external interrupt flag register
		LDR r1, [r0]
		TST r1, #2 ;check bit 1(EINT1), if its a 1, there is an interrupt pending
		BNE push_button_handling
		
		LDR r0, =0xE000C008 ;UART0 Interrupt Identification Register
		LDR r1, [r0]
		AND r1, #0
		;CMP r1, #1 ; check for zero to see if pending
		BEQ UART0_handling
		
		
		
		
		
;--------------------------DONE CHECKING INTERRUPT SOURCES-----------------------------		
		
		TST r1, #1 ; check if nothing is pending
		BEQ FIQ_Exit
		
		
		


;-----------------------PUSH BUTTON HANDLING----------------------------------------
		; Push button EINT1 Handling Code
push_button_handling
	
toggle_button ;toggles display
		LDR r12, =seven_seg_status
		LDRB r11, [r12]
		CMP r11, #0x34 ; check if display is on
		BEQ turn_on
		
		LDR r0, =0xE0028008 ;IO0DIR
		LDR r1, [r0]
		LDR r2, =0x0000B784
		EOR r1, r1, r2
		STR r1,[r0]
		
		MOV r11,#0x34 ; 0x34 used as flag for off
		STRB r11, [r12]
		B button_clear
		
turn_on
		LDR r0, =0xE0028008 ;IO0DIR
		LDR r1, [r0]
		LDR r2, =0x0000B784
		EOR r1, r1, r2
		STR r1,[r0]
		LDR r12, =seven_seg_status
		MOV r11, #0x37
		STRB r11, [r12] ;put 0x37 into seven_seg_status address 
						;so we know it's back on
	
		
		
button_clear		
		;clears interrupt
		LDR r0, =0xE01FC140
		LDR r1, [r0]
		
		ORR r1,r1,#2 ;write a 1 to pin1(EINT1)
		STR r1,[r0]
		

		
		B FIQ_Exit


;------------------------------PUSH BUTTON DONE-------------------------------
	



;---------------------------------TIMER HANDLING--------------------------------
timer_handling		
		;LDR r4, =timer
		;BL output_string
				
		
		;clears the timer interrupt
		LDR r0, =0xE0004000 ;timer 0 interrupt register
		LDR r1, [r0]
		ORR r1, r1, #0x2
		STR r1, [r0]
		B FIQ_Exit
		
;-------------------------------TIMER DONE--------------------------------------------------




;---------------------------------UART HANDLING ------------------------------------------
UART0_handling	
		STMFD SP!, {r0-r12, lr}   ; Save registers 
		
		BL read_character
		CMP r1, #0x61 ;ascii value for a
		BEQ move_left
		CMP r1, #0x64 ; ascii value for d
		BEQ move_right
		CMP r1, #0x20 ; ascii value for space
		BEQ shoot_bullet
		
		CMP r1, #0x71 ; check for q
		BEQ done
		
		
		
		B UART_done
		
		
		
		
move_left
		;first check if moving left is allowed
		LDR r4, =board
		LDR r5, =playerLocation
		LDR r6,[r5]
		SUB r6,r6,#1 ;get the value of the character to the right of the current position
		LDRB r1, [r4,r6] ;load the character of board offset by player location -1
		CMP r1, #0x7C ;check if next character is |, which is an invalid location
		BEQ UART_done
		
		LDR r4, =formfeed ; clears screen
		BL output_string
		
		LDR r4, =board
		LDR r5, =playerLocation
		LDR r6, [r5] ;put playerLocation offset into a register
		MOV r1, #0x20 ;mov the space character into a register
		STRB r1, [r4, r6] ;puts a space in board + playerLocation address
		SUB r6, r6, #1 ;subtract 1 to move offset left 1 position
		MOV r1, #0x41 ; put A charcter value into a register
		STRB r1, [r4,r6] ; place an A character at board + new player location
		STR r6, [r5] ;save the offset to playerLocation
		
 		BL output_string ;reprint the board
		B UART_done
		
move_right
		;first check if moving right is allowed
		LDR r4, =board
		LDR r5, =playerLocation
		LDR r6,[r5]
		ADD r6,r6,#1 ;get the value of the character to the right of the current position
		LDRB r1, [r4,r6] ;load the character of board offset by player location -1
		CMP r1, #0x7C ;check if next character is |, which is an invalid location
		BEQ UART_done
		
		
		LDR r4, =formfeed ; clears screen
		BL output_string
		
		LDR r4, =board
		LDR r5, =playerLocation
		LDR r6, [r5] ;put playerLocation offset into a register
		MOV r1, #0x20 ;mov the space character into a register
		STRB r1, [r4, r6] ;puts a space in board + playerLocation address
		ADD r6, r6, #1 ;subtract 1 to move offset left 1 position
		MOV r1, #0x41 ; put A charcter value into a register
		STRB r1, [r4,r6] ; place an A character at board + new player location
		STR r6, [r5] ;save the offset to playerLocation
		
		BL output_string ;reprint the board
		B UART_done		
		
shoot_bullet

		LDR r4,=board
		LDR r5, =playerLocation
		LDR r6, [r5] ; load the player location into register
		
		MOV r1, #0x5E ; put character ^ into r1
		SUB r6, r6, #25 ;offset bullet 25 spaces to the left(should be above player)
		STRB r1, [r4,r6]
		
		BL output_string
		B UART_done
		
				
UART_done		
		;clear interrupt
		LDR r0,=0xE000C008
		LDR r1, [r0]
		ORR r1, r1, #1 ;value for no pending interrupt
		STR r1, [r0]
		
		
		LDMFD SP!, {r0-r12, lr}   ; Restore registers
		
;--------------------------------------UART DONE -------------------------------------------		
		
		
		;ORR r1, r1, #2		; Clear Interrupt
		;STR r1, [r0]
		
FIQ_Exit
		LDMFD SP!, {r0-r12, lr}
		SUBS pc, lr, #4	
	
	
;-----------------------------------FIQ_HANDLER DONE------------------------------------	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
;---------------------Begin of 7 seg section--------------------------		

display_digit_on_7_seg
	
	
pickNumber

	;reset pins

	LDR r1, =0xE002801C ; IO1CLR address
	LDR r2, =0xFFFFF80
	STR r2, [r1]
	
	
	;check for done and menu
	;CMP r5, #0x71
	;BEQ done
	;CMP r5, #0x6D
	;BEQ main_menu
	;check what number was entered
	CMP r5, #0x30
	BEQ seg0
	CMP r5, #0x31
	BEQ seg1
	CMP r5, #0x32
	BEQ seg2
	CMP r5, #0x33
	BEQ seg3
	CMP r5, #0x34
	BEQ seg4
	CMP r5, #0x35
	BEQ seg5
	CMP r5, #0x36
	BEQ seg6
	CMP r5, #0x37
	BEQ seg7
	CMP r5, #0x38
	BEQ seg8
	CMP r5, #0x39
	BEQ seg9
	CMP r5, #0x41 ;capital A
	BEQ segA
	CMP r5, #0x42
	BEQ segB
	CMP r5, #0x43
	BEQ segC
	CMP r5, #0x44
	BEQ segD
	CMP r5, #0x45
	BEQ segE
	CMP r5, #0x46
	BEQ segF
	
	;lowecase letters;
	CMP r5, #0x61 ;lowercase A
	BEQ segA
	CMP r5, #0x62
	BEQ segB
	CMP r5, #0x63
	BEQ segC
	CMP r5, #0x64
	BEQ segD
	CMP r5, #0x65
	BEQ segE
	CMP r5, #0x66
	BEQ segF
	
	CMP r5, #0x71 ; check for q
	BEQ done
	
	;BX lr
	
	;B main_menu
	
seg0
	LDR r0, =0xE0028000 ; address of IO0SET
	LDR r1, =0x00003780 ;set bits 7,8,9,10,12,13
	ORR r1, r1, r6 ; saves the bits that were set by selecting segment
	STR r1, [r0]
	BX lr

seg1
	LDR r0, =0xE0028000 ; address of IO0SET
	LDR r1, =0x00000300 ; set bits 8,9
	ORR r1, r1, r6 ; saves the bits that were set by selecting segment
	STR r1, [r0]
	BX lr
	
seg2
	LDR r0, =0xE0028000 ; address of IO0SET
	LDR r1, =0x00009580 ;set bits 7,8,10,12,15
	ORR r1, r1, r6 ; saves the bits that were set by selecting segment
	STR r1, [r0]
	BX lr
	
seg3
	LDR r0, =0xE0028000 ; address of IO0SET
	LDR r1, =0x00008780 ; set bits 7,8,9,10,15
	ORR r1, r1, r6
	STR r1, [r0]
	BX lr


seg4
	LDR r0, =0xE0028000 ; address of IO0SET
	LDR r1, =0x0000A300 ; set bits 8,9,13,15
	ORR r1, r1, r6	
	STR r1, [r0]
	BX lr
	
seg5
	LDR r0, =0xE0028000 ; address of IO0SET
	LDR r1, =0x0000A680 ;set bits 7, 9,10,13,15
	ORR r1, r1, r6
	STR r1, [r0]
	BX lr
	
seg6
	LDR r0, =0xE0028000 ; address of IO0SET
	LDR r1, =0x0000B680 ; set bits ,9,10,12,13,15
	ORR r1, r1, r6
	STR r1, [r0]
	BX lr
	
seg7
	LDR r0, =0xE0028000 ; address of IO0SET
	LDR r1, =0x00000380 ; set bits 7,8,9
	ORR r1, r1, r6	
	STR r1, [r0]
	BX lr
	
seg8	
	LDR r0, =0xE0028000 ; address of IO0SET
	LDR r1, =0x0000B780 ; set bits 7,8,9,10,12,13,15
	ORR r1, r1, r6
	STR r1, [r0]
	BX lr
	
seg9
	LDR r0, =0xE0028000 ; address of IO0SET
	LDR r1, =0x0000A780 ; set bits 7,8,9,10,13,15
	ORR r1, r1, r6
	STR r1, [r0]
	BX lr
	
segA
	LDR r0, =0xE0028000 ; address of IO0SET
	LDR r1, =0x0000B380 ; set bits - 7,8,9,12,13,15
	ORR r1, r1, r6
	STR r1, [r0]
	BX lr
	
segB
	LDR r0, =0xE0028000 ; address of IO0SET
	LDR r1, =0x0000B600 ;set bits 9,10,12,13,15
	ORR r1, r1, r6
	STR r1, [r0]	
	BX lr
	
segC
	LDR r0, =0xE0028000 ; address of IO0SET
	LDR r1, =0x00003480 ; set bits 7,10,12,13
	ORR r1, r1, r6
	STR r1, [r0]
	BX lr
	
segD
	LDR r0, =0xE0028000 ; address of IO0SET
	LDR r1, =0x00009700 ; set bits 8,9,10,12,15
	ORR r1, r1, r6
	STR r1, [r0]
	BX lr
	
segE
	LDR r0, =0xE0028000 ; address of IO0SET
	LDR r1, =0x0000B480 ; set bits 7,10,12,13,15
	ORR r1, r1, r6
	STR r1, [r0]	
	BX lr
	
segF
	LDR r0, =0xE0028000 ; address of IO0SET
	LDR r1, =0x0000B0B0 ; set bits 7,12,,13,15
	ORR r1, r1, r6
	STR r1, [r0]	
	BX lr
	
	;LDMFD sp!, {lr, r0-r3}
	
	

pin_connect_block_7_seg
	STMFD sp!, {r0, r1, lr}
	LDR r0, =0xE002C000 ; PINSEL0
	LDR r1, [r0]
	LDR r2, =0xFFFF003F
	AND r1, r1, r2 ; clears bits 7,8,9,10,12,13,15
	STR r1, [r0]
	LDMFD sp!, {r0, r1, lr}
	BX lr	
 ; Your code goes here
	LDMFD SP!, {lr} ; Restore register lr from stack
	BX LR	
;---------------------End of 7 seg section--------------------------	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
illuminate_LEDs
	LDMFD sp!, {lr, r0-r3}
	
	LDR r1, =0xE0028018 ; IO1DIR address
	LDR r2, =0xFFFFFFFF ; load all 1's into r2
	STR r2, [r1] ; set all the pins to high for IO0DIR
	
LED_loop
	
	LDR r1, =0xE0028018 ; IO1DIR address
	LDR r2, =0xFFFFFFFF ; load all 1's into r2
	STR r2, [r1] ; set all the pins to high for IO0DIR

	LDR r4, =illuminateLED_menu
	BL output_string
	BL read_string
	
	;reset the pins
	LDR r1, =0xE002801C ; IO1CLR address
	LDR r2, =0xFFFFFFFF
	STR r2, [r1]
	
	;check what number was entered
	CMP r5, #0x6D ; check if m was entered (menu)
	;BEQ main_menu
	CMP r5, #0x71
	BEQ done
	CMP r5, #0x30
	BEQ LED0
	CMP r5, #0x31
	BEQ LED1
	CMP r5, #0x32
	BEQ LED2
	CMP r5, #0x33
	BEQ LED3
	CMP r5, #0x34
	BEQ LED4
	CMP r5, #0x35
	BEQ LED5
	CMP r5, #0x36
	BEQ LED6
	CMP r5, #0x37
	BEQ LED7
	CMP r5, #0x38
	BEQ LED8
	CMP r5, #0x39
	BEQ LED9
	CMP r5, #0x41
	BEQ LEDA
	CMP r5, #0x42
	BEQ LEDB
	CMP r5, #0x43
	BEQ LEDC
	CMP r5, #0x44
	BEQ LEDD
	CMP r5, #0x45
	BEQ LEDE
	CMP r5, #0x46
	BEQ LEDF
	
LED0
	;to determine the bits required to set, take the inverse of the number
	LDR r1, =0xE0028014 ;IO1SET
	LDR r2, =0x000F0000  
	STR r2, [r1] ;writes to the pins
	B LED_loop

LED1
	LDR r1, =0xE0028014 ;IO1SET
	LDR r2, =0x00070000 
	STR r2, [r1] 
	B LED_loop
	
LED2	
	LDR r1, =0xE0028014 ;IO1SET
	LDR r2, =0x000B0000 
	STR r2, [r1] 
	B LED_loop
	
LED3
	LDR r1, =0xE0028014 ;IO1SET
	LDR r2, =0x00030000 
	STR r2, [r1] 
	B LED_loop
	
LED4
	LDR r1, =0xE0028014 ;IO1SET
	LDR r2, =0x000D0000 
	STR r2, [r1] 
	B LED_loop
	
LED5
	LDR r1, =0xE0028014 ;IO1SET
	LDR r2, =0x00050000 
	STR r2, [r1] 
	B LED_loop
	
LED6
	LDR r1, =0xE0028014 ;IO1SET
	LDR r2, =0x00090000 
	STR r2, [r1] 
	B LED_loop
	
LED7
	LDR r1, =0xE0028014 ;IO1SET
	LDR r2, =0x00010000 
	STR r2, [r1] 
	B LED_loop
	
LED8
	LDR r1, =0xE0028014 ;IO1SET
	LDR r2, =0x000E0000 
	STR r2, [r1] 
	B LED_loop
	
LED9
	LDR r1, =0xE0028014 ;IO1SET
	LDR r2, =0x00060000 
	STR r2, [r1] 
	B LED_loop
	
LEDA
	LDR r1, =0xE0028014 ;IO1SET
	LDR r2, =0x000A0000 
	STR r2, [r1] 
	B LED_loop
	
LEDB
	LDR r1, =0xE0028014 ;IO1SET
	LDR r2, =0x00020000 
	STR r2, [r1] 
	B LED_loop
	
LEDC
	LDR r1, =0xE0028014 ;IO1SET
	LDR r2, =0x000C0000 
	STR r2, [r1] 
	B LED_loop
	
LEDD
	LDR r1, =0xE0028014 ;IO1SET
	LDR r2, =0x00040000 
	STR r2, [r1] 
	B LED_loop
	
LEDE
	LDR r1, =0xE0028014 ;IO1SET
	LDR r2, =0x00080000 
	STR r2, [r1] 
	B LED_loop
	
LEDF
	LDR r1, =0xE0028014 ;IO1SET
	LDR r2, =0x00000000 
	STR r2, [r1] 
	B LED_loop
	
	STMFD sp!, {lr, r0-r3}	
	
illuminate_RGB_LED
	STMFD sp!, {lr, r1,r2}

	LDR r1, =0xE0028008 ; IO0DIR address
	LDR r2, =0x00260000 ; load pins 17,18,21
	STR r2, [r1] ; set all the pins to high for IO0DIR
RGB_loop	
	LDR r4, =illuminateRGB_menu
	BL output_string
	BL read_string
	
	LDR r1, =0xE002800C ; IO1CLR address
	LDR r2, =0xFFFFFFFF
	STR r2, [r1]
	
	CMP r5, #0x6D ; check if m was entered (menu)
	;BEQ main_menu
	CMP r5, #0x71
	BEQ done
	CMP r5, #0x31
	BEQ red
	CMP r5, #0x32
	BEQ green
	CMP r5, #0x33
	BEQ blue
	CMP r5, #0x34
	BEQ purple
	CMP r5, #0x35
	BEQ yellow
	CMP r5, #0x36
	BEQ white
	CMP r5, #0x37
	BEQ turn_off
	
red
	LDR r1, =0xE0028004 ; Address of IO0SET
	LDR r2, =0x00240000
	STR r2, [r1]
	B RGB_loop	
green
	LDR r1, =0xE0028004 ; Address of IO0SET
	LDR r2, =0x00060000
	STR r2, [r1]
	B RGB_loop
blue
	LDR r1, =0xE0028004 ; Address of IO0SET
	LDR r2, =0x00220000
	STR r2, [r1]
	B RGB_loop
purple
	LDR r1, =0xE0028004 ; Address of IO0SET
	LDR r2, =0x00200000
	STR r2, [r1]
	B RGB_loop
yellow
	LDR r1, =0xE0028004 ; Address of IO0SET
	LDR r2, =0x00040000
	STR r2, [r1]
	B RGB_loop
white
	LDR r1, =0xE0028004 ; Address of IO0SET
	LDR r2, =0x00000000
	STR r2, [r1]
	B RGB_loop
turn_off
	LDR r1, =0xE0028004 ; Address of IO0SET
	LDR r2, =0x00260000
	STR r2, [r1]
	B RGB_loop
	
	LDMFD sp!, {lr, r1,r2}
	
	
read_from_push_buttons
	LDMFD sp!, {lr, r0-r3}
	LDR r1, =0xE0028018 ; IO1DIR address
	LDR r2, =0xFF0FFFFF	; set pins 20-23 as input
	STR r2, [r1] 
	
	
	
	
	LDR r3, =0xE0028010 ; Address of IO1PIN
	LDR r2, [r3] ;takes the reading of whats written in IO1PIN to see what buttons were pressed
	MOV r2, r2, LSR #20 ;shift the data so we can compare just a byte
	
	CMP r2, #0x00 
	BEQ buttonF
	
	CMP r2, #0x01
	BEQ button7 
	
	CMP r2, #0x02
	BEQ buttonB
	
	CMP r2, #0x03
	BEQ button3
	
	CMP r2, #0x04
	BEQ buttonD
	
	CMP r2, #0x05
	BEQ button5
	
	CMP r2, #0x06
	BEQ button9
	
	CMP r2, #0x07
	BEQ button1
	
	CMP r2, #0x08
	BEQ buttonE
	
	CMP r2, #0x09
	BEQ button6
	
	CMP r2, #0x0A
	BEQ buttonA
	
	CMP r2, #0x0B
	BEQ button2
	
	CMP r2, #0x0C
	BEQ buttonC
	
	CMP r2, #0x0D
	BEQ button4
	
	CMP r2, #0x0E
	BEQ button8
	
	CMP r2, #0x0F
	BEQ button0
	
	CMP r2, #0x71 ; q for quit
	BEQ done
	
	CMP r2, #0x6D ; main_menu
	;BEQ main_menu
	;finds what button was pressed to provide output to user
button0	
	LDR r4, =button0_str
	BL output_string
	B cont_or_done
	
button1
	LDR r4, =button1_str
	BL output_string
	B cont_or_done
	
button2
	LDR r4, =button2_str
	BL output_string
	B cont_or_done
	
button3
	LDR r4, =button3_str
	BL output_string
	B cont_or_done

button4
	LDR r4, =button4_str
	BL output_string
	B cont_or_done

button5
	LDR r4, =button5_str
	BL output_string
	B cont_or_done
	
button6
	LDR r4, =button6_str
	BL output_string
	B cont_or_done
	
button7
	LDR r4, =button7_str
	BL output_string
	B cont_or_done
	
button8
	LDR r4, =button8_str
	BL output_string
	B cont_or_done
	
button9
	LDR r4, =button9_str
	BL output_string
	B cont_or_done
	
buttonA
	LDR r4, =buttonA_str
	BL output_string
	B cont_or_done

buttonB
	LDR r4, =buttonB_str
	BL output_string
	B cont_or_done
	
buttonC
	LDR r4, =buttonC_str
	BL output_string
	B cont_or_done

buttonD
	LDR r4, =buttonD_str
	BL output_string
	B cont_or_done
	
buttonE
	LDR r4, =buttonE_str
	BL output_string
	B cont_or_done

buttonF
	LDR r4, =buttonF_str
	BL output_string
	B cont_or_done
	
	STMFD sp!, {lr, r0-r3}		
	
cont_or_done
	LDR r4, =button_continue
	BL output_string
	
	BL read_string
	
	CMP r5, #0x6D ; check for m
	;BEQ main_menu
	
	CMP r5, #0x71
	BEQ done
	
	B cont_or_done
	
	
	
	
done
	b done
	
	
	
	
	
	END
	
	
	