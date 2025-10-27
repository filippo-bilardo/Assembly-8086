# Variabili e Gestione della Memoria

## Introduzione

La **memoria** è fondamentale in assembly: tutti i dati devono essere memorizzati da qualche parte. L'8086 offre diverse direttive per dichiarare variabili in memoria e tecniche per accedervi efficientemente.

### Concetti Chiave

- **Segmento dati**: area memoria per variabili (.DATA, .DATA?)
- **Direttive di allocazione**: DB, DW, DD, DQ, DT
- **Array**: sequenze di elementi dello stesso tipo
- **Stringhe**: array di caratteri terminati da null o con lunghezza
- **Puntatori**: indirizzi di memoria
- **Strutture**: raggruppamento di dati eterogenei

## Direttive di Allocazione Dati

### DB - Define Byte

Alloca **1 byte** (8 bit) per elemento.

**Sintassi**:
```assembly
nome DB valore [, valore, ...]
```

**Esempi**:
```assembly
.DATA
    byte_var DB 42              ; 1 byte = 42
    char_var DB 'A'             ; 1 byte = 65 (ASCII di 'A')
    multi_byte DB 10, 20, 30    ; 3 byte consecutivi
    stringa DB 'Hello', 0       ; 6 byte: 'H','e','l','l','o',0
    buffer DB 100 DUP(0)        ; 100 byte tutti a 0
```

**Valori speciali**:
```assembly
    undefined DB ?              ; Non inizializzato
    multiple DB 5 DUP(10)       ; 5 byte, tutti = 10
    pattern DB 3 DUP(1, 2, 3)   ; 9 byte: 1,2,3, 1,2,3, 1,2,3
```

### DW - Define Word

Alloca **2 byte** (16 bit, 1 word) per elemento.

**Sintassi**:
```assembly
nome DW valore [, valore, ...]
```

**Esempi**:
```assembly
.DATA
    word_var DW 1000            ; 2 byte = 1000 (0x03E8)
    signed_var DW -50           ; 2 byte = 0xFFCE (complemento a 2)
    array_word DW 10, 20, 30    ; 6 byte (3 word)
    word_buffer DW 50 DUP(0)    ; 100 byte (50 word) tutti a 0
```

**Nota**: memorizzazione **little-endian**:
```assembly
value DW 0x1234
; Memoria: [indirizzo] = 0x34, [indirizzo+1] = 0x12
;          byte basso prima, byte alto dopo
```

### DD - Define Doubleword

Alloca **4 byte** (32 bit, 1 doubleword) per elemento.

**Sintassi**:
```assembly
nome DD valore
```

**Esempi**:
```assembly
.DATA
    dword_var DD 100000         ; 4 byte = 100000 (0x000186A0)
    large_num DD 0x12345678     ; 4 byte
    far_ptr DD 0x12345678       ; Puntatore FAR (seg:offset)
```

### DQ e DT - Define Quadword e Ten Bytes

**DQ** (Quadword): 8 byte (64 bit)  
**DT** (Ten bytes): 10 byte (80 bit, per floating-point esteso)

```assembly
.DATA
    quad_var DQ 0x123456789ABCDEF0    ; 8 byte
    float_ext DT 3.141592653589793    ; 10 byte (80-bit float)
```

**Uso**: principalmente per coprocessore matematico (8087).

### Tabella Riassuntiva

| Direttiva | Dimensione | Tipo | Esempio |
|-----------|------------|------|---------|
| DB | 1 byte | Byte, char | `DB 65`, `DB 'A'` |
| DW | 2 byte | Word, short | `DW 1000`, `DW -50` |
| DD | 4 byte | Doubleword, long, far ptr | `DD 100000` |
| DQ | 8 byte | Quadword | `DQ 0x123...` |
| DT | 10 byte | Ten bytes (extended float) | `DT 3.14...` |

## Operatore DUP

### Sintassi

**DUP** (DUPlicate) ripete un pattern di inizializzazione.

```assembly
nome tipo_dato conteggio DUP(valore)
```

### Esempi

