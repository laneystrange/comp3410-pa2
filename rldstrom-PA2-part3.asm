# Robert L. Edstrom
# COMP3410 PA2
# Part 3

# I forgot I didn't finish this... 

.data
			.align 2
	array:		.space	1024
	fileinput:	.asciiz	"/home/pronis/PA2_linkedlist.txt"
	fileoutput:	.asciiz	"/home/pronis/PA2_lloutput.txt"
	buffer:		.space	1024
	sep:      	.asciiz "  "
	linef:    	.asciiz "\n"
	
.text
	# Open file
	li 	$v0, 13
	la 	$a0, fileinput
	li 	$a1, 0
	li 	$a2, 0
	syscall
	move 	$s6, $v0
	
	# Read data
	li 	$v0, 14
	move 	$a0, $s6
	la 	$a1, buffer
	li 	$a2, 1024
	syscall	
	
	# Close file
	li $v0, 16
	move $a0, $s6
	syscall
	
#####################################################################################################################################
# Converts ascii values to integers

intialize_atoi:	
	la	$s0, array		# $s0 now contains the array address
	move	$a0, $a1		# $a0 now contains the buffer address
	j atoi				# lets get our integers

atoi:
	move 	$v0, $zero		# zero-out $v0
	move	$t0, $zero		# zero-out $t0
	lb	$t0, 0($a0)		# load one byte into $t0

checksign:
	bne	$t0, 45, evalint	# checks if $t0 not equal to '-'
	addi	$t3, $zero, 1		# negative == 1
	addi	$a0, $a0, 1		# increment the buffer by one byte

evalint:
	lb 	$t0, 0($a0)		# load one-byte into $t0
	jal checks			# jump and run checks on the byte previously loaded
	
	subi	$t0, $t0, '0'		# $t0 -= '0'
	mul	$t1, $t1, 10		# $t2 *= 10
	add	$t1, $t1, $t0		# $t2 += $t0
	addi	$a0, $a0, 1		# increment the buffer by one byte
	j checksign			
	
checks:
	beq	$t0, 10, posorneg	# if $t0 == \n, branch to posorneg
	beq	$t0, 0, exitatoi	# if $t0 == null teminator branch to exitatoi
	jr	$ra
	
posorneg:
	bne	$t3, 1, storeint	# if $t4 != 1 branch to storeint, else move to the next instruction
	mul	$t1, $t1, -1		# set the sign to negative
	move	$t3, $zero  		# zero-out $t4
	j storeint
	
	
storeint:
	sw	$t1, 0($s0)		# store the integer in the array
	move	$t1, $zero		# zero-out $t1
	addi	$s0, $s0, 4		# increment the array by one index i.e. 4 bytes = index + 1
	addi	$a0, $a0, 1		# increment the buffer by one byte
	move	$s1, $t2		# store the total count of integers into $s1
	addi	$t2, $t2, 1		# increment $t2 by one for each stored integer, $t3 will be off by one at the end of atoi
	j atoi				# so it will be moved to $s1 which will contain the actual count
	
exitatoi:
	move	$t2, $zero		# zero-out $t3
	move	$s5, $s1		# move the total count into $s5
	mul	$s1, $s1, 4		# multiply $s1 (the total count) by four to obtain the total bytes
	j linkedlist			# e.g. (4 bytes per int * total count) = in this case 200 bytes / 50 integers
	
# End of conversion
#####################################################################################################################################	
	
#####################################################################################################################################
linkedlist:
	
        la	$s0,array
        la	$t1, buffer      	# get pointer to head
        lw    	$a0,0($s0) 
loop:     
	beqz  	$s0,done      		# while not null
        #lw    	$a0,0($s0)     	 	#   get the data 
        add	$t2, $zero, $a0
        move	$t3, $a0
        
        li    	$v0,1          		#   print it
        syscall               		#
        la     	$a0,sep        		#   print separator
        li     	$v0,4
        syscall
        addi	$s0, $s0, 4 
        lw     	$s0,4($s0)
        addi	$s0, $s0, 4    		 #   get next
        j loop
          
