# Manipolazione Avanzata di Stringhe

## Introduzione

Questo modulo presenta tecniche avanzate per manipolare stringhe in assembly 8086, combinando le istruzioni base (MOVS, CMPS, SCAS, LODS, STOS) con algoritmi più complessi.

### Obiettivi

- Implementare funzioni string.h (strlen, strcpy, strcmp, strcat, ...)
- Convertire stringhe (maiuscolo/minuscolo, trim, reverse)
- Cercare e sostituire pattern
- Tokenizzazione e parsing
- Conversione numeri ↔ stringhe
- Gestione buffer e sicurezza

## Funzioni Classiche String.h

### strlen - Lunghezza Stringa

Calcola lunghezza stringa (escluso null terminator).

```assembly
strlen PROC
    ; DI = puntatore stringa
    ; Return: CX = lunghezza
    
    PUSH DI
    XOR AL, AL              ; Cerca null (0)
    MOV CX, 0FFFFh          ; Lunghezza max
    CLD
    REPNE SCASB             ; Cerca fino a trovare 0
    
    NOT CX                  ; CX = ~CX
    DEC CX                  ; CX = lunghezza (escluso null)
    
    POP DI
    RET
strlen ENDP

; Esempio uso:
; LEA DI, stringa
; CALL strlen
; ; CX = lunghezza
```

### strcpy - Copia Stringa

Copia stringa sorgente in destinazione (incluso null).

```assembly
strcpy PROC
    ; SI = sorgente, DI = destinazione
    
    CLD
strcpy_loop:
    LODSB                   ; AL = [SI], SI++
    STOSB                   ; [DI] = AL, DI++
    TEST AL, AL
    JNZ strcpy_loop         ; Continua se AL ≠ 0
    
    RET
strcpy ENDP
```

**Versione sicura** (con limite):

```assembly
strncpy PROC
    ; SI = src, DI = dest, CX = max lunghezza
    
    CLD
strncpy_loop:
    LODSB
    STOSB
    TEST AL, AL
    JZ done_strncpy         ; Trovato null, fine
    LOOP strncpy_loop       ; Continua se CX > 0
    
    ; Se qui, raggiunto limite senza null
    MOV BYTE PTR [DI-1], 0  ; Termina con null
    
done_strncpy:
    RET
strncpy ENDP
```

### strcmp - Confronta Stringhe

Confronta due stringhe lessicograficamente.

```assembly
strcmp PROC
    ; SI = str1, DI = str2
    ; Return: AL = 0 (uguali), AL < 0 (str1 < str2), AL > 0 (str1 > str2)
    
    CLD
strcmp_loop:
    LODSB                   ; AL = [SI], SI++
    CMP AL, [ES:DI]
    JNE non_uguali
    
    INC DI
    TEST AL, AL
    JNZ strcmp_loop         ; Continua se non null
    
    ; Uguali (entrambi terminati)
    XOR AL, AL
    RET
    
non_uguali:
    SUB AL, [ES:DI-1]       ; AL = str1[i] - str2[i]
    RET
strcmp ENDP
```

**Versione ottimizzata con CMPSB**:

```assembly
strcmp_fast PROC
    ; SI = str1, DI = str2
    
    CLD
cmp_fast_loop:
    CMPSB                   ; Confronta [SI] con [DI], SI++, DI++
    JNE diversi
    
    ; Verifica se era null (fine)
    CMP BYTE PTR [SI-1], 0
    JNE cmp_fast_loop
    
    ; Uguali
    XOR AL, AL
    RET
    
diversi:
    MOV AL, [SI-1]
    SUB AL, [DI-1]
    RET
strcmp_fast ENDP
```

### strcat - Concatena Stringhe

Appende src alla fine di dest.

```assembly
strcat PROC
    ; DI = dest, SI = src
    
    PUSH DI
    
    ; Trova fine di dest
    XOR AL, AL
    MOV CX, 0FFFFh
    CLD
    REPNE SCASB             ; DI punta a DOPO null
    DEC DI                  ; DI ora punta al null
    
    ; Copia src a partire da DI
strcat_copy:
    LODSB
    STOSB
    TEST AL, AL
    JNZ strcat_copy
    
    POP DI
    RET
strcat ENDP
```

### strchr - Cerca Carattere

Trova prima occorrenza di carattere in stringa.

```assembly
strchr PROC
    ; SI = stringa, AL = carattere da cercare
    ; Return: SI = indirizzo prima occorrenza (o null se non trovato)
    
    MOV BL, AL              ; Salva carattere
    CLD
    
strchr_loop:
    LODSB                   ; AL = [SI], SI++
    CMP AL, BL
    JE trovato_chr
    
    TEST AL, AL
    JNZ strchr_loop
    
    ; Non trovato
    XOR SI, SI              ; Return null
    RET
    
trovato_chr:
    DEC SI                  ; SI punta al carattere trovato
    RET
strchr ENDP
```

