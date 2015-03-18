# COMP3410 I/O Primer (Part 2)
# Author: Kieran Blazier
# Assignment: PA[2]
# Date: 3/18/15

# part2.asm
# Input: Text file with 1 integer per line
# Output: Sorted input text
	
	.include "macros.asm"

	.data

fnf:	.ascii  "The file was not found: "
input:	.asciiz "PA2_input1.txt"
output: .asciiz "PA2_output1.txt"
newline: .asciiz "\n"
buffer: .space 256

array: 	.align 2 
	.space 256
size: .word 0

	.text
	
main:	
	la $a0, input		# load the file name
	li $a1, 0		# open as read-only
	li $a2, 0		# (ignored)
	open
	move $s6, $v0		# save the file descriptor
	blt $v0, 0, err		# handle the error
	move $a0, $s6		# pass the file descriptor
	la $a1, buffer		# pass the buffer
	li $a2, 256		# pass the buffer length
	read
	
	la $s0, buffer 		# init buffer pointer
	la $s1, array 		# init array pointer
	li $s2, 0		# init size counter
loop_0:
	move $a0, $s0		# pass the buffer pointer
	jal getline		# call getline
	beq $v0, $zero, end_0	# if $v0 == 0 then we encountered eof, break out
	move $a0, $s0		# pass the buffer pointer
	move $a1, $v0		# pass the line length
	add $s0, $s0, $v0	# move the buffer pointer along
	jal atoi		# call atoi
	sll $s3, $s2, 2		# calculate the array offset*
	add $s3, $s3, $s1	# *
	sw $v0, ($s3)		# store the value 
	
	add $s2, $s2, 1		# advance the array size
	b loop_0		# repeat
end_0:	
	move $a0, $s6		# pass the file descriptor
	close			# close the input file
	sw $s2, size		# update the size variable
	
	move $a0, $s1		# pass the array pointer
	move $a1, $s2		# pass the size
	jal selection_sort	# sort the array
	
	la $s0, buffer 		# init buffer pointer
				# array already in $s1
	li $s2, 0		# init loop counter
	lw $s4, size		# grab size
	li $s5, 0x0A		# load a newline char
loop_3:
	sll $s3, $s2, 2		# calculate $s2 * 4
	add $s3, $s3, $s1	# array + $s2 * 4
		
	lw $a0, ($s3)		# $a0 = array[$s2]
	move $a1, $s0
	jal itoa
	
	add $s0, $s0, $v0
	add $s0, $s0, 1
	sb $s5, ($s0)
	
	add $s2, $s2, 1
	blt $s2, $s4, loop_3
	
	li $s5, 0x0
	add $s0, $s0, 1
	sb $s5, ($s0)
	
	la $a0, output		# load the file name
	li $a1, 1		# open as write-only
	li $a2, 0		# (ignored)
	open
	move $s6, $v0		# save the file descriptor
	blt $v0, 0, err		# handle the error
	move $a0, $s6		# pass the file descriptor
	la $a1, buffer		# pass the buffer
	li $a2, 256		# pass the buffer length
	write
	
	move $a0, $s6
	close
	
	exit

##########################################################
# function: getline
# takes --
# $a0 : address of string
# returns --
# $v0 : length of the first line, returns zero if eof
##########################################################	
getline:
	li $v0, 0 			# init length counters
loop_1:
	lbu $t1, ($a0) 			# $t1 = *src
	beq $t1, 0x0, getline_return	# break if \0 is encountered
	add $v0, $v0, 1 		# size++
	add $a0, $a0, 1 		# src++
	bne $t1, 0x0A, loop_1		# loop if *src != '\n'
getline_return:
	jr $ra 				# return
	
	
	
##########################################################
# function: atoi
# takes --
# $a0 : address of string to parse
# $a1 : length of the string
# returns --
# $v0 : integer value
##########################################################
atoi:	
	sub $t0, $a1, 1 	# init loop counter to size - 1 because we want the last index
	li $t2, 1 		# init place value
	li $v0, 0		# init result
