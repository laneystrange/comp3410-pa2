.data
	file:	.asciiz "list.txt"
	outf:	.asciiz "outputfile.txt"
	buffer:	.space 1024
	
	intro: 	.ascii "This is the linked list: "
	outb:	.space 1024
	first:	.asciiz ""
	
	outro: 	.ascii ". The terminating element was at position "
	pos:	.space 5
	term:	.asciiz ""
	.align 2
	array:	.space 1024
	
.text
	li $v0, 13 	# Open file service
	la $a0, file	# Load 'file' into arg1
	li $a1, 0	# For reading
	li $a2, 0	# Ignored
	syscall
	move $s7, $v0	# Saving the file descriptor
	
	li $v0, 14	# Read data service
	move $a0, $s7	# File descriptor from before
	la $a1, buffer	# The buffer we're going to
	li $a2, 1024	# The buffer's size.
	syscall
	
	li $v0, 16	# Close file service
	move $a0, $s7	# File descriptor from before
	syscall
	
	la $a0, buffer	# Load the source buffer into arg1
	la $a1, array	# Load the destination array into arg2
	jal atoi	# Parse the strings to ints and put them into the array
	
	la $a0, array	# Loads the address of our linkedlist-array
	la $a2, outb	# Locates the output buffer into arg3
	jal linkedlist	# Runs the parser that traverses the linked list itself.
	move $s3, $v1	# Saves the position that the terminating element was found at.
	
	li $v0, 13	# Open file service
	la $a0, outf	# Loads 'outf' into arg1
	li $a1, 1	# For writing
	li $a2,	0	# Ignored
	syscall
	move $s2, $v0	# Saves the file descriptor
	
	li $v0, 15	# Write file service
	move $a0, $s2	# File descriptor
	la $a1, intro	# Buffer to write
	move $a2, $s4	# Number characters to write
	addi $a2, $a2, 25
	syscall
	
	move $s4, $zero	# Resets the number characters used
	
	move $a0, $s3	# Parses the position index
	la $a2, pos	# Loads the buffer to print
	jal itoa	# Parses it
	
	li $v0, 15	
	move $a0, $s2
	la $a1, outro
	move $a2, $zero
	addi $a2, $a2, 43
	add $a2, $a2, $s4
	syscall
	
	li $v0, 10
	syscall
	
	
linkedlist:
	## $a0 is the array containing the linked list
	## $a2 is the output buffer to write the list to
	## $v0 is the number of characters used
	## $v1 is the index of the terminating character (-1)
	## $s4 is the number of characters used until returned
	## $t0 is the current number
	## $t1 is the current node's next-node pointer's address
	## $t2 is the next-node pointer's value
	## $t6 is a writing register
	## $t7 is a copy of the array
#################################
	move $s7, $ra		#
	jal zerotemps		#
	move $ra, $s7		#
	move $t7, $a0		#
itr:	lw $t0, 0($t7)		# Loads an element
	move $s0, $a0		# Saves our original $a0
	move $a0, $t0		# Moves our to-be-written int to the arguments
	move $s7, $ra	
	jal pushvars		# Stores our $t* registers
	move $ra, $s7
	move $s7, $ra
	jal itoa		# Write that element
	move $ra, $s7
	move $s7, $ra
	jal fetchvars		# Fetches the $t* registers
	move $ra, $s7
	move $a0, $s0		# Resets our arg1
	add $s4, $s4, $v0	# Accumulates our running total of characters used
	addi $t1, $t7, 4	# Sets $t1 to the current element's next-node pointer's address
	lw $t2, 0($t1)		# Fetches the value of the next-node pointer.
	beq $t2, -1, endlist	# If the next-node pointer is -1, we are done.
	#			#
	move $t6, $zero		# Zeroes the register
	addi $t6, $t6, '-'	# Adds the formatted character
	sb $t6, 0($a2)		# Writes the character
	addi $a2, $a2, 1	# Advances the write buffer
	addi $s4, $s4, 1 	# Increments the character counter
	##			## These two blocks are for printing the formatted output characters
	move $t6, $zero		# ^
	addi $t6, $t6, '>'	# ^
	sb $t6, 0($a2)		# ^
	addi $a2, $a2, 1	# ^
	addi $s4, $s4, 1 	# ^
	#			#
	mul $t2, $t2, 4		# Converts the index in $t2 to an offset
	add $t7, $a0, $t2	# Moves the current-node pointer to where the next-node pointer indicated
	j itr			#
				#
endlist:			#
	sub $v1, $t1, $a0	# Obtains the terminating character's offset
	div $v1, $v1, 4		# Obtains an index from the offset.
	move $v0, $s6		# Puts the number of used characters into the return register.
	jr $ra			#
#################################


atoi:
	## $a0 is the input string's address
	## $a1 is the output array's address
	## $v0 is the address of the output array
	## $v1 is the number of elements in the output array
	## $t7 is the copied string address, $t6 is the final number, $t5 is the negative flag
	## $t0 is the current byte, $t4 is the number of elements
#################################	
	move $t7, $a0 		# Copying the input string's address so we can manipulate it.
	move $v0, $zero		#
reset:	lb $t0, 0($t7)		# Fetching the first byte, Also our starting point
	move $t5, $zero		#
	bne $t0, 45, loop	# If negative, proceed, otherwise skip to 'loop'
				#
isneg:	addi $t5, $t5, 1 	# Setting the negative flag
	addi $t7, $t7, 1 	# Moving string forward one byte
				#
				#
