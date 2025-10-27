# Istruzioni Logiche e di Manipolazione Bit

## Introduzione

Le istruzioni logiche operano bit a bit sugli operandi, permettendo di manipolare singoli bit, creare maschere, testare condizioni e ottimizzare il codice. Sono fondamentali per la programmazione di basso livello, gestione hardware e algoritmi efficienti.

## AND - Logical AND

Esegue l'AND logico bit a bit tra gli operandi.

### Sintassi

```assembly
AND destinazione, sorgente
```

**Operazione**: ogni bit del risultato è 1 solo se **entrambi** i bit corrispondenti sono 1.

### Tabella di Verità

```
A  B  | A AND B
------|--------
0  0  |   0
0  1  |   0
1  0  |   0
1  1  |   1
```

### Operandi Validi

```assembly
; Registro ← Registro
AND AX, BX
AND AL, BL

; Registro ← Immediato
AND AX, 0FFh
AND BL, 01h

; Registro ← Memoria
AND AX, [BX]
AND CL, variabile

; Memoria ← Registro
AND [SI], AX
AND variabile, DL

; Memoria ← Immediato
AND BYTE PTR [BX], 0Fh
AND WORD PTR [SI], 00FFh
```

### Effetti sui Flag

| Flag | Comportamento |
|------|---------------|
| **CF** | Sempre 0 |
| **OF** | Sempre 0 |
| **SF** | Segno del risultato |
| **ZF** | 1 se risultato = 0 |
| **PF** | Parità del byte basso |
| **AF** | Indefinito |

### Usi Principali di AND

#### 1. Azzerare Bit (Masking)

```assembly
; Azzera bit 0 di AL
AND AL, 11111110b   ; oppure AND AL, 0FEh
; Bit 0 diventa 0, altri invariati

; Azzera nibble alto (bit 4-7) di AL
AND AL, 00001111b   ; oppure AND AL, 0Fh
; Risultato: solo nibble basso rimane

; Esempio:
MOV AL, 10110101b   ; AL = B5h
AND AL, 0Fh         ; AL = 00000101b = 05h
```

#### 2. Estrarre Bit (Bit Extraction)

```assembly
; Estrai bit 3 di AL
MOV BL, AL
AND BL, 00001000b   ; oppure AND BL, 08h
; BL = 00001000b se bit 3 era 1
; BL = 00000000b se bit 3 era 0

; Per ottenere solo 0 o 1:
SHR BL, 3           ; Shifta a destra di 3
; BL = 0 o 1
```

#### 3. Testare Bit

```assembly
; Controlla se bit 7 di AL è 1 (segno negativo)
TEST AL, 80h        ; Imposta ZF senza modificare AL
JZ positivo         ; Salta se bit 7 = 0
; Negativo
JMP fine
positivo:
    ; Positivo
fine:
```

#### 4. Convertire a Maiuscolo/Minuscolo

```assembly
; ASCII: 'A' = 41h = 01000001b
;        'a' = 61h = 01100001b
; Differenza: bit 5

; Maiuscolo → Minuscolo: imposta bit 5
MOV AL, 'A'         ; AL = 41h
OR AL, 20h          ; AL = 61h = 'a'

; Minuscolo → Maiuscolo: azzera bit 5
MOV AL, 'a'         ; AL = 61h
AND AL, 0DFh        ; AL = 41h = 'A' (0DFh = 11011111b)
```

#### 5. Azzerare Registro (Ottimizzazione)

```assembly
; Azzerare AX
AND AX, 0           ; Funziona ma non ottimale

; Meglio:
XOR AX, AX          ; Più veloce, 2 byte
SUB AX, AX          ; Alternativa
```

### Esempi Pratici

**Esempio 1: Verifica Parità/Disparità**
```assembly
; Controlla se numero è pari
MOV AL, numero
AND AL, 1           ; Isola bit 0
JZ pari             ; Se bit 0 = 0, pari
; Dispari
JMP fine
pari:
    ; Pari
fine:
```

**Esempio 2: Maschera Multipli Bit**
```assembly
; Estrai bit 2-5 di AX
MOV AX, 1101101011010110b
AND AX, 0000000000111100b   ; Maschera bit 2-5
SHR AX, 2                   ; Shifta in posizione 0
; AX contiene solo bit 2-5 originali
```

