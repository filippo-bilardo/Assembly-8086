# Istruzioni di Trasferimento Dati

## Introduzione

Le istruzioni di trasferimento dati sono le più frequentemente utilizzate in assembly. Permettono di spostare dati tra registri, tra registri e memoria, e di caricare valori immediati. Comprendere perfettamente queste istruzioni è fondamentale per programmare efficacemente.

## MOV - Move

L'istruzione **MOV** è la più usata: copia dati dalla sorgente alla destinazione.

### Sintassi

```assembly
MOV destinazione, sorgente
```

**IMPORTANTE**: La sorgente NON viene modificata (viene copiata, non spostata).

### Operandi Validi

```assembly
; Registro ← Registro
MOV AX, BX          ; AX = BX
MOV AL, BH          ; AL = BH (8 bit)
MOV CX, DX          ; CX = DX

; Registro ← Immediato
MOV AX, 1234h       ; AX = 1234h
MOV BL, 42          ; BL = 42
MOV CX, 0           ; CX = 0

; Registro ← Memoria
MOV AL, [1234h]     ; AL = byte in DS:1234h
MOV BX, [SI]        ; BX = word in DS:SI
MOV CX, variabile   ; CX = valore di variabile

; Memoria ← Registro
MOV [1234h], AL     ; Byte in DS:1234h = AL
MOV [BX], AX        ; Word in DS:BX = AX
MOV variabile, DX   ; variabile = DX

; Memoria ← Immediato
MOV BYTE PTR [BX], 10       ; Byte in DS:BX = 10
MOV WORD PTR [SI], 1234h    ; Word in DS:SI = 1234h
```

### Operandi NON Validi

```assembly
; ❌ ERRORI COMUNI
MOV 1234h, AX           ; Immediato non può essere destinazione
MOV [BX], [SI]          ; Memoria → Memoria non permesso
MOV DS, 1000h           ; Segmento non accetta immediato
MOV AL, BX              ; Dimensioni diverse (8 vs 16 bit)
MOV CS, AX              ; CS non può essere destinazione di MOV
```

### Regole Importanti

1. **Sorgente e destinazione devono avere la stessa dimensione**
2. **Non si può fare MOV memoria-memoria** (serve registro intermedio)
3. **I registri di segmento** (eccetto CS) possono essere destinazione solo da registro
4. **CS non può essere modificato** con MOV

### Effetti sui Flag

**MOV non modifica NESSUN flag** - questo è importante da ricordare!

```assembly
MOV AX, 0           ; AX = 0 ma ZF non cambia!
; Se vuoi impostare ZF, usa:
SUB AX, AX          ; AX = 0 e ZF = 1
; oppure
XOR AX, AX          ; AX = 0 e ZF = 1 (più veloce)
```

### Esempi Pratici

**Esempio 1: Scambio con registro temporaneo**
```assembly
; Scambia AX e BX usando CX come temporaneo
MOV CX, AX          ; CX = AX
MOV AX, BX          ; AX = BX
MOV BX, CX          ; BX = CX (valore originale di AX)
```

**Esempio 2: Copia memoria-memoria**
```assembly
.DATA
    sorgente DW 1234h
    dest DW ?

.CODE
    ; ❌ MOV dest, sorgente    ; ERRORE!
    
    ; ✓ Corretto:
    MOV AX, sorgente
    MOV dest, AX
```

**Esempio 3: Inizializzazione segmento dati**
```assembly
MOV AX, @DATA       ; Carica indirizzo segmento
MOV DS, AX          ; Imposta DS
; Non si può fare: MOV DS, @DATA (immediato)
```

### Ottimizzazioni con MOV

```assembly
; Azzerare un registro
MOV AX, 0           ; 3 byte: B8 00 00
XOR AX, AX          ; 2 byte: 31 C0 (più veloce!)
SUB AX, AX          ; 2 byte: 29 C0

; Impostare a -1
MOV AX, -1          ; 3 byte
MOV AX, 0FFFFh      ; 3 byte (equivalente)
OR AX, -1           ; Alternativa
```

