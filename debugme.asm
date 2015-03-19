# Claire Skaggs
# COMP 3410
# Programming Assignment 2
# Part One

.data
welcome:	.asciiz "Welcome to the mysterious MIPS Program\n"
msg_iterate:	.asciiz "Iteration: "
linebreak:	.asciiz "\n"
first:		.word 21
		.word 14
		.word 26
		.word 39
		
 .text
 la $a0 welcome		# load the 'welcome' string's memory address into register $a0
 jal printstr		# jump to the 'printstr' function and save the return address
 
 la $s0, first		# load the 'first' array's memory address into register $s0
 ori $s4, 0		# store the value of 0 into register $s4
 move $s1, $zero	# store the value of 0 into register $s1
 
 loop:
 slti $s2, $s1, 4	# if s1 < 4, then $s2 = 1, else $s2 = 0
 beq $s2, $zero, end	# if $s2 = 0, then jump to 'end' function, else continue
 
 lw $s3, 0($s0)		# loads the value currently at the start of the 'first' array's memory address into register $s3
 add $s4, $s4, $s3	# s4 = $s4 + $s3
 
 addi $s0, $s0, 4	# shifts the 'first' array's memory address forward by one word
 addi $s1, $s1, 1	# $s1 = $s1 + 1; as $s1 is acting as the loop counter
 
 la $a0 msg_iterate	# load the 'msg_iterate' string's memory address into register $a0
 jal printstr		# jump to the 'printstr' function and save the return address
 
 move $a0, $s1		# store the current value of register $s1 into $a0
 jal writeint		# jump to the 'writeint' function and save the return address
 
 la $a0, linebreak	# load the 'linebreak' string's memory address into register $a0
 jal printstr		# jump to the 'printstr' function and save the return address
 
 j loop			# jump to the 'loop' function
 
 end:
 move $a0, $s4		# store the current value of register $s4 into $a0
 jal writeint		# jump to the 'writeint' function and save the return address
 j exit			# jump to the 'exit' function
 
 printstr:
 li $v0, 4		# store the print string syscall argument value, 4, into register $v0
 syscall		# issues the syscall which prints the string stored in register $a0
 jr $ra			# jump to the return address where the function was called
 
 writeint:
 li $v0, 1		# store the print integer syscall argument value, 1, into register $v0
 syscall		# issue the syscall which prints the integer stored in register $a0
 jr $ra			# jump to the return address where the function was called
 
 exit:
 li $v0, 10		# store the exit syscall argument value, 10, into register $v0
 syscall		# issue the syscall which exits the program