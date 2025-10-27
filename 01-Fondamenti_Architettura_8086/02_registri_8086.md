# Registri dell'Intel 8086

## Introduzione

I registri sono celle di memoria estremamente veloci situate all'interno del processore. L'8086 dispone di **14 registri** a 16 bit, organizzati in quattro categorie funzionali. La conoscenza approfondita dei registri è fondamentale per programmare efficacemente in assembly.

## Panoramica dei Registri

```
┌─────────────────────────────────────────────────┐
│            REGISTRI INTEL 8086                  │
├─────────────────────────────────────────────────┤
│  REGISTRI GENERALI (General Purpose)            │
│  AX (AH:AL)  BX (BH:BL)  CX (CH:CL)  DX (DH:DL) │
├─────────────────────────────────────────────────┤
│  REGISTRI PUNTATORI E INDICE                    │
│  SP          BP          SI          DI         │
├─────────────────────────────────────────────────┤
│  REGISTRI DI SEGMENTO                           │
│  CS          DS          SS          ES         │
├─────────────────────────────────────────────────┤
│  REGISTRO ISTRUZIONI E FLAG                     │
│  IP                      FLAGS                  │
└─────────────────────────────────────────────────┘
```

## Registri Generali (General Purpose Registers)

I quattro registri generali possono essere utilizzati sia come registri a 16 bit che come coppie di registri a 8 bit.

### AX - Accumulator Register

**Nome completo:** Accumulatore  
**Suddivisione:** AH (high byte) + AL (low byte)

```
   15  14  13  12  11  10   9   8   7   6   5   4   3   2   1   0
  ┌───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┐
  │                   AH                  │         AL            │  AX
  └───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┘
```

**Usi principali:**
- Operazioni aritmetiche e logiche
- Operazioni di I/O (IN, OUT)
- Moltiplicazione e divisione (risultato in AX o DX:AX)
- Conversione tra formati
- Interruzioni DOS/BIOS (parametri e valori di ritorno)

**Esempi:**
```assembly
; Moltiplicazione
MOV AL, 5
MOV BL, 3
MUL BL          ; AX = AL × BL = 15

; Input da porta
IN AL, 60h      ; Legge dalla porta 60h (tastiera)

; Interruzione DOS
MOV AH, 09h     ; Funzione 09h: stampa stringa
INT 21h         ; Chiama DOS
```

### BX - Base Register

**Nome completo:** Registro Base  
**Suddivisione:** BH (high byte) + BL (low byte)

**Usi principali:**
- Indirizzamento indiretto della memoria
- Calcolo degli indirizzi base (da cui il nome)
- Operazioni aritmetiche generali
- Traduzione di indirizzi (tabelle lookup)

**Esempi:**
```assembly
; Indirizzamento indiretto
MOV BX, 1000h
MOV AL, [BX]    ; AL = contenuto di DS:1000h

; Accesso a tabella
MOV BX, OFFSET tabella
ADD BX, indice
MOV AL, [BX]    ; Legge elemento della tabella

; Base + offset
MOV AL, [BX+5]  ; Legge da BX + 5
```

### CX - Count Register

**Nome completo:** Registro Contatore  
**Suddivisione:** CH (high byte) + CL (low byte)

**Usi principali:**
- Contatore per i loop (LOOP, LOOPZ, LOOPNZ)
- Numero di ripetizioni per operazioni su stringhe (REP)
- Numero di bit per shift/rotate (CL come contatore)
- Conteggio generale

**Esempi:**
```assembly
; Loop classico
MOV CX, 10      ; Ripeti 10 volte
ciclo:
    ; ... codice ...
    LOOP ciclo  ; Decrementa CX e salta se CX ≠ 0

; Operazioni su stringhe
MOV CX, 100     ; Copia 100 byte
REP MOVSB       ; Ripeti MOVSB per CX volte

; Shift multiplo
MOV CL, 4       ; Numero di shift
SHL AX, CL      ; Shift AX di 4 posizioni a sinistra
```

### DX - Data Register

**Nome completo:** Registro Dati  
**Suddivisione:** DH (high byte) + DL (low byte)

