# Istruzioni di Salto (Jump)

## Introduzione

Le istruzioni di salto (jump) permettono di alterare il flusso sequenziale di esecuzione del programma, saltando a un'altra parte del codice. Sono fondamentali per implementare:
- Strutture condizionali (if-then-else)
- Cicli (while, do-while, for)
- Selezione multipla (switch-case)
- Gestione errori e casi speciali

L'8086 offre due categorie principali:
- **Salti incondizionati**: JMP (sempre eseguito)
- **Salti condizionati**: basati sui flag del registro FLAGS

## Il Registro FLAGS

Prima di studiare i salti condizionati, ripassiamo i flag principali:

```
FLAGS Register (16 bit):
15 14 13 12 11 10  9  8  7  6  5  4  3  2  1  0
 -  -  -  - OF DF IF TF SF ZF  - AF  - PF  - CF

Bit  Nome    Significato
---  ------  ------------------------------------------
 0   CF      Carry Flag - riporto/prestito unsigned
 2   PF      Parity Flag - parità (pari=1)
 4   AF      Auxiliary Flag - riporto BCD (bit 3→4)
 6   ZF      Zero Flag - risultato zero
 7   SF      Sign Flag - segno (bit più significativo)
11   OF      Overflow Flag - overflow signed
```

**Flag usati per salti condizionati**:
- **ZF** (Zero Flag): confronto uguaglianza
- **CF** (Carry Flag): confronto unsigned (<, >)
- **SF** (Sign Flag) + **OF** (Overflow Flag): confronto signed (<, >)
- **PF** (Parity Flag): raramente usato

## JMP - Jump Unconditional

Salta sempre alla destinazione, senza controllare flag.

### Sintassi

```assembly
JMP destinazione
```

### Tipi di JMP

**1. JMP SHORT** (salto corto, -128 a +127 byte)
```assembly
JMP SHORT vicino     ; Offset a 8 bit, ±127 byte
```

**2. JMP NEAR** (salto vicino, stesso segmento)
```assembly
JMP etichetta        ; Offset a 16 bit, ±32KB
JMP NEAR PTR etichetta
```

**3. JMP FAR** (salto lontano, altro segmento)
```assembly
JMP FAR PTR altra_procedura
```

**4. JMP indiretto**
```assembly
JMP BX               ; Salta a indirizzo in BX (NEAR)
JMP [BX]             ; Salta a indirizzo in memoria [BX]
JMP WORD PTR [BX]    ; NEAR jump indiretto
JMP DWORD PTR [BX]   ; FAR jump indiretto
```

### Esempi JMP

**Esempio 1: Loop infinito**
```assembly
inizio:
    ; ... codice ...
    JMP inizio       ; Loop infinito
```

**Esempio 2: Skip codice**
```assembly
    JMP salta_questo
    ; Codice mai eseguito
    MOV AX, 1
    INT 21h
salta_questo:
    ; Codice normale
```

**Esempio 3: Jump table**
```assembly
.DATA
    jump_table DW offset caso0, offset caso1, offset caso2

.CODE
    MOV BX, scelta      ; scelta = 0, 1, o 2
    SHL BX, 1           ; × 2 (word = 2 byte)
    JMP [jump_table+BX] ; Salto indiretto

caso0:
    ; Codice caso 0
    JMP fine
caso1:
    ; Codice caso 1
    JMP fine
caso2:
    ; Codice caso 2
fine:
```

## Salti Condizionati Basati su Singoli Flag

Questi salti testano **un solo flag**.

### JZ / JE - Jump if Zero / Jump if Equal

Salta se **ZF = 1** (risultato zero o uguaglianza).

```assembly
CMP AX, BX
JZ uguale           ; Salta se AX = BX
JE uguale           ; Equivalente (stesso opcode)

; Dopo operazione aritmetica
SUB AX, 10
JZ e_dieci          ; Salta se AX era 10

; Dopo TEST
TEST AL, AL
JZ e_zero           ; Salta se AL = 0
```

