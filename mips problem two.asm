	.data
fnf:	.ascii  "The file was not found: "
file:	.asciiz	"C:\\data.txt"
cont:	.ascii  "File contents: "
buffer: .space 1024
 
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