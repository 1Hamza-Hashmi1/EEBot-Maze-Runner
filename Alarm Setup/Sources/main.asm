;*****************************************************************
;*                       Timer Alarms                            *
;*****************************************************************
; export symbols
    XDEF Entry, _Startup            ; export 'Entry' symbol
    ABSENTRY Entry                  ; for absolute assembly: mark this as application entry point



; Include derivative-specific definitions 
		INCLUDE 'derivative.inc'
		
;*****************************************************************
;*                         Definitions                           *
;*****************************************************************
OneSec      EQU   23                ; 1 second delay (at 23Hz)
TwoSec      EQU   46                ; 2 second delay (at 23Hz)
LCD_DAT     EQU   PORTB             ; LCD data port, bits - PB7,...,PB0
LCD_CNTR    EQU   PTJ               ; LCD control port, bits - PJ7(E),PJ6(RS)
LCD_E       EQU   $80               ; LCD E-signal pin
LCD_RS      EQU   $40               ; LCD RS-signal pin
                        
;variable/data section
    ORG $3850                       ; Where our TOF counter register lives
TOF_COUNTER RMB   1                 ; The timer, incremented at 23Hz
AT_DEMO     RMB   1                 ; The alarm time for this demo

;*****************************************************************
;*                         Code Section                          *
;*****************************************************************
    ORG $4000                       ; Where the code starts
Entry:
_Startup:
            LDS   #$4000            ; initialize the stack pointer
            JSR   initLCD           ; initialize the LCD
            JSR   clrLCD            ; clear LCD & home cursor
            JSR   ENABLE_TOF        ; Jump to TOF initialization
            CLI                     ; Enable global interrupt
            
            LDAA  #$41              ; Display A (for 1 sec)
            JSR   putcLCD           ; --"--
            
            LDAA  TOF_COUNTER       ; Initialize the alarm time
            ADDA  #OneSec           ; by adding on the 1 sec delay
            STAA  AT_DEMO           ; and save it in the alarm
CHK_DELAY_1 LDAA  TOF_COUNTER       ; If the current time
            CMPA  AT_DEMO           ; equals the alarm time
            BEQ   A1                ; then display B
            BRA   CHK_DELAY_1       ; and check the alarm again
            
A1          LDAA  #$42              ; Display B (for 2 sec)
            JSR   putcLCD           ; --"--
            LDAA  AT_DEMO           ; Initialize the alarm time
            ADDA  #TwoSec            ; by adding on the 2 sec delay
            STAA  AT_DEMO           ; and save it in the alarm
            
CHK_DELAY_2 LDAA  TOF_COUNTER       ; If the current time
            CMPA  AT_DEMO           ; equals the alarm time
            BEQ   A2                ; then display C
            BRA   CHK_DELAY_2       ; and check the alarm again
            
A2          LDAA  #$43              ; Display C (forever)
            JSR   putcLCD           ; --"--
            SWI
            
;*****************************************************************
;*                     Subroutines Section                       *
;*****************************************************************
******************************************************************
initLCD     BSET  DDRB,%11111111    ; configure pins PB7-PB0 for output
            BSET  DDRJ,%11000000    ; configure pins PJ7(E) and PJ6(RS) for output
            LDY   #2000             ; wait for LCD to be ready
            JSR   del_50us          ; -"-
            LDAA  #$28              ; set 4-bit data, 2-line display
            JSR   cmd2LCD           ; -"-
            LDAA  #$0C              ; display on, cursor off, blinking off
            JSR   cmd2LCD           ; -"-
            LDAA  #$06              ; move cursor right after entering a character
            JSR   cmd2LCD           ; -"-
            RTS                     
******************************************************************           
clrLCD      LDAA  #$01              ; clear cursor and return to home position
	          JSR   cmd2LCD           ; -"-
            LDY   #40               ; wait until "clear cursor" command is complete
            JSR   del_50us          ; -"-
            RTS
******************************************************************
del_50us    PSHX                    ;2 E-clk
eloop 		  LDX   #30               ;2 E-clk -
iloop 		  PSHA                    ;2 E-clk  |
  		      PULA                    ;3 E-clk  |
  		      PSHA                    ;2 E-clk  |
  		      PULA                    ;3 E-clk  |
  		      PSHA                    ;2 E-clk  |
  		      PULA                    ;3 E-clk  |
  		      PSHA                    ;2 E-clk  |
  		      PULA                    ;3 E-clk  | 50us
  		      PSHA                    ;2 E-clk  |
  		      PULA                    ;3 E-clk  |
  		      PSHA                    ;2 E-clk  |
  		      PULA                    ;3 E-clk  |
        		PSHA                    ;2 E-clk  |
        		PULA                    ;3 E-clk  |
        		DBNE  X,iloop           ;3 E-clk -
        		DBNE  Y,eloop           ;3 E-clk
        		PULX                    ;3 E-clk
        		RTS                     ;5 E-clk
******************************************************************
cmd2LCD     BCLR  LCD_CNTR,LCD_RS   ; select the LCD Instruction Register (IR)
            JSR   dataMov           ; send data to IR
      	    RTS
******************************************************************
putcLCD     BSET  LCD_CNTR,LCD_RS   ; select the LCD Data register (DR)
            JSR   dataMov           ; send data to DR
            RTS
******************************************************************
dataMov     BSET  LCD_CNTR,LCD_E    ; pull the LCD E-sigal high
            STAA  LCD_DAT           ; send the upper 4 bits of data to LCD
            BCLR  LCD_CNTR,LCD_E    ; pull the LCD E-signal low to complete the write oper.
            LSLA                    ; match the lower 4 bits with the LCD data pins
            LSLA                    ; -"-
            LSLA                    ; -"-
            LSLA                    ; -"-
            BSET  LCD_CNTR,LCD_E    ; pull the LCD E signal high
            STAA  LCD_DAT           ; send the lower 4 bits of data to LCD
            BCLR  LCD_CNTR,LCD_E    ; pull the LCD E-signal low to complete the write oper.
            LDY   #1                ; adding this delay will complete the internal
            JSR   del_50us          ; operation for most instructions
            RTS
******************************************************************
ENABLE_TOF  LDAA  #%10000000
            STAA  TSCR1             ; Enable TCNT
            STAA  TFLG2             ; Clear TOF
            LDAA  #%10000100        ; Enable TOI and select prescale factor equal to 16
            STAA  TSCR2
            RTS
******************************************************************            
TOF_ISR     INC   TOF_COUNTER
            LDAA  #%10000000        ; Clear
            STAA  TFLG2             ; TOF
            RTI
            
;*****************************************************************
;*                      Interrupt Vectors                        *
;*****************************************************************
            ORG   $FFFE
            DC.W  Entry             ; Reset Vector
            
            ORG   $FFDE
            DC.W  TOF_ISR           ; Timer Overflow Interrupt Vector

