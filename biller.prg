/*
 Name                    :  Biller.prg
 Include                 :  Biller.Ch
 Date                    :  18/07/1995
 Author                  :  Venkata Rangan,TNC.
*/

#include "Form_Cls.Ch"
#include "Apply.Ch"
#include "Biller.Ch"
#include "Msg_Cls.Ch"
#include "Sys_Cls.Ch"
#include "Heading.ch"

STATIC aBill[BILLSIZE], sVehCode


// ************************************************************
Function BillMas()
LOCAL oForm

oForm               := NewForm (4, 1, 22, 78,"Bill Register")
oForm:FormEdit      := { || .T.  }
oForm:FormStabilize := { || Stabilize()       }
oForm:FormView      := { || Say_Get("View")   }
oForm:FormInsert    := { || .T.  }
oForm:FormDelete    := { || DeleteBill()  }
oForm:FormPrint     := { || PrintBill()    }
oForm:FormOpen      := { || OpenDatabase("CLIENT"),OpenDatabase("TRPSHEET"),;
                            OpenDataBase("BILLING")}
oForm:FormClose     := { || CloseDataBase("BILLING"),CloseDataBase("TRPSHEET"),;
                            CloseDataBase("CLIENT")}
oForm:FormChoose    := { || Choose()       }
oForm:FormLastLine  := "  F2-print  F7-select"+;
                         " DEL-delete ESC-go to main menu"
APPLY oForm:FormShow (oForm)
RETURN NIL

// ************************************************************

STATIC FUNCTION Stabilize()

DBSELECTAR("BILLING")
aBill:Num       := BILLING->BillNum
aBill:Date      := BILLING->BillDate
aBill:Amt       := BILLING->BillAmt
aBill:ClientId  := BILLING->ClientId
aBill:TrpNum    := BILLING->TrpNum
aBill:Tagged    := BILLING->Tagged
aBill:Cancelled := BILLING->Cancelled

DBSELECTAR("TRPSHEET")
DBSEEK(aBill:TrpNum)
aBill:TrpDate  := TRPSHEET->TrpDate
aBill:Days     := TRPSHEET->Days
aBill:Time     := TRPSHEET->Time
aBill:Kms      := TRPSHEET->Endkm - TRPSHEET->StartKm
aBill:Status   := TRPSHEET->Status
aBill:Hire     := TRPSHEET->Hiring
aBill:Extra    := TRPSHEET->Extra
aBill:Halt     := TRPSHEET->Halt
aBill:Min      := TRPSHEET->Minimum
aBill:Permit   := TRPSHEET->Permit
aBill:Misc     := TRPSHEET->Misc
sVehCode       := TRPSHEET->TypeId

IF RTRIM(aBill:ClientId) == "MISC"
   aBill:Name     := TRPSHEET->ClientName
   aBill:Address1 := ' ' 
   aBill:Address2 := ' '
   aBill:Address3 := ' '
   aBill:Place    := ' ' 
   aBill:City     := ' '
   aBill:PinCode  := 0
ELSE
   DBSELECTAR("CLIENT")
   DBSEEK(aBill:ClientId)
   aBill:Name     := CLIENT->Clientname
   aBill:Address1 := CLIENT->Address1
   aBill:Address2 := CLIENT->Address2
   aBill:Address3 := CLIENT->Address3
   aBill:Place    := CLIENT->Place
   aBill:City     := CLIENT->City
   aBill:PinCode  := CLIENT->PinCode
ENDIF

DBSELECTAR("BILLING")
IF BILLING->Printed == .F.
   Write()
ENDIF
RETURN NIL


// ******************************************************************


STATIC FUNCTION Choose()
LOCAL R:=5, C:=4, GetList := {}, rRec := RECNO()
LOCAL oMsg:=NewMessage(), nTemp := 000000

DBSELECTAR("BILLING")

 DBGOTOP()
 TopStatus("SELECT MODE")

  @ 5,3 CLEAR TO 21,77 
  SETCURSOR(3)
  @ R+2,   C     SAY "Bill No. :" Get nTemp PICTURE "999999"
  READMODAL (GetList)

  IF !DBSEEK(nTemp) 
      oMsg:MsgTitle := "- Bill not found!"
      oMsg:MsgText  := {"The Bill Number entered was not found" }
      Apply oMsg:MsgShow(oMsg)
      DBGOTO (rRec)
  ENDIF
  Stabilize()
  /*Say_Get("View")*/
