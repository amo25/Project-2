	.text		
main:			# execution starts here
				#recall that PC will start at 0x00400000
				
START:	addi $t0, $zero, 12		#set both $t0 and $t1 to 12
		addi $t1, $zero, 12
		beq $t0, $t1,  START 	#expect the PC to jump back to START after this instruction