**Esempio 3: Filtrare Caratteri Non Alfanumerici**
```assembly
; Converti carattere in maiuscolo se alfabetico
MOV AL, [SI]        ; Carica carattere
CMP AL, 'a'
JB non_minuscolo
CMP AL, 'z'
JA non_minuscolo
AND AL, 0DFh        ; Converti in maiuscolo
non_minuscolo:
MOV [DI], AL
```

## OR - Logical OR

Esegue l'OR logico bit a bit.

### Sintassi

```assembly
OR destinazione, sorgente
```

**Operazione**: ogni bit del risultato è 1 se **almeno uno** dei bit corrispondenti è 1.

### Tabella di Verità

```
A  B  | A OR B
------|-------
0  0  |   0
0  1  |   1
1  0  |   1
1  1  |   1
```

### Effetti sui Flag

Identici ad **AND**: CF=0, OF=0, SF/ZF/PF impostati, AF indefinito.

### Usi Principali di OR

#### 1. Impostare Bit (Set Bits)

```assembly
; Imposta bit 0 di AL
OR AL, 00000001b    ; oppure OR AL, 01h
; Bit 0 diventa 1, altri invariati

; Imposta bit 7 (segno)
OR AL, 80h
; Rende AL "negativo" come signed

; Imposta più bit contemporaneamente
OR AL, 11001100b    ; Imposta bit 7,6,3,2
```

#### 2. Azzerare Registro (con se stesso)

```assembly
; Verifica se registro è zero
OR AX, AX           ; AX OR AX = AX, imposta ZF
JZ e_zero           ; Salta se AX = 0

; Più veloce di:
CMP AX, 0
```

#### 3. Combinare Valori

```assembly
; Costruisci AX da AH e AL
; AX = AH (parte alta) | AL (parte bassa)
MOV AH, 12h
MOV AL, 34h
; AX = 1234h (già combinato automaticamente!)

; Esempio reale: costruire word da due byte separati
XOR AX, AX          ; AX = 0
MOV AL, byte_basso
MOV AH, byte_alto
; oppure:
XOR AX, AX
MOV AL, byte_basso
OR AH, byte_alto    ; Combina in AX
```

#### 4. Impostare Flag senza Modificare Valore

```assembly
; Imposta flag basandosi su valore
OR BX, BX           ; Non modifica BX, solo flag
JS negativo         ; Salta se SF=1 (BX negativo)
```

### Esempi Pratici

**Esempio 1: Costruire Maschera di Bit**
```assembly
; Costruisci maschera con bit 0,3,7 impostati
XOR AL, AL          ; AL = 0
OR AL, 00000001b    ; Bit 0
OR AL, 00001000b    ; Bit 3
OR AL, 10000000b    ; Bit 7
; AL = 10001001b = 89h
```

**Esempio 2: Conversione BCD → ASCII**
```assembly
; BCD digit (0-9) → ASCII ('0'-'9')
; Aggiungi 30h (ASCII '0')
MOV AL, 5           ; BCD digit
OR AL, 30h          ; AL = 35h = '5'
```

**Esempio 3: Unire Nibble**
```assembly
; Nibble alto in BH, nibble basso in BL
; Combina in AL
MOV BH, 0Ah         ; Nibble alto
MOV BL, 05h         ; Nibble basso
MOV AL, BL          ; AL = 05h
SHL AL, 4           ; AL = 50h
OR AL, BH           ; AL = 5Ah (non corretto!)

; Corretto:
MOV AL, BH
SHL AL, 4           ; AL = A0h
OR AL, BL           ; AL = A5h
```

## XOR - Logical Exclusive OR

Esegue l'XOR logico bit a bit.

### Sintassi

```assembly
XOR destinazione, sorgente
```

**Operazione**: ogni bit del risultato è 1 se i bit corrispondenti sono **diversi**.

### Tabella di Verità

```
A  B  | A XOR B
------|--------
0  0  |   0
0  1  |   1
1  0  |   1
1  1  |   0
```

### Effetti sui Flag

Identici ad **AND** e **OR**: CF=0, OF=0, SF/ZF/PF impostati.

### Usi Principali di XOR

#### 1. Azzerare Registro (Ottimizzazione Classica)

```assembly
; Metodo più veloce e compatto per azzerare
XOR AX, AX          ; AX = 0 (2 byte, velocissimo)
XOR BL, BL          ; BL = 0

; Confronto:
MOV AX, 0           ; 3 byte: B8 00 00
XOR AX, AX          ; 2 byte: 31 C0 (più veloce!)
SUB AX, AX          ; 2 byte: 29 C0
AND AX, 0           ; 3 byte: 25 00 00
```