**JZ e JE sono identici**, cambia solo il nome per leggibilità:
- Usa **JE** dopo **CMP** (semantica "equal")
- Usa **JZ** dopo operazioni aritmetiche (semantica "zero")

### JNZ / JNE - Jump if Not Zero / Jump if Not Equal

Salta se **ZF = 0** (risultato non zero o diverso).

```assembly
CMP AX, BX
JNE diverso         ; Salta se AX ≠ BX
JNZ diverso         ; Equivalente

; Loop fino a zero
ciclo:
    DEC CX
    JNZ ciclo       ; Ripeti se CX ≠ 0
```

### JS - Jump if Sign

Salta se **SF = 1** (risultato negativo, come signed).

```assembly
MOV AX, numero
TEST AX, AX         ; Imposta SF in base a AX
JS negativo         ; Salta se AX < 0 (signed)

; Dopo sottrazione
SUB AX, BX
JS ax_minore        ; Salta se AX < BX (signed)
```

### JNS - Jump if Not Sign

Salta se **SF = 0** (risultato positivo o zero).

```assembly
TEST AL, AL
JNS positivo_o_zero ; Salta se AL ≥ 0
```

### JC - Jump if Carry

Salta se **CF = 1** (riporto o prestito).

```assembly
; Dopo addizione
ADD AX, BX
JC overflow_unsigned ; Salta se somma > FFFFh

; Dopo sottrazione
SUB AL, BL
JC al_era_minore     ; Salta se AL < BL (unsigned)

; Dopo shift
SHL AX, 1
JC bit15_era_uno     ; Salta se bit 15 era 1
```

### JNC - Jump if Not Carry

Salta se **CF = 0** (nessun riporto/prestito).

```assembly
ADD AX, BX
JNC no_overflow      ; Salta se somma ≤ FFFFh
```

### JO - Jump if Overflow

Salta se **OF = 1** (overflow aritmetico signed).

```assembly
; Dopo addizione signed
MOV AL, 127         ; Massimo signed byte
ADD AL, 1           ; Overflow: 127 + 1 = -128
JO overflow_signed  ; Salta (OF = 1)
```

### JNO - Jump if Not Overflow

Salta se **OF = 0** (nessun overflow signed).

```assembly
ADD AX, BX
JNO ok              ; Salta se nessun overflow
```

### JP / JPE - Jump if Parity Even

Salta se **PF = 1** (numero pari di bit a 1 nel byte basso).

```assembly
MOV AL, 00000011b   ; 2 bit a 1 (pari)
TEST AL, AL
JPE pari            ; Salta (PF = 1)

MOV AL, 00000111b   ; 3 bit a 1 (dispari)
TEST AL, AL
JPE pari            ; Non salta (PF = 0)
```

**Raramente usato** in programmazione normale.

### JNP / JPO - Jump if Parity Odd

Salta se **PF = 0** (numero dispari di bit a 1).

```assembly
JPO dispari         ; Salta se parità dispari
```

## Salti Condizionati per Confronti Unsigned

Dopo **CMP operando1, operando2**, questi salti confrontano come **numeri unsigned**.

**Mnemonici**: Above (sopra), Below (sotto)

### Tabella Completa Salti Unsigned

| Condizione | Salto | Alias | Flag | Esempio dopo `CMP AX, BX` |
|------------|-------|-------|------|---------------------------|
| op1 = op2  | JE | JZ | ZF=1 | AX = BX |
| op1 ≠ op2  | JNE | JNZ | ZF=0 | AX ≠ BX |
| op1 > op2  | JA | JNBE | CF=0 e ZF=0 | AX > BX |
| op1 ≥ op2  | JAE | JNB, JNC | CF=0 | AX ≥ BX |
| op1 < op2  | JB | JNAE, JC | CF=1 | AX < BX |
| op1 ≤ op2  | JBE | JNA | CF=1 o ZF=1 | AX ≤ BX |

### JA - Jump if Above

Salta se **operando1 > operando2** (unsigned).

