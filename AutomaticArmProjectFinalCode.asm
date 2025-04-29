;Automatic Arm Porject using MTS-86C
 
;Members' names:-

;Ahmed Hazem
;Hussien Hamza
;Yasser Salah
;Mahmoud Abbas
;Morteda Hokman


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

MOV DX,PORTA1
MOV AL,00H                   ;Turning ON the DC motor
OUT DX,AL

MOV DX , PORTB1
IN_LOOP:
IN  AL , DX                  ;Waiting to detect object
CMP AL , 0FEH
JNZ IN_LOOP

CALL DELAY_DC

MOV DX,PORTA1
MOV AL,01H                   ;Turning OFF the DC motor
OUT DX,AL

;___________________________________________________RUN THE ARM______________________________________________________________

MOV DX,PORTA2  
MOV CX, 120H 
MOV BL , 20H
CALL TRANS                   ; ROTATE CW - STEPPER 2 DOWN
CALL RCW 
CALL DELAY2
 
MOV CX, 150H 
MOV BL , 40H
CALL TRANS                   ; ROTATE CW - STEPPER 3 PICK
CALL RCW  
CALL DELAY2
        
MOV CX, 120H 
MOV BL , 20H
CALL TRANS                   ; ROTATE CCW - STEPPER 2 UP
CALL RCCW
CALL DELAY2

MOV CX, 250H 
MOV BL , 10H
CALL TRANS                   ; ROTATE CW - STEPPER 1 RIGHT
CALL RCW
CALL DELAY2


MOV CX, 80H 
MOV BL , 20H
CALL TRANS                  ; ROTATE CW - STEPPER 2 DOWN
CALL RCW
CALL DELAY2

MOV CX, 150H 
MOV BL , 40H
CALL TRANS                  ; ROTATE CW - STEPPER 3 RELEASE
CALL RCCW
CALL DELAY2

MOV CX, 80H 
MOV BL , 20H
CALL TRANS                  ; ROTATE CW - STEPPER 2 UP
CALL RCCW
CALL DELAY2

MOV CX, 250H 
MOV BL , 10H
CALL TRANS                  ; ROTATE CW - STEPPER 1 LEFT
CALL RCCW
CALL DELAY2       
          

JMP L
;-------------------------------------------------END MAIN PORGRAM------------------------------------------------------------   

;----------------------------------------------------PROCEDURES---------------------------------------------------------------   


TRANS PROC
    PUSH DX   
    
    MOV DX,PORTB2           
    MOV AL,BL               ; Select the transistor
    OUT DX,AL
    
    POP DX
RET
TRANS ENDP


RCW PROC
MOV AL,11H                       
    L1: 
     
    PUSH CX 
    CALL CW                 ; Clock wise - multi steps
    POP CX  
    
    LOOP L1 
    RET
RCW ENDP


CW PROC    
    OUT DX , AL                      
    CALL DELAY              ; Clock wise - one step
    ROR AL,1H  
    RET
CW ENDP


PROC RCCW
MOV AL,88H  
    L3: 
     
    PUSH CX
    CALL CCW                ; Counter clock wise - multi steps
    POP CX  
    
    LOOP L3 
    RET 
RCCW ENDP


CCW PROC
    OUT DX , AL 
    CALL DELAY              ; Counter clock wise - one step
    ROL AL,1H
    RET
CCW ENDP


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
