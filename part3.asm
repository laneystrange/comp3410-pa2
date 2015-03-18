.data
	file:	.asciiz "p3.txt"
	outf:	.asciiz "out.txt"
	buffer:	.space 1024
	
	intro: 	.ascii "This is my linked list"
	outboundBuffer:	.space 1024
	first:	.asciiz ""
	
	outro: 	.ascii ". The end of the list is  "
	pos:	.space 5
	term:	.asciiz ""
	.align 2
	array:	.space 1024
	
	
	.text
	
	#a0 buffer
	li $v0, 13 	# Open file service
	la $a0, file	# Load 'file' into arg1
	li $a1, 0	# For reading
	li $a2, 0	# Ignored
	syscall
	move $s7, $v0	# Saving the file descriptor
	
	li $v0, 14	# Read data service
	move $a0, $s7	# File descriptor from before
	la $a1, buffer	
	li $a2, 1024	# The buffer's size.
	syscall
	
	li $v0, 16	# Close file service
	move $a0, $s7	# File descriptor from before
	syscall
	
	#load both the array and buffer addresses for later use
	la $a0, buffer
	la $a1, array
	jal itoa
	
	#after converting the ints to the aray we need to reload the arrayand
	#load the outbound buffer to display text in file
	la $a0, array	
	la $a2, outboundBuffer
	#need to jump to the linkedlist portion to format linked list
	jal LinkedList
	move $s3, $v1	# Saves the position that the terminating element was found at.
	
	outBoundFilePrep:
		li $v0, 13		# Open file service
		la $a0, outf		# Loads 'outf' into arg1
		li $a1, 1		# For writing
		li $a2,	0		# Ignored
		syscall
		move $s2, $v0		# Saves the file descriptor
	
		li $v0, 15		# Write file service
		move $a0, $s2		# File descriptor
		la $a1, intro		# Buffer to write
		move $a2, $s4		# Number characters to write
		addi $a2, $a2, 25
		syscall
		
		
		move $s4, $zero		# Resets the number characters used
		
		move $a0, $s3		# Parses the position index
		la $a2, pos		# Loads the buffer to print
		jal itoa		# Parses it
	
		li $v0, 15		# file service
		move $a0, $s2		# File descriptor
		la $a1, outro		# Moves the output string to the arg
		move $a2, $zero		# Zeroes it
		addi $a2, $a2, 44	# Num characters to write
		add $a2, $a2, $s4	# Including the number we used.
		syscall
	
		#end program
		li $v0, 10
		syscall
		
	
	
	
LinkedList:
	move $s7, $ra
	move $ra, $s7		
	move $t7, $a0

	iteration: lw $t0, 0($t7)	#load an element out of the copy of the array
	move $s0, $a0 			#save the array adress from argument into another register 
	move $a0, $t0			#move the current number into the argument resister
	move $s7, $ra
	jal push 			#push the temp register to the stack 
	move $ra, $s7
	move $s7, $ra
	jal itoa			#convert all the ints to ascsii chars
	move $ra, $s7
	move $s7, $ra
	jal pop				#pop all the elements off of the stack
	move $ra, $s7
	move $a0, $s0			#make a0 available
	add $s4, $s4, $v0		#gather the runing count of the chars
	addi $t1, $t7, 4		#get the next element that is available for use
	lw $t2, 0($t1)			#load the next node for use
	beq $t2, -1, reachedTheEnd		#if the next node is -1 the we are done
	
	#if t2 is not -1 then we do this. We need to place the - char and the >before we print the nest
	#element 
	move $t6, $zero		# make s6 0
	addi $t6, $t6, '-'	# adds one of the number seperators to t6
	sb $t6, 0($a2)		# Writes the character
	addi $a2, $a2, 1	# Advances the write buffer
	addi $s4, $s4, 1 	# Increments the character counter
	#same code but writing the > char
	move $t6, $zero		# make s6 0
	addi $t6, $t6, '>'	# adds one of the number seperators to t6
	sb $t6, 0($a2)		# Writes the character
	addi $a2, $a2, 1	# Advances the write buffer
	addi $s4, $s4, 1 	# Increments the character counter	
	#this will in total form the -> string that goes between each number 
	
	mul $t2, $t2, 4	
	add $t7, $a0, $t2
	j iteration
	#once we have reached the end of the list by reaching the terminating character then we have reached the end of the list
	reachedTheEnd:
		sub $v1, $t1, $a0
		div $v1, $v1, 4
		move $v0, $s6 # puts the number of chars into v0
		jr $ra	
	
	
	
