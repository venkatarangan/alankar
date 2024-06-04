/*
* PRG...............: SYS_CLS.PRG
* INCLUDE...........: SYS_CLS.CH
* CLASS.............: Implements several system dependent functions.
* DESC..............: This is a collection of system functions for 
*                                         this project.
* EXPORTS...........: OpenDatabase(), CloseDataBase(), PresenceChk(),
*                                         TopStatus().
*                                         
* CONSTRUCTOR.......: Nil
* METHODS...........: Nil.
* STATIC FUNCTIONS..: ShowMeter(), ErrorCheck(), IndexManager(),
*                                         CreateDatabase().
*
* USES..............: Standard Clipper Functions
*                     Stack Class - STK_CLS.PRG.
*                     Message Class - MSG_CLS.PRG.
*       
* NOTES.............: 
*
* AUTHOR............: venkata rangan, tnc & Madhu,S.
* DATE..............: 03/06/1995.
* PROJECT...........: Alankar Travels Billing Program.
*
* COMPILER..........: CA-Clipper 5.2
* SWITCHES..........: /n /w /m
*/

#include "Clr_Cls.Ch"
#include "MSG_CLS.Ch"
#include "Apply.Ch"
#include "Inkey.Ch"
#include "Box.Ch"
#include "Shad_Cls.Ch"
#include "Sys_Cls.Ch"

STATIC bOldError

STATIC PROCEDURE CreateDatabase (cName)
DO CASE
CASE cName == "VEHTYPE"
         DBCREATE (cName+FILEEXT,                               ;
                     {                                          ;
                        {"TypeId",     "C",    05,     0},      ;
                        {"TypeDesc",   "C",    50,     0},      ;
                        {"Tagged",     "L",     1,     0}       ;
                     } )

CASE cName == "VEHICLE"
         DBCREATE (cName+FILEEXT,                               ;
                     {                                          ;
                        {"RegNum",     "C",    10,     0},      ;
                        {"TypeId",     "C",    05,     0},      ;
                        {"IsAC",       "L",     1,     0},       ;
                        {"Tagged",     "L",     1,     0}/*vr*/ ;   
                     } )

CASE cName == "TRPSHEET"
         DBCREATE (cName+FILEEXT,                               ;
                     {                                          ;
                        {"TrpNum",     "N",    06,     0},      ;
                        {"ClientName", "C",    35,     0},      ;
                        {"TrpDate",    "D",    08,     0},      ;
                        {"RegNum",     "C",    14,     0},      ;
                        {"StartKm",    "N",     8,     0},      ;
                        {"EndKm",      "N",     8,     0},      ;
                        {"TypeId",     "C",    05,     0},      ;                        
                        {"StartDt",    "D",     8,     0},      ;
                        {"EndDt",      "D",     8,     0},      ;
                        {"StartTm",    "C",     5,     0},      ;
                        {"EndTm",      "C",     5,     0},      ;
                        {"Driver",     "C",    25,     0},      ;
                        {"ClientId",   "C",    10,     0},      ;
                        {"IsBilled",   "L",     1,     0},      ;
                        {"BillNum",    "N",    06,     0},      ;
                        {"BillDate",   "D",     8,     0},      ;
                        {"Status",     "C",    1,      0},      ;
                        {"Hiring",     "N",    10,     2},      ;
                        {"Extra",      "N",    10,     2},      ;
                        {"Halt",       "N",    10,     2},      ;
                        {"Minimum",    "N",    10,     2},      ;
                        {"Time",       "N",    4,      0},      ;
                        {"Days",       "N",    4,      0},      ;
                        {"Permit",     "N",    10,     2},      ;
                        {"Misc",       "N",    10,     2},      ;
                        {"Tagged",     "L",     1,     0}/*vr*/ ;   
                     } )

