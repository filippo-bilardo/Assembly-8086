# Quiz Modulo 5: Gestione Memoria e Stringhe

## Istruzioni

Questo quiz verifica la comprensione di:
- Dichiarazione variabili e array (DB, DW, DD, DUP)
- Istruzioni per stringhe (MOVS, CMPS, SCAS, LODS, STOS)
- Prefissi REP, REPE, REPNE
- Manipolazione stringhe avanzata
- Gestione buffer e ottimizzazioni

**Modalità**:
- 20 domande a risposta multipla
- 1 sola risposta corretta
- Soluzioni dettagliate alla fine

---

## Domande

### 1. Quale direttiva alloca 1 byte di memoria?
a) DW  
b) DB  
c) DD  
d) BYTE

---

### 2. Cosa fa `buffer DB 100 DUP(?)`?
a) Alloca 100 byte non inizializzati  
b) Alloca 100 word non inizializzate  
c) Alloca 1 byte ripetuto 100 volte  
d) Errore di sintassi

---

### 3. Come viene memorizzata la word 0x1234 in memoria (little-endian)?
a) [addr] = 0x12, [addr+1] = 0x34  
b) [addr] = 0x34, [addr+1] = 0x12  
c) [addr] = 0x1234  
d) Dipende dal processore

---

### 4. Quale istruzione copia un byte da DS:SI a ES:DI?
a) MOVSB  
b) MOVB  
c) COPYB  
d) XCHG

---

### 5. Cosa fa `CLD` prima di istruzioni stringhe?
a) Pulisce il registro DI  
b) Imposta DF = 0 (incremento SI/DI)  
c) Imposta DF = 1 (decremento SI/DI)  
d) Cancella la stringa

---

### 6. Quale prefisso ripete MOVSB per CX volte?
a) LOOP  
b) REP  
c) REPE  
d) REPEAT

---

### 7. Quale istruzione confronta byte in DS:SI con ES:DI?
a) CMP  
b) CMPSB  
c) TEST  
d) SCASB

---

### 8. Quando termina `REPE CMPSB`?
a) Sempre quando CX = 0  
b) Quando CX = 0 OR ZF = 0 (trovato diverso)  
c) Quando CX = 0 OR ZF = 1  
d) Mai

---

### 9. Quale istruzione cerca AL in ES:DI?
a) LODSB  
b) STOSB  
c) SCASB  
d) CMPSB

---

### 10. Cosa fa `LODSB`?
a) AL = [DS:SI], SI++  
b) [ES:DI] = AL, DI++  
c) AL = [ES:DI], DI++  
d) Confronta AL con [DS:SI]

---

### 11. Quale istruzione memorizza AL in ES:DI?
a) LODSB  
b) STOSB  
c) MOVSB  
d) SCASB

---

### 12. Per copiare 100 byte, quale è più veloce?
a) MOVSB 100 volte in loop  
b) REP MOVSB con CX = 100  
c) REP MOVSW con CX = 50  
d) b e c sono equivalenti

---

### 13. Come calcolare offset per array[i] (word)?
a) i  
b) i × 2  
c) i × 4  
d) i / 2

---

### 14. Cosa fa `EVEN` in .DATA?
a) Inizializza variabili a valori pari  
b) Allinea al prossimo indirizzo pari  
c) Divide per 2  
d) Niente

---

### 15. Quale funzione calcola la lunghezza di una stringa?
a) strlen  
b) size  
c) length  
d) count

---

### 16. Come terminare una stringa C-style?
a) Con byte 0xFF  
b) Con byte 0 (null)  
c) Con byte '$'  
d) Non serve terminatore

---

### 17. Quale tecnica converte 'a' in 'A'?
a) ADD AL, 32  
b) SUB AL, 32  
c) OR AL, 32  
d) AND AL, 32

---

### 18. Cosa fa un buffer circolare quando raggiunge la fine?
a) Smette di accettare dati  
b) Wrappa all'inizio  
c) Raddoppia dimensione  
d) Genera errore

---

### 19. Quale è il vantaggio di MOVSW vs MOVSB?
a) Più semplice  
b) Funziona sempre  
c) ~2× più veloce (copia 2 byte per volta)  
d) Nessun vantaggio

---

### 20. Cosa previene il buffer overflow?
a) Usare buffer grandi  
b) Controllare dimensioni prima di scrivere  
c) Usare solo stringhe corte  
d) Non si può prevenire

---

## Soluzioni

### 1. Risposta: **b) DB**

**Spiegazione**:
- **DB** (Define Byte): alloca 1 byte
- **DW** (Define Word): alloca 2 byte
- **DD** (Define Doubleword): alloca 4 byte
- **BYTE**: non è una direttiva assembly valida

**Esempio**:
```assembly
byte_var DB 42          ; 1 byte = 42
```

---

