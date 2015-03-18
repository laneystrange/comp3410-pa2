
#
#was unable to finish not sure if the acsii and int conversion even work 


#Resources used
#http://www.cplusplus.com/reference/cstdlib/atoi/
#http://www.cmi.ac.in/~nivedita/subjects/CO/mips-material/atoi-3.asm
#http://courses.missouristate.edu/kenvollmar/mars/help/syscallhelp.html
#http://eisertdev.com/reading-files-in-mips/
.data
			.align 2
	array:		.space	1024
	fileinput:	.asciiz	"PA2_input2.txt"
	fileoutput:	.asciiz	"PA2_output2.txt"
	bufferin:	.space	1024
	bufferout:	.space	1024
	
	
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
	la 	$a1, bufferin
	li 	$a2, 1024
	syscall	
	
	# Close file
	li $v0, 16
	move $a0, $s6
	syscall
	
#conversion to ints


	la $s0, array		# s0 contains aray
	move $a0, $a1		# a0 contains buffer address
	j atoi				# convert
	
atoi:
	#zero out the to registers v0 and t0
	move $v0, $zero
	move $t0, $zero
	#first step is to load a byte to convert
	lb $t0, 0($a0)		#desintaion of byte is t0
	
checkSign:
	bne $t0, 45, findValue		#check wether ot no t0 equals a - sign
	#if so we need to flag it
	addi $t3, $zero, 1
	#if it is negative then advance the buffer 
	addi $a0, $a0, 1
	
findValue:
	lb $t0, 0($a0)		#we loaded a byte into $t0
	#now we check to make sure that the byte is not a int
	#it can be a new line or a null terminator
	beq $t0, 10, checkpn	
	beq $t0, 0, endConversion
	
		
#check the flag to make sure that is is not negative if it will then go to store int
#if it is negative by negative one 
checkpn:
	bne $t3, 1, store
	mul $t1, $t1, -1
	move $t3, $zero
	j store
	
	
store:
	sw $t1, 0($s0) 		#storing the integer into the array for sorting
	move $t1, $zero		#clear out results of previous stored intry
	addi $s0, $s0, 4	#to increase the an array in mips we need to increase the overall counter
				#by four.
	addi $a0, $a0, 1	#the buffer is byte by byte adressable so we only need to increment it by
				#to get the next byte
	move $s1, $t2		#move the current count of ints 
	addi $t2, $t2, 1 	#increase the total count by one
	
endConversion:
	move	$t2, $zero
	move	$s5, $s1
	mul	$s1, $s1, 4
	


#sorting time
#One thing I am happy about is not quick sort
sort:
#pre limary steps
	la $t0, array		#load array into t0
	add  $t0, $t0, $s1 	#set up counter
	
#this would be like the outer loop for sorting
outter:
	#for(int i=0; i < t0; i++)
	add $t1, $0, $0
	la $t0, array 		#load array into t0
	
#out of bounds 
inner:	
	lw $t2, 0($t2) 		#Loads the first element of the array I
	lw $t2, 0($t2)		# loads the next element in the array for comparison
				#tto sort the array
	slt $t4, $t3, $t2	#checks whether or not the i+1 element is less than i
	beq $t4, $0, switchelemets	#if ^ true then a flag turns to one
	add $t1, $0, 1
	sw  $t2, 4($a0)		# t2 =  i + 1
    	sw  $t3, 0($a0)		# t3 = i
	

switchelemets:
	addi $a0, $a0, 4
	bne $a0, $t0, inner
	bne $t1, $0, outter
	j itoa
	

#itoa

itoa:
	la $a0, array
	move $a1, $s5
	la $a2, bufferout

	lw $t0, 0($a0)		#load element from array
	move $t1, $zero		#zero out t1
	addi $t1, $t1, 1	#set t1 to the starting magnitude
	move $t6, $t0		#further calculations
	
findMag:
	div $t6, $t6, 10 	#see if wee need to increase the magnitude by dividing by 10
	#we need to know have a condition to see if it is less than 10 when dividing
	beq $t6, 0, checksigns	#checks to see if it is eaual to zero
	addi $t1, $t1, 1 	#increse the magnitude of the value
	
checksigns:
	move 	$t6, $zero
	bgt 	$t0, -1, positive	# if the value is greater than -1 that means that it is a positive value
					#know if it is not greater than then we go to negative
	addi	$t6, $t6, '-'	
	sb 	$t6, 0($a2)		# write bufferout
	addi 	$a2, $a2, 1		# increment buffer
	mul 	$t0, $t0, -1		# (-9)(-1)=9
	


positive:
	move $t2, $a0
	move $t3, $a1
	move $a0, $zero
	addi $a0, $a0, 10
	move 	$a1, $t1
	move 	$t5, $zero		
	addi 	$t5, $t5, 1		
	
	
exponent:
	mul $t5, $t5, $a0		#
	addi $a1, $a1, -1 		#decrement magnitdue
	bgt  $a1, 1, exponent	# if a1 is gretare than one 
	move 	$a0, $t2		
	move 	$a1, $t3
	
loop:
	div $t6, $t0, $t5		# get left most byte
	mul $t4, $t6, $t5		# find mag
	sub $t0, $t0, $t4		# -result
	addi $t6, $t6, '0'		# acsii
	div $t5, $t5, 10		#reset mag
	sb $t6, 0($a2)			#store byte in buffer
	addi $a2, $a2, 1		#need to increase the byte locarion in buffer
	bne $t5, 0, loop		#if t5 is not 0 continue with loop
	
	move $t6, $zero
	addi $t6, $t6, 10 		#t6 is the new line
	sb $t6, 0($a2)
	addi $a2, $a2, 1		#buffer++
	addi 	$a1, $a1, -1		#num int --
	beqz 	$a1, nullTerm		#
	addi 	$a0, $a0, 4		# increment the array by four bytes
	j startitoa
	
			
nullTerm:		
	move $t6, $zero
	addi $t6, $t6, 0	
	sb $t6, 0($a2)		#store byte
	
	
li 	$v0, 13			# opens fileoutput
la 	$a0, fileoutput		# load file descriptor
li 	$a1, 1			# flag for writing
li 	$a2, 0			# ignore
syscall				# makes it happen
move 	$s7, $v0		# $s7 == file descriptor
	
	
	
li 	$v0, 15			# setup for writing to fileoutput
move 	$a0, $s7		# $a0 == file descriptor
la 	$a1, bufferout		# $a1 == bufferout address
li 	$a2, 1024		# bufferout size in bytes
syscall				# writes to file
	
	
	
li 	$v0, 10			# setup for exiting gracefully
syscall		
