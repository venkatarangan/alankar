// *************************************************************
// Address Master
// Address.Prg
// *************************************************************

#include "Form_Cls.Ch"
#include "Apply.Ch"
#include "Address.Ch"
#include "Msg_Cls.Ch"
#include "Clr_Cls.Ch"
#include "Sys_Cls.Ch"
#include "StdFares.Ch"
#include "Inkey.ch"


STATIC aAddress [ADDTOTAL]

Function AddMas()
LOCAL oForm

oForm               := NewForm (5, 1, 21, 77,"Address Book")
oForm:FormEdit      := { || Say_Get("Edit")     }
oForm:FormStabilize := { || Stabilize()         }
oForm:FormView      := { || Say_Get("View")     }
oForm:FormInsert    := { || InsertAdd()      }
oForm:FormDelete    := { || DeleteAdd()      }
oForm:FormPrint     := { || PrintAdd()       }
oForm:FormOpen      := { || OpenDataBase("CLIENT"),   OpenDataBase("ADDRESS")  }
oForm:FormClose     := { || CloseDataBase("ADDRESS"), CloseDataBase("CLIENT")}
oForm:FormChoose    := { || Choose(oForm)       }
oForm:FormLastLine  := "  F2-print  F4-edit  F7-select"+;
                         " DEL-delete  INS-insert   ESC-go to main menu"
APPLY oForm:FormShow (oForm)
RETURN NIL

// ************************************************************

STATIC FUNCTION Stabilize()

aAddress:ClientId    :=  ADDRESS->ClientId        
aAddress:Name        :=  ADDRESS->Name
aAddress:Address1    :=  ADDRESS->Address1
aAddress:Address2    :=  ADDRESS->Address2
aAddress:Address3    :=  ADDRESS->Address3
aAddress:Place       :=  ADDRESS->Place
aAddress:City        :=  ADDRESS->City
aAddress:PinCode     :=  ADDRESS->PinCode
aAddress:Phone       :=  ADDRESS->Phone
aAddress:Fax         :=  ADDRESS->Fax
aAddress:Tagged      :=  ADDRESS->Tagged
aAddress:Dept        :=  ADDRESS->Dept
aAddress:Desc        :=  ADDRESS->Desc
RETURN NIL

// ************************************************************


STATIC FUNCTION Say_Get(nMode)
LOCAL R:=6, C:=4,nYN := "N", nCopy := "N"
LOCAL GetList := {}, cTemp,  nChoice
LOCAL sFares := "", nUserChoice, sScreen 
LOCAL oMsg:=NewMessage()

IF nMode == "View"
   SETCURSOR (0)                // SC_NONE
   TopStatus ("VIEW MODE")  
ELSEIF nMode =="Edit"
   SETCURSOR (1)                // SC_NORMAL
   TopStatus ("EDIT MODE")
ELSEIF nMode =="Insert"
   SETCURSOR (1)               // SC_NORMAL
   TopStatus ("INSERT MODE")
ENDIF

  cTemp := aAddress:ClientId

  @ R,   C SAY "Client Code: " Get aAddress:ClientId PICTURE "@A!" WHEN nMode!="View" ;
                  Valid { | oGet | ChkClient(oGet:Buffer)}
                  
  @ R,   C+37 SAY "Department:" Get aAddress:Dept PICTURE "@!" WHEN nMode!="View"
  
  @ R+2, C     SAY "Name    :"
  @ R+2, C+10  Get aAddress:Name When nMode != "View" PICTURE "@!"

  @ R+3, C     SAY "Address :"
  @ R+3, C+10  Get aAddress:Address1 When nMode != "View"
  @ R+4, C+10  Get aAddress:Address2 When nMode != "View"
  @ R+5, C+10  Get aAddress:Address3 When nMode != "View"


  @ R+5, C+40  SAY "Place   :"
  @ R+5, C+50  Get aAddress:Place When nMode != "View" PICTURE "@!"

  @ R+6, C     SAY "City    :"
  @ R+6, C+10  Get aAddress:City When nMode != "View"  PICTURE "@!"

  @ R+6, C+40  SAY "Pincode :"
  @ R+6, C+50  Get aAddress:PinCode When nMode != "View"

  @ R+8, C     SAY "Phone   :"
  @ R+8, C+10  Get aAddress:Phone When nMode != "View"

  @ R+8, C+40  SAY "Fax :"
  @ R+8, C+45  Get aAddress:Fax When nMode != "View"
  
  @ R+10, C SAY "Description for this address:" Get aAddress:Desc;
             WHEN nMode!="View" PICTURE "@!"

  READMODAL(GetList)

  IF aAddress:Tagged
     @ R+2, C+61 SAY "<TAGGED>"
  ELSE
     @ R+2, C+61 SAY "<no tag>"
  ENDIF


 IF nMode == "Edit" .OR. nMode == "Insert"
      DO WHILE .T.
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

STATIC FUNCTION InsertAdd()
LOCAL nRec, nX

DBGOBOTTOM()
DbSkip(+1)
Stabilize()
Say_Get("Insert")
RETURN NIL

// *********************************************************************

STATIC FUNCTION DeleteAdd()
LOCAL oMessage:=NewMessage()
TopStatus ("DELETE MODE")
oMessage:MsgTitle := "- Deleting"
oMessage:MsgText  := { 'You cannot delete an entry in ',;
                       'the Address Book file.', 'But try modifying it'}