```assembly
CMP AL, 100         ; Confronta AL con 100
JA maggiore         ; Salta se AL > 100 (unsigned)

; Esempio: verifica range
CMP AL, 255
JA fuori_range      ; Salta se AL > 255 (impossibile per byte!)
```

**Condizione**: CF=0 e ZF=0

### JAE - Jump if Above or Equal

Salta se **operando1 ≥ operando2** (unsigned).

```assembly
CMP AX, 1000
JAE almeno_mille    ; Salta se AX ≥ 1000
```

**Alias**: JNB (Jump if Not Below), JNC (Jump if Not Carry)
**Condizione**: CF=0

### JB - Jump if Below

Salta se **operando1 < operando2** (unsigned).

```assembly
CMP AL, 10
JB minore_dieci     ; Salta se AL < 10
```

**Alias**: JNAE (Jump if Not Above or Equal), JC (Jump if Carry)
**Condizione**: CF=1

### JBE - Jump if Below or Equal

Salta se **operando1 ≤ operando2** (unsigned).

```assembly
CMP CX, 100
JBE max_cento       ; Salta se CX ≤ 100
```

**Alias**: JNA (Jump if Not Above)
**Condizione**: CF=1 o ZF=1

### Esempi Unsigned

**Esempio 1: Validazione range**
```assembly
; Verifica se AL è tra 'A' (65) e 'Z' (90)
CMP AL, 'A'
JB non_maiuscola    ; Se AL < 'A', non è maiuscola
CMP AL, 'Z'
JA non_maiuscola    ; Se AL > 'Z', non è maiuscola
; AL è tra A-Z
JMP e_maiuscola
non_maiuscola:
    ; Non è lettera maiuscola
e_maiuscola:
```

**Esempio 2: Ricerca massimo**
```assembly
.DATA
    array DB 5, 12, 8, 20, 3
    max DB 0

.CODE
    LEA SI, array
    MOV CX, 5
    MOV AL, 0           ; max = 0
trova_max:
    CMP AL, [SI]
    JAE non_nuovo_max   ; Se max ≥ elemento, skip
    MOV AL, [SI]        ; Nuovo max
non_nuovo_max:
    INC SI
    LOOP trova_max
    MOV max, AL         ; Salva max
```

## Salti Condizionati per Confronti Signed

Dopo **CMP operando1, operando2**, questi salti confrontano come **numeri signed** (complemento a 2).

**Mnemonici**: Greater (maggiore), Less (minore)

### Tabella Completa Salti Signed

| Condizione | Salto | Alias | Flag | Esempio dopo `CMP AX, BX` |
|------------|-------|-------|------|---------------------------|
| op1 = op2  | JE | JZ | ZF=1 | AX = BX |
| op1 ≠ op2  | JNE | JNZ | ZF=0 | AX ≠ BX |
| op1 > op2  | JG | JNLE | ZF=0 e SF=OF | AX > BX |
| op1 ≥ op2  | JGE | JNL | SF=OF | AX ≥ BX |
| op1 < op2  | JL | JNGE | SF≠OF | AX < BX |
| op1 ≤ op2  | JLE | JNG | ZF=1 o SF≠OF | AX ≤ BX |

### JG - Jump if Greater

Salta se **operando1 > operando2** (signed).

```assembly
CMP AX, 0
JG positivo         ; Salta se AX > 0

CMP BX, -100
JG maggiore         ; Salta se BX > -100
```

**Alias**: JNLE (Jump if Not Less or Equal)
**Condizione**: ZF=0 e SF=OF

### JGE - Jump if Greater or Equal

Salta se **operando1 ≥ operando2** (signed).

```assembly
CMP AL, -50
JGE almeno_meno50   ; Salta se AL ≥ -50

; Verifica non negativo
TEST AX, AX
JGE non_negativo    ; Salta se AX ≥ 0
```

**Alias**: JNL (Jump if Not Less)
**Condizione**: SF=OF

### JL - Jump if Less

