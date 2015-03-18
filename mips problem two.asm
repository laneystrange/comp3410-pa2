	.data
file:		.asciiz	"PA2_input1.txt"
outfile:	.asciiz	"PA2_output1.txt"
cont:		.ascii  "File contents: "
buffer: 	.space 1024
outbound:	.space 1024
bufferend:	.ascii ""
int_array:  	.word   0:36 	#array for the ints that will be sorted eventually
linebreak: 	.ascii "\n"		#line break
.align 2
array: 		.space 1024
 
 
	.text
 main:
	# Open File
	li	$v0, 13		# Open File Syscall
	la	$a0, file	# Load File Name
	li	$a1, 0		# Read-only Flag
	li	$a2, 0		# (ignored)
	syscall
	move	$s6, $v0	# Save File Descriptor
	move $s6, $v0
 
	# Read Data
	li	$v0, 14		# Read File Syscall
	move	$a0, $s6	# Load File Descriptor
	la	$a1, buffer	# Load Buffer Address
	li	$a2, 1024	# Buffer Size
	syscall
	
	# Close File
	li	$v0, 16		# Close File Syscall
	move	$a0, $s6	# Load File Descriptor
	syscall
	#j	done		# Goto End

	#Acess Data
	la $a0, buffer		#place buffer in a0 argument 1
	la $a1, array		#place array into a1 argument 2
	jal asciiToInt		#jump and link to convertToInt
	la $a0, array
	move $a1, $v1		
	move $s1, $v1		
	jal sort		

	
	
	#open new file for the output of the original file
	li	$v0, 13		# Open File Syscall
	la	$a0, outfile	# Load File Name
	li	$a1, 1		# Read-only Flag
	li	$a2, 0		# (ignored)
	syscall
	move	$s2, $v0	# Save File Descriptor

	#allows you to convert the sorted int arrar to ascii character to put in the new file
	la $a0, array		# Moves the int array to a0
	move $a1, $s1		# the number of ints goes in to a1
	la $a2, outbound		# the output buffer is moved to a2 register
	jal intToAscii		# Calls the method to convert the ints to acsii characters
				#for the out put buffer
	
	#setup the output buffer			
	li $v0, 15	
	move $a0, $s2		# Moves the file descriptor to arg1
	la $a1, outbound		# Locates our write-buffer
	li $a2, 1024	
	syscall			# Writes to the file
	
	j done
	
	
	
	
	
	
	
	
	
	
	
	
	
#method that is used to convert the ascii characters to ints for the int arrray
asciiToInt:
	#t9 is the string adress 
	######################################################
	move $t9, $a0 		# Copying the input string's address so we can manipulate it.
	li $v0, 0		#load zero to v0
	
loadByte:	
	lb $t0, 0($t9)		# load the first byte
	move $t5, $zero
	bne $t0, 45, loop	# If negative, proceed, otherwise skip to 'loop'
	
isneg:	addi $t5, $t5, 1 	# Setting the negative flag
	addi $t9, $t9, 1 	# Moving string forward one byte
	
#loop to convert to int
loop:
	lb $t0, 0($t9)		#fetch the first byte of the string to convert it to an int
	beq $t0, 10, finalStep	# if a linefeed is found go to the last step
	beq $t0, 0, finalStep	# if it is the null terminator go to the last step too
	#find the decimal equilvalent for the byte
	subi $t0, $t0, '0'	#find the decimal value from the ascii value 
	mul $t6, $t6, 10	#this will move the magnitude of the number
	add $t6, $t6, $t0	#add the current byte
	add $t9, $t9, 1 	#move the byte forward one byte
	j loop
	
finalStep:
	bne $t5, 1, store
	mul $t6, $t6, -1
	j store

store:
	sw $t6, 0($a1)		# Stores the current integer in the array
	addi $a1, $a1, 4	# increase the array pointer 1 indexes (4 bytes)
	addi $t9, $t9, 1	# increse the byte variable one to access the next byte
	move $t6, $zero		# reset t6 to zero
	beq $t0, 0, asciiToIntFinished	# Null terminator
	addi $t4, $t4, 1	# Increments the number of items the array has
	j loadByte
	
asciiToIntFinished:
	move $v0, $a1
	move $v1, $t4
	jr $ra
	
	
	
	
	
	
	
	
	
#sorting method	
sort:
	#set up the counters
	move $t0, $zero
	move $t2, $a0
	move $t3, $zero
	
newround:
	move $t1, $zero		#our min is now zero
	move $t3, $zero		#makes the iteration cointer to zero
	move $t4, $t2		#
	addu $t1, $t1, 2147479548
	
	
iterate:
	beq $a1, 0, SortisDone	# if the number of elements is equal zero then end sort
	lw $t0, 0($t4)		# load the left most element into the array
	blt $t0, $t1, setMin	# if the current number is the min of the array go to 
				#the set min label to place the min into the min variable
				#to t1
	
resumeIreration:
	addi $t3, $t3 1 	#add one to the iteration counter variable
	addi $t4, $t4, 4	#add four to the memory adress of the the current
				#array adress to get the next one
	beq $t3, $a1, switchingElements		#Once the array as been iterated through go to the sort routine
	j resumeIreration
	
	
switchingElements:
	#need to load the minium and and the left most elemnt from the array
	lw $t5, 0($t6) 		#loads the minium into t5
	lw $t9, 0($t2)		#loads the left most element into the register $t9
	#move the elements to be sorted
	sw $t5, 0($t2)		#puts the minium into the left most spot that 
				#has not been sorted yet 
	sw $t9, 0($t6)		#swaps thright element to where the mininium was
	add $t2, $t2, 4
	addi $a1, $a1, -1
	j newround
	
setMin:
	move $t6, $t4		# Getting the address of the new minimum
	move $t1, $t0		# Setting the new minimum
	j resumeIreration
	

SortisDone:
	move $v0, $a0
	jr $ra
	

	
	
	
	