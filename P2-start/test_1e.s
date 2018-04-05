	.text		
main:			# execution starts here
	addi $t0, $zero, 0xFc		#put 0b00...1111 1100 in $t0
	addi $t1, $zero, 0xFE		#put 0b00...1111 1110 in $t1
	nor $s0, $t0, $t1			#expect 0b111...0001