Salta se **operando1 < operando2** (signed).

```assembly
CMP AL, 0
JL negativo         ; Salta se AL < 0

CMP BX, -10
JL minore           ; Salta se BX < -10
```

**Alias**: JNGE (Jump if Not Greater or Equal)
**Condizione**: SF≠OF

### JLE - Jump if Less or Equal

Salta se **operando1 ≤ operando2** (signed).

```assembly
CMP CX, 100
JLE max_cento       ; Salta se CX ≤ 100 (signed)
```

**Alias**: JNG (Jump if Not Greater)
**Condizione**: ZF=1 o SF≠OF

### Perché SF≠OF per Signed?

Quando SF≠OF, significa che c'è stato un overflow che ha invertito il segno:

```assembly
; Esempio: -5 < 10 (ovvio)
MOV AL, -5          ; AL = FBh = 11111011b
CMP AL, 10          ; AL - 10 = -15 = F1h = 11110001b
                    ; SF = 1 (negativo)
                    ; OF = 0 (nessun overflow)
                    ; SF = OF → falso
JL minore           ; Non salta (SF=OF!)

; Cosa è successo?
; CMP fa SUB: FBh - 0Ah = F1h
; F1h (signed) = -15 (corretto)
; SF = 1 (bit 7 = 1)
; OF = 0 (nessun overflow)
; Per JL serve SF≠OF, ma SF=OF=1? No!

; Rivediamo:
; -5 - 10 = -15
; FBh (251 unsigned) - 0Ah (10) = F1h (241 unsigned)
; SF = 1 (risultato negativo)
; OF = 0 (nessun overflow signed)
; SF = OF? 1 = 0? NO!
; Quindi SF≠OF → JL salta ✓
```

### Esempi Signed

**Esempio 1: Temperatura**
```assembly
; Temperatura può essere negativa
.DATA
    temp DW -10     ; -10°C

.CODE
    MOV AX, temp
    CMP AX, 0
    JGE sopra_zero
    ; Sotto zero
    NEG AX          ; Valore assoluto
    ; "Temperatura: -XX°C"
    JMP stampa
sopra_zero:
    ; "Temperatura: +XX°C"
stampa:
    ; ...
```

**Esempio 2: Clamp (limita valore)**
```assembly
; Limita AX a range [-100, +100]
CMP AX, -100
JGE non_troppo_basso
MOV AX, -100        ; Clamp a -100
non_troppo_basso:
CMP AX, 100
JLE non_troppo_alto
MOV AX, 100         ; Clamp a 100
non_troppo_alto:
; AX ora è in [-100, +100]
```

## JCXZ - Jump if CX is Zero

Salto speciale che testa se **CX = 0**, senza modificare flag.

### Sintassi

```assembly
JCXZ destinazione
```

**Equivalente a**:
```assembly
TEST CX, CX
JZ destinazione
```

**Ma più efficiente!** Non modifica i flag.

### Uso Tipico: Verifica Loop

```assembly
; Evita loop con CX = 0
JCXZ salta_loop     ; Se CX = 0, non entrare nel loop
loop_inizio:
    ; Corpo loop
    LOOP loop_inizio
salta_loop:
```

**Senza JCXZ**:
```assembly
; Se CX = 0, LOOP fa CX = FFFFh e cicla 65535 volte!
loop_inizio:
    ; ...
    LOOP loop_inizio    ; ERRORE se CX era 0!
```

**Con JCXZ (corretto)**:
```assembly
MOV CX, contatore   ; Può essere 0
JCXZ fine           ; Salta se CX = 0
ciclo:
    ; Corpo loop (eseguito CX volte)
    LOOP ciclo
fine:
```

### Esempio: Lunghezza Stringa

