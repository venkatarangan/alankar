/*
* INCLUDE...........: MENU_CLS.CH
* PRG...............: MENU_CLS.PRG
* CLASS.............: Implements a Menu Box.
* DESC..............: Executes the menu box element's code blocks.
* EXPORTS...........: Nil
* CONSTRUCTOR.......: NewMenu  ()
* METHODS...........: MenuShow()
* STATIC FUNCTIONS..: ShowMenu()
*
* USES..............: Standard Clipper Functions
*                     Stack Class - STK_CLS.PRG.
*					  Color Class - CLR_CLS.PRG.
*	
* NOTES.............: The Constructor returns a object, which
*                     contains one code block and elements which
*                     have options for the list and a list array.
* 	  	      		  It has got two private variables.
*
* AUTHOR............: venkata rangan, tnc & madhu, s.
* DATE..............: 20-04-1995
* PROJECT...........: Alankar Travels Billing Program.
*
* COMPILER..........: CA-Clipper 5.2
* SWITCHES..........: /n /w /m
*/

#define MENU_SIZE      10
#define MENUTOP		1 	
#define MENULEFT	2	
#define MENUBOTTOM	3
#define MENURIGHT	4
#define MENUMESSAGE  	5 	
#define MENUARRAY	6
#define MENUCODE	7
#define MENUSHOW	8
#define MENUDEFAULT	9
#define MENUCHOICE	10


#xtranslate :MenuTop		=>  \[MENUTOP\]	
#xtranslate :MenuLeft 		=>  \[MENULEFT\]
#xtranslate :MenuBottom		=>  \[MENUBOTTOM\]
#xtranslate :MenuRight		=>  \[MENURIGHT\]
#xtranslate :MenuMessage	=>  \[MENUMESSAGE\]
#xtranslate :MenuArray		=>  \[MENUARRAY\]
#xtranslate :MenuCodeBlocks	=>  \[MENUCODE\]
#xtranslate :MenuShow		=>  \[MENUSHOW\]
#xtranslate :MenuDefault 	=>  \[MENUDEFAULT\]
#xtranslate :MenuChoice 	=>  \[MENUCHOICE\]
