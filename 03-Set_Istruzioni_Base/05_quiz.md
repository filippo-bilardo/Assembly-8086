# Quiz Modulo 3 - Set di Istruzioni Base

## Istruzioni
- Rispondi alle domande scegliendo l'opzione corretta
- Ogni domanda ha una sola risposta corretta
- Clicca su "Mostra risposta" per vedere la soluzione e la spiegazione

---

## Domanda 1
Quale istruzione è la più efficiente per azzerare il registro AX?

A) `MOV AX, 0`  
B) `SUB AX, AX`  
C) `XOR AX, AX`  
D) `AND AX, 0`

<details>
<summary>Mostra risposta</summary>

**Risposta corretta: C) `XOR AX, AX`**

**Spiegazione:**
- `XOR AX, AX` è la più efficiente: **2 byte** di codice, veloce da eseguire, e imposta ZF=1
- `SUB AX, AX` è equivalente in dimensione (2 byte) e imposta flag, ma leggermente più lenta
- `MOV AX, 0` richiede **3 byte** (opcode + word immediata)
- `AND AX, 0` richiede anche 3 byte e non è idiomatica

L'idioma `XOR reg, reg` è universalmente riconosciuto come il modo standard per azzerare un registro.
</details>

---

## Domanda 2
Dopo l'esecuzione di questo codice, quale sarà il valore di AL e CF?
```assembly
MOV AL, 255
ADD AL, 1
```

A) AL = 0, CF = 0  
B) AL = 0, CF = 1  
C) AL = 256, CF = 1  
D) AL = 255, CF = 0

<details>
<summary>Mostra risposta</summary>

**Risposta corretta: B) AL = 0, CF = 1**

**Spiegazione:**
- AL è un registro a 8 bit, può contenere valori 0-255
- 255 + 1 = 256, che eccede la capacità di 8 bit
- Risultato: AL = 0 (256 mod 256 = 0)
- **CF = 1** (Carry Flag) segnala l'overflow unsigned
- Questo è un esempio di "wraparound" aritmetico

In binario:
```
  11111111  (255)
+ 00000001  (1)
-----------
1 00000000  (256, bit 8 va in CF)
  ↑
  CF=1
```
</details>

---

## Domanda 3
Qual è la differenza principale tra `SHR` e `SAR`?

A) SHR è più veloce di SAR  
B) SAR preserva il bit di segno, SHR inserisce 0  
C) SHR funziona solo su registri, SAR anche su memoria  
D) SAR può shiftare più di 8 bit alla volta

<details>
<summary>Mostra risposta</summary>

**Risposta corretta: B) SAR preserva il bit di segno, SHR inserisce 0**

**Spiegazione:**

**SHR (Shift Logical Right)**:
```
0 ──→ 7 6 5 4 3 2 1 0 ──→ CF
      Inserisce sempre 0
```

**SAR (Shift Arithmetic Right)**:
```
bit7 ──→ 7 6 5 4 3 2 1 0 ──→ CF
         Replica bit di segno
```

Esempio con -8 (11111000b):
- `SHR AL, 1` → AL = 01111100b = 124 (perde il segno!)
- `SAR AL, 1` → AL = 11111100b = -4 (preserva il segno!)

SAR è essenziale per divisioni signed corrette.
</details>

---

## Domanda 4
Quale istruzione NON modifica l'operando destinazione?

A) `ADD AX, BX`  
B) `AND AL, 0Fh`  
C) `TEST AL, 80h`  
D) `XOR CX, DX`

<details>
<summary>Mostra risposta</summary>

**Risposta corretta: C) `TEST AL, 80h`**

**Spiegazione:**
`TEST` è equivalente a `AND`, ma **non salva il risultato** nell'operando destinazione. Modifica solo i flag.

```assembly
MOV AL, 10101010b
TEST AL, 80h        ; Esegue AL AND 80h, imposta flag
; AL = 10101010b (invariato!)
; ZF = 0 (risultato AND ≠ 0)
```

