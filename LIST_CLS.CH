
/*
* INCLUDE...........: LIST_CLS.CH
* PRG...............: LIST_CLS.PRG
* CLASS.............: Implements a List Box with Insert & delete
* DESC..............: 
* EXPORTS...........: Nil
* CONSTRUCTOR.......: NewList  ()
* METHODS...........: ListShow()
* STATIC FUNCTIONS..: Show List()
*
* USES..............: Standard Clipper Functions
*                     Stack Class - STK_CLS.PRG.
*                     Color Class - CLR_CLS.PRG.
*	
* NOTES.............: The Constructor returns a object, which
*                     contains one code block and elements which
*                     have options for the list and a list array.
*  	   	      It has got two private variables.
*
* AUTHOR............: venkata rangan, tnc & madhu, s.
* DATE..............: 20-04-1995
* PROJECT...........: Alankar Travels Billing program.
*
* COMPILER..........: CA-Clipper 5.2
* SWITCHES..........: /n /w /m
*/
#define 	LIST_SIZE        17

#define		LISTTOP			 1
#define		LISTLEFT 		 2
#define		LISTBOTTOM		 3
#define		LISTRIGHT		 4

#define		LISTSHOW 	 	 5
#define		LISTVALIDATE	 	 6
#define		LISTPICTURE		 7
#define		LISTARRAY		 8
#define		LISTDEFAULT		 9

#define		LISTDELETE		 10
#define		LISTINSERT		 11

#define		LISTBUFFER		 12
#define		LISTCHOICE       	 13
#define 	LISTINDEX        	 14
#define     	LISTMESSAGE              15

#define  	LISTINSTEXT 		 16
#define         LISTCARGO 		 17

#xtranslate :ListTop 	  =>	\[LISTTOP\]
#xtranslate :ListLeft     =>  	\[LISTLEFT\]
#xtranslate :ListBottom   =>  	\[LISTBOTTOM\]
#xtranslate :ListRight    =>    \[LISTRIGHT\]

#xtranslate :ListShow     =>    \[LISTSHOW\]
#xtranslate :ListValidate =>    \[LISTVALIDATE\]
#xtranslate :ListPicture  =>    \[LISTPICTURE\]
#xtranslate :ListArray    =>    \[LISTARRAY\]
#xtranslate :ListDefault  =>    \[LISTDEFAULT\]

#xtranslate :ListDelete   =>    \[LISTDELETE\]
#xtranslate :ListInsert   =>    \[LISTINSERT\]

#xtranslate :ListBuffer   =>    \[LISTBUFFER\]
#xtranslate :ListChoice   =>	\[LISTCHOICE\]
#xtranslate :ListIndex    =>	\[LISTINDEX\]
#xtranslate :ListMessage  =>	\[LISTMESSAGE\]

#xtranslate :ListInsText  => 	\[LISTINSTEXT\]
#xtranslate :ListCargo	  =>	\[LISTCARGO\]