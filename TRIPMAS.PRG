/*
* PRG...............: TRIPMAS.PRG
* INCLUDE...........: TRIPMAS.CH
* DESC..............: Implements Confirmatory Order information.
* EXPORTS...........: Nil
* STATIC FUNCTIONS..: StabilizeTrip(), Say_GetTrip(), InsertTrip(),
*                     DeleteTrip(), PrintTrip(), WriteTrip(), OpenTrip(),
*                     ShowCustomer().
*
* USES..............: Standard Clipper Functions
*                     Stack Class   - STK_CLS.PRG.
*                     System Class  - SYS_CLS.PRG
*                     Color Class   - CLR_CLS.PRG.
*                     Form Class    - FORM_CLS.PRG.
*                     Message Class - MSG_CLS.PRG.
*                     List Class    - LIST_CLS.PRG.
*                     Code Class    - TAIL_CLS.PRG.
*       
* NOTES.............:
* AUTHOR............: venkata rangan, tnc. 
* DATE..............: 16/07/1995.
* PROJECT...........: Alankar Billing Module.
*
* COMPILER..........: CA-Clipper 5.2
* SWITCHES..........: /n /w /m
*/

#include "Form_Cls.Ch"
#include "Fare_Cls.Ch"
#include "StdFares.Ch"
#include "Apply.Ch"
#include "TripMas.Ch"
#include "Msg_Cls.Ch"
#include "Sys_Cls.Ch"
#include "Inkey.Ch"
#include "Heading.Ch"


STATIC aTrpSheet [TMAS_SIZE], sFares, nType

/*******************************************************************
*  This procedure is called by the main program and this uses the  *
*     form class. It constructs a new form object and initializes  *
*     that object's code blocks to point to this program file's    *
*     functions.                                                   *
*                                                                  *
********************************************************************
*/
PROCEDURE Tripmaster
LOCAL oForm
oForm               := NewForm (3, 1, 22, 77,"Confirmatory Order")
oForm:FormEdit      := { || DBSELECTAR("TRPSHEET"),Say_GetTrip("Edit") }
oForm:FormStabilize := { || DBSELECTAR("TRPSHEET"),StabilizeTrip()     }
oForm:FormView      := { || DBSELECTAR("TRPSHEET"),Say_GetTrip("View") }
oForm:FormInsert    := { || DBSELECTAR("TRPSHEET"),InsertTrip()        }
oForm:FormDelete    := { || DBSELECTAR("TRPSHEET"),DeleteTrip()        }
oForm:FormPrint     := { || DBSELECTAR("TRPSHEET"),PrintTrip()         }
oForm:FormOpen      := { || OpenDataBase("VEHTYPE"),   OpenDataBase("CLIENT"),;
                            OpenDataBase("BILLING"),   OpenDataBase("TRPSHEET")}
oForm:FormClose     := { || CloseDataBase("TRPSHEET"), CloseDataBase("CLIENT"),;
                            CloseDataBase("BILLING"),  CloseDataBase("VEHTYPE")}
oForm:FormChoose    := { || DBSELECTAR("TRPSHEET"),ChooseTrip(oForm) }
oForm:FormLastLine  := "  F2-print  F4-edit  F7-select"+;
                         " DEL-delete  INS-insert   ESC-go to main menu"
APPLY oForm:FormShow (oForm)
RETURN

