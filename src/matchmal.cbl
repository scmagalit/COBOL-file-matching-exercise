      *------------------------
       IDENTIFICATION DIVISION.
      *------------------------
       PROGRAM-ID. MATCHMAL.
       AUTHOR.     Sam Magalit.
      *----------------------------------------------------------------*
      * Generate 3 files based on male names in 2017 and 2018:         *
      * 1.) Names in 2017 file only                                    *
      * 2.) Names in 2018 file only                                    *
      * 3.) Names in both files                                        *
      *----------------------------------------------------------------*
      *------------------------
       ENVIRONMENT DIVISION.
      *------------------------
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
      * INPUT FILES
           SELECT FD-B17MALE ASSIGN TO B17MALE
                  ORGANIZATION       IS SEQUENTIAL
                  FILE STATUS        IS FS-B17MALE
                  .
           SELECT FD-B18MALE ASSIGN TO B18MALE
                  ORGANIZATION     IS SEQUENTIAL
                  FILE STATUS      IS FS-B18MALE
                  .
      * OUTPUT FILES
           SELECT FD-M17ONLY ASSIGN TO M17ONLY
                  ORGANIZATION     IS SEQUENTIAL
                  FILE STATUS      IS FS-M17ONLY
                  .
           SELECT FD-M18ONLY ASSIGN TO M18ONLY
                  ORGANIZATION     IS SEQUENTIAL
                  FILE STATUS      IS FS-M18ONLY
                  .
           SELECT FD-MALEBOTH ASSIGN TO MALEBOTH
                  ORGANIZATION     IS SEQUENTIAL
                  FILE STATUS      IS FS-MALEBOTH
                  .
      *------------------------
       DATA DIVISION.
      *------------------------
       FILE SECTION.
      * INPUT FILES 
       FD  FD-B17MALE
           RECORD CONTAINS 11 CHARACTERS
           RECORDING MODE F
           .
       01  M17-REC.
           05  M17-NAME PIC X(11).

       FD  FD-B18MALE
           RECORD CONTAINS 11 CHARACTERS
           RECORDING MODE F
           .
       01  M18-REC.
           05  M18-NAME PIC X(11).

      * OUTPUT FILES
       FD  FD-M17ONLY
           RECORD CONTAINS 11 CHARACTERS
           RECORDING MODE F
           .
       01  O17-REC.
           05  O17-NAME PIC X(11).

       FD  FD-M18ONLY
           RECORD CONTAINS 11 CHARACTERS
           RECORDING MODE F
           .
       01  O18-REC.
           05  O18-NAME PIC X(11).
           
       FD  FD-MALEBOTH
           RECORD CONTAINS 11 CHARACTERS
           RECORDING MODE F
           .
       01  BTH-REC.
           05  BTH-NAME PIC X(11).

       WORKING-STORAGE SECTION.
       01  WS-VARS.
           05  WS-M17FLAG PIC 9 VALUE 0.
               88  EOF17        VALUE 1.
           05  WS-M18FLAG PIC 9 VALUE 0.
               88  EOF18        VALUE 1.
       01  WS-SYS-VARS.
           05  FILE-STATUS.
               10 FS-B17MALE  PIC 99.
               10 FS-B18MALE  PIC 99.
               10 FS-M17ONLY  PIC 99.
               10 FS-M18ONLY  PIC 99.
               10 FS-MALEBOTH PIC 99.

      *------------------------
       PROCEDURE DIVISION.
      *------------------------
       0000-MAIN.
           PERFORM 1000-INIT

           PERFORM 2000-READ-M17
           PERFORM 3000-READ-M18
      * Process records until either file reaches the end
           PERFORM UNTIL EOF17 OR EOF18 
              EVALUATE TRUE
                  WHEN M17-NAME > M18-NAME 
                       WRITE O18-REC FROM M18-REC
                       PERFORM 3000-READ-M18 
                  WHEN M17-NAME < M18-NAME 
                       WRITE O17-REC FROM M17-REC
                       PERFORM 2000-READ-M17
                  WHEN OTHER
                       WRITE BTH-REC FROM M18-REC
                       PERFORM 2000-READ-M17
                       PERFORM 3000-READ-M18
              END-EVALUATE
           END-PERFORM 
      * Since previous perform block ensures that one of the files 
      * reached EOF, only one of the following perform blocks will be
      * executed. If both reached EOF at the same time, none will be 
      * executed.
           PERFORM UNTIL EOF17 
              WRITE O17-REC FROM M17-REC
              PERFORM 2000-READ-M17
           END-PERFORM

           PERFORM UNTIL EOF18
              WRITE O18-REC FROM M18-REC
              PERFORM 3000-READ-M18
           END-PERFORM

           PERFORM 9000-CLEANUP
           .
       1000-INIT.
           OPEN INPUT FD-B17MALE FD-B18MALE
           OPEN OUTPUT FD-M17ONLY FD-M18ONLY FD-MALEBOTH

           IF FILE-STATUS NOT = ZEROES
              DISPLAY 'ERROR ON OPEN'
              DISPLAY FILE-STATUS
              PERFORM 9999-TERMINATE
           END-IF
           .
       2000-READ-M17.
           READ FD-B17MALE
                AT END SET EOF17 TO TRUE 
           END-READ

           IF FS-B17MALE NOT = 0 AND 10
              DISPLAY 'ERROR ON READ (B17MALE)'
              DISPLAY FS-B17MALE
              PERFORM 9999-TERMINATE
           END-IF
           .
       3000-READ-M18.
           READ FD-B18MALE
                AT END SET EOF18 TO TRUE 
           END-READ

           IF FS-B18MALE NOT = 0 AND 10
              DISPLAY 'ERROR ON READ (B17MALE)'
              DISPLAY FS-B18MALE
              PERFORM 9999-TERMINATE
           END-IF
           .
       9000-CLEANUP.
           CLOSE FD-B17MALE FD-B18MALE FD-M17ONLY FD-M18ONLY FD-MALEBOTH

           PERFORM 9999-TERMINATE
           .
       9999-TERMINATE.
           DISPLAY 'PROGRAM TERMINATED'
           STOP RUN
           .