/*
* PRG...............: CLR_CLS.PRG
* INCLUDE...........: CLR_CLS.CH
* DATABASE FILES....: COLORS.DBF
* STRUCTURE.........: "CODE"   N  2
*                     "VALUE"  C  15
*
* CLASS.............: Color settings management Class
* DESC..............: Gets, Stores & Provides Color Settings
* EXPORTS...........: Nil
* CONSTRUCTOR.......: NewColor  ()
* METHODS...........: ColorChange ()
* STATIC FUNCTIONS..: ReadColor(), WriteColor(),
*                     DefaultColor() & ChangeColor()
*
* USES..............: Standard Clipper Functions
*                      Stack Class - STK_CLS.PRG.
*
* NOTES.............: The Constructor returns a object, which
*                     contains one code block and elements which
*                     have color options.
*
* AUTHOR............: venkata rangan, tnc
* DATE..............: 20-04-1995
* PROJECT...........: Alankar Travels Billing Program.
*
* COMPILER..........: CA-Clipper 5.2
* SWITCHES..........: /n /w /m
*/

#include "Clr_Cls.Ch"
#include "Apply.Ch"
#include "Box.Ch"

FUNCTION NewColor
LOCAL oClr

// reading a color from database, if failed from default
oClr := ReadColor ()

// this is a method, oClr:ColorChange()
AADD(oClr, { |o| ChangeColor (o) } ) 

RETURN oClr

/*
*  This function is visible only in this program
*  Gives the default colors as an Object
*/

STATIC FUNCTION DefaultColor
LOCAL oClr[CLR_SIZE]

oClr:WndTitle    :=  "n/w"
oClr:WndText     :=  "w/r"
oClr:WndBox      :=  "w/b"

oClr:ScrollBar   :=  "n/w"

oClr:MenuText1   :=  "w+/b"      // Normal,Inactive color
oClr:MenuText2   :=  "n/w" // Reverse, Active Color
oClr:MenuText    :=  oClr:MenuText1+','+oClr:MenuText2
oClr:MenuBox     :=  "rg+/b"

oClr:Buttons1    :=  "w/n" // Normal, Inactive color
oClr:Buttons2    :=  "w+/b"// Reverse, Active Color
oClr:Buttons     :=  oClr:Buttons1 + ','+oClr:Buttons2

oClr:MsgTitle    :=  "W+/GR"
oClr:MsgText     :=  "b/w"
oClr:MsgBox      :=  "n/w"

oClr:TitleBar    :=  "b/bg"
oClr:Desktop     :=  "w/b"

oClr:ShowScr     :=  "rg+/b"
oClr:EditScr     :=  "n/w"
oClr:WorkSpace   :=  oClr:ShowScr + ','+oClr:EditScr

//oClr:Show  + oClr:Edit will give you the WorkSpace color

oClr:HelpLine    :=  "b/w"
oClr:HelpBox     :=  "n/w"
oClr:HelpText    :=  "w+/n"

RETURN oClr


/*
*  This function is visible only in this program
*  Reads the colors from a database called colors.dbf,
*  if database fails from defaultcolor function.
*/

STATIC FUNCTION ReadColor
LOCAL oClr[CLR_SIZE], oStack := NewStack()

Push (oStack, SELECT ())

// if file is not found, create a new one
IF FILE ("Colors.Dbf")
   SELECT 0
   USE Colors
   DBEVAL ( {| | oClr[Colors->Code] := Colors->Value} )
   oClr:MenuText    :=  oClr:MenuText1+','+oClr:MenuText2
   oClr:Buttons     :=  oClr:Buttons1 + ','+oClr:Buttons2
   oClr:WorkSpace   :=  oClr:ShowScr + ','+oClr:EditScr	
   USE
   DBSELECTAR (Pop(oStack))
ELSE
    ALERT ("COLORS.DBF file is missing, using default Colors")
    oClr := DefaultColor()
ENDIF

RETURN oClr

/*
*  This function is visible only in this program
*  Writes the colors into the database file Colors.Dbf,
*  returns .T. if mission successful, if not returns .F.
*/

STATIC PROCEDURE WriteColor (oClr)
LOCAL oStack := NewStack(), I

//save the database informations
Push (oStack, SELECT ())

// if file is not found, create a new one
IF FILE ("Colors.Dbf")
   // file is found
ELSE
    ALERT ("COLORS.DBF file is missing, creating a new one")
    DBCREATE ("Colors",{ {"Code", "N", 2, 0},{"Value","C",15,0}} )
ENDIF
SELECT 0
USE Colors
ZAP
FOR I := 1 TO CLR_SIZE
    DBAPPEND()
    Colors->Code  := I
    Colors->Value := oClr[I]
