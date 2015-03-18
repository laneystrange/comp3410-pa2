#Herve Aniglo
#COMP 3410
#March 18, 2015

.data
            welcome:  .asciiz "Welcome to the mysterious MIPS Program\n"
            msg_iterate: .asciiz "Iteration: "
           linebreak: .asciiz "\n"
           
            first:    .word 21
                      .word 14
                      .word 26
                      .word 39        
                      
 .text
            la $a0, welcome #This was $v0 but I changed it to $a0.
            jal printstr
    
            la $s0, first
            ori $s4, 0x0
            move $s1, $zero
            
loop: 	slti $s2, $s1, 0x04 #This needed to be slti, not slt. I changed 0x03 to 0x04 so they can be added together correctly.
            beq $s2, $zero, end
            lw $s3, 0($s0)
           
            add $s4, $s4, $s3
            addi $s0, $s0, 0x4 #This was supposed to be addi.
            addi $s1, $s1, 1
            la $a0, msg_iterate
            jal printstr
            
            move $a0, $s1
            jal writeint #This was printstr. $s1 does not have a string but an integer. I Changed it to writeint.
           
            la $a0, linebreak
            jal printstr
            
            j loop
            
end:        move $4, $20
            jal writeint #writeint does not exist. I wrote a new call. I removed j _exit and wrote li $v0, 10 and afterwards, I performed a syscall.
            li $v0, 10
            syscall
            
printstr:	li $v0, 4
		syscall
		jr $ra
		
writeint:	li $v0, 1  #I added this in
		syscall 
		jr $ra
		
exit: 	    li $v0, 10			# I Added this so the program would exit correctly.
	    syscall