**Usi principali:**
- Operazioni di I/O (numero di porta per IN/OUT)
- Moltiplicazione/divisione (parte alta del risultato in DX)
- Operazioni su dati a 32 bit (DX:AX)
- Parametri per interrupt

**Esempi:**
```assembly
; Output su porta
MOV DX, 3F8h    ; Porta seriale COM1
MOV AL, 'A'
OUT DX, AL      ; Invia 'A' alla porta

; Divisione a 32 bit
MOV DX, 0       ; Parte alta del dividendo
MOV AX, 1234h   ; Parte bassa del dividendo
MOV BX, 10      ; Divisore
DIV BX          ; DX:AX ÷ BX → Quoto in AX, resto in DX

; Moltiplicazione a 32 bit
MOV AX, FFFFh
MOV BX, FFFFh
MUL BX          ; DX:AX = AX × BX = FFFE0001h
```

## Registri Puntatori e Indice

Questi registri sono utilizzati principalmente per l'indirizzamento della memoria. A differenza dei registri generali, **non possono essere suddivisi** in registri a 8 bit.

### SP - Stack Pointer

**Nome completo:** Puntatore allo Stack

**Caratteristiche:**
- Punta al top dello stack (indirizzo SS:SP)
- Decrementato da PUSH, incrementato da POP
- Modificato automaticamente da CALL e RET
- Di solito inizializzato all'inizio del programma

**Funzionamento dello stack:**
```
Stack vuoto:         Dopo PUSH AX:        Dopo PUSH BX:
                    
 ← SP (alto)         ← SP-2                ← SP-4
                     [  AX  ]              [  BX  ]
                     ← SP                  [  AX  ]
                                          ← SP
```

**Esempi:**
```assembly
; Inizializzazione dello stack
MOV AX, stack_segment
MOV SS, AX
MOV SP, 1000h       ; Stack inizia a SS:1000h

; PUSH e POP
PUSH AX             ; SP = SP - 2, [SS:SP] = AX
PUSH BX             ; SP = SP - 2, [SS:SP] = BX
POP CX              ; CX = [SS:SP], SP = SP + 2
POP DX              ; DX = [SS:SP], SP = SP + 2
```

### BP - Base Pointer

**Nome completo:** Puntatore Base

**Caratteristiche:**
- Usato per accedere a parametri e variabili locali nello stack
- Di default usa il segmento SS (non DS come gli altri)
- Fondamentale nelle procedure con stack frame

**Esempio - Stack Frame:**
```assembly
procedura PROC
    PUSH BP         ; Salva BP precedente
    MOV BP, SP      ; BP punta all'inizio del frame
    SUB SP, 10      ; Alloca 10 byte per variabili locali
    
    ; Accesso a parametri (passati nello stack)
    MOV AX, [BP+4]  ; Primo parametro
    MOV BX, [BP+6]  ; Secondo parametro
    
    ; Accesso a variabili locali
    MOV [BP-2], CX  ; Prima variabile locale
    MOV [BP-4], DX  ; Seconda variabile locale
    
    MOV SP, BP      ; Dealloca variabili locali
    POP BP          ; Ripristina BP
    RET
procedura ENDP
```

### SI - Source Index

**Nome completo:** Indice Sorgente

**Caratteristiche:**
- Usato nelle operazioni su stringhe (sorgente)
- Punta ai dati sorgente in DS:SI (o ES:SI con override)
- Auto-incrementato/decrementato dalle istruzioni stringa
- Utilizzabile come registro generale per indirizzamento

**Esempi:**
```assembly
; Operazioni su stringhe
LEA SI, sorgente    ; SI punta alla stringa sorgente
LEA DI, destinazione
MOV CX, 10
REP MOVSB           ; Copia 10 byte da DS:SI a ES:DI

; Indirizzamento con SI
MOV SI, 100h
MOV AL, [SI]        ; Legge da DS:100h
MOV AL, [SI+5]      ; Legge da DS:105h
```

### DI - Destination Index

**Nome completo:** Indice Destinazione

