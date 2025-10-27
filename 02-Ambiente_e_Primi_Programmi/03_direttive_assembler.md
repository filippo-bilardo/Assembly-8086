# Direttive dell'Assembler

## Introduzione

Le **direttive** (o **pseudo-istruzioni**) sono comandi per l'assembler, non per il processore. Non generano codice macchina eseguibile, ma controllano come l'assembler elabora il codice sorgente.

Le direttive permettono di:
- Definire la struttura del programma
- Allocare dati in memoria
- Definire costanti e macro
- Controllare il processo di assemblaggio

## Direttive di Segmentazione

### .MODEL (MASM/TASM)

Specifica il modello di memoria del programma.

#### Sintassi
```assembly
.MODEL modello [, opzioni]
```

#### Modelli Disponibili

| Modello  | Codice  | Dati    | Descrizione                      |
|----------|---------|---------|----------------------------------|
| TINY     | ≤ 64KB  | ≤ 64KB  | Codice + Dati + Stack nello stesso segmento (.COM) |
| SMALL    | ≤ 64KB  | ≤ 64KB  | Un segmento codice, un segmento dati |
| COMPACT  | ≤ 64KB  | > 64KB  | Un segmento codice, multipli segmenti dati |
| MEDIUM   | > 64KB  | ≤ 64KB  | Multipli segmenti codice, un segmento dati |
| LARGE    | > 64KB  | > 64KB  | Multipli segmenti per entrambi |
| HUGE     | > 64KB  | > 64KB  | Come LARGE, array possono superare 64KB |

#### Esempi

```assembly
.MODEL SMALL        ; Programma semplice
.MODEL TINY         ; File .COM
.MODEL LARGE        ; Programma grande
.MODEL SMALL, C     ; Con convenzioni C
```

#### Opzioni Linguaggio

```assembly
.MODEL SMALL, C       ; Convenzioni C
.MODEL SMALL, PASCAL  ; Convenzioni Pascal
.MODEL SMALL, BASIC   ; Convenzioni BASIC
```

Queste opzioni influenzano:
- Naming delle procedure (underscore, case)
- Ordine dei parametri nello stack
- Pulizia dello stack

### .STACK

Alloca spazio per lo stack.

#### Sintassi
```assembly
.STACK dimensione
```

#### Esempi
```assembly
.STACK 100h         ; 256 byte (default tipico)
.STACK 200h         ; 512 byte
.STACK 1000h        ; 4096 byte (4KB)
```

#### Note
- La dimensione è in byte
- Se omessa, alcuni assembler usano default (tipicamente 1KB)
- Per programmi semplici, 100h-200h è sufficiente
- Programmi ricorsivi necessitano stack più grandi

### Segmenti Semplificati

#### .DATA

Inizia il segmento dati inizializzati.

```assembly
.DATA
    variabile1 DB 10
    variabile2 DW 1234h
    stringa DB 'Hello$'
```

- Dati che hanno valori iniziali
- Caricati in memoria all'avvio del programma

#### .DATA?

Inizia il segmento dati non inizializzati.

```assembly
.DATA?
    buffer DB 100 DUP(?)    ; 100 byte non inizializzati
    temp DW ?               ; Word non inizializzata
```

- Dati senza valore iniziale
- Risparmia spazio nel file .EXE
- Più veloce da caricare

#### .CODE

Inizia il segmento codice.

```assembly
.CODE
main PROC
    ; istruzioni
main ENDP
END main
```

#### .CONST

Segmento per costanti (dati read-only).

```assembly
.CONST
    PI DW 314           ; Pi greco * 100
    E DW 271            ; e * 100
    MAX_SIZE EQU 100
```

### Segmenti Completi (Sintassi Tradizionale)

#### SEGMENT...ENDS

Definizione esplicita dei segmenti.

```assembly
DATA_SEG SEGMENT
    messaggio DB 'Hello$'
DATA_SEG ENDS

CODE_SEG SEGMENT
ASSUME CS:CODE_SEG, DS:DATA_SEG
main PROC
    MOV AX, DATA_SEG
    MOV DS, AX
    ; ...
main ENDP
CODE_SEG ENDS
END main
```

**Nota**: Sintassi più complessa, raramente usata con le direttive semplificate.

## Direttive di Allocazione Dati

### DB - Define Byte

Alloca e inizializza byte (8 bit).

#### Sintassi
```assembly
nome DB valore(i)
```

#### Esempi
```assembly
; Singolo byte
byte1 DB 42             ; Decimale
byte2 DB 2Ah            ; Esadecimale
byte3 DB 101010b        ; Binario
byte4 DB 'A'            ; Carattere ASCII (65)

; Byte multipli
array DB 10, 20, 30, 40, 50
stringa DB 'Hello, World!$'

; Con duplicazione
buffer DB 100 DUP(0)    ; 100 byte a zero
spazi DB 80 DUP(' ')    ; 80 spazi

; Non inizializzato
temp DB ?               ; Un byte qualsiasi
```

