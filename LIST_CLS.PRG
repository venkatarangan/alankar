/*
* PRG...............: LIST_CLS.PRG
* INCLUDE...........: LIST_CLS.CH
* CLASS.............: Implements a List Box with Insert & delete
* DESC..............: 
* EXPORTS...........: Nil
* CONSTRUCTOR.......: NewList  ()
* METHODS...........: ListShow()
* STATIC FUNCTIONS..: Show List()
*
* USES..............: Standard Clipper Functions
*                     Stack Class - STK_CLS.PRG.
*                         Color Class - CLR_CLS.PRG.
*       
* NOTES.............: The Constructor returns a object, which
*                     contains one code block and elements which
*                     have options for the list and a list array.
*                             It has got two private variables.
*
* AUTHOR............: venkata rangan, tnc
* DATE..............: 20-04-1995
* PROJECT...........: Alankar Travels Billing Program.
*
* COMPILER..........: CA-Clipper 5.2
* SWITCHES..........: /n /w /m
*/

#include "List_Cls.Ch"
#include "Inkey.Ch"
#include "Achoice.Ch"
#include "Clr_Cls.Ch"
#include "Box.ch"
#include "Apply.Ch"
#include "Msg_Cls.Ch"
#include "Shad_Cls.Ch"

MEMVAR CargoKey, CargoIndex

FUNCTION NewList(t,l,b,r)
LOCAL oList[LIST_SIZE]
oList:ListTop     := t
oList:ListLeft    := l
oList:ListBottom  := b
oList:ListRight   := r

oList:ListShow      := { |oList| ShowList (oList) }
oList:ListValidate  := { | | .T. }
oList:ListPicture   := ""
oList:ListArray     := { }
oList:ListDefault   := 1

oList:ListDelete  := { | | .T. }
oList:ListInsert  := { | | .T. }
 
oList:ListBuffer    := ""
oList:ListChoice    := ""
oList:ListIndex     := 1
oList:ListMessage   := "Lister"
oList:ListInsText   := "New Item: "
RETURN oList
/*
**************************************************************************
*       FUNCTION         : Show List                                     *
*       PARAMETERS       : The List Object                               *
*       USES     : Color, Stack, Shadow Classes                          * 
*       DESC     : Displays the Lists and defines the User Defined       *
*                                       ACHOICE function.                *
*       PRIVATE  : It defines two PRIVATE variables so that UDF of       *
*                                               ACHOICE can see it.      *
**************************************************************************
*/

STATIC FUNCTION ShowList (oList)
LOCAL oStack := NewStack(),oShad, oShadIns
LOCAL oColor := NewColor()
LOCAL oMsg   := NewMessage()
LOCAL nChoice,xBuffer, nR, nC
LOCAL GetList:={ }

PRIVATE CargoKey := K_TAB, CargoIndex := 1
oShad := NewShadow(oList:ListTop-1, oList:ListLeft-1,;
               oList:ListBottom+1, oList:ListRight+1)

oList:ListArray := ASORT (oList:ListArray)
Apply oShad:ShaShow(oShad)


DO WHILE !CargoKey==K_ENTER
  @ oList:ListTop-1, oList:ListLeft-1, oList:ListBottom+1, oList:ListRight+1;
                BOX B_DOUBLE_SINGLE COLOR oColor:MenuBox
  @ oList:ListTop-1,oList:ListLeft SAY oList:ListMessage
  SETCOLOR (oColor:MenuText)
  @ oList:ListTop, oList:ListLeft CLEAR TO oList:ListBottom,oList:ListRight

  nChoice := ACHOICE (oList:ListTop, oList:ListLeft,;
                      oList:ListBottom, oList:ListRight,;   
                      oList:ListArray,.T.,"ListAction",;
                      oList:ListDefault)

 IF CargoKey == K_INS .AND. EVAL (oList:ListInsert)
        nR := IIF (ROW() <  4,  5, ROW())  
        nR := IIF (ROW() > 20, 20, ROW())
        nC := 60
    oShadIns := NewShadow (nR,10,nR+3,nC)
    Apply oShadIns:ShaShow (oShadIns)
    @ nR,10,nR+3,nC BOX B_SINGLE COLOR oColor:WndBox
        SETCOLOR (oColor:WorkSpace)
        @ nR+1,11 CLEAR TO nR+2,nC-1
        xBuffer := oList:ListBuffer
        @ nR+1,12 SAY oList:ListInsText GET xBuffer PICTURE oList:ListPicture
        READ
                IF !EMPTY(xBuffer)
                        AADD(oList:ListArray, xBuffer)
                        ASORT(oList:ListArray)                  
                        oList:ListDefault := ASCAN (oList:ListArray, xBuffer)
                ENDIF
        Apply oShadIns:ShaKill (oShadIns)               
  ELSEIF CargoKey == K_ESC      
                nChoice :=      oList:ListDefault
                EXIT
  ELSEIF CargoKey == K_DEL .AND. EVAL (oList:ListDelete)
            IF LEN (oList:ListArray) > 1
                   oMsg:MsgTitle   := "- Confirm Deletion"
                   oMsg:MsgText    := {"You are about to delete an Entry",;
                                     "Are you sure about this?"}
                   oMsg:MsgDefault := 2 
                   oMsg:MsgButtons := {'Yes','No'}
                   IF Apply oMsg:MsgShow (oMsg) == 1
                           ADEL  (oList:ListArray, CargoIndex)
                           ASORT (oList:ListArray)      
                           ASIZE (oList:ListArray, LEN(oList:ListArray)-1)
                   ENDIF 
                ENDIF
  ENDIF
ENDDO
oList:ListChoice := nChoice
Apply oShad:ShaKill(oShad)
RETURN oList

/*
*****************************************************************************
*       FUNCTION     : ACTION                                               *
*       PARAMETERS   : nMode of ACHOICE, nCurrent Element under Hilite bar, *
*                          nROW of the Hilite bar.                          * 
*       DESC         : User defined for ACHOICE of List Class.              *
*****************************************************************************
*/

FUNCTION ListAction (nMode, nCurElement, nRowPos)
LOCAL nRetVal := AC_CONT
LOCAL nKey    := LASTKEY()
CargoKey   := nKey                           // Private DANGER !
CargoIndex := nCurElement        // Private DANGER !

IF nMode==AC_HITTOP .OR. nKey==K_END
    KEYBOARD CHR(K_CTRL_PGDN)
    RETURN nRetVal
ELSEIF nMode==AC_HITBOTTOM .OR. nKey==K_HOME
    KEYBOARD CHR(K_CTRL_PGUP)
    RETURN nRetVal
ENDIF

IF nMode==AC_EXCEPT
    DO CASE
       CASE nKey==K_RETURN
            nRetVal :=AC_SELECT   
           CASE nKey ==K_INS .OR. nKey==K_DEL .OR. nKey==K_ESC
                   nRetVal := AC_ABORT  
           OTHERWISE
                        nRetVal := AC_GOTO      
   ENDCASE
ENDIF
RETURN nRetVal
