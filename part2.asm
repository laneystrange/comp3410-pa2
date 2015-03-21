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
ferr: .ascii "Error writing to: "
output: .asciiz "PA2_output1.txt"
newline: .asciiz "\n"

buffer: .space 256

array: 	.align 2 
	.space 256
size: .word 0

	.text
	
main:		
	la $a0, input		# load the input file name file 
	li $a1, 0		# open as read-only
	li $a2, 0		# (ignored)
	open
	
	bltz $v0, input_err	# handle any errors
	
	move $s6, $v0		# save the file descriptor
	
	move $a0, $s6		# pass the file descriptor
	la $a1, buffer		# pass the buffer
	li $a2, 256		# pass the buffer length
	read
	
	la $s0, buffer 		# init buffer pointer
	la $s1, array 		# init array pointer
	li $s2, 0		# init size counter
	
input.loop:
	move $a0, $s0		# pass the buffer pointer
	jal getline		# call getline
	move, $s3, $v0		# save the string
	
	lb $t0, 0($v0)		# *check for null string
	beqz $t0, input.end	# *
	
	move $a0, $s3		# pass the string
	jal atoi		# call atoi
	
	sw $v0, 0($s1)		# write the result to the array
	
	move $a0, $s3		# pass the string
	jal strlen		# call strlen
	
	add $s0, $s0, $v0	# advance the buffer pointer
	add $s1, $s1, 4		# advance the array pointer
	add $s2, $s2, 1		# increment the size
	
	j input.loop
input.end:
	move $a0, $s6		# pass the file descriptor
	close			# close the input file
	sw $s2, size		# write the size
	
	la $a0, array		# pass the array
	lw $a1, size		# pass the length
	jal selection_sort	# sort the array
	
	
	la $s0, buffer		# load the buffer pointer
	la $s1, array		# load the array pointer
	li $s2, 0		# init the index
	lw $s3, size		# load the size of the array
output.loop:
	sll $t0, $s2, 2		# i * 4
	add $t0, $t0, $s1	# array + i * 4
	lw $t0, 0($t0)		# array[i]
	
	move $a0, $t0		# pass array[i]
	jal itoa		# convert to string
	
	move $a0, $v0		# *write the string
	move $a1, $s0		# *
	jal strcopy		# *
	
	add $s0, $s0, $v0	# move the buffer pointer along by bytes written
	
	la $a0, newline		# *write newline
	move $a1, $s0		# *
	jal strcopy		# *
	
	add $s0, $s0, $v0	# move the buffer pointer along by bytes written
	
	add $s2, $s2, 1		# increment the index
	blt $s2, $s3, output.loop	# loop while less than array length
	
	la $t0, buffer		# *compute the length of the written string
	sub $t0, $s0, $t0	# *
	
	la $a0, output		# load the output file name file 
	li $a1, 1		# open as write-only
	li $a2, 0		# (ignored)
	open
	
	bltz $v0, output_err	# handle any errors
	
	move $s6, $v0		# save the file descriptor
	
	move $a0, $s6		# pass the file descriptor
	la $a1, buffer		# pass the buffer
	move $a2, $t0		# pass the buffer length
	write
	
	move $a0, $s6		# pass the file descriptor
	close			# close the output file
	
	exit
	
input_err:	
	la	$a0, fnf	# load error string
	print_str
	exit
	
output_err:	
	la	$a0, ferr	# load error string
	print_str
	exit
	

	
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
selection_sort.outer:
	bge $t0, $a1, skip_4	# break if j >= length
	move $t2, $t0		# min index = j
	sll $t3, $t2, 2		# compute j * 4
	add $t3, $t3, $a0	# array + j * 4
	lw $t3, ($t3)		# min = array[j]
	
	move $t4, $t0		# init loop counter i to j
	add $t4, $t4, 1		# i = j + 1
selection_sort.inner:
	bge $t4, $a1, skip_2	# break if i >= length
	sll $t5, $t4, 2		# compute i * 4
	add $t5, $t5, $a0	# array + i * 4
	lw $t5, ($t5)		# $t5 = array[i]
	
	bge $t5, $t3, skip_1	# goto skip_1 if !($t5 < $t3)
	move $t3, $t5		# min = array[i]
	move $t2, $t4		# min index = i
	
skip_1:
	add $t4, $t4, 1		# i++
	b selection_sort.inner	# repeat
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
	b selection_sort.outer	# repeat
skip_4:
	jr $ra 			# return	