CASE cName == "BILLING"
         DBCREATE (cName+FILEEXT,                               ;
                     {                                          ;
                        {"BillNum",    "N",    06,     0},      ;
                        {"BillDate",   "D",     8,     0},      ;
                        {"ClientId",   "C",    10,     0},      ;
                        {"BillImg",    "M",    10,     0},      ;
                        {"TrpNum",     "N",    06,     0},      ;
                        {"Printed",    "L",     1,     0},      ;
                        {"Cancelled",  "L",     1,     0},      ;
                        {"BillAmt",    "N",    10,     2},      ;
                        {"Tagged",     "L",     1,     0}/*vr*/ ;   
                     } )

CASE cName == "CLIENT"
         DBCREATE (cName+FILEEXT,                               ;
                     {                                          ;
                        {"ClientId",   "C",    10,     0},      ;
                        {"ClientName", "C",    40,     0},      ;
                        {"Address1",   "C",    35,     0},      ;
                        {"Address2",   "C",    30,     0},      ;                        
                        {"Address3",   "C",    25,     0},      ;
                        {"Place",      "C",    20,     0},      ;
                        {"City",       "C",    15,     0},      ;
                        {"PinCode",    "N",    6,     0},      ;
                        {"Phone",      "C",    25,     0},      ;
                        {"Fax",        "C",    25,     0},      ;
                        {"Fare",       "M",    10,     0},      ;
                        {"IsSplit",    "C",     1,     0},      ; 
                        {"Tagged",     "L",     1,     0}/*vr*/ ;   
                     } )

CASE cName == "BOOKING"
         DBCREATE (cName+FILEEXT,                               ;
                     {                                          ;
                        {"BookDate",   "D",     8,     0},      ;
                        {"TodayDate",  "D",     8,     0},      ;
                        {"Ref",        "C",     15,    0},      ;
                        {"Time",       "C",     5,    0},      ;
                        {"TypeId",     "C",     5,     0},      ;
                        {"ClientId",   "C",    10,     0},      ;
                        {"Info1",      "C",    50,     0},      ;
                        {"Info2",      "C",    50,     0},      ;
                        {"Info3",      "C",    50,     0},      ;
                        {"Info4",      "C",    50,     0},      ;
                        {"Tagged",     "L",     1,     0}/*vr*/ ;
                     } )
CASE cName == "ACCOUNTS"
         DBCREATE (cName+FILEEXT,                               ;
                     {                                          ;
                        {"Desc",       "C",    15,     0},      ;
                        {"Num",        "N",    15,     0},      ;
                        {"Date",       "D",     8,     0},      ;
                        {"ClientId",   "C",    10,     0},      ;
                        {"Recd",       "N",    12,     2},      ;
                        {"Bill",       "N",    12,     2},      ;                        
                        {"Tagged",     "L",     1,     0}/*vr*/ ;
                     } )
CASE cName == "ADDRESS"
         DBCREATE (cName+FILEEXT,                               ;
                     {                                          ;
                        {"ClientId",   "C",    10,     0},      ;
                        {"Dept",       "C",    15,     0},      ;
                        {"Desc",       "C",    10,     0},      ;
                        {"Name",       "C",    40,     0},      ;
                        {"Address1",   "C",    35,     0},      ;
                        {"Address2",   "C",    30,     0},      ;                        
                        {"Address3",   "C",    25,     0},      ;
                        {"Place",      "C",    20,     0},      ;
                        {"City",       "C",    15,     0},      ;
                        {"PinCode",    "N",    06,     0},      ;
                        {"Phone",      "C",    25,     0},      ;
                        {"Fax",        "C",    25,     0},      ;
                        {"Tagged",     "L",     1,     0}/*vr*/ ;   
                     } )
                                         
ENDCASE
RETURN 

