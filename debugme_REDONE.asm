#KENDAL HARRIS
#18 MARCH 2015
#PROGRAMMING ASSIGNMENT 2
#EECE3410

# CAP LOCKED COMMENTS DESCRIBE THE CHANGES THAT WERE MADE BY ME
# lowercase comments describe the functionality of the line (for both modified lines and original lines)

.data
            welcome:  .asciiz "Welcome to the mysterious MIPS Program\n"
            msg_iterate: .asciiz "Iteration: "
           linebreak: .asciiz "\n"
           #ADDED TOTAL MESSAGE THAT WILL DISPLAY BEFORE TOTAL IS SHOWN DURING EACH ITERATION 
           total: .asciiz "TOTAL: "
           
           #creates array first with values [21 14 26 39]
            first:    .word 21
                      .word 14
                      .word 26
                      .word 39        
                      
 .text
            la $a0, welcome #CHANGE THE LOADING LOCATION OF WELCOME FROM $v0 --> $ao __loads welcome message
            jal printstr    #proceeds to pringstr label__prints the welcome message
    
            la $s0, first #loads array into $s0
            ori $s4, $zero,0x0 #CORRECT SYNTAX FOR ORI OPERATION BY ADDING $zero__initialize $s4 with value 0
            move $s1, $zero #set $s1=0 ($s1 sserves as loop counter)
            
            li $t0,4 #NEEDED TO COMPLY WITH THE SLT SYNTAX ON LINE 22(IT REQUIRES 3 REGISTERS, NOT AN IMMEDIATE)__ALSO CAN USE FOR THE ADDITTION TO GET TO THE NEXT WORD IN LINE 26
loop: 	    slt $s2, $s1,$t0 #CHANGED THE SLT REFERENCE TO $t0(TO ACCOUNT FOR ALL THE ARRAY NUMBERS)__as long as $s1 < 3, $s2=1. If $s1 > 3, $s2=0
            beq $s2, $zero, end #if $s2=0 then jump to the end method
            lw $s3, 0($s0) #if $s2=1 then proceed with loop__load the word from $s0 into $s3 (will be added to the cumulative total)
           
            add $s4, $s4, $s3	#adds the current value of $s4 and $s3 and stores it into $s4 ($s4 = $s4 + $s3)
            add $s0, $s0, $t0	#CHANGED 0X04 TO $t0 FOR ADD SYNTAX REASONS__adds 4 to the base address (advance base address to next word in array)
            addi $s1, $s1, 1	#increases $s1 by 1
            
            #PRINT ITERATION NUMBER (PRINTS "Iteration: n" FOR EACH ITERATION)
            la $a0, msg_iterate #loads msg_iterate message
            jal printstr	#proceeds to printstr label__prints the iteration message ("Iteration: ")
            move $a0, $s1	#move the number from $s1 --> $a0 (this is the iteration counter)
            jal writeint	#proceeds to writeint label (to prep to print an integer)__PRINTS THE NUMBER OF ITERATION
            la $a0, linebreak	#loads linebreak message
            jal printstr	#proceeds to printstr label__prints a new empty line
            
            #PRINT TOTAL (PRINTS TOTAL FOR EACH ITERATION)__ADDED BY KENDAL HARRIS
            la $a0, total	#LOAD TOTAL MESSAGE INTO $a0
            jal printstr 	#proceed to printstr label__PRINTS THE TOTAL MESSAGE
            move $a0,$s4	#MOVES THE TOTAL BEING KEPT IN $s4 TO $a0
            jal writeint 	#PROCEEDS TO PRINTSTR LABEL__PRINTS THE CUMULATIVE TOTAL
            la $a0, linebreak	#loads linebreak message
            jal printstr	#proceeds to printstr label__prints a new empty line after total
            
            j loop		#repeat the loop__jump to the loop label
                     
#ADDED TO PRINT INTEGER, NEEDED DUE TO THE REFERENCE FROM LINE 39 (will print integer in $s4)__common to all writeint calls
writeint:    li $v0, 1 #PREP CALL FOR DISPLAYING AN INTEGER
	     syscall   #proceed with display of integer
	     jr $ra    #return to caller

#commom to all printstring calls          
printstr:	li $v0, 4	#PRINTSTR IS CORRECT (CAN BE USED WITH LINE 12 NOW THAT THE LINE WAS MODIFIED)__preps system to pring string
		syscall		#prints string
		jr $ra		#return to caller

#MOVED TO THE VERY END OF PROGRAM SO IT WOULD EXIT PROPERLY
end:	li,$v0,10   #REPLACED ORIGINAL CODE WITH A SYSCALL TO TERMINATE THE PROGRAM PROPERLY__prep system to end program
	syscall	    #terminate the program