# Modalità di Indirizzamento nell'8086

## Introduzione

Le **modalità di indirizzamento** determinano come il processore accede agli operandi delle istruzioni. L'8086 supporta diverse modalità di indirizzamento, ognuna ottimizzata per situazioni specifiche. Comprendere queste modalità è fondamentale per scrivere codice assembly efficiente ed espressivo.

## Classificazione delle Modalità di Indirizzamento

L'8086 supporta le seguenti modalità di indirizzamento:

```
1. Indirizzamento Immediato (Immediate)
2. Indirizzamento a Registro (Register)
3. Indirizzamento Diretto (Direct)
4. Indirizzamento Indiretto a Registro (Register Indirect)
5. Indirizzamento Indicizzato (Indexed)
6. Indirizzamento Basato (Based)
7. Indirizzamento Basato Indicizzato (Based Indexed)
8. Indirizzamento Relativo (Relative)
```

## 1. Indirizzamento Immediato

L'operando è una **costante** inclusa direttamente nell'istruzione.

### Sintassi
```assembly
MOV destinazione, valore_immediato
```

### Caratteristiche
- Il valore è parte del codice macchina
- Molto veloce (nessun accesso alla memoria)
- L'operando immediato può essere solo la sorgente, mai la destinazione
- Dimensione: 8 o 16 bit

### Esempi
```assembly
MOV AL, 25          ; AL = 25 (decimale)
MOV BX, 1234h       ; BX = 1234h (esadecimale)
MOV CX, 0           ; CX = 0
ADD AX, 100         ; AX = AX + 100
SUB DX, 0FFh        ; DX = DX - 255
AND AL, 0Fh         ; Maschera i 4 bit superiori
OR BL, 80h          ; Imposta il bit 7
```

### Rappresentazione in Memoria
```
Istruzione: MOV AX, 1234h
Codice macchina: B8 34 12
                 │  └─┴─ Valore immediato (little-endian)
                 └─ Opcode (B8 = MOV AX, imm16)
```

### Uso Tipico
- Inizializzazione di variabili
- Caricamento di costanti
- Impostazione di contatori
- Operazioni con valori fissi

## 2. Indirizzamento a Registro

L'operando è contenuto in un **registro del processore**.

### Sintassi
```assembly
MOV registro_dest, registro_sorg
```

### Caratteristiche
- Modalità più veloce (nessun accesso alla memoria)
- Entrambi gli operandi possono essere registri
- Registri devono avere la stessa dimensione

### Esempi
```assembly
MOV AX, BX          ; AX = BX
MOV CL, DH          ; CL = DH
ADD SI, DI          ; SI = SI + DI
SUB AL, BL          ; AL = AL - BL
XCHG AX, DX         ; Scambia AX e DX
```

### Combinazioni Valide
```assembly
; 16 bit con 16 bit
MOV AX, BX          ; ✓ Valido
MOV SI, CX          ; ✓ Valido

; 8 bit con 8 bit
MOV AL, BH          ; ✓ Valido
MOV CL, DL          ; ✓ Valido

; Dimensioni diverse
MOV AX, BL          ; ✗ ERRORE!
MOV AL, BX          ; ✗ ERRORE!
```

### Uso Tipico
- Trasferimento veloce di dati
- Operazioni aritmetiche e logiche
- Preservazione temporanea di valori

## 3. Indirizzamento Diretto

L'operando è in memoria a un **indirizzo specifico** (offset).

### Sintassi
```assembly
MOV registro, [offset]
MOV [offset], registro
```

### Caratteristiche
- L'offset è hardcoded nell'istruzione
- Usa il segmento DS per default (modificabile con segment override)
- L'indirizzo fisico è DS:offset

### Esempi
```assembly
MOV AL, [1234h]     ; AL = byte in DS:1234h
MOV [5678h], BX     ; Word in DS:5678h = BX
MOV AX, [WORD PTR var]  ; AX = contenuto di var

; Con segment override
MOV AL, ES:[1000h]  ; AL = byte in ES:1000h
MOV BX, SS:[2000h]  ; BX = word in SS:2000h
```

