.data
            welcome:  .asciiz "Welcome to the mysterious MIPS Program\n"
            msg_iterate: .asciiz "Iteration: "
           linebreak: .asciiz "\n"
           
            first:    .word 21
                      .word 14
                      .word 26
                      .word 39        
                      
 .text
            la $a0, welcome	# load address welcome into $a0
            jal printstr	# call print string
    
            la $s0, first	# load the first value in $s0
            ori $s4, 0x0	# $s4 stores the results, right now is 0
            move $s1, $zero	# move s1 that is the number of interactions
            
loop: 	slti $s2, $s1, 0x04	# shift left s1 by 3 and put into s2
            beq $s2, $zero, end	# if condition is met, jump to end
            lw $s3, 0($s0)	# load word s3 = 21
           
            add $s4, $s4, $s3	# s4 addes s3
            addi $s0, $s0, 0x4	# add inmediate value to add 
            addi $s1, $s1, 1	# s1 add immediate = 1
            la $a0, msg_iterate	# load address to a0 the message iterate
            jal printstr	# jump and link the print string
            
            move $a0, $s1	# move the value 
            jal writeint	# print the writtent int
           
            la $a0, linebreak	# load  new line to a0
            jal printstr	# print the line
            
            j loop		# jump back to loop
            
end: move $4, $20		# a0 is equal to s4
            jal writeint	# write it
            j _exit		# jump to _exit
            
printstr:	li $v0, 4	# load immediate 4 to $v0
		syscall		# issual a system call
		jr $ra		# to to register ra			
		
writeint:	li $v0, 1	# print
		syscall		# 
		jr $ra		# jump to register ra
		
_exit:		li $v0, 10	# exit
		syscall		# 
		

		
