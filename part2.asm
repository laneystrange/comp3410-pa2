#name: Hien Vo      
#partner: Greg Lawrencer
#COMP3410
#March 18, 2015

.data
fnf:	.ascii  "The file was not found: "
file:	.asciiz	"C:\\PA2-input2.txt"
cont:	.ascii  "File contents: "
linebreak: .asciiz "\n"
buffer: .space 1024
sorted: .word 0:20

 
.text

# Open File
open:
li	$v0, 13	# Open File Syscall
la	$a0, file	# Load File Name
li	$a1, 0	# Read-only Flag
li	$a2, 0	# (ignored)
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
la $s3, sorted	#load address to be sorted into s3 register.
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

#lb	$t1, ($a1)
#move	$a0, $t1
#li	$v0, 11	# Print Character Syscall
#la	$a0, cont	# Load Contents String
#syscall
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
    la  $t0, sorted      # Copy the base address of your array into $t1
    add $t0, $t0, 80    # 4 bytes per int * 20 ints = 80 bytes                              
outterLoop:             # Used to determine when we are done iterating over the Array
    add $t1, $0, $0     # $t1 holds a flag to determine when the list is sorted
    la  $a0, sorted      # Set $a0 to the base address of the Array
innerLoop:                  # The inner loop will iterate over the Array checking if a swap is needed
    lw  $t2, 0($a0)         # sets $t0 to the current element in array
    lw  $t3, 4($a0)         # sets $t1 to the next element in array
    slt $t5, $t2, $t3       # $t5 = 1 if $t0 < $t1
    beq $t5, $0, Next   # if $t5 = 1, then swap them
    add $t1, $0, 1          # if we need to swap, we need to check the list again
    sw  $t2, 4($a0)         # store the greater numbers contents in the higher position in array (swap)
    sw  $t3, 0($a0)         # store the lesser numbers contents in the lower position in array (swap)
Next:
    addi $a0, $a0, 4            # advance the array to start at the next location from last time
    bne  $a0, $t0, innerLoop    # If $a0 != the end of Array, jump back to innerLoop
    bne  $t1, $0, outterLoop 
    
la	$s0, sorted
li	$s1, 20

    print:
lw	$a0, 0($s0)
li	$v0, 1
syscall
addi	$s0, $s0, 4
addi	$s1, $s1, -1
la	$a0, linebreak
li	$v0, 4
syscall
beqz	$s1, close
j print
