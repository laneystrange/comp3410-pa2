Berkeley Willis
3/18/2015
PA2
Dr. Strange


In Problem 1 I tried my best to make the fewest possible changes by modifying the
original and keeping the labels that it originallly had. This meant I had to make
another two labels for writeint, which merely prints the integer that is in $a0,
and exit, which just kills the program. The errors are all marked inside the
modified debugme file. 
There were about 7 errors, if you count not having the labels
coded. It did not perform all hte iterations that we expected, that being expected
4, because the loop only branched to hte end if the "slt $s2, $s1, 0x03" needed to
to take an immediate, so it knows what to do with 0x03, and 0x03 needs to be 4.

In Problem 2 it took a while to understand how the buffer works, but when I figured
it out it wasn't as bad as it seemed. I first had the buffer ready the first symbol,
and if it was a "-" symbol it took sent the next number to a subroutine that handled
negative numbers, even negative double multi-digit numbers because the multi-digit
subroutine was right under it. From there it had an easy sotring subroutine, that 
simply compared two different numbers and if the first one was larger than the
second, it swapped it an started again at the beginning of array again with the 
sorting subroutine. When the sorting was finished it built a string from the same
buffer, by converting all of the digits back to ascii. It did this through basically
the same subroutine's that converted from ascii but backwards of course. It first
checked if the number was negative, if it was it was sent to that section, and if it
was double digit (negative or not) it went to another subroutine. From there it opens
an output file that has been predetermined, and then writes the entire string to the
file at once.

In Problem 3 I found that it was a much like the last problem. The main difference was
the use of pointers, but this did not complicate it much. I used much of the same code,
it was simple because the converter from the buffer stored it in an array. I just took
out the sorting method, and then I merely altered the code that would convert the code
back to ascii. I made it to where it jumped the section of the array from a certain register,
the pointer. From there it takes the number in the 0 position of the array and the pointer
from the 4 position of the array. It then changed the position of the array back to the
starting position, and then takes the number and converts it to ascii. If the pointer is
not -1 it then adds the "->" symbols. Then it loops back to label where it uses the
pointer to adjust the array and starts the entire thing over again until -1 halts it.