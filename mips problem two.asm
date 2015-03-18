	.data
	file: .asciiz "PA2_input1.txt"
	outf: .asciiz "PA2_output1.txt"
	bufstart: .ascii ""
	buffer: .space 1024
	bufend: .asciiz ""
	outs:	.ascii ""
	outb:	.space 1024
	oute:	.asciiz ""
	.align 2
	array: .space 1024
.text	
main:
	# Open file
	li $v0, 13
	la $a0, file
	li $a1, 0
	li $a2, 0
	syscall
	move $s6, $v0
	
	# Read data
	li $v0, 14
	move $a0, $s6
	la $a1, buffer
	li $a2, 1024
	syscall
	
	# Print contents
	#li $v0, 4
	#la $a0, bufstart
	#syscall
	
	# Close file
	li $v0, 16
	move $a0, $s6
	syscall
	
	# Access data
	la $a0, buffer		# Puts the location of the buffer in arg1
	la $a1, array		# Puts the location of the output array in arg2
	jal atoi		# Parses the list of strings into integers
	jal zerotemps
	la $a0, array		# Puts our array into arg1.
	move $a1, $v1		# Moves the number of elements in that array to arg2
	move $s1, $v1		# Since we need it later, we store the number of ints here.
	jal selsort		# Sorts the integers in-place
	jal zerotemps
	
	# Open new file
	li $v0, 13		# Opens our new file to write the sorted integers to
	la $a0, outf		# Loads the file descriptor
	li $a1, 1		# Flag for writing
	li $a2, 0		# Ignored
	syscall			# Does it
	move $s2, $v0		# Saves the file descriptor
	
	la $a0, array		# Moves the sorted array of ints to arg1
	move $a1, $s1		# Moves the number of ints to arg2
	la $a2, outb		# Moves the output buffer to arg3
	jal itoa		# Calls atoi to make a string in the output buffer
	
	li $v0, 15		# Integer for writing	
	move $a0, $s2		# Moves our file descriptor to arg1
	la $a1, outb		# Locates our write-buffer
	li $a2, 1024		#
	syscall			# Writes to the file
	
	j exit
	
atoi:
	## $a0 is the input string's address
	## $a1 is the output array's address
	## $t7 is the copied string address, $t6 is the final number, $t5 is the negative flag
	## $t0 is the current byte, $t4 is the number of elements
#################################	
	move $t7, $a0 		# Copying the input string's address so we can manipulate it.
	move $v0, $zero
reset:	lb $t0, 0($t7)		# Fetching the first byte, Also our starting point
	move $t5, $zero
	bne $t0, 45, loop	# If negative, proceed, otherwise skip to 'loop'
	
isneg:	addi $t5, $t5, 1 	# Setting the negative flag
	addi $t7, $t7, 1 	# Moving string forward one byte
	
	
loop:	lb $t0, 0($t7)		# Fetch current byte
	beq $t0, 10, laststep	# If we are at a linefeed, store this and start over with the next number.
	beq $t0, 0, laststep	# If we find the null terminator, we are also done.
	subi $t0, $t0, '0'	# Finding the decimal value from ASCII value
	mul $t6, $t6, 10	# Move the number's magnitude forward one order.
	add $t6, $t6, $t0	# Add the current byte.
	addi $t7, $t7, 1	# Move the byte forward one.
	j loop
	
laststep:
	bne $t5, 1, store	# If the number is positive, skip this immediately.
	mul $t6, $t6, -1	# Set the number to negative otherwise.
	j store			# Jump to the storing routine.
	
store:	sw $t6, 0($a1)		# Stores the current integer in the array
	addi $a1, $a1, 4	# Moves the array pointer forward one element
	addi $t7, $t7, 1	# Move to the next byte before returning
	move $t6, $zero		# Zeroing out the final number
	beq $t0, 0, parsedone	# Null terminator, do not repeat.
	addi $t4, $t4, 1	# Increments the number of elements in the array by 1.
	j reset
	
parsedone:
	move $v0, $a1		# Moves the output array to the results register
	move $v1, $t4		# Stores the number of elements in the array
	jr $ra			#
#################################

selsort:
	# $a0 is the address of the unsorted array
	# $a1 is the number of elements in $a0
	# The number of elements in $a0 is in $a1
	# $t0 is the current number
	# $t1 is the current minimum
	# $t2 is the current unsorted boundary location
	# $t3 is the iterations counter
	# $t4 is a copy of the array address to iterate with
	# $t6 is the address of the current minimum
#################################
setup:	move $t0, $zero		# Sets our current number to zero
	move $t2, $a0		# Sets the unsorted boundary to the whole list (initial state)
	move $t3, $zero		# Sets our iterations counter to zero
newround:
	move $t3, $zero		# Resets the iteration counter
	move $t4, $t2		# Sets our iterating array to the boundary of the unsorted list
	move $t1, $zero		# Zeroes out our min, then sets it to the maximum.
	addu $t1, $t1, 2147479548