### 2. Risposta: **a) Alloca 100 byte non inizializzati**

**Spiegazione**:
- **DUP(?)**: ripete il simbolo `?` (non inizializzato)
- **100 DUP(?)**: 100 ripetizioni = 100 byte
- Utile per buffer dove i valori iniziali non contano

**Esempio**:
```assembly
buffer DB 100 DUP(?)    ; 100 byte non inizializzati
; Equivalente a riservare spazio senza valori iniziali
```

**Confronto**:
```assembly
buffer1 DB 100 DUP(0)   ; 100 byte inizializzati a 0
buffer2 DB 100 DUP(?)   ; 100 byte NON inizializzati (più veloce)
```

---

### 3. Risposta: **b) [addr] = 0x34, [addr+1] = 0x12**

**Spiegazione**:
**Little-endian**: byte **meno significativo** per primo (indirizzo basso).

```assembly
value DW 0x1234

Memoria:
[addr+0] = 0x34         ; Byte basso
[addr+1] = 0x12         ; Byte alto
```

**Contrasto con big-endian** (non 8086):
```
[addr+0] = 0x12         ; Byte alto primo
[addr+1] = 0x34
```

**Importante**: quando leggi word con `MOV AX, [addr]`, il processore inverte automaticamente.

---

### 4. Risposta: **a) MOVSB**

**Spiegazione**:
**MOVSB** (Move String Byte):
```assembly
MOVSB
; Equivalente a:
; MOV AL, [DS:SI]
; MOV [ES:DI], AL
; SI++, DI++ (se DF=0)
```

**Altre istruzioni**:
- **MOVB**: non esiste
- **COPYB**: non esiste
- **XCHG**: scambia, non copia

---

### 5. Risposta: **b) Imposta DF = 0 (incremento SI/DI)**

**Spiegazione**:
**Direction Flag (DF)** controlla direzione:
- **DF = 0**: SI++, DI++ (avanti)
- **DF = 1**: SI--, DI-- (indietro)

```assembly
CLD                     ; DF = 0 (Clear Direction)
MOVSB                   ; SI++, DI++

STD                     ; DF = 1 (Set Direction)
MOVSB                   ; SI--, DI--
```

**Best practice**: **SEMPRE** usa `CLD` prima di istruzioni stringhe (DF potrebbe essere impostato da codice precedente).

---

### 6. Risposta: **b) REP**

**Spiegazione**:
**REP** (REPeat): ripete istruzione stringa per CX volte.

```assembly
MOV CX, 100
REP MOVSB
; Equivalente a:
; loop:
;   MOVSB
;   DEC CX
;   JNZ loop
```

**Altri prefissi**:
- **REPE/REPZ**: ripete mentre ZF=1 (per CMPS, SCAS)
- **REPNE/REPNZ**: ripete mentre ZF=0

---

### 7. Risposta: **b) CMPSB**

**Spiegazione**:
**CMPSB** (Compare String Byte):
```assembly
CMPSB
; Equivalente a:
; CMP [DS:SI], [ES:DI]    ; Aggiorna flag
; SI++, DI++
```

**Differenza con CMP**:
- **CMP**: confronta registri/memoria, non aggiorna SI/DI
- **CMPSB**: confronta stringhe, auto-incrementa

---

### 8. Risposta: **b) Quando CX = 0 OR ZF = 0 (trovato diverso)**

**Spiegazione**:
**REPE CMPSB** (REPeat while Equal):
```assembly
REPE CMPSB
; Continua mentre: CX ≠ 0 AND ZF = 1
; Termina quando: CX = 0 OR ZF = 0
```

**Uso tipico**: confronta stringhe fino a trovare differenza.

```assembly
; Confronta str1 e str2
LEA SI, str1
LEA DI, str2
MOV CX, lunghezza
CLD
REPE CMPSB              ; Termina se CX=0 (uguali) o ZF=0 (diverse)
JE stringhe_uguali      ; Se ZF=1, tutte uguali
; Altrimenti, diverse
```

---

### 9. Risposta: **c) SCASB**

**Spiegazione**:
**SCASB** (Scan String Byte):
```assembly
SCASB
; Equivalente a:
; CMP AL, [ES:DI]
; DI++
```

**Uso**: cerca valore in AL nella stringa puntata da ES:DI.

**Esempio**: cerca 'X':
```assembly
LEA DI, stringa
MOV AL, 'X'
MOV CX, lunghezza
CLD
REPNE SCASB             ; Cerca fino a trovare 'X'
JE trovato              ; Se ZF=1, trovato
```

---

### 10. Risposta: **a) AL = [DS:SI], SI++**

**Spiegazione**:
**LODSB** (Load String Byte):
```assembly
LODSB
; Equivalente a:
; MOV AL, [DS:SI]
; SI++
```

**Uso**: carica byte da stringa in AL (per elaborazione).