#### 2. Toggle Bit (Invertire Bit)

```assembly
; Inverti bit 0 di AL
XOR AL, 00000001b   ; oppure XOR AL, 01h
; Se bit 0 era 0 → diventa 1
; Se bit 0 era 1 → diventa 0

; Esempio:
MOV AL, 10110100b
XOR AL, 00000001b   ; AL = 10110101b (bit 0 invertito)
XOR AL, 00000001b   ; AL = 10110100b (bit 0 ri-invertito)
```

#### 3. Scambiare Valori senza Registro Temporaneo

```assembly
; Swap AX e BX senza usare CX
XOR AX, BX          ; AX = AX XOR BX
XOR BX, AX          ; BX = BX XOR (AX XOR BX) = AX
XOR AX, BX          ; AX = (AX XOR BX) XOR AX = BX
; Risultato: AX e BX scambiati!

; Attenzione: funziona solo se AX ≠ BX inizialmente
```

**Dimostrazione matematica:**
```
Iniziale: AX=A, BX=B
XOR AX, BX    → AX = A⊕B, BX = B
XOR BX, AX    → AX = A⊕B, BX = B⊕(A⊕B) = A
XOR AX, BX    → AX = (A⊕B)⊕A = B, BX = A
```

#### 4. Crittografia Semplice (XOR Cipher)

```assembly
; Cripta/Decripta con chiave
.DATA
    chiave DB 42h
    testo DB 'H','e','l','l','o'
    len EQU $ - testo

.CODE
    LEA SI, testo
    MOV CX, len
cripta_loop:
    MOV AL, [SI]
    XOR AL, chiave      ; Cripta
    MOV [SI], AL
    INC SI
    LOOP cripta_loop
    
; Per decriptare: ripeti XOR con stessa chiave!
; A XOR K XOR K = A
```

#### 5. Verificare se Due Valori Sono Uguali

```assembly
; Controlla se AX = BX
XOR AX, BX
JZ uguali           ; Se AX XOR BX = 0, erano uguali
; Diversi
JMP fine
uguali:
    ; Uguali
fine:

; Attenzione: AX viene modificato!
; Se devi preservare AX:
MOV CX, AX
XOR CX, BX
JZ uguali
```

### Esempi Pratici

**Esempio 1: Checksum XOR**
```assembly
; Calcola checksum XOR di un array
.DATA
    array DB 10h, 20h, 30h, 40h
    len EQU $ - array
    checksum DB ?

.CODE
    LEA SI, array
    MOV CX, len
    XOR AL, AL          ; Inizializza checksum
calc_loop:
    XOR AL, [SI]        ; XOR con ogni elemento
    INC SI
    LOOP calc_loop
    MOV checksum, AL
```

**Esempio 2: Inversione Bit (NOT Simulato)**
```assembly
; Inverti tutti i bit di AL
XOR AL, 0FFh        ; Tutti bit invertiti
; Equivalente a NOT AL, ma imposta flag
```

**Esempio 3: Determinare Segno Diverso**
```assembly
; Controlla se AX e BX hanno segni diversi
MOV CX, AX
XOR CX, BX
JS segni_diversi    ; Se bit sign risultato = 1, segni diversi
; Stesso segno
JMP fine
segni_diversi:
    ; Uno positivo, uno negativo
fine:
```

## NOT - Logical NOT

Inverte tutti i bit dell'operando (complemento a 1).

### Sintassi

```assembly
NOT operando
```

**Operazione**: ogni bit viene invertito (0→1, 1→0).

### Operandi Validi

```assembly
NOT AL
NOT AX
NOT BYTE PTR [BX]
NOT WORD PTR [SI]
NOT variabile
```

### Effetti sui Flag

**NOT non modifica NESSUN flag!**

Questo è importante: se hai bisogno di impostare flag, usa **XOR** con FFh/FFFFh.

```assembly
; NOT non imposta flag
MOV AL, 0
NOT AL              ; AL = FFh, ma ZF non cambia

; XOR imposta flag
MOV AL, 0
XOR AL, 0FFh        ; AL = FFh, ZF=0, SF=1
```

### Differenza NOT vs NEG

