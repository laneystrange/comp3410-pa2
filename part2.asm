	.data
fnf:	.ascii  "The file was not found: "
file:	.asciiz	"C:\\Users\\Frank\\Desktop\\test.txt"
lbreak:	.ascii	"\n"
buffer: .space 1024
array: 	.word 0:50 	#create an empty array of 50 words
obuff:	.space 1024
outfile:.asciiz "testOut.txt"
temp:	.space 50

 
	.text
 
 	move	$s7, $zero	#prep s7 as trigger for first array value
 	li 	$s1, 10		#preparing s1 for later
	la 	$s4, array	#load array address to s4v
 
 
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
	
	j close
	

pl:	la 	$s0, buffer	#load buffer address
	
#load values to array
load:	lb	$t0, ($s0) 	#load byte to $t0
	addi 	$s0, $s0, 1 	#increment to next byte	address
	addi 	$t0, $t0, -45 	#begin conversion from asscii to decimal
	
	
	beq 	$t0, -45, ps
	bltz 	$t0, load
	bgtz 	$t0, parsep
	beqz 	$t0, parsen

	
 	 
 	
 
# Close File
close:	li	$v0, 16		# Close File Syscall
	move	$a0, $s6	# Load File Descriptor
	syscall
	j	pl		# Goto End
	
 
# Error
err:	li	$v0, 4		# Print String Syscall
	la	$a0, fnf	# Load Error String
	syscall
 
# Done
exit:	li	$v0, 10		# Exit Syscall
	syscall
	
	
parsep:	addi 	$s2, $t0, -3	#finish conversion to ascii
	
	lb	$t0, ($s0)	#load next byte into t0
	addi 	$t0, $t0, -48	#ascii conversion begining
	addi 	$s0, $s0, 1	#increment address for next byte
	j loadloop
			
loadloop:	bltz	$t0, save
	
	mul	$s2, $s2, $s1	#multiply the current t1 by 10
	add	$s2, $s2, $t0	#add t0 to t1
	
	lb	$t0, ($s0)	#load next byte into t0
	addi 	$t0, $t0, -48	#ascii conversion begining
	addi 	$s0, $s0, 1	#increment address for next byte
	j 	loadloop

parsen:
	lb	$t0, ($s0)	#load next byte into t0
	addi 	$t0, $t0, -48	#ascii conversion begining
	addi 	$s0, $s0, 1	#increment address for next byte
	
	mul 	$s2, $t0, -1
	
	lb	$t0, ($s0)	#load next byte into t0
	addi 	$t0, $t0, -48	#ascii conversion begining
	addi 	$s0, $s0, 1	#increment address for next byte
	
	
negativeloadloop:	bltz	$t0, save
	
	mul	$s2, $s2, $s1	#multiply the current t1 by 10
	sub	$s2, $s2, $t0	#add t0 to t1
	
	lb	$t0, ($s0)	#load next byte into t0
	addi 	$t0, $t0, -48	#ascii conversion begining
	addi 	$s0, $s0, 1	#increment address for next byte
	j 	negativeloadloop

save: 	sw 	$s2, ($s4)	#add the value to the array
	addi 	$s4, $s4, 4	#INCREMENT Address in the array
	j load			#jump back to the load procedure
	
	
ps:	sw 	$t0, ($s4)	#add the value to the array
	
psort:	la 	$s4, array	#get initial array address
	li 	$t7, 1
	
sort:	lw	$t0, ($s4)	#load array int at a[i]
	lw	$t1, 4($s4)	#load next array int
	
	bge 	$t1, $t0, sortgreat

sortless:
	sw	$t1, ($s4)	#move a[i+1] to a[i]
	sw	$t0, 4($s4)	#move a[i] to a[i+1]
	
	addi 	$s4, $s4, 4	#increment array address to next value
	
	lw 	$t0, 4($s4)	#load next array value
	
	li 	$t7, 5		#set t7 as a flag
	
	bne $t0, -45, sort
	
	j 	psort	
	

sortgreat:
	addi $s4, $s4, 4	#increment array address
	lw $t0, 4($s4)	#load next value in the array	
	
	bne	$t0, -45, sort
	
	beq 	$t7, 5, psort
	la 	$s4, array
	
	
toAscii:
	la 	$s0, obuff	#load address for out buffer in s0
	la	$s1, temp	#load the temp space
	move	$t5, $zero	#prep counter
	lw 	$t0, ($s4)	#load current array value
	addi	$s4, $s4, 4	#increment array
	
	beq	$t0, -45, fileout
	
converloop:
	bltz	$t0, negative
	bge	$t0, 10, btone
	
	addi	$t0, $t0, 48
	
saveb:	sb	$t0, ($s0)
	addi	$s0, $s0, 1
	li 	$t0, 32
	sb	$t0, ($s0)
	addi	$s0, $s0, 1
	
	lw 	$t0, ($s4)	#load current array value
	addi	$s4, $s4, 4	#increment array
	
	beq	$t0, -45, fileout
	j converloop
	
negative:
	li $t1, 45	#ascii negative symbol
	sb $t1, ($s0)
	addi $s0, $s0, 1
	
	mul $t0, $t0, -1
	
	bge $t0, 10, btone
	
	addi	$t0, $t0, 48
	j	savebs
	
btone:
	rem	$t1, $t0, 10
	div	$t0, $t0, 10
	
	addi	$t1, $t1, 48
	
	sb	$t1, ($s1)
	addi	$s1, $s1, 1
	addi	$t5, $t5, 1
	
	bge $t0, 10, btone
	addi	$t0, $t0, 48
	sb	$t0, ($s1)
	addi	$s0, $s1, 1
	addi	$t5, $t5, 1
	j savebs

savebs:
	lb	$t0, ($s1)
	sb	$t0, ($s0)
	addi	$s0, $s0, 1
	addi	$s1, $s1, -1
	addi	$t5, $t5, -1
	
sbsloop: beqz 	$t5, sbsfin
	lb	$t0, ($s1)
	sb	$t0, ($s0)
	addi	$s0, $s0, 1
	addi	$s1, $s1, -1
	addi	$t5, $t5, -1
	j sbsloop
	
sbsfin:	li 	$t0, 32
	sb	$t0, ($s0)
	addi	$s0, $s0, 1
	
	lw 	$t0, ($s4)	#load current array value
	addi	$s4, $s4, 4	#increment array
	
	beq	$t0, -45, fileout
	j converloop
		
	
fileout:
	la	$s0, obuff	#load obuff
	li	$v0, 13		#prep syscall for file out
	la	$a0, outfile	#output file name
	li	$a1, 1		#open for writing
	li 	$a2, 0		#mode is ignored
	syscall
	move $s6, $v0		#save file descrip

filewrite:
	li	$v0, 15		#syscall for writing to a file
	move 	$a0, $s6	#file descrip
	move 	$a1, $s0	#load buffer address
	li 	$a2, 1024	#buffer length
	syscall
	
outclose:
	li 	$v0, 16		#syscall for close file 
	move	$a0, $s6	#file descrip
	syscall 		#close file
	
	j	exit


