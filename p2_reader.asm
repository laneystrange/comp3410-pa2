# problem 2 solution
# sorts a list of integers from file
# by kevin fisher

.data
	intbuffer: .space 256	# space for storing integers
	inputbuffer: .space 4096	# input buffer for file + console input. 4096 bytes should be plenty of space
	welcomemessage: .asciiz "Welcome to the Fisher Number Sorter.\nLoading file..\n"
	errormessage: .asciiz "There was an error opening that file!"
	completemessage: .asciiz "Results:"
	newline: .asciiz "\n"
	
	
	filepath: .asciiz "/Users/kevin/comp3410-pa2/p2_input2.txt"

.text
	la $a0, welcomemessage
	jal printstr		#print welcome message
	
	# inputbuffer now holds path to file
	la $a0, filepath
	jal openfile		# open the file
	
	
	la $a1, inputbuffer
	jal readfile		# will read up to 4096 bytes from file into inputbuffer
	move $s0, $v0		# save number of bytes read
	
	jal closefile
	
	la $s1, inputbuffer	# put address of buffer in s1
	la $v1, inputbuffer	# also put it in v1
	la $s2, intbuffer	# save pointer to buffer in s2
	move $s3, $zero		# set integer count to zero
loopread:	
	# first we must check if we are about to read past the end of the file
	sub $t0, $v1, $s1
	bge $t0, $s0, endread
	# ok, now just read the next integer
	move $a0, $v1
	jal stringtoint
	sw $v0, 0($s2)		# save result in buffer
	addi $s2, $s2, 4	# move foward 32 bits
	addi $s3, $s3, 1	# increment counter by 1
	j loopread # and repeat
	
endread:
	# ok, now we have ints loaded to the buffer.
	# we must sort it.
	li $s4, 1 # current int index
	la $s5, intbuffer # address of the filled buffer
sortloop:
	# this is just a really simple sort algo.
	# we scan down the ints, looking at the current and next one
	# if we notice something out of order,
	# we swap and then start again.
	bge $s4, $s3, printresults # if we have read all ints, we are done
	lw $t0, 0($s5)	#t0 = current int
	lw $t1, 4($s5)	#t1 = next int
	bgt $t0, $t1, fixsort
	addi $s5, $s5, 4	# move location forward 4
	addi $s4, $s4, 1	# move int index forward 1
	j sortloop
	
fixsort:
	# swap current and next ints, then start over
	sw $t0, 4($s5)
	sw $t1, 0($s5)
	j endread
	
	
printresults:
	li $s4, 0		# current print index
	la $s5, intbuffer	# current place in the buffer
	la $a0, completemessage # print completion message
	jal printstr
loopprint:
	la $a0, newline
	jal printstr
	lw $a0, 0($s5)
	jal printint
	addi $s4, $s4, 1
	addi $s5, $s5, 4
	blt $s4, $s3, loopprint

	li $v0, 10
	syscall
	
	
	
printstr:
	li $v0, 4	# syscall 4 = print string
	syscall
	jr $ra
	
printint:
	li $v0, 1
	syscall
	jr $ra
	
readstr:
	li $v0, 8	# syscall 8 = read string
	syscall
	jr $ra
	
openfile:
	li	$v0, 13		# Open File Syscall
	li	$a1, 0		# Read-only Flag
	li	$a2, 0		# (ignored)
	syscall
	move	$s6, $v0	# Save File Descriptor
	blt	$v0, 0, err	# Goto Error
	jr $ra
	
closefile:
	li	$v0, 16		# Close file Syscall
	move $a0, $s6		
	syscall
	jr $ra
	
readfile:
	li	$v0, 14		# Read File Syscall
	move	$a0, $s6	# Load File Descriptor
	li	$a2, 4096	# Buffer Size
	syscall
	jr $ra
	
err:
	la $a0, errormessage
	jal printstr
	
# this is heavily based off the atoi implementation from
# http://www.cmi.ac.in/~nivedita/subjects/CO/mips-material/atoi-3.asm
# but i've made some changed, and typed it all myself (no copy-paste!)
# it now also returns the new string pointer in $v1
stringtoint:
	# the string is passed in via $a0
	# we're going to return the int in $v0
	# first thing we have to do is check for -
	
	move $v0, $zero 	# init return to 0
	move $v1, $zero 	# if there's overflow, this will be set
	
	lb $t0, 0($a0) 		# load the first character into t0
	beq $t0, '-', negvalue 	# if the char is '-', then branch to negvalue
	
	li $t2, 1 		#else, it is possitive, so set 1
	
	j create_value
	
negvalue:
	li $t2, -1		# set value to multiply by to -1
	addi $a0, $a0, 1	# move location forward 1

create_value:
	lb $t0, 0($a0)		# load current char into t0
	addi $a0, $a0, 1	# advance location by 1
	slti $t3, $t0, '0'	# if char value is < 0..
	bne $t3, $zero, done	# then go to done
	slti $t3, $t0, ':'	# if char value is > 9..
	beq $t3, $zero, done	# then go to done
	li $t3, 10		# t3 = 10
	mult $v0, $t3		# hi/lo registers = v0 * 10
	mfhi $t3		# see if there was overflow
	bne $t3, $zero, setvalue# set $v1 to reflect overflow
	mflo $v0		# else get the lo value
	slt $t3, $v0, $zero	# make sure it isn't negative
	bne $t3, $zero, setvalue# if it is negative,
	
	addi $t0, $t0, -48	# t0 = s0 - '0'
	addu $v0, $v0, $t0	# add t0 to value
	slt $t3, $v0, $zero	# make sure it isn't negative
	bne $t3, $zero, setvalue#if negative, set $v0 to reflect it
	
	j create_value		# else, continue adding
	
	nop
	
setvalue:
	move $v1, $zero
	add $v0, $zero, $zero
	jr $ra
	
done:
	mul $v0, $v0, $t2
	move $v1, $a0		#place new string pointer in v1
	jr $ra