```assembly
; NOT: complemento a 1
MOV AL, 5           ; AL = 00000101b
NOT AL              ; AL = 11111010b = FAh = 250 (unsigned)

; NEG: complemento a 2 (negazione)
MOV AL, 5           ; AL = 00000101b
NEG AL              ; AL = 11111011b = FBh = 251 = -5 (signed)

; Relazione: NEG = NOT + 1
MOV AL, 5
NOT AL              ; AL = 11111010b
ADD AL, 1           ; AL = 11111011b (uguale a NEG!)
```

### Esempi Pratici

**Esempio 1: Creare Maschera Inversa**
```assembly
; Hai maschera con alcuni bit a 1
MOV AL, 00001111b   ; Maschera nibble basso
; Vuoi maschera nibble alto
NOT AL              ; AL = 11110000b
```

**Esempio 2: Complemento a 2 Manuale**
```assembly
; Negazione manuale
MOV AL, 42
NOT AL              ; Complemento a 1
ADD AL, 1           ; +1 = complemento a 2
; AL = -42
```

**Esempio 3: Invertire Pattern**
```assembly
.DATA
    pattern DB 10101010b

.CODE
    MOV AL, pattern
    NOT AL              ; AL = 01010101b (pattern invertito)
```

## TEST - Logical Compare

Esegue AND bit a bit ma **non salva** il risultato (solo imposta flag).

### Sintassi

```assembly
TEST operando1, operando2
```

**Operazione**: `operando1 AND operando2` → imposta flag, operandi invariati

### Uso Principale

TEST è identico ad AND, ma:
- **Non modifica** gli operandi (come CMP)
- Imposta i **flag** in base al risultato AND

```assembly
; Verifica se bit 7 di AL è impostato
TEST AL, 80h        ; AL AND 80h, imposta flag
JNZ bit_set         ; Se risultato ≠ 0, bit 7 = 1

; AL rimane invariato!
```

### Confronto TEST vs AND

```assembly
; Con AND (modifica operando):
AND AL, 01h         ; AL viene modificato!
JZ bit_zero
; AL ora vale 0 o 1

; Con TEST (non modifica):
TEST AL, 01h        ; AL invariato
JZ bit_zero
; AL conserva valore originale
```

### Effetti sui Flag

Identici ad **AND**: CF=0, OF=0, SF/ZF/PF impostati.

### Esempi Pratici

**Esempio 1: Verificare se Numero è Pari**
```assembly
TEST AL, 1          ; Testa bit 0
JZ pari             ; Se bit 0 = 0, pari
; Dispari
JMP fine
pari:
    ; Pari
fine:
```

**Esempio 2: Verificare se Registro è Zero**
```assembly
TEST AX, AX         ; AX AND AX = AX (imposta flag)
JZ e_zero           ; Se AX = 0, salta

; Equivalente a:
CMP AX, 0
; o
OR AX, AX

; Ma TEST è più idiomatico e chiaro
```

**Esempio 3: Verificare Multipli Bit**
```assembly
; Controlla se bit 2 E bit 5 sono entrambi impostati
TEST AL, 00100100b  ; Testa bit 2 e 5
JP entrambi         ; Se risultato ha parità pari... (no!)

; Modo corretto:
MOV BL, AL
AND BL, 00100100b
CMP BL, 00100100b
JE entrambi         ; Se risultato = maschera, entrambi a 1
```

**Esempio 4: Verificare se Numero è Potenza di 2**
```assembly
; Un numero è potenza di 2 se ha solo un bit a 1
; Proprietà: n AND (n-1) = 0 per potenze di 2

; Esempio: 8 = 00001000b
;          7 = 00000111b
;      8 & 7 = 00000000b ✓

MOV AL, numero
MOV BL, AL
DEC BL              ; BL = numero - 1
TEST AL, BL         ; numero AND (numero-1)
JZ potenza_di_2     ; Se = 0, è potenza di 2
```

**Esempio 5: Mascherare e Confrontare**
```assembly
; Controlla se i bit 0-3 di AL valgono 5
TEST AL, 0Fh        ; Isola bit 0-3
; Non funziona! TEST solo imposta ZF

; Corretto:
MOV BL, AL
AND BL, 0Fh
CMP BL, 5
JE match
```

## Tabella Riepilogativa

| Istruzione | Operazione | Modifica Operandi | Flag CF/OF | Flag SF/ZF/PF |
|------------|------------|-------------------|------------|---------------|
| AND | dest AND src | Sì | 0 | Impostati |
| OR | dest OR src | Sì | 0 | Impostati |
| XOR | dest XOR src | Sì | 0 | Impostati |
| NOT | NOT dest | Sì | - | Nessuno |
| TEST | dest AND src | No | 0 | Impostati |

