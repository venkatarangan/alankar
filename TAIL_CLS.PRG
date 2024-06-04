/*
* PRG...............: TAIL_CLS.PRG
* INCLUDE...........: TAIL_CLS.CH
* CLASS.............: Number integrity Class
* DESC..............: Attaches and checks the Tail digit padded to numbers.
* EXPORTS...........: Nil
* CONSTRUCTOR.......: NewTail ()
* METHODS...........: Tail(), Packet(), Data(), Valid(),
*				      Eleven() & Integrity()
* EXAMPLE...........: You can use my APPLY command and apply methods
*                     to the object instead of EVAL function.
*		      X := EVAL (oTail:Tail,10) can be written as 
*		      X := APPLY oTail:Tail(10)		 	
*
* STATIC FUNCTIONS..: TailDigit ()
* USES..............: Standard Clipper Fucntions
* NOTES.............: The Constructor returns a object, which
*                     contains code blocks, that should be EVALuated.
* AUTHOR............: venkata rangan, tnc  & madhu, s.
* DATE..............: 20-04-1995
* PROJECT...........: Alankar Travels Billing Program.
* COMPILER..........: CA-Clipper 5.2
* SWITCHES..........: /n /w /m
*/
#include "Tail_Cls.Ch"
#include "Apply.Ch"

FUNCTION NewTail
LOCAL oTail[TAIL_SIZE]

// returns the coded number by accepting a number.
oTail:Packet    := { |x| (x * 10) + TailDigit(x) }
// returns the tail digit alone for a number.
oTail:Tail      := { |x| TailDigit (x) }
// returns the data from a coded number
oTail:Data      := { |x| INT (x/10) }
// checks the tail digit and the coded number for a match
oTail:Valid     := { |x| IIF (INT(x % 10) == TailDigit (INT(x/10)),.T.,.F.) }
// checks whether a coded number's data is a multiple of 11
oTail:Eleven    := { |x| IIF(INT(EVAL(oTail:Data,x)%11)==0,.T.,.F.) }
// checks the complete integrity of a coded number (11 based data) 
oTail:Integrity := { |x| EVAL(oTail:Eleven,x) .AND. EVAL(oTail:Valid,x) }
RETURN oTail

/* 
*   This function is visible only in this program file. 
*   Uses a logic of recursive addition of a numbers digits,
*   till u arrive at a single digit number.
*/
STATIC FUNCTION TailDigit (nVal)
LOCAL nX,nV
DO WHILE nVal >9
    nV := 0
    DO WHILE nVal !=0
        nX := INT(nVal % 10)
        nV += nX
        nVal := INT(nVal/10)
    ENDDO
    nVal := nV
ENDDO
RETURN nVal