	.text		
main:			# execution starts here
	lui $s1, 0x1000			#choose 0x10000000
							#user data segment default QTSpim: 0x10000000-0x10040000
	addi $s0, $zero, 12		#store 12 in $s0
	sw $s0, 16($s1)			#store 12 in 0x10000010
	lw $s2, 16($s1)			#retrieve 12 from memory