/*
********************************************************************
* This function reads data from the file tripmas and               *
*      writes it into the memory array aTrpSheet.                  *
********************************************************************
*/
STATIC FUNCTION StabilizeTrip  ()
aTrpSheet:mTrpNum     := TrpSheet->TRPNUM
aTrpSheet:mTrpDate    := TrpSheet->TRPDATE
aTrpSheet:mRegNum     := TrpSheet->REGNUM
aTrpSheet:mStartKm    := TrpSheet->STARTKM
aTrpSheet:mEndKm      := TrpSheet->ENDKM
aTrpSheet:mStartDt    := TrpSheet->STARTDT
aTrpSheet:mEndDt      := TrpSheet->ENDDT
aTrpSheet:mStartTm    := TrpSheet->STARTTM
aTrpSheet:mEndTm      := TrpSheet->ENDTM
aTrpSheet:mDriver     := TrpSheet->DRIVER
aTrpSheet:mClientId   := TrpSheet->CLIENTID
aTrpSheet:mIsBilled   := TrpSheet->ISBILLED
aTrpSheet:mBillNum    := TrpSheet->BILLNUM
aTrpSheet:mTagged     := TrpSheet->TAGGED
aTrpSheet:mTypeId     := TrpSheet->TYPEID
aTrpSheet:mClientName := TrpSheet->CLIENTNAME
aTrpSheet:mPermit     := TrpSheet->PERMIT
aTrpSheet:mMisc       := TrpSheet->MISC
aTrpSheet:mStatus     := TrpSheet->STATUS
RETURN NIL


/*
********************************************************************
* This function displays and allows user to edit the fields in the *
*      screen. It uses a WHEN clause of GET to implement SAY.      *
********************************************************************
*/

STATIC FUNCTION Say_GetTrip (nMode)
LOCAL R:=4, C:=4
LOCAL GetList := {}, nTemp,  nChoice

LOCAL nDate := Date(), nBillAmt, nBillNum

LOCAL oMsg:=NewMessage()
LOCAL oCharge[CHARGESIZE]

DBSELECTAR ("TRPSHEET")
@ R+5, C CLEAR TO R+5,75

IF nMode == "View"
   SETCURSOR (0)                // SC_NONE
   TopStatus ("VIEW MODE")  
   @ R+7, C    SAY aTrpSheet:mClientName
ELSEIF nMode =="Edit"
   SETCURSOR (1)                // SC_NORMAL
   TopStatus ("EDIT MODE")
   @ R+7, C  CLEA TO R+7,C+70
ELSEIF nMode =="Insert"
   SETCURSOR (1)               // SC_NORMAL
   TopStatus ("INSERT MODE")
   @ R+7, C  CLEA TO R+7,C+70
ENDIF
IF aTrpSheet:mTagged
    @ R, C+60 SAY "<TAGGED>"
ELSE
    @ R, C+60 SAY "<no tag>"
ENDIF

DO CASE
   CASE aTrpSheet:mStatus == 'F'
    @ R,30 SAY "{ FLAT  Rate }"
   CASE aTrpSheet:mStatus == 'S'
    @ R,30 SAY "{ SPLIT Rate }"
   CASE aTrpSheet:mStatus == 'O'
    @ R,30 SAY "{ OUTSTATION }"
   OTHERWISE
    @ R,30 SAY "              "
ENDCASE

IF aTrpSheet:mIsBilled
   @ R, C SAY "[BILLED]     "
ELSE
   @ R, C SAY "[NOT BILLED] "
ENDIF
R+=2

nTemp := aTrpSheet:mTrpNum
@ R,   C     SAY "TRIP SHEET No."
@ R,   C+15  GET aTrpSheet:mTrpNum  PICTURE "999999" WHEN nMode!="View" ;
             VALID {|oGet| PresenceChk(oGet,nTemp)}

@ R,   C+48 SAY  "Date  :"
@ R,   C+57 GET  aTrpSheet:mTrpDate WHEN nMode!="View" 

@ R+2, C    SAY  "Driver :" GET aTrpSheet:mDriver    WHEN nMode!="View"
@ R+2, C+40 SAY  "Reg.  No      : " GET aTrpSheet:mRegNum PICTURE "@!" WHEN nMode!="View"


@ R+4,  C    SAY "Client Code   : " GET aTrpSheet:mClientId PICTURE "@A!" WHEN nMode!="View";
   Valid { |oGet| SuperClient (oGet,R+5,C,"TRPSHEET") } 
 

@ R+4,  C+40 SAY "Vehicle Type  : " GET aTrpSheet:mTypeId PICTURE "@!" WHEN nMode!="View";
    Valid { |oGet| SuperVehicle (oGet, R+5, C+40,"TRPSHEET") }

