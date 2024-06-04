// *************************************************************
// Accounts Master
// Accounts.Prg
// *************************************************************

#include "Form_Cls.Ch"
#include "Apply.Ch"
#include "Accounts.Ch"
#include "Msg_Cls.Ch"
#include "Sys_Cls.Ch"


STATIC aAccounts [ACCSIZE]

Function AccMas()
LOCAL oForm

oForm               := NewForm (5, 7, 19, 71,"Accounts Register")
oForm:FormEdit      := { || Say_Get("Edit")  }
oForm:FormStabilize := { || Stabilize()         }
oForm:FormView      := { || Say_Get("View")     }
oForm:FormInsert    := { || InsertAcc()         }
oForm:FormDelete    := { || DeleteAcc()         }
oForm:FormPrint     := { || PrintAcc()          }
oForm:FormOpen      := { || OpenDataBase("CLIENT"), OpenDataBase("ACCOUNTS") }
oForm:FormClose     := { || CloseDataBase("ACCOUNTS"), CloseDatabase("CLIENT")}
oForm:FormChoose    := { || Choose(oForm)       }
oForm:FormSpecial   := { || TotalSpecial()      }
oForm:FormLastLine  := "  F4-Edit; INS-Add a new entry; ESC-go to main menu"
APPLY oForm:FormShow (oForm)
RETURN NIL

// ************************************************************

STATIC FUNCTION Stabilize()

aACCOUNTS:Recd     := ACCOUNTS->Recd
aACCOUNTS:Bill     := ACCOUNTS->Bill
aACCOUNTS:Desc     := ACCOUNTS->Desc
aACCOUNTS:Num      := ACCOUNTS->Num
aACCOUNTS:Date     := ACCOUNTS->Date
aACCOUNTS:ClientId := ACCOUNTS->ClientId
aACCOUNTS:Tagged   := ACCOUNTS->Tagged
RETURN NIL

// ************************************************************
STATIC FUNCTION Say_Get(nMode)
LOCAL R:=6, C:=10
LOCAL GetList := {}, nTemp,  nChoice
LOCAL oMsg:=NewMessage()

        IF nMode == "View"
               SETCURSOR (0)                // SC_NONE
               TopStatus ("VIEW MODE")
               @ 16,10 Say " F7 - To Select a Customer"
               @ 17,10 Say " F5 - To See Outstanding Balance of Customer(s)"
               @ 18,10 Say " F2 - To Print the Statement of this customer"
        ELSEIF nMode =="Edit"
               SETCURSOR (1)               // SC_NORMAL
               TopStatus ("EDIT MODE")
               @ 16,10 Say "                          "
               @ 17,10 Say "                                               "
               @ 18,10 Say "                                             "
        ELSEIF nMode =="Insert"
               SETCURSOR (1)               // SC_NORMAL
               TopStatus ("INSERT MODE")
               @ 16,10 Say "                          "
               @ 17,10 Say "                                               "
               @ 18,10 Say "                                             "
        ENDIF

@ R+1, C    SAY "ClientCode:" GET aAccounts:ClientId WHEN nMode!="View" PICTURE "@!";
            VALID { |oGet| ChkClient(oGet:Buffer) } 

@ R+3, C+6  SAY "Description"
@ R+4, C+4  GET aAccounts:Desc WHEN nMode!="View"

@ R+3, C+32 SAY "Number"
@ R+4, C+27 GET aAccounts:Num  WHEN nMode!="View"

@ R+3, C+48 SAY "Dated" 
@ R+4, C+47 GET aAccounts:Date  WHEN nMode!="View"

@ R+6, C+8  SAY "Received"
@ R+7, C    SAY "(Rs.)" GET aAccounts:Recd  WHEN nMode!="View"  

@ R+6, C+33 SAY "Billed"
@ R+7, C+24 SAY "(Rs.)" GET aAccounts:Bill  WHEN nMode!="View"  

READMODAL(GetList)

            IF aAccounts:Tagged
                @ R, C+45 SAY "<TAGGED>"
            ELSE
                @ R, C+45 SAY "<no tag>"
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

STATIC FUNCTION InsertAcc()
DBGOBOTTOM()
DbSkip(+1)
Stabilize()
Say_Get("Insert")
RETURN NIL

// *********************************************************************

STATIC FUNCTION DeleteAcc()
LOCAL oMessage:=NewMessage()
TopStatus ("DELETE MODE")
oMessage:MsgTitle := "- Deleting"
oMessage:MsgText  := { 'You cannot delete an entry in ',;
                       'the Accounts Register file.'}
Apply oMessage:MsgShow(oMessage)
RETURN NIL

// ********************************************************************

STATIC FUNCTION Write(nRec)
LOCAL oTail:=NewTail()

DBSELECTAR("ACCOUNTS")
DBGOTO (nRec)
ACCOUNTS->Recd      :=     aACCOUNTS:Recd      
ACCOUNTS->Bill      :=     aACCOUNTS:Bill     
ACCOUNTS->Desc      :=     aACCOUNTS:Desc     
ACCOUNTS->Num       :=     aACCOUNTS:Num      
ACCOUNTS->Date      :=     aACCOUNTS:Date     
ACCOUNTS->ClientId  :=     aACCOUNTS:ClientId 

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
@ R+1,   C+17  Get aAccounts:ClientId PICTURE "@!" 
READMODAL (GetList)