### DW - Define Word

Alloca e inizializza word (16 bit).

#### Sintassi
```assembly
nome DW valore(i)
```

#### Esempi
```assembly
; Singola word
word1 DW 1234h
word2 DW 65535          ; FFFF in hex
word3 DW -1             ; FFFF in complemento a 2

; Word multiple
coordinate DW 100, 200, 150, 75

; Array di word
buffer DW 50 DUP(0)     ; 100 byte (50 word)

; Non inizializzato
risultato DW ?
```

### DD - Define Double Word

Alloca e inizializza double word (32 bit).

#### Sintassi
```assembly
nome DD valore(i)
```

#### Esempi
```assembly
dword1 DD 12345678h
dword2 DD 1000000       ; Un milione
puntatore DD ?          ; Puntatore FAR (seg:offset)

; Array
grandi_numeri DD 10000000, 20000000, 30000000
```

### DQ - Define Quad Word

Alloca e inizializza quad word (64 bit).

```assembly
qword1 DQ 123456789ABCDEFh
```

### DT - Define Ten Bytes

Alloca 10 byte (per numeri BCD packed).

```assembly
bcd_number DT 12345678901234567890
```

## Operatore DUP

Duplica valori per inizializzazioni ripetute.

#### Sintassi
```assembly
conteggio DUP(valore)
```

#### Esempi
```assembly
; 10 byte a zero
buffer1 DB 10 DUP(0)

; 100 spazi
spazi DB 100 DUP(' ')

; 50 word a -1
numeri DW 50 DUP(-1)

; Pattern ripetuto
pattern DB 5 DUP(1, 2, 3)   ; 1,2,3,1,2,3,1,2,3,1,2,3,1,2,3

; Non inizializzato
buffer2 DB 256 DUP(?)       ; 256 byte indefiniti
```

#### DUP Annidati
```assembly
; Matrice 10x10 di byte a zero
matrice DB 10 DUP(10 DUP(0))    ; 100 byte totali
```

## Direttive di Definizione Simboli

### EQU - Equate

Definisce una costante simbolica (non modificabile).

#### Sintassi
```assembly
simbolo EQU valore
```

#### Esempi
```assembly
; Costanti numeriche
MAX_SIZE EQU 100
BUFFER_SIZE EQU 512
TRUE EQU 1
FALSE EQU 0

; Costanti carattere
CR EQU 13               ; Carriage Return
LF EQU 10               ; Line Feed
EOF EQU 1Ah             ; End of File

; Espressioni
TOTAL_SIZE EQU MAX_SIZE * 2
LAST_INDEX EQU MAX_SIZE - 1

; Stringhe
MESSAGE EQU <'Hello, World!$'>

; Uso
buffer DB BUFFER_SIZE DUP(0)
MOV CX, MAX_SIZE
```

**Caratteristiche:**
- Sostituito dall'assembler (come #define in C)
- Non occupa memoria
- Non può essere ridefinito

### = (Uguale)

Definisce un simbolo modificabile.

#### Sintassi
```assembly
simbolo = valore
```

#### Esempi
```assembly
contatore = 0
contatore = contatore + 1   ; Ridefinito!
contatore = contatore + 1   ; Ridefinito ancora!

; Uso in macro per contatori
```

**Differenza da EQU:**
- Può essere ridefinito
- Usato principalmente in macro

## Direttive di Procedure

### PROC...ENDP

Definisce una procedura.

#### Sintassi
```assembly
nome PROC [NEAR|FAR]
    ; corpo procedura
    RET
nome ENDP
```

#### Esempi

**Procedura NEAR (default):**
```assembly
stampa PROC NEAR
    PUSH AX
    MOV AH, 09h
    INT 21h
    POP AX
    RET
stampa ENDP
```

**Procedura FAR:**
```assembly
; Chiamabile da altri segmenti
funzione_lontana PROC FAR
    ; ...
    RET
funzione_lontana ENDP
```

#### NEAR vs FAR

| Tipo | Chiamata          | Ritorno    | Stack          |
|------|-------------------|------------|----------------|
| NEAR | Salva solo IP     | RET        | 2 byte         |
| FAR  | Salva CS:IP       | RETF       | 4 byte         |

**Quando usare FAR:**
- Procedura in un segmento di codice diverso
- Modelli di memoria MEDIUM, LARGE, HUGE

## Direttive di Controllo Assembler

### ORG - Origin

Imposta il contatore di locazione.

#### Sintassi
```assembly
ORG indirizzo
```

#### Esempi