**Array di zeri**:
```assembly
buffer DB 256 DUP(0)        ; 256 byte a 0
array DW 100 DUP(0)         ; 100 word (200 byte) a 0
```

**Array non inizializzato**:
```assembly
temp_buffer DB 512 DUP(?)   ; 512 byte non inizializzati
```

**Pattern ripetuto**:
```assembly
pattern DB 10 DUP(1, 2, 3)
; Risultato: 1,2,3, 1,2,3, 1,2,3, ... (10 volte)
; Totale: 30 byte
```

**DUP annidato**:
```assembly
matrix DB 3 DUP(4 DUP(0))
; 3 righe di 4 zeri = 12 byte totali
```

## Stringhe

### Stringhe C-style (null-terminated)

Terminate da byte 0 (NULL):

```assembly
.DATA
    msg DB 'Hello, World!', 0   ; 14 byte (13 + null terminator)
    nome DB 'Mario', 0          ; 6 byte
```

**Calcolo lunghezza**:
```assembly
; Conta caratteri fino a null
conta_lunghezza PROC
    ; SI punta alla stringa
    XOR CX, CX              ; CX = 0 (contatore)
loop_conta:
    LODSB                   ; AL = [SI], SI++
    TEST AL, AL
    JZ fine_conta           ; Se AL = 0, fine
    INC CX
    JMP loop_conta
fine_conta:
    ; CX = lunghezza stringa
    RET
conta_lunghezza ENDP
```

### Stringhe Pascal-style (lunghezza prefissa)

Primo byte = lunghezza:

```assembly
.DATA
    pstring DB 5, 'H','e','l','l','o'
    ;          ^-- lunghezza (5 byte)
```

**Accesso**:
```assembly
    LEA SI, pstring
    MOV CL, [SI]            ; CL = lunghezza
    INC SI                  ; SI punta al primo carattere
```

### Stringhe Multilinea

```assembly
.DATA
    long_msg DB 'Questa è una stringa molto lunga ', 
                'che continua su più righe ', 
                'per migliorare la leggibilità', 0
```

### Caratteri Speciali

```assembly
.DATA
    newline DB 13, 10, 0            ; CR + LF (Windows)
    tab_str DB 'Col1', 9, 'Col2', 0 ; 9 = TAB
    quote DB '"Testo tra virgolette"', 0
```

**Codici ASCII comuni**:
- `0`: NULL (terminatore)
- `9`: TAB
- `10`: LF (Line Feed, \n Unix)
- `13`: CR (Carriage Return, \r)
- `32`: Spazio
- `65-90`: 'A'-'Z'
- `97-122`: 'a'-'z'

## Array

### Array di Byte

```assembly
.DATA
    byte_array DB 10, 20, 30, 40, 50
    dimensione = $ - byte_array     ; $ = indirizzo corrente
                                     ; dimensione = 5
```

**Accesso tramite indice**:
```assembly
    LEA SI, byte_array
    MOV AL, [SI]            ; AL = byte_array[0] = 10
    MOV AL, [SI+1]          ; AL = byte_array[1] = 20
    MOV AL, [SI+2]          ; AL = byte_array[2] = 30
    
    ; Indice variabile
    MOV BX, 3
    MOV AL, [SI+BX]         ; AL = byte_array[3] = 40
```

### Array di Word

```assembly
.DATA
    word_array DW 100, 200, 300, 400, 500
    num_elementi = ($ - word_array) / 2    ; 10 byte / 2 = 5 word
```

**Accesso** (indice × 2):
```assembly
    LEA SI, word_array
    MOV AX, [SI]            ; AX = word_array[0] = 100
    MOV AX, [SI+2]          ; AX = word_array[1] = 200
    MOV AX, [SI+4]          ; AX = word_array[2] = 300
    
    ; Indice variabile
    MOV BX, 3
    SHL BX, 1               ; BX = BX × 2 (offset byte)
    MOV AX, [SI+BX]         ; AX = word_array[3] = 400
```

### Matrice (Array 2D)

**Row-major order** (per righe):

