//JRANKFEM JOB CLASS=A,MSGCLASS=H,MSGLEVEL=(1,1),REGION=2048K,
//          NOTIFY=&SYSUID
//********************************************************************
//RANKFEM  EXEC PGM=RANKFEM,REGION=4M
//STEPLIB  DD DSN=DSN910.DB9G.RUNLIB.LOAD,DISP=SHR
//B17FEM   DD DSN=IBMUSER.SMAGALIT.B17FEM,DISP=SHR
//B18FEM   DD DSN=IBMUSER.SMAGALIT.B18FEM,DISP=SHR
//* Use PASS to let the succeeding steps use the DD
//RANKCHNG DD DSN=IBMUSER.SMAGALIT.RANKTEMP,DISP=(,PASS),
//            LIKE=IBMUSER.SMAGALIT.B18FEM,LRECL=17
//SYSOUT   DD SYSOUT=*
//SYUDUMP  DD SYSOUT=*
//CEEDUMP  DD SYSOUT=*
//SYSPRINT DD SYSOUT=*
//SYSTSPRT DD SYSOUT=*
//********************************************************************
//* SORT RANK CHANGE FILE BY RANKING                                 *
//********************************************************************
//* Since resulting file from previous step is still sroted by name,
//* we still need to resort it by ranking
//R18SORT  EXEC PGM=SORT
//* Referring back to DD in previous step format: *.STEPNAME.DDNAME
//* SORTIN DSN is just a temporary dataset so we delete it after
//SORTIN   DD DSN=*.RANKFEM.RANKCHNG,DISP=(OLD,DELETE,DELETE)
//SORTOUT  DD DSN=IBMUSER.SMAGALIT.RANKCHNG,DISP=(NEW,CATLG,DELETE),
//            LIKE=IBMUSER.SMAGALIT.B18FEM,LRECL=17
//SYSIN    DD *
   SORT FIELDS=(1,3,CH,A)
/*
//SYSOUT   DD SYSOUT=*