@ R+7, C    SAY "Closing Km    : " GET aTrpSheet:mEndKm    WHEN nMode!="View"
@ R+7, C+40 SAY "Closing Time  : " GET aTrpSheet:mEndTm    WHEN nMode!="View";
     PICTURE "99:99" VALID {|oGet| CheckTime(oGet)}

@ R+9,  C    SAY "Start Km      : " GET aTrpSheet:mStartKm  WHEN nMode!="View";
     VALID {|oGet| IIF(VAL(oGet:Buffer)<=aTrpSheet:mEndKm,.T.,;
            Messager("The Starting KM is greater than End Km, Retry.") ) }

@ R+9,  C+40 SAY "Start Time    : " GET aTrpSheet:mStartTm  WHEN nMode!="View";
     PICTURE "99:99" VALID {|oGet| CheckTime(oGet)}


@ R+11, C    SAY "Closing Date  : " GET aTrpSheet:mEndDt    WHEN nMode!="View"
@ R+11, C+40 SAY "Starting Date : " GET aTrpSheet:mStartDt  WHEN nMode!="View";
      VALID {|oGet| IIF(CTOD(oGet:Buffer)<=aTrpSheet:mEndDt,.T.,;
           Messager("The Starting Date is greater than End Date, Retry.") ) }
        

@ R+13, C    SAY "Permit (Rs.)  : " GET aTrpSheet:mPermit   WHEN nMode!="View"
@ R+13, C+40 SAY "Misc.  (Rs.)  : " GET aTrpSheet:mMisc     WHEN nMode!="View"

@ R+15, C    SAY "Bill Number   : " GET aTrpSheet:mBillNum  WHEN nMode=="Insert";
             VALID { |oGet| BillChk(oGet:Buffer)} PICTURE "999999"

@ R+15, C+40 SAY "Bill Date     : " GET nDate     WHEN nMode!="View"
READMODAL (GetList)
If LastKey() = K_ESC
   Return Nil
Endif


IF nMode !="View"
   DO WHILE (Time2Val(aTrpSheet:mStartTm,aTrpSheet:mEndTm,;
                       aTrpSheet:mEndDt-aTrpSheet:mStartDt)<= 0)
       READMODAL(GetList)
   ENDDO
   DO WHILE .T.
      IF RTRIM(aTrpSheet:mClientId) == "MISC" .OR. UPPER(CLIENT->IsSplit) == "Y"
          oMsg:MsgButtons := {"Flat","Outstation","Split"}
      ELSE   
          oMsg:MsgButtons := {"Flat","Outstation"}
      ENDIF

      oMsg:MsgText    := {"Please Indicate the type of travel"}
      oMsg:MsgTitle   := ''
      oMsg:MsgDefault := 1
      nType := Apply oMsg:MsgShow(oMsg)

      oMsg:MsgTitle   := "- Confirm Changes"
      oMsg:MsgText    := {"What is Your Choice"}
      oMsg:MsgDefault := 1
      oMsg:MsgButtons := {'Change it','Save','Cancel'}
      nChoice := Apply oMsg:MsgShow(oMsg)
      IF nChoice == 1
         DBSELECTAR("TRPSHEET")
         READMODAL (GetList)
         LOOP
      ELSEIF nChoice==2
         IIF(nMode=="Insert",DBAPPEND(),.F.)
         WriteTrip(RECNO())
         oCharge:= TripProcess(RECNO())
         TRPSHEET->STATUS     := oCharge:zStatus 
         TRPSHEET->HIRING     := oCharge:zHire
         TRPSHEET->EXTRA      := oCharge:zExtra
         TRPSHEET->HALT       := oCharge:zHalt 
         TRPSHEET->MINIMUM    := oCharge:zMin
         TRPSHEET->TIME       := oCharge:zTime
         TRPSHEET->DAYS       := oCharge:zDays

         nBillAmt := oCharge:zHire  + oCharge:zExtra + aTrpSheet:mMisc
         nBillAmt += oCharge:zMin
         IF oCharge:zStatus == "O"
            nBillAmt += aTrpSheet:mPermit + oCharge:zHalt
         ENDIF
         Biller(aTrpSheet:mBillNum,nDate,aTrpSheet:mClientId,nBillAmt,nMode)
      ENDIF
      EXIT
   ENDDO