**File .COM:**
```assembly
ORG 100h            ; Obbligatorio per .COM
start:
    ; codice inizia a offset 100h
```

**Tabella a indirizzo specifico:**
```assembly
ORG 1000h
tabella DB 10, 20, 30, 40
```

**Reset offset:**
```assembly
ORG 0
interrupt_vector DW handler
```

### ALIGN

Allinea il prossimo dato/codice a un boundary specifico.

#### Sintassi
```assembly
ALIGN boundary
```

#### Esempi
```assembly
.DATA
    byte1 DB 42
    ALIGN 2             ; Allinea a word boundary
    word1 DW 1234h      ; Ora su indirizzo pari
    
    ALIGN 4             ; Allinea a double word
    dword1 DD 12345678h
```

**Perché allineare:**
- Alcuni processori accedono più velocemente a dati allineati
- Word su indirizzi pari sono più veloci (8086/8088)

### EVEN

Allinea al prossimo indirizzo pari (shortcut per ALIGN 2).

```assembly
.DATA
    byte1 DB 1
    EVEN                ; Se offset dispari, inserisce un byte
    word1 DW 100        ; Ora su offset pari
```

### INCLUDE

Include un file sorgente esterno.

#### Sintassi
```assembly
INCLUDE filename
```

#### Esempi
```assembly
; main.asm
INCLUDE 'macros.inc'
INCLUDE 'constants.inc'

.MODEL SMALL
; ...
```

**File macros.inc:**
```assembly
; Definizioni macro comuni
PRINT MACRO msg
    PUSH AX
    PUSH DX
    MOV AH, 09h
    LEA DX, msg
    INT 21h
    POP DX
    POP AX
ENDM
```

### COMMENT

Commento multi-linea.

#### Sintassi
```assembly
COMMENT delimitatore
    testo commentato
    può occupare
    multiple linee
delimitatore
```

#### Esempio
```assembly
COMMENT @
    Questo è un blocco di commento
    che può estendersi su più righe.
    Utile per documentazione estesa.
@
```

**Alternativa:**
```assembly
COMMENT *
    Altro esempio
    con delimitatore *
*
```

## Direttive NASM

NASM usa sintassi leggermente diverse.

### BITS

Specifica la modalità del processore.

```assembly
BITS 16             ; Codice 16-bit (8086, 80286)
BITS 32             ; Codice 32-bit (80386+)
BITS 64             ; Codice 64-bit (x86-64)
```

### SECTION

Definisce sezioni (equivalente a SEGMENT).

```assembly
section .data
    ; dati

section .bss        ; Block Started by Symbol (dati non init.)
    ; dati non inizializzati

section .text
    ; codice
```

### RESB, RESW, RESD

Riserva spazio non inizializzato (in .bss).

```assembly
section .bss
    buffer resb 100     ; Riserva 100 byte
    array resw 50       ; Riserva 50 word (100 byte)
    var resd 10         ; Riserva 10 dword (40 byte)
```

### TIMES

Ripete istruzione o dato (equivalente a DUP).

```assembly
section .data
    zeros times 100 db 0        ; 100 byte a zero
    pattern times 10 db 1, 2    ; 1,2,1,2,...,1,2 (20 byte)

section .text
    times 5 nop                 ; 5 istruzioni NOP
```

### EQU in NASM

Simile a MASM ma con sintassi diversa.

```assembly
MAX_SIZE equ 100
CR equ 13
LF equ 10

buffer times MAX_SIZE db 0
```

### INCBIN

Include un file binario.

```assembly
section .data
    immagine incbin 'logo.bin'
    musica incbin 'sound.raw'
```

## Direttive Condizionali

### IF...ENDIF (MASM/TASM)

Assemblaggio condizionale.

#### Sintassi
```assembly
IF condizione
    ; codice assemblato se vero
ELSE
    ; codice assemblato se falso
ENDIF
```

#### Esempi

```assembly
DEBUG EQU 1

IF DEBUG
    ; Codice di debug
    .DATA
    debug_msg DB 'Debug attivo$'
    .CODE
    MOV AH, 09h
    LEA DX, debug_msg
    INT 21h
ENDIF
```

```assembly
VERSIONE EQU 2

IF VERSIONE EQ 1
    MOV AX, 100
ELSEIF VERSIONE EQ 2
    MOV AX, 200
ELSE
    MOV AX, 300
ENDIF
```

### IFDEF, IFNDEF

Verifica se simbolo è definito.

```assembly
IFDEF simbolo
    ; assemblato se simbolo è definito
ENDIF

IFNDEF simbolo
    ; assemblato se simbolo NON è definito
ENDIF
```