**Esempio**: elabora caratteri:
```assembly
LEA SI, stringa
CLD
loop_proc:
    LODSB               ; AL = [SI], SI++
    TEST AL, AL
    JZ fine             ; Se null, fine
    ; Elabora AL
    JMP loop_proc
```

---

### 11. Risposta: **b) STOSB**

**Spiegazione**:
**STOSB** (Store String Byte):
```assembly
STOSB
; Equivalente a:
; MOV [ES:DI], AL
; DI++
```

**Uso**: memorizza AL nella stringa puntata da ES:DI.

**Esempio**: riempi buffer con 0:
```assembly
LEA DI, buffer
MOV AL, 0
MOV CX, 100
CLD
REP STOSB               ; Riempi 100 byte con 0
```

---

### 12. Risposta: **c) REP MOVSW con CX = 50**

**Spiegazione**:
**Prestazioni**:
- **MOVSB loop**: ~10+ cicli/byte (overhead loop)
- **REP MOVSB**: ~3 cicli/byte
- **REP MOVSW**: ~3 cicli/word = **~1.5 cicli/byte** (più veloce!)

**Esempio**:
```assembly
; Copia 100 byte

; ✓ Veloce (word)
MOV CX, 50              ; 50 word = 100 byte
REP MOVSW               ; ~150 cicli

; ✗ Lento (byte)
MOV CX, 100
REP MOVSB               ; ~300 cicli
```

**Nota**: MOVSW richiede buffer allineato (indirizzi pari) per prestazioni ottimali.

---

### 13. Risposta: **b) i × 2**

**Spiegazione**:
**Array di word**: ogni elemento = 2 byte.

```assembly
.DATA
    array DW 10, 20, 30, 40, 50

.CODE
    ; Accesso array[2] (terzo elemento = 30)
    MOV BX, 2               ; Indice
    SHL BX, 1               ; BX = 2 × 2 = 4 (offset byte)
    LEA SI, array
    MOV AX, [SI+BX]         ; AX = 30
```

**Formula generale**:
```
offset = indice × sizeof(elemento)

Byte:  offset = i × 1 = i
Word:  offset = i × 2
Dword: offset = i × 4
```

---

### 14. Risposta: **b) Allinea al prossimo indirizzo pari**

**Spiegazione**:
**EVEN**: inserisce padding per allineare al prossimo indirizzo **pari**.

```assembly
.DATA
    byte1 DB 1              ; Indirizzo 0x0000
    byte2 DB 2              ; Indirizzo 0x0001
    byte3 DB 3              ; Indirizzo 0x0002
    EVEN                    ; Padding a 0x0004 (pari)
    word_var DW 100         ; Indirizzo 0x0004 (allineato!)
```

**Perché importante**:
- Accesso a word **allineate** (indirizzi pari) = 1 ciclo
- Accesso a word **non allineate** (indirizzi dispari) = 2 cicli (8086)

---

### 15. Risposta: **a) strlen**

**Spiegazione**:
**strlen** calcola lunghezza stringa (escluso null terminator).

**Implementazione**:
```assembly
strlen PROC
    ; DI = stringa
    ; Return: CX = lunghezza
    
    PUSH DI
    XOR AL, AL              ; Cerca null (0)
    MOV CX, 0FFFFh
    CLD
    REPNE SCASB             ; Cerca fino a null
    
    NOT CX                  ; CX = ~CX
    DEC CX                  ; Lunghezza (escluso null)
    
    POP DI
    RET
strlen ENDP
```

**Esempio**:
```assembly
msg DB 'Hello', 0       ; Lunghezza = 5
LEA DI, msg
CALL strlen
; CX = 5
```

---

### 16. Risposta: **b) Con byte 0 (null)**

**Spiegazione**:
**Stringa C-style**: terminata da **null terminator** (byte 0).

```assembly
.DATA
    stringa DB 'Hello', 0   ; Lunghezza memorizzata = 6 byte
    ;          'H','e','l','l','o',0
```

**Perché**:
- Permette lunghezza variabile
- Funzioni (strlen, strcpy) riconoscono fine automaticamente

**Alternativa Pascal-style**:
```assembly
; Lunghezza prefissa (1 byte)
pstring DB 5, 'H','e','l','l','o'
;          ^-- lunghezza
```

---

### 17. Risposta: **b) SUB AL, 32**

**Spiegazione**:
**Conversione minuscolo → maiuscolo**:

Codici ASCII:
- 'A' = 65, 'Z' = 90
- 'a' = 97, 'z' = 122
- Differenza: 97 - 65 = **32**

```assembly
; Minuscolo → Maiuscolo
MOV AL, 'a'             ; AL = 97
SUB AL, 32              ; AL = 65 = 'A'

; Maiuscolo → Minuscolo
MOV AL, 'A'             ; AL = 65
ADD AL, 32              ; AL = 97 = 'a'
```

