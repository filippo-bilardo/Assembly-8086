# Istruzioni per Stringhe

## Introduzione

L'8086 offre **istruzioni specializzate** per operazioni su stringhe (sequenze di byte o word in memoria). Queste istruzioni sono **molto più efficienti** di loop espliciti e si combinano con i prefissi **REP** per elaborare interi blocchi di dati automaticamente.

### Caratteristiche

- **Auto-incremento/decremento**: SI/DI aggiornati automaticamente
- **Prefissi REP**: ripetizione automatica (loop hardware)
- **Direction Flag (DF)**: controlla direzione (avanti/indietro)
- **Operazioni**: copia, confronto, ricerca, caricamento, memorizzazione

### Registri Coinvolti

- **SI** (Source Index): puntatore sorgente
- **DI** (Destination Index): puntatore destinazione
- **CX**: contatore per REP
- **DS:SI**: indirizzo sorgente (tipicamente)
- **ES:DI**: indirizzo destinazione (sempre ES!)
- **AL/AX**: accumulatore per LODS/STOS/SCAS

### Direction Flag (DF)

**DF = 0**: incremento (stringhe processate da sinistra a destra)  
**DF = 1**: decremento (stringhe processate da destra a sinistra)

**Istruzioni**:
```assembly
CLD             ; Clear Direction Flag (DF = 0, incremento)
STD             ; Set Direction Flag (DF = 1, decremento)
```

**Comportamento**:
```assembly
CLD             ; DF = 0
; SI++, DI++ dopo ogni operazione byte
; SI += 2, DI += 2 dopo ogni operazione word

STD             ; DF = 1
; SI--, DI-- dopo ogni operazione byte
; SI -= 2, DI -= 2 dopo ogni operazione word
```

## MOVS - Move String

### Sintassi

```assembly
MOVSB           ; Move String Byte: [ES:DI] = [DS:SI], poi SI++/DI++
MOVSW           ; Move String Word: [ES:DI] = [DS:SI], poi SI+=2/DI+=2
```

### Operazione

**MOVSB**:
```assembly
MOVSB
; Equivalente a:
; MOV AL, [DS:SI]
; MOV [ES:DI], AL
; SI = SI ± 1 (dipende da DF)
; DI = DI ± 1
```

**MOVSW**:
```assembly
MOVSW
; Equivalente a:
; MOV AX, [DS:SI]
; MOV [ES:DI], AX
; SI = SI ± 2
; DI = DI ± 2
```

### Esempio: Copia Singolo Elemento

```assembly
.DATA
    src DB 'A'
    dst DB ?

.CODE
    MOV AX, @DATA
    MOV DS, AX
    MOV ES, AX              ; ES = DS (stesso segmento)
    
    LEA SI, src
    LEA DI, dst
    CLD                     ; Incremento
    MOVSB                   ; dst = src = 'A'
    ; SI e DI incrementati di 1
```

### Con Prefisso REP

**REP MOVSB/MOVSW**: ripete MOVS per CX volte.

```assembly
REP MOVSB
; Equivalente a:
; loop:
;   MOVSB
;   DEC CX
;   JNZ loop
```

**Esempio: Copia Array**:
```assembly
.DATA
    source DB 'Hello, World!', 0
    dest DB 14 DUP(?)

.CODE
    MOV AX, @DATA
    MOV DS, AX
    MOV ES, AX
    
    LEA SI, source
    LEA DI, dest
    MOV CX, 14              ; Lunghezza (13 char + null)
    CLD
    REP MOVSB               ; Copia tutti i 14 byte
    ; Ora dest = "Hello, World!\0"
```

### Copia Word

```assembly
.DATA
    src_array DW 10, 20, 30, 40, 50
    dst_array DW 5 DUP(?)

.CODE
    MOV AX, @DATA
    MOV DS, AX
    MOV ES, AX
    
    LEA SI, src_array
    LEA DI, dst_array
    MOV CX, 5               ; 5 word
    CLD
    REP MOVSW               ; Copia 10 byte (5 word)
```

## CMPS - Compare String

### Sintassi

```assembly
CMPSB           ; Compare String Byte: confronta [DS:SI] con [ES:DI]
CMPSW           ; Compare String Word
```

### Operazione

**CMPSB**:
```assembly
CMPSB
; Equivalente a:
; CMP [DS:SI], [ES:DI]    ; Sottrazione, aggiorna flag
; SI = SI ± 1
; DI = DI ± 1
```