### Dichiarazione di Variabili
```assembly
.DATA
    byte_var    DB 42           ; Byte
    word_var    DW 1234h        ; Word
    array       DB 10, 20, 30   ; Array

.CODE
    MOV AL, byte_var            ; AL = 42
    MOV BX, word_var            ; BX = 1234h
    MOV CL, array               ; CL = 10 (primo elemento)
```

### Indirizzamento Fisico
```
Se DS = 2000h e offset = 1234h:
Indirizzo fisico = 2000h × 10h + 1234h = 21234h
```

### Uso Tipico
- Accesso a variabili globali
- Lettura/scrittura di dati a indirizzi noti
- Configurazione di hardware a indirizzi fissi

## 4. Indirizzamento Indiretto a Registro

L'operando è in memoria all'indirizzo contenuto in un **registro**.

### Sintassi
```assembly
MOV registro, [BX]
MOV registro, [SI]
MOV registro, [DI]
MOV registro, [BP]
```

### Caratteristiche
- Solo BX, SI, DI, BP possono essere usati per indirizzamento indiretto
- BX, SI, DI usano DS per default
- BP usa SS per default
- Più flessibile dell'indirizzamento diretto

### Esempi
```assembly
MOV BX, 1000h
MOV AL, [BX]        ; AL = byte in DS:1000h

MOV SI, 2000h
MOV AX, [SI]        ; AX = word in DS:2000h

MOV BP, SP
MOV CX, [BP]        ; CX = word in SS:SP (stack)

; Con segment override
MOV DI, 3000h
MOV BL, ES:[DI]     ; BL = byte in ES:3000h
```

### Registri Validi per Indirizzamento Indiretto
```assembly
; VALIDI
[BX]    ; Base register
[SI]    ; Source index
[DI]    ; Destination index
[BP]    ; Base pointer

; NON VALIDI
[AX]    ; ✗ ERRORE!
[CX]    ; ✗ ERRORE!
[DX]    ; ✗ ERRORE!
[SP]    ; ✗ ERRORE!
```

### Uso Tipico
- Accesso a array (indice variabile)
- Puntatori
- Strutture dati dinamiche
- Passaggio di indirizzi

## 5. Indirizzamento Indicizzato

L'operando è in memoria all'indirizzo ottenuto sommando un **registro indice** (SI o DI) a un **displacement**.

### Sintassi
```assembly
MOV registro, [SI + displacement]
MOV registro, [DI + displacement]
MOV registro, displacement[SI]    ; Sintassi alternativa
```

### Caratteristiche
- Solo SI e DI possono essere usati
- Displacement può essere una costante o un'etichetta
- Utile per accedere a campi di strutture

### Esempi
```assembly
MOV SI, 0
MOV AL, [SI+10]     ; AL = byte in DS:000Ah

MOV DI, 100h
MOV BX, [DI+5]      ; BX = word in DS:0105h

; Accesso a strutture
struc Person
    name    DB 20 DUP(?)
    age     DB ?
    salary  DW ?
ends

MOV SI, OFFSET persona1
MOV AL, [SI+20]     ; Legge age
MOV BX, [SI+21]     ; Legge salary
```

### Sintassi Alternative
```assembly
; Queste tre forme sono equivalenti
MOV AL, [SI+5]
MOV AL, 5[SI]
MOV AL, [SI][5]
```

### Uso Tipico
- Accesso a campi di strutture
- Array con offset fisso
- Buffer circolari

## 6. Indirizzamento Basato

Simile all'indicizzato, ma usa **BX o BP** come registro base.

### Sintassi
```assembly
MOV registro, [BX + displacement]
MOV registro, [BP + displacement]
```

### Caratteristiche
- Solo BX e BP possono essere usati
- BX usa DS, BP usa SS per default
- BP è usato tipicamente per stack frames

### Esempi
```assembly
; Con BX (usa DS)
MOV BX, OFFSET array
MOV AL, [BX+3]      ; Quarto elemento dell'array

; Con BP (usa SS) - accesso a parametri
procedura PROC
    PUSH BP
    MOV BP, SP
    MOV AX, [BP+4]  ; Primo parametro
    MOV BX, [BP+6]  ; Secondo parametro
    POP BP
    RET
procedura ENDP
```

