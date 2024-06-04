/*
* PRG...............: PUSH_CLS.PRG
* INCLUDE...........: PUSH_CLS.CH
* DATABASE FILES....: NIL
* CLASS.............: Push Button implementation Class
* DESC..............: Creates and Implements buttons
* EXPORTS...........: Nil
* CONSTRUCTOR.......: NewPush  ()
* METHODS...........: PushShow () 
* STATIC FUNCTIONS..: Show()
* USES..............: Standard Clipper Functions
*	              Stack Class - STK_CLS.PRG, CLR_CLS.PRG
*       	      & APPLY.CH
*      	
* NOTES.............: The Constructor returns a object, which
*                     contains one code block and elements which
*	  	      have Push button elemenst.
*
* AUTHOR............: venkata rangan, tnc & madhu, s.
* DATE..............: 20/04/1995
* PROJECT...........: Alankar Travels Billing Program.
*
* COMPILER..........: CA-Clipper 5.2
* SWITCHES..........: /n /w /m
*/

#include "Inkey.Ch"
#include "Clr_Cls.Ch"
#include "Push_Cls.Ch"
#include "Apply.Ch"

FUNCTION NewPush 
LOCAL oPush[PUSHSIZE+1]
	oPush:PushRow 		:= 	ROW()
	oPush:PushCol 		:=  COL()
	oPush:PushDefault	:=  1
	oPush:PushButtons 	:= 	{"Ok"}
	oPush:PushShow      :=  { |o| Show(o) }
RETURN oPush

STATIC FUNCTION Show (oPush)
LOCAL oStack := NewStack ()
LOCAL oClr   := NewColor ()
LOCAL nTemp, nLen
Push (oStack, SETCOLOR (oClr:Buttons))
Push (oStack, SETKEY (K_ESC,    {|| Inkey()})) 
Push (oStack, SETKEY (K_SPACE,  {|| __KeyBoard(CHR(K_ENTER))}))
Push (oStack, SETKEY (K_TAB,    {|| __KeyBoard(CHR(K_RIGHT))}))
Push (oStack, SETKEY (K_SH_TAB, {|| __KeyBoard(CHR(K_LEFT))}))
Push (oStack, SETKEY (K_PGDN,   {|| __KeyBoard(CHR(K_RIGHT))}))
Push (oStack, SETKEY (K_PGUP,   {|| __KeyBoard(CHR(K_LEFT))}))

SET WRAP ON 

DEVPOS (oPush:PushRow, oPush:PushCol)
nLen := LEN(oPush:PushButtons)

FOR nTemp = 1 TO nLen
	DEVOUT ('[')	
        @ ROW(), COL() PROMPT oPush:PushButtons[nTemp]
        DEVOUT(']')
        DEVPOS (ROW(),COL()+4)
NEXT 
nTemp := oPush:PushDefault
MENU TO nTemp

SETKEY (K_PGDN,    Pop(oStack))
SETKEY (K_PGUP,    Pop(oStack))
SETKEY (K_SH_TAB,  Pop(oStack))
SETKEY (K_TAB,     Pop(oStack))
SETKEY (K_SPACE,   Pop(oStack))
SETKEY (K_ESC,     Pop(oStack))
SETCOLOR (Pop(oStack))

RETURN nTemp
