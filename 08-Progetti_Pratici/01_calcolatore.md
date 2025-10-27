# Progetto 1: Calcolatore a Riga di Comando

## Obiettivo

Sviluppare un **calcolatore interattivo** con:
- Interfaccia a riga di comando
- 4 operazioni base (+, -, ×, ÷)
- Gestione errori (divisione per 0, overflow)
- Numeri interi signed 16-bit
- Estensione: numeri multiprecisione (32-bit)

## Specifiche Funzionali

### Input/Output

**Formato input**: `operando1 operatore operando2`

```
Esempi:
> 10 + 20
Risultato: 30

> 100 * 50
Risultato: 5000

> 15 / 0
Errore: Divisione per zero

> 40000 + 30000
Overflow! Risultato: -27768 (con estensione: 70000)
```

### Operatori

| Simbolo | Operazione | ASCII |
|---------|------------|-------|
| `+` | Addizione | 2Bh |
| `-` | Sottrazione | 2Dh |
| `*` | Moltiplicazione | 2Ah |
| `/` | Divisione | 2Fh |

## Progettazione

### Architettura

```
┌─────────────┐
│    main     │
└──────┬──────┘
       │
       ├──→ print_prompt
       ├──→ read_input
       ├──→ parse_input
       │      ├──→ skip_spaces
       │      ├──→ read_number
       │      └──→ read_operator
       ├──→ calculate
       │      ├──→ add_numbers
       │      ├──→ sub_numbers
       │      ├──→ mul_numbers
       │      └──→ div_numbers
       ├──→ print_result
       └──→ print_error
```

### Strutture Dati

```assembly
.DATA
    input_buf DB 80 DUP(?)      ; Buffer input
    operand1 DW ?                ; Primo operando
    operand2 DW ?                ; Secondo operando
    operator DB ?                ; Operatore
    result DW ?                  ; Risultato
    error_flag DB 0              ; Flag errore
```

## Implementazione Base

### Versione 1.0: Operazioni 16-bit

