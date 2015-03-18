 .data 
  .ascii  "The file was not found: " 
 .asciiz "PA_input1.txt" 
  .asciiz "sortedtest.txt" 
  .ascii  "File contents: " 
 .asciiz "\n" 
  .space 1024 
 .space 1024 

   
  .text 
 
 open: 
  li $v0, 13  
  la $a0, file 
  li $a1, 0  
  li $a2, 0   
  syscall 
  move $s6, $v0 
  blt $v0, 0, err 
   
  
 read: 
 li $v0, 14  
  move $a0, $s6 # Load File Descriptor 
  la $a1, buffer
  li $a2, 1024 # Buffer Size 
  syscall 
   
 
print:  
   
   
    
 # Close File 
 close: 
  li $v0, 16  # Close File Syscall 
  move $a0, $s6 
  syscall 
  j done  # Goto End 
   
 # Error 
 err: 
  li $v0, 4   
  la $a0, fnf # Load Error String 
  syscall 
   
 # Done 
 done: 
  
  
   
  la $t0, buffer  
  li $t4, 1024 #set byte size 
  li $t2, 0 
  la $t1, list #initialize the array that the buffer is being placed in.  
 loop: 
  lb $s0, 0($t0) 
  beq $s0, 0, sort #branch if character is null 
  beq $s0, 45, skip #branch if character is - 
  beq $s0, 13, skip #branch if character is \ 
  beq $s0, 10, skip #branch if character is n 
   
  subi $s0, $s0, 48  
   
  move $a0, $s0 
  li $v0, 1 
  syscall 
   
  sb $s0, 0($t1) #save byte 
  addi $t9, $t9, 1 #counter for number of values (used later) 
  addi $t1, $t1, 1 #increment the value in the array  
 skip:  
  addi $t0, $t0, 1 #increment the value in memory (buffer)  
   
  #sb $a0, 0($t1)  
   
  addi $t2, $t2, 1 
  
   
  beq $t2, $t4, sort 
   
  j loop 
   
  
 sort: 
   
 main: 
     la  $t0, list      # Copy the base address of your array into $t1 
     add $t0, $t0, 1024    # 4 bytes per int * 10 ints = 40 bytes                               
 outterLoop:             # Used to determine when we are done iterating over the Array 
     add $t1, $0, $0     # $t1 holds a flag to determine when the list is sorted 
     la  $a0, list      # Set $a0 to the base address of the Array 
 innerLoop:                  # The inner loop will iterate over the Array checking if a swap is needed 
     lb  $t2, 0($a0)         # sets $t0 to the current element in array 
   lb  $t3, 1($a0)         # sets $t1 to the next element in array 
     slt $t5, $t2, $t3       # $t5 = 1 if $t0 < $t1 
     beq $t5, $0, continue   # if $t5 = 1, then swap them 
     add $t1, $0, 1          # if we need to swap, we need to check the list again 
    sb  $t2, 1($a0)         # store the greater numbers contents in the higher position in array (swap) 
     sb  $t3, 0($a0)         # store the lesser numbers contents in the lower position in array (swap) 
 continue: 
     addi $a0, $a0, 1            # advance the array to start at the next location from last time 
     bne  $a0, $t0, innerLoop    # If $a0 != the end of Array, jump back to innerLoop 
     bne  $t1, $0, outterLoop    # $t1 = 1, another pass is needed, jump back to outterLoop 
 
 
 init:  
  li $t3, 1024 
  li $t2, 0 
  la $t1, list 
  add $t1, $t1, $t9 
  subi $t1, $t1, 1 
   
  la $a0, LB 
  li $v0, 4 
  syscall 
  
 print2:   
  lb $a0, 0($t1) 
  li $v0 1 
  syscall 
  subi $t1, $t1, 1 #increments array memory value 
  subi $t9, $t9, 1 #decrement counter  
  beq $t9, $t2, end 
   
  j print2 
   
    
 end: 
 la $t0, list 
  
 
 li   $v0, 13       
 la   $a0, fout     # output file name 
 li   $a1, 1        # Open for writing (flags are 0: read, 1: write) 
 li   $a2, 0        #ignore mode 
 syscall            # open a file (file descriptor returned in $v0) 
 move $s6, $v0      # save the file descriptor  
  
 
 li   $v0, 15       
 move $a0, $s6      # file descriptor  
 la   $a1, list  
 li   $a2, 1024       
 syscall            
  
 
 li   $v0, 16       # system call for close file 
 move $a0, $s6      # file descriptor to close 
 syscall 