Apply oMessage:MsgShow(oMessage)
RETURN NIL

// ********************************************************************

STATIC FUNCTION Write(nRec)
DBSELECTAR("ADDRESS")
DBGOTO (nRec)

ADDRESS->ClientId   :=  aAddress:ClientId
ADDRESS->Name       :=  aAddress:Name
ADDRESS->Address1   :=  aAddress:Address1
ADDRESS->Address2   :=  aAddress:Address2
ADDRESS->Address3   :=  aAddress:Address3
ADDRESS->Place      :=  aAddress:Place
ADDRESS->City       :=  aAddress:City
ADDRESS->PinCode    :=  aAddress:PinCode
ADDRESS->Phone      :=  aAddress:Phone
ADDRESS->Fax        :=  aAddress:Fax
ADDRESS->Desc       :=  aAddress:Desc
ADDRESS->Dept       :=  aAddress:Dept
ADDRESS->Tagged     :=  aAddress:Tagged

RETURN NIL

// ******************************************************************
STATIC FUNCTION Choose()
LOCAL R:=6, C:=4, GetList := {}, rRec := RECNO()
LOCAL oMsg:=NewMessage()

    DBGOBOTTOM()
    DBSKIP(+1)
    Stabilize()
    Say_Get("View")
    TopStatus("SELECT MODE")

SETCURSOR(3)
@ R,   C   SAY "Client Code: " Get aAddress:ClientId PICTURE "@A!"
@ R+2, C     SAY "Name    :"
@ R+2, C+10  Get aAddress:Name 
READMODAL (GetList)

IF !DBSEEK(aAddress:ClientId+RTRIM(aAddress:Name)) 
    oMsg:MsgTitle := "- Data not found!"
    oMsg:MsgText  := {"The Client Code entered was not found" }
    Apply oMsg:MsgShow(oMsg)
    DBGOTO (rRec)
ENDIF

RETURN NIL

// ************************************************************
Static Function PrintAdd()
LOCAL nIsAll, oMsg:=NewMessage(), nPage:=1, nType
LOCAL nCount:=3, PrintLen := PrintLine() 
LOCAL nCurrent := RecNo()

oMsg:MsgTitle   := "- Address Selection"
oMsg:MsgText    := {"Which of the Clients do you want to print?"}
oMsg:MsgButtons := {"Only this","Only Tagged Addresses","Cancel"}
oMsg:MsgDefault := 1
nIsAll          := Apply oMsg:MsgShow(oMsg)
IF nIsAll == 3; RETURN .T.; ENDIF

oMsg:MsgTitle   := "- Printing Format "
oMsg:MsgText    := {"In which format do you want to print?"}
oMsg:MsgButtons := {"Full details","Mailing List"}
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
     IF (nIsAll == 1) .OR. (nIsAll==2 .AND. ADDRESS->Tagged)
         DO CASE
            CASE nType == 2  // Mailing List
               nCount +=1
               @ nCount++,1 SAY ADDRESS->Name
               @ nCount++,1 SAY ADDRESS->Address1
               IF ADDRESS->Address2 <> " "
                  @ nCount++,1 SAY ADDRESS->Address2
               ENDIF   
               IF ADDRESS->Address3 <> " "               
                  @ nCount++,1 SAY ADDRESS->Address3
               ENDIF   
               @ nCount++,1 SAY ADDRESS->Place + " "+ ADDRESS->City
               @ nCount++,1 SAY "Pin:"+LTRIM(STR(ADDRESS->PinCode))
               nCount += 2
            CASE nType == 1  // Full Details
               nCount +=1
               @ nCount++,1 SAY ADDRESS->Name
               @ nCount++,1 SAY ADDRESS->Address1
               IF ADDRESS->Address2 <> " "
                  @ nCount++,1 SAY ADDRESS->Address2
               ENDIF   
               IF ADDRESS->Address3 <> " "               
                  @ nCount++,1 SAY ADDRESS->Address3
               ENDIF   
               @ nCount++,1 SAY ADDRESS->Place + " "+ ADDRESS->City
               @ nCount++,1 SAY "Pin:"+LTRIM(STR(ADDRESS->PinCode))
               nCount++
               @ nCount,1    SAY "Phone:"+ADDRESS->Phone
               @ nCount++,37 SAY "Fax  : "+ADDRESS->Fax
               @ nCount,1  SAY "Client Code: "+aAddress:ClientId
               @ nCount++,37 SAY "Dept : "+aAddress:Dept
               @ nCount++,1  SAY "Description: "+aAddress:Desc
               nCount++
            ENDCASE
      ENDIF
      IF nIsAll == 1
         EXIT
      ENDIF    
      IF !EOF()
          DBSKIP (+1)
          IF EOF()
             EXIT
          ENDIF   
      ELSE
          EXIT
      ENDIF
     
      If nCount+7 >= PrintLen
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
STATIC FUNCTION CHKCLIENT(Type)
LOCAL lT:=.f.
IF RTRIM(Type) == "MISC"
  lT:=.T. 
ELSE
  DBSELECTAR("CLIENT")
  lT := DBSEEK(Type)
ENDIF

DBSELECTAR("ADDRESS")
RETURN lT

