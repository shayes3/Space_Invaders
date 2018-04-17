	AREA game, CODE, READWRITE
		
	EXPORT lab7
		
	EXTERN output_string	
	EXTERN FIQ_Handler
	EXTERN interrupt_init	
	EXTERN uart_init
	EXTERN pin_connect_block_setup_for_uart0

	EXPORT formfeed
	EXPORT playerLocation
	EXPORT board	

	EXTERN read_character



instructions = "Welcome to Micro Space Invaders!\n\rThe goal of the game is to destroy all the invaders!\n\rBut watch our for enemies as they will shoot bullets at you, use the shields for additional safety!\n\rScoring goes as follows:\n\rKill a W: 10 points\n\rKill a M: 20 Points\n\rKill an O: 40 Points\n\rKill a X: Random value between 100-300\n\rLosing a life: -100 Points\n\rThe controls for the game are:\n\ra: Moves the ship to the left\n\rd: Moves the ship to the right\n\rspacebar: Shoots a bullet\n\rPush button: pauses the game\n\rq: Quit the game at anytime\n\rPress Enter to begin!\n\r",0 
playerLocation = "0000",0 ;original location of player is offset 19C from begining of board
formfeed = "\f",0
board = "\n\r|---------------------|\n\r|                     |\n\r|       OOOOOOO       |\n\r|       MMMMMMM       |\n\r|       MMMMMMM       |\n\r|       WWWWWWW       |\n\r|       WWWWWWW       |\n\r|                     |\n\r|                     |\n\r|                     |\n\r|                     |\n\r|                     |\n\r|   SSS   SSS   SSS   |\n\r|   S S   S S   S S   |\n\r|                     |\n\r|          A          |\n\r|---------------------|",0

bulletLocation = "0000",0 

	
	ALIGN
		
		
		
lab7
	STMFD sp!, {lr}
	
	BL pin_connect_block_setup_for_uart0
	BL uart_init
	
	
	LDR r4, =instructions
	BL output_string
	
wait_for_enter	
	BL read_character
	CMP r1, #0x0D ;check if the user pressed enter
	BEQ enter_pressed
	B wait_for_enter
	
enter_pressed	
	BL interrupt_init

	LDR r4, =board
	BL output_string
	
	LDR r5, =playerLocation
	LDR r6, =0x00000184 ;put the player offset into a register
	STR r6, [r5] ; put the offset into memory
	

	
	
game_start

	B game_start

	LDMFD sp!, {lr}

	END