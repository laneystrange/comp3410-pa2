.data
            welcome:  .asciiz "Welcome to the mysterious MIPS Program\n"
            msg_iterate: .asciiz "Iteration: "
           linebreak: .asciiz "\n"
           
            first:    .word 21
                      .word 14
                      .word 26
                      .word 39        
                      
 .text
            la $a0, welcome	#Was originally la $v0, welcome
            jal printstr
    
            la $s0, first
            ori $s4, 0x0
            move $s1, $zero
            
loop: 	slti $s2, $s1, 0x04	#Was originally slt $s2, $s1, 0x03
            beq $s2, $zero, end
            lw $s3, 0($s0)
           
            add $s4, $s4, $s3
            addi $s0, $s0, 0x4	#Was originally add $s0, $s0, 0x4
            addi $s1, $s1, 1
            la $a0, msg_iterate
            jal printstr
            
            la $a0, ($s3) 	#Was originally move $a0, $s1
            jal writeint	#Was originally jal printstr
           
            la $a0, linebreak
            jal printstr
            
            j loop
            
end: move $4, $20
            jal writeint
            j _exit
            
            
printstr:	li $v0, 4
		syscall
		jr $ra

writeint:			#Lable needed to be created with its code
	li $v0, 1	#Preps to prints an integer
	syscall		#Prints an integer
	jr $ra		#Jumpts to the return register

_exit:				#Label needed to be created with its code
	li $v0, 10	#Preps to end the program
	syscall		#Ends the program