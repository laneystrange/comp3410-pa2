# COMP3410
# Author: Michael Vance
# Assignment: PA[2]
# Date: 3/14/2015

# partOne.asm

.data
            welcome:  .asciiz "Welcome to the mysterious MIPS Program\n"
            msg_iterate: .asciiz "Iteration: "
           linebreak: .asciiz "\n"
           
            first:    .word 21
                      .word 14
                      .word 26
                      .word 39        
                      
 .text
            la $a0, welcome
            jal printstr
    
            la $s0, first
            ori $s4, 0
            move $s1, $zero
            
            li $t0, 3
loop:	slt $s2, $s1, $t0
            beq $s2, $zero, end
            lw $s3, 0($s0)
           
            add $s4, $s4, $s3
            add $s0, $s0, 4
            addi $s1, $s1, 1
            la $a0, msg_iterate
            jal printstr
            
            move $a0, $s1
            jal printint
           
            la $a0, linebreak
            jal printstr
            
            j loop
            
end:	move $a0, $s4
            jal printint
            j exit
            
printstr:	li $v0, 4
		syscall
		jr $ra
printint:	li $v0, 1
		syscall
		jr $ra

exit:	li $v0, 10
	syscall
