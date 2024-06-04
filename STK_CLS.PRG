/*
* PRG...............: STK_CLS.PRG
* CLASS.............: Stack Implementation Class
* DESC..............: Performs the Pushing & Poping actions
*
* EXPORTS...........: Push (object,cargo), Pop (object)
* CONSTRUCTOR.......: NewStack ()
*
* USES..............: Standard Clipper Fucntions
* NOTES.............: The Constructor returns a object, which is 
*					   an array that can be used as a stack.
*
* AUTHOR............: venkata rangan, tnc
* DATE..............: 20-04-1995.
* PROJECT...........: Alankar Travels Billing Program.
*
* COMPILER..........: CA-Clipper 5.2
* SWITCHES..........: /n /w /m
*/

FUNCTION NewStack ()
RETURN { }

PROCEDURE Push (aStack,Cargo)
  AADD (aStack, Cargo)
RETURN 

FUNCTION Pop (aStack)
LOCAL Cargo
	Cargo := ATAIL (aStack)
	ASIZE (aStack, LEN(aStack) - 1) 	
RETURN Cargo
