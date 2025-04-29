;Automatic Arm Porject using MTS-86C
 
;Members' names:-

;Ahmed Hazem
;Hussien Hamza
;Yasser Salah
;Mahmoud Abbas
;Morteda Hokman
               

;INITIALIZATION
;PORTA1: 1^ST, 2^ND & 3RD STEPPER                                     
;PORTB1: IR SENSOR INPUT
;PORTC1: DC MOTOR                                      
;PORTA2: SEVENSEGMENT1                                      
;PORTB2; SEVENSEGMENT2

  
;CODE:-
COMMAND1 EQU 0FFFFH
PORTA1 EQU 0FFF9H
PORTB1 EQU 0FFFBH     ;Addresses Define PPI-1
PORTC1 EQU 0FFFDH                                                                       

COMMAND2 EQU 0FFFEH
PORTA2 EQU 0FFF8H
PORTB2 EQU 0FFFAH     ;Addresses Define PPI-2 
PORTC2 EQU 0FFFCH   

;----------------------------------------------------MAIN PORGRAM------------------------------------------------------------   
org 100h                     
CODE    SEGMENT              
    ASSUME CS:CODE,DS:CODE   
                             ;this code initializes the stack pointer to address 2000H
START:  MOV SP,2000H         ;and then sets the data segment register to the same value as the code segment
        MOV AX,CS            ;This is a typical setup for x86 assembly programs.
        MOV DS,AX   
        
MOV DX, COMMAND1
MOV AL , 82H                 ;Initializes PPI-1
OUT DX, AL        

MOV DX, COMMAND2
MOV AL, 80H                  ;Initializes PPI-2
OUT DX , AL        
        
L:        

MOV DX,PORTC1
MOV AL,00H                   ;Turning ON the DC motor
OUT DX,AL

MOV DX , PORTB1
IN_LOOP:
IN  AL , DX                  ;Waiting to detect object
CMP AL , 0FEH
JNZ IN_LOOP

CALL DELAY_DC

MOV DX,PORTC1
MOV AL,01H                   ;Turning OFF the DC motor
OUT DX,AL
                                                       
                                                       
 
;___________________________________________________RUN THE ARM______________________________________________________________


MOV DX,PORTA1  
MOV CX, 120H
MOV AL, 0AH
MOV AH,04H                    ; ROTATE CW - STEPPER 2 DOWN
CALL RCW 
CALL DELAY2
 
MOV CX, 150H                    ; ROTATE CW - STEPPER 3 PICK
CALL RCWS3  
CALL DELAY2
        
MOV CX, 120H
MOV AL,0H                 ; ROTATE CCW - STEPPER 2 UP
CALL RCCW
CALL DELAY2

MOV CX, 250H 
MOV AL,0AH
MOV AH,01H                   ; ROTATE CW - STEPPER 1 RIGHT
CALL RCW
CALL DELAY2


MOV CX, 80H 
MOV AL, 0AH
MOV AH,04H                  ; ROTATE CW - STEPPER 2 DOWN
CALL RCW
CALL DELAY2

MOV CX, 150H                   ; ROTATE CW - STEPPER 3 RELEASE
CALL RCCWS3
CALL DELAY2

MOV CX, 80H 
MOV AL,0H                  ; ROTATE CW - STEPPER 2 UP
CALL RCCW
CALL DELAY2

MOV CX, 250H 
MOV AL,0H
MOV AH,01H                  ; ROTATE CW - STEPPER 1 LEFT
CALL RCCW
CALL DELAY2       
          
;-------------------------------------------DISPLAY NUMBER OF ARM ROUNDS---------------- 

INC BX
CALL SEVENSEGMENT1


JMP L
;-------------------------------------------------END MAIN PORGRAM------------------------------------------------------------   

;----------------------------------------------------PROCEDURES---------------------------------------------------------------   


RCW PROC                       
    L1: 
     
    PUSH CX 
    CALL CW                 ; Clock wise - multi steps
    POP CX  
    
    LOOP L1 
    RET
RCW ENDP


CW PROC
    OR AL,AH   
    OUT DX , AL                      
    CALL DELAY              ; Clock wise - one step
    XOR AL,AH
    OUT DX,AL
    CALL DELAY  
    RET
CW ENDP

RCWS3 PROC                       
    L2: 
     
    PUSH CX 
    CALL CW3                 ; Clock wise - multi steps
    POP CX  
    
    LOOP L2 
    RET
RCWS3 ENDP


CWS3 PROC
    MOV AL,10H    
    OUT DX , AL                      
    CALL DELAY
    MOV AL,20H    
    OUT DX , AL                                                                                                                                             
    CALL DELAY
    MOV AL,40H 
    OUT DX , AL
    CALL DELAY
    MOV AL,80H    
    OUT DX , AL
    CALL DELAY              ; Clock wise - one step 
    RET
CWS3 ENDP

PROC RCCWS3
    L3: 
     
    PUSH CX
    CALL CCW3                ; Counter clock wise - multi steps
    POP CX  
    
    LOOP L3 
    RET 
RCCWS3 ENDP


CCWS3 PROC
    MOV AL,80H    
    OUT DX , AL                      
    CALL DELAY
    MOV AL,40H    
    OUT DX , AL
    CALL DELAY
    MOV AL,20H
    OUT DX , AL
    CALL DELAY
    MOV AL,10H    
    OUT DX , AL              ; Counter clock wise - one step 
    CALL DELAY
    RET
CCWS3 ENDP


PROC RCCW
    L3: 
     
    PUSH CX
    CALL CCW                ; Counter clock wise - multi steps
    POP CX  
    
    LOOP L3 
    RET 
RCCW ENDP


CCW PROC
    OR AL,AH
    OUT DX , AL 
    CALL DELAY              ; Counter clock wise - one step
    XOR AL,AH
    OUT DX,AL
    CALL DELAY
    RET
CCW ENDP


;-------------SEVENSEGMENTS---------------------- 
   
SEVENSEGMENT1 PROC          ;TURN ON FIRST SEVEN SEGMENT
CMP BX , 09H
JA SEVENSEGMENT2 
PUSH DX
MOV DX , PORTA2
MOV SI, OFFSET sevensegment
MOV AL, [BX+SI]
OUT DX , AL
POP DX
RET
SEVENSEGMENT1 ENDP


SEVENSEGMENT2 PROC    ;TURN ON SECOND SEVEN SEGMENT
CMP BP , 09H
JA RESETSEVENSEGMENT
MOV BX,0H
CALL SEVENSEGMENT1
INC BP 
PUSH DX
MOV DX , PORTB2
MOV SI, OFFSET sevensegment
MOV AL, [BP+SI]
OUT DX , AL
POP DX
RET
SEVENSEGMENT2 ENDP

RESETSEVENSEGMENT PROC  ;RESET SEVEN SEGMENT 
MOV BX , 0H
MOV BP , 0H
JMP SEVENSEGMENT1
RESETSEVENSEGMENT ENDP

sevensegment: DB 00111111B , 00000110B , 01011011B , 01001111B , 01100110B , 01101101B , 01111101B , 00000111B , 01111111B , 01101111B

;--------------Delay procedures------------------


DELAY PROC NEAR USES CX
MOV CX , 300
D1:
LOOP D1
RET
DELAY ENDP 


DELAY2 PROC NEAR USES CX
MOV CX , 50
D:  
PUSH CX
MOV CX,2000
    D2:
    LOOP D2
POP CX
LOOP D
RET
DELAY2 ENDP


DELAY_DC PROC NEAR USES CX
MOV CX , 0FFFFH
D_DC:
LOOP D_DC
RET
DELAY_DC ENDP


;End code