**Caratteristiche:**
- Usato nelle operazioni su stringhe (destinazione)
- Punta ai dati destinazione in ES:DI
- Auto-incrementato/decrementato dalle istruzioni stringa
- Utilizzabile come registro generale per indirizzamento

**Esempi:**
```assembly
; Ricerca in stringa
LEA DI, buffer
MOV AL, 'A'         ; Carattere da cercare
MOV CX, 100         ; Lunghezza massima
CLD                 ; Direzione incrementale
REPNE SCASB         ; Cerca 'A' in ES:DI

; Indirizzamento con DI
MOV DI, 200h
MOV [DI], AL        ; Scrive in DS:200h (se ES = DS)
```

## Registro dei Flag (FLAGS Register)

Il registro FLAGS è un registro a 16 bit che contiene flag di stato e controllo. Solo 9 bit sono utilizzati nell'8086.

```
  15  14  13  12  11  10   9   8   7   6   5   4   3   2   1   0
 ┌───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┐
 │   │   │   │   │ O │ D │ I │ T │ S │ Z │   │ A │   │ P │   │ C │
 └───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┘
                    │   │   │   │   │   │       │       │       │
                    │   │   │   │   │   │       │       │       └─ Carry
                    │   │   │   │   │   │       │       └─────── Parity
                    │   │   │   │   │   │       └─────────────── Auxiliary
                    │   │   │   │   │   └─────────────────────── Zero
                    │   │   │   │   └─────────────────────────── Sign
                    │   │   │   └─────────────────────────────── Trap
                    │   │   └─────────────────────────────────── Interrupt
                    │   └─────────────────────────────────────── Direction
                    └─────────────────────────────────────────── Overflow
```

### Flag di Stato (Status Flags)

Vengono impostati automaticamente dalle operazioni aritmetiche e logiche.

#### CF - Carry Flag (bit 0)

- Impostato a 1 se c'è riporto/prestito dal bit più significativo
- Usato per operazioni aritmetiche multi-precisione

**Esempio:**
```assembly
MOV AL, FFh
ADD AL, 1       ; AL = 00h, CF = 1 (riporto)

MOV AL, 0
SUB AL, 1       ; AL = FFh, CF = 1 (prestito)
```

#### PF - Parity Flag (bit 2)

- Impostato a 1 se il numero di bit '1' nel byte meno significativo è pari
- Usato per controllo di parità nelle comunicazioni

**Esempio:**
```assembly
MOV AL, 00000011b   ; Due bit a 1 (pari)
OR AL, AL           ; PF = 1

MOV AL, 00000111b   ; Tre bit a 1 (dispari)
OR AL, AL           ; PF = 0
```

#### AF - Auxiliary Carry Flag (bit 4)

- Impostato a 1 se c'è riporto/prestito dal bit 3
- Usato per aritmetica BCD (Binary Coded Decimal)

**Esempio:**
```assembly
MOV AL, 0Fh
ADD AL, 1       ; AL = 10h, AF = 1 (riporto da bit 3)
```

#### ZF - Zero Flag (bit 6)

- Impostato a 1 se il risultato è zero
- Molto usato nei confronti e nei salti condizionati

**Esempio:**
```assembly
MOV AX, 5
SUB AX, 5       ; AX = 0, ZF = 1

CMP BX, CX      ; Confronta BX e CX
JE uguale       ; Salta se ZF = 1 (BX = CX)
```

#### SF - Sign Flag (bit 7)

- Impostato a 1 se il risultato è negativo (bit più significativo = 1)
- Usato per numeri con segno

**Esempio:**
```assembly
MOV AL, 7Fh     ; 127 (positivo)
ADD AL, 1       ; AL = 80h, SF = 1 (negativo in complemento a 2)
```

#### OF - Overflow Flag (bit 11)

- Impostato a 1 se c'è overflow in operazioni con segno
- Diverso dal CF che indica riporto senza segno

**Esempio:**
```assembly
MOV AL, 7Fh     ; 127 (massimo positivo su 8 bit)
ADD AL, 1       ; AL = 80h (-128), OF = 1, SF = 1
```

