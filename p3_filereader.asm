	.data
fnf:	.ascii "The file was not found: "
file: 	.asciiz "/home/miguel/Documents/Assembly/Pa2_solutions/pa2_input1" 
cont:	.ascii	"File contents: "
buffer:	.space	1024

	.text
	
# Open file

open:	
	li	$v0, 13		#open file syscall
	la	$a0, file	# load file name
	li	$a1, 0		# read-only flag
	li	$a2, 0		# (ignored)
	syscall
	move	$s6, $v0	# Save file descriptor
	blt	$v0, 0, err	# Goto Error
	
#Read data

read:	
	li 	$v0, 14		#Read file syscall
	move	$a0, $s6	#load file descriptor
	la 	$a1, buffer	#load buffer address
	li	$a2, 1024	#buffer size
	syscall

print:
	li	$v0, 4		#print String syscall
	la	$a0, cont	#load contents string
	syscall
	
#close file
close:
	li	$v0, 16		#close file syscall
	move	$a0, $s6	#load file descriptor
	syscall	
	j	done		#goto end
	
#error
err:
	li	$v0, 4		#print string syscall
	la	$a0, fnf	#load error string
	syscall

# done
done:
	li	$v0, 10		#exit Syscall
	syscall	

