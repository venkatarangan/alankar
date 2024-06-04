// *************************************************************
// Client Master
// Client.Prg
// *************************************************************

#include "Form_Cls.Ch"
#include "Apply.Ch"
#include "Client.Ch"
#include "Msg_Cls.Ch"
#include "Clr_Cls.Ch"
#include "List_Cls.ch"
#include "Sys_Cls.Ch"
#include "StdFares.Ch"
#include "Inkey.ch"


STATIC aClient [CLIENTTOTAL]

Function Client()
LOCAL oForm

oForm               := NewForm (6, 1, 20, 77,"Client Type Master")
oForm:FormEdit      := { || Say_Get("Edit")     }
oForm:FormStabilize := { || Stabilize()         }
oForm:FormView      := { || Say_Get("View")     }
oForm:FormInsert    := { || InsertClient()      }
oForm:FormDelete    := { || DeleteClient()      }
oForm:FormPrint     := { || PrintClient()       }
oForm:FormOpen      := { || OpenDataBase("CLIENT")  }
oForm:FormClose     := { || CloseDataBase("CLIENT") }
oForm:FormChoose    := { || Choose(oForm)       }
oForm:FormMemo      := { || MemoCtrl("ViewOnly") }
oForm:FormSpecial   := { || WriteStdFare() }
oForm:FormLastLine  := "  F2-print  F4-edit  F7-select"+;
                         " DEL-delete  INS-insert   ESC-go to main menu"
APPLY oForm:FormShow (oForm)
RETURN NIL

// ************************************************************

STATIC FUNCTION Stabilize()

aClient:ClientId    :=  Client->ClientId        
aClient:ClientName  :=  Client->ClientName
aClient:Address1    :=  Client->Address1
aClient:Address2    :=  Client->Address2
aClient:Address3    :=  Client->Address3
aClient:Place       :=  Client->Place
aClient:City        :=  Client->City
aClient:PinCode     :=  Client->PinCode
aClient:Phone       :=  Client->Phone
aClient:Fax         :=  Client->Fax
aClient:Fare        :=  Client->Fare
aClient:Tagged      :=  Client->Tagged
aClient:IsSplit     :=  Client->IsSplit
RETURN NIL

// ************************************************************


STATIC FUNCTION Say_Get(nMode)
LOCAL R:=7, C:=4,nYN := "N", nCopy := "N"
LOCAL GetList := {}, cTemp,  nChoice
LOCAL sFares := "", nUserChoice, sScreen 
LOCAL oMsg:=NewMessage()

IF nMode == "View"
   SETCURSOR (0)                // SC_NONE
   TopStatus ("VIEW MODE")  
   @ R+12, C+0 SAY "F3 - View fares; F5 - Overwrite fares with standard fares" 
ELSEIF nMode =="Edit"
   SETCURSOR (1)                // SC_NORMAL
   TopStatus ("EDIT MODE")
   @ R+12, C+0 CLEAR TO R+12,C+70

ELSEIF nMode =="Insert"
   SETCURSOR (1)               // SC_NORMAL
   TopStatus ("INSERT MODE")
   @ R+12, C+0 CLEAR TO R+12,C+70
ENDIF

  cTemp := aClient:ClientId

  @ R,   C SAY "Client Code: " Get aClient:ClientId PICTURE "@A!" WHEN nMode!="View" ;
                  Valid { | oGet | PresenceChk(oGet,cTemp)}
                  
  @ R+2, C     SAY "Name    :"  
  @ R+2, C+10  Get aClient:ClientName When nMode != "View" PICTURE "@!"

  @ R+3, C     SAY "Address :"
  @ R+3, C+10  Get aClient:Address1 When nMode != "View"
  @ R+4, C+10  Get aClient:Address2 When nMode != "View"
  @ R+5, C+10  Get aClient:Address3 When nMode != "View"


  @ R+5, C+40  SAY "Place   :"  
  @ R+5, C+50  Get aClient:Place When nMode != "View" PICTURE "@!"

  @ R+6, C     SAY "City    :"  
  @ R+6, C+10  Get aClient:City When nMode != "View"  PICTURE "@!"

  @ R+6, C+40  SAY "Pincode :"
  @ R+6, C+50  Get aClient:PinCode When nMode != "View"

  @ R+8, C     SAY "Phone   :"
  @ R+8, C+10  Get aClient:Phone When nMode != "View"

  @ R+8, C+40  SAY "Fax :"
  @ R+8, C+45  Get aClient:Fax When nMode != "View"
  
 
  @ R+10,C  SAY "Allow Split Rate Y/N:" Get aClient:IsSplit ;
        When nMode != "View" PICTURE "Y"
   
  IF nMode=="Edit"
     @ R+12, C SAY "Edit fare of this Client Yes/No:" GET nYN PICTURE "Y"
  ENDIF   

  READMODAL(GetList)

  IF aClient:Tagged
     @ R+2, C+61 SAY "<TAGGED>"
  ELSE
     @ R+2, C+61 SAY "<no tag>"
  ENDIF


 IF nMode == "Edit" .OR. nMode == "Insert"
      DO WHILE .T.
         IF UPPER(nYN)="Y"
            aClient:Fare := MemoCtrl ('EditToo')
         ENDIF   
         oMsg:MsgTitle   := "- Confirm Changes"
         oMsg:MsgText    := {"What is Your Choice"}
         oMsg:MsgDefault := 1
         oMsg:MsgButtons := {'Change it','Save','Cancel'}
         nChoice := Apply oMsg:MsgShow(oMsg)
         IF nChoice == 1
            READMODAL (GetList)
            LOOP
         ELSEIF nChoice==2
            IF nMode=="Insert"
               DBAPPEND()
               aClient:Fare := MemoRead(FARESFILE)
               Write(RECNO())
            ELSE
               Write(RECNO())
            ENDIF  
         ENDIF      
         EXIT
      ENDDO
 ENDIF     
