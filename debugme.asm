.data
            welcome:  .asciiz "Welcome to the mysterious MIPS Program\n"
            msg_iterate: .asciiz "Iteration: "
           linebreak: .asciiz "\n"
           
            first:    .word 21
                      .word 14
                      .word 26
                      .word 39        
                      
 .text
            la $a0, welcome #initially loaded welcome into $v0 instead of $a0--loads welcome message
            jal printstr #prints string loaded into $a0   
            la $s0, first #loads address of first
            #removed two unnecessary lines, one of which made the program uncompilable
            li $s2, 4 #loop counter
            
loop:	    slti $s2, $s1, 0x04 #was four, needed to be three
            beq $s2, $zero, end #when $s1 is 4, $s2 becomes zero ending the program
            lw $s3, 0($s0) #load first value of array in memory address in $s0 into save register 3
 
            add $s4, $s4, $s3 #adds value in $s3 to $s4, saves in $s4
            add $s0, $s0, 0x4 #increments memory address in $s0 by 4 (one word)
            addi $s1, $s1, 1 #increments value of $s1, which holds the value of the current iteration
            la $a0, msg_iterate #next two lines print "Iteration: "
            jal printstr
            
            move $a0, $s1 #next two lines print value of current iteration
            jal writeint
           
            la $a0, linebreak #next two lines print a linebreak
            jal printstr
            
            
            j loop #immediate jump back to the start of loop
            
end: 	    move $4, $20 #next two lines write out the final sum (move $s4 to $a0, print out the int)
            jal writeint
            j exit #immediate jump to exit
            
writeint:	li $v0, 1 #prints int in $a0, jumps back to return address
		syscall
		jr $ra
            
printstr:	li $v0, 4 #prints string in $a0, jumps back to return address
		syscall
		jr $ra
		
exit:		li $v0, 10 #exits
		syscall
