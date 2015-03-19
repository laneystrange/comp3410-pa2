# Claire Skaggs
# COMP 3410
# Programming Assignment 2
# Part Two


##################################################################
# atoi - converts ascii values to integer values and stores them #
##################################################################
# converts ascii values to integer values into an array		 # 
# ARGUMENTS:							 #
# $a0 = memory address of buffer				 #
# $a1 = memory address of array					 #
# RETURNS:							 #
# $v0 = number of integers in array				 #
##################################################################
atoi:
lb $t1, 0($a0)			# $t1 = current char from buffer
move $t3, $zero			# $t3 = order of mag
move $t4, $zero			# $t4 = neg flag
bne $t1, 45, atoi_loop		# if current char != negative sign character, jump to 'atoi_loop'

atoi_neg:
addi $t4, $t4, 1		# neg flag = 1
addi $a0, $a0, 1		# advance the buffer by 1 byte

atoi_loop:
lb $t1, 0($a0)			# $t1 = current char from buffer
beq $t1, 10, atoi_prestore	# if current char == '\n' character, jump to 'atoi_loop'
beq $t1, 0, atoi_prestore	# if current char == null terminator character, jump to 'atoi_loop'
sub $t1, $t1, '0'		# converts current char to a decimal value
mul $t3, $t3, 10		# order of mag = order of mag * 10
add $t3, $t3, $t1		# $t3 = order of mag * 10 + current char
addi $a0, $a0, 1		# advance the buffer by 1 byte
j atoi_loop

atoi_prestore:
bne $t4, 1, atoi_store		# if neg flag == 0, then jump to 'atoi_store'
mul $t3, $t3, -1		# multiply the number by -1 to ensure its value is negative when stored

atoi_store:
sw $t3, 0($a1)
addi $a1, $a1, 4		# shift the array address, $a1,  forward by 4 bytes
addi $t2, $t2, 1		# increment the number of integers in the array, $t2, by 1
addi $a0, $a0, 1		# shift the buffer forward by 1 byte
move $t3, $zero			# $t3 = 0
beq $t1, 0, atoi_end		# if current char == null terminator character, then jump to 'atoi_end'
j atoi

atoi_end:
move $v0, $t2			# store the number of integers into $v0 for return
jr $ra				# return to the line where the 'atoi' function was called

##################################################################
# itoa								 #
##################################################################
# converts an array of integer values to ascii values 		 #
# ARGUMENTS:							 #
# $a0 = memory address of array					 #
# $a1 = number of integers in array				 #
# $a2 = memory address of output buffer				 #
##################################################################
itoa:
lw $t0, 0($a0)			# $t0 = current int from array
move $t7, $t0			# $t7 = current int from array
move $t1, $zero			# $t1 = 0
addi $t1, $t1, 1		# $t1 = mag count, initially 1

itoa_mag:
div $t7, $t7, 10		# current int = current int / 10
beq $t7, 0, itoa_sign		# if current int == 0, then jump to 'itoa_sign'
addi $t1, $t1, 1		# mag count = mag count + 1
j itoa_mag

itoa_sign:
move $t7, $zero			# $t7 = 0
bgt $t0, -1, itoa_pos		# if current int > -1, then jump to 'itoa_pos'
addi $t7, $t7, '-'		# $t7 = '-' character
sb $t7, 0($a2)			# store the '-' character to the buffer
addi $a2, $a2, 1		# advance the buffer by 1 byte
mul $t0, $t0, -1		# make the current integer postive now
move $t7, $zero			# $t7 = 0

itoa_pos:
move $t2, $zero			# $t2 = 0
move $t3, $zero			# $t3 = 0
move $t4, $zero			# $t4 = 0
addi $t2, $t2, 10		# $t2 = 10
addi $t3, $t3, 1		# $t3 = 1, will be order of mag
move $t4, $t1			# $t4 = mag count

itoa_exp:
mul $t3, $t3, $t2		# $t3 = order of mag * 10
addi $t4, $t4, -1		# mag count = mag count - 1
bgt $t4, 1, itoa_exp		# if mag count > 1, jump to 'itoa_exp'

itoa_loop:
div $t7, $t0, $t3		# $t7 = left-most digit
mul $t6, $t7, $t3		# $t6 = left-most digit * order of mag
sub $t0, $t0, $t6		# $t0 = integer - (left-most digit * order of mag)
div $t3, $t3, 10		# decrease order of mag by one order
addi $t7, $t7, '0'		# converts the left-most digit to ascii
sb $t7, 0($a2)			# store the converted left-most digit to the buffer
addi $a2, $a2, 1		# advance the buffer by 1 byte
bne $t3, 0, itoa_loop		# if order of mag != 0, then jump to 'itoa_loop'

itoa_newline:
move $t7, $zero 		# $t7 = 0
addi $t7, $t7, 10		# $t7 = '\n' character
sb $t7, 0($a2) 			# store the '\n' character to the buffer
addi $a2, $a2, 1		# advance the buffer by 1 byte
addi $a1, $a1, -1		# num of ints = num of ints - 1
beqz $a1, itoa_null		# if num of ints == 0, then jump to 'itoa_null'
addi $a0, $a0, 4		# advance the array by 4 bytes
j itoa

itoa_null:
move $t7, $zero 		# $t7 = 0
addi $t7, $t7, 0		# $t7 = null terminator character
sb $t7, 0($a2) 			# store the null terminator character to the buffer
jr $ra				# return to the line where the 'itoa' function was called

##################################################################
# temp0								 #
##################################################################
# Zeros out all temporary register values			 #
##################################################################
temp0:
move $t1, $zero			# set $t1 to zero
move $t2, $zero			# set $t2 to zero
move $t3, $zero			# set $t3 to zero
move $t4, $zero			# set $t4 to zero
move $t5, $zero			# set $t5 to zero
move $t6, $zero			# set $t6 to zero
move $t7, $zero			# set $t7 to zero
jr $ra				# return to the line where the 'ttoz' function was called