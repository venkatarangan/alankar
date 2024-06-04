/*
* PRG...............: MSG_CLS.PRG
* INCLUDE...........: MSG_CLS.CH
* DATABASE FILES....: NIL
* CLASS.............: Message Box implementation Class
* DESC..............: Creates and Implements Message Boxes
* EXPORTS...........: Nil
* CONSTRUCTOR.......: NewMessage  ()
* METHODS...........: MsgShow () 
* STATIC FUNCTIONS..: Show()
* USES..............: Standard Clipper Functions
*		      Classes -> STK_CLS, SHAD_CLS, CLR_CLS.PRG & PUSH_CLS
* 		      Include Files-> Apply.Ch
*      	
* NOTES.............: The Constructor returns a object, which
*                     contains one code block and elements which
*	  	      have Message Box elements.
*
* AUTHOR............: venkata rangan, tnc 
* DATE..............: 20/04/1995
* PROJECT...........: Alankar Travels Billing Program.
*
* COMPILER..........: CA-Clipper 5.2
* SWITCHES..........: /n /w /m
*/

#include "Clr_Cls.Ch"
#include "Apply.Ch"
#include "Push_Cls.Ch" 
#include "Shad_Cls.Ch"
#include "Msg_Cls.Ch"
#include "Box.Ch"

FUNCTION NewMessage
	LOCAL oMsg[MSG_SIZE+1]
	oMsg:MsgTitle     := ""
	oMsg:MsgText      := {}
	oMsg:MsgDefault   := 1
	oMsg:MsgButtons   := {'Ok'}
	oMsg:MsgShow      := { |o| Show (o)}
RETURN oMsg

STATIC FUNCTION Show (oMsg)
LOCAL oShadow
LOCAL oColor   := NewColor ()
LOCAL oPush    := NewPush ()
LOCAL long:=0, lines:=0, temp:=0, t:=0, l:=0 , r:=0, b:=0

// find the total width occupied by the buttons 
  AEVAL ( oMsg:MsgButtons, {|x| temp := temp+LEN(x)} )  
  temp  += LEN (oMsg:MsgButtons) * 6

// find the largest message string, & between Title and buttons width
  AEVAL ( oMsg:MsgText, { |x| long := MAX (long, LEN(x))})
  long := MAX (long, LEN(oMsg:MsgTitle))
  long := MAX (long, temp)

  long += 2 + 4	
  l := INT((79-long)/2)

  lines := LEN(oMsg:MsgText)

  lines := IIF ( oMsg:MsgTitle == "", lines, lines+1) + 4

  t := INT((24-lines)/2)
  
  b := t+lines; r := l + long

// save the screen and colors inside NewShadow & create a shadow object
  oShadow := NewShadow (t,l,b,r) 
// display the shadow
  APPLY oShadow:ShaShow(oShadow)	  

  IF LEN(oMsg:MsgTitle) != 0
    	  SETCOLOR (oColor:MsgTitle)
    	  @ t,l CLEAR TO t,r
       	  @ t,l SAY oMsg:MsgTitle
		  t++
  ENDIF

// draw a box around the message box and clear its contents
  SETCOLOR (oColor:MsgBox)
  DISPBOX (t++,l++,b,r,B_SINGLE)

// write all the text elements from array into the msg box
  SETCOLOR (oColor:MsgText)
  DISPBOX (t,l,b-1,r-1,REPL(' ',9))
  AEVAL (oMsg:MsgText, { |x| SETPOS(t++,l+1),DEVOUT(x)})

// call the push button class for displaying buttons
  oPush:PushRow     := t + 2
  oPush:PushCol     := INT ((long - temp) /2) + l
  oPush:PushDefault := oMsg:MsgDefault
  oPush:PushButtons := oMsg:MsgButtons	

  temp := APPLY oPush:PushShow(oPush)

// clear the shadow and restore screen contents
  APPLY oShadow:ShaKill (oShadow)		 
RETURN temp
