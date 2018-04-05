	.text		
main:			# execution starts here
				#recall that PC will start at 0x00400000
				
		addi $s0, $zero, 1	#intialize $s0 to 1
STARTL:	addi $s0, $s0, 1	#increment $s0
		j STARTL 	#expect the PC to jump back to START after this instruction
		addi $t2, $zero, 4