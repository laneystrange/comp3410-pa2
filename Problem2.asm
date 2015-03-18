
#The following is a group of predetermined strings that may print during the program's run
	.data
fnf: .ascii "The file was not found:"
file: .asciiz "PA2_input1.txt"
fileOut: .asciiz "PA2_output1.txt"
cont: .ascii "File contents: "
buffer: .space 1024
maxSize: .word 0 : 50	#Largest size of array
mDigit:	.word 0 : 9	#Used for multi digit conversion from digit to ascii

#Next is the code that the program runs
	.text

li $v0, 13	#Preps to open a file
la $a0, file	#Loads the File Name
li $a1, 0	#Read-only Flag
li $a2, 0	#Ignored
syscall		#Opens the file
move $s6, $v0	#Save File Descriptor
blt $v0, 0, error	#Sends an error if the file was not found

li $v0, 14	#Preps for reading of the file
move $a0, $s6	#Moves the file descriptor back to $a0
la $a1, buffer	#Makes a buffer in $a1
li $a2, 1024	#Creates the cap to 1024, the size of the buffer
syscall		#Reads the file into the buffer

la $s0, maxSize	#Creates an array in $s0 the size of 50, the highest number of integers to be read
la $s1, 0	#Zeros out $s1 to be able to take in each ascii integer

li $v0, 16	#Preps to close the file
move $a0 $s6	#Loads the file discriptor
syscall		#Closes the file

#This next section takes the buffer and reads it each byte at a time and makes an array of integers 
nextNum:
	la $t2, 0	#Zeros out $t2 for use throughout this subroutine
	lb $t0, 0($a1)	#Loads the first byte from the buffer into $t0
	addi $a1, $a1, 1	#Increments $a1 to recieve the next byte when needed
	beq $t0, 45, negative	#Checks to see if byte is a "-" symbol, if it is it sents it to the
				#negative label to be processed as a netative integer
	beq $t0, 0, preSort	#Checks if the next byte in the buffer is a zero, signifying that the
				#buffer is empty and sents it to the pre sorting label to be sorted after
	lb $t1, 0($a1)		#Loads the next byte of data
	beq $t1, 13, translateAndAdd	#This branches to the translate and add the number to the array if
					#it finds that it is a new line ascii number
	beqz $t1, translateAndAdd	#Branches again, but if $t1 is zero, incase $t0 is the last number
	addi $t0, $t0, -48	#Adjusts $t0 from its ascii to its decimal integer form is
	jal loop	#Branches to the loop to be processed as a multi digit number
	b addToArray
	
#This is if the number is negative
negative:
	lb $t0, 0($a1)	#Loads the next byte, after the "-" symbol, which should be a number so it can be processed
	addi $a1, $a1, 1
	lb $t1, 0($a1)	#Loads the next byte, after the number, so it can be determined if it is multi digit or not
	addi $t0, $t0, -48	#Translates the $t0 to its decimal integer form
	beq $t1, 13, skip	#If ascii number is a new line number it goes to skip
	jal loop	#Branches to a loop if it is multi digit
	skip:
		la $t2, 0
		mulu $t0, $t0, -1	#Multiplies the positive translated form of the negative number by -1 to find the negative version
		b addToArray	#Branches to add the number to the array
	
#If the number in question is multi digit	
loop:
	mulu $t0, $t0, 10	#Multiplies the first digit by 10
	addi $t1, $t1, -48	#Translates $t1 to its decimal integer form
	add $t0, $t0, $t1	#Adds $t1 translated to $t0
	addi $a1, $a1, 1	#Increments to get the next byte
	lb $t1, 0($a1)	#Loads the next ascii code to $t1
	beqz $t1, addToArray	#If the last number is double digit it will get a 0 value and branch out
	
	bne $t1, 13, loop	#Branches back to loop if $t1 is not a new line code
	jr $ra

#Adds the number in $t0 to the array
addToArray:
	sw $t0, 0($s0)	#Stores the word in the array at $s0
	addi $s0, $s0, 4	#Increments the array to accept the next number
	addi $a1, $a1, 2	#Increments $a1 by 2 to ignore both 13, and 10
	addi $s1, $s1, 1	#Increments a counter for how many numbers have been processed
	j nextNum	#Jumps to the next number
	
#Both translates and adds the number to the array
translateAndAdd:
	addi $t0, $t0, -48	#Translates ascii code
	sw $t0, 0($s0)	#Adds to the array
	addi $s0, $s0, 4	#Increments the array
	addi $a1, $a1, 2	#Increments the buffer
	addi $s1, $s1, 1	#Increments the counter
	j nextNum	#Jumps to the next number

#This next subroutine section contains the sorting algorithms and their set ups
#First the set up to sort
preSort:
	mulu $s2, $s1, -4	#Stores the product of the counter from earlier multiplied to -4
	add $s3, $s1, -2	#Stores the counter minus 2, because two will be used in the sorting and if it is not used
				#it causes an off by 2 error
	add $s0, $s0, $s2	#Resets the array's position by adding the product from earlier
	la $s2, 0	#Resets $s2 for a counter

#Label for a loop uses a counter to end if the entire list is sorted
sort:
	lw $t0, 0($s0)	#Loads the first integer in $t0
	lw $t1, 4($s0)	#Loads the second integer in $t1
	bgt $s2, $s3, outStart	#If the $s2 counter is more than the original counter minus 2 stored in $s3
	blt $t1, $t0, swap	#If The first integer is greater than the second
	addi $s0, $s0, 4	#Increments array since the branch was false
	addi $s2, $s2, 1	#Increases the counter
	j sort	#Jumps back to the sort loop

