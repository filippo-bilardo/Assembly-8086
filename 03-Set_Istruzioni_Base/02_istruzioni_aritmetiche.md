# Istruzioni Aritmetiche

## Introduzione

Le istruzioni aritmetiche permettono di eseguire operazioni matematiche fondamentali: addizione, sottrazione, moltiplicazione e divisione. L'8086 distingue tra operazioni con e senza segno, e molte istruzioni influenzano il registro FLAGS per segnalare overflow, riporti e altri risultati.

## ADD - Addition

Addiziona sorgente a destinazione.

### Sintassi

```assembly
ADD destinazione, sorgente
```

**Risultato**: `destinazione = destinazione + sorgente`

### Operandi Validi

```assembly
; Registro ← Registro
ADD AX, BX          ; AX = AX + BX
ADD AL, BL          ; AL = AL + BL

; Registro ← Immediato
ADD AX, 100         ; AX = AX + 100
ADD CL, 5           ; CL = CL + 5

; Registro ← Memoria
ADD AX, [BX]        ; AX = AX + [BX]
ADD DX, variabile   ; DX = DX + variabile

; Memoria ← Registro
ADD [SI], AX        ; [SI] = [SI] + AX
ADD variabile, BX   ; variabile = variabile + BX

; Memoria ← Immediato
ADD BYTE PTR [BX], 10       ; [BX] = [BX] + 10
ADD WORD PTR [SI], 1000h    ; [SI] = [SI] + 1000h
```

### Operandi NON Validi

```assembly
; ❌ ERRORI
ADD [BX], [SI]      ; Memoria ← Memoria non permesso
ADD 100, AX         ; Immediato non può essere destinazione
ADD AL, BX          ; Dimensioni diverse (8 vs 16 bit)
```

### Effetti sui Flag

| Flag | Significato |
|------|-------------|
| **CF** | Carry Flag - riporto bit più significativo (unsigned overflow) |
| **OF** | Overflow Flag - overflow aritmetico con segno |
| **SF** | Sign Flag - segno del risultato (bit più significativo) |
| **ZF** | Zero Flag - risultato è zero |
| **PF** | Parity Flag - parità byte meno significativo |
| **AF** | Auxiliary Flag - riporto dal bit 3 (BCD) |

### Esempi Pratici

**Esempio 1: Addizione semplice**
```assembly
MOV AX, 5
ADD AX, 3           ; AX = 8
; CF=0, OF=0, ZF=0, SF=0
```

**Esempio 2: Overflow senza segno (CF)**
```assembly
MOV AL, 255         ; AL = FFh (massimo unsigned 8-bit)
ADD AL, 1           ; AL = 0 (overflow!)
; CF=1 (riporto!), ZF=1, SF=0
```

**Esempio 3: Overflow con segno (OF)**
```assembly
MOV AL, 127         ; AL = 7Fh (massimo signed 8-bit)
ADD AL, 1           ; AL = 128 = 80h = -128 (overflow!)
; OF=1 (overflow signed!), CF=0, SF=1 (negativo)
```

**Esempio 4: Addizione 32-bit**
```assembly
; Somma DX:AX + CX:BX → DX:AX
ADD AX, BX          ; Parte bassa
ADC DX, CX          ; Parte alta (con riporto)
```

## ADC - Add with Carry

Addiziona sorgente + destinazione + CF (carry flag).

### Sintassi

```assembly
ADC destinazione, sorgente
```

**Risultato**: `destinazione = destinazione + sorgente + CF`

### Uso Principale: Aritmetica Multi-Precisione

ADC è essenziale per sommare numeri più grandi di 16 bit.

**Esempio: Somma 32-bit**
```assembly
; Somma 12345678h + 87654321h
;     DX:AX  +    CX:BX
MOV DX, 1234h
MOV AX, 5678h       ; DX:AX = 12345678h

MOV CX, 8765h
MOV BX, 4321h       ; CX:BX = 87654321h

ADD AX, BX          ; Somma parte bassa
                    ; AX = 5678h + 4321h = 9999h
                    ; CF = 0

ADC DX, CX          ; Somma parte alta + CF
                    ; DX = 1234h + 8765h + 0 = 9999h
; Risultato: DX:AX = 99999999h
```

