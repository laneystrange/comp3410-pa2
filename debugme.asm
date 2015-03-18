# COMP3410 Debugme (Part 1)
# Author: Kieran Blazier
# Assignment: PA[2]
# Date: 3/18/15

# debugme.asm
# Input: None
# Output: The sum of the four numbers pointed to by first

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
            
loop:       lw $s3, 0($s0)
           
            add $s4, $s4, $s3
            add $s0, $s0, 0x4
            addi $s1, $s1, 1
            la $a0, msg_iterate
            jal printstr
            
            move $a0, $s1
            jal writeint
           
            la $a0, linebreak
            jal printstr
            
            blt $s1, 0x4, loop
            
end: 	    move $a0, $s4
            jal writeint
            li   $v0, 10 # system call for exit
	    syscall
            
writeint:	li $v0, 1
		syscall
		jr $ra
            
printstr:	li $v0, 4
		syscall
		jr $ra