### Stack Frame Tipico
```
Stack:
    ┌──────────────┐
    │ Parametro 2  │ ← [BP+6]
    ├──────────────┤
    │ Parametro 1  │ ← [BP+4]
    ├──────────────┤
    │ Return Addr  │ ← [BP+2]
    ├──────────────┤
    │ Vecchio BP   │ ← [BP]
    ├──────────────┤
    │ Variab. loc. │ ← [BP-2]
    └──────────────┘ ← SP
```

### Uso Tipico
- Accesso a parametri di procedure
- Variabili locali
- Array locali

## 7. Indirizzamento Basato Indicizzato

Combina un **registro base** (BX o BP) con un **registro indice** (SI o DI).

### Sintassi
```assembly
MOV registro, [BX + SI]
MOV registro, [BX + DI]
MOV registro, [BP + SI]
MOV registro, [BP + DI]
```

### Con Displacement
```assembly
MOV registro, [BX + SI + displacement]
MOV registro, [BP + DI + displacement]
```

### Caratteristiche
- Massima flessibilità
- Utile per matrici bidimensionali
- Può includere displacement opzionale

### Esempi
```assembly
; Array bidimensionale
; Indirizzo = base + riga*larghezza + colonna
MOV BX, OFFSET matrice
MOV SI, 0           ; Indice riga (× larghezza)
MOV DI, 2           ; Indice colonna
MOV AL, [BX+SI+DI]  ; Elemento matrice[riga][colonna]

; Array di strutture
MOV BX, OFFSET array_persone
MOV SI, 30          ; Terza persona (offset = 30)
MOV DI, 20          ; Campo age (offset = 20)
MOV AL, [BX+SI+DI]  ; array_persone[2].age
```

### Combinazioni Valide
```assembly
; VALIDE
[BX + SI]
[BX + DI]
[BP + SI]
[BP + DI]

; NON VALIDE
[BX + BP]   ; ✗ Due basi
[SI + DI]   ; ✗ Due indici
[BX + BX]   ; ✗ Stesso registro due volte
```

### Calcolo dell'Indirizzo
```
Indirizzo effettivo = base + indice + displacement

Esempio:
BX = 1000h
SI = 0020h
displacement = 5

[BX + SI + 5] → 1000h + 20h + 5 = 1025h
Indirizzo fisico = DS:1025h
```

### Uso Tipico
- Matrici bidimensionali
- Array di strutture
- Tabelle di lookup complesse

## 8. Indirizzamento Relativo

Usato nelle **istruzioni di salto** per specificare la destinazione relativa all'istruzione corrente.

### Sintassi
```assembly
JMP etichetta
Jcc etichetta       ; cc = condizione (E, NE, G, L, ecc.)
CALL procedura
```

### Caratteristiche
- L'offset è calcolato relativamente a IP
- Salti brevi: -128 a +127 byte
- Salti vicini: -32768 a +32767 byte
- Codice rilocabile

### Esempi
```assembly
        MOV AX, 1
        CMP AX, 1
        JE uguale       ; Salto relativo di pochi byte
        MOV BX, 2
uguale: MOV CX, 3

; Salto incondizionato
        JMP avanti
        MOV DX, 4       ; Questa istruzione viene saltata
avanti: MOV SI, 5
```

### Calcolo del Displacement
```assembly
Posizione corrente (IP): 0100h
Posizione target:        0110h
Displacement = 0110h - 0100h - 2 = 000Eh
(Il -2 è la dimensione dell'istruzione JMP)
```

### Tipi di Salti
```assembly
; Salto breve (SHORT) - 1 byte signed displacement
JMP SHORT vicino    ; -128 a +127 byte

; Salto vicino (NEAR) - 2 byte signed displacement
JMP NEAR lontano    ; -32768 a +32767 byte

; Salto lontano (FAR) - cambia CS:IP
JMP FAR altro_segmento
```

### Uso Tipico
- Implementazione di if-then-else
- Loop
- Chiamate a procedure
- Gestione errori

## Segment Override

È possibile **sovrascrivere** il segmento di default per alcune modalità di indirizzamento.

### Sintassi
```assembly
MOV AL, ES:[BX]     ; Usa ES invece di DS
MOV BX, SS:[SI]     ; Usa SS invece di DS
MOV CX, CS:[DI]     ; Usa CS invece di DS
```

### Segmenti di Default

