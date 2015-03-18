###################### DATA SECTION ##########################
.data
loadErrorMessage: .ascii "File Not Found"
inputFile: .asciiz "PA2_input1"
outputFile: .asciiz "PA2_output1"
outputBuffer: .ascii "File contents: "
buffer: .space 1024
numbersArray: .word 0 : 50	#Largest size of array

###################### TEXT SECTION ##########################
.text

#OPEN FILE
li $v0, 13		#open file prep
la $a0, inputFile	#load file name
li $a1, 0		#Read-only Flag
li $a2, 0		#mode ignored
syscall			#proceed to open file
blt $v0, 0, error	#tell user if load fails
move $s6, $v0		#move file descriptor to $s6 

#READ FILE
li $v0, 14	#read file prep
move $a0, $s6	#move file descriptor to $a0
la $a1, buffer	#place buffer in $a1
li $a2, 1024	#hardcode buffer to 1024
syscall		#proceed to read file into the buffer ($a1)

#SET UP STORAGE OF FILE NUMBERS
la $s0,numbersArray  #places numbersArray in $s0 (able to contain at most 50 ints)
la $s1, 0	     #will contain ascii integer representations

#CLOSE FILE
li $v0, 16	#close file prep
move $a0,$s6	#move file descriptor to $a0
syscall		#proceed to close file

###################### ARRAY ITERATION ##########################
#Creates int array from buffer ascii values
iterate:
	lb $t0, 0($a1)			#load first byte $t0
	addi $a1, $a1, 1		#move to next byte
	beq $t0, 45, negative		#check if byte represents a negative number
	beq $t0, 0, beginSort		#check if buffer is empty (if so sort)
	lb $t1, 0($a1)			#proceed to next byte
	beq $t1, 13, addAsciiVal	#if positive number, add to array
	beqz $t1, addAsciiVal		#special instruction to sort zeros
	addi $t0, $t0, -48		#convert ascii --> decimal
	jal loop			#proceed to code for numbers with more than one digit
	b addNumber
	
#NEGATIVE NUMBERS
negative:
	lb $t0, 0($a1)		#load number after - value
	addi $a1, $a1, 1	#proceed to next byte
	lb $t1, 0($a1)		#load byte to determine if 2+ digits
	addi $t0, $t0, -48	#convert ascii --> decimal
	beq $t1, 13, single	#if not 2+ digits 
	jal multiDigit		#if 2+ digit proceed to code that handles that

single:
	mulu $t0, $t0, -1	#turn -integer into integer
	b addNumber		#go to add the number to array
	
# 2+ DIGIT NUMBERS	
multiDigit:
	mulu $t0, $t0, 10	#mult by 10 to create 10's place for addition
	addi $t1, $t1, -48	#convert one's place digit from ascii --> decimal
	add $t0, $t0, $t1	#add two numbers
	addi $a1, $a1, 1	#get next byte
	lb $t1, 0($a1)		#Loads the next ascii code to $t1
	beqz $t1, addToArray	#go to add number to array
	bne $t1, 13,multiDigit	#return to multiDigit if there are still more digits to process
	jr $ra			#return to caller

#ADD A NUMBER TO ARRAY
addNumber:
	sw $t0, 0($s0)		#place number in array
	addi $s0, $s0, 4	#adjust base address
	addi $a1, $a1, 2	#increment byte by 2 (ignores \r and \n ascii values)
	addi $s1, $s1, 1	#track of how many numbers have been processed (ensures that empty buffer spaces aren't unnecessarily sorted)
	j nextNum		#proceed to add next number to array
	
#CONVERT TO DECIMAL BEFORE ADDING TO ARRAY
addAsciiVal:
	addi $t0, $t0, -48	#convert ascii --> decimal
	j addNumber		#add number to array

###################### SORTING SECTION ##########################
#PROLOGUE TO SORT
beginSort:
	mulu $s2, $s1, -4	# (#ints)(-4)--> used to reset the array position (has been increasing as numbers were added byte by byte)
	add $s0, $s0, $s2	#reset array position to original
	add $s3, $s1, -2	#takes two from counter to account for first two lines of sortNumbers (two numbers are loaded into registers)
	la $s2, 0		#use $s2 as a counter

#SORT ARRAY
sortNumbers:
	lw $t0, 0($s0)		#load int1 in $t0
	lw $t1, 4($s0)		#load int2 in $t1
	bgt $s2, $s3,startWrite	#if counter for sort > counter for buffer read through then proceed to writing file (sorting is complete)
	blt $t1, $t0, switch	#if int2>int1 switch integers
	addi $s0, $s0, 4	#no change needs to take place
	addi $s2, $s2, 1	#counter++
	j sortNumbers		#compare next two numbers (int2 and int3...)

