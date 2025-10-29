.MODEL SMALL
.STACK 100h
.CODE
main PROC
    MOV CX, 10      ; Conta da 9 a 0 (10 iterazioni)
    MOV DL, '9'     ; Inizia da '9'
    
countdown:
    MOV AH, 02h     ; Stampa carattere
    INT 21h
    
    PUSH DX         ; Salva DL sullo stack
    MOV DL, ' '
    MOV AH, 02h     ; Stampa spazio
    INT 21h
    POP DX          ; Recupera DL
    
    DEC DL          ; Decrementa carattere
    LOOP countdown
    
    MOV AH, 4Ch
    INT 21h
main ENDP
END main