**Esempio: Somma 64-bit**
```assembly
; num1 in [BP+8]:[BP+6]:[BP+4]:[BP+2] (4 word)
; num2 in [BP+16]:[BP+14]:[BP+12]:[BP+10]

MOV AX, [BP+2]
ADD AX, [BP+10]     ; Prima word
MOV [BP+2], AX

MOV AX, [BP+4]
ADC AX, [BP+12]     ; Seconda word + CF
MOV [BP+4], AX

MOV AX, [BP+6]
ADC AX, [BP+14]     ; Terza word + CF
MOV [BP+6], AX

MOV AX, [BP+8]
ADC AX, [BP+16]     ; Quarta word + CF
MOV [BP+8], AX
```

### Effetti sui Flag

Identici a **ADD**: CF, OF, SF, ZF, PF, AF

## SUB - Subtraction

Sottrae sorgente da destinazione.

### Sintassi

```assembly
SUB destinazione, sorgente
```

**Risultato**: `destinazione = destinazione - sorgente`

### Operandi

Stessi di **ADD** (reg/mem/imm).

### Effetti sui Flag

| Flag | Significato |
|------|-------------|
| **CF** | Prestito (borrow) - risultato negativo per unsigned |
| **OF** | Overflow aritmetico con segno |
| **SF** | Segno del risultato |
| **ZF** | Risultato è zero |

### Esempi Pratici

**Esempio 1: Sottrazione semplice**
```assembly
MOV AX, 10
SUB AX, 3           ; AX = 7
; CF=0, ZF=0, SF=0
```

**Esempio 2: Risultato zero**
```assembly
MOV AX, 5
SUB AX, 5           ; AX = 0
; ZF=1, CF=0
```

**Esempio 3: Underflow unsigned (CF)**
```assembly
MOV AL, 5
SUB AL, 10          ; AL = 251 (5 - 10 = -5 = FBh unsigned)
; CF=1 (prestito!), SF=1 (negativo)
```

**Esempio 4: Azzerare registro**
```assembly
SUB AX, AX          ; AX = 0, ZF=1 (imposta zero flag!)
; Più efficiente di MOV AX, 0 per impostare ZF
```

## SBB - Subtract with Borrow

Sottrae sorgente + CF da destinazione.

### Sintassi

```assembly
SBB destinazione, sorgente
```

**Risultato**: `destinazione = destinazione - sorgente - CF`

### Uso: Sottrazione Multi-Precisione

**Esempio: Sottrazione 32-bit**
```assembly
; Sottrai CX:BX da DX:AX → DX:AX
SUB AX, BX          ; Parte bassa
SBB DX, CX          ; Parte alta (con prestito)
```

**Esempio completo:**
```assembly
; 12345678h - 01234567h
MOV DX, 1234h
MOV AX, 5678h       ; DX:AX = 12345678h

MOV CX, 0123h
MOV BX, 4567h       ; CX:BX = 01234567h

SUB AX, BX          ; 5678h - 4567h = 1111h, CF=0
SBB DX, CX          ; 1234h - 0123h - 0 = 1111h
; Risultato: DX:AX = 11111111h
```

## INC - Increment

Incrementa l'operando di 1.

### Sintassi

```assembly
INC operando
```

**Risultato**: `operando = operando + 1`

### Operandi Validi

```assembly
INC AX              ; AX = AX + 1
INC AL              ; AL = AL + 1
INC BYTE PTR [BX]   ; [BX] = [BX] + 1
INC variabile       ; variabile++
```

### Effetti sui Flag

**IMPORTANTE**: INC **NON modifica CF** (Carry Flag)!

Modifica: OF, SF, ZF, PF, AF

### Quando Usare INC vs ADD

