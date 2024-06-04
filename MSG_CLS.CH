/*
* INCLUDE...........: MSG_CLS.CH
* PRG...............: MSG_CLS.PRG
* DATABASE FILES....: NIL
* CLASS.............: Message Box implementation Class
* DESC..............: Creates and Implements Message Boxes
* EXPORTS...........: Nil
* CONSTRUCTOR.......: NewMessage  ()
* METHODS...........: MsgShow () 
* STATIC FUNCTIONS..: Show()
* USES..............: Standard Clipper Functions
*                     Classes -> STK_CLS, SHAD_CLS, CLR_CLS.PRG & PUSH_CLS
* 	              Include Files-> Apply.Ch
*      	
* NOTES.............: The Constructor returns a object, which
*                     contains one code block and elements which
*	  	      have Message Box elements.
*
* AUTHOR............: venkata rangan, tnc & madhu, s.
* DATE..............: 20/04/1995
* PROJECT...........: Alankar Travels Billing program.
*
* COMPILER..........: CA-Clipper 5.2
* SWITCHES..........: /n /w /m
*/

#define MSG_SIZE         4

#define MSG_TITLE        1
#define MSG_TEXT         2 
#define MSG_DEFAULT      3
#define MSG_BUTTONS      4
#define MSG_SHOW         MSG_SIZE+1

#xtranslate :MsgTitle   => \[MSG_TITLE\]
#xtranslate :MsgText    => \[MSG_TEXT\]
#xtranslate :MsgDefault => \[MSG_DEFAULT\]
#xtranslate :MsgButtons => \[MSG_BUTTONS\]
#xtranslate :MsgShow    => \[MSG_SHOW\]