PROCEDURE OpenDataBase (cName)
LOCAL oMsg := NewMessage()
LOCAL nWorkArea := 0
        bOldError := ERRORBLOCK ( {|e| ErrorCheck(e) } )
        cName := UPPER(cName)
        nWorkArea := Select(cName)
        If nWorkArea > 0
            dbSelectAr(nWorkArea)
            ErrorBlock (bOldError)  
            Return
        Endif
        IF .NOT. FILE (cName+FILEEXT)
           oMsg:MsgTitle := "- Database Not Found ?"
           oMsg:MsgText  := {cName+FILEEXT+" is not found",;
                             "I am Creating a new file of this name"}
           APPLY oMsg:MsgShow(oMsg)      
           CreateDataBase (cName)
           IF FILE (cName+ORDBAGEXT())
                 FERASE (cName+ORDBAGEXT())
           ENDIF        
        ENDIF
        SELECT 0
        USE (cName+FILEEXT) ALIAS (cName)
        IndexManager (cName)
        ErrorBlock (bOldError)  
RETURN

PROCEDURE CloseDataBase (cName)
        DBSELECTAREA (cName)
        DBCLOSEAREA ()
RETURN

FUNCTION UserName ()
RETURN "Operator"


//**************************************************
STATIC PROCEDURE IndexManager(cName)
LOCAL cScreen, nRecCount, cColor
LOCAL kMeterSave := { ||cScreen := SAVESCREEN(24,0,24,30),;
                       nRecCount := LASTREC(), cColor := SETCOLOR("W/N+")}   
LOCAL kMeterRest := { ||RESTSCREEN (24,0,24,30,cScreen), SETCOLOR (cColor)}
EVAL (kMeterSave) 

DO CASE
CASE cName == "VEHTYPE" 
         IF .NOT. FILE (cName+ORDBAGEXT())
            INDEX ON VehType->TypeId TAG "TypeId" TO VehType ;
                     EVAL {||ShowMeter(nRecCount)} EVERY 100
         ENDIF  
         SET INDEX TO VehType
         SET ORDER TO "TypeId"

CASE cName == "VEHICLE"
        If !File(cName + OrdBagExt())   
                Index On Vehicle->RegNum TAG "RegNum" To Vehicle ;
                            Eval {||ShowMeter(nRecCount)} EVERY 100
               
        Endif
        SET INDEX TO Vehicle
        SET ORDER TO "RegNum"

CASE cName == "TRPSHEET"
        If !File(cName + OrdBagExt())
                Index on TrpSheet->TrpNum TAG "TripNum" To TrpSheet ;
                       Eval {||ShowMeter(nRecCount)} EVERY 100 /* VR */
        Endif
        Set Index to TrpSheet
        Set Order to "TripNum" /* VR */

Case cName == "BILLING"
        If !File(cName+OrdBagExt())
                Index on Billing->BillNum TAG "Bill" to Billing ;
                            Eval {||ShowMeter(nReccount)} EVERY 100
        Endif
        Set Index to Billing
        Set Order to "Bill"

Case cName == "CLIENT"
        If !File(cName+OrdBagExt())
                Index on Client->ClientId TAG "Client" To Client ;
                            Eval {||ShowMeter(nReccount)} EVERY 100
        Endif
        Set Index to Client
        Set Order to "Client"
Case cName == "BOOKING"
        If !File(cName+OrdBagExt())
                Index on Booking->BookDate TAG "BookDate" To Booking;
                      Eval {||ShowMeter(nReccount)} EVERY 10
        Endif
        Set Index to Booking
        Set Order to "BookDate"
Case cName == "ACCOUNTS"
        If !File(cName+OrdBagExt())
                Index on Accounts->ClientId TAG "ClientId" To Accounts;
                      Eval {||ShowMeter(nReccount)} EVERY 10
                Index on Accounts->Num TAG "Number" To Accounts;
                      Eval {||ShowMeter(nReccount)} EVERY 10

        Endif
        Set Index to Accounts
        Set Order to "ClientId"
Case cName == "ADDRESS"
        If !File(cName+OrdBagExt())
                Index on Address->ClientId + Address->Name TAG "AddName" To Address ;
                            Eval {||ShowMeter(nReccount)} EVERY 100
        Endif
        Set Index to Address
        Set Order to "AddName"
        