Confronto con `AND`:
```assembly
MOV AL, 10101010b
AND AL, 80h         ; AL = 10000000b (modificato!)
```

`TEST` è l'equivalente logico di `CMP` (che fa SUB senza salvare).
</details>

---

## Domanda 5
Dopo questo codice, quale sarà il valore di AX?
```assembly
MOV AL, 10
MOV BL, 3
MUL BL
```

A) AX = 30  
B) AL = 30, AH indefinito  
C) AX = 30, DX = 0  
D) Errore di compilazione

<details>
<summary>Mostra risposta</summary>

**Risposta corretta: A) AX = 30**

**Spiegazione:**
`MUL` per operandi a 8 bit funziona così:
- Moltiplicando implicito: **AL**
- Risultato: **AX** (16 bit, anche se serve solo 8 bit)

```assembly
MUL BL  →  AX = AL × BL
```

In questo caso:
- AL = 10
- BL = 3
- AX = 10 × 3 = 30 = 001Eh
- AH = 00h, AL = 1Eh

Se il risultato fosse > 255, AH conterrebbe la parte alta:
```assembly
MOV AL, 200
MOV BL, 2
MUL BL          ; AX = 400 = 0190h
                ; AH = 01h, AL = 90h
```
</details>

---

## Domanda 6
Quale flag NON viene modificato da `INC AX`?

A) ZF (Zero Flag)  
B) SF (Sign Flag)  
C) CF (Carry Flag)  
D) OF (Overflow Flag)

<details>
<summary>Mostra risposta</summary>

**Risposta corretta: C) CF (Carry Flag)**

**Spiegazione:**
`INC` e `DEC` sono le uniche istruzioni aritmetiche che **non modificano CF**.

Flag modificati da `INC/DEC`:
- ✓ ZF - zero flag
- ✓ SF - sign flag
- ✓ OF - overflow flag
- ✓ PF - parity flag
- ✓ AF - auxiliary flag
- ✗ **CF - carry flag** (invariato!)

Questo può causare problemi:
```assembly
MOV AL, 255
INC AL              ; AL = 0, ma CF non cambia!
JC overflow         ; Non salta (CF non impostato)

; Se serve CF, usa ADD:
ADD AL, 1           ; AL = 0, CF = 1 ✓
```
</details>

---

## Domanda 7
Cosa fa questa sequenza di istruzioni?
```assembly
XOR AX, BX
XOR BX, AX
XOR AX, BX
```

A) Azzera AX e BX  
B) Scambia i valori di AX e BX  
C) Imposta AX = BX  
D) Causa un errore

<details>
<summary>Mostra risposta</summary>

**Risposta corretta: B) Scambia i valori di AX e BX**

**Spiegazione:**
Questo è il famoso "XOR swap trick", che scambia due valori senza registro temporaneo.

Dimostrazione (A=AX iniziale, B=BX iniziale):
```
Iniziale:     AX=A,        BX=B
XOR AX, BX → AX=A⊕B,      BX=B
XOR BX, AX → AX=A⊕B,      BX=B⊕(A⊕B)=A
XOR AX, BX → AX=(A⊕B)⊕A=B, BX=A
Finale:       AX=B,        BX=A
```

Esempio concreto:
```
AX=5 (0101), BX=3 (0011)
XOR AX, BX → AX=6 (0110)
XOR BX, AX → BX=5 (0101)
XOR AX, BX → AX=3 (0011)
Risultato: AX=3, BX=5 (scambiati!)
```

**Svantaggio**: più lento di `XCHG AX, BX` su 8086, usato solo in contesti di risorse molto limitate.
</details>

---

## Domanda 8
Prima di eseguire `DIV BL` con un dividendo a 16 bit in AX, cosa bisogna fare?

A) Azzerare BL  
B) Impostare DX = 0  
C) Impostare CF = 0  
D) Niente, AX è già corretto

