;*****************************************************************
;* This stationery serves as the framework for a                 *
;* user application (single file, absolute assembly application) *
;* For a more comprehensive program that                         *
;* demonstrates the more advanced functionality of this          *
;* processor, please see the demonstration applications          *
;* located in the examples subdirectory of the                   *
;* Freescale CodeWarrior for the HC12 Program directory          *
;*****************************************************************

; export symbols
            XDEF Entry, _Startup            ; export 'Entry' symbol
            ABSENTRY Entry        ; for absolute assembly: mark this as application entry point



; Include derivative-specific definitions 
		INCLUDE 'derivative.inc' 

;*****************************************************************
;*                         Code Section                          *
;*****************************************************************    
    ORG $4000
Entry:
_Startup: 
    BSET DDRA,%00000011
    BSET DDRT,%00110000
    JSR STARFWD
    JSR PORTFWD
    JSR STARON
    JSR PORTON
    JSR STARREV
    JSR PORTREV
    JSR STAROFF
    JSR PORTOFF
    BRA *

;*****************************************************************
;*                     Subroutines Section                       *
;*****************************************************************    
STARON LDAA PTT       ; sets pin PT5
    ORAA #%00100000
    STAA PTT
    RTS
    
STAROFF LDAA PTT      ; clears pin PT5
    ANDA #%11011111
    STAA PTT
    RTS
    
PORTON LDAA PTT       ; sets pin PT4
    ORAA #%00010000
    STAA PTT     
    RTS
    
PORTOFF LDAA PTT      ; clears pin PT4 
    ANDA #%11101111
    STAA PTT    
    RTS
    
STARFWD LDAA PORTA    ; clears pin PA1  
    ANDA #%11111101
    STAA PORTA
    RTS
    
STARREV LDAA PORTA    ; sets pin PA1 
    ORAA #%00000010
    STAA PORTA
    RTS

PORTFWD LDAA PORTA    ; clears pin PA0
    ANDA #%11111110
    STAA PORTA
    RTS
    
PORTREV LDAA PORTA    ; sets pin PA0
    ORAA #%00000001
    STAA PORTA
    RTS

;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