## XCHG - Exchange

Scambia i valori tra due operandi.

### Sintassi

```assembly
XCHG operando1, operando2
```

### Operandi Validi

```assembly
; Registro ↔ Registro
XCHG AX, BX         ; Scambia AX e BX
XCHG AL, BL         ; Scambia AL e BL
XCHG CX, DX         ; Scambia CX e DX

; Registro ↔ Memoria
XCHG AX, variabile  ; Scambia AX con variabile
XCHG [BX], AL       ; Scambia byte in DS:BX con AL
XCHG CL, [SI]       ; Scambia CL con byte in DS:SI

; Memoria ↔ Registro (stesso risultato)
XCHG variabile, AX  ; Equivalente a XCHG AX, variabile
```

### Operandi NON Validi

```assembly
; ❌ ERRORI
XCHG [BX], [SI]     ; Memoria ↔ Memoria non permesso
XCHG 10, AX         ; Immediato non permesso
XCHG DS, AX         ; Segmenti non supportati direttamente
```

### Effetti sui Flag

**XCHG non modifica NESSUN flag**

### Esempi Pratici

**Esempio 1: Scambio semplice**
```assembly
; Invece di:
MOV CX, AX
MOV AX, BX
MOV BX, CX

; Usa:
XCHG AX, BX         ; Una sola istruzione!
```

**Esempio 2: Invertire byte in una word**
```assembly
; AX = 1234h, vogliamo AX = 3412h
MOV AX, 1234h
XCHG AH, AL         ; AX = 3412h
```

**Esempio 3: Scambio array elements**
```assembly
.DATA
    array DB 5, 10, 15, 20

.CODE
    LEA BX, array
    MOV AL, [BX]        ; AL = array[0] = 5
    XCHG AL, [BX+1]     ; Scambia array[0] e array[1]
    MOV [BX], AL        ; array = [10, 5, 15, 20]
```

### Ottimizzazione

```assembly
; XCHG AX, reg è codificato in 1 byte (velocissimo!)
XCHG AX, BX         ; 1 byte: 93
XCHG AX, CX         ; 1 byte: 91
XCHG AX, DX         ; 1 byte: 92

; Altri XCHG sono 2+ byte
XCHG BX, CX         ; 2 byte: 87 CB
```

## LEA - Load Effective Address

Carica l'**indirizzo effettivo** (offset) nella destinazione, senza accedere alla memoria.

### Sintassi

```assembly
LEA registro, memoria
```

### Differenza tra LEA e MOV OFFSET

```assembly
.DATA
    variabile DW 1234h

.CODE
    ; LEA: carica l'INDIRIZZO
    LEA BX, variabile       ; BX = offset di variabile
    
    ; MOV OFFSET: stesso risultato (solo MASM/TASM)
    MOV BX, OFFSET variabile    ; BX = offset di variabile
    
    ; MOV: carica il VALORE
    MOV BX, variabile       ; BX = 1234h (CONTENUTO)
    MOV BX, [variabile]     ; BX = 1234h (equivalente)
```

### Calcolo di Indirizzi

LEA è potente perché può **calcolare indirizzi complessi**:

```assembly
; Carica indirizzo base + offset
LEA BX, [SI+10]         ; BX = SI + 10

; Indirizzamento basato indicizzato
LEA DI, [BX+SI]         ; DI = BX + SI
LEA AX, [BX+SI+20]      ; AX = BX + SI + 20

; Calcolo senza accesso memoria
LEA CX, [BX+DI+100]     ; CX = BX + DI + 100
```

### Uso come Calcolo Aritmetico

LEA può sostituire multiple istruzioni aritmetiche:

```assembly
; Calcolare AX = BX + SI + 10
; Metodo tradizionale:
MOV AX, BX
ADD AX, SI
ADD AX, 10              ; 3 istruzioni

; Con LEA:
LEA AX, [BX+SI+10]      ; 1 istruzione (più veloce!)

; Moltiplicazioni veloci
; AX = BX * 2
LEA AX, [BX+BX]         ; Invece di ADD AX, AX

; AX = BX * 3
LEA AX, [BX+BX*2]       ; BX + (BX × 2) = BX × 3

; AX = BX * 5
LEA AX, [BX+BX*4]       ; BX + (BX × 4) = BX × 5
```

### Esempi Pratici

**Esempio 1: Array indexing**
```assembly
.DATA
    array DW 100 DUP(?)

.CODE
    ; Accesso a array[5]
    LEA BX, array
    MOV SI, 5
    SHL SI, 1           ; SI = 5 × 2 (word = 2 byte)
    LEA DI, [BX+SI]     ; DI = indirizzo di array[5]
    MOV AX, [DI]        ; AX = array[5]
```

**Esempio 2: Strutture**
```assembly
; Struttura Persona (23 byte)
; Offset 0: nome (20 byte)
; Offset 20: età (1 byte)
; Offset 21: salario (2 byte)

.DATA
    persone DB 100 DUP(23 DUP(?))

.CODE
    ; Accesso a persone[3].salario
    LEA BX, persone
    MOV AX, 3           ; Indice
    MOV CX, 23          ; Dimensione struttura
    MUL CX              ; AX = 3 × 23 = 69
    ADD BX, AX          ; BX = base + offset struttura
    LEA SI, [BX+21]     ; SI = indirizzo campo salario
    MOV AX, [SI]        ; AX = salario
```

### Effetti sui Flag

**LEA non modifica NESSUN flag** (non accede alla memoria, solo calcola)

## PUSH - Push onto Stack

Inserisce un valore nello stack.

### Sintassi

```assembly
PUSH operando
```

### Funzionamento

```
1. SP = SP - 2
2. [SS:SP] = operando
```

Lo stack **cresce verso il basso** (indirizzi decrescenti).

### Operandi Validi

```assembly
; Registro a 16 bit
PUSH AX
PUSH BX
PUSH SI
PUSH DS         ; Anche registri di segmento

; Memoria (word)
PUSH variabile
PUSH [BX]
PUSH WORD PTR [SI]
```

### Operandi NON Validi

```assembly
; ❌ ERRORI
PUSH AL         ; No registri 8-bit
PUSH 1234h      ; No immediati (solo su 80186+)
PUSH [AL]       ; Operando non valido
```

### Effetti sui Flag

**PUSH non modifica NESSUN flag**

### Esempi Pratici

**Esempio 1: Salvataggio registri**
```assembly
procedura PROC
    PUSH AX         ; Salva AX
    PUSH BX         ; Salva BX
    PUSH CX         ; Salva CX
    
    ; ... usa AX, BX, CX ...
    
    POP CX          ; Ripristina (ordine inverso!)
    POP BX
    POP AX
    RET
procedura ENDP
```

**Esempio 2: Passaggio parametri**
```assembly
; Chiamante
PUSH 10         ; Secondo parametro (su 80186+)
PUSH 20         ; Primo parametro
CALL somma

; Procedura
somma PROC
    PUSH BP
    MOV BP, SP
    MOV AX, [BP+4]  ; Primo parametro (20)
    ADD AX, [BP+6]  ; Secondo parametro (10)
    POP BP
    RET 4           ; Pulisce stack (2 parametri × 2 byte)
somma ENDP
```

**Esempio 3: Stack frame**
```assembly
Stack dopo PUSH BP e MOV BP, SP:

    ┌──────────┐
    │ Param 2  │ ← [BP+6]
    ├──────────┤
    │ Param 1  │ ← [BP+4]
    ├──────────┤
    │ Ret Addr │ ← [BP+2]
    ├──────────┤
    │ Old BP   │ ← [BP]
    ├──────────┤
    │ Local 1  │ ← [BP-2]
    ├──────────┤
    │ Local 2  │ ← [BP-4]
    └──────────┘ ← SP
```

