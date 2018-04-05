	.text		
main:			# execution starts here
	addi $t0, $zero, 14			#put 0b..0001110 = 14 in $t0
	andi $s0, $t0, 7			#expect 0b110 = 6 in $s0