RETURN NIL

// ************************************************************

STATIC FUNCTION Say_Get(nMode)
LOCAL R:=5, C:=4
LOCAL GetList := {}, nTemp,  nChoice, nLine := 8
/*LOCAL sBill := BILLING->BillImg*/
LOCAL oMsg:=NewMessage()
DBSELECTAR("BILLING")

 @ 5,3 CLEAR TO 21,77
 IF nMode == "View"
    SETCURSOR (0)                // SC_NONE
    TopStatus ("VIEW MODE")  
 ENDIF
 
 IF BILLING->Printed
    @ R++, 03 SAY "COPY"
 ELSE
    @ R++, 03 SAY "ORIGINAL"
 ENDIF      

 /*DO WHILE nLine <= 15 
    @ R,3 SAY MEMOLINE(sBill,75,nLine++)
    R++
 ENDDO*/

 R+=2

 @ R,   C+01 SAY "Bill No     : "
 @ R,   C+15 SAY aBill:Num
 @ R,   C+50 SAY "Date: "
 @ R++, C+60 SAY aBill:Date

 R++
 
 @ R,   C+01 SAY "Con.  No    : "
 @ R,   C+15 SAY aBill:TrpNum
 @ R,   C+45 SAY "Con. Date: "
 @ R++, C+60 SAY aBill:TrpDate

 R++
 
 @ R,   C+01 SAY "ClientCode  : "
 @ R++, C+15 SAY aBill:ClientId

 R++

 @ R,   C+01 SAY "AMOUNT (Rs.): "
 @ R++, C+15 SAY aBill:Amt

 R++
 
 
 IF aBill:Tagged
    @ 5, C+61 SAY "<TAGGED>"
 ELSE
    @ 5, C+61 SAY "<no tag>"
 ENDIF

 IF aBill:Cancelled
    @ 5, 40 SAY "CANCELLED"
 ELSE
    @ 5, 40 SAY "         "
 ENDIF

RETURN NIL

// ********************************************************************
STATIC FUNCTION Write()
LOCAL nRow := 1

FERASE("TEMP.TXT")
SET PRINTER TO "TEMP.PRN"
SET DEVICE  TO PRINTER
SET PRINTER ON

 nRow := Header(nRow)
 nRow := FullDetails(nRow)
 nRow := Footer(nRow)

SET DEVICE TO SCREEN
SET PRINTER OFF
SET PRINTER TO

 DBSELECTAR("BILLING")
 BILLING->BillImg := MemoRead("Temp.PRN")
RETURN NIL


//*********************************************************************
STATIC FUNCTION FullDetails(pR)
LOCAL nAmt:=0, sVehicle
LOCAL x, sAmt, rAmt, pAmt, wAmt

OpenDatabase("VEHTYPE")
        DBSELECTAR("VEHTYPE")
        DBSEEK(sVehCode)
        sVehicle := VEHTYPE->TypeDesc
        CloseDatabase("VEHTYPE")