### strstr - Cerca Sottostringa

Trova prima occorrenza di sottostringa in stringa.

```assembly
strstr PROC
    ; SI = stringa (haystack), DI = sottostringa (needle)
    ; Return: SI = indirizzo prima occorrenza (o null)
    
    PUSH DI
    
    ; Calcola lunghezza needle
    PUSH SI
    MOV SI, DI
    CALL strlen_internal    ; CX = lunghezza needle
    MOV BX, CX              ; BX = lunghezza needle
    POP SI
    
    CMP BX, 0
    JE trovato_strstr       ; Needle vuoto = sempre trovato
    
strstr_outer:
    ; Cerca primo carattere di needle
    MOV AL, [DI]
    CALL strchr_from_SI     ; Cerca AL a partire da SI
    TEST SI, SI
    JZ non_trovato_strstr   ; Non trovato
    
    ; Confronta intera sottostringa
    PUSH SI
    PUSH DI
    MOV CX, BX              ; CX = lunghezza needle
    REPE CMPSB              ; Confronta CX byte
    POP DI
    POP SI
    
    JE trovato_strstr       ; Tutte uguali, trovato!
    
    ; Continua ricerca dal prossimo carattere
    INC SI
    JMP strstr_outer
    
trovato_strstr:
    POP DI
    RET
    
non_trovato_strstr:
    XOR SI, SI
    POP DI
    RET
strstr ENDP
```

## Conversioni Stringhe

### Maiuscolo / Minuscolo

**toupper** - Singolo carattere:

```assembly
toupper PROC
    ; AL = carattere
    ; Return: AL = carattere maiuscolo
    
    CMP AL, 'a'
    JL not_lowercase
    CMP AL, 'z'
    JG not_lowercase
    
    SUB AL, 32              ; 'a' - 'A' = 32
    
not_lowercase:
    RET
toupper ENDP
```

**strupr** - Intera stringa:

```assembly
strupr PROC
    ; SI = stringa (modificata in-place)
    
    CLD
strupr_loop:
    LODSB
    TEST AL, AL
    JZ done_strupr
    
    ; Converti in maiuscolo
    CMP AL, 'a'
    JL non_lower
    CMP AL, 'z'
    JG non_lower
    SUB AL, 32
    MOV [SI-1], AL          ; Scrivi di nuovo
    
non_lower:
    JMP strupr_loop
    
done_strupr:
    RET
strupr ENDP
```

**strlwr** - Stringa in minuscolo:

```assembly
strlwr PROC
    ; SI = stringa
    
    CLD
strlwr_loop:
    LODSB
    TEST AL, AL
    JZ done_strlwr
    
    CMP AL, 'A'
    JL non_upper
    CMP AL, 'Z'
    JG non_upper
    ADD AL, 32              ; 'a' - 'A' = 32
    MOV [SI-1], AL
    
non_upper:
    JMP strlwr_loop
    
done_strlwr:
    RET
strlwr ENDP
```

### Invertire Stringa

```assembly
strrev PROC
    ; SI = stringa (modificata in-place)
    
    PUSH SI
    
    ; Trova lunghezza
    LEA DI, [SI]
    CALL strlen             ; CX = lunghezza
    
    ; DI punta all'ultimo carattere
    ADD DI, CX
    DEC DI
    
    ; Scambia metà stringa
    SHR CX, 1               ; CX /= 2
    
strrev_loop:
    MOV AL, [SI]
    MOV BL, [DI]
    MOV [SI], BL
    MOV [DI], AL
    
    INC SI
    DEC DI
    LOOP strrev_loop
    
    POP SI
    RET
strrev ENDP
```

### Trim (Rimuovi Spazi)

**ltrim** - Rimuovi spazi a sinistra:

```assembly
ltrim PROC
    ; SI = stringa
    ; Return: SI = primo carattere non-spazio
    
    CLD
ltrim_loop:
    LODSB
    CMP AL, ' '
    JE ltrim_loop
    CMP AL, 9               ; TAB
    JE ltrim_loop
    
    ; Trovato primo non-spazio
    DEC SI
    RET
ltrim ENDP
```

**rtrim** - Rimuovi spazi a destra:

```assembly
rtrim PROC
    ; SI = stringa (modificata in-place)
    
    PUSH SI
    
    ; Trova fine stringa
    LEA DI, [SI]
    CALL strlen
    ADD DI, CX              ; DI punta al null
    
    ; Torna indietro fino a non-spazio
rtrim_loop:
    DEC DI
    CMP DI, SI
    JL done_rtrim           ; Inizio stringa
    
    MOV AL, [DI]
    CMP AL, ' '
    JE rtrim_loop
    CMP AL, 9
    JE rtrim_loop
    
    ; Trovato ultimo non-spazio
    INC DI
    MOV BYTE PTR [DI], 0    ; Nuovo null terminator
    
done_rtrim:
    POP SI
    RET
rtrim ENDP
```

**trim** - Entrambi i lati:

```assembly
trim PROC
    ; SI = stringa
    
    CALL ltrim              ; SI aggiornato
    CALL rtrim
    RET
trim ENDP
```

## Conversione Numeri ↔ Stringhe

### atoi - String to Integer (ASCII to Integer)

Converte stringa decimale in numero.

```assembly
atoi PROC
    ; SI = stringa (es. "123", "-456")
    ; Return: AX = numero
    
    XOR AX, AX              ; Risultato = 0
    XOR CX, CX              ; Segno = 0 (positivo)
    CLD
    
    ; Salta spazi iniziali
atoi_skip_space:
    LODSB
    CMP AL, ' '
    JE atoi_skip_space
    CMP AL, 9
    JE atoi_skip_space
    
    ; Controlla segno
    CMP AL, '-'
    JNE atoi_check_plus
    MOV CX, 1               ; Segno negativo
    LODSB
    JMP atoi_digits
    
atoi_check_plus:
    CMP AL, '+'
    JNE atoi_digits
    LODSB                   ; Salta '+'
    
atoi_digits:
    ; Processa cifre
    CMP AL, '0'
    JL atoi_done
    CMP AL, '9'
    JG atoi_done
    
    ; AX = AX × 10 + (AL - '0')
    SUB AL, '0'             ; Converte ASCII a valore
    MOV BX, AX
    MOV AX, 10
    MUL BX                  ; AX = vecchio_AX × 10
    XOR BH, BH
    MOV BL, AL_salvato      ; BX = cifra
    ADD AX, BX
    
    LODSB
    JMP atoi_digits
    
atoi_done:
    ; Applica segno
    TEST CX, CX
    JZ atoi_positive
    NEG AX
    
atoi_positive:
    RET
atoi ENDP
```

**Versione semplificata** (solo positivi):

```assembly
atoi_simple PROC
    ; SI = stringa (solo cifre, es. "123")
    ; Return: AX = numero
    
    XOR AX, AX              ; Risultato = 0
    XOR BX, BX
    CLD
    
atoi_s_loop:
    LODSB
    CMP AL, '0'
    JL atoi_s_done
    CMP AL, '9'
    JG atoi_s_done
    
    ; AX = AX × 10 + (AL - '0')
    SUB AL, '0'
    MOV BL, AL
    
    MOV DX, AX              ; Salva AX
    MOV AX, 10
    MUL DX                  ; AX = DX × 10
    ADD AX, BX              ; AX += cifra
    
    JMP atoi_s_loop
    
atoi_s_done:
    RET
atoi_simple ENDP
```

### itoa - Integer to String (Integer to ASCII)

Converte numero in stringa decimale.

```assembly
itoa PROC
    ; AX = numero, DI = buffer output
    ; Return: DI punta a stringa
    
    PUSH DI
    
    ; Gestisci zero
    TEST AX, AX
    JNZ itoa_not_zero
    MOV BYTE PTR [DI], '0'
    MOV BYTE PTR [DI+1], 0
    POP DI
    RET
    
itoa_not_zero:
    ; Gestisci segno negativo
    TEST AX, AX
    JNS itoa_positive
    
    MOV BYTE PTR [DI], '-'
    INC DI
    NEG AX                  ; AX = |AX|
    
itoa_positive:
    ; Converti cifre (in ordine inverso)
    MOV SI, DI              ; Salva inizio cifre
    MOV BX, 10
    
itoa_digit_loop:
    XOR DX, DX
    DIV BX                  ; AX = AX / 10, DX = AX % 10
    
    ADD DL, '0'             ; Converte a ASCII
    MOV [DI], DL
    INC DI
    
    TEST AX, AX
    JNZ itoa_digit_loop
    
    ; Termina stringa
    MOV BYTE PTR [DI], 0
    
    ; Inverti cifre (sono al contrario)
    DEC DI                  ; DI punta all'ultima cifra
itoa_reverse:
    CMP SI, DI
    JGE itoa_done
    
    MOV AL, [SI]
    MOV BL, [DI]
    MOV [SI], BL
    MOV [DI], AL
    
    INC SI
    DEC DI
    JMP itoa_reverse
    
itoa_done:
    POP DI
    RET
itoa ENDP
```