```assembly
; INC è più compatto e veloce
INC AX              ; 1 byte: 40
ADD AX, 1           ; 3 byte: 05 01 00

; Ma se ti serve CF, usa ADD
MOV AL, 255
INC AL              ; AL=0, ma CF non cambia!
ADD AL, 1           ; AL=0, CF=1 ✓
```

### Esempio: Loop Counter

```assembly
MOV CX, 0
loop_inizio:
    ; ... codice ...
    
    INC CX              ; CX++
    CMP CX, 100
    JL loop_inizio      ; Ripeti se CX < 100
```

## DEC - Decrement

Decrementa l'operando di 1.

### Sintassi

```assembly
DEC operando
```

**Risultato**: `operando = operando - 1`

### Effetti sui Flag

Come **INC**: **NON modifica CF**!

Modifica: OF, SF, ZF, PF, AF

### Esempi

```assembly
; Countdown
MOV CX, 10
countdown:
    ; ... codice ...
    
    DEC CX              ; CX--
    JNZ countdown       ; Ripeti se CX != 0
```

**Uso tipico con LOOP:**
```assembly
MOV CX, 10
loop_inizio:
    ; ... corpo loop ...
    
    LOOP loop_inizio    ; DEC CX; JNZ loop_inizio
```

## NEG - Negate

Nega l'operando (complemento a due).

### Sintassi

```assembly
NEG operando
```

**Risultato**: `operando = -operando = NOT operando + 1`

### Esempi

```assembly
MOV AL, 5
NEG AL              ; AL = -5 = FBh = 251 unsigned
; CF=1 (a meno che operando=0), SF=1

MOV AX, -10
NEG AX              ; AX = 10
; Negare un negativo dà positivo

MOV AL, 0
NEG AL              ; AL = 0 (caso speciale)
; CF=0, ZF=1
```

### Effetti sui Flag

| Flag | Comportamento |
|------|---------------|
| **CF** | 1 se operando ≠ 0, altrimenti 0 |
| **OF** | 1 se operando = -128 (byte) o -32768 (word) |
| **ZF** | 1 se risultato = 0 |
| **SF** | Segno del risultato |

### Esempio: Valore Assoluto

```assembly
; Calcola valore assoluto di AX
; Se AX < 0, negalo

TEST AX, AX         ; Test segno (imposta SF)
JNS gia_positivo    ; Salta se SF=0 (non negativo)
NEG AX              ; Se negativo, nega
gia_positivo:
; AX ora è positivo
```

## MUL - Unsigned Multiplication

Moltiplicazione **senza segno**.

### Sintassi

```assembly
MUL operando
```

### Comportamento

| Dimensione | Operazione | Risultato |
|------------|------------|-----------|
| 8-bit      | AL × operando | AX |
| 16-bit     | AX × operando | DX:AX |

**Moltiplicando implicito**: AL (8-bit) o AX (16-bit)

### Esempi 8-bit

```assembly
; 10 × 20 = 200
MOV AL, 10
MOV BL, 20
MUL BL              ; AX = AL × BL = 200 = 00C8h
                    ; AH = 0, AL = C8h (200)
```

**Overflow 8-bit:**
```assembly
; 200 × 2 = 400 (overflow!)
MOV AL, 200         ; AL = C8h
MOV BL, 2
MUL BL              ; AX = 400 = 0190h
                    ; AH = 01h, AL = 90h
                    ; CF=1, OF=1 (parte alta non zero)
```

### Esempi 16-bit

```assembly
; 1000 × 2000 = 2000000
MOV AX, 1000        ; AX = 03E8h
MOV BX, 2000        ; BX = 07D0h
MUL BX              ; DX:AX = AX × BX = 001E8480h
                    ; DX = 001Eh, AX = 8480h
```

### Effetti sui Flag

| Flag | Comportamento |
|------|---------------|
| **CF, OF** | 1 se parte alta (AH o DX) ≠ 0 |
| **SF, ZF, AF, PF** | Indefiniti |

### Esempio: Area Rettangolo

```assembly
.DATA
    base DW 50
    altezza DW 30
    area DW ?

.CODE
    MOV AX, base
    MUL altezza         ; DX:AX = 50 × 30 = 1500
    MOV area, AX        ; Salva risultato (parte bassa)
    ; Se DX ≠ 0, c'è overflow!
```

