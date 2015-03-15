.data
            welcome:  .asciiz "Welcome to the mysterious MIPS Program\n"
            msg_iterate: .asciiz "Iteration: "
           linebreak: .asciiz "\n"

            first:    .word 21
                      .word 14
                      .word 26
                      .word 39

 .text
            la $a0, welcome   		#Change the register $v0 to $a0
                              		#$v0 is used for system calls (error 1)
            jal printstr

            la $s0, first
            ori $s4, 0x0
            move $s1, $zero
            
            li $s5, 0x4			# Added register $s5 to contain the value 4.

loop: 	slt $s2, $s1, $s5 		#if $s2 is less than $t3 then set $t1 to 1 else set it to 0(error 2)
            beq $s2, $zero, end
            lw $s3, 0($s0)

            add $s4, $s4, $s3
            add $s0, $s0, 0x4
            addi $s1, $s1, 1
            la $a0, msg_iterate
            jal printstr

            move $a0, $s1
            jal writeint		#$a0 containt a int

            la $a0, linebreak
            jal printstr

            j loop

end: move $4, $20
            jal writeint
            j exit  			#matching the labels

printstr:	li $v0, 4
		      syscall
		      jr $ra
		      
writeint:   li $v0, 1			# Added write Int because it did not exist in the orginal document(error 3)
	    syscall
	    jr $ra
exit: 	    li $v0, 10			# Added the label exit to the documnet since it did not exist and it allows the 
					#program to end and not run continusously(error 4)
	    syscall