**Versione ottimizzata** (push cifre nello stack):

```assembly
itoa_stack PROC
    ; AX = numero, DI = buffer
    
    PUSH DI
    MOV BX, 10
    XOR CX, CX              ; Contatore cifre
    
    ; Estrai cifre (stack = LIFO, ordine corretto!)
itoa_st_push:
    XOR DX, DX
    DIV BX                  ; DX = AX % 10
    PUSH DX                 ; Salva cifra
    INC CX
    
    TEST AX, AX
    JNZ itoa_st_push
    
    ; Pop cifre in ordine corretto
itoa_st_pop:
    POP AX
    ADD AL, '0'
    STOSB                   ; [DI] = AL, DI++
    LOOP itoa_st_pop
    
    ; Termina
    MOV BYTE PTR [DI], 0
    
    POP DI
    RET
itoa_stack ENDP
```

### Conversione Esadecimale

**Numero → Hex string**:

```assembly
itoh PROC
    ; AX = numero, DI = buffer (es. "1A3F")
    
    PUSH DI
    MOV CX, 4               ; 4 hex digits
    
itoh_loop:
    ROL AX, 4               ; Porta nibble alto in basso
    PUSH AX
    AND AL, 0Fh             ; Isola 4 bit bassi
    
    ; Converti a hex ASCII
    CMP AL, 10
    JL itoh_decimal
    ADD AL, 'A' - 10        ; A-F
    JMP itoh_store
itoh_decimal:
    ADD AL, '0'             ; 0-9
    
itoh_store:
    STOSB
    POP AX
    LOOP itoh_loop
    
    MOV BYTE PTR [DI], 0
    POP DI
    RET
itoh ENDP
```

**Hex string → Numero**:

```assembly
htoi PROC
    ; SI = stringa hex (es. "1A3F"), Return: AX = numero
    
    XOR AX, AX
    CLD
    
htoi_loop:
    LODSB
    
    ; Fine stringa?
    TEST AL, AL
    JZ htoi_done
    
    ; Shift risultato di 4 bit
    SHL AX, 4
    
    ; Converti ASCII a valore
    CMP AL, '0'
    JL htoi_done
    CMP AL, '9'
    JG htoi_check_alpha
    
    SUB AL, '0'
    JMP htoi_add
    
htoi_check_alpha:
    ; A-F o a-f
    AND AL, 0DFh            ; Maiuscolo
    CMP AL, 'A'
    JL htoi_done
    CMP AL, 'F'
    JG htoi_done
    
    SUB AL, 'A' - 10
    
htoi_add:
    OR AL, AL               ; Aggiungi nibble
    JMP htoi_loop
    
htoi_done:
    RET
htoi ENDP
```

## Tokenizzazione

### strtok - Split String by Delimiter

```assembly
strtok PROC
    ; SI = stringa (null per continuare), AL = delimitatore
    ; Return: SI = token (null se fine)
    ; Usa variabile statica per stato
    
    .DATA?
        strtok_pos DW ?     ; Posizione corrente
    
    .CODE
    ; Prima chiamata?
    TEST SI, SI
    JNZ strtok_first
    
    ; Continuazione: usa posizione salvata
    MOV SI, strtok_pos
    TEST SI, SI
    JZ strtok_no_more       ; Fine
    
strtok_first:
    ; Salta delimitatori iniziali
    MOV BL, AL              ; Salva delimitatore
strtok_skip:
    MOV AL, [SI]
    TEST AL, AL
    JZ strtok_no_more       ; Fine stringa
    CMP AL, BL
    JNE strtok_found_start
    INC SI
    JMP strtok_skip
    
strtok_found_start:
    ; SI punta all'inizio del token
    PUSH SI                 ; Salva inizio
    
    ; Cerca fine token (prossimo delimitatore o null)
strtok_find_end:
    INC SI
    MOV AL, [SI]
    TEST AL, AL
    JZ strtok_end_null
    CMP AL, BL
    JNE strtok_find_end
    
    ; Trovato delimitatore
    MOV BYTE PTR [SI], 0    ; Termina token
    INC SI
    MOV strtok_pos, SI      ; Salva posizione
    POP SI                  ; Ritorna inizio token
    RET
    
strtok_end_null:
    ; Fine stringa
    MOV strtok_pos, 0       ; Nessun altro token
    POP SI
    RET
    
strtok_no_more:
    XOR SI, SI              ; Return null
    RET
strtok ENDP

; Esempio uso:
; LEA SI, stringa
; MOV AL, ','
; CALL strtok             ; SI = primo token
; XOR SI, SI
; CALL strtok             ; SI = secondo token
; ...
```