ENDIF
RETURN NIL

//**************************************************************************
STATIC FUNCTION TripProcess(nRec)
LOCAL oMsg:= NewMessage(),  aFare
LOCAL nDay, nTime, nTotTime, nKm
LOCAL oLoc[6], oOut[3], oCharge[CHARGESIZE]

aFare  := FareRead (sFares,RTRIM(aTrpSheet:mTypeId))

nDay     := aTrpSheet:mEndDt - aTrpSheet:mStartDt
nTotTime := Time2Val(aTrpSheet:mStartTm,aTrpSheet:mEndTm,nDay)
nKm      := aTrpSheet:mEndKm - aTrpSheet:mStartKm

oCharge:zTime := nTotTime // here is the total time calculated
oCharge:zDays := nDay+1   // here is the total CALENDAR days

DO CASE
 CASE nType ==1
   oLoc:=LocFare(nTotTime, aFare)
   
   oCharge:zStatus := 'F'
   oCharge:zHire   := oLoc:lBasic
   oCharge:zMin    := 0
   oCharge:zHalt   := 0
     
   nKm -= oLoc:lFreeKm // find extra kms
   If nKm > 0
      oCharge:zExtra := nKm * oLoc:lKmRate
   Else
      nKm := 0 ; oCharge:zExtra := 0
   Endif
 CASE nType ==3  
   oLoc:=LocFare(nTotTime, aFare) 

   oCharge:zStatus  := 'S'
   oCharge:zHire    := oLoc:hBasic
   oCharge:zHalt    := 0
   
   IF oLoc:hFuelKm >= nKm
       oCharge:zMin := nKm * oLoc:hKmFuel
       oCharge:zExtra := 0
   ELSE 
       oCharge:zMin   := oLoc:hFuelKm * oLoc:hKmFuel    
       oCharge:zExtra := (nKm - oLoc:hFuelKm) * oLoc:lKmRate
   ENDIF
   // zMin   HERE MEANS THE NORMAL KM FUEL COST
   // zHire  MEANS THE BASIC HIRING CHARGES
   // zExtra MEANS THE EXTRA KM CHARGES
 CASE nType ==2  
   oOut:=OutFare(aFare)
   oCharge:zStatus := 'O'
   oCharge:zHalt  := nDay * oOut:oHalt   
   oCharge:zHire  := 0
   
   nDay++   //  SAME DAY ALSO GETS ADDED
   If nKm > (oOut:oMinKm * nDay)
      oCharge:zExtra := (nKm-(oOut:oMinKm*nDay)) * oOut:oKmRate
      oCharge:zMin   := (oOut:oMinKm*nDay) * oOut:oKmRate
   ELSE
      oCharge:zMin   := (oOut:oMinKm*nDay) * oOut:oKmRate
      oCharge:zExtra := 0
   ENDIF
ENDCASE

DBSELECTAR("TRPSHEET")
DBGOTO(nRec)
RETURN oCharge

//****************************************************************
STATIC FUNCTION LocFare (nTotTime,aFare)

LOCAL aLoc:=aFare[1],   aExt:=aFare[2],   aGen:= aFare[3]
LOCAL iLoc:=aFare[5,1]-1, iExt:=aFare[5,2]-1, iGen:= aFare[5,3]-1

LOCAL nRate,nFreeKm,nPerKm,nHireRate,nHireKm, nKmRate, nKmFuel
LOCAL nX,nY
LOCAL nTimes, nMod := 0
IF nTotTime <= aLoc[iLoc]:Hrs
   nX:=1
   DO WHILE nTotTime <> aLoc[nX]:Hrs
      nX++
   ENDDO
   nRate     := aLoc[nX]:Rate
   nFreeKm   := aLoc[nX]:FreeKm
   nHireRate := aLoc[nX]:HireRate
   nHireKm   := aLoc[nX]:HireKm