**Funzione completa**:
```assembly
toupper PROC
    ; AL = carattere
    CMP AL, 'a'
    JL not_lower
    CMP AL, 'z'
    JG not_lower
    SUB AL, 32
not_lower:
    RET
toupper ENDP
```

---

### 18. Risposta: **b) Wrappa all'inizio**

**Spiegazione**:
**Buffer circolare** (ring buffer): quando raggiunge la fine, **ricomincia dall'inizio**.

```
Buffer (size = 8):

Iniziale:  [_][_][_][_][_][_][_][_]
           ^head              ^tail=0

3 write:   [A][B][C][_][_][_][_][_]
           ^head  ^tail

5 write:   [A][B][C][D][E][F][G][H]
           ^head              ^tail

1 write (wrap!):
           [I][B][C][D][E][F][G][H]
              ^head           ^tail
           ^-- Wrappato all'inizio!
```

**Implementazione**:
```assembly
cbuf_write:
    ; ... scrivi byte ...
    INC head
    CMP head, BUFFER_SIZE
    JL no_wrap
    MOV head, 0             ; Wrap!
no_wrap:
```

**Uso**: buffering I/O, code FIFO.

---

### 19. Risposta: **c) ~2× più veloce (copia 2 byte per volta)**

**Spiegazione**:
**MOVSW** copia **2 byte** (1 word) per operazione, mentre **MOVSB** copia 1 byte.

**Prestazioni**:
```assembly
; Copia 1000 byte

; MOVSB: 1000 iterazioni
MOV CX, 1000
REP MOVSB               ; ~3000 cicli

; MOVSW: 500 iterazioni
MOV CX, 500             ; 500 word = 1000 byte
REP MOVSW               ; ~1500 cicli (2× veloce!)
```

**Tecnica ottimale** (gestisce dimensioni dispari):
```assembly
optimized_copy:
    SHR CX, 1           ; CX = word count
    REP MOVSW           ; Copia word
    
    RCL CX, 1           ; Recupera bit dispari
    REP MOVSB           ; Copia byte rimanente (se dispari)
```

---

### 20. Risposta: **b) Controllare dimensioni prima di scrivere**

**Spiegazione**:
**Buffer overflow**: scrivere oltre la fine del buffer → corrompe memoria!

**Prevenzione**:
```assembly
✓ Controlla sempre:
safe_copy PROC
    ; CX = lunghezza da copiare
    ; BX = capacità buffer
    
    CMP CX, BX
    JA too_large            ; Se CX > capacità, errore
    
    REP MOVSB               ; Sicuro
    RET
    
too_large:
    ; Gestisci errore
    RET
safe_copy ENDP

✗ Senza controllo:
unsafe_copy PROC
    REP MOVSB               ; PERICOLOSO! Può sovrascrivere!
    RET
unsafe_copy ENDP
```

**Best practice**:
- Usa versioni "n" (strncpy, memcpy_s)
- Valida input prima di copiare
- Alloca buffer con margine

---

## Riepilogo Punteggi

- **18-20 corrette**: Eccellente! Maestria completa
- **15-17 corrette**: Molto bene, rivedi prefissi REP
- **12-14 corrette**: Buono, approfondisci istruzioni stringhe
- **9-11 corrette**: Sufficiente, studia MOVS/CMPS/SCAS
- **< 9 corrette**: Ripassa tutto il modulo 5

---

## Concetti Chiave da Ricordare

### Dichiarazione Memoria
- **DB**: 1 byte
- **DW**: 2 byte (word)
- **DD**: 4 byte (doubleword)
- **DUP(n)**: ripete n volte
- **?**: non inizializzato

### Istruzioni Stringhe
| Istruzione | Operazione | Auto-update |
|------------|------------|-------------|
| MOVSB/W | Copia DS:SI → ES:DI | SI, DI |
| CMPSB/W | Confronta DS:SI vs ES:DI | SI, DI |
| SCASB/W | Cerca AL/AX in ES:DI | DI |
| LODSB/W | Carica DS:SI → AL/AX | SI |
| STOSB/W | Memorizza AL/AX → ES:DI | DI |

### Prefissi
- **REP**: ripete CX volte (MOVS, STOS)
- **REPE/REPZ**: ripete mentre ZF=1 (CMPS, SCAS)
- **REPNE/REPNZ**: ripete mentre ZF=0

### Direction Flag
- **CLD**: DF=0, incremento (avanti)
- **STD**: DF=1, decremento (indietro)

### Ottimizzazioni
- **MOVSW** > MOVSB (~2× veloce)
- **Allineamento**: EVEN per word
- **Buffer checking**: previeni overflow

---

**Modulo completato!** Procedi al [Modulo 6](../06-IO_e_Interruzioni/01_interruzioni.md)
