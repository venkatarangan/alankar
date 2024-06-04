// *************************************************************
// Booking Master
// Booking.Prg
// *************************************************************

#include "Form_Cls.Ch"
#include "Apply.Ch"
#include "Booking.Ch"
#include "Msg_Cls.Ch"
#include "Clr_Cls.Ch"
#include "List_Cls.ch"
#include "Sys_Cls.Ch"
#include "Inkey.ch"


STATIC aBooking [BOOKINGSIZE]

Function Booking()
LOCAL oForm
SET DELETE ON
oForm               := NewForm (6, 1, 20, 77,"Booking Register")
oForm:FormEdit      := { || DBSELECTAR ("BOOKING"),Say_Get("Edit")  }
oForm:FormStabilize := { || DBSELECTAR ("BOOKING"),Stabilize()      }
oForm:FormView      := { || DBSELECTAR ("BOOKING"),Say_Get("View")  }
oForm:FormInsert    := { || DBSELECTAR ("BOOKING"),InsertBooking()  }
oForm:FormDelete    := { || DBSELECTAR ("BOOKING"),DeleteBooking()  }
oForm:FormPrint     := { || DBSELECTAR ("BOOKING"),PrintBooking()   }
oForm:FormOpen      := { || OpenDataBase("VEHTYPE"),OpenDataBase("CLIENT"),OpenDataBase("BOOKING") }
oForm:FormClose     := { || CloseDataBase("BOOKING"),CloseDataBase("CLIENT"), CloseDataBase("VEHTYPE")}
oForm:FormChoose    := { || DBSELECTAR ("BOOKING"),Choose(oForm)            }
oForm:FormMemo      := { || .T.    }
oForm:FormSpecial   := { || .T. }
oForm:FormLastLine  := "F2-print; F4-edit; F7-select; "+;
                         "DEL-delete; INS-insert; ESC-return"
APPLY oForm:FormShow (oForm)
RETURN NIL

// ************************************************************

STATIC FUNCTION Stabilize()
aBooking:BookDate       :=  BOOKING->BOOKDATE 
aBooking:TodayDate      :=  BOOKING->TODAYDATE 
aBooking:Time           :=  BOOKING->TIME 
aBooking:Ref            :=  BOOKING->REF
aBooking:TypeId         :=  BOOKING->TYPEID
aBooking:ClientId       :=  BOOKING->CLIENTID
aBooking:Info1          :=  BOOKING->INFO1 
aBooking:Info2          :=  BOOKING->INFO2 
aBooking:Info3          :=  BOOKING->INFO3 
aBooking:Info4          :=  BOOKING->INFO4 
aBooking:Tagged         :=  BOOKING->TAGGED
RETURN NIL

// ************************************************************
STATIC FUNCTION Write(nRec)
LOCAL oTail:=NewTail()

DBGOTO (nRec)

BOOKING->BOOKDATE  :=     aBooking:BookDate           
BOOKING->TODAYDATE :=     aBooking:TodayDate           
BOOKING->TIME      :=     aBooking:Time           
BOOKING->TYPEID    :=     aBooking:TypeId         
BOOKING->CLIENTID  :=     aBooking:ClientId       
BOOKING->REF       :=     aBooking:Ref
BOOKING->INFO1     :=     aBooking:Info1         
BOOKING->INFO2     :=     aBooking:Info2           
BOOKING->INFO3     :=     aBooking:Info3          
BOOKING->INFO4     :=     aBooking:Info4          
BOOKING->TAGGED    :=     aBooking:Tagged         
                                                    
RETURN NIL
// ************************************************************

STATIC FUNCTION Say_Get(nMode)
LOCAL R:=7, C:=4
LOCAL GetList := {},nChoice
LOCAL oMsg:=NewMessage()

IF nMode == "View"
   SETCURSOR (0)                // SC_NONE
   TopStatus ("VIEW MODE")  
ELSEIF nMode =="Edit"
   SETCURSOR (1)                // SC_NORMAL
   TopStatus ("EDIT MODE")
ELSEIF nMode =="Insert"
   SETCURSOR (1)                // SC_NORMAL
   TopStatus ("INSERT MODE")
ENDIF
  
  DBSELECTAR("BOOKING")
  
  @ R,   C     SAY "Order Date     : " GET aBooking:TodayDate  WHEN nMode!="View" 
  @ R,   C+37  SAY "Reference      : " GET aBooking:Ref        WHEN nMode!="View" 
  
  @ R+1, C     SAY "Reporting Date : " GET aBooking:BookDate   WHEN nMode!="View" 
  @ R+1, C+37  SAY "Reporting Time : " GET aBooking:Time       WHEN nMode!="View";
               VALID {|oGet| CheckTime(oGet) } PICTURE "99:99"          

  @ R+3, C  SAY "Vehicle Type: " Get aBOOKING:TypeId PICTURE "@!" WHEN nMode!="View" ;
    Valid { |oGet| SuperCheckIt (oGet, "VEHTYPE" ,"BOOKING") }
               
 @ R+3, C+37  SAY "Client Code    : " Get aBOOKING:ClientId PICTURE "@A!" WHEN nMode!="View";
    Valid { |oGet| SuperCheckIt (oGet,"CLIENT","BOOKING") } 

  @ R+6, C+10  SAY "Information/Address "
  @ R+7, C+10  SAY "===================="
  @ R+8, C     GET aBooking:Info1  WHEN nMode!="View" 
  @ R+9, C     GET aBooking:Info2  WHEN nMode!="View" 
  @ R+10,C     GET aBooking:Info3  WHEN nMode!="View" 
  @ R+11,C     GET aBooking:Info4  WHEN nMode!="View"  
  
  READMODAL(GetList)

  DBSELECTAR("BOOKING")
  
  IF aBooking:Tagged
     @ R+9, C+61 SAY "<TAGGED>"
  ELSE
     @ R+9, C+61 SAY "<no tag>"
  ENDIF

  DBSELECTAR("BOOKING")
  
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