ELSE
   nTimes := INT(nTotTime/aLoc[iLoc]:Hrs) 
   nMod   := nTotTime % aLoc[iLoc]:Hrs

   nRate     := (nTimes * aLoc[iLoc]:Rate     )
   nFreeKm   := (nTimes * aLoc[iLoc]:FreeKm   )
   nHireRate := (nTimes * aLoc[iLoc]:HireRate )
   nHireKm   := (nTimes * aLoc[iLoc]:HireKm   )
   

   IF nMod > 0
      nY:=1
      DO WHILE nMod <> aExt[nY]:Hrs
         nY++
      ENDDO
      nRate     += aExt[nY]:Rate
      nFreeKm   += aExt[nY]:FreeKm       
      nHireRate += aExt[nY]:HireRate 
      nHireKm   += aExt[nY]:HireKm
   ENDIF
ENDIF

nKmFuel := aGen:gFuelRate
nKmRate := aGen:gRateKm 

RETURN {nRate,nFreeKm,nKmRate,nHireRate,nHireKm,nKmFuel}


//*******************************************************************
STATIC FUNCTION OutFare (aFare)
LOCAL aOut:=aFare[4]
RETURN {aOut:oRateKm,aOut:oMinKm,aOut:oNightHalt}

/*
**********************************************************************
*  This functions initializes the memory array used for GET editing. *
*       It does this by skipping to EOF and reading the fields       *
*   Then takes the form to EDIT mode                                 *
**********************************************************************
*/
STATIC FUNCTION InsertTrip ()
DBSELECTAR("TRPSHEET")
DBGOBOTTOM()
DbSkip(+1)
StabilizeTrip()
aTrpSheet:mTrpDate := Date()
aTrpSheet:mStartDt := Date()
aTrpSheet:mEndDt   := Date()

DBSELECTAR("BILLING")
IF EOF()
  aTrpSheet:mBillNum := 1
ELSE
  DBGOBOTTOM()
  aTrpSheet:mBillNum := BILLING->BillNum + 1
ENDIF

DBSELECTAR("TRPSHEET")
Say_GetTrip ("Insert")
RETURN NIL

/*
*******************************************************************
* This function displays the warning when the user tries to       *
*      delete a TripSheet.                                        *
*******************************************************************
*/

STATIC FUNCTION DeleteTrip ()
LOCAL oMessage:=NewMessage()
TopStatus ("DELETE MODE")
oMessage:MsgTitle := "- Deleting a Trip"
oMessage:MsgText  := { 'You cannot delete an entry in ',;
                       'the Trip Sheet Master file.'}
Apply oMessage:MsgShow(oMessage)
RETURN NIL

/*
****************************************************************
*This function write the current Trip Sheet Master record      * 
being edited into the DBF file TrpSheet.                       * 
****************************************************************
*/
STATIC FUNCTION WriteTrip (nRec)
LOCAL oTail:=NewTail()

DBSELECTAR("TrpSheet")
DBGOTO (nRec)
TrpSheet->TRPNUM     := aTrpSheet:mTrpNum   
TrpSheet->TRPDATE    := aTrpSheet:mTrpDate  
TrpSheet->REGNUM     := aTrpSheet:mRegNum   
TrpSheet->STARTKM    := aTrpSheet:mStartKm  
TrpSheet->ENDKM      := aTrpSheet:mEndKm    
TrpSheet->STARTDT    := aTrpSheet:mStartDt  
TrpSheet->ENDDT      := aTrpSheet:mEndDt    
TrpSheet->STARTTM    := aTrpSheet:mStartTm  
TrpSheet->ENDTM      := aTrpSheet:mEndTm    
TrpSheet->DRIVER     := aTrpSheet:mDriver   
TrpSheet->CLIENTID   := aTrpSheet:mClientId 
TrpSheet->ISBILLED   := aTrpSheet:mIsBilled 
TrpSheet->BILLNUM    := aTrpSheet:mBillNum  
TrpSheet->TAGGED     := aTrpSheet:mTagged
TrpSheet->TYPEID     := aTrpSheet:mTypeId
TrpSheet->CLIENTNAME := aTrpSheet:mClientName
TrpSheet->PERMIT     := aTrpSheet:mPermit
TrpSheet->MISC       := aTrpSheet:mMisc  
RETURN NIL

