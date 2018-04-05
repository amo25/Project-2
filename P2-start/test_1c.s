	.text		
main:			# execution starts here
	addi $t0, $zero, 5	#put 5 in $t0
	addi $t1, $zero, 2	#put 2 in $t1
	slt $s0, $t1, $t0	#expect $s0 to get 1
	slt $s0, $t0, $t1	#put $s0 back to 0
