# Coprocessore Matematico 8087

## Introduzione

Il **8087** è un coprocessore floating-point per 8086/8088, aggiunge:
- Aritmetica **floating-point** (IEEE 754)
- Registri a **80 bit** (precisione estesa)
- Istruzioni **trigonometriche**, logaritmiche, esponenziali
- ~100× più veloce di emulazione software

**Successori**: 80287 (286), 80387 (386), integrato in 486+.

## Architettura 8087

### Registri Stack

8 registri **ST(0) - ST(7)** organizzati a **stack**:
- **ST(0)**: top of stack (TOS)
- **ST(1)** - **ST(7)**: elementi sotto

Ogni registro: **80 bit** (10 byte)
- 1 bit: segno
- 15 bit: esponente
- 64 bit: mantissa

### Registri di Controllo

- **Control Word**: arrotondamento, precisione, maschere eccezioni
- **Status Word**: flags (C0-C3), stack pointer, eccezioni
- **Tag Word**: tipo ogni registro (valid, zero, special, empty)

### Formati Dati

| Tipo | Byte | Bit | Range (approx) |
|------|------|-----|----------------|
| Word integer | 2 | 16 | ±32K |
| Short integer | 4 | 32 | ±2.1B |
| Long integer | 8 | 64 | ±9.2E18 |
| Short real | 4 | 32 | ±3.4E38, 7 cifre |
| Long real | 8 | 64 | ±1.7E308, 15 cifre |
| Temp real | 10 | 80 | ±1.2E4932, 19 cifre |
| Packed BCD | 10 | 80 | 18 cifre decimali |

## Istruzioni Base

### Inizializzazione

```assembly
FINIT               ; Inizializza 8087 (reset)
; o
FNINIT              ; No-wait FINIT (non controlla eccezioni)
```

### Caricamento (Load)

```assembly
.DATA
    float32 DD 3.14159      ; Short real (4 byte)
    float64 DQ 2.71828      ; Long real (8 byte)
    int16 DW 100
    int32 DD 1000

.CODE
    FLD float32             ; ST(0) = 3.14159
    FLD float64             ; ST(0) = 2.71828, ST(1) = 3.14159
    
    FILD int16              ; Integer Load: ST(0) = 100
    FILD int32              ; ST(0) = 1000
    
    ; Costanti
    FLD1                    ; ST(0) = 1.0
    FLDZ                    ; ST(0) = 0.0
    FLDPI                   ; ST(0) = π (3.14159...)
    FLDL2E                  ; ST(0) = log₂(e)
    FLDL2T                  ; ST(0) = log₂(10)
    FLDLG2                  ; ST(0) = log₁₀(2)
    FLDLN2                  ; ST(0) = ln(2)
```

### Salvataggio (Store)

```assembly
.DATA
    result32 DD ?
    result64 DQ ?
    result_int DW ?

.CODE
    ; Store (mantiene in stack)
    FST result32            ; result32 = ST(0)
    FST result64
    
    ; Store and Pop
    FSTP result32           ; result32 = ST(0), POP stack
    FSTP result64
    
    ; Integer Store
    FIST result_int         ; Converte ST(0) → intero
    FISTP result_int        ; Store + POP
```

### Aritmetica

```assembly
; Addizione
    FLD a
    FADD b                  ; ST(0) = a + b
    
    FLD a
    FLD b
    FADDP ST(1), ST(0)      ; ST(1) += ST(0), POP
    ; Equivalente: ST(0) = a + b

; Sottrazione
    FLD a
    FSUB b                  ; ST(0) = a - b
    
    FLD a
    FSUB b                  ; ST(0) = a - b
    FSUBR b                 ; ST(0) = b - a (reverse)

; Moltiplicazione
    FLD a
    FMUL b                  ; ST(0) = a × b

; Divisione
    FLD a
    FDIV b                  ; ST(0) = a ÷ b
    FDIVR b                 ; ST(0) = b ÷ a (reverse)
```

### Esempi Pratici

**Calcola (a + b) × c**:
```assembly
.DATA
    a DD 10.5
    b DD 20.3
    c DD 2.0
    result DD ?

.CODE
    FINIT
    
    FLD a                   ; ST(0) = a
    FADD b                  ; ST(0) = a + b
    FMUL c                  ; ST(0) = (a+b) × c
    FSTP result             ; result = ST(0), POP
```