atoi:	
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



itoa:
start:	move $t1, $a0		# Loading aka moving the current byte to be used
	move $t2, $zero		
	addi $t2, $t2, 1	# Smagnitude begins at one
	move $t7, $t1	
	j magfind		# Finds the magnitude of the current number
	move $t7, $zero		# Resets our $t7 for future use.
negative:			
	bgt $t1, -1, positive	
	addi $t7, $t7, '-'	# if the value is negative it stroes it in the register that writes
	sb $t7, 0($a2)		# it will load the byte into the buffer
	addi $t3, $t3, 1	# chars used +1
	addi $a2, $a2, 1	# +1 write buffer
	mul $t1, $t1, -1	# since the number is negative we need to make is positive
				#using the format of (NegativeNum * -1) = the number in its positive value
positive:			
	move $t4, $a0		#moving and saving 
	move $a0, $zero		
	addi $a0, $a0, 10	# a0 = 10
	move $a1, $t2		# move the magnitude of the number to the a0 register
	move $t6, $zero		
	addi $t6, $t6, 1	
	j exp			
eret:	move $a0, $t4		# Restores original values
notdone:			
	div $t7, $t1, $t6	#get the left most digit to our writing buffer
	mul $t5, $t7, $t6	#Get the true value of the int get the closest number
				#place for the number if your number is 1555 then it would 
				#get 1000 
	sub $t1, $t1, $t5	#get the other value (555 out of 1555)
	addi $t7, $t7, '0'	
	div $t6, $t6, 10	#reduce the magnitude register by dividing by 10
	sb $t7, 0($a2)		#writes the byte to the buffer
	addi $t3, $t3, 1	# Increments the characters used so far
	addi $a2, $a2, 1	# Advances the write buffer one byte
	bne $t6, 0, notdone	#as long as the magnitude still exist then we need 
				#to branch to notdon again until we do not ave any
				#magnitude left
	j return		
	
	magfind:
	div $t7, $t7, 10 	#we need to divide the number that is strored in t7(the vurrent byte)
				# this allows us to tell wether or not out number that we have is less thatn
				#10.
	beq $t7, 0, negative
	addi $t2, $t2, 1	
	j magfind		
	
	
exp:	beq $a1, 1, nil		
	mul $t6, $t6, $a0	
	addi $a1, $a1, -1	
	bgt $a1, 1, exp		
nil:	j eret			
				
return:	move $v0, $t3		# This is the number of chracters that was used.
	jr $ra			# Returns


push:
	addi $sp, $sp, -48 	#need to make room for the variables
	sw $8, 16($sp)		#store with offset starting at 16 and increasing by four each time
	sw $9, 20($sp)		
	sw $10, 24($sp)		
	sw $11, 28($sp)		
	sw $12, 32($sp)		
	sw $13, 36($sp)		
	sw $14, 40($sp)		
	sw $15, 44($sp)		#^
	jr $ra			


pop:
	lw $8, 16($sp)		#nneed to store all the variable back into their locations
	lw $9, 20($sp)		
	lw $10, 24($sp)		
	lw $11, 28($sp)		
	lw $12, 32($sp)		
	lw $13, 36($sp)		
	lw $14, 40($sp)		
	lw $15, 44($sp)		
	addi $sp, $sp, 48 	#pops all elements off of stack
	jr $ra			