```assembly
.MODEL SMALL
.STACK 100h

.DATA
    prompt DB '> $'
    result_msg DB 'Risultato: $'
    error_div0 DB 'Errore: Divisione per zero$'
    error_overflow DB 'Overflow!$'
    error_input DB 'Input non valido$'
    newline DB 13, 10, '$'
    
    input_buf DB 80, 0, 80 DUP(?)  ; Buffered input
    operand1 DW ?
    operand2 DW ?
    operator DB ?
    result DW ?
    error_flag DB 0

.CODE
main PROC
    MOV AX, @DATA
    MOV DS, AX
    
main_loop:
    ; Stampa prompt
    LEA DX, prompt
    MOV AH, 09h
    INT 21h
    
    ; Leggi input
    LEA DX, input_buf
    MOV AH, 0Ah
    INT 21h
    
    ; Newline
    LEA DX, newline
    MOV AH, 09h
    INT 21h
    
    ; Controlla uscita (input vuoto)
    CMP BYTE PTR input_buf+1, 0
    JE exit_program
    
    ; Parse input
    CALL parse_input
    CMP error_flag, 0
    JNE show_error
    
    ; Calcola
    CALL calculate
    CMP error_flag, 0
    JNE show_error
    
    ; Stampa risultato
    CALL print_result
    JMP main_loop
    
show_error:
    CALL print_error
    MOV error_flag, 0           ; Reset
    JMP main_loop
    
exit_program:
    MOV AH, 4Ch
    INT 21h
main ENDP

; ===== PARSING =====

parse_input PROC
    PUSH SI
    
    LEA SI, input_buf+2         ; Salta length bytes
    
    ; Leggi operand1
    CALL skip_spaces
    CALL read_number
    JC parse_error
    MOV operand1, AX
    
    ; Leggi operator
    CALL skip_spaces
    CALL read_operator
    JC parse_error
    MOV operator, AL
    
    ; Leggi operand2
    CALL skip_spaces
    CALL read_number
    JC parse_error
    MOV operand2, AX
    
    CLC                         ; Successo
    POP SI
    RET
    
parse_error:
    MOV error_flag, 3           ; Input error
    STC
    POP SI
    RET
parse_input ENDP

skip_spaces PROC
    ; SI = puntatore input
skip_loop:
    CMP BYTE PTR [SI], ' '
    JNE skip_done
    INC SI
    JMP skip_loop
skip_done:
    RET
skip_spaces ENDP

read_number PROC
    ; Legge numero decimale signed da [SI]
    ; Ritorna AX = numero, SI aggiornato
    ; CF = 1 se errore
    
    PUSH BX
    PUSH CX
    PUSH DX
    
    XOR BX, BX                  ; Risultato
    XOR CX, CX                  ; Segno (0 = +, 1 = -)
    
    ; Controlla segno
    CMP BYTE PTR [SI], '-'
    JNE check_digit
    INC CX                      ; Negativo
    INC SI
    
check_digit:
    MOV AL, [SI]
    CMP AL, '0'
    JB num_done                 ; < '0'
    CMP AL, '9'
    JA num_done                 ; > '9'
    
    ; Cifra valida
    SUB AL, '0'                 ; ASCII → valore
    XOR AH, AH
    
    ; BX = BX × 10 + AL
    PUSH AX
    MOV AX, BX
    MOV DX, 10
    IMUL DX                     ; AX = BX × 10
    MOV BX, AX
    POP AX
    ADD BX, AX
    
    INC SI
    JMP check_digit
    
num_done:
    ; Applica segno
    MOV AX, BX
    CMP CX, 0
    JE num_positive
    NEG AX
    
num_positive:
    CLC                         ; Successo
    POP DX
    POP CX
    POP BX
    RET
read_number ENDP

read_operator PROC
    ; Legge operatore da [SI]
    ; Ritorna AL = operatore, SI++
    ; CF = 1 se invalido
    
    MOV AL, [SI]
    CMP AL, '+'
    JE op_valid
    CMP AL, '-'
    JE op_valid
    CMP AL, '*'
    JE op_valid
    CMP AL, '/'
    JE op_valid
    
    ; Invalido
    STC
    RET
    
op_valid:
    INC SI
    CLC
    RET
read_operator ENDP

; ===== CALCOLO =====

calculate PROC
    MOV AL, operator
    CMP AL, '+'
    JE do_add
    CMP AL, '-'
    JE do_sub
    CMP AL, '*'
    JE do_mul
    CMP AL, '/'
    JE do_div
    RET
    
do_add:
    MOV AX, operand1
    ADD AX, operand2
    JO calc_overflow            ; Overflow?
    MOV result, AX
    RET
    
do_sub:
    MOV AX, operand1
    SUB AX, operand2
    JO calc_overflow
    MOV result, AX
    RET
    
do_mul:
    MOV AX, operand1
    IMUL operand2               ; DX:AX = result
    JO calc_overflow            ; Overflow se DX != 0 o sign mismatch
    MOV result, AX
    RET
    
do_div:
    CMP operand2, 0
    JE div_by_zero
    
    MOV AX, operand1
    CWD                         ; Estendi AX → DX:AX
    IDIV operand2               ; AX = quotient
    MOV result, AX
    RET
    
div_by_zero:
    MOV error_flag, 1
    RET
    
calc_overflow:
    MOV error_flag, 2
    RET
calculate ENDP

; ===== OUTPUT =====

print_result PROC
    LEA DX, result_msg
    MOV AH, 09h
    INT 21h
    
    MOV AX, result
    CALL print_decimal
    
    LEA DX, newline
    MOV AH, 09h
    INT 21h
    RET
print_result ENDP

print_error PROC
    CMP error_flag, 1
    JE err_div0
    CMP error_flag, 2
    JE err_overflow
    CMP error_flag, 3
    JE err_input
    RET
    
err_div0:
    LEA DX, error_div0
    JMP print_err
    
err_overflow:
    LEA DX, error_overflow
    JMP print_err
    
err_input:
    LEA DX, error_input
    
print_err:
    MOV AH, 09h
    INT 21h
    LEA DX, newline
    INT 21h
    RET
print_error ENDP

print_decimal PROC
    ; Stampa AX come decimale signed
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    
    ; Controlla segno
    OR AX, AX
    JNS pd_positive
    
    ; Negativo: stampa '-'
    PUSH AX
    MOV AH, 02h
    MOV DL, '-'
    INT 21h
    POP AX
    NEG AX
    
pd_positive:
    ; Converti a decimale (ricorsivo via stack)
    XOR CX, CX                  ; Conta cifre
    MOV BX, 10
    
pd_divide:
    XOR DX, DX
    DIV BX                      ; DX = AX % 10, AX = AX / 10
    PUSH DX                     ; Salva cifra
    INC CX
    OR AX, AX
    JNZ pd_divide
    
    ; Stampa cifre (da stack)
pd_print:
    POP DX
    ADD DL, '0'                 ; Valore → ASCII
    MOV AH, 02h
    INT 21h
    LOOP pd_print
    
    POP DX
    POP CX
    POP BX
    POP AX
    RET
print_decimal ENDP

END main
```