## POP - Pop from Stack

Estrae un valore dallo stack.

### Sintassi

```assembly
POP operando
```

### Funzionamento

```
1. operando = [SS:SP]
2. SP = SP + 2
```

### Operandi Validi

```assembly
; Registro a 16 bit
POP AX
POP BX
POP DS          ; Anche registri di segmento

; Memoria (word)
POP variabile
POP [BX]
POP WORD PTR [SI]
```

### Operandi NON Validi

```assembly
; ❌ ERRORI
POP AL          ; No registri 8-bit
POP CS          ; CS non può essere destinazione
```

### Effetti sui Flag

**POP non modifica NESSUN flag** (eccetto POPF che ripristina FLAGS)

### Regola d'Oro

**L'ordine dei POP deve essere INVERSO rispetto ai PUSH!**

```assembly
PUSH AX
PUSH BX
PUSH CX

POP CX          ; ✓ Corretto (inverso)
POP BX
POP AX

; Se fai:
; POP AX        ; ✗ ERRORE! AX = valore di CX
; POP BX        ; BX = valore di BX (corretto per caso)
; POP CX        ; CX = valore di AX (sbagliato!)
```

### Esempio: Bilanciamento Stack

```assembly
procedura PROC
    PUSH AX         ; SP = SP - 2
    PUSH BX         ; SP = SP - 2
    PUSH CX         ; SP = SP - 2
    
    ; ... codice ...
    
    ; Devi fare 3 POP o SP sarà sbagliato!
    POP CX          ; SP = SP + 2
    POP BX          ; SP = SP + 2
    POP AX          ; SP = SP + 2
    RET
procedura ENDP
```

## PUSHF / POPF - Push/Pop Flags

Salvano e ripristinano il registro FLAGS.

### Sintassi

```assembly
PUSHF           ; Salva FLAGS nello stack
POPF            ; Ripristina FLAGS dallo stack
```

### Uso Tipico

```assembly
procedura PROC
    PUSHF           ; Salva stato flag
    
    ; ... operazioni che modificano flag ...
    ADD AX, BX
    CMP CX, DX
    
    POPF            ; Ripristina flag originali
    RET
procedura ENDP
```

### Applicazione: Preservare Risultati Confronti

```assembly
; Vogliamo preservare il risultato di un CMP

CMP AX, BX      ; Imposta flag in base a AX vs BX
PUSHF           ; Salva i flag

; ... altre operazioni che modificano flag ...
ADD CX, DX      ; Modifica CF, ZF, OF, ecc.
MOV SI, 100

POPF            ; Ripristina flag del CMP
JE uguale       ; Salta basandosi sul CMP originale
```

## XLATB - Translate Byte

Traduce un byte usando una tabella.

### Sintassi

```assembly
XLATB           ; o XLAT
```

### Funzionamento

```
AL = [DS:BX + AL]
```

1. Usa AL come **indice** nella tabella
2. BX punta alla **base** della tabella
3. Risultato in AL

### Esempio: Conversione Maiuscole/Minuscole

```assembly
.DATA
    ; Tabella per convertire cifre esadecimali in ASCII
    hex_tabella DB '0123456789ABCDEF'

.CODE
    ; Converti 10 (0Ah) in 'A'
    MOV AL, 10          ; Valore da convertire
    LEA BX, hex_tabella ; Base tabella
    XLATB               ; AL = hex_tabella[10] = 'A'
    
    ; Ora AL = 'A' (41h)
```

### Esempio: Tabella Lookup

```assembly
.DATA
    ; Tabella conversione ASCII numeri in valori
    digit_table DB 0, 1, 2, 3, 4, 5, 6, 7, 8, 9

.CODE
    ; Converti '5' (35h) in 5
    MOV AL, '5'         ; AL = 35h
    SUB AL, '0'         ; AL = 5 (indice)
    LEA BX, digit_table
    XLATB               ; AL = digit_table[5] = 5
```