**Flag aggiornati**: ZF, SF, CF, OF, AF, PF (come CMP).

### Esempio: Confronto Singolo Byte

```assembly
.DATA
    str1 DB 'A'
    str2 DB 'B'

.CODE
    LEA SI, str1
    LEA DI, str2
    CLD
    CMPSB                   ; Confronta 'A' con 'B'
    JE uguali               ; Non salta (A ≠ B)
    JL str1_minore          ; Salta ('A' < 'B')
```

### Con Prefisso REPE/REPNE

**REPE CMPSB** (REPeat while Equal): ripete finché CX≠0 **AND** ZF=1 (uguali).  
**REPNE CMPSB** (REPeat while Not Equal): ripete finché CX≠0 **AND** ZF=0 (diversi).

**Alias**:
- **REPE** = **REPZ** (REPeat while Zero)
- **REPNE** = **REPNZ** (REPeat while Not Zero)

```assembly
REPE CMPSB
; Equivalente a:
; loop:
;   CMPSB
;   DEC CX
;   JZ continua         ; Se ZF=1 (uguali), continua
;   JMP fine
; continua:
;   CMP CX, 0
;   JNZ loop
; fine:
```

### Esempio: Confronto Stringhe

```assembly
; Confronta due stringhe
.DATA
    string1 DB 'Hello', 0
    string2 DB 'Hello', 0
    string3 DB 'World', 0

.CODE
    ; Confronta string1 e string2
    LEA SI, string1
    LEA DI, string2
    MOV CX, 5               ; Lunghezza
    CLD
    REPE CMPSB              ; Confronta finché uguali
    JE sono_uguali          ; Se finito con ZF=1, uguali
    ; Altrimenti, diverse
    
sono_uguali:
    ; string1 == string2
```

**Attenzione**: se le stringhe sono uguali, REPE termina con CX=0 e ZF=1.  
Se diverse, REPE termina con CX>0 e ZF=0.

### Determinare Quale Stringa è Maggiore

```assembly
compare_strings PROC
    ; SI = stringa1, DI = stringa2, CX = lunghezza
    CLD
    REPE CMPSB
    JE equal                ; Uguali
    JA str1_greater         ; string1 > string2 (unsigned)
    ; Altrimenti string1 < string2
    MOV AL, -1              ; return -1
    JMP fine_cmp
str1_greater:
    MOV AL, 1               ; return 1
    JMP fine_cmp
equal:
    MOV AL, 0               ; return 0
fine_cmp:
    RET
compare_strings ENDP
```

## SCAS - Scan String

### Sintassi

```assembly
SCASB           ; Scan String Byte: confronta AL con [ES:DI]
SCASW           ; Scan String Word: confronta AX con [ES:DI]
```

### Operazione

**SCASB**:
```assembly
SCASB
; Equivalente a:
; CMP AL, [ES:DI]         ; Sottrazione, aggiorna flag
; DI = DI ± 1
```

**Nota**: confronta **accumulatore** (AL/AX) con memoria, **solo DI** incrementato (non SI).

### Esempio: Cerca Carattere

```assembly
.DATA
    stringa DB 'Hello, World!', 0

.CODE
    MOV AX, @DATA
    MOV ES, AX
    
    LEA DI, stringa
    MOV AL, 'W'             ; Cerca 'W'
    MOV CX, 13              ; Lunghezza stringa
    CLD
    REPNE SCASB             ; Ripeti finché AL ≠ [ES:DI]
    JE trovato              ; Se ZF=1, trovato
    ; Non trovato
    JMP fine_cerca
    
trovato:
    ; DI punta a DOPO 'W'
    DEC DI                  ; DI ora punta a 'W'
    ; Posizione = DI - OFFSET stringa
fine_cerca:
```

### Lunghezza Stringa (Cerca Null)

```assembly
; Calcola lunghezza stringa terminata da null
strlen PROC
    ; DI punta alla stringa
    XOR AL, AL              ; AL = 0 (cerca null)
    MOV CX, 0FFFFh          ; Lunghezza massima (65535)
    CLD
    REPNE SCASB             ; Cerca fino a trovare 0
    
    ; CX contiene quanti byte RIMANGONO (dopo null)
    ; Lunghezza = 0FFFFh - CX - 1
    NOT CX                  ; CX = ~CX = 0FFFFh - CX
    DEC CX                  ; CX = lunghezza (esclude null)
    ; Oppure più semplice:
    ; MOV AX, 0FFFFh
    ; SUB AX, CX
    ; DEC AX
    
    RET
strlen ENDP
```