DBSELECTAR("BILLING")
    
    @ pR,   01 SAY "Bill. No.: " + SUBSTR(CMONTH(aBill:Date),1,3) + '/' +;
       LTRIM(STR(aBill:Num)) + '/' + RIGHT(STR(YEAR(aBill:Date)),2)
    @ pR,   30 SAY '|'
    @ pR++, 50 SAY "| DATE : " + DTOC(aBill:Date)

    @ pR++, 01 SAY REPL('_',70)

    @ pR,   01 SAY 'To.'
    @ pR++, 50 SAY '|'

    @ pR,   05 SAY  aBill:Name
    @ pR++, 50 SAY '| ATTN:'

    @ pR,   05 SAY aBill:Address1
    @ pR++, 50 SAY '| -----'

    @ pR,   05 SAY aBill:Address2
    @ pR++, 50 SAY '|'

    @ pR,   05 SAY aBill:Address3 + aBill:Place
    @ pR++, 50 SAY '|'
   
    @ pR,   05 SAY aBill:City
    @ pR,   30 SAY 'Pin: '
    @ pR,   35 SAY aBill:PinCode
    @ pR++, 50 SAY '|'

    @ pR++, 01 SAY REPL('=',70)

    pR++

    @ pR++, 01 SAY "Charges for the car (" + RTRIM(sVehicle) + ")"

    @ pR,   01 SAY "engaged by you as per our Con. No:"
    @ pR++, 35 SAY LTRIM(STR(aBill:TrpNum)) + '   Dated: ' + DTOC(aBill:TrpDate)

    pR++

    @ pR, 01 SAY "TOTAL USED KMS................"
    @ pR++, 31 SAY  aBill:Kms  PICTURE "99999"

    pR++

    DO CASE
       CASE aBill:Status == 'F'   // LOCAL
          @ pR,   01 SAY "TOTAL USED HOURS.............."
          @ pR++, 31 SAY aBill:Time PICTURE "99999"

          pR++

          @ pR,   01 SAY "Hiring Charges....................................."
          @ pR,   54 SAY "Rs."
          @ pR++, 57 SAY aBill:Hire  PICTURE "99999999.99"

          @ pR,   01 SAY "Ext. Km Charges...................................."
          @ pR,   54 SAY "Rs."
          @ pR++, 57 SAY aBill:Extra   PICTURE "99999999.99"
          pR+=2

       CASE aBill:Status == 'S'  // HIRE
          @ pR,   01 SAY "TOTAL USED HOURS.............."
          @ pR++, 31 SAY aBill:Time PICTURE "99999"
                  
          @ pR,   01 SAY "Hiring Charges....................................."
          @ pR,   54 SAY "Rs."
          @ pR++, 57 SAY aBill:Hire  PICTURE "99999999.99"

          pR++

          @ pR,   01 SAY "Fuel Cost.........................................."
          @ pR,   54 SAY "Rs."
          @ pR++, 57 SAY aBill:Min  PICTURE "99999999.99"

          @ pR,   01 SAY "Extra Km Charges..................................."
          @ pR,   54 SAY "Rs."
          @ pR++, 57 SAY aBill:Extra   PICTURE "99999999.99"
          pR++
       OTHERWISE                     // OUTSTATION
           // 4 Lines
          @ pR,   01 SAY "TOTAL CALENDAR DAYS..........."
          @ pR++, 31 SAY aBill:Days PICTURE "99999"
                    
          pR++

          @ pR,   01 SAY "Total Charges......................................"
          @ pR,   54 SAY "Rs."
          @ pR++, 57 SAY aBill:Min + aBill:Extra PICTURE "99999999.99"

          @ pR,   01 SAY "Night Halt Charges................................."
          @ pR,   54 SAY "Rs."
          @ pR++, 57 SAY aBill:Halt   PICTURE "99999999.99"

          @ pR,   01 SAY "Permit Charges....................................."
          @ pR,   54 SAY "Rs."
          @ pR++, 57 SAY aBill:Permit PICTURE "99999999.99"
          pR+=1
          nAmt := aBill:Permit + aBill:Halt
    ENDCASE
    

          @ pR,    01 SAY "Misc. Expenses (Parking charges, etc.)............."
          @ pR,    54 SAY "Rs."
          @ pR++,  57 SAY aBill:Misc   PICTURE "99999999.99"
          
          nAmt += aBill:Hire  + aBill:Extra
          nAmt += aBill:Min  + aBill:Misc
          
          pR+=2

          @ pR++,  54 SAY "==============="

          @ pR,    01 SAY "TOTAL AMOUNT......................................."
          @ pR,    54 SAY "Rs."
          @ pR++,  57 SAY nAmt  PICTURE "99999999.99"

          @ pR++,  54 SAY "==============="

          sAmt := STR(nAmt)
          x    := AT('.',sAmt)
          rAmt := fig2word(val(substr(sAmt,1,x-1))) 
          pAmt := fig2word(val(substr(sAmt,x+1,2)))
          IF val(substr(sAmt,x+1,2)) <> 0
             wAmt := "(Rupees " + rAmt + " & " + pAmt + " paise only)"
          ELSE
             wAmt := "(Rupees " + rAmt + " only)"
          ENDIF
          pAmt := ''
          x := 1
          rAmt := wAmt

          DO WHILE LEN(rAmt) > 69
             x    :=  RAT(' ',rAmt)
             pAmt :=  SUBSTR(rAmt, x+1, 100) + ' ' +pAmt
             rAmt := SUBSTR(rAmt, 1,   x-1)
          ENDDO

          @ pR++,01 SAY rAmt
          @ pR++,01 SAY pAmt

          pR+=2

          @ pR++, 01 SAY "E. & O.E."

          //@ pR++, 01 SAY REPL('-',70)

          pR++

          @ pR++, 50 SAY "for " + UPPER(COMPANYNAME)

          pR+=5

