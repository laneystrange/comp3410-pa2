#Enyil Padilla
.data
    STRING: .asciiz "-49"
    input: .asciiz "U:\\PA2_input1.txt" #Name of input
    number: .space 4
    numberror: .asciiz "Something went wrong with the number convertion" #Name of input
    null: .asciiz ""
    list: .word 0:50
    buffer: .space 1024
.text   
li $v0, 13 #Open file syscal
	la $a0, input #loads address of the file
	li $a1, 0 #Read only (0: read, 1: write)
	li $a2, 0 #mode is ignored
	syscall #open file $v0 contains descriptor
	move $s0, $v0 #Saves file descriptor
	blt $v0, 0, error #thros file not found
	li	$v0, 14		# Read File Syscall
	move	$a0, $s0	# Load File Descriptor
	la	$a1, buffer	# Load Buffer Address
	li	$a2, 1024	# how many to read.
	syscall
	li $s3, 0 #counter
	la $t1, number #loads number integer
	move $s2, $t1
	move $s4, $t1
	li $t4, 0 #word counter
	la $s1, list
	move $t5, $v0 #characters read
	li $t3, 0
reader:
	lb $t2, buffer($s3) #loads first digit of buffer
	beq $t2, 0x0a, saveNum #if new line, then save number
	beq $t2, 0x00, saveNum #end of document
	sb $t2, 0($t1) #stores digit into number variable
	addi $t1, $t1, 1 #moves number forward
	addi $s3, $s3, 1 #moves index of buffer forward
	addi $t3, $t3, 1 #bit counter
	blt $s3, $t5, reader
	la $s4, list
	j loopP
saveNum:
	la $t7, null
	lb $t6, 0($t7)
	sb $t6, 0($t1)
	addi    $sp, $sp, -4 #moves stack back
	sw  $s2, 0($sp) #pushes number to convert
	jal     string2int #calls metod        
    	#add     $a0, $s2, $zero  #prints  
    	#jal print_int       # Test print the int as integer.
	#not important#
	sw $s2, 0($s1)
	addi $t4, $t4, 1 #word counter
	move $t1, $s4  #moves index of number back to zero
	move $s2, $s4  #moves index of number back to zero
	addi $s3, $s3, 1 #moves index of buffer forward
	addi $s1, $s1, 4
	li $t3, 0 #resets counter
	blt $s3, $t5, reader
	la $s4, list
	j loopP
loopP:
	lw $a0, 0($s4)
	jal print_int
	addi $s4, $s4, 4
	subi $t4, $t4, 1
	bgtz $t4, loopP
	j error	
main:
    la  $t0, STRING         
    addi    $sp, $sp, -4        
    sw  $t0, 0($sp)         # Let's save STRING to a stack
    jal     string2int      # Let's do the conversion in a subprogram

    # Here we have returned from the subprogram and we have a int in 4($sp). However, the issue is that it gets wrong when string has more than 10 digits.

    lw  $s7, 4($sp)          
    add     $a0, $s7, $zero     
    jal print_int       # Test print the int as integer.
    addi    $v0, $zero, 10      
    syscall             # Shutdown

string2int:
    add $t7, $zero, $t3
    addi $t7, $t7, -1
    li $t8, 0
    addi    $sp, $sp, -4        
    sw  $ra, 0($sp)         # Save the return address to the beginning of the stack $ra
    lw  $s5, 4($sp)         # Load the string from the stack into s5.
    addi    $t0, $zero, 10
    addi    $s2, $zero, 0
    loop:         
    lbu     $t1, ($s5)          # Load unsigned char from array into t1
    addi $t7, $t7, -1
    beqz    $t7, end        # NULL terminator found
    beq     $t1, '-', negative
    cont:
    blt     $t1, 48, nerror      # Check if char is not a digit (ascii<'0')
    bgt     $t1, 57, nerror      # Check if char is not a digit (ascii>'9')
    addi    $t1, $t1, -48       # Converts t1's ascii value to dec value
    mul     $s2, $s2, $t0       # Sum *= 10
    add     $s2, $s2, $t1       # Sum += array[s1]-'0'
    addi    $s5, $s5, 1         # Increment array address
    j   loop                    # Jump to start of loop
negative:
	addi    $s5, $s5, 1
	lbu     $t1, ($s5)
	li $t8, 1
	j cont
end:
    beqz $t8, nn
    sub $s2, $zero, $s2
nn:    
    sw  $s2, 4($sp)     # Save it into stack
    lw  $ra, 0($sp)   
    jr  $ra 

nerror:
	la $a0, numberror
	li $v0, 4
	syscall
error:
    addi    $v0, $zero, 10      
    syscall             # Shutdown

print_string:               
    addi    $v0, $zero, 4       
    syscall             
    jr  $ra             

print_int:
    addi    $v0, $zero, 1       
    syscall             
    jr  $ra 
