# comp3410-pa2
Solution:
1B: 
Approximately how many errors did you find and have to correct?
5 errors.
Errors include: -slt $s2, $s1, 0x03   	//there are 2 errors in this code
		-move $a0, $s1
            	 jal printstr		//$s1 is an integer so this should printint not printstr
            	-jal writeint		// no writeint label exist plus this suppose to be printint
            	-j _exit		// there are no _exit lable 
		

Why did the program not perform all the iterations as expected?
because the line: slti $s2, $s1, 0x03 that already get correct by syntax.
0x03 will perform 3 iteration then stop but there are 4 iterations should be perform.
change to 0x04 will make it work.

How much easier would the program have been to debug if it had been commented?
It would be much more easier if they clearly comment which register is use for and the constant in the program.
For example: $s4 is the register store the sum of all 4 numbers, the constant 0x03.

