/*
* INCLUDE...........: TAIL_CLS.CH
* PRG...............: TAIL_CLS.PRG
* CLASS.............: Number integrity Class
* DESC..............: Attaches and checks the Tail digit padded to numbers.
* EXPORTS...........: Nil
* CONSTRUCTOR.......: NewTail ()
* STATIC FUNCTIONS..: TailDigit ()
* USES..............: Standard Clipper Fucntions
* NOTES.............: The Constructor returns a object, which
*                      contains code blocks, that should be EVALuated.
*
* EXAMPLE...........: You can use my APPLY command and apply methods
*		      to the object instead of EVAL function.
*                     X := EVAL (oTail:Tail,10) can be written as 
*		      X := APPLY oTail:Tail(10)		 	
*
* AUTHOR............: venkata rangan, tnc  & madhu, s.
* DATE..............: 20/04/1995
* PROJECT...........: Alankar Travels Billing Program.
*
* COMPILER..........: CA-Clipper 5.2
* SWITCHES..........: /n /w /m
*/

#define TAIL_SIZE        6

#define TAIL_PACKET      1
#define TAIL_TAIL        2
#define TAIL_VALID       3

#define TAIL_DATA        4
#define TAIL_ELEVEN      5
#define TAIL_BOTH        6

#xtranslate :Packet             =>      \[TAIL_PACKET\]
#xtranslate :Tail               =>      \[TAIL_TAIL\]
#xtranslate :Valid              =>      \[TAIL_VALID\]
#xtranslate :Data               =>      \[TAIL_DATA\]
#xtranslate :Eleven             =>      \[TAIL_ELEVEN\]
#xtranslate :Integrity          =>      \[TAIL_BOTH\]