#SWITCH INTEGERS	
switch:
	sw $t0, 4($s0)		#int2=int1
	sw $t1, 0($s0)		#int1=int2 (no need for temp val because they are being stored in a seperate array)
	mulu $s2, $s2, -4	#mult counter by-4
	add $s0, $s0, $s2	#reset array position to original
	la $s2, 0		#reset counter
	j sortNumbers		#compare next two numbers (int2 and int3...)

###################### CONVERTING SECTION ##########################
#PROLOGUE TO CONVERT INTS BACK TO ASCII
convertStart:
	mulu $s2, $s2, -4	#mult counter by-4
	add $s0, $s0, $s2	#reset array position to original
	la $s4, buffer		#new 1024 buffer
	la $s2, 0		#new counter for write buffer
	
#GET OUTPUT ARRAY
outPut:
	blez $s1, writeNumbers	#move to write file section of no more numbers to convert
	lw $t0, 0($s0)		#load first number
	bltz $t0,negOutput	#negative numbers
	bgt $t0, 9,multiOutput	# 2+ digits
	b addOutput		#add to array if single positive number
	
#NEGATIVE OUTPUT COMMANDS
negOutput:
	li $t1, 45			#load ascii representative of -
	sb $t1, 1($s4)			#store -
	addi $s4, $s4, 1		#change buffer base address
	addi $s2, $s2, 1		#counter++
	mulu $t1, $t0, -2		#gets positive double of (-int)
	add $t0, $t0, $t1		#converts (-int) to int
	blt $t0, 10, addOutput		#add single digits to array
	
# 2+ DIGIT OUTPUT COMMANDS
multiOutput:
	div $t0, $t0, 10	#convert 10's place to ascii
	addi $t0,$t0,48		#convert decimal --> ascii
	mfhi $t1		#remainder=1's place digit
	addi $t1,$t1,48		#convert decimal --> ascii
	sb $t0, 1($s4)		#place tens digit in array
	sb $t1, 2($s4)		#place ones digit in array
	li $t0, 13		#load new line equivalent
	sb $t0, 3($s4)		#place new line in array
	li $t0, 10		#load carriage return equivalent
	sb $t0, 4($s4)		#place carriage return into array
	addi $s1, $s1, -1	#counter--
	addi $s4, $s4, 4	#change base address
	addi $s2, $s2, 4	#buffer counter increment (1 byte)
	add $s0, $s0, 4		#move to next byte in buffer
	b outPut		#Branches back to output
	
#ADD OUTPUT TO ARRAY
addOutput:
	addi $t0, $t0,48	#Converts $t0 to ascii code to be saved
	sb $t0, 1($s4)	#Saves the byte to the buffer
	addi $s4, $s4, 1	#Increments the buffer
	li $t0, 13	#Loads the new line ascii code to $t0
	sb $t0, 1($s4)	#Saves the code to $t0
	addi $s4, $s4, 1	#Increments the buffer
	li $t0, 10	#Loads the return line ascii code to $t0
	sb $t0, 1($s4)	#Saves the code to $t0
	addi $s0, $s0, 4	#Increments the array by another word
	addi $s1, $s1, -1	#Decrements the counter by one
	addi $s4, $s4, 1	#Incrments the buffer
	addi $s2, $s2, 3	#Increments the counter
	b outPut		#Branches to output

###################### WRITING SECTION ##########################	
writeNumbers:

	#add $s4, $s4, $s2	#put buffer back to original
	li $v0, 13		#prep to open file (makes output file)
	la $a0, outputFile	#loads the File Name
	li $a1, 1		#write flag
	li $a2, 0		#mode ignored
	syscall			#proceed to open file (make output file)
	move $s6, $v0		#move file descriptor to $s6 
	
	li $v0, 15		#prep system to write to file
	move $a0, $s6		#move file descriptor to $a0
	la $a1, outputBuffer	#Moves where the buffer was to $a1 where it can be writen
	la $a2, 1024		#Hardcoded buffer
	syscall			#Should write to the file
	
	li $v0, 16	#prep system to close file
	move $a0, $s6	#move file descriptor to $a0
	syscall		#close file and proceed to close program
	
###################### END PROGRAM ##########################
exit:
	li $v0, 10	#prep system to exit
	syscall		#exit gracefully

###################### ERROR WARNING ##########################
#Incase the file is not found
error:
	li $v0, 4			#Preps to print a string
	la $a0, loadErrorMessage	#Loads the string that will be printed
	syscall				#Prints the string
	j exit				#Jumps to the exit label