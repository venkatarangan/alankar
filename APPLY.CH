/*
* INCLUDE...........: APPLY.CH
* DESC..............: Imitates a method application by using EVAL
* USES..............: Standard Clipper PreProcessor
*      	
* NOTES.............: The Keyword APPLY is transformed into Clipper EVAL
*					  calls, inorder to imitate Functions inside Objects.
*
* AUTHOR............: venkata rangan, tnc & madhu, s.
* DATE..............: 20/04/1995
* PROJECT...........: Alankar Travels Billing Routine.
*
* COMPILER..........: CA-Clipper 5.2
* SWITCHES..........: /n /w /m
*/

#xtranslate APPLY <a>:<b> ([<c>] [,<d>] [,<e>] ) ;
				 => EVAL (<a>:<b>[,<c>] [,<d>] [,<e>] )