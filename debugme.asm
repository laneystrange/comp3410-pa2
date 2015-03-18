#Aaron Marshall
#1
.data
            welcome:  .asciiz "Welcome to the mysterious MIPS Program\n"
            msg_iterate: .asciiz "Iteration: "
           linebreak: .asciiz "\n"
           
            first:    .word 21
                      .word 14
                      .word 26
                      .word 39        
                      
 .text
            la $a0, welcome #loads welcome message
            jal printstr # jump and load to printstr
    
            la $s0, first #loads s0 with array
           # ori $s4, 0x0  # no idea what this is for
           add $s1, $zero, $zero #sets s1 to 0
            
loop: 	    slti $s2, $s1, 4 #counter for array of 4
            beq $s2, $zero, end #if loop is done go to end to exit
            lw $s3, 0($s0) #store address of array
            add $t1, $s3, $t1 # just addition to get final result
            add $s0, $s0, 0x4 #increments address
            addi $s1, $s1, 1 # adds 1 to counter
            la $a0, msg_iterate # loads iteration message
            jal printstr #same as above
            
            add $a0, $s1,$zero # loads counter
            jal writeint #ready to print int
           
            la $a0, linebreak # loads linebreak
            jal printstr
            
            j loop #jumps to loop
            
end:        add $a0, $t1, $zero #loads final result
            jal writeint #get ready to print int
            j exit #jump to exit
            
printstr:	li $v0, 4 # print string
		syscall
		jr $ra #jumps back
writeint:	li $v0, 1 # print int
		syscall
		jr $ra #jumps back
exit:		li $v0, 10 #exit
		syscall
