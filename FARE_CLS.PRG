#include "fare_cls.ch"

STATIC aLoc[SLABSIZE,LOCSIZE], aExt[SLABSIZE,EXTSIZE]
STATIC aGen[GENSIZE], aOut[OUTSIZE]
STATIC iLoc,iGen,iExt,iOut

FUNCTION FareRead(mFare, VehType)
LOCAL nTotal, sLine, nRow, sChar, nSec, nTemp 
VehType:= upper(VehType)
nTotal := MLCOUNT (mFare)
nSec := nRow := 0
// Initialize
iLoc:= iGen := iExt := iOut := 1

DO WHILE nRow <= nTotal
   sLine := UPPER(MEMOLINE (mFare,70,nRow))
   sChar := SUBSTR(sLine,1,1)
   DO CASE
      CASE  sChar == '{'  .OR. sChar == SPACE(1)
           // no Job for Us                  
      CASE sChar == '['
           DO CASE
              CASE "LOCAL" $ sLine
                  nSEC := XLOC
              CASE "EXTRA" $ sLine
                 nSEC := XEXT
              CASE "GENERAL" $ sLine
                 nSEC := XGEN
              CASE "OUTSTATION" $ sLine
                 nSEC := XOUT
           ENDCASE  
      OTHERWISE 
        nTemp := AT ('-',sLine)
        IF UPPER(SUBST(sLine,1,nTemp-1)) == VehType
         DO CASE
            CASE nSEC == XLOC
                 //? "Local " + sLine
                 vLoc(SUBSTR(sLine,nTemp+1,70))
            CASE nSEC == XEXT
                //? "Extra " + sLine 
                vExt(SUBSTR(sLine,nTemp+1,70))
            CASE nSEC == XGEN
                //? "General " + sLine
                vGen(SUBSTR(sLine,nTemp+1,70))
            CASE nSEC == XOUT
               //? "Out " + sLine 
               vOut(SUBSTR(sLine,nTemp+1,70))
         ENDCASE
       ENDIF 
   ENDCASE 
   nRow++
ENDDO

RETURN {aLoc,aExt,aGen,aOut, {iLoc,iExt,iGen,iOut}}



FUNCTION vLoc(sLine)
LOCAL nTemp

SET DECIMALS TO 0
nTemp := AT('-',sLine)
aLoc[iLoc]:Hrs       := VAL(SUBSTR(sLine,1,nTemp-1))
sLine := SUBSTR(sLine,nTemp+1,70)

SET DECIMALS TO 2
nTemp := AT('-',sLine)
aLoc[iLoc]:Rate      := VAL(SUBSTR(sLine,1,nTemp-1))
sLine := SUBSTR(sLine,nTemp+1,70)


SET DECIMALS TO 0
nTemp := AT('-',sLine)
aLoc[iLoc]:FreeKm    := VAL(SUBSTR(sLine,1,nTemp-1))
sLine := SUBSTR(sLine,nTemp+1,70)

SET DECIMALS TO 2
nTemp := AT('-',sLine)
aLoc[iLoc]:HireRate   := VAL(SUBSTR(sLine,1,nTemp-1))
sLine := SUBSTR(sLine,nTemp+1,70)

SET DECIMALS TO 0
nTemp := 70
aLoc[iLoc]:HireKm     := VAL(SUBSTR(sLine,1,nTemp-1))

iLoc++
RETURN NIL

//----------------------------------------------------------
FUNCTION vExt(sLine)
LOCAL nTemp

SET DECIMALS TO 0
nTemp := AT('-',sLine)
aExt[iExt]:Hrs       := VAL(SUBSTR(sLine,1,nTemp-1))
sLine := SUBSTR(sLine,nTemp+1,70)

SET DECIMALS TO 2
nTemp := AT('-',sLine)
aExt[iExt]:Rate      := VAL(SUBSTR(sLine,1,nTemp-1))
sLine := SUBSTR(sLine,nTemp+1,70)

SET DECIMALS TO 0
nTemp := AT('-',sLine)
aExt[iExt]:FreeKm    := VAL(SUBSTR(sLine,1,nTemp-1))
sLine := SUBSTR(sLine,nTemp+1,70)

SET DECIMALS TO 2
nTemp := AT('-',sLine)
aExt[iExt]:HireRate    := VAL(SUBSTR(sLine,1,nTemp-1))
sLine := SUBSTR(sLine,nTemp+1,70)

SET DECIMALS TO 0
nTemp := 70
aExt[iExt]:HireKm     := VAL(SUBSTR(sLine,1,nTemp-1))

iExt++
RETURN NIL

//----------------------------------------------------------
FUNCTION vGen(sLine)
LOCAL nTemp

SET DECIMALS TO 2
nTemp := AT('-',sLine)
aGen:gFuelRate       := VAL(SUBSTR(sLine,1,nTemp-1))
sLine := SUBSTR(sLine,nTemp+1,70)

nTemp := 70
aGen:gRateKm     := VAL(SUBSTR(sLine,1,nTemp-1))
SET DECIMALS TO 0
RETURN NIL
        
//----------------------------------------------------------
FUNCTION vOut(sLine)
LOCAL nTemp

SET DECIMALS TO 0
nTemp := AT('-',sLine)
aOut:oRateKm       := VAL(SUBSTR(sLine,1,nTemp-1))
sLine := SUBSTR(sLine,nTemp+1,70)

SET DECIMALS TO 0
nTemp := AT('-',sLine)
aOut:oMinKm      := VAL(SUBSTR(sLine,1,nTemp-1))
sLine := SUBSTR(sLine,nTemp+1,70)

SET DECIMALS TO 2
nTemp := 70
aOut:oNightHalt     := VAL(SUBSTR(sLine,1,nTemp-1))

SET DECIMALS TO 0
RETURN NIL