<details>
<summary>Mostra risposta</summary>

**Risposta corretta: D) Niente, AX è già corretto**

**Spiegazione:**
`DIV` ha due modalità:

**8-bit**: dividendo in **AX** (16 bit)
```assembly
MOV AX, 1000        ; Dividendo
MOV BL, 7           ; Divisore
DIV BL              ; AL = quoziente (142)
                    ; AH = resto (6)
```
Non serve azzerare nulla, AX è il dividendo completo.

**16-bit**: dividendo in **DX:AX** (32 bit)
```assembly
MOV AX, 1000        ; Parte bassa
XOR DX, DX          ; ← IMPORTANTE! Azzera parte alta
MOV BX, 7
DIV BX              ; AX = quoziente, DX = resto
```

**Errore comune**:
```assembly
MOV AX, 1000
; Dimenticare di azzerare DX!
DIV BX              ; DX contiene spazzatura → risultato errato o crash!
```
</details>

---

## Domanda 9
Qual è il risultato di `ROL AL, 4` quando AL = 12h (00010010b)?

A) AL = 21h  
B) AL = 20h  
C) AL = 01h  
D) AL = 48h

<details>
<summary>Mostra risposta</summary>

**Risposta corretta: A) AL = 21h**

**Spiegazione:**
`ROL` (Rotate Left) ruota i bit verso sinistra, reinserendo i bit che escono dall'altra parte.

AL = 12h = 00010010b

Rotazioni successive:
```
Iniziale:  0001 0010  (12h)
ROL 1:     0010 0100  (24h)
ROL 2:     0100 1000  (48h)
ROL 3:     1001 0000  (90h)
ROL 4:     0010 0001  (21h) ✓
          ↑       ↑
     Nibble  Nibble
      basso   alto
```

`ROL AL, 4` scambia efficacemente i nibble (4 bit bassi ↔ 4 bit alti):
- 12h → 21h
- ABh → BAh
- F0h → 0Fh

Trucco mnemonic: ROL di 4 bit scambia le cifre esadecimali!
</details>

---

## Domanda 10
Quale combinazione di istruzioni calcola correttamente -AX (negazione)?

A) `NOT AX` + `INC AX`  
B) `XOR AX, 0FFFFh`  
C) `SUB 0, AX`  
D) `NEG AX`

<details>
<summary>Mostra risposta</summary>

**Risposta corretta: D) `NEG AX`** (ma anche A è corretta!)

**Spiegazione:**
Ci sono due modi per negare un valore (complemento a due):

**Metodo 1: NEG (diretto)**
```assembly
MOV AX, 5
NEG AX              ; AX = -5 = FFFBh
```

**Metodo 2: NOT + INC (manuale)**
```assembly
MOV AX, 5           ; AX = 0005h = 0000000000000101b
NOT AX              ; AX = FFFAh = 1111111111111010b (complemento a 1)
INC AX              ; AX = FFFBh = 1111111111111011b (complemento a 2 = -5)
```

Relazione matematica:
```
-n = NOT(n) + 1 = complemento_a_due(n)
```

**Perché le altre sono sbagliate?**
- B) `XOR AX, 0FFFFh` è equivalente a `NOT AX` (solo complemento a 1, manca +1)
- C) `SUB 0, AX` non è valida (immediato non può essere destinazione)

**Nota**: NEG è più chiara e imposta correttamente i flag (CF, OF).
</details>

---

## Domanda 11
Cosa succede dopo questa sequenza?
```assembly
MOV AL, 5
CBW
```

A) AX = 0005h  
B) AX = 0500h  
C) AX = 00FFh  
D) Errore

<details>
<summary>Mostra risposta</summary>

**Risposta corretta: A) AX = 0005h**

**Spiegazione:**
`CBW` (Convert Byte to Word) estende il segno di AL in AX:
- Se AL è **positivo** (bit 7 = 0): AH = 00h
- Se AL è **negativo** (bit 7 = 1): AH = FFh

