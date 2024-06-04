// *************************************************************
// Vehicle Type Master
// VehType.Prg
// *************************************************************

#include "Form_Cls.Ch"
#include "Apply.Ch"
#include "VehType.Ch"
#include "Tail_Cls.Ch"
#include "Msg_Cls.Ch"
#include "List_Cls.cH"
#include "Sys_Cls.Ch"


STATIC aVehType [VTYPESIZE]

Function VehType()
LOCAL oForm

oForm               := NewForm (6, 1, 17, 77,"Vehicle Type Master")
oForm:FormEdit      := { || Say_Get("Edit")     }
oForm:FormStabilize := { || Stabilize()         }
oForm:FormView      := { || Say_Get("View")     }
oForm:FormInsert    := { || InsertVeh()         }
oForm:FormDelete    := { || DeleteVeh()         }
oForm:FormPrint     := { || PrintVeh()          }
oForm:FormOpen      := { || OpenDataBase("VEHTYPE") }
oForm:FormClose     := { || CloseDataBase("VEHTYPE")}
oForm:FormChoose    := { || Choose(oForm)       }
oForm:FormLastLine  := "  F2-print  F4-edit  F7-select"+;
                         " DEL-delete  INS-insert   ESC-go to main menu"
APPLY oForm:FormShow (oForm)
RETURN NIL

// ************************************************************

STATIC FUNCTION Stabilize()

aVehType:TypeId         := VEHTYPE->TypeId
aVehType:TypeDesc       := VEHTYPE->TypeDesc
aVehType:Tagged         := VEHTYPE->Tagged

RETURN NIL

// ************************************************************


STATIC FUNCTION Say_Get(nMode)
LOCAL R:=7, C:=4
LOCAL GetList := {}, nTemp,  nChoice
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

nTemp := aVehType:TypeId

@ R,   C     SAY "Vehicle Type : " Get aVehType:TypeId PICTURE "@!" WHEN nMode!="View" ;
                                Valid { | oGet | PresenceChk(oGet,nTemp)}
@ R+2, C     SAY "Vehicle Description "
@ R+3, C     Get aVehType:TypeDesc When nMode != "View"


READMODAL(GetList)

            IF aVehType:Tagged
                @ R+2, C+61 SAY "<TAGGED>"
            ELSE
                @ R+2, C+61 SAY "<no tag>"
            ENDIF

            IF nMode !="View"
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
                         IIF(nMode=="Insert",DBAPPEND(),.F.)
                         Write(RECNO())
                  ENDIF
                  EXIT
               ENDDO
            ENDIF
RETURN NIL

// ********************************************************************

STATIC FUNCTION InsertVeh()
DBGOBOTTOM()
DbSkip(+1)
Stabilize()
Say_Get("Insert")
RETURN NIL

// *********************************************************************

STATIC FUNCTION DeleteVeh()
LOCAL oMessage:=NewMessage()
TopStatus ("DELETE MODE")
oMessage:MsgTitle := "- Deleting"
oMessage:MsgText  := { 'You cannot delete an entry in ',;
                       'the Vehicle Type Master file.'}
Apply oMessage:MsgShow(oMessage)
RETURN NIL

// ********************************************************************

STATIC FUNCTION Write(nRec)
LOCAL oTail:=NewTail()

DBSELECTAR("VEHTYPE")
DBGOTO (nRec)

VEHTYPE->TypeId         := aVehType:TypeId
VEHTYPE->TypeDesc       := aVehType:TypeDesc
VEHTYPE->Tagged         := aVehType:Tagged

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
@ R,   C     SAY "Vehicle Type : " Get aVehType:TypeId PICTURE "@!"
READMODAL (GetList)

IF !DBSEEK(aVehType:TypeId) 
    oMsg:MsgTitle := "- Data not found!"
    oMsg:MsgText  := {"The Vehicle type entered was not found" }
    Apply oMsg:MsgShow(oMsg)
    DBGOTO (rRec)
ENDIF

RETURN NIL

// ************************************************************

Static Function PrintVeh()
LOCAL PrintLen:=PrintLine(), oMsg := NewMessage(), nPage:=1
LOCAL nCount:=3, nUserChoice, nCurrent := RECNO()
oMsg:MsgTitle   := "- Vehicle Selection"
oMsg:MsgText    := {"Which vehicles description you want to print"}
oMsg:MsgButtons := {"All Vehicles","Only Tagged Vehicles","Cancel"}
oMsg:MsgDefault := 1
nUserChoice := Apply oMsg:MsgShow(oMsg) 
IF nUserChoice == 3; RETURN .T.; ENDIF

If PrintOn() ==.F.
   PrintNoReady() 
Else
  @ 1, 1 SAY "Vehicle Code and Description"
  @ 1,50 SAY "Page No: "
  @ 1,60 SAY LTRIM(STR(nPage))
  @ 2,1   SAY REPL("-",75)
  DBGOTOP()
  
  Do While .T.
     IF  nUserChoice == 1 .OR. ((nUserChoice == 2) .AND. VEHTYPE->Tagged) 
         @ nCount++,1 SAY VEHTYPE->TypeId+SPACE(10)+VEHTYPE->TypeDesc
     ENDIF
     
     IF !EOF()
        DBSKIP (+1)
     ELSE
        EXIT
     ENDIF
     
     If nCount == PrintLen
        EJECT
        nCount := 3
        nPage  += 1
        @ 1,1  SAY "Vehicle Code and Description"
        @ 1,50 SAY "Page No: "
        @ 1,60  SAY LTRIM(STR(nPage))
        @ 2,1  SAY REPL("-",75)
     Endif   
  Enddo   
  
  PrintOff()
    oMsg:MsgTitle   := "- FINISHED PRINTING !"   
    oMsg:MsgText    := { "The Computer has finished sending the data.",;
                             "You can continue with your work."}
    oMsg:MsgButtons := {"Ok"}
    Apply oMsg:MsgShow(oMsg)
Endif
DBGOTO(nCurrent)
Return NIL   
