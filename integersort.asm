.data
charErr:	.asciiz	"INPUT FILE ERROR! Exiting..."
file:		.asciiz "/home/evan/Documents/MIPS/comp3410-pa2/integers.txt"
fix:		.word 0		# this gets everything word-aligned again
buffer:		.space 1024	# room enough for 1024 characters
numbers:	.space 1024 	# room enough for 256 integers
digits:		.space 32	# room enough for 32 characters
.text

open:
	li	$v0, 13		# open file call
	la	$a0, file	# load file by name
	li	$a1, 0		# set flag to read only
	li	$a2, 0		# ignored
	syscall
	move 	$s0, $v0	# save file descriptor into s0
	
read:
	li 	$v0, 14		# read file call
	move	$a0, $s0	# load file descriptor
	la	$a1, buffer	# provide the buffer
	li	$a2, 1024	# buffer size
	syscall
	
insertNumbers:
	la	$t5, numbers	# the address our array of numbers is loaded into $s1
	la 	$t0, buffer	# set t0 to start of buffer
	move	$t1, $t0 	# set t1 to t0's value (this will keep the address of the start of the line)
	
	
	breakIntoLines:
		move	$t2, $t1	# set t2 to t1's value (we'll be moving this one along)
		findBreak:
			lb 	$t3, ($t2)		# load into t3 the character value at the t2 address
			li	$t4, 10			# set t4 to the ascii value of newline
			beq	$t3, $t4, foundBreak	# branch to the end if newline was encountered
			beqz	$t3, sort		# branch to the exit if null terminator was encountered
			addi 	$t2, $t2, 1		# otherwise, increment the address by 1 byte
			j 	findBreak		# do it again
		foundBreak:
			la	$a0, ($t1)	# load the address of the line's start as the argument
			jal	atoi		# convert the char array to an integer
			sw	$v0, ($t5)	# store the returned value in the numbers array
			addi 	$t5, $t5, 4	# set $t5 to the next entry in our numbers array
			addi	$s1, $s1, 1	# increase our total integer count by 1
			move	$t1, $t2	# set the start of the line to the end of the current line
			addi	$t1, $t1, 1	# move to the next character (start of next line if previous character was newline)
			j 	breakIntoLines
sort:
	# this is going to be selection sort because it is the easiest to implement for me
	# set temp count
	sortOuter:
	# determine the point where the max value will be put using temp count/ what is the final thing examined
		sortInner:
			# find the max value's address
	# do a swap
	# if remaining = 1, then done, else jump back
	
la	$a0, numbers
jal	itoa
li	$v0, 4
la	$a0, digits
syscall	

close:
	li	$v0, 16
	move	$a0, $s0
	syscall
	li	$v0, 10
	syscall
	
atoi:
	# first thing to do is to find the newline or null terminator to determine where the 1s place is
	addi 	$sp, $sp, -24	# we're gonna need some temp registers
	sw	$t0, 20($sp)	# store t0 on the stack for out current character address
	sw	$t1, 16($sp)	# store t1 on the stack for the character
	sw	$t2, 12($sp)	# store t2 on the stack for math results
	sw	$t3, 8($sp)	# store t3 on the stack for keeping sign
	sw	$t4, 4($sp)	# store t4 on the stack for keeping the count of places
	sw	$t5, 0($sp)	# store t5 on the stack for keeping track of how many more multiplications by 10 are necessary
	
	la $t0, ($a0)		# set t0 to the address of the line's first character
	li $t3, 1		# set initial sign as positive
	li $v0, 0		# set v0 to 0 for adding stuff onto it
	j findOnesPlace
	
	negate:
		bne 	$a0, $t0, error		# if the negative sign wasn't at the start of the line, we have a problem
		li	$t3, -1			# set the multiplier to -1
		addi 	$t0, $t0, 1		# move to the next character
	findOnesPlace:
		lb	$t1, ($t0)		# load the character at the current address into t1
		
		li	$t2, 45			# load ascii value of - into t2
		beq	$t1, $t2, negate	# branch to negate if 
		
		beqz	$t1, foundEnd		# branch to computation if character is null terminator
		
		li	$t2, 10			# load ascii value of \n into t2
		beq	$t1, $t2, foundEnd	# branch to computation if character is new line
		
		li	$t2, 48			# load ascii value of 0 into t2
		blt	$t1, $t2, error		# branch to error if character's ascii value is less than that of 0
		
		li	$t2, 57			# load ascii value of 9 into t2
		bgt	$t1, $t2, error		# branch to error if character's ascii value is greater than that of 9
		
		addi	$t0, $t0, 1		# go to the next character
		j findOnesPlace			# if we haven't reached an end or error yet, keep looking for it!
		
	# now we have the address of the character after the ones place in t0, so we just have to make a small adjustment
	foundEnd:
		sub	$t4, $t0, $a0		# get the number of numeric characters in our line
		la	$t0, ($a0)		# move the address back to the start of the line
		bgtz	$t3, addingByPlace	# if the number didn't have a negative sign, then we go ahead to addingByPlace
		addi	$t4, $t4, -1		# the negative sign shouldn't count towards the number of places
		addi	$t0, $t0, 1		# move the address forward by one so that it starts at the correct place
		
	addingByPlace:
		lb	$t1, ($t0)		# load the character at this position
		addi	$t1, $t1, -48		# get the numeric value of the number character
		move	$t5, $t4		# move the counter to $t5
		addi	$t5, $t5, -1		# decrement by one to account for not multiplying the ones place at all
		beqz	$t5, exitMultiplication
		placeMultiplication:		# begin the loop
			mul	$t1, $t1, 10			# multiply by 10, possibly again
			addi	$t5, $t5, -1			# remove one from the count
			bgtz 	$t5, placeMultiplication	# if the count is still greater than 0, do it again!
		exitMultiplication:
		add	$v0, $v0, $t1		# add this properly multiplied digit to our sum
		addi	$t0, $t0, 1		# move to the next character
		addi	$t4, $t4, -1		# decrement the place counter
		bgtz	$t4, addingByPlace	# if the place counter is greater than 0, do it again!
		mul	$v0, $v0, $t3		# affix the sign at the end
	
	lw	$t0, 20($sp)	# reload t0
	lw	$t1, 16($sp)	# reload t1
	lw	$t2, 12($sp)	# reload t2
	lw	$t3, 8($sp)	# reload t3
	lw	$t4, 4($sp)	# reload t4
	lw	$t5, 0($sp)	# reload t5
	addi 	$sp, $sp, 24	# move the stack pointer back to its initial position
	jr $ra			# return