RETURN NIL

// ********************************************************************

STATIC FUNCTION InsertClient()
LOCAL nRec, nX

DBGOBOTTOM()
DbSkip(+1)
Stabilize()
Say_Get("Insert")
RETURN NIL

// *********************************************************************

STATIC FUNCTION DeleteClient()
LOCAL oMessage:=NewMessage()
TopStatus ("DELETE MODE")
oMessage:MsgTitle := "- Deleting"
oMessage:MsgText  := { 'You cannot delete an entry in ',;
                       'the Client Master file.'}
Apply oMessage:MsgShow(oMessage)
RETURN NIL

// ********************************************************************

STATIC FUNCTION Write(nRec)

DBSELECTAR("CLIENT")
DBGOTO (nRec)

Client->ClientId   :=  aClient:ClientId
Client->ClientName :=  aClient:ClientName
Client->Address1   :=  aClient:Address1
Client->Address2   :=  aClient:Address2
Client->Address3   :=  aClient:Address3
Client->Place      :=  aClient:Place
Client->City       :=  aClient:City
Client->PinCode    :=  aClient:PinCode
Client->Phone      :=  aClient:Phone
Client->Fax        :=  aClient:Fax
Client->Fare       :=  aClient:Fare
Client->Tagged     :=  aClient:Tagged
Client->IsSplit    :=  aClient:IsSplit
RETURN NIL

// ******************************************************************


STATIC FUNCTION Choose()
LOCAL R:=7, C:=4, GetList := {}, rRec := RECNO()
LOCAL oMsg:=NewMessage()

    DBGOBOTTOM()
    DBSKIP(+1)
    Stabilize()
    Say_Get("View")
    TopStatus("SELECT MODE")

SETCURSOR(3)
@ R,   C   SAY "Client Code: " Get aClient:ClientId PICTURE "@A!"
READMODAL (GetList)

IF !DBSEEK(aClient:ClientId) 
    oMsg:MsgTitle := "- Data not found!"
    oMsg:MsgText  := {"The Client ID entered was not found" }
    Apply oMsg:MsgShow(oMsg)
    DBGOTO (rRec)
ENDIF

RETURN NIL

// ************************************************************
Static Function MemoCtrl(MemoPad)
LOCAL sFares := "", nUserChoice, sScreen 
LOCAL oMsg:=NewMessage(),oColor:=NewColor()
LOCAL bMemo

DO CASE
  CASE MemoPad == "ViewOnly"
      sScreen := SaveScreen()
      SETCOLOR (oColor:HelpLine)  // Bottom Line
      @ 24,0    CLEAR TO 24,79
      @ 24,0 SAY "ESC for Exit"
      SETCOLOR (oColor:WorkSpace) //WndText
      @  5,3 to 18,71
      sFares := aClient:Fare
      sFares  := MemoEdit(sFares,6,4,17,70,.F.)
      Restore Screen from sScreen
  CASE MemoPad == "EditToo"
      bMemo := SETKEY (K_ESC, {| | StuffSave() } )
      Save Screen to sScreen
      SETCOLOR (oColor:HelpLine)  // Bottom Line
      @ 24,0    CLEAR TO 24,79
      @ 24,10 SAY " F2 - Print; ESC - Save the Fare/Exit ;"
      SETCOLOR (oColor:WorkSpace) //WndText
      
      @ 3,5 to 22,74
      sFares := aClient:Fare
      sFares  := Memoedit(sFares,4,6,21,73)
      
      SETKEY (K_ESC, bMemo)    
      
      If LastKey() == K_CTRL_W   
          oMsg:MsgTitle   := "- Fare Conformation! "
          oMsg:MsgText    := {"Shall I Write the changed fares"}
          oMsg:MsgDefault := 1
          oMsg:MsgButtons := {"Yes", "No"}
          nUserChoice := APPLY oMsg:MsgShow (oMsg)
          Restore Screen from sScreen
          If nUserChoice == 1
             Return sFares
          Else
             Return aClient:Fare   
          Endif   
      Endif
ENDCASE      
Return Nil

//**********************************************************
Static Function PrintClient()
LOCAL nIsAll, oMsg:=NewMessage(), nPage:=1, nType
LOCAL nCount:=3, PrintLen := PrintLine() 
LOCAL nMemoLine, FareString, FareLen, nCurrent := RecNo()

