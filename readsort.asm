.data
int_array:  .space 200
file: .asciiz "PA2_input2.txt"
buffer: .space 1024
cont:	.ascii  "File contents: "
line: .ascii "\n"
.text

open:
	li	$v0, 13		#open file
	la	$a0, file	# load name
	li	$a1, 0		# flag for read
	li	$a2, 0		# empty
	syscall
	move	$s6, $v0	#save file 

read:
	li	$v0, 14		#read file
	move	$a0, $s6	#load file des
	la	$a1, buffer	#load buffer
	li	$a2, 1024	#set size
	syscall
close:
	li	$v0, 16		#close file
	move	$a0, $s6	#load file
	syscall	
 	
	
main:   la $a1, int_array #load array
	la $a0, buffer #load buffer

cat:	
	lb  $t0, 0($a0) #load first byte
	beq $t0, 45, neg #if - go to neg
	bne $t0, 10, skip #skip if line read
	beq $t0, 10, add  #increase if 10
neg:	li $t7, 1 #flag for negative
add:	addi $a0, $a0, 1 #inc buffer by one
	j cat #start over
	#beq $t0, '\0', store #if null store the file revision made this pretty useless
skip:	lb  $t6, 1($a0) #load byte to check for end of file
	beq $t0, 13, store #new line char go to store
	subi $t1, $t0, 48 #turn ascii to int
	add $t2, $t2, $t1 #store it in a register
	beq $t6, '\0', store #null character go to store
	addi $a0, $a0, 1 #inc buffer
	bne $t6, 13, mult #mult by 10 if more numbers are there
	j cat #go back to start
mult:	mul $t2, $t2, 10 #does the mult
	j cat #go back to start
store:	beq $t7, 0, go  #check flag for negative
	sub $t2, $zero, $t2 #turn into negative
go:	sw $t2, 0($a1) #store it in array
	li $t7,0 #reset flag
	addi $a0, $a0, 1 #inc buffer
	addi $s0, $s0, 1 #inc counter
	addi $a1, $a1, 4 #inc index
	add $t2, $zero, $zero # reset t2
	bne $t6, '\0', cat #go back to start if not at end of the document

sort:	
	la  $t0, int_array #loads address into $t0
	mul $t7, $s0, 4 #gets counter
        add $t0, $t0, $t7 #adds the bytes into t0
        addi $t0, $t0, -4 #removes a couple to avoid an extra 0      
forloop:
        add $t1, $zero, $zero #this is just a flag 
        la  $a0, int_array #load array
loop:
	lw  $t2, 0($a0) #load first index
   	lw  $t3, 4($a0) #loads second index 
    	slt $t5, $t3, $t2 #this sorts it in ascending order and a flag for swap
   	beq $t5, $0, check #check flag for swap
   	addi $t1, $0, 1 #inc flag for loop
   	sw  $t2, 4($a0) #swaps numbers
   	sw  $t3, 0($a0) #swaps numbers
check:
	addi $a0, $a0, 4 #this increments the array
    	bne  $a0, $t0, loop #goes back to the swap loop
    	bne  $t1, $0, forloop #another pass to make sure everything is sorted
	
	
	la $a2, int_array
print:  
	beq $s0, $zero, end	
	li $v0, 1
	lw $a0, 0($a2)
	syscall
	li $v0, 4
	la $a0, line
	syscall
	addi $s0, $s0, -1
	addi $a2, $a2, 4
	bne $s0, $zero, print
	
end:	li $v0, 10
	syscall

