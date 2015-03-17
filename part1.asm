.data
            welcome:  .asciiz "Welcome to the mysterious MIPS Program\n"
            msg_iterate: .asciiz "Iteration: "
            linebreak: .asciiz "\n"
           
            first:    .word 21
                      .word 14
                      .word 26
                      .word 39        
                      
 .text
            	la $a0, welcome		# Loads the welcome string into the arguments register.
            	jal printstr		# Prints the string.
    
            	la $s0, first		# Loads the address of our 'first' label
            	ori $s4, 0x0		# Sets $s4 to 0.
            	move $s1, $zero		# Also sets $s1 to zero.
            
loop: 			slti $s2, $s1, 0x04	# Sets $s2 to 1 if $s1, our iterator, is less than 4.
            	beq $s2, $zero, end # If the above isn't true, we go to 'end'.
            	lw $s3, 0($s0)		# Loads the current value of 'first' to $s3
           
            	add $s4, $s4, $s3	# $s4 = $s4 + $s3
            	add $s0, $s0, 0x4	# Moves the address of $s0 forward one word.
            	addi $s1, $s1, 1	# Increments $s1 by 1.
            	la $a0, msg_iterate	# Loads the 'msg_iterate' string into the argument.
            	jal printstr		# Prints the 'msg_iterate' string.
            
            	move $a0, $s1		# Should move $s1, our iteration counter, into the arguments.
            	jal writeint		# Prints the iteration counter.
           
            	la $a0, linebreak	# Loads a linebreak into the arguments.
            	jal printstr		# Prints the linebreak.
            
            	j loop				# Jumps to the 'loop' label.
            
end:			move $a0, $s4 		# Puts the content of $s4, our total register, into arguments.
            	jal writeint			# Prints that integer.
            	j exit				# Exits the program.
            
printstr:		li $v0, 4
				syscall
				jr $ra

writeint:		li $v0, 1			# Loads the 'print integer' value into the syscall args.
				syscall				# Prints the integer in $a0.
				jr $ra				# Returns to where it was called from.

exit:			li $v0, 10
				syscall
