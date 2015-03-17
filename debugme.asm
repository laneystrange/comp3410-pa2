.data
            welcome:  .asciiz "Welcome to the mysterious MIPS Program\n"
            msg_iterate: .asciiz "Iteration: "
           linebreak: .asciiz "\n"
           
            first:    .word 21
                      .word 14
                      .word 26
                      .word 39        
                      
 .text
            la $a0, welcome		# load welcome message pointer into a0
            jal printstr		# call printstr
    
            la $s0, first		# s0 is pointer to the current value to add
            ori $s4, 0x0		# s4 is current result (0 at this point)
            move $s1, $zero		# s1 is number of iterations (0 at this point)
            
loop: 	slti $s2, $s1, 0x04		# shift left s1 by 3 and put into s2
            beq $s2, $zero, end		# if s2 == 0, jump to end
            lw $s3, 0($s0)		# s3 =  21
           
            add $s4, $s4, $s3		# s4 += s3
            addi $s0, $s0, 0x4		# advance value to add one space forward
            addi $s1, $s1, 1		# s1 += 1
            la $a0, msg_iterate		# la0 = *msg_iterate
            jal printstr		# print it
            
            move $a0, $s1		#  argument = s1
            jal writeint		# print it
           
            la $a0, linebreak		# argument = new line
            jal printstr		# print it
            
            j loop			# jump back up to loop
            
end: move $4, $20			# a0 = $s4
            jal writeint		# write it
            j _exit
            
printstr:	li $v0, 4
		syscall
		jr $ra

writeint:	li $v0, 1
		syscall
		jr $ra
		
_exit:		li $v0, 10
		syscall