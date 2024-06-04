/*
* PRG...............: MAIN.PRG
* INCLUDE...........: MAIN.CH
* CLASS.............: The Main program that controls the Project
* EXPORTS...........: Nil.
*                                         
* CONSTRUCTOR.......: Nil
* METHODS...........: Nil.
*
* USES..............: Standard Clipper Functions
*       
* NOTES.............: 
*
* AUTHOR............: venkata rangan, tnc & Madhu,S.
* DATE..............: 20/04/1995 - 18/07/95
* PROJECT...........: Alankar Travels Billing Program.
*
* COMPILER..........: CA-Clipper 5.2
* SWITCHES..........: /n /w /m
*/

#include "Clr_Cls.Ch"
#include "Apply.Ch"
#include "List_Cls.ch"
#include "Menu_Cls.ch"
#include "Msg_Cls.Ch"
#include "Box.Ch"
#include "Sys_Cls.Ch"
#include "Heading.Ch"
#include "User.Ch"
#include "Inkey.Ch"

Function zMain()
LOCAL oColor := NewColor()
LOCAL oMenu  := NewMenu(4,13,21,65, "Choose one of these broad topics")

SET SCOREBOARD OFF
SET DATE TO BRIT

SETCOLOR (oColor:TitleBar)
@ 0,0 CLEAR TO 2,79
@ 0,0,2,79 BOX B_SINGLE
@ 1,  2 SAY COMPANYNAME

SETCOLOR(oColor:Desktop)
DISPBOX(3,0,24,79,REPL('�',9))

SETCOLOR (oColor:HelpLine)  // Bottom Line
@ 24,0    CLEAR TO 24,79
@ 24,5 SAY "Up & Down arrow keys to navigate, ENTER for selection, ESC to Quit"
SETCOLOR(oColor:Desktop)

oMenu:MenuArray      := {  ' CONFIRMATORY ORDER [Trip Sheets          ]'   ,  ;
                           ' BILL REGISTER      [Print a bill         ]'   ,  ;
                           ' ACCOUNTS MASTER    [Receipts & Statements]'   ,  ;
                           '                                           ',     ;
                           ' BOOKING      [Booking of cars for clients  ]' ,  ;
                           ' ADDRESS BOOK [Addresses of frequent callers]' ,  ; 
                           '                                           ',     ;
                           ' CUSTOMER MASTER     [Customer maintenance ]'  ,  ;
                           ' VEHICLE TYPE MASTER [Vehicle type master  ]'  ,  ;
                           ' STANDARD FARES      [Standard fares table ]'  ,  ;
                           ' HEADER MODIFY       [Bills, Trip sheets...]'  ,  ;
                           '                                           ',     ;
                           ' COLOR SETTINGS   [Change & save the colors]'  ,  ;
                           ' QUIT THE PROGRAM [I have finished my job  ]' }
    
oMenu:MenuCodeBlocks := {   { | | TripMaster()}, ;
                            { | | BillMas() },   ;
                            { | | AccMas()},     ;
                            { | | .T. }, ;
                            { | | Booking()},    ; 
                            { | | AddMas()},     ;
                            { | | .T. }, ;
                            { | | Client()},     ;
                            { | | VehType()},    ;
                            { | | StdFares()},   ;
                            { | | Heading()},    ;
                            { | | .T. }, ;
                            { | | EVAL(oColor:ColorChange,oColor) },;
                            { | | Quiter() } } 
DO WHILE oMenu:MenuChoice !=0
    TopStatus("MENU MODE")
    Apply oMenu:MenuShow(oMenu)
ENDDO
QUIT
Return NIL

//********************************************************************
FUNCTION Quiter()
LOCAL oMsg   := NewMessage()
oMsg:MsgTitle    := "- Good Bye !"
oMsg:MsgText     := { "Is it OK for you to Quit? "}
oMsg:MsgDefault  := 2
oMsg:MsgButtons  := { "Ok","Cancel" }

IF Apply oMsg:MsgShow(oMsg) == 1
   COMMIT
   CLOSE ALL     
   CLEAR SCREEN
   ? ""
   ? "             Thank you for using this Customised Software!!!"
   ? ""
   ? "               ------------------------------------------"    
   ? "               |  Alankar Software, Ver 2.00-Build 23   |"
   ? "               ------------------------------------------"
   ? " "
   ? "               (c) 1995, T.N.C.Venkata Rangan.   Ph: 123 4567"
   ? "               Training by: R.Madhavan.          Ph: 123 4567"
   ? ""
   QUIT     
ENDIF
RETURN NIL


// ***********************************************************

Static Function Dummy()
Local oMsg      := NewMessage()

oMsg:MsgTitle   := "- Sorry!"
oMsg:MsgText    := { "This module is not yet implemented" }
oMsg:MsgDefault := 1
oMsg:MsgButtons := { "Ok" }

Apply oMsg:MsgShow(oMsg)
Return NIL

// *************************************************************

STATIC FUNCTION Heading()
LOCAL oClr:=NewColor(),bMemo
LOCAL sScreen := SaveScreen(), sHead, oMsg:=NewMessage()
LOCAL nUserChoice
SETCOLOR (oClr:HelpLine)
@ 24,0  CLEAR TO 24,79
@ 24,25 SAY "ESC - Save/Exit"
SETCOLOR (oClr:WorkSpace) //WndText
bMemo  := SETKEY(K_ESC,    { | |  StuffSave() } )

sHead  := MemoRead(HEADFILE)
@ 7,5 to 16,75
sHead  := Memoedit(sHead,8,6,15,74)

If LastKey()==K_CTRL_W
   oMsg:MsgTitle   := ""
   oMsg:MsgText    := {"Shall I Write the changed address"}
   oMsg:MsgDefault := 1
   oMsg:MsgButtons := {"Yes", "No"}
   nUserChoice := APPLY oMsg:MsgShow (oMsg)
   If nUserChoice == 1
      MemoWrit(HEADFILE,sHead)
   Endif   
Endif

Restore Screen from sScreen
SETKEY (K_ESC, bMemo)
RETURN NIL