itoa:
	addi	$sp, $sp, -28
	sw	$t0, 24($sp)	# store t0 to use it for the value of the word
	sw	$t1, 20($sp)	# store t1 to use it for the divisor value
	sw	$t2, 16($sp)	# store t2 to use it for the count of places
	sw	$t3, 12($sp)	# store t3 to use it for the division result
	sw	$t4, 8($sp)	# store t4 to use it for the character count
	sw	$t5, 4($sp)	# store t5 to use it for the character value
	sw	$t6, 0($sp)	# store t6 to use it for the digits address
	
	lw	$t0, ($a0)	# get the value of the word at the given address
	li	$t1, 1		# the place / power value
	li	$t2, 0		# the count of places
	li	$t4, 0		# the count of characters
	la	$t6, digits	# the address of the result
	
	placeCount:
		div 	$t3, $t0, $t2		# get the result of our number divided by the power of 10
		mul	$t1, $t1, 10		# multiply our power number by 10
		addi	$t2, $t2, 1		# increment the place count
		bgtz 	$t3, placeCount		# if the result value is greater to 0, go to placeCount
		bltz	$t3, placeCount		# if the result value is less than 0 (negative nums), go to placeCount
		
		# I realize I could have just used equal to 0, but I would rather do this and let the final flow on through
		# instead of branching to some point which I will probably loop
	
	div	$t1, $t1, 10	# divide our power by a single 10 to ready it for conversion step
	
	bgtz	$t0, convert	# go to conversion if the value is positive
	li	$t5, 45		# store at t5 the ascii value of "-"
	sw	$t5, ($t6)	# store the - as the first char in our result
	addi	$t6, $t6, 1		# move to the next char position
	neg	$t0, $t0	# make it positive now!
	
	convert:
		div 	$t5, $t0, $t1	# get the resulting digit of t0 divided by t1 in t5
		addi	$t5, $t5, 48	# t5 is now the ascii value of the digit that was at t5
		sw	$t5, ($t6)	# store this ascii value in our table
		addi	$t2, $t2, -1	# decrement the place count by 1
		div	$t1, $t1, 10	# divide the power by 10
		bgtz	$t2, convert	# if the count is still greater than 0, repeat
	
	li	$t5, 0		# load at t5 the null terminator
	sw	$t5, ($t6)	# store the null terminator at the address of t6
	
	# this will store the characters in result, it will return the number of characters in it
	
	lw	$t0, 24($sp)	# retrieve the old value of t0
	lw	$t1, 20($sp)	# retrieve the old value of t1
	lw	$t2, 16($sp)	# retrieve the old value of t2
	lw	$t3, 12($sp)	# retrieve the old value of t3
	lw	$t4, 8($sp)	# retrieve the old value of t4
	lw	$t5, 4($sp)	# retrieve the old value of t5
	lw	$t6, 0($sp)	# retrieve the old value of t6
	addi	$sp, $sp, 28	# put the stack back to its initial position
	jr 	$ra

error:
	li	$v0, 4		# tell it we want to print a string
	la	$a0, charErr	# tell it which string we want to print
	syscall			# print it!
	li	$v0, 10		# tell it we want to exit
	syscall			# exit!
