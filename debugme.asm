#Will Robb
#pa2-1

.data
            welcome:  .asciiz "Welcome to the mysterious MIPS Program\n"
            msg_iterate: .asciiz "Iteration: "
           linebreak: .asciiz "\n"
           
            first:    .word 21
                      .word 14
                      .word 26
                      .word 39        
                      
 .text
            la $a0, welcome	#fixed v0 to a0
            jal printstr
    
            la $s0, first
            ori $s4, 0x0
            move $s1, $zero
            
loop: 	slti $s2, $s1, 4	#fixed stl to stli and 0x3 to 4
            beq $s2, $zero, end
            lw $s3, 0($s0)
           
            add $s4, $s4, $s3
            add $s0, $s0, 0x4
            addi $s1, $s1, 1
            la $a0, msg_iterate
            jal printstr
            
            move $a0, $s1
            jal printstr
           
            la $a0, linebreak
            #jal printstr	#fixed need to use print int
            li $v0, 1
            syscall
            
            la $a0, linebreak
            jal printstr
            
            j loop
            
end: move $4, $20
            #jal writeint	#fixed 
            #j _exit
            li $v0, 1
            syscall
            li $v0, 10
            syscall
            
printstr:	li $v0, 4
		syscall
		jr $ra
