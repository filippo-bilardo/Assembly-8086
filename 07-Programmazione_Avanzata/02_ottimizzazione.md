# Ottimizzazione Codice Assembly

## Introduzione

L'**ottimizzazione** mira a migliorare:
- **Velocità** (cicli CPU, throughput)
- **Dimensione** codice (footprint)
- **Consumo** memoria

Questo modulo esplora tecniche di ottimizzazione per Assembly 8086.

## Principi Generali

### Gerarchia Ottimizzazione

1. **Algoritmo**: scegli algoritmo efficiente O(n log n) vs O(n²)
2. **Strutture dati**: array vs lista, hash table
3. **Micro-ottimizzazioni**: istruzioni, registri, cache

**Regola 80/20**: 80% tempo in 20% codice → ottimizza hotspot!

### Profilazione

**Identifica bottleneck prima di ottimizzare!**

Tecniche:
- **Timer**: misura tempo esecuzione sezioni
- **Contatori**: conta iterazioni loop
- **Profiler**: Turbo Profiler, altri tool

## Ottimizzazioni Istruzioni

### 1. Usa Istruzioni Veloci

| Lento | Veloce | Cicli Risparmiati |
|-------|--------|-------------------|
| `MOV AX, 0` | `XOR AX, AX` | ~1-2 |
| `MOV AX, 1` | `XOR AX, AX` + `INC AX` | ~1 |
| `IMUL AX, 2` | `SHL AX, 1` | ~10-15 |
| `IDIV BX` (÷2) | `SAR AX, 1` | ~20+ |
| `ADD AX, AX` | `SHL AX, 1` | 0 (stessa velocità) |

**Esempio**:
```assembly
✗ Lento:
    MOV AX, 0           ; 4 cicli
    MOV BX, 0
    MOV CX, 0

✓ Veloce:
    XOR AX, AX          ; 3 cicli
    XOR BX, BX
    XOR CX, CX
```

### 2. Shift per Moltiplicazione/Divisione

**Moltiplicazione per potenze di 2**:
```assembly
✗ Lento:
    MOV AX, value
    MOV BX, 8
    IMUL BX             ; ~13-21 cicli (8086)

✓ Veloce:
    MOV AX, value
    SHL AX, 3           ; ×8, ~2 cicli
```

**Divisione per potenze di 2**:
```assembly
✗ Lento:
    MOV AX, value
    MOV BX, 4
    XOR DX, DX
    IDIV BX             ; ~20-30 cicli

✓ Veloce:
    MOV AX, value
    SAR AX, 2           ; ÷4 (signed), ~2 cicli
```

### 3. Incremento/Decremento

```assembly
✓ Preferibile:
    INC AX              ; 2 cicli, 1 byte
    DEC BX

✗ Evitabile:
    ADD AX, 1           ; 4 cicli, 3 byte
    SUB BX, 1
```

**Eccezione**: `INC/DEC` non aggiorna Carry Flag!

```assembly
; Serve CF?
    ADD AX, 1           ; Aggiorna CF
    ADC DX, 0           ; Propaga carry

; Non serve CF?
    INC AX              ; Più veloce, ma CF immutato
```

### 4. Test vs CMP

**Test bit/zero**:
```assembly
✗ Lento:
    CMP AX, 0
    JE zero

✓ Veloce:
    OR AX, AX           ; o TEST AX, AX
    JZ zero
```

**Test singolo bit**:
```assembly
✗ Lento:
    MOV AX, flags
    AND AX, 0001h
    CMP AX, 0
    JE bit_clear

✓ Veloce:
    TEST flags, 0001h
    JZ bit_clear
```

### 5. LEA per Calcoli

**LEA** (Load Effective Address) calcola indirizzi, ma può fare aritmetica!

```assembly
✓ Efficiente:
    LEA BX, [SI+DI]     ; BX = SI + DI
    LEA AX, [BX+SI+10]  ; AX = BX + SI + 10

✗ Alternativa più lenta:
    MOV BX, SI
    ADD BX, DI

; Moltiplicazione per 3, 5, 9:
    LEA AX, [BX+BX*2]   ; AX = BX × 3
    LEA AX, [BX+BX*4]   ; AX = BX × 5
    LEA AX, [BX+BX*8]   ; AX = BX × 9
```

