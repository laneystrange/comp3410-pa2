# Claire Skaggs
# COMP 3410
# Programming Assignment 2
# Part Two

.data
		.align 2
array:		.space 1024
input_buffer:	.space 1024
output_buffer:	.space 1024
input_file:	.asciiz "PA2_input1.txt"
output_file:	.asciiz "PA2_output1.txt"

.text
main:
li $v0, 13			# store the integer value for open file, 13, into $v0
la $a0, input_file		# load the 'input_file' memory address into $a0
li $a1, 0			# store the integer value for the read-only flag into $a1
li $a2, 0
syscall				# issue the open file syscall
move $s6, $v0			# move the file descriptor from $v0 into $s6

li $v0, 14			# store the integer value for read file, 14, into $v0
move $a0, $s6			# move the file descriptor from $s6 into $a0
la $a1, input_buffer		# load the 'input_buffer' memory address into $a1
li $a2, 1024			# load the 'input_buffer' size into $a2
syscall				# issue the read file syscall

li $v0, 16			# store the integer value for close file, 15, into $v0
move $a0, $s6			# move the file descriptor from $s6 into $a0
syscall				# issue the close file syscall

la $a0, input_buffer		# store the memory address of 'input_buffer' into $a0
la $a1, array			# store the memory address of 'array' into $a1
jal ttoz			# jump to the 'ttoz' function then return
jal atoi			# jump to the 'atoi' function then return
move $s0, $v1			# store the number of integers in the array to $s0 

move $a0, $s0			# store the number of integers in the array to $a0
jal ttoz			# jump to the 'ttoz' function then return
jal sort			# jump to the 'sort' function then return

la $a0, array			# store the memory address of 'array' into $a0
move $a1, $s0			# store the number of integers in the array to $a1
la $a2, output_buffer		# store the memory address of 'output_buffer' into $a0
jal ttoz			# jump to the 'ttoz' function then return
jal itoa			# jump to the 'itoa' function then return

li $v0, 13			# store the integer value for open file, 13, into $v0
la $a0, output_file		# load the 'output_file' memory address into $a0
li $a1, 1			# store the integer value for the wri flag into $a1
li $a2, 0
syscall				# issue the open file syscall
move $s7, $v0			# move the file descriptor from $v0 into $s7

li $v0, 15			# store the integer value for write to file, 15, into $v0
move $a0, $s7			# move the file descriptor from $s7 into $a0
la $a1, output_buffer  		# load the 'output_buffer' memory address into $a1
li $a2, 1024			# load the 'output_buffer' size into $a2
syscall 			# issue the write to file syscall

exit:
li $v0, 10			# store the integer value for exit, 10, into $v0
syscall				# issue the exit syscall

##################################################################
# atoi - converts ASCII values to Integer values and stores them #
##################################################################
# ARGUMENTS:							 #
# $a0 = memory address of the buffer				 #
# $a1 = memory address of the array				 #
# RETURNS:							 #
# $v0 = the array of converted integers to be returned		 #
# $v1 = the number of integers in the array to be returned	 #
##################################################################
atoi:
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
jr $ra				# return to the line where the 'atoi' function was called

##################################################################
# itoa - converts Integer values to ASCII values and stores them #
##################################################################
# ARGUMENTS:							 #
# $a0 = memory address of the array of integers to convert	 #
# $a1 = number of integers stored in the array $a0		 #
# $a2 = memory address of the space to place the result integers #
##################################################################
itoa:
move $t0, $a0			# copy the memory address of the integer array $a0 into $t0

itoa_begin:
move $t1, $zero			# make sure $t1 is 0
lw $t1, 0($t0)			# load the first integer from the array
move $t2, $zero			# $t2 is the magnitude counter, reset it to 0
addi $t2, $t2, 1		# $t2 is the magnitude counter, initalize it to 1
move $t3, $zero			# make sure $t3 is 0
move $t3, $t1			# copy the value of $t1 into $t3 so it its magnitude may be found without altering it
j itoa_mag			# call the 'itoa_mag' function to set the magnitude counter correctly

itoa_mag:
div $t3, $t3, 10		# divide the integer value stored in $t3 by ten
beq $t3, $zero, itoa_neg	# if the integer is now < 10, jump to 'itoa_neg', else continue
addi $t2, $t2, 1		# increment the magnitude counter by 1
j itoa_mag			# loop until its magnitude is counted