RETURN pR++

//*********************************************************************
STATIC FUNCTION Footer(pR)
    @ pR,   01 SAY REPL('_',70)
    @ ++pR, 02 SAY DATE() 
    @ pR,   60 SAY TIME()
    @ ++pR, 01 SAY REPL(' ',70)
RETURN pR

//********************************************************************
STATIC FUNCTION Header (pR)
LOCAL sHead := MEMOREAD (HEADFILE), nX:=0        
    DO WHILE nX <= 5
       @ pR++, 1 SAY MEMOLINE(sHead, 70, nX++)
    ENDDO   
RETURN ++pR

//*********************************************************************
STATIC FUNCTION PrintBill()
LOCAL oMessage:=NewMessage()
LOCAL nChoice,rRec := RECNO(), nPage := 1

DBSELECTAR("BILLING")

IF BILLING->Cancelled
   ALERT ('This bill has been deleted')
   RETURN NIL
ENDIF

oMessage:MsgTitle   := "- Printing a Bill"
oMessage:MsgText    := { "You have choosed to print Bill",;
                         "Please select your choice: "}
oMessage:MsgDefault := 1                         
oMessage:MsgButtons := {"This Bill", "Only Tagged Bills","All Bills","Cancel"}
nChoice := Apply oMessage:MsgShow(oMessage)

IF nChoice == 4; RETURN .T.; ENDIF

IF !PrintOn()
    oMessage:MsgTitle   := "- PRINTER NOT READY !"   
    oMessage:MsgText    := { "Please make ready your printer and try again"}
    oMessage:MsgButtons := {"Ok"}
    Apply oMessage:MsgShow(oMessage)
    RETURN NIL
ELSE
    IF nChoice == 1
       PrintControl (nPage)
    ELSEIF nChoice==2
       DBEVAL ({||IIF(BILLING->Tagged,;
           PrintControl(nPage++),.F.)})
    ELSE 
       DBEVAL ({||PrintControl(nPage++)})
    ENDIF    
    PrintOff()
    IF BILLING->Printed == .F.
       BILLING->PRINTED := .T.
    ENDIF 
    oMessage:MsgTitle   := "- FINISHED PRINTING !"   
    oMessage:MsgText    := { "The Computer has finished sending the data.",;
                             "You can continue with your work."}
    oMessage:MsgButtons := {"Ok"}
    Apply oMessage:MsgShow(oMessage)
ENDIF
DBGOTO (rRec)
RETURN NIL

//***********************************************************************
STATIC FUNCTION PRINTCONTROL(nPage)
LOCAL nRow:=1, sBill := BILLING->BillImg, nLine:=3

IF nPage>1
 EJECT
ELSE
 SETPRC(nRow,1)      // Prevents Ejection of Printer
ENDIF
DO WHILE nLine <= MLCOUNT(sBill)
   @ nRow,1 SAY MEMOLINE(sBill,75,nLine++)
   nRow++
ENDDO
IF BILLING->Printed
   @ nRow++, 03 SAY "[COPY]"
ELSE
   @ nRow++, 03 SAY "[ORIGINAL]"
ENDIF

RETURN Nil

//**************************************************************************
STATIC FUNCTION DeleteBill()
LOCAL oMessage := NewMessage(), nChoice
DBSELECTAR('BILLING')

oMessage:MsgTitle   := "- Deleting a Bill"
oMessage:MsgText    := { "You have choosed to cancel this Bill",;
                         "Are you sure ?"}
oMessage:MsgDefault := 2                         
oMessage:MsgButtons := {"Yes", "No"}
nChoice := Apply oMessage:MsgShow(oMessage)

IF nChoice == 1
            OpenDatabase  ("ACCOUNTS")
                    DBAPPEND()    
                    ACCOUNTS->ClientId  := aBill:ClientId
                    ACCOUNTS->Date      := aBill:Date
                    ACCOUNTS->Desc      := "CANCELLED BILL"
                    ACCOUNTS->Num       := STR(aBill:Num)
                    ACCOUNTS->Recd      := aBill:Amt
            CloseDatabase ("ACCOUNTS")
            DBSELECTAR('BILLING')
            BILLING->Cancelled := .T.
ELSE
            DBSELECTAR('BILLING')
ENDIF

RETURN NIL