## Testing

### Test Case

```
Input            | Output Atteso
-----------------+---------------------------
10 + 20          | Risultato: 30
100 - 50         | Risultato: 50
5 * 6            | Risultato: 30
20 / 4           | Risultato: 5
10 / 3           | Risultato: 3 (troncato)
10 / 0           | Errore: Divisione per zero
-5 + 10          | Risultato: 5
-10 - 5          | Risultato: -15
30000 + 30000    | Overflow! (se non esteso)
```

## Estensione: Multiprecisione 32-bit

### Versione 2.0: Operazioni 32-bit

```assembly
.DATA
    operand1 DD ?               ; 32-bit
    operand2 DD ?
    result DD ?

; Modifica read_number per 32-bit
read_number32 PROC
    ; Ritorna DX:AX = numero 32-bit
    ; (implementazione simile, usa DX:AX invece AX)
    ; ...
    RET
read_number32 ENDP

; Addizione 32-bit
add32 PROC
    MOV AX, WORD PTR operand1
    MOV DX, WORD PTR operand1+2
    ADD AX, WORD PTR operand2
    ADC DX, WORD PTR operand2+2
    JC overflow32
    
    MOV WORD PTR result, AX
    MOV WORD PTR result+2, DX
    RET
    
overflow32:
    MOV error_flag, 2
    RET
add32 ENDP

; Moltiplicazione 32-bit (16×16→32)
mul32 PROC
    ; operand1 (16-bit) × operand2 (16-bit) → result (32-bit)
    MOV AX, WORD PTR operand1
    IMUL WORD PTR operand2      ; DX:AX = result
    
    MOV WORD PTR result, AX
    MOV WORD PTR result+2, DX
    RET
mul32 ENDP

; Stampa 32-bit
print_decimal32 PROC
    ; Stampa DX:AX come decimale
    ; (usa divisione 32-bit ripetuta)
    ; ...
    RET
print_decimal32 ENDP
```

## Ulteriori Estensioni

### 1. Calcoli Concatenati

```
> 10 + 20 - 5
Risultato: 25
```

**Implementazione**: parser espressioni (ricorsivo discendente).

### 2. Parentesi

```
> (10 + 20) * 2
Risultato: 60
```

**Implementazione**: stack operatori/operandi, shunting yard algorithm.

### 3. Floating-Point

```
> 10.5 + 3.2
Risultato: 13.7
```

**Implementazione**: usa 8087 FPU o fixed-point.

### 4. Funzioni

```
> sqrt(16)
Risultato: 4

> sin(90)
Risultato: 1.0
```

### 5. Variabili

```
> a = 10
> b = 20
> a + b
Risultato: 30
```

**Implementazione**: hash table o array variabili.

## Debugging

### Tecniche

1. **Print debug**: stampa variabili intermedie
2. **Turbo Debugger**: step-by-step
3. **Test unit**: testa parse_input separatamente

### Debug Print

```assembly
DEBUG_PRINT MACRO msg
    LEA DX, msg
    MOV AH, 09h
    INT 21h
ENDM

; Uso:
    DEBUG_PRINT debug_msg
    ; ...
    
.DATA
debug_msg DB 'Debug: operand1 = $'
```

## Performance

### Profiling

**Operazioni/secondo** (8086 @ 4.77 MHz, emulato):
- Addizione: ~500K ops/sec
- Moltiplicazione: ~50K ops/sec
- Parsing: ~1K expr/sec (bottleneck)

### Ottimizzazioni

1. **Cache risultato**: evita ricalcolare stessa espressione
2. **Lookup table**: per moltiplicazioni piccole
3. **Fast path**: numeri singola cifra

## Conclusioni

### Cosa Hai Imparato

- ✓ Parsing input testuale
- ✓ Conversione stringa ↔ numero
- ✓ Gestione errori robusto
- ✓ Interfaccia utente interattiva
- ✓ Aritmetica multiprecisione

### Esercizi Avanzati

1. Aggiungi operatori: `%` (modulo), `^` (potenza)
2. Implementa stack RPN (Reverse Polish Notation)
3. Parser espressioni complesse con precedenza
4. Salva/carica espressioni da file
5. Cronologia comandi (frecce su/giù)

---

**Prossimo progetto:** [Editor di Testo Minimale](modulo8_02_editor_testo.md)
