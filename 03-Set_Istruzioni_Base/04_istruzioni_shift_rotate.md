# Istruzioni di Shift e Rotate

## Introduzione

Le istruzioni di shift (scorrimento) e rotate (rotazione) permettono di spostare i bit all'interno di un operando. Sono fondamentali per:
- Moltiplicazioni e divisioni veloci per potenze di 2
- Manipolazione di campi di bit
- Estrazione e inserimento di bit
- Conversioni tra formati
- Operazioni crittografiche e checksum

L'8086 offre due famiglie di istruzioni:
- **SHIFT**: SHL, SHR, SAL, SAR (bit escono dall'operando)
- **ROTATE**: ROL, ROR, RCL, RCR (bit circolano)

## Concetti Fondamentali

### Shift vs Rotate

**SHIFT (Scorrimento)**:
- I bit escono da un lato
- Entrano 0 dall'altro lato
- Il bit che esce va in **CF** (Carry Flag)

**ROTATE (Rotazione)**:
- I bit che escono rientrano dall'altro lato
- Circolazione continua
- CF può far parte della rotazione (RCL/RCR) o solo ricevere l'ultimo bit (ROL/ROR)

### Direzioni

- **LEFT** (sinistra): verso i bit più significativi (**moltiplicazione** per 2)
- **RIGHT** (destra): verso i bit meno significativi (**divisione** per 2)

## SHL - Shift Logical Left

Scorre i bit verso **sinistra** (verso il bit più significativo), inserendo 0 a destra.

### Sintassi

```assembly
SHL destinazione, contatore
```

**Contatore**: può essere:
- `1` (letterale)
- `CL` (registro, per shift multipli)

### Funzionamento

```
┌─────────────────────┐
│ 7 6 5 4 3 2 1 0 ←── 0
└─────────────────────┘
  ↓
 CF (l'ultimo bit spostato)
```

Ogni shift a sinistra **moltiplica per 2**.

### Esempi Base

**Esempio 1: Shift di 1 posizione**
```assembly
MOV AL, 00000101b   ; AL = 5
SHL AL, 1           ; AL = 00001010b = 10 (5 × 2)
                    ; CF = 0 (bit 7 era 0)
```

**Esempio 2: Shift multipli**
```assembly
MOV AL, 00000101b   ; AL = 5
MOV CL, 3           ; Shifta 3 posizioni
SHL AL, CL          ; AL = 00101000b = 40 (5 × 8 = 5 × 2³)
                    ; CF = 0
```

**Esempio 3: Overflow**
```assembly
MOV AL, 10000000b   ; AL = 128
SHL AL, 1           ; AL = 00000000b = 0
                    ; CF = 1 (bit 7 uscito)
```

### Moltiplicazione per Potenze di 2

```assembly
; Moltiplica AX per 2
SHL AX, 1           ; AX = AX × 2

; Moltiplica AX per 4
SHL AX, 1
SHL AX, 1           ; AX = AX × 4
; oppure:
MOV CL, 2
SHL AX, CL          ; AX = AX × 4

; Moltiplica AX per 16
MOV CL, 4
SHL AX, CL          ; AX = AX × 16
```

### Effetti sui Flag

| Flag | Comportamento |
|------|---------------|
| **CF** | Ultimo bit shiftato fuori |
| **OF** | Impostato se segno cambia (solo per shift di 1) |
| **SF** | Segno del risultato |
| **ZF** | 1 se risultato = 0 |
| **PF** | Parità del byte basso |
| **AF** | Indefinito |

### Esempi Pratici

**Esempio 1: Moltiplicazione veloce**
```assembly
; AX × 10 = AX × (8 + 2) = (AX << 3) + (AX << 1)
MOV AX, 25
MOV BX, AX          ; Salva AX
SHL AX, 1           ; AX × 2 = 50
MOV DX, AX          ; Salva AX × 2
SHL AX, 1
SHL AX, 1           ; AX × 8 = 200
ADD AX, DX          ; AX × 8 + AX × 2 = 250
```

**Esempio 2: Allineamento a multipli di potenze di 2**
```assembly
; Allinea AX al multiplo di 8 superiore
; (utile per allineamento memoria)
ADD AX, 7           ; +7 per arrotondare
SHR AX, 3           ; /8
SHL AX, 3           ; ×8
; Esempio: 10 → 16, 15 → 16, 16 → 16
```

**Esempio 3: Estrazione nibble**
```assembly
; Estrai nibble alto di AL
MOV AL, 0A5h        ; AL = 10100101b
MOV BL, AL
SHR BL, 4           ; BL = 00001010b = 0Ah
; Nibble alto estratto
```

## SHR - Shift Logical Right

Scorre i bit verso **destra**, inserendo 0 a sinistra.

### Sintassi

```assembly
SHR destinazione, contatore
```

### Funzionamento

```
    ┌─────────────────────┐
0 ──→ 7 6 5 4 3 2 1 0 │
    └─────────────────────┘
                        ↓
                       CF
```

Ogni shift a destra **divide per 2** (unsigned).

### Esempi Base

**Esempio 1: Divisione per 2**
```assembly
MOV AL, 00001010b   ; AL = 10
SHR AL, 1           ; AL = 00000101b = 5 (10 ÷ 2)
                    ; CF = 0 (bit 0 era 0)
```

**Esempio 2: Divisione per 8**
```assembly
MOV AX, 1000
MOV CL, 3
SHR AX, CL          ; AX = 125 (1000 ÷ 8)
```

**Esempio 3: Perdita bit (resto)**
```assembly
MOV AL, 00001011b   ; AL = 11
SHR AL, 1           ; AL = 00000101b = 5 (11 ÷ 2 = 5)
                    ; CF = 1 (bit perso, era il resto!)
```

### Divisione per Potenze di 2 (Unsigned)

```assembly
; Dividi AX per 2
SHR AX, 1           ; AX = AX ÷ 2

; Dividi AX per 16
MOV CL, 4
SHR AX, CL          ; AX = AX ÷ 16
```

### Effetti sui Flag

Identici a **SHL**.

### Esempi Pratici

**Esempio 1: Estrazione bit pari/dispari**
```assembly
; Separa bit pari e dispari di AL
MOV AL, 10101100b   ; AL = ACh

; Estrai bit dispari (1,3,5,7)
MOV BL, AL
AND BL, 10101010b   ; Maschera bit dispari
SHR BL, 1           ; Compatta: BL = 01010110b

; Estrai bit pari (0,2,4,6)
AND AL, 01010101b   ; Maschera bit pari: AL = 00000100b
```

**Esempio 2: Conversione word → byte**
```assembly
; Media di AX (word) e BX (word) → AL (byte)
ADD AX, BX          ; Somma
RCR AX, 1           ; Divide per 2 (con carry rotation)
; oppure:
SHR AX, 1
MOV AL, AL          ; Risultato in AL
```

## SAL - Shift Arithmetic Left

Identico a **SHL** (stesso opcode).

```assembly
SAL AX, 1           ; Uguale a SHL AX, 1
```

**SAL** è fornito per simmetria con **SAR**, ma è identico a SHL.

## SAR - Shift Arithmetic Right

Scorre i bit verso destra, ma **preserva il segno** (estensione segno).

### Sintassi

```assembly
SAR destinazione, contatore
```

### Funzionamento

```
    ┌─────────────────────┐
bit7 ──→ 7 6 5 4 3 2 1 0 │  (bit 7 replicato)
    └─────────────────────┘
                        ↓
                       CF
```

Il **bit di segno** (bit 7 per byte, bit 15 per word) viene **replicato**.

### Differenza SHR vs SAR

```assembly
; SHR: inserisce 0
MOV AL, 11111100b   ; AL = -4 (signed) o 252 (unsigned)
SHR AL, 1           ; AL = 01111110b = 126 (segno perso!)

; SAR: preserva segno
MOV AL, 11111100b   ; AL = -4 (signed)
SAR AL, 1           ; AL = 11111110b = -2 (segno preservato!)
```

### Divisione con Segno

SAR divide correttamente numeri **signed** per potenze di 2.

**Esempio: Divisione signed**
```assembly
; -8 ÷ 2 = -4
MOV AL, -8          ; AL = 11111000b
SAR AL, 1           ; AL = 11111100b = -4 ✓

; Con SHR (sbagliato per signed):
MOV AL, -8          ; AL = 11111000b
SHR AL, 1           ; AL = 01111100b = 124 ✗
```

**Esempio: Divisione 16-bit signed**
```assembly
MOV AX, -1000
MOV CL, 2
SAR AX, CL          ; AX = -250 (divisione signed corretta)
```

### Arrotondamento con SAR

**ATTENZIONE**: SAR arrotonda verso **-∞** (negativo infinito), non verso 0.

```assembly
; -5 ÷ 2
MOV AL, -5          ; AL = FBh = 11111011b
SAR AL, 1           ; AL = FDh = 11111101b = -3 (non -2!)
; Perché: -5 ÷ 2 = -2.5 → arrotonda a -3
```

Per arrotondare verso 0 (come division):
```assembly
; Divisione -5 ÷ 2 arrotondata a 0
MOV AL, -5
TEST AL, AL         ; Controlla segno
JNS positivo
; Negativo: aggiungi (divisore - 1) prima di SAR
ADD AL, 1           ; AL = -4
positivo:
SAR AL, 1           ; AL = -2 (arrotondato verso 0)
```

### Effetti sui Flag

Identici a **SHL/SHR**.

## ROL - Rotate Left

Ruota i bit verso **sinistra**, il bit più significativo torna al bit meno significativo.

### Sintassi

```assembly
ROL destinazione, contatore
```

### Funzionamento

```
    ┌──────────────────────┐
    │ ┌──────────────────┐ │
    └→│ 7 6 5 4 3 2 1 0 │─┘
      └──────────────────┘
        ↓
       CF (copia bit 7)
```

Il bit che esce **rientra** dall'altra parte e va anche in **CF**.

### Esempi

**Esempio 1: Rotazione base**
```assembly
MOV AL, 10000001b   ; AL = 81h
ROL AL, 1           ; AL = 00000011b = 03h
                    ; CF = 1 (bit 7 era 1)
```

**Esempio 2: Rotazione multipla**
```assembly
MOV AL, 11110000b   ; AL = F0h
MOV CL, 4
ROL AL, CL          ; AL = 00001111b = 0Fh
                    ; Nibble scambiati!
```

**Esempio 3: Ciclico**
```assembly
MOV AL, 10000000b
ROL AL, 1           ; AL = 00000001b, CF=1
ROL AL, 1           ; AL = 00000010b, CF=0
; ... dopo 8 rotazioni
; AL = 10000000b (torna all'originale)
```

### Uso: Scambio Nibble

```assembly
; Scambia nibble alto e basso
MOV AL, 12h         ; AL = 00010010b
MOV CL, 4
ROL AL, CL          ; AL = 00100001b = 21h
```

### Effetti sui Flag

| Flag | Comportamento |
|------|---------------|
| **CF** | Ultimo bit ruotato |
| **OF** | Impostato se bit più significativi cambiano (solo count=1) |
| Altri | Non modificati |

## ROR - Rotate Right

Ruota i bit verso **destra**.

### Sintassi

```assembly
ROR destinazione, contatore
```

### Funzionamento

```
┌──────────────────────┐
│ ┌──────────────────┐ │
└─│ 7 6 5 4 3 2 1 0 │←┘
  └──────────────────┘
                    ↓
                   CF
```

### Esempi

**Esempio 1: Rotazione base**
```assembly
MOV AL, 10000001b   ; AL = 81h
ROR AL, 1           ; AL = 11000000b = C0h
                    ; CF = 1 (bit 0 era 1)
```

**Esempio 2: Scambio nibble (alternativa)**
```assembly
MOV AL, 12h
MOV CL, 4
ROR AL, CL          ; AL = 21h (equivalente a ROL AL, 4)
```

### Effetti sui Flag

Identici a **ROL**.

## RCL - Rotate Through Carry Left

Ruota verso sinistra **includendo CF** nella rotazione.

### Sintassi

```assembly
RCL destinazione, contatore
```

### Funzionamento

```
    ┌─────────────────────┐
    │ ┌────────────────┐  │
    └→│CF│7 6 5 4 3 2 1 0│─┘
      └────────────────┘
```

CF fa parte della rotazione (9 bit per byte, 17 bit per word).

### Esempi

**Esempio 1: Rotazione con CF**
```assembly
CLC                 ; CF = 0
MOV AL, 10000001b
RCL AL, 1           ; AL = 00000010b (shift + 0 da CF)
                    ; CF = 1 (bit 7 uscito)
RCL AL, 1           ; AL = 00000101b (shift + 1 da CF)
                    ; CF = 0
```

**Esempio 2: Shift multi-word**
```assembly
; Shift left di 32-bit (DX:AX)
SHL AX, 1           ; Shifta parte bassa, bit 15 → CF
RCL DX, 1           ; Shifta parte alta, CF → bit 0
; Risultato: DX:AX shiftato a sinistra di 1
```

### Uso: Aritmetica Multi-Precisione

**Shift 64-bit a sinistra:**
```assembly
; [BP+8]:[BP+6]:[BP+4]:[BP+2] (4 word = 64 bit)
SHL WORD PTR [BP+2], 1      ; Prima word
RCL WORD PTR [BP+4], 1      ; Seconda word (+ carry)
RCL WORD PTR [BP+6], 1      ; Terza word
RCL WORD PTR [BP+8], 1      ; Quarta word
; 64-bit shiftato a sinistra
```

## RCR - Rotate Through Carry Right

Ruota verso destra **includendo CF**.

### Sintassi

```assembly
RCR destinazione, contatore
```

### Funzionamento

```
┌─────────────────────┐
│  ┌────────────────┐ │
└─ │7 6 5 4 3 2 1 0│CF│←┘
   └────────────────┘
```

### Esempi

**Esempio 1: Rotazione con CF**
```assembly
STC                 ; CF = 1
MOV AL, 10000001b
RCR AL, 1           ; AL = 11000000b (1 da CF + shift)
                    ; CF = 1 (bit 0 uscito)
```

**Esempio 2: Shift right multi-word**
```assembly
; Shift right di DX:AX (32-bit)
SHR DX, 1           ; Shifta parte alta, bit 0 → CF
RCR AX, 1           ; Shifta parte bassa, CF → bit 15
```

**Esempio 3: Divisione per 2 con 32-bit**
```assembly
; Dividi DX:AX per 2
SHR DX, 1           ; Parte alta ÷ 2
RCR AX, 1           ; Parte bassa ÷ 2, include carry
; DX:AX ora è (DX:AX originale) ÷ 2
```

## Tabella Riepilogativa

| Istruzione | Direzione | Inserisce | Bit Uscito | Uso Principale |
|------------|-----------|-----------|------------|----------------|
| **SHL**    | Left ←    | 0         | CF ← bit più significativo | Moltiplicazione × 2ⁿ |
| **SHR**    | Right →   | 0         | CF ← bit meno significativo | Divisione ÷ 2ⁿ (unsigned) |
| **SAL**    | Left ←    | 0         | CF ← bit più significativo | = SHL |
| **SAR**    | Right →   | Bit segno | CF ← bit meno significativo | Divisione ÷ 2ⁿ (signed) |
| **ROL**    | Left ←    | Bit uscito| CF ← bit più significativo | Rotazione, scambio nibble |
| **ROR**    | Right →   | Bit uscito| CF ← bit meno significativo | Rotazione, scambio nibble |
| **RCL**    | Left ←    | CF        | CF ← bit più significativo | Multi-word shift left |
| **RCR**    | Right →   | CF        | CF ← bit meno significativo | Multi-word shift right |

## Confronto Shift vs Rotate

| Operazione | SHL | ROL | RCL |
|------------|-----|-----|-----|
| AL = 10000001b | | | |
| Iniziale CF | - | - | 0 |
| Shift 1 | AL=00000010b, CF=1 | AL=00000011b, CF=1 | AL=00000010b, CF=1 |
| Shift 2 | AL=00000100b, CF=0 | AL=00000110b, CF=0 | AL=00000101b, CF=0 |
| Shift 8 | AL=00000000b, CF=0 | AL=10000001b, CF=1 | AL=00000010b, CF=1 |

## Applicazioni Pratiche

### 1. Moltiplicazione/Divisione Veloce

```assembly
; AX × 8
MOV CL, 3
SHL AX, CL          ; Molto più veloce di MUL

; AX ÷ 4
MOV CL, 2
SHR AX, CL          ; Molto più veloce di DIV
```

### 2. Estrazione Campi Bit

```assembly
; Estrai bit 4-7 di AL
MOV BL, AL
SHR BL, 4           ; Shifta in posizione 0-3
AND BL, 0Fh         ; Maschera (opzionale se già 0)
```

### 3. Inserimento Campi Bit

```assembly
; Inserisci valore (0-15) in bit 4-7 di AL
AND AL, 0Fh         ; Azzera bit 4-7
MOV BL, valore
AND BL, 0Fh         ; Assicura valore ≤ 15
SHL BL, 4           ; Posiziona in bit 4-7
OR AL, BL           ; Combina
```

### 4. Shift Multi-Word

```assembly
; Shift left 32-bit in DX:AX
SHL AX, 1
RCL DX, 1

; Shift right 32-bit
SHR DX, 1
RCR AX, 1
```

### 5. Rotazione per Checksum

```assembly
; Calcola checksum rotazionale
XOR AX, AX          ; Checksum = 0
LEA SI, dati
MOV CX, lunghezza
checksum_loop:
    ROL AX, 1       ; Ruota checksum
    XOR AL, [SI]    ; XOR con byte corrente
    INC SI
    LOOP checksum_loop
; AX contiene checksum
```

### 6. Scambio Byte in Word (Byte Swapping)

```assembly
; AX = 1234h → AX = 3412h
MOV AX, 1234h

; Metodo 1: con rotate
ROL AX, 8           ; o ROR AX, 8

; Metodo 2: con XCHG
XCHG AH, AL

; Metodo 3: manuale
MOV BX, AX
SHL AX, 8           ; AH in AL (parte bassa)
SHR BX, 8           ; AL in BL
OR AX, BX
```

## Ottimizzazioni e Performance

### Velocità Istruzioni

```assembly
; Più veloci:
SHL AX, 1           ; Shift di 1 (veloce)
ROL AL, 1

; Più lenti:
MOV CL, 5
SHL AX, CL          ; Shift multipli (più lento)
```

### Moltiplicazioni Complesse

```assembly
; AX × 7 = AX × (8 - 1) = (AX << 3) - AX
MOV BX, AX
SHL AX, 3           ; AX × 8
SUB AX, BX          ; - AX originale

; AX × 9 = AX × (8 + 1)
MOV BX, AX
SHL AX, 3
ADD AX, BX

; AX × 5 = AX × (4 + 1)
MOV BX, AX
SHL AX, 2
ADD AX, BX
```

### Allineamento Memoria

```assembly
; Allinea AX a multiplo di 16
ADD AX, 15          ; Aggiungi (allineamento - 1)
SHR AX, 4           ; Dividi per 16
SHL AX, 4           ; Moltiplica per 16
; Risultato: multiplo di 16 ≥ AX originale
```

## Best Practices

### 1. Usa Shift per Moltiplicazioni/Divisioni per 2ⁿ

```assembly
; ❌ Lento
MOV BX, 8
MUL BX              ; AX × 8

; ✓ Veloce
MOV CL, 3
SHL AX, CL          ; AX × 8 (molto più veloce!)
```

### 2. SAR per Divisioni Signed

```assembly
; Divisione signed
SAR AX, 2           ; AX ÷ 4 (signed corretto)

; Non usare:
SHR AX, 2           ; Sbagliato per numeri negativi!
```

### 3. RCL/RCR per Multi-Word

```assembly
; Shift 64-bit: usa RCL/RCR per propagare carry
SHL word1, 1
RCL word2, 1
RCL word3, 1
RCL word4, 1
```

### 4. ROL per Scambio Nibble

```assembly
; Scambio nibble
MOV CL, 4
ROL AL, CL          ; 1 istruzione invece di molte
```

### 5. Attenzione ai Flag

```assembly
; Shift modifica OF solo per count=1
SHL AX, 1           ; OF valido
MOV CL, 2
SHL AX, CL          ; OF indefinito!
```

## Esercizi Pratici

1. Implementa moltiplicazione per 13 usando solo shift e add/sub
2. Estrai bit 3,5,7 di AL e impacchettali nei bit 0,1,2 di BL
3. Ruota circolarmente gli elementi di un array di 4 byte
4. Implementa divisione signed per 8 con arrotondamento verso 0
5. Calcola numero di trailing zeros in AX (bit 0 consecutivi a 0)

### Soluzione Esercizio 1

```assembly
; AX × 13 = AX × (16 - 3) = (AX << 4) - (AX << 1) - AX
MOV BX, AX          ; Salva AX
MOV CX, AX          ; Salva AX
SHL AX, 4           ; AX × 16
SHL BX, 1           ; BX × 2
SUB AX, BX          ; AX × 16 - AX × 2 = AX × 14
SUB AX, CX          ; AX × 14 - AX = AX × 13
```

### Soluzione Esercizio 5

```assembly
; Conta trailing zeros (bit 0 consecutivi a zero)
; Esempio: 00011000b ha 3 trailing zeros

TEST AX, AX
JZ tutti_zero       ; Se AX=0, tutti bit sono 0

XOR CX, CX          ; Contatore
conta_loop:
    TEST AX, 1      ; Testa bit 0
    JNZ fine        ; Se bit 0 = 1, fine
    INC CX          ; Incrementa contatore
    SHR AX, 1       ; Shifta a destra
    JMP conta_loop

fine:
; CX contiene numero di trailing zeros
```

---

**Prossimo argomento:** [Quiz Modulo 3](05_quiz.md)
