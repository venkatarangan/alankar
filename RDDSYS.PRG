/***
*
*  RddSys.prg
*
*  This program is run each time your application is started to setup
*  the proper default driver.  You should modify a copy of this file
*  if you wish to use a default RDD other than DBFNTX.
*
*  Copyright (c) 1993, Computer Associates International, Inc.
*  All rights reserved.
*
*/

ANNOUNCE RDDSYS                        // This line must not change

INIT PROCEDURE RddInit
   REQUEST DBFCDX                     // Causes FoxPro 2.0 RDD to be linked in
                               
   rddSetDefault( "DBFCDX" )           // Set up FoxPro 2.0 as default driver

   RETURN

// eof: rddsys.prg
