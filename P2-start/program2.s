	.text		
main:			# execution starts here
	addi $t0, $zero, 12		#store 12 in $t0
	lui $t1, 0x1000			#choose 0x10000000
							#user data segment default QTSpim: 0x10000000-0x10040000