**Calcola √(x² + y²)** (distanza):
```assembly
distance PROC
    ; Parametri: x (float), y (float) su stack
    PUSH BP
    MOV BP, SP
    
    FINIT
    
    FLD DWORD PTR [BP+4]    ; ST(0) = x
    FMUL ST(0), ST(0)       ; ST(0) = x²
    
    FLD DWORD PTR [BP+8]    ; ST(0) = y, ST(1) = x²
    FMUL ST(0), ST(0)       ; ST(0) = y²
    
    FADDP ST(1), ST(0)      ; ST(0) = x² + y²
    FSQRT                   ; ST(0) = √(x² + y²)
    
    ; Risultato in ST(0)
    POP BP
    RET
distance ENDP
```

## Istruzioni Avanzate

### Confronto

```assembly
    FLD a
    FCOMP b                 ; Confronta ST(0) con b, POP
    FSTSW AX                ; Copia Status Word → AX
    SAHF                    ; AX → CPU flags
    JA greater              ; Jump in base a confronto
```

**Flags dopo FCOMP**:

| Relazione | C3 | C2 | C0 |
|-----------|----|----|-----|
| ST(0) > b | 0  | 0  | 0   |
| ST(0) < b | 0  | 0  | 1   |
| ST(0) = b | 1  | 0  | 0   |
| Incomparabile | 1 | 1 | 1 |

**Esempio Completo**:
```assembly
compare_floats PROC
    ; Confronta a e b (float)
    FINIT
    
    FLD a
    FCOMP b                 ; ST(0) vs b
    FSTSW AX                ; Status → AX
    SAHF                    ; AX → CPU flags
    
    JE equal
    JA greater
    JB less
    
equal:
    ; a == b
    RET
    
greater:
    ; a > b
    RET
    
less:
    ; a < b
    RET
compare_floats ENDP
```

### Funzioni Trascendentali

```assembly
; Seno/Coseno
    FLD angle_rad           ; Angolo in radianti
    FSIN                    ; ST(0) = sin(angle)
    
    FLD angle_rad
    FCOS                    ; ST(0) = cos(angle)
    
    FLD angle_rad
    FSINCOS                 ; ST(0) = cos, ST(1) = sin

; Tangente
    FLD angle_rad
    FPTAN                   ; ST(0) = 1, ST(1) = tan(angle)
    FSTP ST(0)              ; Rimuovi 1
    ; ST(0) = tan(angle)

; Arcotangente
    FLD y
    FLD x
    FPATAN                  ; ST(0) = atan2(y, x)

; Radice quadrata
    FLD x
    FSQRT                   ; ST(0) = √x

; Esponenziale (2^x)
    FLD x
    F2XM1                   ; ST(0) = 2^x - 1 (-1 ≤ x ≤ 1)
    FLD1
    FADDP                   ; ST(0) = 2^x

; Logaritmo base 2
    FLD x
    FLD1
    FYL2X                   ; ST(0) = ST(1) × log₂(ST(0))
    ; ST(0) = log₂(x)
```

### Esempio: Calcola e^x

```assembly
exp_func PROC
    ; Calcola e^x
    ; ST(0) = x (input/output)
    
    ; e^x = 2^(x × log₂(e))
    
    FLDL2E                  ; ST(0) = log₂(e), ST(1) = x
    FMULP                   ; ST(0) = x × log₂(e)
    
    ; Split in integer + fraction
    FLD ST(0)               ; Duplica
    FRNDINT                 ; ST(0) = int part
    FSUB ST(1), ST(0)       ; ST(1) = frac part
    FXCH                    ; Scambia ST(0) ↔ ST(1)
    
    ; ST(0) = frac, ST(1) = int
    F2XM1                   ; ST(0) = 2^frac - 1
    FLD1
    FADDP                   ; ST(0) = 2^frac
    FSCALE                  ; ST(0) = 2^frac × 2^int = 2^x
    FSTP ST(1)              ; POP int part
    
    ; ST(0) = e^x
    RET
exp_func ENDP
```

## Gestione Stack

### Manipolazione

```assembly
; Exchange
    FXCH                    ; Scambia ST(0) ↔ ST(1)
    FXCH ST(3)              ; Scambia ST(0) ↔ ST(3)

; Free (marca come empty)
    FFREE ST(2)             ; ST(2) → empty (non POP)

; No-op
    FNOP                    ; Nessuna operazione
```

### Verifica Stack

```assembly
check_stack PROC
    FSTSW AX                ; Status Word → AX
    TEST AH, 40h            ; Bit 14 = stack fault
    JNZ stack_error
    
    ; Stack ok
    RET
    
stack_error:
    ; Stack overflow/underflow
    RET
check_stack ENDP
```

## Virgola Fissa (Alternativa)

**Floating-point** lento senza 8087 → **fixed-point**.

### Concetto

Rappresenta decimali come **interi scalati**.

**Esempio**: 16.16 fixed-point (16 bit int, 16 bit frac)
- 1.0 = 65536 (1 << 16)
- 2.5 = 163840 (2.5 × 65536)
- 0.25 = 16384 (0.25 × 65536)