## IMUL - Signed Multiplication

Moltiplicazione **con segno** (complemento a due).

### Sintassi

```assembly
IMUL operando
```

### Comportamento

Identico a **MUL**, ma interpreta gli operandi come **numeri con segno**.

### Esempi

```assembly
; 10 × (-5) = -50
MOV AL, 10          ; AL = 0Ah
MOV BL, -5          ; BL = FBh (complemento a due di 5)
IMUL BL             ; AX = -50 = FFCEh
                    ; AH = FFh (estensione segno)
                    ; AL = CEh

; (-10) × (-5) = 50
MOV AL, -10         ; AL = F6h
MOV BL, -5          ; BL = FBh
IMUL BL             ; AX = 50 = 0032h
```

### Differenza MUL vs IMUL

```assembly
; Stesso bit pattern, interpretazione diversa

MOV AL, 250         ; AL = FAh
MOV BL, 2           ; BL = 02h

MUL BL              ; AX = 500 = 01F4h (unsigned)

MOV AL, 250         ; AL = FAh = -6 (signed)
MOV BL, 2
IMUL BL             ; AX = -12 = FFF4h (signed)
```

### Effetti sui Flag

| Flag | Comportamento |
|------|---------------|
| **CF, OF** | 1 se parte alta ≠ estensione segno di parte bassa |
| Altri | Indefiniti |

**Estensione segno**: se AL è negativo, AH deve essere FFh; se positivo, 00h.

```assembly
; Esempio CF/OF con IMUL
MOV AL, 10
MOV BL, 10
IMUL BL             ; AX = 100 = 0064h
                    ; AH = 00h (estensione segno corretta)
                    ; CF=0, OF=0

MOV AL, 100
MOV BL, 2
IMUL BL             ; AX = 200 = 00C8h
                    ; AH = 00h, ma 200 > 127 (overflow!)
                    ; CF=1, OF=1
```

## DIV - Unsigned Division

Divisione **senza segno**.

### Sintassi

```assembly
DIV divisore
```

### Comportamento

| Dimensione | Operazione | Quoziente | Resto |
|------------|------------|-----------|-------|
| 8-bit      | AX ÷ divisore | AL | AH |
| 16-bit     | DX:AX ÷ divisore | AX | DX |

**Dividendo implicito**: AX (8-bit) o DX:AX (16-bit)

### Esempi 8-bit

```assembly
; 100 ÷ 7 = 14 resto 2
MOV AX, 100         ; Dividendo
MOV BL, 7           ; Divisore
DIV BL              ; AL = 14 (quoziente)
                    ; AH = 2 (resto)
```

**ATTENZIONE: Overflow!**
```assembly
; 300 ÷ 2 = 150, ma AL può contenere max 255!
MOV AX, 300         ; AX = 012Ch
MOV BL, 2
DIV BL              ; AL = 150 ✓ (OK)

; 1000 ÷ 2 = 500, ma AL può contenere max 255!
MOV AX, 1000        ; AX = 03E8h
MOV BL, 2
DIV BL              ; ERRORE! Divide error (INT 0)
```

### Esempi 16-bit

```assembly
; 100000 ÷ 300
MOV DX, 1           ; Parte alta
MOV AX, 34464       ; Parte bassa (DX:AX = 100000)
MOV BX, 300
DIV BX              ; AX = 333 (quoziente)
                    ; DX = 100 (resto)
```

### Preparazione Dividendo 16-bit

Per dividere un valore in AX (16-bit) per un divisore 16-bit:

```assembly
; SBAGLIATO:
MOV AX, 1000
MOV BX, 3
DIV BX              ; DX contiene spazzatura!

; CORRETTO:
MOV AX, 1000
XOR DX, DX          ; Azzera DX (parte alta)
MOV BX, 3
DIV BX              ; AX = 333, DX = 1
```

### Divisione per Zero

