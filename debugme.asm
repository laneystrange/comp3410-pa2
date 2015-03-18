#Ben Murphy
#COMP 3410 PA2
#Part 1 - debugme.asm

.data
            welcome:  .asciiz "Welcome to the mysterious MIPS Program\n"
            msg_iterate: .asciiz "Iteration: "
            sumtext: .asciiz "Sum is: "
           linebreak: .asciiz "\n"
          
            first:    .word 21, 14, 26, 39  
                     
 .text
            la $a0, welcome    	# change from v0 to a0
            jal printstr
   
            la $s0, first		# load the address of the first number
            ori $s4, 0			# It's there for safety, might as well keep it. s4 is the running total
            move $s1, $zero	# similarly
           
loop:     slti $s2, $s1, 4    	# changed to slti, we're looping 4 times, not 3 (since the program wants to start by adding the first number to zero)
            beq $s2, $zero, end
            lw $s3, 0($s0)		# load the number to be added
          
            add $s4, $s4, $s3	# add to running total
            addi $s0, $s0, 4    	# no need to use hex, also this should be addi?
            addi $s1, $s1, 1	# increment iterator
            la $a0, msg_iterate	# load iteration message
            jal printstr
           
            move $a0, $s1		# load iteration number
            jal printint    		# using printstr here breaks it, since we load an int to a0
          
            la $a0, linebreak
            jal printstr
           
            j loop
           
end:	la $a0, sumtext    #can't go wrong with a bit of flavor
	jal printstr
        move $a0, $s4    		#getting rid of those ugly register numbers in favor of names
        jal printint
        j _exit
           
printstr:	li $v0, 4
        	syscall
        	jr $ra
       
#added
printint:	li $v0, 1
        	syscall
        	jr $ra

#added
_exit:   	 li $v0, 10
    		syscall
