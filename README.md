### Claire Skaggs
##### COMP 3410
##### Programming Assignment 2

###### PART ONE

My answer to part one A is located in the original debugme.asm file, which I have modified.
My answer to part one B is as follows:


Initally, as mentioned in the instructions, debugme.asm failed to assemble.
In total, I made six changes to debugme.asm to ensure that the program both assembles and functions properly.

1. The 'welcome' string was incorrectly loaded into the syscall call register, $v0. I changed this to correctly load into the argument register, $a0.
2. There was a jump to a function label called 'writeint' which did not exist. I created it, along with its function, such that it would print an integer then return.
3. I changed the line 'slt $s2, $s1, 0x03' to 'slti, $s2, 4' to ensure that the loop function passed through all four iterations correctly.
4. There was an incorrect jump to the 'printstr' function to print the integer value in register $s1, rather than the correct jump to the 'writeint' function. I changed this.
5. Inside the 'end' function, I changed the line 'move $4, $20' to 'move $a0, $s4', which correctly prepares the register $s4, holding the sum, for printing.
6. Inside the 'end' function, there was an incorrect jump to a label called '_exit'. This label was changed to 'exit'.

The program failed to iterate through the loop for enough passes, as the counter register $s1 was checked with 'slt $s2, $s1, 0x03' rather than 'slti, $s2, 4'.
In other words, it was seeing if the value of register $s1 was less than 3.
This meant it looped 3 total times before exiting:

1. $s1 = 0
2. $s1 = 1
3. $s1 = 2
4. exit loop.

The version I altered instead loops 4 total times before exiting:

1. $s1 = 0
2. $s1 = 1
3. $s1 = 2
4. $s1 = 3
5. exit loop.

After these modifications, debugme.asm has the following output when executed:

- Welcome to the mysterious MIPS Program
- Iteration: 1
- Iteration: 2
- Iteration: 3
- Iteration: 4
- 100

The program would have been much easier to debug if it had fully commented code from the start.
MIPS, or Assembly in general, is fairly arcane and difficult to follow.
Commenting the code gives the reader a window into the thought process behind the code.
In my modified version, I commented all of the instructions, both the original lines and my additions.

###### PART TWO

My answer to part two is located in parttwo.asm.
The two input files are PA_input1.txt and PA_input2.txt respectively.
The two output files are PA_output1.txt and PA_output2.txt respectively.

###### PART THREE

My answer to part three is located in partthree.asm.