**Attenzione**: LEA non aggiorna flags!

## Ottimizzazioni Loop

### 1. Loop Unrolling

**Espandi loop** per ridurre overhead iterazioni.

```assembly
✗ Originale:
    MOV CX, 4
clear_loop:
    MOV [BX], 0
    INC BX
    INC BX
    LOOP clear_loop         ; Overhead: DEC CX, JNZ

✓ Unrolled:
    MOV WORD PTR [BX], 0
    MOV WORD PTR [BX+2], 0
    MOV WORD PTR [BX+4], 0
    MOV WORD PTR [BX+6], 0
    ; Nessun loop!
```

**Parziale Unrolling** (loop grande):
```assembly
✗ Originale (1000 iterazioni):
    MOV CX, 1000
loop1:
    ; 1 operazione
    LOOP loop1              ; 1000× LOOP

✓ Unrolled 4×:
    MOV CX, 250             ; 1000 ÷ 4
loop2:
    ; 4 operazioni (unroll)
    ; ...
    LOOP loop2              ; 250× LOOP (75% overhead risparmiato)
```

### 2. Ottimizza Condizione Loop

```assembly
✗ Count-up (lento):
    XOR SI, SI
loop_up:
    ; ... usa SI ...
    INC SI
    CMP SI, 100
    JL loop_up

✓ Count-down (veloce):
    MOV CX, 100
loop_down:
    ; ... usa CX-1 o adatta ...
    LOOP loop_down          ; DEC CX + JNZ integrati
```

### 3. Hoisting (Sposta Fuori Loop)

**Calcoli invarianti** → fuori loop!

```assembly
✗ Calcolo ripetuto:
loop1:
    MOV AX, base
    ADD AX, offset          ; Invariante!
    MOV [BX], AX
    INC BX
    INC BX
    LOOP loop1

✓ Hoisted:
    MOV AX, base
    ADD AX, offset          ; Calcolato 1 volta
loop2:
    MOV [BX], AX
    INC BX
    INC BX
    LOOP loop2
```

### 4. Strength Reduction

**Sostituisci operazioni costose con equivalenti veloci**.

```assembly
✗ Moltiplicazione in loop:
    XOR SI, SI
    MOV CX, 100
loop1:
    MOV AX, SI
    MOV BX, 5
    MUL BX                  ; AX = SI × 5 (lento!)
    ; ... usa AX ...
    INC SI
    LOOP loop1

✓ Addizione incrementale:
    XOR AX, AX              ; AX = 0
    MOV CX, 100
loop2:
    ; ... usa AX (già = SI × 5) ...
    ADD AX, 5               ; Incremento (veloce!)
    LOOP loop2
```

## Ottimizzazioni Registri

### 1. Riuso Registri

**Variabili frequenti** → registri, non memoria.

```assembly
✗ Memoria:
sum_array PROC
    XOR AX, AX              ; sum
sum_loop:
    ADD AX, [SI]
    MOV sum, AX             ; Salva in memoria
    INC SI
    INC SI
    MOV AX, sum             ; Ricarica (lento!)
    LOOP sum_loop
    RET

sum DW ?
sum_array ENDP

✓ Registro:
sum_array2 PROC
    XOR AX, AX              ; sum in AX
sum_loop2:
    ADD AX, [SI]
    INC SI
    INC SI
    LOOP sum_loop2
    ; AX = risultato
    RET
sum_array2 ENDP
```

### 2. Register Allocation

**Mappa variabili → registri**:
- **AX**: accumulator, risultati temporanei
- **BX**: base pointer, indice
- **CX**: contatore loop
- **DX**: estensione AX (DX:AX), I/O
- **SI/DI**: puntatori, stringhe
- **BP**: stack frame

**Esempio**:
```c
// C
int sum = 0;
for (int i = 0; i < n; i++) {
    sum += array[i];
}
```

```assembly
; Mapping: sum→AX, i→CX, array→SI, n→DX
    XOR AX, AX              ; sum = 0
    MOV CX, DX              ; i = 0..n (countdown)
    ; SI già punta array
loop1:
    ADD AX, [SI]
    INC SI
    INC SI
    LOOP loop1
    ; AX = sum
```