## Tabelle di Verità Riepilogative

```
Bit A | Bit B | AND | OR | XOR | Utilizzo Tipico
------|-------|-----|----|----|----------------
  0   |   0   |  0  | 0  | 0  |
  0   |   1   |  0  | 1  | 1  |
  1   |   0   |  0  | 1  | 1  |
  1   |   1   |  1  | 1  | 0  |
      Operazioni      ↓    ↓   ↓
              Azzerare│Set │Toggle
                 bit │bit │bit
```

## Operazioni Comuni e Idioms

### Azzerare Registro

```assembly
XOR AX, AX          ; ✓ Più veloce (2 byte)
SUB AX, AX          ; ✓ Alternativa (2 byte)
MOV AX, 0           ; ✗ Più lento (3 byte)
AND AX, 0           ; ✗ Peggiore (3 byte)
```

### Testare se Zero

```assembly
TEST AX, AX         ; ✓ Idiomatico
OR AX, AX           ; ✓ Alternativa
CMP AX, 0           ; ✓ Più leggibile
```

### Impostare a -1 (Tutti Bit a 1)

```assembly
MOV AX, -1          ; 3 byte
MOV AX, 0FFFFh      ; 3 byte (equivalente)
OR AX, -1           ; 3 byte
NOT AX dopo XOR     ; 4 byte totali
; Su 8086 non c'è modo più corto di MOV
```

### Scambiare Nibble in Byte

```assembly
; AL = 12h, vogliamo AL = 21h
MOV AL, 12h
MOV AH, AL          ; Salva
AND AL, 0Fh         ; AL = 02h (nibble basso)
SHL AL, 4           ; AL = 20h
AND AH, 0F0h        ; AH = 10h (nibble alto)
SHR AH, 4           ; AH = 01h
OR AL, AH           ; AL = 21h
```

### Verificare Bit Specifico

```assembly
; Verifica bit 5 di AL
TEST AL, 00100000b  ; oppure TEST AL, 20h
JNZ bit5_set
```

### Estrarre Campo Bit

```assembly
; Estrai bit 3-6 di AX
MOV BX, AX
AND BX, 01111000b   ; Maschera bit 3-6
SHR BX, 3           ; Shifta in posizione 0-3
; BX contiene valore campo
```

## Best Practices

### 1. Usa XOR per Azzerare

```assembly
XOR AX, AX          ; Più veloce di MOV AX, 0
```

### 2. Usa TEST invece di AND per Verifiche

```assembly
; ❌ Modifica AL
AND AL, 80h
JNZ negativo

; ✓ Non modifica AL
TEST AL, 80h
JNZ negativo
```

### 3. NOT non Imposta Flag

```assembly
; Se servono flag:
XOR AL, 0FFh        ; Inverte e imposta flag
; Invece di:
NOT AL              ; Inverte ma non imposta flag
```

### 4. Usa OR per Testare Zero

```assembly
OR AX, AX           ; Idioma comune per testare zero
JZ is_zero
```

### 5. XOR è Reversibile

```assembly
; Crittografia semplice
XOR AL, chiave      ; Cripta
XOR AL, chiave      ; Decripta (stesso risultato!)
```

## Esercizi Pratici

1. Scrivi codice per contare quanti bit sono impostati a 1 in AL
2. Implementa rotazione di nibble: AL = 1234h → AL = 2143h
3. Verifica se un numero ha un numero pari di bit a 1 (usa PF)
4. Cripta una stringa con chiave XOR a rotazione
5. Estrai e visualizza singolarmente ogni bit di AX

### Soluzione Esercizio 1

```assembly
; Conta bit a 1 in AL
XOR CX, CX          ; Contatore
MOV BL, AL          ; Copia valore
MOV CL, 8           ; 8 bit da testare
conta_loop:
    SHL BL, 1       ; Shifta bit più a sinistra in CF
    JNC non_set     ; Se CF=0, bit era 0
    INC CH          ; Incrementa contatore
non_set:
    DEC CL
    JNZ conta_loop
; CH contiene numero di bit a 1
```

---

**Prossimo argomento:** [Istruzioni di Shift e Rotate](modulo3_04_istruzioni_shift_rotate.md)
