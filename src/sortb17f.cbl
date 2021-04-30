      *------------------------
       IDENTIFICATION DIVISION.
      *------------------------
       PROGRAM-ID. SORTB17F.
       AUTHOR.     Sam Magalit.
      *----------------------------------------------------------------*
      * Sorting BABY2017 file according to and retaining female names  *
      * only (and ranking to be used for succeeding steps              *
      *----------------------------------------------------------------*
      *------------------------
       ENVIRONMENT DIVISION.
      *------------------------
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
      * INPUT FILES
           SELECT FD-BABY2017 ASSIGN TO BABY2017
                  ORGANIZATION       IS SEQUENTIAL
                  FILE STATUS        IS FS-BABY2017
                  .
      * OUTPUT FILES
           SELECT FD-B17FEM ASSIGN TO B17FEM
                  ORGANIZATION     IS SEQUENTIAL
                  FILE STATUS      IS FS-B17FEM
                  .
      * SORT FILES
           SELECT SD-SORTFILE ASSIGN TO SORTFILE
                  .
      *------------------------
       DATA DIVISION.
      *------------------------
       FILE SECTION.
      * INPUT FILES
       FD  FD-BABY2017
           RECORD CONTAINS 25 CHARACTERS
           RECORDING MODE F
           .
       01  B17-REC.
           05  B17-RANK PIC 999.
           05  FILLER   PIC X.
           05  B17-MALE PIC X(11).
           05  FILLER   PIC X.
           05  B17-FEM  PIC X(09).
      * OUTPUT FILES
       FD  FD-B17FEM
           RECORD CONTAINS 13 CHARACTERS
           RECORDING MODE F
           .
       01  F17-REC.
           05  F17-RANK PIC 999.
           05  FILLER   PIC X.
           05  F17-FEM PIC X(09).
      * SORT FILES
       SD  SD-SORTFILE
           RECORD CONTAINS 25 CHARACTERS
           .
       01  S17-REC.
           05  S17-RANK PIC 999.
           05  FILLER   PIC X.
           05  S17-MALE PIC X(11).
           05  FILLER   PIC X.
           05  S17-FEM  PIC X(09).

       WORKING-STORAGE SECTION.
       01  WS-VARS.
           05  WS-SORT-FLAG PIC 9 VALUE 0.
               88  EOF            VALUE 1.
       01  WS-SYS-VARS.
           05  FILE-STATUS.
               10 FS-BABY2017 PIC 99.
               10 FS-B17FEM   PIC 99.

      *------------------------
       PROCEDURE DIVISION.
      *------------------------
       0000-MAIN.
      * We use USING instead of INPUT PROCEDURE since we don't need to
      * filter records before releasing (writing) from input record.
      * We use OUTPUT PROCEDURE to edit the format of the output file
      * since the input and output files don't have the same format
           SORT SD-SORTFILE ON ASCENDING KEY S17-FEM
                USING FD-BABY2017
                OUTPUT PROCEDURE 1000-OUTREC

           DISPLAY 'PROGRAM TERMINATED'
           PERFORM 9999-TERMINATE
           .
       1000-OUTREC.
           OPEN OUTPUT FD-B17FEM
           IF FS-B17FEM NOT = 0
              DISPLAY 'ERROR OPENING FD-B17FEM'
              PERFORM 9999-TERMINATE
           END-IF

           PERFORM 1100-READ-SORTFILE
      * Perform one read before entering loop to prevent execution of
      * loop when file is empty
           PERFORM UNTIL EOF
              MOVE SPACES TO F17-REC
              MOVE S17-RANK TO F17-RANK
              MOVE S17-FEM TO F17-FEM

              WRITE F17-REC
              IF FS-B17FEM NOT = 0
                 DISPLAY 'ERROR WRITING TO FD-B17FEM'
                 DISPLAY F17-REC
                 PERFORM 9999-TERMINATE
              END-IF

              PERFORM 1100-READ-SORTFILE
           END-PERFORM
           .
       1100-READ-SORTFILE.
      * RETURN keyword is like READ for SD file (OUTPUT PROCEDURE)
      * RELEASE keyword is like WRITE for SD file (INPUT PROCEDURE)
           RETURN SD-SORTFILE
              AT END SET EOF TO TRUE
           END-RETURN
           .
       9999-TERMINATE.
           STOP RUN
           .