loop_2:	
	add $t1, $a0, $t0	# compute the address of the next char
	lbu $t1, ($t1)		# load the char
	beq $t1, 0x2D, end_2 	# goto end_2 if '-' is encountered
	blt $t1, 0x30, skip_0	# if it's not numeric, skip it
	sub $t1, $t1, 0x30 	# subtract '0' from the character
	mul $t1, $t1, $t2	# multiply by the place value
	add $v0, $v0, $t1	# add to the result
	mul $t2, $t2, 10	# multiply the place by 10
skip_0:	
	sub $t0, $t0, 1		# decrement the loop counter
	bge $t0, $zero, loop_2	# if the index is greater than or equal to zero, loop
	jr $ra			# return
end_2:
	mul $v0, $v0, -1	# negate the result
	jr $ra			# return
	
##########################################################
# function: itoa
# takes --
# $a0 : integer value
# $a1 : pointer to buffer
# returns --
# $v0 : length of result
##########################################################
itoa:	
	li, $t0, 10		# store constant 10 for div
	slti $t3, $a0, 0 	# store the sign
	move, $t1, $a0		# store the number
	
	li $v0, 0		# initialize the length
	beq $t3, 0, loop_4	# positive, begin loop
	mul $t1, $t1, -1	# else, negate and begin loop
loop_4:	
	div $t1, $t0		# divmod the argument
	mflo $t1		# get the quotient
	mfhi $t2		# get the current digit (remainder)
	add $t2, $t2, 0x30	# add '0' to the digit
	addi $sp, $sp, -1 	# reserve one byte on the stack
	sb $t2, ($sp) 		# push the char
	add $v0, $v0, 1		# length++
	bne $t1, $zero, loop_4  # loop while quotient != 0
	
	bne $t3, 1, skip_5
	li $t2, 0x2D		# load ascii '-'
	addi $sp, $sp, -1 	# reserve one byte on the stack
	sb $t2, ($sp) 		# push the minus
	add $v0, $v0, 1		# length++
skip_5:
	li $t0, 0		# inti loop counter i
loop_5:
	lbu $t1, ($sp)		# pop the char
	add $sp, $sp, 1		# release 1 byte on the stack
	sll $t2, $t0, 2		# i * 4
	add $t2, $t2, $a1	# array + i * 4	
	sb $t1, ($t2)		# array[i] = the char
	add $t0, $t0, 1		# i++
	blt $t0, $v0, loop_5	# loop if i < length
	
	jr $ra			# return
	
##########################################################
# function: selection_sort
# takes --
# $a0 : address of word array to sort
# $a1 : length of array
# returns --
# void
##########################################################	
selection_sort:
	li $t0, 0	# init loop counter j
outer:
	bge $t0, $a1, skip_4	# break if j >= length
	move $t2, $t0		# min index = j
	sll $t3, $t2, 2		# compute j * 4
	add $t3, $t3, $a0	# array + j * 4
	lw $t3, ($t3)		# min = array[j]
	
	move $t4, $t0		# init loop counter i to j
	add $t4, $t4, 1		# i = j + 1
inner:
	bge $t4, $a1, skip_2	# break if i >= length
	sll $t5, $t4, 2		# compute i * 4
	add $t5, $t5, $a0	# array + i * 4
	lw $t5, ($t5)		# $t5 = array[i]
	
	bge $t5, $t3, skip_1	# goto skip_1 if !($t5 < $t3)
	move $t3, $t5		# min = array[i]
	move $t2, $t4		# min index = i
	
skip_1:
	add $t4, $t4, 1		# i++
	b inner			# repeat
skip_2:	
	
	beq $t0, $t2, skip_3
	sll $t4, $t0, 2		# compute j * 4
	add $t4, $t4, $a0	# array + j * 4
	lw $t5, ($t4)		# $t5 = array[j]
	sw $t3, ($t4)		# array[j] = min
	sll $t2, $t2, 2		# compute min index * 4
	add $t2, $t2, $a0	# array + min index * 4
	sw $t5, ($t2)		# array[min index] = array[j]
skip_3:
	add $t0, $t0, 1 	# j++
	b outer			# repeat
skip_4:
	jr $ra 			# return

err:	
	la	$a0, fnf	# load error string
	print_str
	exit