```assembly
MOV AX, 100
MOV BL, 0
DIV BL              ; INT 0 (Divide Error) - CRASH!
```

**Protezione:**
```assembly
MOV AX, 100
MOV BL, divisore
TEST BL, BL         ; Controlla se BL = 0
JZ divisore_zero    ; Salta se zero
DIV BL              ; Sicuro
JMP fine
divisore_zero:
    ; Gestisci errore
fine:
```

### Effetti sui Flag

**TUTTI i flag sono INDEFINITI** dopo DIV.

## IDIV - Signed Division

Divisione **con segno**.

### Sintassi

```assembly
IDIV divisore
```

### Comportamento

Identico a **DIV**, ma operandi con segno.

### Esempi

```assembly
; 100 ÷ (-7) = -14 resto 2
MOV AX, 100
MOV BL, -7          ; BL = F9h
IDIV BL             ; AL = -14 = F2h (quoziente)
                    ; AH = 2 (resto)

; (-100) ÷ 7 = -14 resto -2
MOV AX, -100        ; AX = FF9Ch
MOV BL, 7
IDIV BL             ; AL = -14 = F2h
                    ; AH = -2 = FEh
```

### Preparazione Dividendo con Segno

Per estendere il segno da 8 a 16 bit: **CBW**
Per estendere il segno da 16 a 32 bit: **CWD**

```assembly
; Dividi AL (signed) per BL
MOV AL, -50         ; AL = CEh
CBW                 ; AX = FFCEh (estende segno)
MOV BL, 3
IDIV BL             ; AL = -16, AH = -2

; Dividi AX (signed) per BX
MOV AX, -1000       ; AX = FC18h
CWD                 ; DX:AX = FFFFFC18h (estende segno)
MOV BX, 7
IDIV BX             ; AX = -142, DX = -6
```

### CBW e CWD

**CBW** - Convert Byte to Word
```assembly
MOV AL, -5          ; AL = FBh
CBW                 ; AX = FFFBh (estende segno di AL in AH)
```

**CWD** - Convert Word to Doubleword
```assembly
MOV AX, -1000       ; AX = FC18h
CWD                 ; DX = FFFFh (estende segno di AX in DX)
                    ; DX:AX = FFFFFC18h
```

## CMP - Compare

Confronta due operandi **sottraendo** ma **senza salvare** il risultato.

### Sintassi

```assembly
CMP operando1, operando2
```

**Operazione interna**: `operando1 - operando2` (solo flag modificati)

### Uso

CMP imposta i flag come se facessi SUB, ma **non modifica gli operandi**.

```assembly
CMP AX, BX          ; Calcola AX - BX, imposta flag
                    ; AX e BX NON cambiano

; Equivalente a:
; PUSH AX
; SUB AX, BX        ; Flag impostati
; POP AX            ; Ripristina AX
```

### Salti Condizionati dopo CMP

#### Confronti Unsigned

| Condizione | Salto | Flag |
|------------|-------|------|
| op1 = op2  | JE / JZ | ZF=1 |
| op1 ≠ op2  | JNE / JNZ | ZF=0 |
| op1 > op2  | JA / JNBE | CF=0 e ZF=0 |
| op1 ≥ op2  | JAE / JNB | CF=0 |
| op1 < op2  | JB / JNAE | CF=1 |
| op1 ≤ op2  | JBE / JNA | CF=1 o ZF=1 |

#### Confronti Signed

| Condizione | Salto | Flag |
|------------|-------|------|
| op1 = op2  | JE / JZ | ZF=1 |
| op1 ≠ op2  | JNE / JNZ | ZF=0 |
| op1 > op2  | JG / JNLE | ZF=0 e SF=OF |
| op1 ≥ op2  | JGE / JNL | SF=OF |
| op1 < op2  | JL / JNGE | SF≠OF |
| op1 ≤ op2  | JLE / JNG | ZF=1 o SF≠OF |

### Esempi

**Esempio 1: If-Then-Else**
```assembly
; if (AX == 10) { ... } else { ... }

CMP AX, 10
JE uguale
; Codice per AX ≠ 10
JMP fine
uguale:
    ; Codice per AX = 10
fine:
```

