//JSORT    JOB CLASS=A,MSGCLASS=H,MSGLEVEL=(1,1),REGION=2048K,
//          NOTIFY=&SYSUID
//*
//********************************************************************
//* SORT BABY2017 FILE BY MALE NAMES (USING DFSORT)                  *
//********************************************************************
//* Sort file retaining only the male names field (hence the starting
//* column of 5 and record length 11)
//M17SORT  EXEC PGM=SORT
//SORTIN   DD DSN=IBMUSER.SMAGALIT.BABY2017,DISP=SHR
//SORTOUT  DD DSN=IBMUSER.SMAGALIT.B17MALE,DISP=(NEW,CATLG,DELETE),
//            LIKE=IBMUSER.SMAGALIT.BABY2017,LRECL=11
//SYSIN    DD *
   SORT FIELDS=(5,11,CH,A)
   OUTREC FIELDS=(5,11)
/*
//SYSOUT   DD SYSOUT=*
//********************************************************************
//* SORT BABY2017 FILE BY FEMALE NAMES (USING COBOL PROGRAM)         *
//********************************************************************
//* Sort file retaining only the female names and rank
//* field (with max length 13)
//F17SORT  EXEC PGM=SORTB17F,REGION=4M
//STEPLIB  DD DSN=DSN910.DB9G.RUNLIB.LOAD,DISP=SHR
//BABY2017 DD DSN=IBMUSER.SMAGALIT.BABY2017,DISP=SHR
//B17FEM   DD DSN=IBMUSER.SMAGALIT.B17FEM,DISP=(NEW,CATLG,DELETE),
//            LIKE=IBMUSER.SMAGALIT.BABY2017,LRECL=13
//SORTFILE DD DSN=&&TEMP
//SYSOUT   DD SYSOUT=*
//SYUDUMP  DD SYSOUT=*
//CEEDUMP  DD SYSOUT=*
//SYSPRINT DD SYSOUT=*
//SYSTSPRT DD SYSOUT=*
//********************************************************************
//* SORT BABY2018 FILE BY MALE AND FEMALE NAMES (USING ICETOOL)      *
//********************************************************************
//* Sort file retaining using ICETOOL to create 2 files at once
//* (retaining male only and female names only)
//B18SORT  EXEC PGM=ICETOOL
//SORTIN   DD DSN=IBMUSER.SMAGALIT.BABY2018,DISP=SHR
//SORTM18  DD DSN=IBMUSER.SMAGALIT.B18MALE,DISP=(NEW,CATLG,DELETE),
//            LIKE=IBMUSER.SMAGALIT.BABY2018,LRECL=11
//SORTF18  DD DSN=IBMUSER.SMAGALIT.B18FEM,DISP=(NEW,CATLG,DELETE),
//            LIKE=IBMUSER.SMAGALIT.BABY2018,LRECL=13
//SYSOUT   DD SYSOUT=*
//TOOLMSG  DD SYSOUT=*
//DFSMSG   DD SYSOUT=*
//TOOLIN   DD *
   SORT FROM(SORTIN) TO(SORTM18) USING(CTL1)
   SORT FROM(SORTIN) TO(SORTF18) USING(CTL2)
/*
//CTL1CNTL DD *
   SORT FIELDS=(5,11,CH,A)
   OUTREC FIELDS=(5,11)
/*
//CTL2CNTL DD *
   SORT FIELDS=(17,9,CH,A)
   OUTREC FIELDS=(1,4,17,9)
/*