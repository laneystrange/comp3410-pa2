# COMP3410
# Author: Michael Vance
# Assignment: PA[2]
# Date: 3/14/2015

# partThree.asm
	
	.data
fnf:		.ascii  "The file was not found: "
file:		.asciiz	"C:\\input.txt"
file_out:	.asciiz "C:\\output.txt"		# Output file, needs to be changed for output2
buffer: 	.space 1024
output_msg: 	.asciiz "Here is my linked list: "
output_msg2: 	.asciiz ". The end of the list was found at position "
output_msg3: 	.asciiz "."
pointer: 	.asciiz "->"
elements:	.word 0:10
indices:	.word 0:10
 
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
	la	$t6, elements
	la	$t7, indices	# Load address for array
contElements:	
	lb	$t1, 0($t0)		# Load byte (first digit from buffer "string")
	beq	$t1, 45, specEle	# If "-" go to special
	beq	$t1, 13, specEle	# If "\" go to special
	beq	$t1, 10, specEle	# If "newline" go to special
	beq	$t1, 0, print		# If end of string/buffer go ahead and sort
	addi	$t1, $t1, -48		# Convert ASCII to int by -48
	sb	$t1, 0($t6)		# Store byte (the digit) into array
	addi	$t6, $t6, 1		# Increment array
specEle:
	addi	$t0, $t0, 2		# Increment buffer
	j contElements			# Loop again	
contIndices:
	lb	$t1, 1($t0)		# Load byte (first digit from buffer "string")
	beq	$t1, 45, specInd	# If "-" go to special
	beq	$t1, 13, specInd	# If "\" go to special
	beq	$t1, 10, specInd	# If "newline" go to special
	beq	$t1, 0, print		# If end of string/buffer go ahead and sort
	addi	$t1, $t1, -48		# Convert ASCII to int by -48
	sb	$t1, 0($t7)		# Store byte (the digit) into array
	addi	$t7, $t7, 1		# Increment array
specInd:
	addi	$t0, $t0, 2		# Increment buffer
	j contIndices			# Loop again
 
# Print Data
print:	
	li	$v0, 4		# Print String Syscall
	la	$a0, output_msg	# Load Contents String
	syscall
	
	li	$v0, 4		# Print String Syscall
	la	$a0, output_msg2	# Load Contents String
	syscall
	
	li	$v0, 4		# Print String Syscall
	la	$a0, output_msg3	# Load Contents String
	syscall
 
# Close File
close:
	li	$v0, 16		# Close File Syscall
	move	$a0, $s6	# Load File Descriptor
	syscall
	j	done		# Goto End
 
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
	li	$v0, 10		# Exit Syscall
	syscall

