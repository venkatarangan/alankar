#include "Msg_Cls.Ch"
#include "Apply.Ch"

STATIC kError 
FUNCTION PrintOn()
        IF ISPRINTER()
            kError := ErrorBlock({|o| MyError(o)})        
            SET DEVICE TO PRINTER
            SET MARGIN TO 4
        ELSE
            RETURN .F.
        ENDIF
RETURN  .T.

FUNCTION PrintOff()
        EJECT
        ErrorBlock(kError)
        SET DEVICE TO SCREEN
RETURN .T.

STATIC FUNCTION MyError (oErr)
        EVAL (kError,oErr) 
RETURN .T.

FUNCTION PrintLine()
RETURN 65

FUNCTION PrintNoReady()
LOCAL oMsg:=NewMessage()
oMsg:MsgTitle   := "- Printer Error"
oMsg:MsgText    := {"Make sure your printer is ready and try again"}
oMsg:MsgButtons := {"Ok"}
oMsg:MsgDefault := 1
Apply oMsg:MsgShow(oMsg)
RETURN NIL