done:   la     	$a0,linef      	
        li     	$v0,4
        syscall              			
           	

		
#####################################################################################################################################

#####################################################################################################################################
# Converts integers to ascii values

itoa:
	move	$a1, $s5		# move the total count into $a1
	la	$a2, buffer		# load the address of the outputbuffer

initialize_itoa:	
	move 	$t0, $t2		# load integer in $t0
	move 	$t1, $zero		# zero-out $t1
	addi 	$t1, $t1, 1		# defalut magnitude set to 1
	move 	$t6, $t0		# $t6 temp register for further calculations

magnitude:
	div 	$t6, $t6, 10 		# $t6 /= 10
	beq 	$t6, 0, checksin	# if $t6 == 0, branch and check 
	addi 	$t1, $t1, 1		# increment magnitude flag
	j magnitude			

checksin:
	move 	$t6, $zero
	bgt 	$t0, -1, positive	# if $t0 > -1 branch to positive
	addi	$t6, $t6, '-'		# $t6 == '-'
	sb 	$t6, 0($a2)		# write negative sign to bufferout
	addi 	$a2, $a2, 1		# increment the bufferout by one byte
	mul 	$t0, $t0, -1		# change negative number to positive

positive:
	move 	$t2, $a0		# $t2 set to the array address
	move 	$t3, $a1		# $t3 set to the total count of integers
	move 	$a0, $zero		# zero-out $a0
	addi 	$a0, $a0, 10		# $a0 == 10
	move 	$a1, $t1		# $a1 contains the magnitude flag
	move 	$t5, $zero		# zero-out $t5
	addi 	$t5, $t5, 1		# Sets it to 1 so exp can work.

exponent:
	mul 	$t5, $t5, $a0		
	addi 	$a1, $a1, -1		# decrement magnitude flag
	bgt 	$a1, 1, exponent	# if $a1 (magnitude flag) > 1 repeat, else exit exponent loop
	move 	$a0, $t2		
	move 	$a1, $t3		

loopie:
	div 	$t6, $t0, $t5		# extract left-most byte
	mul 	$t4, $t6, $t5		# extract the magnitude
	sub 	$t0, $t0, $t4		# left with the result 
	addi 	$t6, $t6, '0'		# $t6 == ascii value
	div 	$t5, $t5, 10		# decrease magnitude
	sb 	$t6, 0($a2)		# write the byte to the bufferout
	addi 	$a2, $a2, 1		# Advances the write buffer one byte
	bne 	$t5, 0, loop		# if $t5 == 0, exit loop, else loop	
	
	move 	$t6, $zero		# zero-out $t6
	addi 	$t6, $t6, 10		# $t6 == \n
	sb 	$t6, 0($a2)		# write \n
	addi 	$a2, $a2, 1		# increment the bufferout by one byte
	addi 	$a1, $a1, -1		# decrement the total count of integers to be written
	beqz 	$a1, addnullterm	# if a1 == 0, branch to addnullterm
	addi 	$a0, $a0, 4		# increment the array by four bytes
	j initialize_itoa		

addnullterm:
	move	$t6, $zero		# zero-out $t6
	addi	$t6, $t6, 0		# $t6 == null terminator
	sb	$t6, 0($a2)		# write null terminator to bufferout
	
openwritefile:
	li 	$v0, 13			# opens fileoutput
	la 	$a0, fileoutput		# load file descriptor
	li 	$a1, 1			# flag for writing
	li 	$a2, 0			# ignore
	syscall				# makes it happen
	move 	$s7, $v0		# $s7 == file descriptor
	
writetofile:	
	li 	$v0, 15			# setup for writing to fileoutput
	move 	$a0, $s7		# $a0 == file descriptor
	la 	$a1, buffer		# $a1 == bufferout address
	li 	$a2, 1024		# bufferout size in bytes
	syscall	
	move	$ra, $t3				# writes to file
	jr	$ra
	
exit:	
	li 	$v0, 10			# setup for exiting gracefully
	syscall				# program finished
