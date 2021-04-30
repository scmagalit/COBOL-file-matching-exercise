      *------------------------
       IDENTIFICATION DIVISION.
      *------------------------
       PROGRAM-ID. RANKFEM.
       AUTHOR.     Sam Magalit.
      *----------------------------------------------------------------*
      * Generate 3 files showing rank changes of feFEM names from      *
      * 2017 to 2018                                                   *
      *----------------------------------------------------------------*
      *------------------------
       ENVIRONMENT DIVISION.
      *------------------------
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
      * INPUT FILES
           SELECT FD-B17FEM ASSIGN TO B17FEM
                  ORGANIZATION       IS SEQUENTIAL
                  FILE STATUS        IS FS-B17FEM
                  .
           SELECT FD-B18FEM ASSIGN TO B18FEM
                  ORGANIZATION     IS SEQUENTIAL
                  FILE STATUS      IS FS-B18FEM
                  .
      * OUTPUT FILES
           SELECT FD-RANKCHNG ASSIGN TO RANKCHNG
                  ORGANIZATION     IS SEQUENTIAL
                  FILE STATUS      IS FS-RANKCHNG
                  .
      *------------------------
       DATA DIVISION.
      *------------------------
       FILE SECTION.
      * INPUT FILES
       FD  FD-B17FEM
           RECORD CONTAINS 13 CHARACTERS
           RECORDING MODE F
           .
       01  F17-REC.
           05  F17-RANK PIC 999.
           05  FILLER   PIC X.
           05  F17-NAME PIC X(09).

       FD  FD-B18FEM
           RECORD CONTAINS 13 CHARACTERS
           RECORDING MODE F
           .
       01  F18-REC.
           05  F18-RANK PIC 999.
           05  FILLER   PIC X.
           05  F18-NAME PIC X(09).

      * OUTPUT FILES
       FD  FD-RANKCHNG
           RECORD CONTAINS 17 CHARACTERS
           RECORDING MODE F
           .
       01  R18-REC.
           05  R18-RANK PIC 999.
           05  FILLER   PIC X.
           05  R18-NAME PIC X(09).
           05  FILLER   PIC X.
           05  R18-CHNG PIC XXX.

       WORKING-STORAGE SECTION.
       01  WS-VARS.
           05  WS-F17FLAG PIC 9 VALUE 0.
               88  EOF17        VALUE 1.
           05  WS-F18FLAG PIC 9 VALUE 0.
               88  EOF18        VALUE 1.
           05  WS-RANK-CHNG PIC +99 VALUE SPACES.
           05  WS-RANK-NUMC PIC S99 VALUE 0.
       01  WS-SYS-VARS.
           05  FILE-STATUS.
               10 FS-B17FEM  PIC 99.
               10 FS-B18FEM  PIC 99.
               10 FS-RANKCHNG  PIC 99.

      *------------------------
       PROCEDURE DIVISION.
      *------------------------
       0000-MAIN.
           PERFORM 1000-INIT

           PERFORM 2000-READ-F17
           PERFORM 3000-READ-F18
      * Process records until either file reaches the end
           PERFORM UNTIL EOF17 OR EOF18
              MOVE SPACES TO R18-REC
              EVALUATE TRUE
                  WHEN F17-NAME > F18-NAME
      * Name exists in 2018 only, new entry
                       MOVE F18-RANK TO R18-RANK
                       MOVE F18-NAME TO R18-NAME
                       MOVE 'NEW'    TO R18-CHNG
                       WRITE R18-REC
                       PERFORM 3000-READ-F18
                  WHEN F17-NAME < F18-NAME
                       PERFORM 2000-READ-F17
                  WHEN OTHER
      * Name exists in both, compute change in rank
                       MOVE F18-RANK TO R18-RANK
                       MOVE F18-NAME TO R18-NAME
                       COMPUTE WS-RANK-NUMC = F17-RANK - F18-RANK
                       MOVE WS-RANK-NUMC TO WS-RANK-CHNG
                       MOVE WS-RANK-CHNG TO R18-CHNG
                       WRITE R18-REC
                       PERFORM 2000-READ-F17
                       PERFORM 3000-READ-F18
              END-EVALUATE
           END-PERFORM
      * We only check the 2018 file for remaining records signifying
      * new names.
           PERFORM UNTIL EOF18
              MOVE SPACES TO R18-REC
              MOVE F18-RANK TO R18-RANK
              MOVE F18-NAME TO R18-NAME
              MOVE '>NEW'   TO R18-CHNG
              WRITE R18-REC
              PERFORM 3000-READ-F18
           END-PERFORM

           PERFORM 9000-CLEANUP
           .
       1000-INIT.
           OPEN INPUT FD-B17FEM FD-B18FEM
           OPEN OUTPUT FD-RANKCHNG

           IF FILE-STATUS NOT = ZEROES
              DISPLAY 'ERROR ON OPEN'
              DISPLAY FILE-STATUS
              PERFORM 9999-TERMINATE
           END-IF
           .
       2000-READ-F17.
           READ FD-B17FEM
                AT END SET EOF17 TO TRUE
           END-READ

           IF FS-B17FEM NOT = 0 AND 10
              DISPLAY 'ERROR ON READ (B17FEM)'
              DISPLAY FS-B17FEM
              PERFORM 9999-TERMINATE
           END-IF
           .
       3000-READ-F18.
           READ FD-B18FEM
                AT END SET EOF18 TO TRUE
           END-READ

           IF FS-B18FEM NOT = 0 AND 10
              DISPLAY 'ERROR ON READ (B17FEM)'
              DISPLAY FS-B18FEM
              PERFORM 9999-TERMINATE
           END-IF
           .
       9000-CLEANUP.
           CLOSE FD-B17FEM FD-B18FEM FD-RANKCHNG

           PERFORM 9999-TERMINATE
           .
       9999-TERMINATE.
           DISPLAY 'PROGRAM TERMINATED'
           STOP RUN
           .