## Sicurezza e Gestione Errori

### Buffer Overflow Prevention

```assembly
safe_strcpy PROC
    ; SI = src, DI = dest, CX = dest size (incluso null)
    ; Return: AL = 0 (OK), AL = 1 (overflow, troncato)
    
    DEC CX                  ; Riserva spazio per null
    XOR AL, AL              ; Assume OK
    CLD
    
safe_strcpy_loop:
    TEST CX, CX
    JZ safe_strcpy_overflow
    
    LODSB
    STOSB
    TEST AL, AL
    JZ safe_strcpy_ok       ; Copiato tutto
    
    DEC CX
    JMP safe_strcpy_loop
    
safe_strcpy_overflow:
    MOV BYTE PTR [DI], 0    ; Termina
    MOV AL, 1               ; Overflow
    RET
    
safe_strcpy_ok:
    XOR AL, AL              ; OK
    RET
safe_strcpy ENDP
```

### Validazione Input

```assembly
is_valid_int_string PROC
    ; SI = stringa
    ; Return: AL = 1 (valido), AL = 0 (invalido)
    
    CLD
    
    ; Salta spazi
is_valid_skip:
    LODSB
    CMP AL, ' '
    JE is_valid_skip
    
    ; Segno opzionale
    CMP AL, '-'
    JE is_valid_sign_ok
    CMP AL, '+'
    JE is_valid_sign_ok
    JMP is_valid_check_digit
    
is_valid_sign_ok:
    LODSB
    
is_valid_check_digit:
    ; Deve esserci almeno una cifra
    CMP AL, '0'
    JL is_valid_false
    CMP AL, '9'
    JG is_valid_false
    
    ; Altre cifre
is_valid_digit_loop:
    LODSB
    TEST AL, AL
    JZ is_valid_true        ; Fine: valido
    
    CMP AL, '0'
    JL is_valid_false
    CMP AL, '9'
    JG is_valid_false
    
    JMP is_valid_digit_loop
    
is_valid_true:
    MOV AL, 1
    RET
    
is_valid_false:
    XOR AL, AL
    RET
is_valid_int_string ENDP
```

## Best Practices

### 1. Sempre Terminare Stringhe

```assembly
✓ Null terminator:
    MOV BYTE PTR [DI], 0
    
✗ Dimenticato:
    ; Stringa senza null → strlen infinito loop!
```

### 2. Controlla Dimensioni Buffer

```assembly
✓ Usa versioni "n" (strncpy, strncat):
    MOV CX, buffer_size
    CALL strncpy
    
✗ Overflow:
    ; strcpy senza limite → buffer overflow!
```

### 3. Preserva Registri

```assembly
✓ Salva/ripristina:
    PUSH SI
    PUSH DI
    ; ... usa SI, DI ...
    POP DI
    POP SI
```

### 4. Valida Input

```assembly
✓ Controlla prima di convertire:
    CALL is_valid_int_string
    TEST AL, AL
    JZ input_invalido
    CALL atoi
```

## Esercizi Pratici

1. Implementa `strdup` (duplica stringa con allocazione dinamica)
2. Implementa `substr` (estrai sottostringa da indice a indice)
3. Conta parole in una stringa
4. Rimuovi caratteri duplicati consecutivi (es. "aabbcc" → "abc")
5. Implementa ricerca case-insensitive (`stristr`)
6. Converti numero binario stringa → intero

### Soluzione Esercizio 3 (Conta parole)

```assembly
word_count PROC
    ; SI = stringa
    ; Return: CX = numero parole
    
    XOR CX, CX              ; Contatore parole = 0
    XOR BX, BX              ; Flag: 0 = fuori parola, 1 = dentro
    CLD
    
wc_loop:
    LODSB
    TEST AL, AL
    JZ wc_done
    
    ; Spazio o tab?
    CMP AL, ' '
    JE wc_delim
    CMP AL, 9
    JE wc_delim
    
    ; Carattere di parola
    TEST BX, BX
    JNZ wc_loop             ; Già dentro parola
    
    ; Inizio nuova parola
    INC CX
    MOV BX, 1               ; Flag dentro parola
    JMP wc_loop
    
wc_delim:
    XOR BX, BX              ; Flag fuori parola
    JMP wc_loop
    
wc_done:
    ; CX = numero parole
    RET
word_count ENDP
```

---

**Prossimo argomento:** [Gestione Buffer e Performance](04_buffer_performance.md)
