#Justin Hiller
#Comp 3410
#Programming Assignment 2
#Debugme.asm

.data
            welcome:  .asciiz "Welcome to the mysterious MIPS Program\n"
            msg_iterate: .asciiz "Iteration: "
           linebreak: .asciiz "\n"
           
            first:    .word 21
                      .word 14
                      .word 26
                      .word 39        
                      
 .text
            la $a0, welcome	#Changed to $a0 
            jal printstr	#Prints 
    
            la $s0, first	#Loads "first"
            ori $s4, 0x0
            move $s1, $zero
            
loop: 	    slti $s2, $s1, 0x04		#Changed slt to slti
            beq $s2, $zero, end
            lw $s3, 0($s0)
           
            add $s4, $s4, $s3
            add $s0, $s0, 0x4
            addi $s1, $s1, 1
            la $a0, msg_iterate		#Prints the iteration
            jal printstr
            
            move $a0, $s1
            jal printInt		# changed to print the integer
           
            la $a0, linebreak		#New Line
            jal printstr
            
            j loop			#Continues loop
            
end:        move $a0, $s4	#Changed the locations 
            jal printInt	#Changed to printInt
            j _exit

printInt:	li $v0, 1	#Added method to print the integer
		syscall
		jr $ra
            
printstr:	li $v0, 4	#Prints the message
		syscall
		jr $ra

_exit:		#added exit