Esempi:
```assembly
; Numero positivo
MOV AL, 5           ; AL = 05h = 00000101b
CBW                 ; AX = 0005h (AH = 00h)

; Numero negativo
MOV AL, -5          ; AL = FBh = 11111011b
CBW                 ; AX = FFFBh (AH = FFh)
```

**Uso tipico**: prima di `IDIV` (divisione signed)
```assembly
MOV AL, -50         ; AL = CEh
CBW                 ; AX = FFCEh (estensione segno)
MOV BL, 3
IDIV BL             ; AL = -16 (quoziente), AH = -2 (resto)
```

Senza CBW, AX conterrebbe spazzatura in AH, causando risultati errati.

**CWD**: analoga, estende AX (word) in DX:AX (doubleword).
</details>

---

## Domanda 12
Quale istruzione testa se il bit 7 di AL è impostato SENZA modificare AL?

A) `AND AL, 80h`  
B) `TEST AL, 80h`  
C) `OR AL, 80h`  
D) `SHR AL, 7`

<details>
<summary>Mostra risposta</summary>

**Risposta corretta: B) `TEST AL, 80h`**

**Spiegazione:**

**TEST AL, 80h** (corretto):
```assembly
MOV AL, 10101100b   ; AL = ACh
TEST AL, 80h        ; Esegue AND senza salvare
; AL = 10101100b (invariato!)
; ZF = 0 (risultato AND ≠ 0, quindi bit 7 = 1)
JNZ bit7_set        ; Salta se bit 7 = 1
```

**AND AL, 80h** (sbagliato - modifica AL):
```assembly
MOV AL, 10101100b   ; AL = ACh
AND AL, 80h         ; AL = 10000000b (MODIFICATO!)
; AL perde tutti i bit tranne il 7
```

**OR AL, 80h** (sbagliato - imposta bit 7):
```assembly
OR AL, 80h          ; Forza bit 7 = 1, non testa!
```

**SHR AL, 7** (sbagliato - distrugge AL):
```assembly
SHR AL, 7           ; AL = 00000001b o 00000000b
; AL completamente modificato
```

**Regola generale**: usa `TEST` per verificare bit senza modificare l'operando.
</details>

---

## Domanda 13
Dopo questo codice, quanto vale DX:AX?
```assembly
MOV AX, 1000h
MOV DX, 0
MOV CL, 1
SHL AX, CL
RCL DX, CL
```

A) DX:AX = 00002000h  
B) DX:AX = 00012000h  
C) DX:AX = 20000000h  
D) DX:AX = 00001000h

<details>
<summary>Mostra risposta</summary>

**Risposta corretta: A) DX:AX = 00002000h**

**Spiegazione:**
Questa sequenza esegue un **shift left a 32 bit** su DX:AX.

Passo per passo:
```
Iniziale: DX = 0000h, AX = 1000h
          DX:AX = 00001000h

SHL AX, 1:
  AX = 1000h << 1 = 2000h
  Bit 15 di AX (era 0) → CF = 0
  
  DX = 0000h, AX = 2000h, CF = 0

RCL DX, 1:
  DX ruotato a sinistra includendo CF
  CF (0) → bit 0 di DX
  Bit 15 di DX (era 0) → CF
  DX = 0000h (invariato)
  
Finale: DX:AX = 00002000h
```

**Se AX fosse stato più grande**:
```assembly
MOV AX, 8000h       ; Bit 15 = 1
SHL AX, 1           ; AX = 0000h, CF = 1
RCL DX, 1           ; DX = 0001h (CF entra in bit 0)
; DX:AX = 00010000h (16-bit 8000h shiftato a 32-bit)
```

Questo pattern è essenziale per aritmetica multi-precisione.
</details>

---

## Domanda 14
Quale risultato produce `IMUL` vs `MUL` con AL=250 (FAh) e BL=2?