/*
*********************************************************
* This function accepts a Trpsheet Number and positions *
* the screen to that book                               *
*********************************************************
*/
STATIC FUNCTION ChooseTrip ()
LOCAL R:=7, C:=4, GetList := {}, rRec := RECNO()
LOCAL oMsg:=NewMessage()

    DBGOBOTTOM()
    DBSKIP(+1)
    StabilizeTrip()
    Say_GetTrip("View")
    TopStatus ("SELECT MODE")

SETCURSOR(3)
@ R-1,   C+15  GET aTrpSheet:mTrpNum PICTURE "999999"
READMODAL (GetList)

IF !DBSEEK(aTrpSheet:mTrpNum) 
    oMsg:MsgTitle := "- Trip Sheet not found!"
    oMsg:MsgText  := {"The number you typed doesnot have any trip sheet",;
                      "associated to it. Try again with the correct no.",;
                      " & press the select key again."}   
    Apply oMsg:MsgShow(oMsg)
    DBGOTO (rRec)
ENDIF

RETURN NIL

/*
*****************************************************************
*   this function prints the trip information                   *
*****************************************************************
*/
STATIC FUNCTION PrintTrip ()
LOCAL oMessage:=NewMessage()
LOCAL nChoice,rRec := RECNO(), nPage := 1
TopStatus ("PRINT MODE")

oMessage:MsgTitle   := "- Printing a Trip Sheet"
oMessage:MsgText    := { "You have choosed to print Confirmation Order",;
                         "Please select your choice: "}
oMessage:MsgDefault := 1                         
oMessage:MsgButtons := {"This Trip", "Only Tagged Trips","All Trips","Cancel"}
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
       DBEVAL ({||IIF(TrpSheet->Tagged,;
           PrintControl(nPage++),.F.)})
    ELSE 
       DBEVAL ({||PrintControl(nPage++)})
    ENDIF    
    PrintOff()
    oMessage:MsgTitle   := "- FINISHED PRINTING !"   
    oMessage:MsgText    := { "The Computer has finished sending the data.",;
                             "You can continue with your work."}
    oMessage:MsgButtons := {"Ok"}
    Apply oMessage:MsgShow(oMessage)
ENDIF
DBGOTO (rRec)
RETURN NIL


//*********************************************************************
STATIC FUNCTION PRINTCONTROL(nPage)
LOCAL nRow   := 1

IF nPage<>1
  EJECT
ENDIF  
nRow := Header(nRow)
nRow := FullDetails(nRow)
nRow := Footer(nRow)
// 24 alert(str(pr))
RETURN Nil