```assembly
; Calcola lunghezza stringa (max CX caratteri)
.DATA
    stringa DB 'Hello', 0
    
.CODE
    LEA SI, stringa
    MOV CX, 100         ; Max caratteri da controllare
    JCXZ fine           ; Se CX = 0, skip
    
    XOR BX, BX          ; Contatore lunghezza
conta_loop:
    LODSB               ; AL = [SI], SI++
    TEST AL, AL
    JZ trovato_fine
    INC BX
    LOOP conta_loop
trovato_fine:
    ; BX = lunghezza stringa
fine:
```

## LOOP - Loop Until CX = 0

Decrementa CX e salta se CX ≠ 0.

### Sintassi

```assembly
LOOP etichetta
```

**Equivalente a**:
```assembly
DEC CX
JNZ etichetta
```

### Esempi LOOP

**Esempio 1: Conta alla rovescia**
```assembly
MOV CX, 10
countdown:
    ; Stampa CX
    ; ...
    LOOP countdown
; CX = 0
```

**Esempio 2: Somma array**
```assembly
.DATA
    array DW 10, 20, 30, 40, 50
    somma DW 0

.CODE
    LEA SI, array
    MOV CX, 5
    XOR AX, AX
somma_loop:
    ADD AX, [SI]
    ADD SI, 2           ; Next word
    LOOP somma_loop
    MOV somma, AX       ; AX = 150
```

### LOOPE / LOOPZ - Loop While Equal/Zero

Decrementa CX e salta se **CX ≠ 0 E ZF = 1**.

```assembly
LOOPE etichetta     ; Loop while equal (ZF=1)
LOOPZ etichetta     ; Equivalente
```

**Equivalente a**:
```assembly
DEC CX
JZ fine_loop        ; Se CX = 0, esci
TEST ZF             ; (figurativo)
JZ fine_loop        ; Se ZF = 0, esci
JMP etichetta
fine_loop:
```

**Esempio: Trova primo diverso**
```assembly
; Trova primo elemento ≠ 0 in array
LEA SI, array
MOV CX, 100
cerca_loop:
    CMP BYTE PTR [SI], 0
    LOOPE cerca_loop    ; Continua se CX≠0 E elemento=0
    INC SI
; Uscito perché trovato ≠0 o CX=0
```

### LOOPNE / LOOPNZ - Loop While Not Equal/Zero

Decrementa CX e salta se **CX ≠ 0 E ZF = 0**.

```assembly
LOOPNE etichetta    ; Loop while not equal (ZF=0)
LOOPNZ etichetta    ; Equivalente
```

**Esempio: Trova primo uguale**
```assembly
; Cerca valore in array
MOV AL, valore_cercato
LEA SI, array
MOV CX, lunghezza
cerca:
    CMP AL, [SI]
    LOOPNE cerca        ; Continua se CX≠0 E non trovato
    INC SI
; Uscito perché trovato (ZF=1) o CX=0
```

## Tabella Riepilogativa Salti

### Salti Incondizionati
| Istruzione | Descrizione |
|------------|-------------|
| JMP | Salto sempre |
| CALL | Chiama procedura (vedi modulo procedure) |

### Salti su Singoli Flag
| Istruzione | Condizione | Flag |
|------------|------------|------|
| JZ / JE | Zero / Equal | ZF=1 |
| JNZ / JNE | Not Zero / Not Equal | ZF=0 |
| JS | Sign (negative) | SF=1 |
| JNS | Not Sign (positive/zero) | SF=0 |
| JC | Carry | CF=1 |
| JNC | Not Carry | CF=0 |
| JO | Overflow | OF=1 |
| JNO | Not Overflow | OF=0 |
| JP / JPE | Parity Even | PF=1 |
| JNP / JPO | Parity Odd | PF=0 |

### Salti Unsigned (dopo CMP)
| Istruzione | Significato | Alias | Flag |
|------------|-------------|-------|------|
| JE | Equal (=) | JZ | ZF=1 |
| JNE | Not Equal (≠) | JNZ | ZF=0 |
| JA | Above (>) | JNBE | CF=0 e ZF=0 |
| JAE | Above or Equal (≥) | JNB, JNC | CF=0 |
| JB | Below (<) | JNAE, JC | CF=1 |
| JBE | Below or Equal (≤) | JNA | CF=1 o ZF=1 |