oMsg:MsgTitle   := "- Client Selection"
oMsg:MsgText    := {"Which of the Clients do you want to print?"}
oMsg:MsgButtons := {"All Clients", "Only Tagged Clients","Cancel"}
oMsg:MsgDefault := 1
nIsAll          := Apply oMsg:MsgShow(oMsg)
IF nIsAll == 3; RETURN .T.; ENDIF

oMsg:MsgTitle   := "- Printing Format "
oMsg:MsgText    := {"In which format do you want to print?"}
oMsg:MsgButtons := {"Client Code only","Mailing List","Complete with fare"}
oMsg:MsgDefault := 1
nType           := Apply oMsg:MsgShow(oMsg)

IF PrintOn()==.F.
   PrintNoReady()
ELSE
   @ 1,1  SAY "Customer Information"
   @ 1,50 SAY "Page No: "
   @ 1,60  SAY LTRIM(STR(nPage))
   @ 2,1  SAY REPL("-",75)
   DBGOTOP()
   DO WHILE .T.
     IF (nIsAll == 1) .OR. (nIsAll==2 .AND. CLIENT->Tagged)
         DO CASE
            CASE nType == 1  // Client Code Only
               @ nCount++,1 SAY CLIENT->ClientId + SPACE(10) + CLIENT->ClientName
               nCount++
            CASE nType == 2  // Mailing List
               nCount +=1
               @ nCount++,1 SAY CLIENT->ClientName
               @ nCount++,1 SAY CLIENT->Address1
               IF CLIENT->Address2 <> " "
                  @ nCount++,1 SAY CLIENT->Address2
               ENDIF   
               IF CLIENT->Address3 <> " "               
                  @ nCount++,1 SAY CLIENT->Address3
               ENDIF   
               @ nCount++,1 SAY CLIENT->Place + " "+ CLIENT->City
               @ nCount++,1 SAY "Pin:"+LTRIM(STR(CLIENT->PinCode))
               nCount += 2
            CASE nType == 3  // Complete With Fare
               nCount +=1
               FareString := CLIENT->Fare
               FareLen = MLCOUNT (FareString)
               nMemoLine := 0
               @ nCount++,1 SAY CLIENT->ClientName
               @ nCount++,1 SAY CLIENT->Address1
               IF CLIENT->Address2 <> " "
                  @ nCount++,1 SAY CLIENT->Address2
               ENDIF   
               IF CLIENT->Address3 <> " "               
                  @ nCount++,1 SAY CLIENT->Address3
               ENDIF   
               @ nCount++,1 SAY CLIENT->Place + " "+ CLIENT->City
               @ nCount++,1 SAY "Pin:"+LTRIM(STR(CLIENT->PinCode))
               nCount++
               @ nCount,1   SAY "Phone:"+CLIENT->Phone
               @ nCount++,45  SAY "Fax:"+CLIENT->Fax 
               nCount++
               Do While nMemoLine <= FareLen
                   @ nCount++, 1 SAY MEMOLINE(FareString,68,nMemoLine++) 
                   If nCount == PrintLen
                      EJECT
                      nCount := 3
                      nPage  += 1
                      @ 1,1  SAY CLIENT->ClientName + "Fare Sheet"
                      @ 1,60 SAY "Page No: "
                      @ 1,70  SAY LTRIM(STR(nPage))
                      @ 2,1  SAY REPL("-",75)
                   Endif   
               ENDDO
            ENDCASE
      ENDIF
      IF !EOF()
          DBSKIP (+1)
          IF EOF()
             EXIT
          ENDIF   
      ELSE
          EXIT
      ENDIF
     
      If nCount+6 >= PrintLen
         EJECT
         nCount := 3
         nPage  += 1
         @ 1,1  SAY "Customer Information"
         @ 1,50 SAY "Page No: "
         @ 1,60  SAY LTRIM(STR(nPage))
         @ 2,1  SAY REPL("-",75)
      Endif   
   ENDDO
  PrintOff()
    oMsg:MsgTitle   := "- FINISHED PRINTING !"   
    oMsg:MsgText    := { "The Computer has finished sending the data.",;
                             "You can continue with your work."}
    oMsg:MsgButtons := {"Ok"}
    Apply oMsg:MsgShow(oMsg)
ENDIF
DBGOTO(nCurrent)
Return NIL

//**********************************************************
Static Function WriteStdFare()
LOCAL sFares := "", nUserChoice, sScreen 
LOCAL oMsg:=NewMessage(),oColor:=NewColor()
LOCAL bMemo


oMsg:MsgTitle   := "- Fare overwrite Fare Conformation! "
oMsg:MsgText    := {"Shall I OverWrite the present fares with Std. fares ?"}
oMsg:MsgDefault := 1
oMsg:MsgButtons := {"Yes", "No"}
nUserChoice := APPLY oMsg:MsgShow (oMsg)

If nUserChoice == 1
    Stabilize()
    sFares := MemoRead(FARESFILE)
    aClient:Fare := sFares
    Write(RecNo())
Endif   
Return Nil


