#Frank Martino
#3/17/2015
.data
            welcome:  .asciiz "Welcome to the mysterious MIPS Program\n"
            msg_iterate: .asciiz "Iteration: "
           linebreak: .asciiz "\n"
           
            first:    .word 21, 14, 26, 39 #fixed the array declaration       
                      
 .text
            la $a0, welcome	# prepares welcome message 
            jal printstr	# prints welcome message 
    
            la $s0, first	# loads initial array address to $s0
       	    li $s2, 3		# deleted ori command
            move $s1, $zero	#sets s1 to zero
            lw $s4, 0($s0)	#load the first value to $s4
            addi $s0, $s0, 4	#increment the array to the next value
            
loop: 	 beq $s2, $zero, end	#end the loop if $s2 == 0
            lw $t1, 0($s0)	#load next array value to $t1
            
            addi $s0, $s0, 4	#increment array address to next array value
           
            add $s4, $s4, $t1	#add t1 to s4 
            
            addi $s1, $s1, 1	#increment s1 value of the increments
            addi $s2, $s2, -1 	#decrement the s2 value by 1
            
            la $a0, msg_iterate	#loadload iterat message call the print process 
            jal printstr	#jump to the print process 
            
            move $a0, $s1	#move the value of s1 to the argument register
            jal printint	#call the print process
           
            la $a0, linebreak	#load the line break character to the argument
            jal printstr	#call the print process
            
            j loop		#jump to start of loop
            
end: 	    move $a0, $s4	#load sum to argument value 
            jal printint	#call print method to print the sum
           
            li $v0, 10		#prepare syscall for exit
            syscall		#exit ssyscall
            
printstr:	li $v0, 4	#prepare the syscall for string print
		syscall		#syscall for print 
		jr $ra		#return from where it was called
		
printint:	li $v0, 1	#prepare the syscall for int print
		syscall		#print the int
		jr $ra		#return to the call spot
		
		

