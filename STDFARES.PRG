// ****************************************************
// StdFares.Prg
// Standard Fares program
// Maintains a file Fares.Txt -- Hard coded
// which contains the standard fare stucture
// ****************************************************

#include "StdFares.Ch"
#include "Msg_Cls.Ch"
#include "Inkey.ch"
#include "User.Ch"
#include "Apply.Ch"
#include "Clr_Cls.Ch"

Static FareString

Function StdFares()

Local oMsg := NewMessage()
Local nUserChoice := 0, nKey
Local sFares := "",oColor:=NewColor()
LOCAL bPrint, bMemo
Local sScreen := SaveScreen()

SETCOLOR (oColor:HelpLine)  // Bottom Line
@ 24,0  CLEAR TO 24,79
@ 24,10 SAY " F2 - Print;  ESC - Save the Fare/Exit Without Saving;"
SETCOLOR (oColor:WorkSpace) //WndText

bPrint := SETKEY(UK_PRINT, { | |  Printfare (sFares) } )  
bMemo  := SETKEY(K_ESC,  { | |  StuffSave() } )

sFares  := MemoRead(FARESFILE)
FareString := sFares
@ 3,5 to 22,74
sFares  := Memoedit(sFares,4,6,21,73)

nKey := Lastkey()       

If nKey==K_CTRL_W
   oMsg:MsgTitle   := "- Fare Conformation! "
   oMsg:MsgText    := {"Shall I Write the changed fares"}
   oMsg:MsgDefault := 1
   oMsg:MsgButtons := {"Yes", "No"}
   nUserChoice := APPLY oMsg:MsgShow (oMsg)
   If nUserChoice == 1
      MemoWrit(FARESFILE,sfares)
   Endif   
Endif

Restore Screen from sScreen
SETKEY (UK_PRINT,bPrint)
SETKEY (K_ESC, bMemo)
Return NIL


Static Function PrintFare()
LOCAL PrintLen:=PrintLine(), oMsg := NewMessage(), nMemoLine := 0
LOCAL FareLen := MLCOUNT (FareString), nCount:=3,nPage:=1 
LOCAL nUserChoice := 1
oMsg:MsgTitle   := "- Standard Fare Printing!"
oMsg:MsgText    := {"Shall I start printing?"}
oMsg:MsgButtons := {"Ok","Cancel"}
oMsg:MsgDefault := 1
nUserChoice := Apply oMsg:MsgShow(oMsg) 

IF nUserChoice == 2; RETURN .T.; ENDIF

If PrintOn() ==.F.
   PrintNoReady()
Else
  @ 1,1   SAY "STANDARD FARE RATES (for Computer Purposes only)"
  @ 1,60  SAY "Page No:"
  @ 1,70  SAY LTRIM(STR(nPage))
  @ 2,1   SAY REPL("-",75)
  
  Do While nMemoLine <= FareLen
     @ nCount++, 1 SAY MEMOLINE(FareString,68,nMemoLine++) 
     If nCount == PrintLen
        EJECT
        nCount := 3
        nPage  += 1
        @ 1,1   SAY "STANDARD FARE RATES (for Computer Purposes only)"
        @ 1,60  SAY "Page No:"
        @ 1,70  SAY LTRIM(STR(nPage))
        @ 2,1   SAY REPL("-",75)
     Endif   
  Enddo   
  PrintOff()
    oMsg:MsgTitle   := "- FINISHED PRINTING !"   
    oMsg:MsgText    := { "The Computer has finished sending the data.",;
                             "You can continue with your work."}
    oMsg:MsgButtons := {"Ok"}
    Apply oMsg:MsgShow(oMsg)
Endif
Return Nil
