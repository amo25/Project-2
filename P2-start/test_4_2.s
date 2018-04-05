	.text		
main:			# execution starts here
				#recall that PC will start at 0x00400000
				
		lui $s0, 0x0040					#intialize $s0 to starting instruction addresss
		jr $s0							#jump to the starting address contained in $s0