#### Esempio
```assembly
IFDEF DEBUG
    ; Inserisce codice di logging
    CALL log_debug
ENDIF

IFNDEF MAX_SIZE
    MAX_SIZE EQU 100    ; Default se non definito
ENDIF
```

## Direttive Macro

### MACRO...ENDM

Definisce una macro.

#### Sintassi Base
```assembly
nome MACRO [parametri]
    ; corpo della macro
ENDM
```

#### Esempi

**Macro Semplice:**
```assembly
NEWLINE MACRO
    PUSH AX
    PUSH DX
    MOV AH, 02h
    MOV DL, 13      ; CR
    INT 21h
    MOV DL, 10      ; LF
    INT 21h
    POP DX
    POP AX
ENDM

; Uso
NEWLINE             ; Espanso dall'assembler
```

**Macro con Parametri:**
```assembly
PRINT MACRO messaggio
    PUSH AX
    PUSH DX
    MOV AH, 09h
    LEA DX, messaggio
    INT 21h
    POP DX
    POP AX
ENDM

; Uso
.DATA
    msg1 DB 'Hello$'
.CODE
    PRINT msg1      ; Espanso con msg1 al posto di messaggio
```

**Macro con Parametri Multipli:**
```assembly
ADD_WORD MACRO dest, src
    PUSH AX
    MOV AX, src
    ADD dest, AX
    POP AX
ENDM

; Uso
ADD_WORD [var1], [var2]
```

### LOCAL

Definisce etichette locali in macro.

```assembly
REPEAT MACRO volte
    LOCAL ciclo     ; Etichetta locale
    PUSH CX
    MOV CX, volte
ciclo:
    ; corpo
    LOOP ciclo
    POP CX
ENDM
```

Senza LOCAL, chiamate multiple creerebbero etichette duplicate.

## Direttive di Linking

### PUBLIC

Rende simboli visibili ad altri moduli.

```assembly
; file1.asm
PUBLIC funzione1, variabile1

.CODE
funzione1 PROC
    ; ...
    RET
funzione1 ENDP

.DATA
variabile1 DW 100
```

### EXTRN / EXTERN

Dichiara simboli esterni.

```assembly
; file2.asm
EXTRN funzione1:PROC
EXTRN variabile1:WORD

.CODE
main PROC
    CALL funzione1      ; Definita in file1.asm
    MOV AX, variabile1
main ENDP
```

## Tabella Riepilogativa Direttive

| Direttiva      | Scopo                           | Esempio                    |
|----------------|---------------------------------|----------------------------|
| .MODEL         | Modello di memoria              | .MODEL SMALL               |
| .STACK         | Alloca stack                    | .STACK 100h                |
| .DATA          | Segmento dati                   | .DATA                      |
| .CODE          | Segmento codice                 | .CODE                      |
| DB/DW/DD       | Definisce dati                  | var DB 10                  |
| DUP            | Duplica valori                  | DB 10 DUP(0)               |
| EQU            | Costante simbolica              | MAX EQU 100                |
| PROC/ENDP      | Definisce procedura             | func PROC ... ENDP         |
| ORG            | Imposta offset                  | ORG 100h                   |
| ALIGN/EVEN     | Allineamento dati               | ALIGN 4                    |
| INCLUDE        | Include file                    | INCLUDE 'lib.inc'          |
| MACRO/ENDM     | Definisce macro                 | PRINT MACRO ... ENDM       |
| IF/ENDIF       | Assemblaggio condizionale       | IF DEBUG ... ENDIF         |
| PUBLIC         | Esporta simboli                 | PUBLIC funzione            |
| EXTRN          | Importa simboli                 | EXTRN var:WORD             |

## Esercizi Pratici

1. **Costanti**: Definisci costanti per CR, LF e TAB usando EQU
2. **Array**: Crea un array di 100 word inizializzate a -1
3. **Stringhe**: Definisci 5 stringhe diverse e stampale con un loop
4. **Macro**: Crea una macro PRINT_CHAR che stampa un carattere passato come parametro
5. **Conditional**: Usa IF/ENDIF per includere codice di debug solo se DEBUG EQU 1

### Soluzione Esercizio 4

```assembly
PRINT_CHAR MACRO carattere
    PUSH AX
    PUSH DX
    MOV AH, 02h
    MOV DL, carattere
    INT 21h
    POP DX
    POP AX
ENDM

.CODE
main PROC
    PRINT_CHAR 'H'
    PRINT_CHAR 'e'
    PRINT_CHAR 'l'
    PRINT_CHAR 'l'
    PRINT_CHAR 'o'
    
    MOV AH, 4Ch
    INT 21h
main ENDP
```

---

**Argomento precedente:** [Primo Programma: Hello World](02_hello_world.md)  
**Prossimo argomento:** [Processo di Assemblaggio e Linking](04_assemblaggio_linking.md)
