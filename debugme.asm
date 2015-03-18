#Enyil Padilla
.data
            welcome:  .asciiz "Welcome to the mysterious MIPS Program\n"
            msg_iterate: .asciiz "Iteration: "
           linebreak: .asciiz "\n"
           
            first:    .word 21
                      .word 14
                      .word 26
                      .word 39        
                      
 .text
            la $a0, welcome #$v0 = "Welcome...." #modified
            jal printstr #prints
    
            la $s0, first #loads first array
            ori $s4, 0x0   #sets $s4 to 0
            move $s1, $zero #sets $s1 to $zero
            
loop: 	slti $s2, $s1, 0x04  #if($s1 < 3) $s2 = 1 else $s2 = 0  			#modified 
            beq $s2, $zero, end #if($s2 == zero) exit();
            lw $s3, 0($s0) #$s3 = first[0];
           
            add $s4, $s4, $s3 #$s4 = $s4 + $s3;
            add $s0, $s0, 0x4 # $s0 = $s0 + 4;
            addi $s1, $s1, 1 # $s1++;
            la $a0, msg_iterate # $a0 = "Iteration";
            jal printstr #prints
            
            move $a0, $s1 # $a0 = $s1
            jal writeint # prints 	#modified
           
            la $a0, linebreak #$a0 = "\n";
            jal printstr #prints
            
            j loop #goes back to loop
            
end: move $a0, $s4  #modified
            jal writeint
            j _exit
            
printstr:	li $v0, 4
		syscall
		jr $ra
		
writeint:	li $v0, 1 #added
		syscall
		jr $ra	
_exit:	#added
