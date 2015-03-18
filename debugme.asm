.data
            welcome:  .asciiz "Welcome to the mysterious MIPS Program\n"
            msg_iterate: .asciiz "Iteration: "
           linebreak: .asciiz "\n"
           
            first:    .word 21
                      .word 14
                      .word 26
                      .word 39        
                      
 .text 
 	    li $v0, 4
            la $a0, welcome #load string adress into $a0
            syscall
            #jal printstr #jumping to printstr and linking $ra
    
            la $s0, first #load adress of first
            ori $s4, 0 #Do nothing if set to 0
            move $s1, $zero #setting $s1 to zero
            
loop: 	slti $s2, $s1, 4 #If $s1 is less than immediate, $s2 is set to one. set to zero otherwise
            beq $s2, $zero, end #checks to see if $s2 is equal to zero and if so jump to end
            lw $s3, 0($s0)
           
            add $s4, $s4, $s3 #$s4 = $s4 + $s3 // adds them together first time is set to 0
            add $s0, $s0, 4 #increment the register by 4 for the next value
            addi $s1, $s1, 1 #increment $s1 as to help stop the loop
            li $v0, 4 #prepare syscall for string value
            la $a0, msg_iterate #load string into adresss
            jal printstr #jump to sysmcall section
            
            li $v0, 1 #prep system for int
            #move $a0, $s1
            add $a0, $zero, $s1 #load int into adresss
            jal printstr #jump to sysmcall section
           
            li $v0, 4 #prep system for string
            la $a0, linebreak #load string into adresss
            jal printstr #jump to sysmcall section
            
            j loop #jump back to the loop
            
end: 		
	    li $v0, 1
	    move $a0, $s4
	    #add $a0, $zero, $s4
            jal printstr
            j _exit
            
printstr:	#li $v0, 4
		syscall
		jr $ra #return to the last linked location

_exit:
