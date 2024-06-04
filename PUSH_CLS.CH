/*
* INCLUDE...........: PUSH_CLS.CH
* PRG...............: PUSH_CLS.PRG
* DATABASE FILES....: NIL
* CLASS.............: Push Button implementation Class
* DESC..............: Creates and Implements buttons
* EXPORTS...........: Nil
* CONSTRUCTOR.......: NewPush  ()
* METHODS...........: PushShow () 
* STATIC FUNCTIONS..: Show()
* USES..............: Standard Clipper Functions
*       	          Stack Class - STK_CLS.PRG, CLR_CLS.PRG
*			  & APPLY.CH
*      	
* NOTES.............: The Constructor returns a object, which
*                     contains one code block and elements which
*	              have Push button elemenst.
*
* AUTHOR............: venkata rangan, tnc
* DATE..............: 20/04/1995
* PROJECT...........: Alankar Travels Billing program.
*
* COMPILER..........: CA-Clipper 5.2
* SWITCHES..........: /n /w /m
*/

#define  PUSHSIZE 		4

#xtranslate :PushRow		=>	\[1\]
#xtranslate :PushCol		=>	\[2\]
#xtranslate :PushDefault	=>	\[3\]
#xtranslate :PushButtons 	=>	\[4\]
#xtranslate :PushShow           =>      \[5\]