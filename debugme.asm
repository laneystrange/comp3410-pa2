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
            ori $s4, 0x0		#$s4 = 0, $s4 is the sum of all numbers
            move $s1, $zero		# s1 = 0
            				# move mean copy a value from register to another register
            
loop: 	slti $s2, $s1, 0x04		# $s2 = 1 if $s1 < 4 \ 0 if $s1 >= 4
					# 0x04 mean there are 4 numbers to be add, slti is set less than immediate
            beq $s2, $zero, end		# $s2 equal to 0 then jump to end
            lw $s3, 0($s0)		# store the front of $s0 to $s3
           
            add $s4, $s4, $s3		
            add $s0, $s0, 0x4		# move $s0 pointer to the next element
            addi $s1, $s1, 1		
            la $a0, msg_iterate
            jal printstr		# jump to printstr label then come back
            
            move $a0, $s1		# copy value from $s1 to $a0
            jal printnum		# jump to printnum label then come back
           
            la $a0, linebreak
            jal printstr
            
            j loop			# jump to loop label
            
end: 		move $4, $20		# $a0 = $s4
            jal printnum
            j exit
 
# printstr label to print string           
printstr:	li $v0, 4
		syscall
		jr $ra		#to return from label to where you initially were, you just use jr $ra

# writenum label to print an integer
printnum: 	li $v0, 1	
		syscall
		jr $ra

# exist label since there is no label name exist so I have to create one
exit: 		li $v0, 10
		syscall
