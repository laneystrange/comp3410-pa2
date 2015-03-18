#name: Hien Vo      
#partner: Greg Lawrencer
#COMP3410
#March 18, 2015

.data
fnf:	.ascii  "Error: File not found "
file:	.asciiz	"C:\\linkedlist.txt"
cont:	.ascii  "File contents: "
linebreak: .asciiz "\n"
nodepointer: .asciiz "-->"
outtro: .asciiz "Found at position: "
buffer: .space 1024
Array: .word 0:20

 
.text

# Open File
open:
li	$v0, 13	# Open File Syscall
la	$a0, file	
li	$a1, 0	
li	$a2, 0	
syscall
move	$s6, $v0	# Save File Descriptor
blt	$v0, 0, err	# Goto Error
 
# Read Data
read:
li	$v0, 14	# Read File Syscall
move	$a0, $s6	# Load File Descriptor
la	$a1, buffer	# Load Buffer Address
li	$a2, 1024	# Buffer Size
syscall
 
# Take the file, convert it to decimals, add it to a string.
la $s3, Array	#load address to be sorted into s3 register.
li $s4, 0	#Flag to determine if negative
Convert:
#la	$a0, buffer
#li	$a1, 1024
lb	$s1, 0($a1) #current element. s1 = index i.
beqz	$s1, Continue
beq	$s1, '-', IsNegative
addi	$s1, $s1, -48	#ascii convert
ConvertContinue:

addiu	$a1, $a1, 1	#index i = i + 1
lb	$s2, 0($a1) #next element. s2 = i + 1
addi	$s2, $s2, -48	#ascii convert

add	$s5, $s5, $s1	#result = result + i
blt	$s2, $zero, set	#if (i + 1) < 0, then set the number.
			#This means it is not 1-9 but a line break.
li	$t4, 10		#else, result * 10

mult	$s5, $t4	
mflo	$s5
j Convert	

IsNegative:
li $s4, 1	#Flag = 1
addiu $a1, $a1, 1
j Convert

TurnNegative:
sub $s5, $zero, $s5
li $s4, 0
j SetContinue

set:

beq	$s4, 1, TurnNegative
SetContinue:
sw	$s5, 0($s3)	#index = result
xor	$s5, $s5, $s5	#result = 0
addi	$s3, $s3, 4

addiu	$a1, $a1, 1
addiu	$a1, $a1, 1
j	Convert

bne	$s4, 0, Convert
j close

linebreaker:
la	$a0, linebreak
li	$v0, 4
syscall
jr	$ra

 
# Close File
close:
li	$v0, 16	# Close File Syscall
move	$a0, $s6	# Load File Descriptor
syscall
j	done	# Goto End
 
# Error
err:
li	$v0, 4	# Print String Syscall
la	$a0, fnf	# Load Error String
syscall
 
# Done
done:
li	$v0, 10	# Exit Syscall
syscall

Continue:
sw	$s5, 0($s3)	#store the remaining number into the array.

main:
la	$s0, Array
li	$t0, 0	#Current Position
li	$s1, 20	#size of the Array



PrintList:
lw	$a0, 0($s0)	#.data
li	$v0, 1		#print .data
syscall
addi	$s0, $s0, 4
lw	$t2, 0($s0)	#.next



blt	$t2, $zero, prepare
la	$a0, nodepointer
li	$v0, 4
syscall
move $t0, $t2

j IndexAt

ListNext:
lw	$a0, 0($s0)
syscall
j close

move	$t0, $t2
add	$t2, $t2, $t2
add	$t2, $t2, $t2	#index * 4
add	$t3, $s0, $t2	#combine the components for .next's address
lw	$a0, 0($t3)
li	$v0, 1
syscall
move	$s0, $t3
lw	$a0, 0($s0)
syscall
j PrintList

IndexAt:
la	$s0, Array
IndexLoop:
beqz	$t2, PrintList

addi	$s0, $s0, 4


addi	$t2, $t2, -1
j	IndexLoop


prepare:
la	$a0, linebreak
li	$v0, 4
syscall
la	$a0, outtro
syscall
move	$a0, $t0
li	$v0, 1
syscall
j close
