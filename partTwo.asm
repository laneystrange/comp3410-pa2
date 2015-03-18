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
     la		$t0, array      	# Copy the base address of your array into $t1
     add 	$t0, $t0, 1024    	                            
outterLoop:             		# Used to determine when we are done iterating over the Array
     add 	$t1, $0, $0     	# $t1 holds a flag to determine when the list is sorted
     la  	$a0, array      	# Set $a0 to the base address of the Array
innerLoop:                  		# The inner loop will iterate over the Array checking if a swap is needed
     lb  	$t2, 0($a0)         	# sets $t2 to the current element in array
     lb  	$t3, 1($a0)         	# sets $t3 to the next element in array
     slt 	$t5, $t2, $t3       	# $t5 = 1 if $t2 < $t3
     beq 	$t5, $0, contin  	# if $t5 = 1, then swap them
     add 	$t1, $0, 1          	# if we need to swap, we need to check the list again
     sb  	$t2, 1($a0)         	# store the greater numbers contents in the higher position in array (swap)
     sb  	$t3, 0($a0)         	# store the lesser numbers contents in the lower position in array (swap)
contin:
     addi 	$a0, $a0, 1            	# advance the array to start at the next location from last time
     bne  	$a0, $t0, innerLoop    	# If $a0 != the end of Array, jump back to innerLoop
     bne  	$t1, $0, outterLoop    	# $t1 = 1, another pass is needed, jump back to outterLoop
 
# Print Data
#print:	li	$t2, 5
#	add  	$t1, $zero, $t2  # initialize loop counter to array size
#	la	$s4, array

#out_print:
#	li	$v0, 1		# Print String Syscall
#	lb	$a0, 0($s4)	# Load Contents String
#	syscall
	
#	la  	$a0, space       # load address of spacer for syscall
#	li   	$v0, 4           # specify Print String service
#	syscall               # print the spacer string
	
#	addi 	$s4, $s4, 1      # increment address of data to be printed
#	addi 	$t1, $t1, -1     # decrement loop counter
#	bgtz 	$t1, out_print         # repeat while not finished

# Convert Data Back
convertBack:			# Basically trying to undo all of the previous conversions to get sorted buffer
	la	$t7, buffer	# Load address of buffer
	la	$t0, array	# Load address of array
	la	$t2, newline	# Load address of newline
continueAgain:	
	lb	$t1, 0($t0)	# Load byte (int from array)
	beq	$t1, 0, close	# If the end of array, go ahead and close
	addi	$t1, $t1, 48	# Int -> ASCII
	sb	$t1, 0($t7)	# Store byte (char into buffer)
	sb	$t2, 1($t7)	# Add a newline
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

