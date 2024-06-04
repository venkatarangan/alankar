/*
* INCLUDE...........: SHAD_CLS.CH	
* PRG...............: SHAD_CLS.PRG
* CLASS.............: Shadow Implementation Class.
* DESC..............: Displays shadows around rectangles.
*
* EXPORTS...........: Nil
* CONSTRUCTOR.......: NewShadow (t,l,b,r)
*
* USES..............: Standard Clipper Fucntions
* NOTES.............: The Constructor returns a object.
* METHOD............: ShaShow(), ShaKill() 
* 
* AUTHOR............: venkata rangan, tnc & madhu, s.               
* DATE..............: 20/04/1995
* PROJECT...........: Alankar Travels Billling Program.
*
* COMPILER..........: CA-Clipper 5.2
* SWITCHES..........: /n /w /m
*/

#define SHA_SIZE    8

#define SHA_SHOW    1
#define SHA_KILL    2
#define SHA_TOP	    3
#define SHA_LEFT    4	
#define	SHA_BOTTOM  5	 
#define SHA_RIGHT   6	
#define SHA_COLOR   7	
#define SHA_SCREEN  8 

#xtranslate :ShaShow  	=> \[SHA_SHOW\]
#xtranslate :ShaKill    => \[SHA_KILL\]
#xtranslate :ShaTop  	=> \[SHA_TOP\]
#xtranslate :ShaLeft    => \[SHA_LEFT\]
#xtranslate :ShaRight  	=> \[SHA_RIGHT\]
#xtranslate :ShaBottom  => \[SHA_BOTTOM\]
#xtranslate :ShaScreen 	=> \[SHA_SCREEN\]
#xtranslate :ShaColor   => \[SHA_COLOR\]