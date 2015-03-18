.data
            welcome:  .asciiz "Welcome to the mysterious MIPS Program\n"
            msg_iterate: .asciiz "Iteration: "
           linebreak: .asciiz "\n"
           
            first:    .word 21
                      .word 14
                      .word 26
                      .word 39        
                      
 .text
            la $a0, welcome	# FIXED load the welcome message into a0 instead of v0
            jal printstr	# do the print message stuff
    
            la $s0, first	# load the first word into s0
            ori $s4, 0x0	# superfluous
            move $s1, $zero	# set s1 to zero
            
loop: 	slti $s2, $s1, 4	# FIXED replaced slt with slti and 0x03 with 4, this will set s2 to 1 because s1 (= 0) is less than 3
            beq $s2, $zero, end	# This will cause the loop to run 4 times total, then jump to end
            lw $s3, 0($s0)	# load into s3 the value 21, the first word
           
            add $s4, $s4, $s3	# This should be the negative value + s3, not an overflow error
            add $s0, $s0, 0x4	# This should go to the next word address, which is for the 14
            addi $s1, $s1, 1	# This should add one to s1
            la $a0, msg_iterate # Will load msg_iterate as the argument to...
            jal printstr	# print the message
            
            move $a0, $s1	# this will move the what I assume is an iterator to the argument
            #jal printstr	# FIXED, is an int, so need to use print int, replacing it below... print it as a string
            li	$v0, 1		# We're gonna print int
            syscall		# print
            
           
            la $a0, linebreak	# load the address of linebreak
            jal printstr	# print the linebreak
            
            j loop	
            
end: move $4, $20
            #jal writeint
            #j _exit		# FIXED, replaced with just the same things that would have been in those functions
            li	$v0, 1		# Tell it we're printing an int
            syscall
            li	$v0, 10
            syscall		# exit

printstr:	li $v0, 4
		syscall
		jr $ra
