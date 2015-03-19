# Robert L. Edstrom
# COMP3410 PA2
# Part 1a 

.data
            welcome:     .asciiz "Welcome to the mysterious MIPS Program\n"
            msg_iterate: .asciiz "Iteration: "
            linebreak:   .asciiz "\n"
           
            first:    .word 21
                      .word 14
                      .word 26
                      .word 39        
                      
.text
            la $a0, welcome		# Changed because I couldn't get the jal printstr to work so I took the easy route.
            li $v0, 4
            syscall
    
            la $s0, first
            ori $s4, 0x0
            move $s1, $zero
            
            li $s5, 0x4			# Added register $s5 to contain the value 4.
            
loop: 	    slt $s2, $s1, $s5		# Changed 0x03 to register five because slt is a R-Type instruction.
            beq $s2, $zero, end
            lw $s3, 0($s0)
           
            add $s4, $s4, $s3
            add $s0, $s0, 0x4
            addi $s1, $s1, 1
            la $a0, msg_iterate
            jal printstr
            
            move $a0, $s1
            jal writeint		# Changed printstr to writeint because register $a0 contains a integer.
           
            la $a0, linebreak
            jal printstr
            
            j loop
            
end:        move $4, $20
            jal writeint
            j exit
            
printstr:   li $v0, 4
	    syscall
	    jr $ra
	    
writeint:   li $v0, 1			# Added writeint label because it did not exist.
	    syscall
	    jr $ra
	    
exit: 	    li $v0, 10			# Added exit label because it did not exit.
	    syscall