### Flag di Controllo (Control Flags)

Vengono impostati dal programma per controllare il comportamento del processore.

#### DF - Direction Flag (bit 10)

- Controlla la direzione delle operazioni su stringhe
- DF = 0: incrementa SI e DI (CLD)
- DF = 1: decrementa SI e DI (STD)

**Esempio:**
```assembly
CLD             ; DF = 0, incrementa
MOV CX, 10
REP MOVSB       ; Copia in avanti

STD             ; DF = 1, decrementa
MOV CX, 10
REP MOVSB       ; Copia all'indietro
```

#### IF - Interrupt Flag (bit 9)

- Abilita/disabilita le interruzioni maskabili
- IF = 0: interruzioni disabilitate (CLI)
- IF = 1: interruzioni abilitate (STI)

**Esempio:**
```assembly
CLI             ; IF = 0, disabilita interruzioni
; ... codice critico ...
STI             ; IF = 1, riabilita interruzioni
```

#### TF - Trap Flag (bit 8)

- Abilita la modalità single-step per debugging
- TF = 1: il processore genera un'interruzione dopo ogni istruzione
- Usato dai debugger

## Registro IP - Instruction Pointer

Il registro IP contiene l'offset dell'istruzione successiva da eseguire.

**Caratteristiche:**
- Usato insieme a CS per formare l'indirizzo CS:IP
- Non accessibile direttamente con MOV
- Modificato da:
  - Istruzioni di salto (JMP, Jcc)
  - Chiamate a procedure (CALL)
  - Ritorni (RET)
  - Interruzioni (INT)

**Esempio di flusso:**
```assembly
        MOV AX, 1   ; IP punta qui
        ADD AX, 2   ; Poi qui
        JMP skip    ; Poi qui, poi salta
        MOV BX, 3   ; Saltato!
skip:   MOV CX, 4   ; IP salta qui
```

## Convenzioni e Best Practices

### Preservazione dei Registri

Nelle procedure, è buona norma salvare e ripristinare i registri usati:

```assembly
mia_proc PROC
    PUSH AX         ; Salva registri
    PUSH BX
    
    ; ... usa AX e BX ...
    
    POP BX          ; Ripristina (in ordine inverso!)
    POP AX
    RET
mia_proc ENDP
```

### Scelta del Registro

Scegli il registro appropriato per il compito:

- **AX**: operazioni aritmetiche, I/O, interruzioni
- **BX**: indirizzamento base
- **CX**: contatori
- **DX**: I/O su porte, estensione di AX
- **SI/DI**: operazioni su stringhe, indirizzamento indicizzato
- **BP**: accesso a parametri e variabili locali

### Registri a 8 o 16 bit?

```assembly
; Preferisci registri a 8 bit per byte singoli
MOV AL, 'A'     ; Meglio di MOV AX, 'A'

; Usa 16 bit per parole
MOV AX, 1234h   ; Corretto per word

; Attenzione alle modifiche parziali
MOV AX, 1234h
MOV AL, 56h     ; AX = 1256h (solo AL cambiato)
```

## Esercizi di Verifica

1. Qual è il valore di AX dopo questa sequenza?
   ```assembly
   MOV AX, 1234h
   MOV AL, 56h
   MOV AH, 78h
   ```

2. Scrivi una sequenza di istruzioni per scambiare i valori di AX e BX senza usare XCHG.

3. Che flag sono impostati dopo:
   ```assembly
   MOV AL, 7Fh
   ADD AL, 1
   ```

4. Perché questo codice non funziona?
   ```assembly
   MOV DS, 1000h
   ```

5. Simula l'esecuzione di questo codice e indica il valore finale dello stack pointer:
   ```assembly
   MOV SP, 1000h
   PUSH AX
   PUSH BX
   POP CX
   ```

---

**Argomento precedente:** [Introduzione all'Architettura 8086](modulo1_01_introduzione_architettura_8086.md)  
**Prossimo argomento:** [Modalità di Indirizzamento](modulo1_03_modalita_indirizzamento.md)