loop:	lb $t0, 0($t7)		# Fetch current byte
	beq $t0, 10, laststep	# If we are at a linefeed, store this and start over with the next number.
	beq $t0, 0, laststep	# If we find the null terminator, we are also done.
	subi $t0, $t0, '0'	# Finding the decimal value from ASCII value
	mul $t6, $t6, 10	# Move the number's magnitude forward one order.
	add $t6, $t6, $t0	# Add the current byte.
	addi $t7, $t7, 1	# Move the byte forward one.
	j loop			#
				#
laststep:			#
	bne $t5, 1, store	# If the number is positive, skip this immediately.
	mul $t6, $t6, -1	# Set the number to negative otherwise.
	j store			# Jump to the storing routine.
				#
store:	sw $t6, 0($a1)		# Stores the current integer in the array
	addi $a1, $a1, 4	# Moves the array pointer forward one element
	addi $t7, $t7, 1	# Move to the next byte before returning
	move $t6, $zero		# Zeroing out the final number
	beq $t0, 0, parsedone	# Null terminator, do not repeat.
	addi $t4, $t4, 1	# Increments the number of elements in the array by 1.
	j reset			#
				#
parsedone:			#
	move $v0, $a1		# Moves the output array to the results register
	move $v1, $t4		# Stores the number of elements in the array
	jr $ra			#
#################################


itoa:
	## $a0 is the int to convert
	## $a2 is the buffer to write to
	## $v0 is the number of characters used so far
	## $t1 is the current number
	## $t2 is the magnitude of the current element
	## $t3 is the number of characters used so far
	## $t7 is the current byte to write
#################################
start:	move $t1, $a0		# Loads the current element in the array
	move $t2, $zero		# Makes sure $t2 is zero.
	addi $t2, $t2, 1	# Sets our magnitude indicator to 1 to start with.
	move $t7, $t1		# Removes one extra label by doing the temporary register here.
	j magfind		# Finds the magnitude of the current number
	move $t7, $zero		# Resets our $t7 for future use.
negative:			#
	bgt $t1, -1, positive	# Skips the negative writing if it's positive or zero
	addi $t7, $t7, '-'	# Stores the negative in the writing register
	sb $t7, 0($a2)		# Writes the byte to the buffer
	addi $t3, $t3, 1	# Increments the characters used so far
	addi $a2, $a2, 1	# Advances the write buffer one byte
	mul $t1, $t1, -1	# Since we have written the negative, we want to make our number positive.
positive:			#
	move $t4, $a0		# Saves our original arg1
	move $a0, $zero		# Zeroes arg1
	addi $a0, $a0, 10	# Sets it to 10
	move $a1, $t2		# Sets arg2 to the magnitude of the number
	move $t6, $zero		# Zeroes $t6
	addi $t6, $t6, 1	# Sets it to 1 so exp can work.
	j exp			#
eret:	move $a0, $t4		# Restores original values
notdone:			#
	div $t7, $t1, $t6	# Gets the leftmost digit of our number to our writing byte
	mul $t5, $t7, $t6	# Gets the adjusted value (e.g. 600 out of 628) from writing byte * mag to $t5
	sub $t1, $t1, $t5	# Gives us the other digits (e.g. 28 out of 628) from number - (writing byte* mag) to $t1
	addi $t7, $t7, '0'	# Gets the ASCII value to writing byte
	div $t6, $t6, 10	# Reduces our magnitude register by a factor of 10 (e.g. from 100 to 10)
	sb $t7, 0($a2)		# Writes the current byte
	addi $t3, $t3, 1	# Increments the characters used so far
	addi $a2, $a2, 1	# Advances the write buffer one byte
	bne $t6, 0, notdone	# If we have magnitude left, branch to notdone.
	j return		# We've finished.
				#
				#
	# $t2 is the magnitude	#
				#
magfind:			#
	div $t7, $t7, 10 	# Divides the number by ten
	beq $t7, 0, negative	# If we got 0, it means our number < 10, so we're done.
	addi $t2, $t2, 1	# Else, we increment our magnitude indicator, then go again
	j magfind		# ^
				#
	# Base is in $a0	#
	# Power is in $a1	#
	# Result is in $v0	#
exp:	beq $a1, 1, nil		#
	mul $t6, $t6, $a0	#
	addi $a1, $a1, -1	#
	bgt $a1, 1, exp		#
nil:	j eret			#
				#
return:	move $v0, $t3		# This is the number of chracters that was used.
	jr $ra			# Returns
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

pushvars:
################################# This routine stores every temp register on the stack so nothing can interfere with it.
	addi $sp, $sp, -48	#
	sw $8, 16($sp)		#
	sw $9, 20($sp)		#
	sw $10, 24($sp)		#
	sw $11, 28($sp)		#
	sw $12, 32($sp)		#
	sw $13, 36($sp)		#
	sw $14, 40($sp)		#
	sw $15, 44($sp)		#
	jr $ra			#
#################################	

fetchvars:
################################# This routine fetches every temp variable that was previously stored on the stack.
	lw $8, 16($sp)		#
	lw $9, 20($sp)		#
	lw $10, 24($sp)		#
	lw $11, 28($sp)		#
	lw $12, 32($sp)		#
	lw $13, 36($sp)		#
	lw $14, 40($sp)		#
	lw $15, 44($sp)		#
	addi $sp, $sp, 48	#
	jr $ra			#
#################################			
