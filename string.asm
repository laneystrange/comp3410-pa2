
	.globl strlen, strcopy, atoi, itoa, getline
	
##########################################################
# function: strlen
# takes --
# $a0 : null terminated string
# returns --
# $v0 : length in bytes
##########################################################
strlen:
	li $v0, 0 			# init length to 0
strlen.loop:
	lbu $t0, 0($a0)			# load the char
	beq $t0, '\0', strlen.return 	# break if '\0'
	add $a0, $a0, 1			# advance the pointer
	add $v0, $v0, 1			# increment the length
	j strlen.loop
strlen.return:
	jr $ra

##########################################################
# function: strcopy
# takes --
# $a0 : null terminated string
# $a1 : destination buffer
# returns --
# $v0 : bytes copied
##########################################################
strcopy:
	addi $sp, $sp, -8	# reserve 2 words on the stack
	sw $ra, 0($sp)		# save the $ra
	sw $s0, 4($sp)
	move $s0, $a0
	
	jal strlen
	
	move $t0, $v0		# init loop counter to length
strcopy.loop:
	lb $t1, 0($s0)		# load byte from src
	sb $t1, 0($a1)		# store byte to dst
	addi $s0, $s0, 1 	# src++
	addi $a1, $a1, 1 	# dst++
	addi $t0, $t0, -1 	# count--
	bnez $t0, strcopy.loop
	
	lw $s0, 4($sp)
	lw $ra, 0($sp)
	addi $sp, $sp, 8
	jr $ra
	
##########################################################
# function: atoi
# takes --
# $a0 : null terminated string
# returns --
# $v0 : integer value
##########################################################
atoi:	
	add $sp, $sp, -8
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	move $s0, $a0
	
	jal strlen
	sub $t0, $v0, 1 		# init loop counter to size - 1 because we want the last index
	li $t2, 1 			# init place value
	li $v0, 0			# init result
atoi.loop:	
	add $t1, $s0, $t0		# compute the address of the next char
	lbu $t1, 0($t1)			# load the char
	beq $t1, '-', atoi.neg		# goto negative case if '-' is encountered
	blt $t1, '0', atoi.continue	# *if it's not numeric, skip it
	bgt $t1, '9', atoi.continue	# *
	sub $t1, $t1, '0'		# subtract '0' from the character
	mul $t1, $t1, $t2		# multiply by the place value
	add $v0, $v0, $t1		# add to the result
	mul $t2, $t2, 10		# multiply the place by 10
atoi.continue:	
	sub $t0, $t0, 1			# decrement the loop counter
	bge $t0, $zero, atoi.loop	# if the index is greater than or equal to zero, loop
	j atoi.return
atoi.neg:
	neg $v0, $v0			# negate the result
atoi.return:
	lw $s0, 4($sp)
	lw $ra, 0($sp)
	add $sp, $sp, 8
	jr $ra				# return
	
##########################################################
# function: itoa
# takes --
# $a0 : integer value
# returns --
# $v0 : null terminated string
##########################################################
	.data
	
str_buffer: .space 32

	.text

itoa:	
	la $t0, str_buffer		# load the string buffer
	addi $t0, $t0, 30		# seek to end
	sb $zero, 1($t0)		# add null terminator
	li $t1, '0'			# init with ascii '0' *
	sb $t1, ($t0)			# *
	li $t1, 10			# store constant 10 for div
	slti $t2, $a0, 0 		# store the sign
	beq $t2, $zero, itoa.loop	# positive, begin loop
	neg $a0, $a0
itoa.loop:	
	div $a0, $t1			# divmod the argument
	mflo $a0			# get the quotient
	mfhi $t3			# get the current digit (remainder)	
	addi $t3, $t3, '0'		# add '0' to the digit
	sb $t3, ($t0) 			# write the char
	addi $t0, $t0, -1		# decrement pointer
	bne $a0, $zero, itoa.loop	# loop if not zero
	addi $t0, $t0, 1		# if zero, readjust pointer

	beq $t2, $zero, itoa.return
	addi $t0, $t0, -1
	li $t1, '-'		# load ascii '
	sb $t1, ($t0)
itoa.return:
	move $v0, $t0	
	jr $ra			# return
	
##########################################################
# function: getline
# takes --
# $a0 : source buffer
# returns --
# $v0 : null terminated string or null string if eof
##########################################################
	.data
	
getline_buffer: .space 128

	.text

getline:
	la $t0, getline_buffer
getline.loop:
	lbu $t1, ($a0) 			# $t1 = *src
	beq $t1, '\0', getline.return	# break if '\0' is encountered
	sb $t1, ($t0)			# *dst = *src
	add $t0, $t0, 1			# dst++
	add $a0, $a0, 1 		# src++
	bne $t1, '\n', getline.loop	# loop if *src != '\n'
getline.return:
	li $t2, '\0'			# load null terminator
	sb $t2, 0($t0)			# write null terminator
	la $v0, getline_buffer		# load buffer pointer
	jr $ra 				# return