A) Identico: AX = 500  
B) IMUL: AX = -12, MUL: AX = 500  
C) IMUL: AX = 500, MUL: AX = -12  
D) Entrambi causano overflow

<details>
<summary>Mostra risposta</summary>

**Risposta corretta: B) IMUL: AX = -12, MUL: AX = 500**

**Spiegazione:**

**MUL (unsigned)**:
- Interpreta AL = FAh = 250 (unsigned)
- 250 × 2 = 500 = 01F4h
```assembly
MOV AL, 250         ; AL = FAh
MOV BL, 2
MUL BL              ; AX = 01F4h = 500
```

**IMUL (signed)**:
- Interpreta AL = FAh = -6 (signed, complemento a 2)
- (-6) × 2 = -12 = FFF4h
```assembly
MOV AL, 250         ; AL = FAh = -6 (signed)
MOV BL, 2
IMUL BL             ; AX = FFF4h = -12
```

**Tabella conversione**:
| Bit Pattern | Unsigned | Signed |
|-------------|----------|--------|
| 01111111 (7Fh) | 127 | 127 (max positive) |
| 10000000 (80h) | 128 | -128 (min negative) |
| 11111010 (FAh) | 250 | -6 |
| 11111111 (FFh) | 255 | -1 |

**Regola**: usa IMUL per numeri signed, MUL per unsigned.
</details>

---

## Domanda 15
Quale istruzione imposta AL = 0 E ZF = 1 contemporaneamente?

A) `MOV AL, 0`  
B) `XOR AL, AL`  
C) `AND AL, 0`  
D) Sia B che C

<details>
<summary>Mostra risposta</summary>

**Risposta corretta: D) Sia B che C**

**Spiegazione:**

**MOV non modifica flag**:
```assembly
MOV AL, 0           ; AL = 0, ma ZF non cambia!
; Se ZF era 0, rimane 0
```

**XOR imposta flag**:
```assembly
XOR AL, AL          ; AL = 0, ZF = 1 ✓
; Qualunque valore XOR se stesso = 0
```

**AND imposta flag**:
```assembly
AND AL, 0           ; AL = 0, ZF = 1 ✓
; Qualunque valore AND 0 = 0
```

**Altre opzioni che impostano ZF**:
```assembly
SUB AL, AL          ; AL = 0, ZF = 1
```

**Tabella comparativa**:
| Istruzione | AL risultato | ZF | Byte codice | Velocità |
|------------|--------------|----|----|----------|
| MOV AL, 0 | 0 | Non modifica | 2 | Media |
| XOR AL, AL | 0 | 1 | 2 | Veloce ✓ |
| AND AL, 0 | 0 | 1 | 3 | Lenta |
| SUB AL, AL | 0 | 1 | 2 | Media |

**Best practice**: usa `XOR reg, reg` per azzerare e impostare ZF.
</details>

---

## Domanda 16
In quale situazione `SBB` (Subtract with Borrow) è indispensabile?

A) Sottrazione normale di due numeri  
B) Sottrazione multi-precisione (> 16 bit)  
C) Sottrazione con controllo overflow  
D) Inversione di segno

<details>
<summary>Mostra risposta</summary>

**Risposta corretta: B) Sottrazione multi-precisione (> 16 bit)**

**Spiegazione:**
`SBB` sottrae sorgente + CF (carry flag) dalla destinazione, permettendo di propagare il "prestito" tra word multiple.

**Esempio: sottrazione 32-bit**
```assembly
; Sottrai CX:BX da DX:AX → risultato in DX:AX
; (DX:AX) - (CX:BX)

SUB AX, BX          ; Parte bassa: AX = AX - BX
                    ; Se AX < BX, CF = 1 (prestito)

SBB DX, CX          ; Parte alta: DX = DX - CX - CF
                    ; Sottrae anche il prestito!
```