```assembly
.DATA
    ; Matrice 3×4 (3 righe, 4 colonne)
    matrix DW 1, 2, 3, 4,      ; Riga 0
              5, 6, 7, 8,      ; Riga 1
              9, 10, 11, 12    ; Riga 2
    
    ROWS = 3
    COLS = 4
```

**Accesso elemento [riga][col]**:
```assembly
; offset = (riga × COLS + col) × sizeof(elemento)

    MOV AX, 1               ; riga = 1
    MOV BX, COLS
    MUL BX                  ; AX = riga × COLS
    ADD AX, 2               ; AX += col (col = 2)
    SHL AX, 1               ; AX × 2 (word = 2 byte)
    MOV BX, AX
    LEA SI, matrix
    MOV AX, [SI+BX]         ; AX = matrix[1][2] = 7
```

## Variabili non Inizializzate

### Direttiva ?

```assembly
.DATA
    init_var DW 100         ; Inizializzata a 100
    uninit_var DW ?         ; NON inizializzata (valore casuale!)
```

**Uso**: alloca spazio senza valore iniziale (più efficiente).

### Segmento .DATA?

Separare variabili non inizializzate:

```assembly
.DATA
    ; Variabili inizializzate
    counter DW 0
    message DB 'Hello', 0

.DATA?
    ; Variabili non inizializzate (BSS-like)
    buffer DB 1024 DUP(?)
    temp_array DW 100 DUP(?)
```

**Vantaggio**: file eseguibile più piccolo (spazio riservato, non memorizzato).

## Allineamento Memoria

### Concetto

L'8086 accede alla memoria più efficientemente se i dati sono **allineati**:
- **Word** (2 byte): allineate a indirizzi pari
- **Doubleword** (4 byte): allineate a indirizzi multipli di 4

**Esempio inefficiente**:
```assembly
.DATA
    byte_var DB 1           ; Indirizzo 0x0000
    word_var DW 1000        ; Indirizzo 0x0001 (DISPARI! 2 accessi memoria)
```

**Soluzione**: usa **EVEN** o **ALIGN**:

```assembly
.DATA
    byte_var DB 1
    EVEN                    ; Allinea al prossimo indirizzo pari
    word_var DW 1000        ; Ora a indirizzo pari (1 accesso)
```

### EVEN

Allinea al prossimo indirizzo **pari**:

```assembly
    DB 1, 2, 3              ; Indirizzi 0, 1, 2
    EVEN                    ; Padding a indirizzo 4 (inserisce 1 byte)
    DW 100                  ; Indirizzo 4 (pari)
```

### ALIGN n

Allinea al prossimo multiplo di **n**:

```assembly
    DB 1, 2
    ALIGN 4                 ; Allinea a multiplo di 4
    DD 12345678             ; Indirizzo multiplo di 4
```

**Best practice**: allinea sempre word e doubleword per prestazioni ottimali.

## Puntatori e Indirizzi

### Offset vs Segment:Offset

**Offset** (NEAR pointer): 16 bit, indirizzo all'interno del segmento.

```assembly
.DATA
    var DW 100
    ptr_var DW OFFSET var   ; ptr_var = offset di var
```

**Far pointer**: 32 bit (segment:offset).

```assembly
    far_ptr DD ?            ; 4 byte: 2 per segment, 2 per offset
```

### Operatori LEA, OFFSET, SEG

**LEA** (Load Effective Address): carica indirizzo in registro.

```assembly
    LEA SI, var             ; SI = offset di var
```

**OFFSET**: restituisce offset di una variabile (usato con MOV).

```assembly
    MOV SI, OFFSET var      ; SI = offset di var (equivalente a LEA)
```

**SEG**: restituisce segmento di una variabile.

```assembly
    MOV AX, SEG var         ; AX = segmento di var
    MOV DS, AX
```

**Differenza LEA vs MOV OFFSET**:

```assembly
LEA SI, [BX+DI+10]      ; SI = BX + DI + 10 (calcolo runtime)
MOV SI, OFFSET var      ; SI = offset var (costante compile-time)
```

### Dereferenziare Puntatori

```assembly
.DATA
    value DW 42
    ptr DW OFFSET value

.CODE
    MOV BX, ptr             ; BX = indirizzo di value
    MOV AX, [BX]            ; AX = *ptr = 42 (dereference)
    
    ; Modifica tramite puntatore
    MOV WORD PTR [BX], 100  ; *ptr = 100
    ; Ora value = 100
```

## Strutture Dati

### Strutture (Record)

Raggruppare dati eterogenei:

```assembly
.DATA
    ; Struttura Persona (senza STRUCT)
    persona_nome DB 'Mario', 0, 0, 0, 0, 0  ; 10 byte (nome max)
    persona_eta DB 30                        ; 1 byte
    persona_altezza DW 175                   ; 2 byte (cm)
    ; Totale: 13 byte
```

**Accesso**:
```assembly
    LEA SI, persona_nome
    ; [SI+0..9] = nome
    ; [SI+10] = età
    ; [SI+11..12] = altezza
    
    MOV AL, [SI+10]         ; AL = età
    MOV AX, [SI+11]         ; AX = altezza
```

### STRUCT (MASM/TASM)

Definizione formale:

```assembly
Persona STRUC
    nome DB 10 DUP(?)
    eta DB ?
    altezza DW ?
Persona ENDS

.DATA
    mario Persona {'Mario', 0, 0, 0, 0, 0, 30, 175}
    luigi Persona {'Luigi', 0, 0, 0, 0, 0, 25, 180}
```

**Accesso con nomi campo**:
```assembly
    LEA SI, mario
    MOV AL, [SI].Persona.eta        ; AL = 30
    MOV AX, [SI].Persona.altezza    ; AX = 175
    
    ; O più semplicemente (MASM assume tipo)
    MOV AL, mario.eta
    MOV AX, mario.altezza
```

### Array di Strutture

```assembly
Punto STRUC
    x DW ?
    y DW ?
Punto ENDS

.DATA
    punti Punto 10 DUP(<0, 0>)      ; 10 punti, tutti (0,0)
    ; Oppure
    linea Punto <10, 20>, <30, 40>  ; 2 punti: (10,20) e (30,40)
```

**Accesso**:
```assembly
    LEA SI, punti
    ; Punto 0: [SI+0..3]
    ; Punto 1: [SI+4..7]
    ; Punto i: [SI+i*4..i*4+3] (ogni punto = 4 byte)
    
    MOV BX, 2               ; Indice punto
    SHL BX, 2               ; BX × 4 (size Punto)
    MOV AX, [SI+BX]         ; AX = punti[2].x
    MOV AX, [SI+BX+2]       ; AX = punti[2].y
```

## Allocazione Dinamica (DOS)

### Concetto

**Allocazione statica**: memoria definita a compile-time (.DATA).  
**Allocazione dinamica**: memoria richiesta a runtime (INT 21h).

### Ottenere Memoria (INT 21h, AH=48h)

```assembly
; Richiedi memoria
    MOV AH, 48h             ; Funzione allocazione memoria
    MOV BX, num_paragraphs  ; Numero di paragraphs (1 para = 16 byte)
    INT 21h
    JC errore_memoria       ; CF=1 se errore
    
    ; AX = segmento del blocco allocato
    MOV ES, AX              ; ES punta al blocco
    ; Usa ES:[offset] per accedere
    
errore_memoria:
    ; AX = codice errore
    ; BX = massima memoria disponibile (paragraphs)
```

**Esempio**: allocare 1024 byte (64 paragraphs):

```assembly
    MOV AH, 48h
    MOV BX, 64              ; 64 × 16 = 1024 byte
    INT 21h
    JC no_memory
    
    MOV ES, AX              ; ES = segmento allocato
    ; Scrivi nel blocco
    MOV DI, 0
    MOV BYTE PTR ES:[DI], 'A'
    
no_memory:
    ; Gestisci errore
```

### Liberare Memoria (INT 21h, AH=49h)