#Swap subroutine	
swap:
	sw $t0, 4($s0)	#Stores the greater number in the higher part of the array
	sw $t1, 0($s0)	#Stores the lesser number in the array to the lower part of the array
	mulu $s2, $s2, -4	#Finds the number that is needed to set the array back to its original position with the formula
	add $s0, $s0, $s2	#Resets the array to its original position using $s2
	la $s2, 0	#Zeros out $s2 for the counter
	j sort	#Jumps back to the sort label
	
#The next subroutines are for building the string in a new buffer so it can be converted back to ascii and read back into a new file
outStart:
	mulu $s2, $s2, -4	#Finds the number needed to reset the array back to its original position
	addi $t2, $zero, 48	#Creates a number that can more easily translate from decimal to ascii code
	add $s0, $s0, $s2	#Resets the array back to its original position
	la $s5, mDigit	#An array that can be used to store values that can't be placed in the string yet if there are
			#multi digit numbers 
	la $s4, buffer	#Creates a new buffer with the same space
	la $s2, 0	#Zeros out $s2 to be used as a counter for how much the buffer has moved
	
#The next part of the outputing string subroutines that will be repeated, uses $s0 to set teh buffer back after it is filled
outPut:	
	blez $s1, write	#If the counter reaches zero then it branches to the next subroutine
	add $t3, $0, $0	#A counter for multi digit numbers zeroed out every time a new number is being processed
	lw $t0, 0($s0)	#Loads the first word in the array for evaluation
	bltz $t0, lTZero	#If the number is less than zero
	bgt $t0, 9, dDigit	#If the number is double Digit
	
	#If neither execute it goes straight into addToString because it is between 0 and 9
		
#Adds the bytes to the buffer
addToString:
	add $t0, $t0, $t2	#Converts $t0 to ascii code to be saved
	sb $t0, 0($s4)	#Saves the byte to the buffer
	addi $s4, $s4, 1	#Increments the buffer
	jal nLine	#Jumps and links to nLline to have the space print
	addi $s1, $s1, -1	#Decrements the counter by one
	b outPut	#Branches to output
	
#Subroutine if the number is less than zero
lTZero:
	li $t1, 45	#Loads the 45, ascii symbol for "-"
	sb $t1, 0($s4)	#Stores the byte in the buffer
	addi $s4, $s4, 1	#Increments the buffer for the - symbol
	addi $s2, $s2, 1	#Increments the counter
	mulu $t0, $t0, -1	#Multiplies the negative number by -1 to make it positive
	blt $t0, 10, addToString	#If the number is less than 10 it branches to addToString label
	#Else it just goes straight into dDigit to be evaluated as a double digit number
	
#If the number was a multi digit number
dDigit:
	div $t0, $t0, 10	#Divides the number by ten
	mfhi $t1	#Gets the remainder from the hi register
	sw $t1, 4($s5)	#Saves the remainder to the array for remainders that can't be saved yet
	addi $t3, $t3, 1	#Increments a multi-digit counter for unloading the array
	addi $s5, $s5, 4	#Increments the array up one word to store another possible number needed
	bgt $t0, 9, dDigit	#If what is left in $t0 from being devided is more than 9 then it jumps back as a loop
dDigitDown:
	add $t0, $t0, $t2	#Converts the latest number to ascii
	sb $t0, 0($s4)	#Saves the number to the string
	addi $s4, $s4, 1	#Increments the buffer by one for the saved by this loop
	lw $t0, 0($s5)	#Loads one of the remainders stored in the array
	addi $s5, $s5, -4	#Decrements the array by one word
	addi $t3, $t3, -1	#Decrementts the counter for multi-digit numbers
	addi $s2, $s2, 1
	bgt $t3, -1, dDigitDown	#If the counter is greater than -1, it repeats the loop
	jal nLine	#Jumps and links to nLine
	addi $s1, $s1, -1	#Decrements the counter by one, for the number saved
	b outPut	#Branches back to output to recieve another number

#Does the next line and return line code and returns
nLine:
	li $t0, 13	#Loads ascii code for new line
	sb $t0, 0($s4)	#Saves the ascii code in the string 
	li $t0, 10	#Loads ascii code for return line
	sb $t0, 1($s4)	#Saves the ascii code in the string
	addi $s4, $s4, 2	#Increments the buffer to adjust for the new two symbols
	add $s2, $s2, 2	#Increments the counter by the amount added to the buffer
	addi $s0, $s0, 4	#Increments the array by another word
	jr $ra	#Jumps back to the return register
	
#This last section takes the string and pints writes it to the file in outFile in the .data section
write:

	li $v0, 13	#Preps to open a file
	la $a0, fileOut	#Loads the File Name
	li $a1, 1	#Write flag
	li $a2, 0	#Ignored
	syscall		#Opens the file
	move $s6, $v0	#Saves the file identifier to $s6
	
	li $v0, 15	#Preps to write to the file
	move $a0, $s6	#Moves the file identifies back to $a0
	la $a1, cont	#Moves where the buffer was to $a1 where it can be writen
	la $a2, 1024	#Hardcoded buffer
	syscall	#Should write to the file
	
	li $v0, 16	#Preps to close the file
	move $a0 $s6	#Loads the file discriptor
	syscall		#Closes the file
	
#Exits the program
exit:
	li $v0, 10	#Preps to exit
	syscall	#Exits the program 

#Incase the file is not found
error:
	li $v0, 4	#Preps to print a string
	la $a0, fnf	#Loads the string that will be printed
	syscall	#Prints the string
	j exit	#Jumps to the exit label
