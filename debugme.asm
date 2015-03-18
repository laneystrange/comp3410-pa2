#name: Hien Vo      
#COMP3410
#March 18, 2015
.data
welcome: .asciiz "Welcome to the mysterious MIPS Program\n"
msg_iterate: .asciiz "Iteration: "
linebreak: .asciiz "\n"

	first: 	.word 21
		.word 14
		.word 26
		.word 39
		
	.text
	la $a0, welcome #la $v0, welcome ---> $v0 changed $a0
	jal printstr
	
	la $s0, first
	ori $s4, 0x0
	
	move $s1, $zero
	
loop: 	slti $s2, $s1, 0x04 #changed slit ---> slti
	#also changed 0x03 to 0x04 so all four numbers are added properly together.
	beq $s2, $zero, end
	lw $s3, 0($s0)
	
	add $s4, $s4, $s3
	addi $s0, $s0, 0x4 # change add ---> addi
	addi $s1, $s1, 1
	la $a0, msg_iterate
	jal printstr
	
	move $a0, $s1
	jal writeint # printstr  ---> writeint because $s1 contains int
	
	la $a0, linebreak
	jal printstr
	
	j loop
	
end: 	move $4, $20
	jal writeint #writeint was not found in the symbol table. Wrote a writeint call.
	#j _exit #_exit not found in symbols table. Changing from j _exit to using li $v0, 10. Then doing a syscall
	li $v0, 10
	syscall
	
printstr: 	li $v0, 4 
		syscall
		jr $ra
		
writeint:	li $v0, 1
		syscall
		jr $ra
