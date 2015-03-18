#Justin Hiller
#Comp 3410
#Programming Assignment 2 
#Problem 2	
	
	.data
fnf:	.ascii  "The file was not found: "
file:	.asciiz	"C:\\Users\\Justin\\Documents\\input1.txt"
cont:	.ascii  "File contents: "
inputBuffer: .space 1024
outputBuffer: .space 1024
outputFile:	.asciiz "C:\\Users\\Justin\\Documents\\output1.txt"
 
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
	la	$a1, inputBuffer	# Load Buffer Address
	li	$a2, 1024	# Buffer Size
	syscall
 
# Print Data
print:
	li	$v0, 4		# Print String Syscall
	la	$a0, cont	# Load Contents String
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
 
# Done
done:
	li	$v0, 10		# Exit Syscall
	syscall
