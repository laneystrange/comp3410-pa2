# COMP3410
# Author: Michael Vance
# Assignment: PA[2]
# Date: 3/14/2015

# partTwo.asm

	.data
fnf:		.ascii  "The file was not found: "	# Error message
file:		.asciiz	"C:\\PA2_input1.txt"		# Input file, needs to be changed for input2
file_out:	.asciiz "C:\\PA2_output1.txt"		# Output file, needs to be changed for output2
buffer: 	.space 1024				# Buffer space
array:		.space 4				# Array space
newline:	.asciiz "\n"				# newline character
space:		.asciiz  " "          			# Print a space between each pair of numbers
 
	.text
 
# Open File
open:
	li	$v0, 13		# Open File Syscall
	la	$a0, file	# Load File Name
	li	$a1, 0		# Read-only Flag
	li	$a2, 0		# (ignored)
	syscall
	move	$s6, $v0	# Save File Descriptor
	blt	$v0, 0, err	# Goto Error
 
# Read Data
read:
	li	$v0, 14		# Read File Syscall
	move	$a0, $s6	# Load File Descriptor
	la	$a1, buffer	# Load Buffer Address
	li	$a2, 1024	# Buffer Size
	syscall
	
# Convert Data
convert:
	la	$t0, buffer	# Load address for buffer
	la	$t7, array	# Load address for array
continue:	
	lb	$t1, 0($t0)		# Load byte (first digit from buffer "string")
	beq	$t1, 45, special	# If "-" go to special
	beq	$t1, 13, special	# If "\" go to special
	beq	$t1, 10, special	# If "newline" go to special
	beq	$t1, 0, sort		# If end of string/buffer go ahead and sort
	addi	$t1, $t1, -48		# Convert ASCII to int by -48
	sb	$t1, 0($t7)		# Store byte (the digit) into array
	addi	$t7, $t7, 1		# Increment array
	addi	$t0, $t0, 1		# Increment buffer
	j continue			# Loop again
	
# Special Cases
special:				# Did not implement negatives, or number larger than single digits
	addi	$t0, $t0, 1		# This basically skips those instances. . .
	j continue

# Sort Data
sort:
 la $a1,array      #load a pointer to array into $a1 

loop:
 li $t1,20          #if $t1 is zero, load 9 into $t1

loop1: 
 beqz $t1,convertBack     #if $t2 is zero, goto here 
 addi $t1,$t1,-1   #subtract 1 from $t2, save to $t2 
 lb $t5,0($a1)     #load an input int into $t5 
 lb $t6,1($a1)     #load the next one into $t6 
 addi $a1,$a1,1    #add 4 to $a1, save to $a1 
 ble $t5,$t6,loop1 #if $t5 <= $t6, goto loop1 
 sb $t5,0($a1)     #else, store $t5 in $a1 
 sb $t6,-1($a1)     #and store $t6 in $a1-4 (swapping them) 
 bgez  $t1,loop1    #if $t2 is not zero, to go loop1

# Convert Data Back
convertBack:			# Basically trying to undo all of the previous conversions to get sorted buffer
	la	$t7, buffer	# Load address of buffer
	la	$t0, array	# Load address of array
#	lb	$t2, newline	# Load address of newline
continueAgain:	
	lb	$t1, 0($t0)	# Load byte (int from array)
	beq	$t1, 0, close	# If the end of array, go ahead and close
	addi	$t1, $t1, 48	# Int -> ASCII
	sb	$t1, 0($t7)	# Store byte (char into buffer)
#	sb	$t2, 1($t7)	# Add a newline
	addi	$t7, $t7, 1	# Increment buffer
	addi	$t0, $t0, 1	# Increment array
	j continueAgain		# repeat loop
 
# Close File
close:
	li	$v0, 16		# Close File Syscall
	move	$a0, $s6	# Load File Descriptor
	syscall
	j	write		# Goto End
 
# Error
err:
	li	$v0, 4		# Print String Syscall
	la	$a0, fnf	# Load Error String
	syscall
 	
# Open (for writing) a file that does not exist
write:	li	$v0, 13       # system call for open file
	la	$a0, file_out # output file name
	li	$a1, 1        # Open for writing (flags are 0: read, 1: write)
	li	$a2, 0        # mode is ignored
	syscall		      # open a file (file descriptor returned in $v0)
	
	move	$s6, $v0      # save the file descriptor 
# Write to file just opened
	li	$v0, 15       # system call for write to file
	move	$a0, $s6
	la	$a1, buffer   # address of buffer from which to write
	li	$a2, 1024     # hardcoded buffer length
	syscall               # write to file
	
# Close the file
	li	$v0, 16
	move	$a0, $s6      # file descriptor 
	syscall

# Done
done:
	li	$v0, 10	      # Exit Syscall
	syscall

