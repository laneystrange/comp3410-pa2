	.data
fnf:	.ascii  "The file was not found: "
file:	.asciiz	"C:\\Users\\Frank\\Desktop\\test.txt"
buffer: .space 1024
array: 	.word 0:50 	#create an empty array of 50 words

 
	.text
 
# Open File
open:	li	$v0, 13		# Open File Syscall
	la	$a0, file	# Load File Name
	li	$a1, 0		# Read-only Flag
	li	$a2, 0		# (ignored)
	syscall
	move	$s6, $v0	# Save File Descriptor
	blt	$v0, 0, err	# Goto Error
 
# Read Data
read:	li	$v0, 14		# Read File Syscall
	move	$a0, $s6	# Load File Descriptor
	la	$a1, buffer	# Load Buffer Address
	li	$a2, 1024	# Buffer Size
	syscall
	
	jal close
	

	la 	$s0, buffer	#load buffer address
	
#load values to array
load:	lb	$t0, ($s0) 	#load byte to $t0
	addi 	$s0, $s0, 1 	#increment to next byte	address
	addi 	$t0, $t0, -45 	#begin conversion from asscii to decimal
	
	bltz 	$t0, load
	bgtz 	$t0, parsep
	beqz 	$t0, parsen

 	 
 	
 
# Close File
close:	li	$v0, 16		# Close File Syscall
	move	$a0, $s6	# Load File Descriptor
	syscall
	j	$ra		# Goto End
	
 
# Error
err:	li	$v0, 4		# Print String Syscall
	la	$a0, fnf	# Load Error String
	syscall
 
# Done
exit:	li	$v0, 10		# Exit Syscall
	syscall
	
	
parsep:	
	
parsen:



