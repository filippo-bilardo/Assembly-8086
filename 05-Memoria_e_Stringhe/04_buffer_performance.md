# Gestione Buffer e Ottimizzazioni

## Introduzione

La gestione efficiente dei buffer e l'ottimizzazione delle operazioni su stringhe sono cruciali per prestazioni elevate. Questo modulo esplora tecniche avanzate per lavorare con grandi quantità di dati in memoria.

### Obiettivi

- Gestire buffer circolari e dinamici
- Ottimizzare operazioni su stringhe
- Tecniche di buffering per I/O
- Allineamento memoria e cache
- Prevenire errori comuni (overflow, memory leaks)

## Buffer Circolari

### Concetto

Un **buffer circolare** (ring buffer) è una struttura FIFO (First In, First Out) di dimensione fissa che "wrappa" quando raggiunge la fine.

```
Buffer circolare (size = 8):

Inizio:  [_][_][_][_][_][_][_][_]
         ^head                ^tail

Dopo 3 write:
         [A][B][C][_][_][_][_][_]
         ^head        ^tail

Dopo 2 read:
         [_][_][C][_][_][_][_][_]
               ^head  ^tail

Dopo 6 write (wrapping):
         [F][G][C][D][E][H][I][J]
                  ^tail ^head
```

### Implementazione

```assembly
.DATA
    BUFFER_SIZE EQU 256
    circ_buffer DB BUFFER_SIZE DUP(?)
    head DW 0               ; Indice scrittura
    tail DW 0               ; Indice lettura
    count DW 0              ; Elementi nel buffer

.CODE

; Inserisci byte nel buffer circolare
cbuf_write PROC
    ; AL = byte da inserire
    ; Return: CF = 0 (OK), CF = 1 (buffer pieno)
    
    ; Controlla se pieno
    CMP count, BUFFER_SIZE
    JAE cbuf_full
    
    ; Scrivi byte
    MOV BX, head
    LEA DI, circ_buffer
    MOV [DI+BX], AL
    
    ; Aggiorna head (con wrapping)
    INC head
    CMP head, BUFFER_SIZE
    JL cbuf_w_no_wrap
    MOV head, 0             ; Wrap to 0
    
cbuf_w_no_wrap:
    INC count
    CLC                     ; CF = 0 (success)
    RET
    
cbuf_full:
    STC                     ; CF = 1 (full)
    RET
cbuf_write ENDP

; Leggi byte dal buffer circolare
cbuf_read PROC
    ; Return: AL = byte letto, CF = 0 (OK), CF = 1 (vuoto)
    
    ; Controlla se vuoto
    CMP count, 0
    JE cbuf_empty
    
    ; Leggi byte
    MOV BX, tail
    LEA SI, circ_buffer
    MOV AL, [SI+BX]
    
    ; Aggiorna tail (con wrapping)
    INC tail
    CMP tail, BUFFER_SIZE
    JL cbuf_r_no_wrap
    MOV tail, 0
    
cbuf_r_no_wrap:
    DEC count
    CLC
    RET
    
cbuf_empty:
    STC
    RET
cbuf_read ENDP

; Reset buffer
cbuf_reset PROC
    MOV head, 0
    MOV tail, 0
    MOV count, 0
    RET
cbuf_reset ENDP
```

### Uso Tipico: Buffering Input

```assembly
; Buffer tastiera con buffer circolare
keyboard_handler PROC
    ; Leggi carattere da tastiera (INT 16h)
    MOV AH, 00h
    INT 16h                 ; AL = ASCII char
    
    ; Inserisci in buffer circolare
    CALL cbuf_write
    JC buffer_overflow      ; Se CF = 1, buffer pieno
    
    RET
    
buffer_overflow:
    ; Gestisci overflow (beep, scarta, ...)
    RET
keyboard_handler ENDP

; Lettura da buffer (chiamata dal programma principale)
get_buffered_char PROC
    ; Return: AL = carattere, CF = 0/1
    
    CALL cbuf_read
    RET
get_buffered_char ENDP
```

## Buffer Dinamici

### Allocazione Crescente

Buffer che cresce quando pieno (simile a `std::vector`).

```assembly
.DATA?
    dyn_buffer DW ?         ; Puntatore al buffer (segmento)
    dyn_capacity DW ?       ; Capacità corrente (byte)
    dyn_size DW ?           ; Dimensione usata (byte)

.CODE

; Inizializza buffer dinamico
dbuf_init PROC
    ; BX = capacità iniziale (paragraphs)
    
    MOV AH, 48h
    INT 21h                 ; Alloca memoria
    JC dbuf_init_error
    
    MOV dyn_buffer, AX      ; Salva segmento
    SHL BX, 4               ; Paragraphs → byte
    MOV dyn_capacity, BX
    MOV dyn_size, 0
    CLC
    RET
    
dbuf_init_error:
    STC
    RET
dbuf_init ENDP

; Aggiungi byte al buffer dinamico
dbuf_append PROC
    ; AL = byte da aggiungere
    
    PUSH ES
    
    ; Controlla se c'è spazio
    MOV BX, dyn_size
    CMP BX, dyn_capacity
    JL dbuf_has_space
    
    ; Espandi buffer (doppia capacità)
    CALL dbuf_grow
    JC dbuf_append_error
    
dbuf_has_space:
    ; Scrivi byte
    MOV ES, dyn_buffer
    MOV BX, dyn_size
    MOV ES:[BX], AL
    
    INC dyn_size
    CLC
    
    POP ES
    RET
    
dbuf_append_error:
    POP ES
    STC
    RET
dbuf_append ENDP

; Espandi capacità buffer
dbuf_grow PROC
    ; Raddoppia capacità
    
    MOV BX, dyn_capacity
    SHL BX, 1               ; Capacità × 2
    SHR BX, 4               ; Byte → paragraphs
    
    ; Ridimensiona blocco
    MOV AH, 4Ah
    MOV ES, dyn_buffer
    INT 21h
    JC dbuf_grow_error
    
    ; Aggiorna capacità
    MOV BX, dyn_capacity
    SHL BX, 1
    MOV dyn_capacity, BX
    CLC
    RET
    
dbuf_grow_error:
    STC
    RET
dbuf_grow ENDP

; Libera buffer dinamico
dbuf_free PROC
    MOV AH, 49h
    MOV ES, dyn_buffer
    INT 21h
    
    MOV dyn_buffer, 0
    MOV dyn_capacity, 0
    MOV dyn_size, 0
    RET
dbuf_free ENDP
```

## Ottimizzazioni Stringhe

### 1. MOVSW vs MOVSB

Per buffer grandi, usa **MOVSW** quando possibile (copia 2 byte per volta).

```assembly
; ✓ Veloce (copia word)
optimized_copy PROC
    ; SI = src, DI = dst, CX = byte count
    
    PUSH CX
    SHR CX, 1               ; CX = word count
    CLD
    REP MOVSW               ; Copia word
    
    POP CX
    AND CX, 1               ; CX = 1 se dispari
    REP MOVSB               ; Copia byte rimanente (se dispari)
    
    RET
optimized_copy ENDP

; ✗ Lento (copia byte)
slow_copy PROC
    ; CX = byte count
    REP MOVSB               ; ~2× più lento!
    RET
slow_copy ENDP
```

**Prestazioni**:
- MOVSB: ~3 cicli/byte
- MOVSW: ~3 cicli/word = ~1.5 cicli/byte

### 2. Unrolling Loop

Riduce overhead del loop ripetendo il corpo.

```assembly
; ✓ Loop unrolled (4× per iterazione)
fast_fill PROC
    ; DI = buffer, AL = valore, CX = count (multiplo di 4)
    
    SHR CX, 2               ; CX = count / 4
    CLD
    
fill_loop_unrolled:
    STOSB
    STOSB
    STOSB
    STOSB
    LOOP fill_loop_unrolled
    
    RET
fast_fill ENDP

; ✗ Loop normale
normal_fill PROC
    REP STOSB               ; Overhead LOOP ogni byte
    RET
normal_fill ENDP
```

**Vantaggio**: riduce numero di iterazioni (meno `DEC CX, JNZ`).

### 3. Allineamento Memoria

Accessi allineati sono più veloci.

```assembly
.DATA
    EVEN                    ; Allinea a indirizzo pari
    aligned_buffer DW 1000 DUP(?)
    
    ; ✗ Non allineato
    byte_var DB 1
    unaligned_word DW 100   ; Indirizzo dispari!
```

**Regola**: allinea word a indirizzi **pari**, doubleword a multipli di **4**.

### 4. Minimize Memory Access

Usa registri invece di memoria quando possibile.

```assembly
; ✓ Registri (veloce)
fast_sum PROC
    ; SI = array, CX = count
    ; Return: AX = somma
    
    XOR AX, AX              ; Somma in registro
fast_sum_loop:
    ADD AX, [SI]
    ADD SI, 2
    LOOP fast_sum_loop
    
    RET
fast_sum ENDP

; ✗ Memoria (lento)
slow_sum PROC
.DATA
    temp_sum DW 0           ; Somma in memoria
    
.CODE
slow_sum_loop:
    MOV AX, temp_sum
    ADD AX, [SI]
    MOV temp_sum, AX        ; Accesso memoria extra!
    ADD SI, 2
    LOOP slow_sum_loop
    
    RET
slow_sum ENDP
```

## Tecniche di Buffering I/O

### Line Buffering

Accumula caratteri fino a newline prima di processare.

```assembly
.DATA
    line_buffer DB 256 DUP(?)
    line_pos DW 0

.CODE

; Aggiungi carattere a line buffer
line_putchar PROC
    ; AL = carattere
    
    CMP AL, 13              ; CR (Enter)?
    JE line_complete
    
    ; Aggiungi a buffer
    MOV BX, line_pos
    CMP BX, 255
    JAE line_overflow
    
    LEA DI, line_buffer
    MOV [DI+BX], AL
    INC line_pos
    RET
    
line_complete:
    ; Termina linea
    MOV BX, line_pos
    LEA DI, line_buffer
    MOV BYTE PTR [DI+BX], 0
    
    ; Processa linea
    CALL process_line
    
    ; Reset buffer
    MOV line_pos, 0
    RET
    
line_overflow:
    ; Gestisci overflow
    RET
line_putchar ENDP
```

### Block Buffering (File I/O)

Leggi/scrivi blocchi grandi invece di byte singoli.

```assembly
.DATA
    FILE_BLOCK_SIZE EQU 4096
    file_buffer DB FILE_BLOCK_SIZE DUP(?)
    file_handle DW ?
    buffer_pos DW 0
    buffer_valid DW 0       ; Byte validi nel buffer

.CODE

; Leggi byte da file (con buffering)
fgetc PROC
    ; Return: AL = byte, CF = 0/1 (EOF)
    
    ; Controlla se buffer ha dati
    MOV BX, buffer_pos
    CMP BX, buffer_valid
    JL fgetc_from_buffer
    
    ; Ricarica buffer
    CALL refill_buffer
    JC fgetc_eof
    
fgetc_from_buffer:
    LEA SI, file_buffer
    ADD SI, BX
    MOV AL, [SI]
    
    INC buffer_pos
    CLC
    RET
    
fgetc_eof:
    STC
    RET
fgetc ENDP

; Ricarica buffer da file
refill_buffer PROC
    ; Leggi blocco
    MOV AH, 3Fh             ; DOS read
    MOV BX, file_handle
    MOV CX, FILE_BLOCK_SIZE
    LEA DX, file_buffer
    INT 21h
    JC refill_error
    
    ; AX = byte letti
    MOV buffer_valid, AX
    MOV buffer_pos, 0
    
    CMP AX, 0
    JE refill_eof           ; Nessun byte = EOF
    
    CLC
    RET
    
refill_eof:
refill_error:
    STC
    RET
refill_buffer ENDP
```

**Vantaggio**: riduce chiamate DOS (lento) da migliaia a decine.

## Memory Pool

### Concetto

Alloca memoria da un **pool** pre-allocato invece di chiamare DOS ogni volta.

```assembly
.DATA
    POOL_SIZE EQU 10000
    mem_pool DB POOL_SIZE DUP(?)
    pool_used DW 0

.CODE

; Alloca memoria dal pool
pool_alloc PROC
    ; CX = byte richiesti
    ; Return: BX = offset nel pool, CF = 0/1
    
    MOV BX, pool_used
    ADD BX, CX              ; BX = new pool_used
    CMP BX, POOL_SIZE
    JA pool_alloc_fail
    
    ; Allocazione OK
    MOV BX, pool_used       ; BX = offset allocato
    ADD pool_used, CX       ; Aggiorna used
    
    CLC
    RET
    
pool_alloc_fail:
    STC
    RET
pool_alloc ENDP

; Reset pool (dealloca tutto)
pool_reset PROC
    MOV pool_used, 0
    RET
pool_reset ENDP

; Uso:
; MOV CX, 100             ; Richiedi 100 byte
; CALL pool_alloc
; JC no_memory
; ; BX = offset, accedi con mem_pool[BX]
```

**Vantaggio**: allocazione O(1), no overhead DOS.  
**Svantaggio**: no deallocazione selettiva (solo reset totale).

## Copy-on-Write

### Concetto

Condividi buffer tra copie finché uno non viene modificato (risparmia memoria).

```assembly
.DATA?
    str1_ptr DW ?           ; Puntatore logico stringa 1
    str2_ptr DW ?           ; Puntatore logico stringa 2
    shared_buffer DB 256 DUP(?)
    ref_count DW 0          ; Numero riferimenti

.CODE

; Crea riferimento (no copia fisica)
str_ref PROC
    ; Return: AX = nuovo riferimento
    
    INC ref_count
    LEA AX, shared_buffer
    RET
str_ref ENDP

; Modifica stringa (copy-on-write)
str_write PROC
    ; BX = stringa da modificare, AL = nuovo byte, DI = offset
    
    ; Se ref_count > 1, copia buffer
    CMP ref_count, 1
    JE str_write_inplace
    
    ; Copia buffer (COW)
    CALL allocate_new_buffer
    ; ... copia shared_buffer in nuovo buffer ...
    DEC ref_count
    ; ... aggiorna BX al nuovo buffer ...
    
str_write_inplace:
    ; Scrivi byte
    MOV [BX+DI], AL
    RET
str_write ENDP
```

## Prevenzione Errori

### 1. Buffer Overflow Check

```assembly
safe_append PROC
    ; SI = src, DI = dest buffer, CX = dest capacity, BX = current size
    ; Return: AX = new size, CF = overflow
    
    PUSH BX
    
safe_append_loop:
    LODSB
    TEST AL, AL
    JZ safe_append_ok
    
    ; Controlla spazio
    CMP BX, CX
    JAE safe_append_overflow
    
    MOV [DI+BX], AL
    INC BX
    JMP safe_append_loop
    
safe_append_ok:
    MOV [DI+BX], 0          ; Null terminator
    MOV AX, BX
    POP BX
    CLC
    RET
    
safe_append_overflow:
    MOV AX, BX
    POP BX
    STC
    RET
safe_append ENDP
```

### 2. Memory Leak Prevention

```assembly
; ✓ Traccia allocazioni
.DATA
    alloc_count DW 0
    alloc_list DW 100 DUP(?)    ; Lista segmenti allocati

.CODE
tracked_alloc PROC
    ; BX = paragraphs
    ; Return: AX = segmento
    
    MOV AH, 48h
    INT 21h
    JC tracked_alloc_fail
    
    ; Aggiungi a lista
    MOV BX, alloc_count
    SHL BX, 1
    LEA DI, alloc_list
    MOV [DI+BX], AX
    
    INC alloc_count
    CLC
    RET
    
tracked_alloc_fail:
    STC
    RET
tracked_alloc ENDP

; Libera tutte le allocazioni
free_all PROC
    MOV CX, alloc_count
    XOR BX, BX
    
free_all_loop:
    LEA SI, alloc_list
    SHL BX, 1
    MOV ES, [SI+BX]
    
    MOV AH, 49h
    INT 21h
    
    SHR BX, 1
    INC BX
    LOOP free_all_loop
    
    MOV alloc_count, 0
    RET
free_all ENDP
```

### 3. Null Pointer Check

```assembly
safe_deref PROC
    ; BX = puntatore
    ; Return: AL = valore, CF = 1 se null
    
    TEST BX, BX
    JZ safe_deref_null
    
    MOV AL, [BX]
    CLC
    RET
    
safe_deref_null:
    STC
    RET
safe_deref ENDP
```

## Best Practices

### 1. Validazione Input Size

```assembly
✓ Sempre controlla dimensioni:
    CMP CX, MAX_SIZE
    JA input_too_large
    
✗ Assumere dimensione:
    ; Cosa succede se CX > buffer?
    REP MOVSB               ; Overflow!
```

### 2. Inizializza Buffer

```assembly
✓ Zero-fill buffer sensibili:
    LEA DI, password_buffer
    MOV CX, 256
    XOR AL, AL
    REP STOSB
    
✗ Usare buffer non inizializzato:
    ; Contiene dati precedenti!
```

### 3. Usa Const per Dimensioni

```assembly
✓ Costanti:
    BUFFER_SIZE EQU 1024
    buffer DB BUFFER_SIZE DUP(?)
    
✗ Magic numbers:
    buffer DB 1024 DUP(?)
    MOV CX, 1024            ; Cambiare in due posti!
```

### 4. Testa Casi Limite

```assembly
; Testa:
; - Buffer vuoto
; - Buffer pieno
; - Singolo elemento
; - Capacità massima
; - Overflow intenzionale
```

## Esercizi Pratici

1. Implementa buffer circolare thread-safe (con lock)
2. Crea memory pool con deallocazione selettiva (linked list)
3. Implementa cache LRU (Least Recently Used) per stringhe
4. Buffer dinamico con shrinking (riduce capacità se sottoutilizzato)
5. Implementa compressione RLE (Run-Length Encoding) su buffer

### Soluzione Esercizio 5 (RLE Compression)

```assembly
; Run-Length Encoding: "AAABBC" → "3A2B1C"
rle_compress PROC
    ; SI = input, DI = output
    ; Return: CX = byte output
    
    XOR CX, CX              ; Contatore output
    CLD
    
rle_loop:
    LODSB                   ; AL = carattere corrente
    TEST AL, AL
    JZ rle_done
    
    MOV BL, AL              ; BL = carattere
    MOV BH, 1               ; BH = contatore
    
    ; Conta occorrenze consecutive
rle_count:
    CMP BYTE PTR [SI], BL
    JNE rle_write
    CMP BH, 255             ; Max count
    JAE rle_write
    
    INC BH
    INC SI
    JMP rle_count
    
rle_write:
    ; Scrivi count
    MOV AL, BH
    ADD AL, '0'             ; Converti a ASCII (se < 10)
    STOSB
    INC CX
    
    ; Scrivi carattere
    MOV AL, BL
    STOSB
    INC CX
    
    JMP rle_loop
    
rle_done:
    MOV BYTE PTR [DI], 0    ; Termina
    ; CX = lunghezza output
    RET
rle_compress ENDP
```

---

**Prossimo argomento:** [Quiz Modulo 5](modulo5_05_quiz.md)
