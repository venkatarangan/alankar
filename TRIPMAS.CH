/*
* INCLUDE...........: TRIPMAS.CH
* PRG...............: TRIPMAS.PRG
* DESC..............: Implements basic Trip master informations
* EXPORTS...........: Nil
* STATIC FUNCTIONS..: StabilizeTrip(), Say_GetTrip(), InsertTrip(),
*                     DeleteTrip(), PrintTrip(), WriteTrip(), OpenTrip(),
*                     
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
* AUTHOR............: venkata rangan, tnc & Madhu, S.
* DATE..............: 25/04/1995
* PROJECT...........: Alankar's Billing program.
*
* COMPILER..........: CA-Clipper 5.2
* SWITCHES..........: /n /w /m
*/
  
  
  
  
#xtranslate :mTrpNum   =>  \[1\]
#xtranslate :mTrpDate  =>  \[2\]
#xtranslate :mRegNum   =>  \[3\]
#xtranslate :mTypeId   =>  \[4\]
#xtranslate :mStartKm  =>  \[5\]
#xtranslate :mEndKm    =>  \[6\]
#xtranslate :mStartDt  =>  \[7\]
#xtranslate :mEndDt    =>  \[8\]
#xtranslate :mStartTm  =>  \[9\]
#xtranslate :mEndTm    =>  \[10\]
#xtranslate :mDriver     =>  \[11\]
#xtranslate :mClientName =>  \[12\]
#xtranslate :mClientId =>  \[13\]
#xtranslate :mIsBilled =>  \[14\]
#xtranslate :mBillNum  =>  \[15\]
#xtranslate :mBillDate =>  \[16\]
#xtranslate :mTagged   =>  \[17\]
#xtranslate :mPermit   =>  \[18\]
#xtranslate :mMisc     =>  \[19\]
#xtranslate :mStatus   =>  \[20\]

#define TMAS_SIZE 20
  
#xtranslate :lBasic  => \[1\]
#xtranslate :lFreeKm => \[2\]
#xtranslate :lKmRate => \[3\]

#xtranslate :hBasic   => \[4\]
#xtranslate :hFuelKm  => \[5\]
#xtranslate :hKmFuel  => \[6\]

#xtranslate :oKmRate  => \[1\]
#xtranslate :oMinKm   => \[2\]
#xtranslate :oHalt    => \[3\]


#xtranslate :zStatus =>  \[1\]
#xtranslate :zHire   =>  \[2\]
#xtranslate :zExtra  =>  \[3\]
#xtranslate :zHalt   =>  \[4\]
#xtranslate :zMin    =>  \[5\]
#xtranslate :zTime   =>  \[6\]
#xtranslate :zDays   =>  \[7\]

#define CHARGESIZE   7
                     