### 3. Evita Spill (Salvataggio Temporaneo)

```assembly
✗ Spill su stack:
    PUSH AX                 ; Salva AX (non serve dopo)
    ; ... codice che non usa AX ...
    POP AX                  ; Ripristina (inutile!)

✓ Evita:
    ; Non salvare se non necessario
    ; ... codice ...
```

## Ottimizzazioni Memoria

### 1. Accesso Allineato

**8086**: accesso word allineato (indirizzo pari) più veloce.

```assembly
✗ Non allineato:
.DATA
    value DB 0              ; Indirizzo dispari
    word_val DW 1234h       ; Potrebbe essere dispari

✓ Allineato:
.DATA
    EVEN                    ; Forza allineamento pari
    word_val DW 1234h
```

### 2. Localizza Dati

**Località spaziale/temporale**: accessi vicini nel tempo/spazio → cache hit.

```assembly
✗ Sparse:
.DATA
    array1 DW 100 DUP(?)
    temp DW ?               ; Usato spesso con array2
    array2 DW 100 DUP(?)

✓ Raggruppato:
.DATA
    temp DW ?
    array2 DW 100 DUP(?)    ; Vicini in memoria
```

### 3. Usa Istruzioni Stringhe

**MOVS/STOS** più veloci di loop manuale.

```assembly
✗ Loop manuale:
    MOV CX, 100
copy_loop:
    MOV AL, [SI]
    MOV [DI], AL
    INC SI
    INC DI
    LOOP copy_loop

✓ Istruzione stringa:
    MOV CX, 100
    CLD
    REP MOVSB               ; 2× più veloce!
```

## Ottimizzazioni Specifiche

### 1. Tabelle Lookup

**Calcoli complessi** → tabella precalcolata.

**Esempio: sin(x) × 256** (0-90°):
```assembly
.DATA
sin_table DB 0, 4, 9, 13, 18, 22, 27, 31, 36, 40, ...  ; 91 valori

.CODE
get_sin PROC
    ; AL = angolo (0-90)
    ; Ritorna AL = sin(angolo) × 256
    
    LEA BX, sin_table
    XOR AH, AH
    ADD BX, AX
    MOV AL, [BX]
    RET
get_sin ENDP
```

### 2. Jump Tables (Switch)

```assembly
✗ Sequenziale (O(n)):
    CMP AL, 0
    JE case0
    CMP AL, 1
    JE case1
    CMP AL, 2
    JE case2
    ; ...

✓ Jump Table (O(1)):
.DATA
jump_table DW case0, case1, case2, case3

.CODE
    CMP AL, 3               ; Valida range
    JA default_case
    
    XOR AH, AH
    SHL AX, 1               ; × 2 (word)
    LEA BX, jump_table
    ADD BX, AX
    JMP WORD PTR [BX]       ; Jump indiretto
```

### 3. Bit Tricks

**Set/Clear/Toggle bit veloce**:
```assembly
; Set bit 3
    OR flags, 08h           ; Più veloce di shift+or

; Clear bit 5
    AND flags, 0DFh         ; NOT 20h

; Toggle bit 2
    XOR flags, 04h

; Test multipli bit
    TEST flags, 0Ch         ; Bit 2 e 3
    JZ both_clear
```

**Moltiplicazione per 10** (BCD, output decimale):
```assembly
✗ MUL:
    MOV AX, value
    MOV BX, 10
    MUL BX

✓ Shift + ADD:
    MOV AX, value
    MOV BX, AX
    SHL AX, 3               ; × 8
    SHL BX, 1               ; × 2
    ADD AX, BX              ; × 10
```

## Pipeline e Dipendenze (CPU 286+)

### Evita Stall

**Dipendenza dato** → stall pipeline.

```assembly
✗ Stall:
    MOV AX, [SI]
    ADD BX, AX              ; Dipende da AX (stall!)

✓ Riordina:
    MOV CX, [DI]            ; Istruzione indipendente
    MOV AX, [SI]
    ADD BX, AX              ; Meno stall (CX caricato in parallelo)
```