| Indirizzamento        | Segmento Default | Override Possibile |
|-----------------------|------------------|--------------------|
| [BX]                  | DS               | Sì                 |
| [SI]                  | DS               | Sì                 |
| [DI]                  | DS               | Sì                 |
| [BP]                  | SS               | Sì                 |
| [BX+SI]               | DS               | Sì                 |
| [BX+DI]               | DS               | Sì                 |
| [BP+SI]               | SS               | Sì                 |
| [BP+DI]               | SS               | Sì                 |
| Istruzioni stringa src| DS               | Sì                 |
| Istruzioni stringa dst| ES               | No                 |

### Esempi Pratici
```assembly
; Copia tra segmenti diversi
MOV AX, ES:[BX]     ; Legge da ES
MOV DS:[SI], AX     ; Scrive in DS

; Accesso allo stack con registri non-BP
MOV BX, SP
MOV AX, SS:[BX]     ; Necessario override per BX

; Lettura di codice (self-modifying code - sconsigliato!)
MOV AL, CS:[100h]
```

## Tabella Riassuntiva

| Modalità                  | Sintassi          | Esempio           | Indirizzo Effettivo |
|---------------------------|-------------------|-------------------|---------------------|
| Immediato                 | valore            | MOV AL, 5         | -                   |
| Registro                  | registro          | MOV AX, BX        | -                   |
| Diretto                   | [offset]          | MOV AL, [1000h]   | DS:1000h            |
| Indiretto Registro        | [reg]             | MOV AL, [BX]      | DS:BX               |
| Indicizzato               | [SI+disp]         | MOV AL, [SI+5]    | DS:SI+5             |
| Basato                    | [BX+disp]         | MOV AL, [BX+10]   | DS:BX+10            |
| Basato Indicizzato        | [BX+SI]           | MOV AL, [BX+SI]   | DS:BX+SI            |
| Basato Ind. con Disp.     | [BX+SI+disp]      | MOV AL, [BX+SI+3] | DS:BX+SI+3          |
| Relativo                  | etichetta         | JMP label         | IP+displacement     |

## Ottimizzazione e Best Practices

### Scegli la Modalità Appropriata

```assembly
; Se l'indirizzo è fisso
MOV AL, [1234h]         ; Diretto - semplice e chiaro

; Se l'indirizzo è variabile
MOV BX, indirizzo
MOV AL, [BX]            ; Indiretto - più flessibile

; Se accedi a elementi di array
MOV SI, indice
MOV AL, array[SI]       ; Indicizzato - naturale per array
```

### Evita Calcoli Ridondanti

```assembly
; INEFFICIENTE
MOV AL, [BX+SI+100]
MOV AH, [BX+SI+101]
MOV BL, [BX+SI+102]

; MIGLIORE
LEA DI, [BX+SI+100]
MOV AL, [DI]
MOV AH, [DI+1]
MOV BL, [DI+2]
```

### Usa LEA per Calcoli di Indirizzi

```assembly
; LEA (Load Effective Address) calcola l'indirizzo senza accedere alla memoria
LEA BX, [SI+DI+10]      ; BX = SI + DI + 10
; Equivalente a: MOV BX, SI
;                ADD BX, DI
;                ADD BX, 10
; Ma più veloce!
```

## Esercizi di Verifica

1. Quale indirizzo fisico viene acceduto in `MOV AL, [BX]` se DS=2000h e BX=0100h?

2. Qual è la differenza tra queste due istruzioni?
   ```assembly
   MOV AX, BX
   MOV AX, [BX]
   ```

3. Scrivi un'istruzione per leggere il quinto elemento di un array (indice 4) usando SI.

4. Perché questa istruzione è errata?
   ```assembly
   MOV AL, [AX]
   ```

5. Calcola l'indirizzo effettivo per `MOV AL, [BP+SI+10]` se:
   - SS = 3000h
   - BP = 0100h
   - SI = 0020h

6. Come accederesti al terzo parametro passato nello stack a una procedura?

7. Qual è il vantaggio dell'indirizzamento relativo nei salti?

8. Scrivi codice per accedere all'elemento `matrice[2][3]` di una matrice 5×4 usando indirizzamento basato indicizzato.

---

**Argomento precedente:** [Registri dell'8086](modulo1_02_registri_8086.md)  
**Prossimo argomento:** [Domande di Autovalutazione - Modulo 1](modulo1_04_quiz.md)
