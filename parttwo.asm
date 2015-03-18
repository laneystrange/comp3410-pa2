# Claire Skaggs
# COMP 3410
# Programming Assignment 2
# Part Two

.data
		.align 2
array:		.space 1024
input_buffer:	.space 1024
output_buffer:	.space 1024
file_error:	.asciiz "An error has occured. The file could not be found."
input_file:	.asciiz "PA_input1.txt"
output_file:	.asciiz "PA_output1.txt"

.text
main:
jal open
jal read

la $a0, buffer
la $a1, array
jal atoi


open:
li $v0, 13
la $a0, input_file
li $a1, 0
li $a2, 0
syscall
move $s6, $v0
blt $v0, 0, error
jr $ra

read:
li $v0, 14
move $a0, $s6
la $a1, buffer
li $a2, 1024
syscall
jr $ra

write:
li $v0, 13
la $a0, output_file
li $a1, 1
li $a2, 0
syscall
move $s6, $v0
blt $v0, 0, error

close:
li $v0, 16
move $a0, $s6
syscall
jr $ra

##################################################################
# atoi - converts ASCII values to Integer values and stores them #
##################################################################
# $a0 = memory address of the buffer				 #
# $a1 = memory address of the array				 #
# $t0 = memory address of the buffer copy			 #
# $t1 = current byte which $t0 is pointing at			 #
# $t2 = number of integers currently stored in $a1		 #
# $t3 = converted integer to be stored into $a1			 #
# $t4 = negative flag where 0 is postive and 1 is negative	 #
# $v0 = the array of converted integers to be returned		 #
# $v1 = the number of integers in the array to be returned	 #
##################################################################
atoi:
addi $sp, $sp, -4		# shift the stack point forward by 4 bytes
sw $ra, 0($sp)			# store the current return address onto the stack
jal ttoz			# jump to the 'ttoz' function then return
move $t0, $a0			# $t0 is a copy of the buffer memory address in $a0

atoi_begin:
lb $t1, 0($t0)			# $t1 is the current byte of $t0
move $t4, $zero			# $t4 is the negative flag and is set to 0
bne $t1, 45, atoi_loop		# if $t1 does not point to a negative sign (ASCII 45), jump to 'atoi_loop', else continue

atoi_neg:
addi $t4, $t4, 1		# $t4 is the negative flag and is set to 1
addi $t0, $t0, 1		# $t0 is shifted by 1 byte to bypass the negative sign

atoi_loop:
lb $t1, 0($t0)			# $t1 is the current byte of $t0
beq $t1, 10, atoi_prestore	# if $t1 points to a newline feed (ASCII 10), jump to 'atoi_prestore', else continue
beq $t1, 0, atoi_prestore	# if $t1 points to a null terminator (ASCII 0), jump to 'atoi_prestore', else continue
subi $t1, $t1, 0x30		# convert the ASCII value of the character to the decimal
mul $t3, $t3, 10		# for each digit increase the magitute by one order
add $t3, $t3, $t0		# add the converted value of the current byte
addi $t0, $t0, 1		# $t0 is shifted by 1 byte to point to the next character
j atoi_loop			# loop back to gather every digit until $t1 points to either a newline feed or a null terminator

atoi_prestore:
bne $t4, 1, atoi_store		# if $t4 is not flagged, then jump to 'atoi_store', else continue
mul $t3, $t3, -1		# multiply the number by -1 to ensure its value is negative when stored

atoi_store:
sw $t3, 0($a1)			# store the newly converted integer, t3, into memory at array address, $a1
addi $a1, $a1, 4		# shift the array address, $a1,  forward by 4 bytes
addi $t2, $t2, 1		# increment the number of integers in the array, $t2, by 1
addi $t0, $t0, 1		# shift the buffer address copy, $t0,  forward by 1 byte
move $t3, $zero			# set the converted integer, $t3, to 0
beq $t1, 0, atoi_end		# if $t1 points to a null terminator, then jump to 'atoi_end', else continue
j atoi_begin			# start again as we have not yet hit a null terminator

atoi_end:
move $v0, $a1			# store the array address, $a1, to the return address, $v0
move $v1, $t2			# store the number of integers in the array, $t2, to the return address, $v1
addi $sp, $sp, 4		# shift the stack pointer back by 4 bytes
lw $ra, 0($sp)			# load the original return address back into $ra
jr $ra				# return to the line where the 'atoi' function was called

##################################################################
# itoa - converts Integer values to ASCII values and stores them #
##################################################################
# $a0 = memory address of the array				 #
# $a1 = memory address of the output_buffer			 #
# $t0 = memory address of the buffer copy			 #
# $t1 = current byte which $t0 is pointing at			 #
# $t2 = number of integers currently stored in $a1		 #
# $t3 = converted integer to be stored into $a1			 #
# $t4 = negative flag where 0 is postive and 1 is negative	 #
# $v0 = the array of converted integers to be returned		 #
# $v1 = the number of integers in the array to be returned	 #
##################################################################

##################################################################
# ttoz - zeros out all temporary register values		 #
##################################################################
ttoz:
move $t1, $zero			# set $t1 to zero
move $t2, $zero			# set $t2 to zero
move $t3, $zero			# set $t3 to zero
move $t4, $zero			# set $t4 to zero
move $t5, $zero			# set $t5 to zero
move $t6, $zero			# set $t6 to zero
move $t7, $zero			# set $t7 to zero
jr $ra				# return to the line where the 'ttoz' function was called

error:
li $v0, 4			# stores syscall print string value, 4, into $v0
la $a0, file_error		# loads the memory address of the 'file_error' string into $a0
syscall				# issues syscall to print string
j exit				# jump to the 'exit' function

exit:
li $v0, 10			# stores syscall exit program value, 10, into $v0
syscall				# issues syscall to exit the program