**Esempio 2: Confronto Unsigned**
```assembly
; if (AL > 200) ...
CMP AL, 200
JA maggiore         ; Jump if Above (unsigned)
; AL ≤ 200
JMP fine
maggiore:
    ; AL > 200
fine:
```

**Esempio 3: Confronto Signed**
```assembly
; if (AX < -100) ...
CMP AX, -100
JL minore           ; Jump if Less (signed)
; AX ≥ -100
JMP fine
minore:
    ; AX < -100
fine:
```

## Tabella Riepilogativa

| Istruzione | Operazione | Operandi | Flag |
|------------|------------|----------|------|
| ADD | dest + src | reg/mem, reg/mem/imm | CF OF SF ZF PF AF |
| ADC | dest + src + CF | reg/mem, reg/mem/imm | CF OF SF ZF PF AF |
| SUB | dest - src | reg/mem, reg/mem/imm | CF OF SF ZF PF AF |
| SBB | dest - src - CF | reg/mem, reg/mem/imm | CF OF SF ZF PF AF |
| INC | dest + 1 | reg/mem | OF SF ZF PF AF |
| DEC | dest - 1 | reg/mem | OF SF ZF PF AF |
| NEG | -dest (compl. 2) | reg/mem | CF OF SF ZF PF AF |
| MUL | AL/AX × src | reg/mem 8/16 | CF OF (altri indef.) |
| IMUL | AL/AX × src (signed) | reg/mem 8/16 | CF OF (altri indef.) |
| DIV | AX/DX:AX ÷ src | reg/mem 8/16 | Tutti indefiniti |
| IDIV | AX/DX:AX ÷ src (signed) | reg/mem 8/16 | Tutti indefiniti |
| CMP | dest - src (no salv.) | reg/mem, reg/mem/imm | CF OF SF ZF PF AF |
| CBW | Estende AL → AX | - | - |
| CWD | Estende AX → DX:AX | - | - |

## Best Practices

### 1. Usa INC/DEC per ±1

```assembly
; ❌ Lento
ADD CX, 1           ; 3-4 byte

; ✓ Veloce
INC CX              ; 1 byte
```

### 2. Controlla Overflow Moltiplicazione

```assembly
MUL BX
JC overflow         ; Se CF=1, risultato > 16 bit
; Risultato OK in AX
JMP ok
overflow:
    ; Gestisci overflow (usa DX:AX)
ok:
```

### 3. Azzera DX prima di DIV 16-bit

```assembly
MOV AX, dividendo
XOR DX, DX          ; IMPORTANTE!
DIV divisore
```

### 4. Protezione Divisione per Zero

```assembly
TEST divisore, divisore
JZ errore_divisione
DIV divisore
```

### 5. Usa CWD/CBW per Signed Division

```assembly
MOV AX, -1000
CWD                 ; Estende segno in DX
IDIV divisore       ; Divisione signed corretta
```

### 6. CMP non Modifica Operandi

```assembly
CMP AX, BX
; AX e BX invariati, solo flag cambiati
JE uguale
```

## Esercizi Pratici

1. Calcola 12345678h + 87654321h (32-bit) e salva in DX:AX
2. Moltiplica AX per 10 senza usare MUL (solo shift e add)
3. Implementa divisione per 2 con signed preservando segno
4. Scrivi codice per trovare il massimo tra tre numeri in AX, BX, CX
5. Calcola media di 5 numeri salvati in un array

### Soluzione Esercizio 2

```assembly
; AX × 10 = AX × (8 + 2) = (AX << 3) + (AX << 1)
MOV BX, AX          ; Salva AX
SHL AX, 1           ; AX × 2
MOV CX, AX          ; Salva AX × 2
SHL AX, 1
SHL AX, 1           ; AX × 8
ADD AX, CX          ; AX × 8 + AX × 2 = AX × 10
```

---

**Prossimo argomento:** [Istruzioni Logiche](03_istruzioni_logiche.md)