STATIC FUNCTION InsertBooking()
DBGOBOTTOM()
DbSkip(+1)
Stabilize()
aBooking:BookDate := aBooking:TodayDate := DATE()
Say_Get("Insert")
RETURN NIL

// *********************************************************************

STATIC FUNCTION DeleteBooking()
LOCAL oMessage:=NewMessage(), nChoice
TopStatus ("DELETE MODE")
oMessage:MsgTitle := "- Deleting"
oMessage:MsgText  := { 'Are you sure ? '}
oMessage:MsgButtons := {"Yes", "No", "Clean Up"}
nChoice := Apply oMessage:MsgShow(oMessage)
If nChoice == 1
   DBDELETE()
   DBGOTOP()
   Stabilize()
   Say_Get("View") 
ElseIF nChoice == 3
   PackUp()
Endif
RETURN NIL

// ********************************************************************

STATIC FUNCTION Choose()
LOCAL R:=7, C:=4, GetList := {}, rRec := RECNO()
LOCAL oMsg:=NewMessage()
DBGOBOTTOM()
DBSKIP(+1)
Stabilize()
Say_Get("View")
TopStatus("SELECT MODE")

SETCURSOR(3)
@ R+1, C     SAY "Reporting Date : " GET aBooking:BookDate
READMODAL (GetList)

DBGOTOP()
IF !DBSEEK(aBooking:BookDate) 
    oMsg:MsgTitle := "- Data not found!"
    oMsg:MsgText  := {"The Date you entered do not have a booking" }
    Apply oMsg:MsgShow(oMsg)
    DBGOTO (rRec)
ENDIF

RETURN NIL

//**********************************************************
Static Function PrintBooking()
LOCAL nIsAll, oMsg:=NewMessage(), nPage:=1, nType
LOCAL nCount:=3, PrintLen := PrintLine()
LOCAL nLine:=1, nCurrent := RecNo(), nDate := aBooking:BookDate

oMsg:MsgTitle   := "- Booking Report"
oMsg:MsgText    := {"Which of these do you want to print"}
oMsg:MsgButtons := {"All Bookings", "This Date Bookings","Only one","Cancel"}
oMsg:MsgDefault := 2
nIsAll          := Apply oMsg:MsgShow(oMsg)

DO CASE
   CASE nIsAll == 1
        DBGOTOP()
   CASE nIsAll == 2
        DBGOTOP()
        DBSEEK(abooking:BookDate)
        Stabilize()
   CASE nIsAll == 4
        RETURN .T.
ENDCASE

IF PrintOn()==.F.
   PrintNoReady()
ELSE
 @ 1, 1 SAY "Bookings Report"
 @ 1,50 SAY "Page No: "
 @ 1,60  SAY LTRIM(STR(nPage))
 @ 2, 1 SAY REPL ('-',75)
 DO WHILE .T. 
  DO CASE 
   CASE nIsAll == 1
      nCount := PrintInfo (nCount)  
   CASE nIsAll == 2
      IF aBooking:BookDate <> nDate 
         EXIT
      ENDIF 
      nCount := PrintInfo (nCount)  
   CASE nIsAll == 3
      nCount := PrintInfo (nCount)  
      EXIT
  ENDCASE
  IF !EOF()
       DBSKIP(+1)
       Stabilize() 
       IF EOF()
          EXIT
       ENDIF   
   ELSE
       EXIT
   ENDIF
     
   If nCount+11 >= PrintLen
         EJECT
         nCount := 3
         nPage  += 1
         @ 1, 1 SAY "Bookings Report"
         @ 1,50 SAY "Page No: "
         @ 1,60  SAY LTRIM(STR(nPage))
         @ 2, 1 SAY REPL ('-',75)
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
STATIC FUNCTION PrintInfo(nCount)
@ nCount,   1  SAY "Order Date: "
@ nCount,   20 SAY  aBooking:TodayDate
@ nCount,   35 SAY "Veh.Type: "   + aBooking:TypeId
@ nCount++, 55 SAY "Time :" + aBooking:Time

@ nCount,   1  SAY "Reporting Date:"
@ nCount,   20 SAY aBooking:BookDate
@ nCount++, 35 SAY "Client Code: " + aBooking:ClientId

@ nCount++, 54 SAY "Ref: " + aBooking:Ref

@ nCount++, 1 SAY "=> "+aBooking:Info1 

@ nCount++, 1 SAY "=> "+aBooking:Info2      

@ nCount++, 1 SAY "=> "+aBooking:Info3 

@ nCount++, 1 SAY "=> "+aBooking:Info4

nCount +=2
@ nCount++, 1 SAY REPL ('.',75)
nCount++

RETURN nCount
//**********************************************************
STATIC FUNCTION PackUp()
LOCAL oMsg:=NewMessage(), nChoice
oMsg:MsgText := {"Clean Up process may take few minutes.",;
                 "Use ONLY when your booking process takes long time."}
oMsg:MsgButtons :={"Proceed", "Cancel"}
oMsg:MsgDefault := 2
oMsg:MsgTitle := "- Clean Up Confirmation"
IF APPLY oMsg:MsgShow(oMsg) == 1
 DBSELECTAR("BOOKING")
 PACK
ELSE 
  oMsg:MsgText := {"Please use Clean Up some other time "}
  oMsg:MsgButtons :={"Ok"}
  oMsg:MsgDefault := 1
  oMsg:MsgTitle := ""
  APPLY oMsg:MsgShow(oMsg)
ENDIF 
RETURN NIL

//**********************************************************


