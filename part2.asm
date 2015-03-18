.data
fnf: .asciiz "404 file not found ;_;7"
inname1: "/home/skyvizer/comp3410/pa2/comp3410-pa2/PA2_input1.txt"
inname2: "/home/skyvizer/comp3410/pa2/comp3410-pa2/PA2_input2.txt"
outname1: "/home/skyvizer/comp3410/pa2/comp3410-pa2/PA2_output1.txt"
outname2: "/home/skyvizer/comp3410/pa2/comp3410-pa2/PA2_output1.txt"
buffer: .space 1024

.text
la $s5, buffer		#s5 is current buffer position. we start at the start, obviously
li $v0, 13
la $a0, inname1
li $a1, 0
li $a2, 0
syscall
move $s7, $v0
bltz $v0, error
jal fillbuffer
jal readnum
la $t1, buffer
lb $t2, 1($t1)
#la $t0, buffer
#lw $t1, 0($t0)
la $a0, buffer
jal printchar
j _end

error:
li $v0, 4
la $a0, fnf
syscall
j _end

fillbuffer:
li $v0, 14
move $a0, $s7
la $a1, buffer
li $a2, 1024
syscall
jr $ra

printchar:
li $v0, 4
syscall

atoi:
addi $sp, $sp, -1
sw $sp, $ra
loop:
lb $t0, 0($s5)	#read the next byte
beq $t0, 10, rlend	#if it's a newline, we have everything we need
addi $s6, $s6, 1	#counter for how many digits we've stored
addi $sp,$sp, -1	#appropriately allocate space
sw $t0, 0($sp)	#store
addi $s5, $s5, 1	#move on to next byte
j loop
rlend:
addi $s5, $s5, 1	#skip over the \n
jr $ra

_end:
li $v0, 10
syscall