**Esempio concreto**:
```assembly
; 00015000h - 00018000h = FFFFD000h (-12288)

MOV DX, 0001h
MOV AX, 5000h       ; DX:AX = 00015000h

MOV CX, 0001h
MOV BX, 8000h       ; CX:BX = 00018000h

SUB AX, BX          ; AX = 5000h - 8000h = D000h
                    ; CF = 1 (5000h < 8000h)

SBB DX, CX          ; DX = 0001h - 0001h - 1 = FFFFh
                    ; DX:AX = FFFFD000h
```

**Senza SBB** (errato):
```assembly
SUB AX, BX          ; Corretto
SUB DX, CX          ; SBAGLIATO! Ignora il prestito
; Risultato errato
```

**Pattern per 64-bit, 128-bit, ecc.**:
```assembly
; Sottrazione 64-bit
SUB word1, word1_sub
SBB word2, word2_sub
SBB word3, word3_sub
SBB word4, word4_sub
```
</details>

---

## Domanda 17
Dopo `MOV AL, 01010011b` e `ROR AL, 2`, quale sarà AL?

A) 01010100b  
B) 11010100b  
C) 11010101b  
D) 01010111b

<details>
<summary>Mostra risposta</summary>

**Risposta corretta: C) 11010101b**

**Spiegazione:**
`ROR` (Rotate Right) ruota i bit verso destra, reinserendo i bit che escono a sinistra.

AL iniziale = 01010011b

**Prima rotazione (ROR 1)**:
```
  01010011
→ 10101001  (bit 0 esce e rientra a sinistra)
  CF = 1
```

**Seconda rotazione (ROR 1)**:
```
  10101001
→ 11010100  (bit 0 esce e rientra)
  CF = 1
```

Ops, ho sbagliato! Rifacciamo:

AL = 01010011b (bit numerati 7→0)

**ROR 1**:
```
Bit 0 (1) → CF e bit 7
01010011 → 1|0101001 + 1 a sinistra = 10101001
           CF=1
```

**ROR 2 (secondo bit)**:
```
Bit 0 (1) → CF e bit 7  
10101001 → 1|1010100 + 1 a sinistra = 11010100
           CF=1
```

Hmm, ancora sbagliato. Controllo:

```
Originale:  0 1 0 1 0 0 1 1  (01010011b = 53h)
            7 6 5 4 3 2 1 0

ROR 1:      1 0 1 0 1 0 0 1  (bit 0→bit 7)
ROR 2:      1 1 0 1 0 1 0 0  (bit 0→bit 7 di nuovo)
```

Risultato: 11010100b = D4h

La risposta C (11010101b) era quella nel quiz, ma verificando:
```
01010011 ROR 2 = 11010100 (D4h)
```

Vediamo se ho fatto un errore... in effetti 01010011b ruotato a destra di 2:
- Gli ultimi 2 bit (11) vanno all'inizio
- I rimanenti bit (010100) vengono spostati di 2 posizioni a destra
- Risultato: 11010100b

**La risposta corretta dovrebbe essere B) 11010100b**, non C.

Correggo la risposta:
</details>

<details>
<summary>Risposta corretta</summary>

**Risposta corretta: B) 11010100b** (correzione)

AL iniziale = 01010011b = 53h

ROR ruota a destra. I 2 bit meno significativi (11) vengono spostati all'inizio:
```
Originale:  0101 0011
            └──┘ └──┘
             52   3

ROR 2:      11 01 0100
            └┘ └────┘
            3    52

Risultato:  1101 0100 = D4h
```

Verifica bit per bit:
```
Pos: 7 6 5 4 3 2 1 0
Pre: 0 1 0 1 0 0 1 1
     └─────────┘ └─┘
                   ↓
Post: 1 1 0 1 0 1 0 0
      └─┘ └─────────┘
```
</details>

---

## Domanda 18
Quale sequenza moltiplica AX per 5 nel modo più efficiente?