### Interleave Istruzioni

```assembly
✗ Sequenziale:
    MOV AX, [SI]
    ADD AX, 10
    MOV [DI], AX
    
    MOV BX, [SI+2]
    ADD BX, 20
    MOV [DI+2], BX

✓ Interleaved:
    MOV AX, [SI]
    MOV BX, [SI+2]          ; Carica mentre AX elaborato
    ADD AX, 10
    ADD BX, 20
    MOV [DI], AX
    MOV [DI+2], BX
```

## Profiling e Misura

### Timer INT 08h

```assembly
.DATA
    start_tick DW 0
    end_tick DW 0

.CODE
start_timer PROC
    ; Leggi timer tick (0040:006C, 4 byte)
    PUSH ES
    MOV AX, 40h
    MOV ES, AX
    MOV AX, ES:[6Ch]
    MOV start_tick, AX
    POP ES
    RET
start_timer ENDP

end_timer PROC
    PUSH ES
    MOV AX, 40h
    MOV ES, AX
    MOV AX, ES:[6Ch]
    MOV end_tick, AX
    POP ES
    
    ; Calcola elapsed
    MOV AX, end_tick
    SUB AX, start_tick
    ; AX = tick elapsed (~18.2 tick/sec)
    RET
end_timer ENDP
```

### Benchmark Macro

```assembly
BENCHMARK MACRO label, iterations
    LOCAL loop_start
    
    CALL start_timer
    
    MOV CX, iterations
loop_start:
    ; Codice da testare
    PUSH CX
    label
    POP CX
    LOOP loop_start
    
    CALL end_timer
    ; Stampa risultato
ENDM
```

## Best Practices

### 1. Misura Sempre

```assembly
✓ Prima ottimizza:
    BENCHMARK my_func, 10000
    ; Nota: 523 tick

✓ Dopo ottimizza:
    BENCHMARK my_func_opt, 10000
    ; Nota: 312 tick (40% più veloce!)
```

### 2. Ottimizza Hotspot

```assembly
✓ 80/20:
    ; Ottimizza loop interno (80% tempo)
    
✗ Spreco tempo:
    ; Ottimizza inizializzazione (0.1% tempo)
```

### 3. Leggibilità vs Velocità

```assembly
✓ Bilanciato:
; Commenta ottimizzazioni oscure
    LEA AX, [BX+BX*4]   ; AX = BX × 5 (faster than MUL)

✗ Oscuro:
    LEA AX, [BX+BX*4]   ; Cosa fa?!
```

### 4. Portabilità

```assembly
✓ Documentato:
    ; 386+ only: usa MOVZX
    IFDEF CPU386
        MOVZX EAX, AL
    ELSE
        XOR AH, AH
    ENDIF
```

## Esercizi Pratici

1. Ottimizza funzione `strlen`: confronta loop vs SCASB
2. Implementa `memset` ottimizzato: usa STOSW invece STOSB quando possibile
3. Crea jump table per switch con 10 case
4. Scrivi moltiplicazione per 100 senza MUL (shift + add)
5. Benchmark bubble sort vs quicksort su array 1000 elementi

### Soluzione Esercizio 1

```assembly
; Versione base
strlen_slow PROC
    PUSH SI
    MOV SI, [BP+4]          ; str
    XOR AX, AX
strlen_loop:
    CMP BYTE PTR [SI], 0
    JE strlen_done
    INC SI
    INC AX
    JMP strlen_loop
strlen_done:
    POP SI
    RET
strlen_slow ENDP

; Versione ottimizzata
strlen_fast PROC
    PUSH DI
    MOV DI, [BP+4]          ; str
    MOV CX, 0FFFFh          ; Max length
    XOR AL, AL              ; Cerca 0
    CLD
    REPNE SCASB             ; DI avanza fino 0
    
    MOV AX, 0FFFFh
    SUB AX, CX
    DEC AX                  ; AX = lunghezza
    
    POP DI
    RET
strlen_fast ENDP

; Benchmark: strlen_fast ~3-5× più veloce!
```

---

**Prossimo argomento:** [Coprocessore Matematico 8087](modulo7_03_coprocessore_8087.md)