itoa_neg:
move $t3, $zero			# set $t3 back to 0
move $t4, $zero			# set $t4 back to 0
move $t5, $zero			# set $t4 back to 0
move $t4, $t2			# save a copy of the magnitude counter $t2 into $t4 for 'itoa_exp' function
li $t5, 1			# store the value of 1 into $t5 for 'itoa_exp' function
bgt $t1, -1, itoa_exp		# if $t1 > -1, jump to 'itoa_exp', else continue
addi $t3, $t3, '-'		# store the negative sign character to $t3
sb $t3, 0($a2)			# store the negative sign character in $t3 to the buffer $a2
addi $a2, $a2, 1		# shift the buffer memory address in $a2 forward 1 byte
mul $t1, $t1, -1		# the negative sign is already written to the buffer, so make $t1 postive
move $t3, $zero			# set $t3 back to 0

itoa_exp:
beqz $t4, itoa_loop		# if $t4, a copy of the magnitude counter = 0, then jump to 'itoa_loop' else continue.
mul $t5, $t5, 10		# repeatly multiply 10 times itself, storing that into result to $t5
addi $t4, $t4, -1		# decrement the magnitude counter copy
j itoa_exp			# loop until the value of $t5 is the proper value

itoa_loop:
beqz $t2, itoa_store		# if the magnitude counter = 0, then jump to 'itoa_store', else continue
move $t7, $zero			# set $t7 to zero
div $t1, $t5			# $t1 / 10 ^ magnitude counter
mflo $t1			# store $t1 % 10 ^ magnitude counter result into $t1
mfhi $t7			# store $t1 / 10 ^ magnitude counter result into $t7
addi $t7, $t7, 0x30		# convert this value from integer to ASCII
sb $t7, 0($a2)			# store this converted value from $t7 to the current byte of the buffer, $a2
addi $a2, $a2, 1		# shift the buffer memory address in $a2 forward 1 byte
addi $t2, $t2, -1		# decrement the magnitude counter by -1
j itoa_loop			# make another pass until we run out of magnitude counter

itoa_store:
addi $t1, $t1, 0x30		# convert this value from integer to ASCII
sb $t1, 0($a2)			# store this converted value from $t1 to the current byte of the buffer, $a2
addi $a2, $a2, 1		# shift the buffer memory address in $a2 forward 1 byte
move $t1, $zero			# make sure $t1 is zero
addi $t1, $t1, 10		# add the ASCII value for the newline character to $t1
sb $t1, 0($a2)			# store this newline character from $t1 to the current byte of the buffer, $a2
addi $a2, $a2, 1		# shift the buffer memory address in $a2 forward 1 byte
addi $a1, $a1, -1		# decrement the number of integers left by 1
beq $a1, 0, itoa_end		# if we are out of integers, jump to 'itoa_end', otherwise continue
j itoa_begin

itoa_end:
move $t1, $zero			# make sure $t1 is 0
addi $t1, $t1, 0		# add the ASCII value for the null terminator chracter to $t1
sb $t1, 0($a2)			# store this newline character from $t1 to the current byte of the buffer, $a2
jr $ra				# return to the line where the 'itoa' function was called

##################################################################
# sort - bubblesorts the integers in the argument array		 #
##################################################################
# ARGUMENTS:							 #
# $a0 = number of integers to sort				 #
##################################################################
sort:
la $t0, array 			# load the memory address of the 'array' in $t0
mul $t7, $a0, 4			# multiply the number of integers by 4 to find the total number of bytes
add $t0, $t0, $t7 		# sets $t0 to $t0 added to the total number of bytes

sort_outer_loop:
add $t1, $0, $0			# when $t1 = 1 the list is sorted
la $a0, array 			# load the memory address of 'array' in $a0

sort_inner_loop:
lw $t2, 0($a0) 			# $t2 = index i of the array
lw $t3, 4($a0) 			# $t3 = index i + 1 of the array
slt $t4, $t3, $t2 		# if $t3 < $t2, then $t4 = 1, else $t4 = 0
beq $t4, $0, sort_swap 		# if $t4 = 0, then jump to 'sort_swap', else continue
add $t1, $0, 1 			# recheck after a swap, so set $t1 to 1
sw $t2, 4($a0)			# $t2 = index i + 1
sw $t3, 0($a0) 			# $t3 = index i

sort_swap:
addi $a0, $a0, 4 		# increment the array by 4 bytes
bne $a0, $t0, sort_inner_loop	# if $a0 is not yet to the end of the array, jump to 'sort_inner_loop'
bne $t1, $0, sort_outer_loop	# if $t1 is 1 the list is not sorted, jump to 'sort_outer_loop'
jr $ra				# return to the line where the 'sort' function was called

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