## LODS - Load String

### Sintassi

```assembly
LODSB           ; Load String Byte: AL = [DS:SI], SI++
LODSW           ; Load String Word: AX = [DS:SI], SI += 2
```

### Operazione

**LODSB**:
```assembly
LODSB
; Equivalente a:
; MOV AL, [DS:SI]
; SI = SI ± 1
```

**Nota**: carica da **DS:SI** in **AL/AX**, incrementa **solo SI**.

### Esempio: Elabora Stringa

```assembly
.DATA
    input DB 'Hello', 0

.CODE
    LEA SI, input
    CLD
    
loop_elabora:
    LODSB                   ; AL = [SI], SI++
    TEST AL, AL
    JZ fine_loop            ; Se null, fine
    
    ; Elabora carattere in AL
    ; (es. converti in maiuscolo)
    CMP AL, 'a'
    JL non_minuscola
    CMP AL, 'z'
    JG non_minuscola
    SUB AL, 32              ; Maiuscolo
non_minuscola:
    
    ; Stampa AL (codice omesso)
    
    JMP loop_elabora
fine_loop:
```

**Raramente usato con REP** (nessun output automatico).

## STOS - Store String

### Sintassi

```assembly
STOSB           ; Store String Byte: [ES:DI] = AL, DI++
STOSW           ; Store String Word: [ES:DI] = AX, DI += 2
```

### Operazione

**STOSB**:
```assembly
STOSB
; Equivalente a:
; MOV [ES:DI], AL
; DI = DI ± 1
```

**Nota**: memorizza **AL/AX** in **ES:DI**, incrementa **solo DI**.

### Esempio: Riempire Buffer

```assembly
.DATA
    buffer DB 100 DUP(?)

.CODE
    MOV AX, @DATA
    MOV ES, AX
    
    LEA DI, buffer
    MOV AL, 0               ; Valore riempimento
    MOV CX, 100             ; Numero byte
    CLD
    REP STOSB               ; Riempi con 0
    ; buffer ora contiene 100 zeri
```

### Inizializzare Array di Word

```assembly
.DATA
    array DW 50 DUP(?)

.CODE
    LEA DI, array
    MOV AX, 1234            ; Valore iniziale
    MOV CX, 50              ; 50 word
    CLD
    REP STOSW               ; Inizializza tutte a 1234
```

## Tabella Riassuntiva Istruzioni Stringhe

| Istruzione | Operazione | Registri | Segmenti | Auto-update |
|------------|------------|----------|----------|-------------|
| MOVSB/W | Copia | SI, DI | DS:SI → ES:DI | SI, DI |
| CMPSB/W | Confronta | SI, DI | DS:SI vs ES:DI | SI, DI |
| SCASB/W | Cerca | DI, AL/AX | AL/AX vs ES:DI | DI |
| LODSB/W | Carica | SI, AL/AX | DS:SI → AL/AX | SI |
| STOSB/W | Memorizza | DI, AL/AX | AL/AX → ES:DI | DI |

## Prefissi REP

### REP (REPeat)

**Uso**: MOVS, STOS (operazioni senza confronto).

```assembly
REP istruzione
; Equivalente a:
; loop:
;   istruzione
;   DEC CX
;   JNZ loop
```

### REPE/REPZ (REPeat while Equal/Zero)

**Uso**: CMPS, SCAS (continua se ZF=1).

```assembly
REPE istruzione
; Equivalente a:
; loop:
;   istruzione
;   DEC CX
;   JZ continua
;   JMP fine
; continua:
;   CMP CX, 0
;   JNZ loop
; fine:
```

**Termina quando**:
- CX = 0 (elaborati tutti gli elementi), **OR**
- ZF = 0 (trovata differenza)

### REPNE/REPNZ (REPeat while Not Equal/Not Zero)

**Uso**: CMPS, SCAS (continua se ZF=0).

```assembly
REPNE istruzione
; Equivalente a:
; loop:
;   istruzione
;   DEC CX
;   JNZ continua
;   JMP fine
; continua:
;   CMP CX, 0
;   JNZ loop
; fine:
```

**Termina quando**:
- CX = 0, **OR**
- ZF = 1 (trovata uguaglianza)