DBGOTOP()
IF !DBSEEK(aAccounts:ClientId) 
    oMsg:MsgTitle := "- Data not found!"
    oMsg:MsgText  := {"The Client type entered was not found" }
    Apply oMsg:MsgShow(oMsg)
    DBGOTO (rRec)
ENDIF

RETURN NIL

// ************************************************************

Static Function PrintAcc()
LOCAL nCurrent:=RECNO(), oMsg:=NewMessage(), nChoice 
TopStatus("PRINT MODE")

If !PrintOn()
   PrintNoReady()
ELSE
   PrintControl()
   PrintOff()
   oMsg:MsgTitle   := "- FINISHED PRINTING !"   
   oMsg:MsgText    := { "The Computer has finished sending the data.",;
                             "You can continue with your work."}
   oMsg:MsgButtons := {"Ok"}
   Apply oMsg:MsgShow(oMsg)
ENDIF

TopStatus("VIEW MODE")    
DBGOTO(nCurrent)
Return NIL   

//**************************************************************
STATIC FUNCTION CHKCLIENT(Type)
LOCAL lT:=.f.
IF RTRIM(Type) == "MISC"
  lT:=.T. 
ELSE
  DBSELECTAR("CLIENT")
  lT := DBSEEK(Type)
ENDIF

DBSELECTAR("ACCOUNTS")
RETURN lT

//***************************************************************
STATIC FUNCTION PrintControl()
LOCAL nPage:=1, nRow := 1, nLines := PrintLine(), nRecd:=0, nBill:=0
LOCAL nClient, nC := .T.

nClient := aAccounts:ClientId

DBSELECTAR("CLIENT")
DBSEEK(aAccounts:ClientId)

DBSELECTAR("ACCOUNTS")
DBGOTOP()
DBSEEK(nClient)
Stabilize()

DO WHILE nC ==.T.
   nRow := 1 
   @ nRow,   01  SAY "Statement : "

   IF RTRIM(nClient) == "MISC"
      @ nRow++, 15  SAY  "MISC"
   ELSE
      @ nRow++, 15  SAY  CLIENT->ClientName
   ENDIF

   @ nRow++, 01  SAY REPL('=',70)
   
   @ nRow,   01  SAY "Description"
   @ nRow,   18  SAY "Number"
   @ nRow,   35  SAY "Date" 
   @ nRow,   45  SAY "Recd (Rs.)"
   @ nRow++, 60  SAY "Bill (Rs.)"   
   @ nRow++, 01  SAY REPL('-',70)
   
   nRow++
   
   DO WHILE nRow+7<nLines
     IF aAccounts:ClientId<>nClient
       nRow++ 
       @ nRow,   25 SAY "Total: "
       @ nRow,   45 SAY  nRecd PICTURE "9999999.99"
       @ nRow++, 60 SAY  nBill PICTURE "9999999.99"       
       @ nRow++, 36 SAY "============"
       @ nRow,   25 SAY "AMOUNT DUE :" 
       @ nRow++, 37 SAY  nBill-nRecd PICTURE "9999999.99"       
       @ nRow++, 36 SAY "============"
       @ nRow++,01 SAY REPL('_',70)
       @ nRow,  02 SAY DATE() 
       @ nRow++,  60 SAY TIME()
       nC:=.F.
       EXIT
     ELSE   
       @ nRow, 01  SAY aAccounts:Desc
       @ nRow, 18  SAY aAccounts:Num
       @ nRow, 35  SAY DTOC(aAccounts:Date)
       @ nRow, 45  SAY aAccounts:Recd PICTURE "9999999.99"
       @ nRow++,60  SAY aAccounts:Bill PICTURE "9999999.99"
       nRecd += aAccounts:Recd
       nBill += aAccounts:Bill
       DBSKIP(+1)
       Stabilize()
     ENDIF
   ENDDO
   EJECT
   LOOP
ENDDO

RETURN NIL
//***************************************************************

STATIC FUNCTION TotalSpecial()
LOCAL nRecd, nBill, nClientId := ACCOUNTS->ClientId
LOCAL oMsg := NewMessage(), nChoice

oMsg:MsgButtons := {"Only this Customer","All Customers"}
oMsg:MsgText    := {"Please choose the category for the statement",;
                 " of amount's pending"}
oMsg:MsgTitle   := ''                 
oMsg:MsgDefault := 2
nChoice := APPLY oMsg:MsgShow(oMsg)

DBSELECTAR("ACCOUNTS")
DBGOTOP()

IF nChoice == 2
   SUM ACCOUNTS->RECD TO nRecd
   SUM ACCOUNTS->BILL TO nBill
   oMsg:MsgTitle := "- All Customers"
ELSE
   SUM ACCOUNTS->RECD TO nRecd FOR (ACCOUNTS->ClientId == nClientId)
   SUM ACCOUNTS->BILL TO nBill FOR (ACCOUNTS->ClientId == nClientId)
   oMsg:MsgTitle := "- Only " + LTRIM(nClientId)
ENDIF           

oMsg:MsgButtons := {"Ok"}
oMsg:MsgDefault := 1
oMsg:MsgText    := {" Total Recd (Rs.): " + LTRIM(STR(nRecd)),;
                    " Total Bill (Rs.): " + LTRIM(STR(nBill))," " ,;
                    " Amount Due (Rs.): " + LTRIM(STR(nBill-nRecd))} 
APPLY oMsg:MsgShow(oMsg)                 

RETURN NIL