thisitr:
	beq $a1, 0, sortdone	# We have no more elements to go, so the array is sorted.
	lw $t0, 0($t4)		# Loads the left-most element in the unsorted portion of the array
	blt $t0, $t1, setmin	# Set the min if the current number is less than the current min.
resume:	addi $t3, $t3, 1	# Increments the iteration counter
	addi $t4, $t4, 4	# Moves the pointer in the iterating array one forward
	beq $t3, $a1, sort	# If we have iterated through the whole array, go to sort routine
	j thisitr

sort:	lw $t5, 0($t6)		# Load the current min into a temporary holding point
	lw $t7, 0($t2)		# Load the leftmost element into a temporary holding point
	sw $t5, 0($t2)		# Puts the current minimum element into the leftmost spot
	sw $t7, 0($t6)		# Puts the leftmost spot into where the current minimum was
	addi $t2, $t2, 4	# Advances the current unsorted boundary forward one element
	addi $a1, $a1, -1	# Decrements the number of elements for the thisitr routine
	j newround

setmin:	move $t6, $t4		# Getting the address of the new minimum
	move $t1, $t0		# Setting the new minimum
	j resume

sortdone:
	move $v0, $a0		# Move the now-sorted array to the results register
	jr $ra			#
#################################

itoa:
	# $a0 is the array of ints to convert
	# $a1 is the number of ints in $a0
	# $a2 is the buffer to write to
	# $t1 is the current number
	# $t2 is the magnitude of the current element
	# $t7 is the current byte to write
#################################
	beqz $a1, return	# If we have nothing to write (primitive error-checking)
start:	lw $t1, 0($a0)		# Loads the current element in the array
	move $t2, $zero		# Makes sure $t2 is zero.
	addi $t2, $t2, 1	# Sets our magnitude indicator to 1 to start with.
	move $t7, $t1		# Removes one extra label by doing the temporary register here.
	j magfind		# Finds the magnitude of the current number
	move $t7, $zero		# Resets our $t7 for future use.
negative:
	bgt $t1, -1, positive	# Skips the negative writing if it's positive or zero
	addi $t7, $t7, '-'	# Stores the negative in the writing register
	sb $t7, 0($a2)		# Writes the byte to the buffer
	addi $a2, $a2, 1	# Advances the write buffer one byte
	mul $t1, $t1, -1	# Since we have written the negative, we want to make our number positive.
positive:
	move $t3, $a0		# Saves our original arg1
	move $t4, $a1		# Saves our original arg2
	move $a0, $zero		# Zeroes arg1
	addi $a0, $a0, 10	# Sets it to 10
	move $a1, $t2		# Sets arg2 to the magnitude of the number
	move $t6, $zero		# Zeroes $t6
	addi $t6, $t6, 1	# Sets it to 1 so exp can work.
	j exp
eret:	move $a0, $t3		# Restores original values
	move $a1, $t4		# ^
notdone:
	div $t7, $t1, $t6	# Gets the leftmost digit of our number to our writing byte
	mul $t5, $t7, $t6	# Gets the adjusted value (e.g. 600 out of 628) from writing byte * mag to $t5
	sub $t1, $t1, $t5	# Gives us the other digits (e.g. 28 out of 628) from number - (writing byte* mag) to $t1
	addi $t7, $t7, '0'	# Gets the ASCII value to writing byte
	div $t6, $t6, 10	# Reduces our magnitude register by a factor of 10 (e.g. from 100 to 10)
	sb $t7, 0($a2)		# Writes the current byte
	addi $a2, $a2, 1	# Advances the write buffer one byte
	bne $t6, 0, notdone	# If we have magnitude left, branch to notdone.
	j nextint		# We've finished this int, progress to the next one
	
	
	# $t2 is the magnitude
	
magfind:
	div $t7, $t7, 10 	# Divides the number by ten
	beq $t7, 0, negative	# If we got 0, it means our number < 10, so we're done.
	addi $t2, $t2, 1	# Else, we increment our magnitude indicator, then go again
	j magfind		# ^

	# Base is in $a0
	# Power is in $a1
	# Result is in $v0
exp:	beq $a1, 1, nil
	mul $t6, $t6, $a0
	addi $a1, $a1, -1
	bgt $a1, 1, exp
nil:	j eret
	
nextint:
	move $t7, $zero		# Zeroes the writing byte
	addi $t7, $t7, 10	# Puts a newline into our writing register
	sb $t7, 0($a2)		# Writes the newline
	addi $a2, $a2, 1	# Advances the write buffer one byte
	addi $a1, $a1, -1	# Decrements the number of integers to write by 1.
	beqz $a1, return	# If we are at 1 ints to write, we are done.
	addi $a0, $a0, 4	# Advances to the next element in the array
	j start			# Does it over
				
return:	jr $ra			# Returns
#################################

zerotemps:
######################### This method simply zeroes all our temporary registers so we can be sure they're free.
	move $t0, $zero	#
	move $t1, $zero #
	move $t2, $zero #
	move $t3, $zero #
	move $t4, $zero #
	move $t5, $zero #
	move $t6, $zero #
	move $t7, $zero #
	jr $ra		#
#########################	


exit:	li $v0, 10
	syscall