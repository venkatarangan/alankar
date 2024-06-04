/*
* PRG...............: SHAD_CLS.PRG
* INCLUDE...........: SHAD_CLS.CH
* CLASS.............: Shadow Implementation Class.
* DESC..............: Displays shadows around rectangles.
*
* EXPORTS...........: Nil
* CONSTRUCTOR.......: NewShadow (t,l,b,r)
*
* USES..............: Standard Clipper Fucntions
*				  Clr_Cls.Prg 			
* NOTES.............: The Constructor returns a object, which contains 
*				  array elements as Kill & Show Methods.
* METHOD............: ShaShow(), ShaKill() 
* 
* AUTHOR............: venkata rangan, tnc               
* DATE..............: 20/04/1995
* PROJECT...........: Alankar Travels Billing program.
* COMPILER..........: CA-Clipper 5.2
* SWITCHES..........: /n /w /m
*/
#include "Shad_Cls.Ch"
#include "Clr_Cls.Ch"

FUNCTION NewShadow (nt,nl,nb,nr)
LOCAL oShadow[SHA_SIZE]
oShadow:ShaTop    := nt
oShadow:ShaLeft   := nl
oShadow:ShaRight  := nr
oShadow:ShaBottom := nb
oShadow:ShaScreen := SAVESCREEN (nt,nl,nb+1,nr+1)
oShadow:ShaColor  := SETCOLOR ()
oShadow:ShaShow   := { |o| Show (o) }
oShadow:ShaKill   := { |o| Kill (o) }
RETURN oShadow

STATIC FUNCTION Show (oShadow)
LOCAL r := oShadow:ShaRight, b := oShadow:ShaBottom
LOCAL t := oShadow:ShaTop, l := oShadow:ShaLeft
IF r <MAXCOL() .AND. b < MAXROW()
   ShowAttr (b+1,l+1,b+1,r+1, 8)
   ShowAttr (t+1,r+1,b+1,r+1, 8) 		
ENDIF	

RETURN NIL

STATIC FUNCTION Kill (oShadow)
SETCOLOR   (oShadow:ShaColor)
RESTSCREEN (oShadow:ShaTop,oShadow:ShaLeft,oShadow:ShaBottom+1,;
			oShadow:ShaRight+1,oShadow:ShaScreen)
RETURN NIL

STATIC PROCEDURE ShowAttr (t,l,b,r,Attr)
LOCAL Old, New, I
Old := SAVESCREEN (t,l,b,r)
New := ""
FOR I := 1 TO LEN(Old) STEP 2
  New := New + SUBSTR (Old,I,1) + CHR (Attr)
NEXT 
RESTSCREEN (t,l,b,r,New)
RETURN 