## LDS / LES - Load Pointer to DS/ES

Caricano un puntatore FAR (segmento:offset) in una coppia di registri.

### Sintassi

```assembly
LDS registro, memoria   ; registro:DS ← [memoria]
LES registro, memoria   ; registro:ES ← [memoria]
```

### Funzionamento

**LDS** carica:
- Registro ← offset (primi 2 byte)
- DS ← segmento (successivi 2 byte)

**LES** carica:
- Registro ← offset
- ES ← segmento

### Esempio

```assembly
.DATA
    ; Puntatore FAR: segmento (2 byte) + offset (2 byte)
    ptr_far DD 12345678h    ; Offset=5678h, Segmento=1234h

.CODE
    LDS SI, ptr_far
    ; SI = 5678h (offset)
    ; DS = 1234h (segmento)
    
    ; Ora DS:SI punta alla locazione 1234:5678

    LES DI, ptr_far
    ; DI = 5678h
    ; ES = 1234h
```

### Uso Tipico: Puntatori a Stringhe FAR

```assembly
.DATA
    stringa DB 'Hello$'
    ptr_stringa DW OFFSET stringa, SEG stringa

.CODE
    LDS SI, ptr_stringa     ; DS:SI punta a stringa
    ; Ora possiamo usare DS:SI per accedere alla stringa
```

## Tabella Riepilogativa

| Istruzione | Operandi           | Effetto                    | Flag |
|------------|--------------------|----------------------------|------|
| MOV        | reg/mem, reg/mem/imm | Copia sorgente → dest    | -    |
| XCHG       | reg/mem, reg/mem   | Scambia operandi          | -    |
| LEA        | reg, mem           | Carica indirizzo effettivo| -    |
| PUSH       | reg/mem            | Inserisce nello stack     | -    |
| POP        | reg/mem            | Estrae dallo stack        | -    |
| PUSHF      | -                  | Salva FLAGS               | -    |
| POPF       | -                  | Ripristina FLAGS          | Tutti|
| XLATB      | -                  | AL = [BX+AL]              | -    |
| LDS        | reg, mem32         | reg:DS ← puntatore FAR    | -    |
| LES        | reg, mem32         | reg:ES ← puntatore FAR    | -    |

## Best Practices

### 1. Usa XOR per Azzerare

```assembly
; ❌ Lento
MOV AX, 0       ; 3 byte

; ✓ Veloce
XOR AX, AX      ; 2 byte, più veloce
```

### 2. LEA per Calcoli

```assembly
; ❌ Multiple istruzioni
MOV AX, BX
ADD AX, SI
ADD AX, 10

; ✓ Una istruzione
LEA AX, [BX+SI+10]
```

### 3. XCHG AX, reg è Velocissimo

```assembly
XCHG AX, BX     ; 1 byte, velocissimo
XCHG BX, CX     ; 2 byte
```

### 4. Bilancia Sempre PUSH/POP

```assembly
PUSH AX
PUSH BX
; ... codice ...
POP BX          ; Ordine inverso!
POP AX
```

### 5. MOV non Imposta Flag

```assembly
MOV AX, 0       ; ZF non cambiato
XOR AX, AX      ; ZF = 1
SUB AX, AX      ; ZF = 1
```

## Esercizi Pratici

1. Scrivi codice per scambiare tre variabili: A, B, C → B, C, A
2. Usa LEA per calcolare AX = (BX × 3) + SI + 20
3. Crea una procedura che salva e ripristina tutti i registri generali
4. Implementa conversione cifra decimale → esadecimale con XLATB
5. Scrivi codice per invertire l'ordine dei byte in una word (byte swapping)

### Soluzione Esercizio 2

```assembly
; AX = (BX × 3) + SI + 20
LEA AX, [BX+BX*2+SI+20]     ; BX + BX×2 = BX×3, poi +SI+20
```

---

**Prossimo argomento:** [Istruzioni Aritmetiche](modulo3_02_istruzioni_aritmetiche.md)