### Aritmetica Fixed-Point

**Addizione/Sottrazione**: normale!
```assembly
; a + b (16.16 fixed)
    MOV AX, a_low
    MOV DX, a_high
    ADD AX, b_low
    ADC DX, b_high
    ; DX:AX = a + b
```

**Moltiplicazione**: shift dopo MUL
```assembly
; a × b (16.16 fixed)
; Risultato temporaneo: 32.32, shift → 16.16

    MOV AX, a_low
    MOV DX, a_high
    MOV BX, b_low
    MOV CX, b_high
    
    ; MUL a × b (semplificato, usa 32×32→64)
    ; ... complesso, usa library ...
    
    ; Shift right 16 bit per rinormalizzare
    ; DX:AX = risultato 16.16
```

**Divisione**: shift prima DIV
```assembly
; a ÷ b (16.16 fixed)
; Shift a left 16, poi DIV

    MOV AX, a_low
    MOV DX, a_high
    MOV CX, 16
shift_left:
    SHL AX, 1
    RCL DX, 1
    LOOP shift_left
    
    DIV b                   ; DX:AX ÷ b
    ; AX = risultato 16.16
```

### Fixed-Point Library

```assembly
; Macro per 16.16 fixed
FIXED_ONE EQU 65536

FP_MUL MACRO a, b
    ; Moltiplica a × b (16.16)
    ; Usa routine library (complessa)
    PUSH a
    PUSH b
    CALL fp_mul_func
    ADD SP, 4
    ; DX:AX = risultato
ENDM
```

## Emulazione Software

Senza 8087, DOS/BIOS emula FPU via **software**.

**Rilevazione 8087**:
```assembly
detect_8087 PROC
    FINIT                   ; Prova inizializzare
    MOV BYTE PTR [test_val], 0
    FNSTSW [test_val]       ; Salva Status Word
    
    CMP BYTE PTR [test_val], 0
    JNE no_8087             ; Se != 0, non presente
    
    ; 8087 presente
    MOV AL, 1
    RET
    
no_8087:
    ; 8087 assente (emulazione)
    XOR AL, AL
    RET
    
test_val DW ?
detect_8087 ENDP
```

## Best Practices

### 1. Inizializza Sempre

```assembly
✓ Inizio programma:
main PROC
    FINIT                   ; Reset 8087
    ; ... codice ...
main ENDP
```

### 2. Gestisci Eccezioni

```assembly
✓ Controlla errori:
    FLD a
    FDIV b
    
    FSTSW AX
    TEST AH, 01h            ; Invalid operation?
    JNZ division_error
    TEST AH, 04h            ; Division by zero?
    JNZ division_error
```

### 3. Svuota Stack

```assembly
✗ Stack leak:
    FLD a
    FLD b
    ; Dimenticato POP!
    RET                     ; Stack non vuoto!

✓ Pulito:
    FLD a
    FLD b
    FADDP                   ; POP automatico
    FSTP result             ; POP
```

### 4. Usa Costanti

```assembly
✓ Efficiente:
    FLDPI                   ; π caricato direttamente
    FMUL radius

✗ Lento:
    FLD pi_variable         ; Carica da memoria
```

## Esercizi Pratici

1. Scrivi funzione `sin(x)` in gradi (converte rad → gradi)
2. Implementa calcolo interesse composto: `A = P(1 + r)^t`
3. Crea sqrt con Newton-Raphson (senza FSQRT) per confronto
4. Fixed-point: moltiplica due numeri 16.16
5. Benchmark floating-point vs fixed-point per 10000 moltiplicazioni

### Soluzione Esercizio 1

```assembly
sin_degrees PROC
    ; Input: ST(0) = angolo gradi
    ; Output: ST(0) = sin(angolo)
    
    ; Converti gradi → radianti
    FLDPI                   ; ST(0) = π, ST(1) = gradi
    FMUL ST(0), ST(0)       ; ST(0) = π²? NO!
    
    ; Ricomincia
    FLDPI                   ; ST(0) = π
    FLD ST(1)               ; ST(0) = gradi, ST(1) = π, ST(2) = gradi
    FMULP                   ; ST(0) = gradi × π, ST(1) = gradi
    
    FILD DWORD PTR [const_180] ; ST(0) = 180
    FDIVP                   ; ST(0) = (gradi × π) / 180 = radianti
    
    FSIN                    ; ST(0) = sin(radianti)
    
    FSTP ST(1)              ; Rimuovi gradi originali
    RET

const_180 DD 180
sin_degrees ENDP
```

---

**Prossimo argomento:** [Quiz Modulo 7](modulo7_04_quiz.md)