NEXT
USE

//restore the database informations
DBSELECTAR (Pop (oStack))
RETURN

/*
*  This function is visible only in this program
*  Interacts with the user and changes colors and calls
*  WriteColor function to write it. If failed reports,
*  to user.
*  Returns the New Color Object or Default Color object
*  F5 - SAVE SETTINGS
*  F6 - DEFAULT COLORS
*/

STATIC FUNCTION ChangeColor (oClr)
LOCAL oStack := NewStack()
LOCAL nChoice :=1, nClr
LOCAL aModuleText := { "Default Colors", "Save Colors",;
                       "Window Title", "Window Text", "Windows Box",;
                       "Message Title", "Message Text", "Message Box",;
                       "Desk top","Get Areas","Say Areas",;
                       "Active Buttons","Inactive Buttons", "Active Menu",;
                       "Inactive Menu", "Menu Box", "TitleBar",;
                       "Help line", "Help Text", "Help Box",;
                       "Scroll Bar"}

LOCAL aModuleId :=   { WNDTITLE, WNDTEXT,   WNDBOX,    ;
                       MSGTITLE, MSGTEXT,   MSGBOX,    ;
                       DESKTOP,  EDITSCR,   SHOWSCR,   ;
                       BUTTONS2, BUTTONS1,  MENUTEXT2, ;
                       MENUTEXT1, MENUBOX,  TITLEBAR,  ;
                       HELPLINE, HELPTEXT,  HELPBOX,   ;
                       SCROLLBAR }

Push (oStack, SETCOLOR   ("n/w,w/n"))
Push (oStack, SETCURSOR  (1) ) // Normal Cursor
Push (oStack, SAVESCREEN (5,10,20,30)  )
Push (oStack, SETKEY ( 19, { | | Inkey() }) ) // left arrow
Push (oStack, SETKEY ( 4,  { | | Inkey() }) ) // right arrow

@ 5,10,20,30 BOX B_DOUBLE + " "
@ 6,15 SAY "Modules"
@ 7,10 SAY 'Ç'
@ 7,11,7,29 BOX REPL('Ä',8)
@ 7,30 SAY '¶'

// swallow left and right
DO WHILE .T.
   nChoice := ACHOICE (8,13,19,27,aModuleText)
   DO CASE
   CASE nChoice == 0
         EXIT
   CASE nChoice == 1
        oClr := DefaultColor()
   CASE nChoice == 2
        WriteColor ( oClr )
   OTHERWISE
        nChoice := nChoice - 2 // used up for default & Save
        oClr[aModuleId[nChoice]] := ColorSelect(oClr[aModuleId[nChoice]])
        oClr:Buttons   := oClr:Buttons1  + ',' + oClr:Buttons2
        oClr:MenuText  := oClr:MenuText1 + ',' + oClr:MenuText2
        oClr:WorkSpace := oClr:ShowScr + ',' + oClr:EditScr
   ENDCASE
ENDDO

SETKEY (4, Pop(oStack))
SETKEY (19, Pop(oStack)) 

RESTSCREEN (5,10,20,30, Pop (oStack))
SETCURSOR  (Pop(oStack))
SETCOLOR   (Pop(oStack))
RETURN oClr



STATIC FUNCTION ColorSelect (cCargo)
LOCAL nrow := ROW()
LOCAL oStack := NewStack()
LOCAL aClrText := { 'Black','White', 'Blue','Red','Green',;
                    'Yellow', 'Cyan', 'Magenta', 'Brown',;
                    'Gray','Bright White','Bright Magenta'}

LOCAL aClrVal := { 'N','W','B','R','G','GR+','BG','RB','GR',;
                   'N+','W+','RB+' }
LOCAL a,b
Push (oStack, SETKEY ( 27, { | | Inkey() }) )
Push (oStack, SAVESCREEN (5,50,20,71) )

@ nrow, 10 SAY "-->"

@ 5,50,20,71 BOX B_DOUBLE +" "
@ 6,52 SAY "Fore Ground Colors"
@ 7,50 SAY 'Ç'
@ 7,51,7,70 BOX REPL('Ä',8)
@ 7,71 SAY '¶'

a := ACHOICE (8,53,19,68,aClrText)
@ 6,52 SAY "Back Ground Colors"
b := ACHOICE (8,53,19,68,aClrText)
cCargo := aClrVal[a] + '/' + aClrVal[b]

@ nrow,10 SAY "º  "
RESTSCREEN (5,50,20,71, Pop(oStack))
SETKEY (27, Pop(oStack))
RETURN cCargo