### Tabella Prefissi

| Prefisso | Alias | Condizione Continuazione | Uso Tipico |
|----------|-------|-------------------------|------------|
| REP | - | CX ≠ 0 | MOVS, STOS |
| REPE | REPZ | CX ≠ 0 AND ZF = 1 | CMPS (confronto uguali) |
| REPNE | REPNZ | CX ≠ 0 AND ZF = 0 | SCAS (cerca diverso) |

## Esempi Pratici

### 1. Copia Stringa

```assembly
strcpy PROC
    ; SI = sorgente, DI = destinazione
    ; Copia fino a null terminator
    
    CLD
copia_loop:
    LODSB                   ; AL = [SI], SI++
    STOSB                   ; [DI] = AL, DI++
    TEST AL, AL
    JNZ copia_loop          ; Continua se AL ≠ 0
    
    RET
strcpy ENDP
```

### 2. Confronto Stringhe Case-Insensitive

```assembly
stricmp PROC
    ; SI = str1, DI = str2
    ; Return: AL = 0 (equal), AL < 0 (str1 < str2), AL > 0 (str1 > str2)
    
    CLD
cmp_loop:
    LODSB                   ; AL = [SI], SI++
    MOV BL, [ES:DI]
    INC DI
    
    ; Converti entrambi in maiuscolo
    CALL toupper_AL
    XCHG AL, BL
    CALL toupper_AL
    XCHG AL, BL
    
    ; Confronta
    CMP AL, BL
    JNE diversi
    
    ; Se entrambi null, uguali
    TEST AL, AL
    JNZ cmp_loop
    
    XOR AL, AL              ; return 0 (uguali)
    RET
    
diversi:
    SUB AL, BL              ; AL = AL - BL
    RET
stricmp ENDP

toupper_AL PROC
    CMP AL, 'a'
    JL not_lower
    CMP AL, 'z'
    JG not_lower
    SUB AL, 32
not_lower:
    RET
toupper_AL ENDP
```

### 3. Riempimento Pattern

```assembly
; Riempi buffer con pattern ripetuto
memset_pattern PROC
    ; DI = buffer, CX = lunghezza buffer
    ; SI = pattern, BX = lunghezza pattern
    
    PUSH CX
    PUSH SI
    PUSH DI
    
    CLD
fill_loop:
    PUSH CX                 ; Salva lunghezza buffer rimanente
    PUSH SI                 ; Salva inizio pattern
    
    MOV CX, BX              ; CX = lunghezza pattern
    REP MOVSB               ; Copia pattern
    
    POP SI                  ; Ripristina inizio pattern
    POP CX                  ; Ripristina lunghezza buffer
    SUB CX, BX              ; Decrementa di lunghezza pattern
    JA fill_loop            ; Continua se CX > 0
    
    POP DI
    POP SI
    POP CX
    RET
memset_pattern ENDP
```

### 4. Invertire Stringa

```assembly
reverse_string PROC
    ; SI = stringa, CX = lunghezza (escluso null)
    
    ; DI punta alla fine
    LEA DI, [SI + CX - 1]
    
    ; Scambia metà stringhe
    SHR CX, 1               ; CX = lunghezza / 2
    
reverse_loop:
    MOV AL, [SI]
    MOV BL, [DI]
    MOV [SI], BL            ; Scambia
    MOV [DI], AL
    
    INC SI
    DEC DI
    LOOP reverse_loop
    
    RET
reverse_string ENDP
```

### 5. Conta Occorrenze Carattere

```assembly
count_char PROC
    ; SI = stringa, AL = carattere da cercare, CX = lunghezza
    ; Return: BX = numero occorrenze
    
    XOR BX, BX              ; Contatore = 0
    CLD
    
count_loop:
    CMPSB                   ; Confronta AL con [SI], SI++
    ; ERRORE! CMPSB usa DI, non AL!
    ; Correzione:
    
count_loop_correct:
    LODSB                   ; AL = [SI], SI++
    CMP AL, carattere_cercato
    JNE non_trovato
    INC BX                  ; Incrementa contatore
non_trovato:
    LOOP count_loop_correct
    
    ; BX = numero occorrenze
    RET
count_char ENDP

; Versione migliore con SCASB:
count_char_v2 PROC
    ; DI = stringa, AL = carattere, CX = lunghezza
    ; Return: BX = occorrenze
    
    XOR BX, BX
    CLD
    
count_scan:
    PUSH CX
    REPNE SCASB             ; Cerca fino a trovare AL
    JNE not_found_end       ; Non trovato
    
    INC BX                  ; Trovato!
    POP CX
    SUB CX, CX_dopo_scas    ; Aggiorna CX rimanente
    ; COMPLICATO! Meglio usare loop esplicito.
    
not_found_end:
    POP CX
    RET
count_char_v2 ENDP
```