//*********************************************************************
STATIC FUNCTION FullDetails(pR)
LOCAL nAmt:=0
    @ pR,   01 SAY "Con. No.: "
    @ pR,   10 SAY TrpSheet->TrpNum
    @ pR,   41 SAY "Date : " 
    @ pR,   50 SAY  DTOC (TrpSheet->TrpDate) 

    @ ++pR, 01 SAY  "Driver : " + TrpSheet->Driver
    @ pR,   41 SAY  "Car No : " + TrpSheet->RegNum

    @ ++pR, 01 SAY "Veh.Type : " + TrpSheet->TypeId 
    @ pR,   20 SAY "Engaged By: " + TrpSheet->ClientName
    
    pR++

    @ ++pR, 01 SAY "Closing Km    : " + STR(TrpSheet->EndKm) 
    @ pR,   41 SAY "Closing Time  : " + TrpSheet->EndTm
                                                           
    @ ++pR, 01 SAY "Start Km      : " + STR(TrpSheet->StartKm)
    @ pR,   41 SAY "Start Time    : " + TrpSheet->StartTm 

                                                           
    @ ++pR, 01 SAY "Closing Date  : " + DTOC(TrpSheet->EndDt)  
    @ pR,   41 SAY "Starting Date : " + DTOC(TrpSheet->StartDt)
    pR++

    @ pR, 01 SAY "Total Kms     : "
    @ pR,   15 SAY TrpSheet->Endkm - TrpSheet->StartKm
    DO CASE
       CASE TrpSheet->Status == 'F'   // LOCAL
          @ pR, 41 SAY "Total Hours :"
          @ pR,   55 SAY TrpSheet->Time  
          pR++
          
          @ ++pR, 01 SAY "Hiring Charges  (Rs.):"
          @ pR,   22 SAY TrpSheet->Hiring  PICTURE "99999999.99"
          @ ++pR, 01 SAY "Ext. Km Charges (Rs.):"
          @ pR,   22 SAY TrpSheet->Extra   PICTURE "99999999.99"
          pR+=2
       CASE TrpSheet->Status == 'S'  // HIRE
          @ pR, 41 SAY "Total Hours :"
          @ pR,   55 SAY TrpSheet->Time
          pR++
          
          @ ++pR, 01 SAY "Hiring Charges  (Rs.):"
          @ pR,   22 SAY TrpSheet->Hiring   PICTURE "99999999.99"
          @ ++pR, 01 SAY "Fuel Cost       (Rs.):"
          @ pR,   22 SAY TrpSheet->Minimum  PICTURE "99999999.99"
          @ ++pR, 01 SAY "Ext. Km Charges (Rs.):"
          @ pR,   22 SAY TrpSheet->Extra    PICTURE "99999999.99"
          pR++
       OTHERWISE                     // OUTSTATION
           // 4 Lines
          @ pR,   41 SAY "Total Days:"
          @ pR,   50 SAY TrpSheet->Days
          pR++
          
          @ ++pR, 01 SAY "Charge          (Rs.):" 
          @ pR,   22 SAY TrpSheet->Minimum + TrpSheet->Extra PICTURE "99999999.99"
          @ ++pR, 01 SAY "Night Halt      (Rs.):"
          @ pR,   22 SAY TrpSheet->Halt   PICTURE "99999999.99"
          @ ++pR, 01 SAY "Permit          (Rs.):"
          @ pR,   22 SAY TrpSheet->Permit PICTURE "99999999.99"
          nAmt := TrpSheet->Permit + TrpSheet->Halt
    ENDCASE
    

          @ ++pR, 01 SAY "Misc. Expenses  (Rs.):"
          @ pR,   22 SAY TrpSheet->Misc   PICTURE "99999999.99"
          
          nAmt += TrpSheet->Hiring  + TrpSheet->Extra
          nAmt += TrpSheet->Minimum + TrpSheet->Misc
          
          @ ++pR, 23 SAY "============"
          @ ++pR, 01 SAY "Total Amount    (Rs.):"
          @ pR,   22 SAY nAmt  PICTURE "99999999.99"
          @ ++pR, 23 SAY "============"
RETURN pR++

//*********************************************************************
STATIC FUNCTION Footer(pR)
    @ pR,01 SAY REPL('_',70)
    @ ++pR,02 SAY DATE() 
    @ pR,  60 SAY TIME()
RETURN pR

//********************************************************************
STATIC FUNCTION Header (pR)
LOCAL sHead := MEMOREAD (HEADFILE), nX:=0        
    DO WHILE nX <= 5
       @ pR++, 1 SAY MEMOLINE(sHead, 70, nX++)
    ENDDO   
    @ pR++, 26 SAY "CONFIRMATORY ORDER"
    @ pR,   26 SAY "=================="
