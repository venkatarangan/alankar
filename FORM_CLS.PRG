/*
* PRG...............: FORM_CLS.PRG
* INCLUDE...........: FORM_CLS.CH
* CLASS.............: Form management Class
* DESC..............: Shows & Activates Forms 
* EXPORTS...........: Nil
* CONSTRUCTOR.......: NewForm  ()
* IMPORTED METHODS..: FormEdit(), FormInsert(), FormDelete(),
*                      FormStabilize(),FormPrint(),FormOpen(),FormClose().
* STATIC FUNCTIONS..: Activate(), ShowForm(), DrawForm()
*
* USES..............: Standard Clipper Functions
*                         Classes -> STK_CLS, CLR_CLS & SHAD_CLS
*
* NOTES.............: The Constructor returns a object, which
*                     contains several code block, some of them 
*                     are provided as default and can be changed.
*
* AUTHOR............: venkata rangan, tnc 
* DATE..............: 28/05/1995
* PROJECT...........: Alankar Travels Billing Travels
*
* COMPILER..........: CA-Clipper 5.2
* SWITCHES..........: /n /w /m
*/

#include "Box.Ch"
#include "InKey.Ch"
#include "SetCurs.Ch"

//User Defined Header files
#include "Clr_Cls.Ch"
#include "Shad_Cls.Ch" 
#include "Form_Cls.Ch"
#include "User.Ch"
#include "Apply.Ch"
     

// This function creates and initialises defaults

FUNCTION NewForm ( t,l,b,r,title )
LOCAL oForm [FORM_SIZE]

oForm:FormTop           := t
oForm:FormLeft          := l
oForm:FormBottom        := b
oForm:FormRight         := r
oForm:FormTitle         := title

oForm:FormEdit          := { | | .T. }
oForm:FormStabilize     := { | | .T. }
oForm:FormView          := { | | .T. }
oForm:FormInsert        := { | | .T. }
oForm:FormDelete        := { | | .T. }
oForm:FormPrint         := { | | .T. }

oForm:FormOpen      := { | | .T.}
oForm:FormClose     := { | | .T.}

oForm:FormPrev      := { || IIF( !BOF(), DBSKIP(-1),.F.) }
oForm:FormNext      := { || DBSKIP (+1),IIF(EOF(),DBGOBOTTOM(),.F.)}

oForm:FormFirst     := { || DBGOTOP()    } 
oForm:FormLast      := { || DBGOBOTTOM() }

oForm:FormTag        := { || FIELD->Tagged := .T. }
oForm:FormUnTag      := { || FIELD->Tagged := .F. }

oForm:FormShow       := { |o| ShowForm(o)}
oForm:FormChoose     := { | | .T.}

oForm:FormSpecial    := { | | .T.}
oForm:FormMemo       := { | | .T.}

oForm:FormLastLine   := ""
RETURN oForm

/* -----------------------------------
*/
STATIC FUNCTION ShowForm (oForm)
LOCAL oStack  := NewStack  ()
LOCAL oShadow , rLastLine

//save all parameters and show the empty form
Push (oStack,SETCURSOR(SC_NONE))
Push (oStack,SELECT())

Apply oForm:FormOpen()

rLastLine := SAVESCREEN (24,0,24,79)
// shadow around the form, this saves the screen area also
oShadow := NewShadow (oForm:FormTop,oForm:FormLeft,oForm:FormBottom,;
                                                  oForm:FormRight)
APPLY oShadow:ShaShow(oShadow)

// drawing of form
DrawForm(oForm:FormTop,oForm:FormLeft,oForm:FormBottom,oForm:FormRight,;
                 oForm:FormTitle, oForm:FormLastLine)

//Activation is done here
Activate (oForm)

// Shadow is cleared and screen restored
APPLY oShadow:ShaKill(oShadow)

//form is closed here
Apply oForm:FormClose()
RESTSCREEN (24,0,24,79,rLastLine)

SELECT     (Pop(oStack))
SETCURSOR  (Pop(oStack))
RETURN NIL

/*<----------------------------------------->
*/
STATIC PROCEDURE Activate (oForm)
LOCAL nKey, nRec, cScreen
SET SCOREBOARD OFF
nKey  := INKEY()
Apply oForm:FormStabilize()     
Apply oForm:FormView()

DO WHILE .T.
   DO CASE
      CASE nKey == UK_EDIT
                   Apply oForm:FormStabilize()  
           Apply oForm:FormEdit()
      CASE nKey == K_INS
           Apply oForm:FormStabilize()
           Apply oForm:FormInsert()
      CASE nKey == K_ESC 
           EXIT
      CASE nKey == UK_CHOOSE
           Apply oForm:FormChoose()
          CASE nKey == K_PGDN .OR. nKey == K_DOWN
           Apply oForm:FormNext()              
      CASE nKey == K_PGUP .OR. nKey == K_UP
           Apply oForm:FormPrev()
      CASE nKey == K_HOME
                   Apply oForm:FormFirst()
      CASE nKey == K_END
                   Apply oForm:FormLast()       
      CASE nKey == UK_PRINT
           Apply oForm:FormPrint()
      CASE nKey == UK_FULL_TAG
                   cScreen := SAVESCREEN (24,0,24,40)   
                           @ 24,0 CLEAR TO 24,40
                           @ 24,1 SAY "Please Wait I am tagging all records"
                           nRec := RECNO()      
                       DBEVAL (oForm:FormTag,{|| NEXTKEY()<>K_ESC})
                           DBGOTO (nRec)
                   RESTSCREEN (24,0,24,40,cScreen)      
          CASE nKey == UK_FULL_UNTAG
                   cScreen := SAVESCREEN (24,0,24,40)   
                           @ 24,0 CLEAR TO 24,40
                           @ 24,1 SAY "Please Wait I am untagging all records"
                           nRec := RECNO()      
                       DBEVAL (oForm:FormUnTag)
                           DBGOTO (nRec)
                   RESTSCREEN (24,0,24,40,cScreen)      
      CASE nKey == UK_TAG   .OR. nKey == UK_TAG+32
                   Apply oForm:FormTag()        
      CASE nKey == UK_UNTAG .OR. nKey == UK_UNTAG+32
                   Apply oForm:FormUnTag()      
      CASE nKey == UK_MEMO
                   Apply oForm:FormMemo()        
      CASE nKey == UK_SPECIAL
                   Apply oForm:FormSpecial()        
      CASE nKey == K_DEL  
                  Apply oForm:FormStabilize()
          Apply oForm:FormDelete()                 
     ENDCASE
            Apply oForm:FormStabilize() 
            APPLY oForm:FormView()
            nKey  := INKEY (0)      
    ENDDO 
RETURN 

STATIC PROCEDURE DrawForm (t,l,b,r,Title,cLastLine)
LOCAL oColor := NewColor(), temp

@ t,l,b,r BOX B_DOUBLE COLOR (oColor:WndBox)
temp := INT(((r-1) - LEN(Title))/2)

DEVPOS(t,l+temp)
DEVOUT ('µ',  oColor:WndBox)
DEVOUT (' '+Title+' ', oColor:WndTitle)  
DEVOUT ('Æ',  oColor:WndBox)
SETCOLOR (oColor:HelpLine)  // Bottom Line
@ 24,0    CLEAR TO 24,79
@ 24,0 SAY cLastLine
SETCOLOR (oColor:WorkSpace) //WndText
@ t+1,l+1 CLEAR TO b-1,r-1
RETURN



