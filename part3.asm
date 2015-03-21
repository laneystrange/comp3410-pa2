# COMP3410 Linked List (Part 3)
# Author: Kieran Blazier
# Assignment: PA[2]
# Date: 3/18/15

# part3.asm
# Input: Text file defining a linked list
# Output: A file containing the values of the list in order
# and the position where the terminal node was found
	
	.include "macros.asm"

	.data

fnf:	.ascii  "The file was not found: "
input:	.asciiz "list_input.txt"
ferr: .ascii "Error writing to: "
output: .asciiz "list_output.txt"

list_message: .asciiz "Here is my linked list: "
pos_message: .asciiz "The end of the list was found at position "
period: .asciiz "."
arrow: .asciiz " -> "
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
	
	la $s3, buffer		# load the buffer pointer
	
	la $a0, list_message	# *write the list message
	move $a1, $s3		# *
	jal strcopy		# *
	
	add $s3, $s3, $v0	# move the buffer pointer along by bytes written
	
	la $s0, array		# load the array pointer
	move $s1, $zero		# init the index
	move $s2, $zero		# init the previous index
output.loop:
	sll $t0, $s1, 2		# i * 4
	add $t0, $t0, $s0	# array + i * 4
	lw $t0, 0($t0)		# array[i]
	
	add $t1, $s1, 1		# i + 1
	sll $t1, $t1, 2		# (i + 1) * 4
	add $t1, $t1, $s0	# array + (i + 1) * 4
	lw $t1, 0($t1)		# array[i + 1]
	
	move $s2, $s1		# store previous index
	move $s1, $t1		# set the index to the current node's pointer index
	
	move $a0, $t0		# pass array[i]
	jal itoa		# convert to string
	
	move $a0, $v0		# *write the string
	move $a1, $s3		# *
	jal strcopy		# *
	
	add $s3, $s3, $v0	# move the buffer pointer along by bytes written
	
	bltz $s1, output.end	# break if index < 0
	
	la $a0, arrow		# *write arrow
	move $a1, $s3		# *
	jal strcopy		# *
	
	add $s3, $s3, $v0	# move the buffer pointer along by bytes written
	
	j output.loop		# repeat
output.end:
	
	la $a0, period		# *write period
	move $a1, $s3		# *
	jal strcopy		# *
	
	add $s3, $s3, $v0	# move the buffer pointer along by bytes written
	
	la $a0, newline		# *write newline
	move $a1, $s3		# *
	jal strcopy		# *
	
	add $s3, $s3, $v0	# move the buffer pointer along by bytes written
	
	la $a0, pos_message	# *write the position message
	move $a1, $s3		# *
	jal strcopy		# *
	
	add $s3, $s3, $v0	# move the buffer pointer along by bytes written
	
	move $a0, $s2		# pass the terminal index
	jal itoa		# convert to string
	
	move $a0, $v0		# *write the string
	move $a1, $s3		# *
	jal strcopy		# *
	
	add $s3, $s3, $v0	# move the buffer pointer along by bytes written
	
	la $a0, period		# *write period
	move $a1, $s3		# *
	jal strcopy		# *
	
	add $s3, $s3, $v0	# move the buffer pointer along by bytes written
	
	la $t0, buffer		# *compute the string length
	sub $t0, $s3, $t0	# *
	
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
	
	exit			# exit
	
input_err:	
	la	$a0, fnf	# load error string
	print_str
	exit
	
output_err:	
	la	$a0, ferr	# load error string
	print_str
	exit
	