### Salti Signed (dopo CMP)
| Istruzione | Significato | Alias | Flag |
|------------|-------------|-------|------|
| JE | Equal (=) | JZ | ZF=1 |
| JNE | Not Equal (≠) | JNZ | ZF=0 |
| JG | Greater (>) | JNLE | ZF=0 e SF=OF |
| JGE | Greater or Equal (≥) | JNL | SF=OF |
| JL | Less (<) | JNGE | SF≠OF |
| JLE | Less or Equal (≤) | JNG | ZF=1 o SF≠OF |

### Loop
| Istruzione | Descrizione |
|------------|-------------|
| LOOP | DEC CX; JNZ |
| LOOPE / LOOPZ | DEC CX; se CX≠0 e ZF=1, salta |
| LOOPNE / LOOPNZ | DEC CX; se CX≠0 e ZF=0, salta |
| JCXZ | Salta se CX=0 (senza modificare flag) |

## Best Practices

### 1. Scegli Signed vs Unsigned Correttamente

```assembly
; Per numeri senza segno (indirizzi, dimensioni):
CMP AX, 1000
JA maggiore         ; Above (unsigned)

; Per numeri con segno (temperature, coordinate):
CMP AX, -10
JG maggiore         ; Greater (signed)
```

### 2. Usa Alias Significativi

```assembly
; Dopo CMP
CMP AL, 'A'
JE e_maiuscola      ; "JE" è più chiaro di "JZ"

; Dopo operazione aritmetica
SUB AL, 10
JZ era_dieci        ; "JZ" è più chiaro di "JE"
```

### 3. Attenzione ai Loop con CX=0

```assembly
; ❌ SBAGLIATO
MOV CX, contatore   ; Può essere 0
ciclo:
    ; ...
    LOOP ciclo      ; Se CX=0, fa 65535 iterazioni!

; ✓ CORRETTO
MOV CX, contatore
JCXZ salta_ciclo
ciclo:
    ; ...
    LOOP ciclo
salta_ciclo:
```

### 4. Attenzione all'Ordine degli Operandi in CMP

```assembly
; CMP fa: operando1 - operando2

CMP AX, BX          ; Calcola AX - BX
JG ax_maggiore      ; Salta se AX > BX

; Non confondere con:
CMP BX, AX          ; Calcola BX - AX
JG bx_maggiore      ; Salta se BX > AX
```

### 5. Ottimizza con TEST

```assembly
; Verifica se zero
CMP AX, 0           ; 3 byte
JZ e_zero

; Meglio:
TEST AX, AX         ; 2 byte, più veloce
JZ e_zero
```

## Esercizi Pratici

1. Scrivi codice per verificare se AL è una cifra ('0'-'9')
2. Implementa un loop che somma numeri da 1 a N
3. Trova il massimo tra tre numeri in AX, BX, CX
4. Conta quanti elementi > 50 in un array
5. Verifica se una stringa è palindroma (usa LOOPNE)

### Soluzione Esercizio 1

```assembly
; Verifica se AL è cifra '0'-'9'
CMP AL, '0'
JB non_cifra        ; Se AL < '0'
CMP AL, '9'
JA non_cifra        ; Se AL > '9'
; È una cifra
JMP e_cifra
non_cifra:
    ; Non è cifra
e_cifra:
```

### Soluzione Esercizio 3

```assembly
; Trova massimo tra AX, BX, CX
MOV DX, AX          ; Assume AX è max

CMP DX, BX
JGE controlla_cx    ; Se DX ≥ BX, controlla CX
MOV DX, BX          ; Altrimenti BX è nuovo max

controlla_cx:
CMP DX, CX
JGE fine            ; Se DX ≥ CX, abbiamo max
MOV DX, CX          ; Altrimenti CX è max

fine:
; DX contiene il massimo
```

---

**Prossimo argomento:** [Strutture di Controllo](modulo4_02_strutture_controllo.md)