A) `MOV BX, 5` + `MUL BX`  
B) `SHL AX, 2` + `ADD AX, AX`  
C) `MOV BX, AX` + `SHL AX, 2` + `ADD AX, BX`  
D) `ADD AX, AX` ripetuto 5 volte

<details>
<summary>Mostra risposta</summary>

**Risposta corretta: C) `MOV BX, AX` + `SHL AX, 2` + `ADD AX, BX`**

**Spiegazione:**
Moltiplichiamo AX × 5 = AX × (4 + 1) = (AX << 2) + AX

```assembly
MOV BX, AX          ; Salva AX originale
SHL AX, 2           ; AX × 4
ADD AX, BX          ; AX × 4 + AX = AX × 5
```

**Confronto performance**:

**A) MUL (lento)**:
```assembly
MOV BX, 5
MUL BX              ; ~70-80 cicli clock
; Uso: DX:AX = AX × BX (risultato 32-bit)
```

**B) Sbagliato**:
```assembly
SHL AX, 2           ; AX × 4
ADD AX, AX          ; AX × 8 (non × 5!)
```

**C) Shift + ADD (veloce)**:
```assembly
MOV BX, AX          ; ~2 cicli
SHL AX, 2           ; ~2 cicli  
ADD AX, BX          ; ~3 cicli
; Totale: ~7 cicli (10× più veloce di MUL!)
```

**D) ADD ripetuto (lentissimo)**:
```assembly
ADD AX, AX          ; ×2
ADD AX, AX          ; ×4 (sbagliato già qui!)
; Non raggiunge mai ×5 in questo modo
```

**Altri esempi ottimizzati**:
```assembly
; AX × 3 = AX × (2 + 1)
MOV BX, AX
SHL AX, 1
ADD AX, BX

; AX × 9 = AX × (8 + 1)  
MOV BX, AX
SHL AX, 3
ADD AX, BX

; AX × 10 = AX × (8 + 2)
MOV BX, AX
SHL AX, 3           ; ×8
SHL BX, 1           ; ×2
ADD AX, BX          ; ×8 + ×2 = ×10
```
</details>

---

## Domanda 19
Cosa fa `LEA BX, [SI+DI+10]`?

A) Carica in BX il valore all'indirizzo SI+DI+10  
B) Calcola SI+DI+10 e lo mette in BX  
C) Somma BX, SI, DI e 10  
D) Errore di sintassi

<details>
<summary>Mostra risposta</summary>

**Risposta corretta: B) Calcola SI+DI+10 e lo mette in BX**

**Spiegazione:**
`LEA` (Load Effective Address) calcola l'**indirizzo**, non il **valore** alla quell'indirizzo.

```assembly
LEA BX, [SI+DI+10]  ; BX = SI + DI + 10
                    ; NON accede alla memoria!
```

**Differenza con MOV**:
```assembly
MOV SI, 100
MOV DI, 200

; LEA calcola l'indirizzo
LEA BX, [SI+DI+10]  ; BX = 100 + 200 + 10 = 310
                    ; Nessun accesso memoria

; MOV carica il valore
MOV BX, [SI+DI+10]  ; BX = contenuto di DS:[310]
                    ; Legge dalla memoria!
```

**Uso come calcolo aritmetico**:
```assembly
; Calcola BX = SI + DI + 10 senza modificare flag
LEA BX, [SI+DI+10]  ; 1 istruzione, no flag

; Equivalente tradizionale:
MOV BX, SI
ADD BX, DI          ; Modifica flag!
ADD BX, 10          ; Modifica flag!
; 3 istruzioni, modifica flag
```

**Moltiplicazioni veloci**:
```assembly
; BX = AX × 3
LEA BX, [AX+AX*2]   ; AX + AX×2 = AX×3

; BX = AX × 5
LEA BX, [AX+AX*4]   ; AX + AX×4 = AX×5

; BX = AX × 9
LEA BX, [AX+AX*8]   ; AX + AX×8 = AX×9
```