ENDCASE
EVAL (kMeterRest)
RETURN 

FUNCTION PresenceChk (oGet,xPresent)
IF EMPTY(oGet:Buffer)
   RETURN .F.
ELSE
  IF VALTYPE(xPresent) == 'C'  
      IF (xPresent == oGet:Buffer)
         RETURN .T.
      ENDIF
      DBSEEK (oGet:Buffer)
  ELSE 
      IF (xPresent == VAL(oGet:Buffer))
         RETURN .T.
      ENDIF
      DBSEEK (VAL(oGet:Buffer))
  ENDIF      
ENDIF
RETURN !FOUND()

STATIC FUNCTION ErrorCheck(e)
LOCAL cBasic
IF (VALTYPE(e:subsystem) == "C" ) .AND. ( VALTYPE(e:subcode) == "N")
   IF ( e:subsystem == "DBFCDX" .AND. e:subcode == 602)
        cBasic := LEFT(e:filename, AT(".",e:filename)-1)
        FERASE(e:filename)
        ALERT ('Corruption detected in '+e:filename+' I am rebuilding',{'Ok'})
        IndexManager (cBasic)
        RETURN .T.
  ENDIF   
ENDIF           
RETURN Eval(bOldError,e)

STATIC FUNCTION ShowMeter (nRecCount)
@ 24,0 CLEAR TO 24,30
DEVPOS (24,0)
DEVOUT (" Indexing "+STR(RECNO()/nRecCount * 100)+"%")
RETURN .T.

INIT PROCEDURE Customize
SET DATE TO BRIT
SET SCOREBOARD OFF
RETURN

FUNCTION TopStatus(cText)
LOCAL oColor:=NewColor()
@ 1,59,1,78 BOX REPL(" ",9) COLOR oColor:TitleBar
@ 1,60 SAY cText COLOR oColor:TitleBar  
RETURN NIL

Function StuffSave()
KEYBOARD CHR(K_CTRL_W)
Return .T.

FUNCTION SuperCheckIt (oGet,AREA,HOMEAREA)
LOCAL nT
    IF AREA == "CLIENT" .AND. SUBSTR(oGet:Buffer,1,4) == "MISC"
       RETURN .T.
    ENDIF
    DBSELECTAR(AREA)
    
    IF EMPTY(oGet:Buffer)
       RETURN .F.
    ENDIF   
   
    nT := DBSEEK (oGet:Buffer) 
    
    IIF(nT == .F., ALERT ("The data you typed is not Valid"),.T.)
    DBSELECTAR(HOMEAREA)
RETURN nT     

//***************************************************************
FUNCTION TIME2VAL (cTime1, cTime2,nDay)
LOCAL nTime:=0, nA1, nB1, nA2, nB2, nMin1, nMin2

// cMin2  - End Time
// cMin1  - Start Time

nA1 := VAL(SUBSTR(cTime1,1,2))
nB1 := VAL(SUBSTR(cTime1,4,2))
nA2 := VAL(SUBSTR(cTime2,1,2))
nB2 := VAL(SUBSTR(cTime2,4,2))

nMin1 := (nA1*60+nB1)   
nMin2 := (nA2*60+nB2)

// DAY == 0 and Min2 less than Min1 is not possible
IF (nMin2 > nMin1) .AND. nDay == 0
   nTime += nMin2- nMin1
ENDIF
// DAY ==2,3,4,... everything is reduced to DAY = 1
IF nDay > 1 
   nTime += (nDay-1) * 24 * 60 
   nDay := 1
ENDIF

//DAY==1
IF nDay == 1
   IF nMin2 < nMin1
      nTime += ((24*60)-nMin1) + nMin2
   ELSE
      nTime += 24*60
      nTime += nMin2-nMin1
   ENDIF
ENDIF
   
nTime := ROUND (nTime/60,0)

If nTime <= 0  //Saveguard for 0-30Minutes trips
   Alert ("The Hours travelled is less than 1 Hour, Retry.")
Endif   

RETURN nTime

