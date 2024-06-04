/*
* PRG...............: MENU_CLS.PRG
* INCLUDE...........: MENU_CLS.CH
* CLASS.............: Implements a Menu Box.
* DESC..............: Executes the menu box element's code blocks.
* EXPORTS...........: Nil
* CONSTRUCTOR.......: NewMenu  ()
* METHODS...........: MenuShow()
* STATIC FUNCTIONS..: ShowMenu()
*
* USES..............: Standard Clipper Functions
*                     Stack Class  - STK_CLS.PRG.
*                     Color Class  - CLR_CLS.PRG.
*                     Shadow Class - SHAD_CLS.PRG.              
*       
* NOTES.............: The Constructor returns a object, which
*                     contains one code block and elements which
*                     have options for the list and a list array.
*                                 It has got two private variables.
*
* AUTHOR............: venkata rangan, tnc
* DATE..............: 20/04/1995
* PROJECT...........: Alankar Travels Billing Program.
*
* COMPILER..........: CA-Clipper 5.2
* SWITCHES..........: /n /w /m
*/

#include "Clr_Cls.Ch"
#include "Shad_Cls.Ch"
#include "Msg_Cls.ch"
#include "Inkey.Ch"
#include "Achoice.Ch"
#include "Menu_Cls.ch"
#include "Apply.Ch"
#include "Box.Ch"

STATIC FUNCTION frame(nTop,nLeft,nBottom,nRight,cText)
LOCAL oColor:= NewColor()
SETCOLOR (oColor:MenuBox)

//SETBOXGROW(10)
@ nTop,nLeft,nBottom,nRight BOX B_DOUBLE+' '
//SETBOXGROW(0)

@ nTop+2,nLeft SAY CHR(204)
@ nTop+2,nRight SAY CHR(185)
@ nTop+2,nLeft+1 TO nTop+2,nRight-1 DOUBLE

@ nTop+3,nLeft+2 TO nBottom-1,nLeft+2
@ nTop+1,nLeft+1 SAY PADC(cText,nRight-nLeft-1)

RETURN NIL

FUNCTION NewMenu(t,l,b,r,Message)
LOCAL oMenu[MENU_SIZE]
oMenu:MenuTop            := t
oMenu:MenuLeft           := l
oMenu:MenuBottom         := b
oMenu:MenuRight          := r
oMenu:MenuMessage    := Message
oMenu:MenuArray          := {}
oMenu:MenuCodeBlocks := {}
oMenu:MenuDefault    := 1
oMenu:MenuChoice     := 1
oMenu:MenuShow           := { |o| ShowMenu(o)}
return oMenu

STATIC FUNCTION ShowMenu(oMenu)
LOCAL oShad, nChoice, oColor := NewColor()
  oShad := NewShadow(oMenu:MenuTop, oMenu:MenuLeft,;
               oMenu:MenuBottom, oMenu:MenuRight)
  Apply oShad:ShaShow(oShad)

  Frame (oMenu:MenuTop, oMenu:MenuLeft, oMenu:MenuBottom,;
                                 oMenu:MenuRight, oMenu:MenuMessage)
  SETCOLOR (oColor:MenuText)
  
  @ oMenu:MenuTop+3, oMenu:MenuLeft+3 CLEAR TO ;
                                  oMenu:MenuBottom-4,oMenu:MenuRight-5
  nChoice := ACHOICE (oMenu:MenuTop+3, oMenu:MenuLeft+3,;
                      oMenu:MenuBottom-1, oMenu:MenuRight-5,;   
                      oMenu:MenuArray,.T.,"MenuAction",;
                      oMenu:MenuDefault)
  oMenu:MenuChoice := IIF(nChoice==0, oMenu:MenuDefault, nChoice)
  
  Apply oShad:ShaKill(oShad)            
  EVAL (oMenu:MenuCodeBlocks[oMenu:MenuChoice])
RETURN oMenu

FUNCTION MenuAction (nMode, nCurElement, nRowPos)
LOCAL nRetVal := AC_CONT
LOCAL nKey := LASTKEY() 
LOCAL oMsg := NewMessage()

IF nMode == AC_HITTOP
        nKey  := K_END
        nMode := AC_EXCEPT
ENDIF
IF nMode == AC_HITBOTTOM
        nKey  := K_HOME
        nMode := AC_EXCEPT
ENDIF

IF nMode == AC_EXCEPT
        DO CASE
        CASE nKey == K_ENTER
                nRetVal := AC_SELECT
        CASE nKey == K_ESC 
                /*oMsg:MsgTitle := '- Escape key was triggered'
                oMsg:MsgText  := {' Please exit this program by ',;
                                   ' selecting the menu option QUIT.'}
                Apply oMsg:MsgShow(oMsg)*/
                Quiter()
        CASE nKey == K_HOME 
                KEYBOARD CHR(K_CTRL_HOME)
        CASE nKey == K_END
                KEYBOARD CHR(K_CTRL_END)
        OTHERWISE
                nRetVal := AC_GOTO
        ENDCASE
ENDIF
RETURN nRetVal