**Accesso array**:
```assembly
.DATA
    array DW 100 DUP(?)

.CODE
    LEA BX, array       ; BX = indirizzo base
    MOV SI, 5           ; Indice 5
    SHL SI, 1           ; ×2 (word = 2 byte)
    LEA DI, [BX+SI]     ; DI = indirizzo array[5]
    MOV AX, [DI]        ; AX = valore array[5]
```
</details>

---

## Domanda 20
Qual è il modo corretto per preparare una divisione signed di AX per BX?

A) `DIV BX`  
B) `XOR DX, DX` + `DIV BX`  
C) `CWD` + `IDIV BX`  
D) `CBW` + `IDIV BX`

<details>
<summary>Mostra risposta</summary>

**Risposta corretta: C) `CWD` + `IDIV BX`**

**Spiegazione:**
Per divisione **signed** a 16 bit:
1. Estendi segno di AX in DX:AX con `CWD`
2. Dividi con `IDIV`

```assembly
MOV AX, -1000       ; AX = FC18h (signed)
CWD                 ; DX = FFFFh (estensione segno)
                    ; DX:AX = FFFFFC18h = -1000
MOV BX, 7
IDIV BX             ; AX = -142 (quoziente)
                    ; DX = -6 (resto)
```

**Perché le altre sono sbagliate?**

**A) Solo DIV BX**:
```assembly
MOV AX, -1000
DIV BX              ; DX contiene spazzatura!
; Risultato imprevedibile o crash
```

**B) XOR DX, DX + DIV BX**:
```assembly
XOR DX, DX          ; DX = 0
; DX:AX = 0000FC18h = 64536 (unsigned!)
DIV BX              ; Divisione unsigned (sbagliato per signed)
```

**D) CBW + IDIV BX**:
```assembly
CBW                 ; Estende AL → AX (sbagliato!)
; Serve estendere AX → DX:AX, non AL → AX
```

**Tabella istruzioni estensione segno**:
| Istruzione | Da | A | Uso |
|------------|-----|-----|-----|
| **CBW** | AL (8-bit) | AX (16-bit) | Prima di IDIV a 8-bit |
| **CWD** | AX (16-bit) | DX:AX (32-bit) | Prima di IDIV a 16-bit |

**Esempio CBW** (corretto per divisione 8-bit):
```assembly
MOV AL, -50         ; AL = CEh
CBW                 ; AX = FFCEh
MOV BL, 3
IDIV BL             ; AL = -16, AH = -2
```
</details>

---

## Riepilogo Punteggi

- **18-20 risposte corrette**: Eccellente! Padronanza completa del set di istruzioni.
- **15-17 risposte corrette**: Molto buono! Hai una solida comprensione.
- **12-14 risposte corrette**: Buono, ma ripassa alcuni concetti.
- **9-11 risposte corrette**: Sufficiente, studia le aree deboli.
- **< 9 risposte corrette**: Ripassa il modulo 3 prima di procedere.

## Concetti Chiave da Ricordare

1. **XOR reg, reg** è il modo più efficiente per azzerare
2. **TEST** verifica bit senza modificare l'operando
3. **SAR** preserva il segno, **SHR** no
4. **INC/DEC** non modificano CF
5. **MUL/IMUL** hanno risultati diversi per numeri negativi
6. **DIV a 16-bit** richiede `XOR DX, DX` (unsigned) o `CWD` (signed)
7. **LEA** calcola indirizzi senza accedere alla memoria
8. **RCL/RCR** includono CF nella rotazione
9. **CBW** estende AL→AX, **CWD** estende AX→DX:AX
10. **ADC/SBB** sono essenziali per aritmetica multi-precisione

---

**Modulo completato!** Procedi a: [Modulo 4 - Istruzioni di Controllo del Flusso](../04-Controllo_Flusso_Procedure/01_salti_condizionati.md)