```assembly
; Libera memoria allocata
    MOV AH, 49h             ; Funzione dealloca memoria
    MOV ES, segmento_blocco ; ES = segmento da liberare
    INT 21h
    JC errore_free
```

### Ridimensionare Memoria (INT 21h, AH=4Ah)

```assembly
; Ridimensiona blocco
    MOV AH, 4Ah
    MOV ES, segmento_blocco ; Blocco da ridimensionare
    MOV BX, new_paragraphs  ; Nuova dimensione
    INT 21h
    JC errore_resize
```

## Best Practices

### 1. Inizializza Variabili

```assembly
✓ Sempre inizializza:
    counter DW 0            ; Chiaro: inizia da 0
    
✗ Evita valori casuali:
    counter DW ?            ; Valore imprevedibile!
    ; Poi usi counter senza inizializzarlo → bug!
```

### 2. Usa Nomi Significativi

```assembly
✓ Nomi descrittivi:
    student_count DW 0
    average_grade DW 0
    
✗ Nomi criptici:
    x DW 0
    temp1 DW 0
```

### 3. Commenta Struttura Dati

```assembly
✓ Documenta:
    ; Array temperature (°C), 7 giorni
    temperature DB 7 DUP(?)
    
    ; Buffer input utente (max 80 char + null)
    input_buffer DB 81 DUP(?)
```

### 4. Controlla Bounds

```assembly
; Verifica indice prima di accedere
    CMP BX, array_size
    JAE index_out_of_bounds ; BX ≥ size → errore!
    
    MOV AL, array[BX]       ; Sicuro
```

### 5. Allinea per Prestazioni

```assembly
✓ Allineamento:
    byte_var DB 1
    EVEN                    ; Padding
    word_var DW 100         ; Pari
    
    ALIGN 4
    dword_var DD 12345      ; Multiplo di 4
```

### 6. Libera Memoria Allocata

```assembly
; Sempre dealloca memoria dinamica!
    MOV AH, 48h
    MOV BX, 100
    INT 21h                 ; Alloca
    ; ... usa memoria ...
    MOV AH, 49h
    INT 21h                 ; Libera (non dimenticare!)
```

## Esercizi Pratici

1. Dichiara array di 10 word, inizializzate ai quadrati (1, 4, 9, 16, ...)
2. Calcola la somma di un array di byte
3. Trova il massimo in un array di word signed
4. Inverti l'ordine degli elementi in un array
5. Copia un array in un altro (senza istruzioni stringhe)
6. Implementa struttura "Rettangolo" (base, altezza) e calcola area

### Soluzione Esercizio 2

```assembly
; Somma elementi array di byte
.DATA
    byte_array DB 10, 20, 30, 40, 50
    array_size = $ - byte_array
    somma DW ?

.CODE
    LEA SI, byte_array
    MOV CX, array_size      ; Contatore
    XOR AX, AX              ; Somma = 0
    
somma_loop:
    XOR BX, BX
    MOV BL, [SI]            ; BL = elemento corrente
    ADD AX, BX              ; Somma += elemento
    INC SI                  ; Prossimo elemento
    LOOP somma_loop
    
    MOV somma, AX           ; Salva risultato
    ; AX = 10+20+30+40+50 = 150
```

### Soluzione Esercizio 3

```assembly
; Trova massimo in array di word signed
.DATA
    word_array DW -50, 30, -10, 100, 25
    array_count = ($ - word_array) / 2
    massimo DW ?

.CODE
    LEA SI, word_array
    MOV CX, array_count
    MOV AX, [SI]            ; Massimo = primo elemento
    ADD SI, 2               ; Prossimo elemento
    DEC CX                  ; Già controllato primo
    
trova_max_loop:
    CMP AX, [SI]
    JGE non_maggiore        ; Se AX ≥ [SI], continua
    MOV AX, [SI]            ; Nuovo massimo
non_maggiore:
    ADD SI, 2               ; Prossimo elemento
    LOOP trova_max_loop
    
    MOV massimo, AX         ; Salva massimo
    ; AX = 100
```

---

**Prossimo argomento:** [Istruzioni per Stringhe](02_istruzioni_stringhe.md)
