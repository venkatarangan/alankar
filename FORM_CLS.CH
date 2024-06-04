/*
* INCLUDE...........: FORM_CLS.CH
* PRG...............: FORM_CLS.PRG
* CLASS.............: Form management Class
* DESC..............: Shows & Activates Forms 
* EXPORTS...........: Nil
* CONSTRUCTOR.......: NewForm  ()
* IMPORTED METHODS..: FormEdit(), FormInsert(), FormDelete(),
*                      FormStabilize(),FormPrint(),FormOpen(),FormClose().
* STATIC FUNCTIONS..: Activate(), ShowForm(), DrawForm()
*
* USES..............: Standard Clipper Functions
*                         Classes -> STK_CLS, CLR_CLS & SHAD_CLS
*
* NOTES.............: The Constructor returns a object, which
*                     contains several code block, some of them 
*                     are provided as default and can be changed.
*
* AUTHOR............: venkata rangan, tnc & madhu, s.
* DATE..............: 20/04/1995
* PROJECT...........: Alankar Travels Billing Program.
*
* COMPILER..........: CA-Clipper 5.2
* SWITCHES..........: /n /w /m
*/

#define FORM_SIZE                25
#define FORM_TOP                 01
#define FORM_LEFT                02
#define FORM_BOTTOM              03
#define FORM_RIGHT               04
#define FORM_TITLE               05

#define FORM_STABILIZE           06
#define FORM_VIEW                07
#define FORM_EDIT                08
#define FORM_INSERT              09
#define FORM_DELETE              10
#define FORM_PRINT               11
#define FORM_CLOSE               12
#define FORM_OPEN                13
#define FORM_SHOW                14

#define FORM_PREV                15 
#define FORM_NEXT                16
#define FORM_TAG                 17
#define FORM_UNTAG               18      
#define FORM_FIRST               19     
#define FORM_LAST                20
#define FORM_CHOOSE              21
#define FORM_LASTLINE            22
#define FORM_SPECIAL             23
#define FORM_MEMO                24

        
#xtranslate :FormTop    => \[FORM_TOP\]
#xtranslate :FormLeft   => \[FORM_LEFT\]
#xtranslate :FormBottom => \[FORM_BOTTOM\]
#xtranslate :FormRight  => \[FORM_RIGHT\]
#xtranslate :FormTitle  => \[FORM_TITLE\]

#xtranslate :FormStabilize => \[FORM_STABILIZE\]
#xtranslate :FormView      => \[FORM_VIEW\]
#xtranslate :FormEdit      => \[FORM_EDIT\]

#xtranslate :FormInsert => \[FORM_INSERT\]
#xtranslate :FormDelete => \[FORM_DELETE\]
#xtranslate :FormPrint  => \[FORM_PRINT\]
#xtranslate :FormClose  => \[FORM_CLOSE\]
#xtranslate :FormOpen   => \[FORM_OPEN\]
#xtranslate :FormShow   => \[FORM_SHOW\]

#xtranslate :FormPrev   => \[FORM_PREV\]
#xtranslate :FormNext   => \[FORM_NEXT\]
#xtranslate :FormFirst  => \[FORM_FIRST\]
#xtranslate :FormLast   => \[FORM_LAST\]

#xtranslate :FormTag      => \[FORM_TAG\]
#xtranslate :FormUntag    => \[FORM_UNTAG\]
#xtranslate :FormChoose   => \[FORM_CHOOSE\]
#xtranslate :FormLastLine => \[FORM_LASTLINE\]
#xtranslate :FormSpecial  => \[FORM_SPECIAL\]
#xtranslate :FormMemo     => \[FORM_MEMO\]

