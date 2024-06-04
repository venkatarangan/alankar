/*
* INCLUDE...........: CLR_CLS.CH
* PRG...............: CLR_CLS.PRG
* CLASS.............: Color settings management Class
* DESC..............: Gets, Stores & Provides Color Settings
* EXPORTS...........: Nil
* CONSTRUCTOR.......: NewColor ()
* STATIC FUNCTIONS..: ReadColor(), WriteColor(),
*					  DefaultColor() & ChangeColor()
* USES..............: Standard Clipper Fucntions
* NOTES.............: The Constructor returns a object, which
*                     contains one code block and elements which
*					  have color options.
*
* AUTHOR............: venkata rangan, tnc & madhu, s.
* DATE..............: 20-04-1995
* PROJECT...........: Alankar Travels Billing program.
*
* COMPILER..........: CA-Clipper 5.2
* SWITCHES..........: /n /w /m
*/

#define CLR_SIZE     22
#define MSGTITLE     1
#define MSGTEXT      2
#define MSGBOX       3

#define WNDTITLE     4
#define WNDTEXT      5
#define WNDBOX       6

#define TITLEBAR     7
#define HELPLINE     8

#define MENUTEXT1    9
#define MENUTEXT2   10
#define MENUTEXT    11

#define MENUBOX     22

#define DESKTOP     12
#define WORKSPACE   13
#define SHOWSCR     14
#define EDITSCR     15

#define BUTTONS1    16
#define BUTTONS2    17
#define BUTTONS	    18



#define HELPTEXT    19
#define HELPBOX     20
#define SCROLLBAR   21


#define COLORCHANGE  CLR_SIZE+1

#xtranslate :MsgTitle    =>     \[MSGTITLE\]
#xtranslate :MsgText	 =>     \[MSGTEXT\]
#xtranslate :MsgBox 	 => 	\[MSGBOX\]

#xtranslate :WndTitle    =>     \[WNDTITLE\]
#xtranslate :WndText	 =>     \[WNDTEXT\]
#xtranslate :WndBox 	 => 	\[WNDBOX\]

#xtranslate :TitleBar    =>     \[TITLEBAR\]
#xtranslate :HelpLine    =>     \[HELPLINE\]

#xtranslate :MenuText1 	 => 	\[MENUTEXT1\]
#xtranslate :MenuText2   =>     \[MENUTEXT2\]
#xtranslate :MenuBox   	 =>     \[MENUBOX\]

#xtranslate :Desktop	 =>     \[DESKTOP\]
#xtranslate :WorkSpace 	 => 	\[WORKSPACE\]

#xtranslate :ShowScr     =>     \[SHOWSCR\]
#xtranslate :EditScr     =>     \[EDITSCR\]

#xtranslate :Buttons1	 =>     \[BUTTONS1\]
#xtranslate :Buttons2	 =>     \[BUTTONS2\]

#xtranslate :ScrollBar 	 => 	\[SCROLLBAR\]
#xtranslate :HelpText    =>     \[HELPTEXT\]
#xtranslate :HelpBox     =>     \[HELPBOX\]

#xtranslate :MenuText    =>    \[MENUTEXT\] 
#xtranslate :Buttons     =>    \[BUTTONS\]

#xtranslate :ColorChange =>     \[COLORCHANGE\]