RETURN ++pR

//*********************************************************************
STATIC FUNCTION SuperVehicle (oGet,nR,nC,HOMEAREA)
LOCAL nT
    DBSELECTAR("VEHTYPE")
    
    IF EMPTY(oGet:Buffer)
       RETURN .F.
    ENDIF   
   
    nT := DBSEEK (oGet:Buffer) 
    
    IF nT == .F.
      ALERT ("The data you typed is not Valid")
    ELSE
      @ nR,nC SAY SUBSTR(VEHTYPE->TYPEDESC,1,30)
    ENDIF  
    DBSELECTAR(HOMEAREA)
RETURN nT     

//***********************************************************************
STATIC FUNCTION SuperClient (oGet,nR,nC,HOMEAREA)
LOCAL nT, GetList := {}

    IF SUBSTR(oGet:Buffer,1,4) == "MISC"
       @ nR,nC GET aTrpSheet:mClientName
       READMODAL (GetList)
       sFares := MemoRead (FARESFILE)
       RETURN .T.
    ENDIF
    
    DBSELECTAR("CLIENT")
    
    IF EMPTY(oGet:Buffer)
       RETURN .F.
    ENDIF   
   
    nT := DBSEEK (oGet:Buffer) 
    
    IF nT == .F.
      ALERT ("The data you typed is not Valid")
    ELSE
      @ nR,nC SAY SUBSTR(CLIENT->CLIENTNAME,1,35)
      aTrpSheet:mClientName := SUBSTR(CLIENT->CLIENTNAME,1,35)
      sFares :=CLIENT->FARE
    ENDIF  
    DBSELECTAR(HOMEAREA)
RETURN nT     

//**************************************************************************
FUNCTION CheckTime(oGet)
 IF VAL(SUBSTR(oGet:Buffer,1,2))==24 .AND. VAL(SUBSTR(oGet:Buffer,4,2))>0
    RETURN .F.
 ENDIF
 IF VAL(SUBSTR(oGet:Buffer,1,2))<=24 .AND. VAL(SUBSTR(oGet:Buffer,4,2))<=60
    RETURN .T.
 ENDIF      
RETURN .F.

//*************************************************************************
FUNCTION Messager(cString)
ALERT (cString)
RETURN .F.


//**************************************************************************
STATIC FUNCTION Biller(nNum,nDate,nClientId,nAmt,nMode)
DBSELECTAR("BILLING")
    IF nMode=="Insert"     
       DBAPPEND()
    ELSE
       If DBSEEK(nNum) == .F.
          Alert("The Bill Number doesnot match in Accounts Register")
       Endif
    ENDIF
    BILLING->BillNum    := nNum
    BILLING->BillDate   := nDate
    BILLING->ClientId   := nClientId
    BILLING->BillAmt    := nAmt
    BILLING->TrpNum     := aTrpSheet:mTrpNum

    TRPSHEET->BillNum   := nNum
    TRPSHEET->BillDate  := nDate

            OpenDatabase  ("ACCOUNTS")
                IF nMode=="Insert"     
                   DBAPPEND()
                ELSE
                   Set Index to Accounts
                   Set Order to "Number"
                   If DBSEEK(nNum) == .F.
                      Alert("The Bill Number doesnot match in Accounts Register")
                   Endif
                ENDIF
                    ACCOUNTS->ClientId  := nClientId
                    ACCOUNTS->Date      := nDate
                    ACCOUNTS->Desc      := "BILL"
                    ACCOUNTS->Num       := nNum
                    ACCOUNTS->Bill      := nAmt
            CloseDatabase ("ACCOUNTS")
DBCOMMITALL()

DBSELECTAR("TRPSHEET")
TRPSHEET->IsBilled  := .T.

RETURN NIL


//************************************************************


STATIC FUNCTION BillChk(cBill)
LOCAL Res
DBSELECTAR("BILLING")
Res := DBSEEK(VAL(cBill))
DBSELECTAR("TRPSHEET")
RETURN !Res