## Best Practices

### 1. Inizializza Direction Flag

```assembly
✓ Sempre CLD/STD prima di istruzioni stringhe:
    CLD
    REP MOVSB
    
✗ Non assumere DF:
    ; DF potrebbe essere 1!
    REP MOVSB               ; Potrebbe andare all'indietro!
```

### 2. Imposta ES Correttamente

```assembly
✓ ES deve puntare al segmento destinazione:
    MOV AX, @DATA
    MOV ES, AX
    
✗ ES non inizializzato:
    ; ES = valore casuale!
    REP MOVSB               ; Scrive in memoria random!
```

### 3. Usa B vs W Appropriatamente

```assembly
✓ MOVSB per byte, MOVSW per word:
    ; Copia 10 byte
    MOV CX, 10
    REP MOVSB
    
    ; Copia 10 word (20 byte)
    MOV CX, 10
    REP MOVSW               ; Più veloce!
    
✗ CX sbagliato per MOVSW:
    ; Vuoi copiare 10 byte
    MOV CX, 10
    REP MOVSW               ; Copia 20 byte! ERRORE!
```

### 4. Controlla CX Dopo REP

```assembly
; Verifica se REPE è terminata per CX=0 o ZF=0
    REPE CMPSB
    JE tutte_uguali         ; Se ZF=1, finite perché CX=0
    ; Altrimenti, trovata differenza (ZF=0, CX>0)
```

### 5. Preferisci Istruzioni Stringhe a Loop

```assembly
✓ Efficiente:
    MOV CX, 100
    REP MOVSB               ; ~2-3 cicli per byte
    
✗ Lento:
    MOV CX, 100
loop_copia:
    MOV AL, [SI]
    MOV [DI], AL
    INC SI
    INC DI
    LOOP loop_copia         ; ~10+ cicli per byte
```

## Esercizi Pratici

1. Implementa `memcpy(dest, src, count)` con MOVSB
2. Implementa `memset(buffer, value, count)` con STOSB
3. Cerca sottostringa in stringa (substring search)
4. Sostituisci tutte le occorrenze di un carattere
5. Rimuovi spazi duplicati da una stringa
6. Converti stringa in maiuscolo usando LODSB/STOSB

### Soluzione Esercizio 1 (memcpy)

```assembly
memcpy PROC
    ; Parametri stack: dest, src, count
    PUSH BP
    MOV BP, SP
    PUSH SI
    PUSH DI
    PUSH CX
    
    ; [BP+4] = count
    ; [BP+6] = src
    ; [BP+8] = dest
    
    MOV AX, @DATA
    MOV DS, AX
    MOV ES, AX
    
    MOV SI, [BP+6]          ; SI = src
    MOV DI, [BP+8]          ; DI = dest
    MOV CX, [BP+4]          ; CX = count
    
    CLD
    REP MOVSB               ; Copia CX byte
    
    POP CX
    POP DI
    POP SI
    POP BP
    RET 6                   ; Pulisci 3 parametri
memcpy ENDP
```

### Soluzione Esercizio 4 (Sostituisci carattere)

```assembly
; Sostituisci tutte le occorrenze di 'old_char' con 'new_char'
replace_char PROC
    ; SI = stringa, AL = old_char, BL = new_char, CX = lunghezza
    
    CLD
replace_loop:
    LODSB                   ; AL = [SI], SI++
    ; ATTENZIONE: LODSB sovrascrive AL!
    ; Soluzione: non usare LODSB, usa MOV
    
    ; Versione corretta:
replace_loop_v2:
    CMP BYTE PTR [SI], AL   ; Confronta con old_char
    JNE non_sostituire
    MOV BYTE PTR [SI], BL   ; Sostituisci con new_char
non_sostituire:
    INC SI
    LOOP replace_loop_v2
    
    RET
replace_char ENDP
```

---

**Prossimo argomento:** [Manipolazione Stringhe Avanzata](03_manipolazione_stringhe.md)
