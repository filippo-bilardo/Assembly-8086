# Quiz Modulo 7 - Programmazione Avanzata

## Domande

### 1. Quale convenzione di chiamata standard per C (DOS/16-bit)?
a) Pascal  
b) cdecl  
c) fastcall  
d) stdcall  

### 2. In cdecl, chi pulisce lo stack dopo chiamata funzione?
a) Callee (funzione chiamata)  
b) Caller (chiamante)  
c) Compilatore automaticamente  
d) Nessuno (stack non pulito)  

### 3. Come si chiama funzione C `sum` in Assembly (cdecl)?
a) sum  
b) _sum  
c) SUM  
d) @sum  

### 4. Dove va il valore di ritorno 16-bit in cdecl?
a) Stack  
b) AX  
c) BX  
d) Memoria globale  

### 5. Quale registri DEVE salvare la funzione Assembly chiamata da C (cdecl)?
a) AX, CX, DX  
b) BX, SI, DI, BP  
c) Tutti i registri  
d) Nessuno  

### 6. Qual è l'istruzione PIÙ veloce per azzerare AX?
a) MOV AX, 0  
b) SUB AX, AX  
c) XOR AX, AX  
d) AND AX, 0  

### 7. Quale istruzione sostituisce efficacemente `MUL AX, 8`?
a) ADD AX, 8  
b) SHL AX, 3  
c) SAL AX, 8  
d) ROL AX, 3  

### 8. Cos'è il "loop unrolling"?
a) Rimuovere loop  
b) Espandere iterazioni loop per ridurre overhead  
c) Usare LOOP invece JMP  
d) Invertire direzione loop  

### 9. Quale più efficiente per azzerare 100 byte memoria?
a) Loop con MOV BYTE PTR [BX], 0  
b) REP STOSB  
c) XOR ogni byte manualmente  
d) CALL memset di C  

### 10. LEA può sostituire quale operazione?
a) Solo caricamento indirizzi  
b) Solo moltiplicazione  
c) Addizione e moltiplicazione (limitata)  
d) Tutte le operazioni aritmetiche  

### 11. Quale tecnica ottimizzazione sposta calcoli invarianti fuori loop?
a) Loop unrolling  
b) Strength reduction  
c) Hoisting  
d) Inlining  

### 12. "Strength reduction" significa?
a) Ridurre dimensione codice  
b) Sostituire operazioni costose con equivalenti veloci  
c) Rimuovere istruzioni inutili  
d) Comprimere dati  

### 13. Quanti bit ha ogni registro FPU 8087?
a) 32 bit  
b) 64 bit  
c) 80 bit  
d) 128 bit  

### 14. Come è organizzato il registro FPU 8087?
a) Generale purpose (come CPU)  
b) Stack  
c) Array  
d) Coda  

### 15. Quale istruzione carica π (pi greco) in ST(0)?
a) FLD PI  
b) FLDPI  
c) FLDP  
d) FLDCONST 3.14159  

### 16. Dopo `FLD a` e `FLD b`, quale istruzione calcola a + b?
a) FADD  
b) FADDP ST(1), ST(0)  
c) FADD ST(0), ST(1)  
d) Tutte le precedenti (equivalenti)  

### 17. Quale istruzione calcola radice quadrata in 8087?
a) FSQR  
b) FSQRT  
c) FROOT  
d) Non esiste (calcolo manuale)  

### 18. Quale istruzione confronta ST(0) con valore e fa POP?
a) FCMP  
b) FCOMP  
c) FCMPP  
d) FTEST  

### 19. In fixed-point 16.16, come si rappresenta 1.0?
a) 1  
b) 16  
c) 256  
d) 65536  

### 20. Quale svantaggio principale virgola fissa vs floating-point?
a) Più lenta  
b) Range e precisione limitati  
c) Più complessa  
d) Non supportata da CPU  

---

## Soluzioni

### 1. Risposta: **b) cdecl**
**Spiegazione**: **cdecl** (C declaration) è la convenzione standard per C in DOS e Windows 16-bit. Caratteristiche:
- Parametri su stack (destra → sinistra)
- Caller pulisce stack
- AX = valore ritorno (DX:AX per 32-bit)

**Pascal** usa ordine inverso parametri e callee pulisce.  
**fastcall** usa registri (non standard 16-bit).  
**stdcall** è Win32 (32-bit).

---

### 2. Risposta: **b) Caller (chiamante)**
**Spiegazione**: In **cdecl**, il **caller pulisce** lo stack dopo chiamata:
```assembly
; Caller
    PUSH param2
    PUSH param1
    CALL func
    ADD SP, 4           ; Caller pulisce (cdecl)
```

**Pascal/stdcall**: callee pulisce (`RET n`).

Vantaggio cdecl: supporta funzioni variadic (`printf`, `scanf`).

---

### 3. Risposta: **b) _sum**
**Spiegazione**: Convenzione cdecl aggiunge **underscore** (`_`) ai nomi funzioni C:
```assembly
; Assembly
PUBLIC _sum             ; int sum(...) in C

_sum PROC
    ; ...
    RET
_sum ENDP
```

**C++** usa name mangling diverso (`?sum@@...`).

---

### 4. Risposta: **b) AX**
**Spiegazione**: Valori ritorno cdecl:
- **16-bit**: AX
- **32-bit**: DX:AX (DX = high, AX = low)
- **Puntatori**: AX (offset) o DX:AX (far pointer)

```assembly
_myfunc PROC
    MOV AX, 42          ; Ritorna 42
    RET
_myfunc ENDP
```

---

### 5. Risposta: **b) BX, SI, DI, BP**
**Spiegazione**: Registri cdecl:
- **Volatili** (caller-save): **AX, CX, DX** - funzione può modificare liberamente
- **Non-volatili** (callee-save): **BX, SI, DI, BP** - funzione DEVE salvare/ripristinare

```assembly
✓ Corretto:
_func PROC
    PUSH BX
    PUSH SI
    ; ... usa BX, SI ...
    POP SI
    POP BX
    RET
_func ENDP
```

---

### 6. Risposta: **c) XOR AX, AX**
**Spiegazione**: Confronto prestazioni (8086):
- `MOV AX, 0`: 4 cicli, 3 byte
- `SUB AX, AX`: 3 cicli, 2 byte
- `XOR AX, AX`: **3 cicli, 2 byte** ✓ (stesso SUB, ma preferito)
- `AND AX, 0`: 4 cicli, 3 byte

**XOR** è standard per azzeramento (riconosciuto da CPU moderne per ottimizzazione).

---

### 7. Risposta: **b) SHL AX, 3**
**Spiegazione**: Moltiplicazione per potenze di 2 → shift:
- `× 2` = `SHL AX, 1`
- `× 4` = `SHL AX, 2`
- `× 8` = `SHL AX, 3` ✓
- `× 16` = `SHL AX, 4`

**MUL** impiega ~13-21 cicli (8086).  
**SHL** impiega ~2 cicli per shift.

`SAL` (Shift Arithmetic Left) = `SHL` (stesso opcode).

---

### 8. Risposta: **b) Espandere iterazioni loop per ridurre overhead**
**Spiegazione**: **Loop unrolling** replica corpo loop per ridurre overhead `LOOP`/`JMP`:

```assembly
✗ Originale (4 iterazioni):
    MOV CX, 4
loop1:
    MOV [BX], 0
    INC BX
    LOOP loop1          ; Overhead: DEC CX, JNZ

✓ Unrolled:
    MOV [BX], 0         ; No loop!
    MOV [BX+2], 0
    MOV [BX+4], 0
    MOV [BX+6], 0
```

Guadagno: ~25-40% più veloce.

---

### 9. Risposta: **b) REP STOSB**
**Spiegazione**: Confronto:

| Metodo | Velocità Relativa |
|--------|-------------------|
| Loop manuale | 1× (base) |
| **REP STOSB** | **~2-3×** ✓ |
| CALL memset (C) | ~1.5× (overhead chiamata) |

```assembly
✓ Ottimale:
    MOV AL, 0           ; Valore
    MOV CX, 100         ; Count
    LEA DI, buffer
    CLD
    REP STOSB           ; Veloce!
```

**REP STOSW** ancora più veloce per word (200 byte).

---

### 10. Risposta: **c) Addizione e moltiplicazione (limitata)**
**Spiegazione**: **LEA** (Load Effective Address) calcola indirizzi, ma può fare aritmetica:

```assembly
LEA BX, [SI+DI]         ; BX = SI + DI
LEA AX, [BX+SI+10]      ; AX = BX + SI + 10
LEA AX, [BX+BX*2]       ; AX = BX × 3
LEA AX, [BX+BX*4]       ; AX = BX × 5
LEA AX, [BX+BX*8]       ; AX = BX × 9
```

**Limitazioni**: solo scale 1, 2, 4, 8; non aggiorna flags.

---

### 11. Risposta: **c) Hoisting**
**Spiegazione**: **Hoisting** sposta calcoli **invarianti** fuori loop:

```assembly
✗ Invariante in loop:
loop1:
    MOV AX, base
    ADD AX, offset      ; Invariante (non cambia)!
    MOV [BX], AX
    INC BX
    LOOP loop1

✓ Hoisting:
    MOV AX, base
    ADD AX, offset      ; Calcolato 1 volta
loop2:
    MOV [BX], AX
    INC BX
    LOOP loop2
```

---

### 12. Risposta: **b) Sostituire operazioni costose con equivalenti veloci**
**Spiegazione**: **Strength reduction** sostituisce operazioni lente:

```assembly
✗ MUL in loop (lento):
    XOR SI, SI
loop1:
    MOV AX, SI
    MOV BX, 5
    MUL BX              ; Costoso!
    ; ... usa AX ...
    INC SI
    LOOP loop1

✓ Addizione (veloce):
    XOR AX, AX
loop2:
    ; AX già = SI × 5
    ADD AX, 5           ; Incremento
    LOOP loop2
```

Altri esempi: `÷ 2` → `SAR`, `× 10` → `SHL+ADD`.

---

### 13. Risposta: **c) 80 bit**
**Spiegazione**: Registri FPU 8087:
- **8 registri**: ST(0) - ST(7)
- **80 bit** ciascuno (10 byte)
  - 1 bit: segno
  - 15 bit: esponente
  - 64 bit: mantissa

Precisione estesa: ~19 cifre decimali, range ±1.2E4932.

---

### 14. Risposta: **b) Stack**
**Spiegazione**: FPU 8087 usa **stack** (LIFO):
- **ST(0)**: top of stack (TOS)
- **ST(1)** - **ST(7)**: sotto ST(0)

```assembly
FLD a               ; ST(0) = a
FLD b               ; ST(0) = b, ST(1) = a
FADDP               ; ST(0) = a + b, POP
```

Non accesso casuale come registri CPU.

---

### 15. Risposta: **b) FLDPI**
**Spiegazione**: Costanti FPU:
- **FLDPI**: π (3.14159265358979...)
- **FLD1**: 1.0
- **FLDZ**: 0.0
- **FLDL2E**: log₂(e)
- **FLDL2T**: log₂(10)
- **FLDLG2**: log₁₀(2)
- **FLDLN2**: ln(2)

```assembly
FLDPI               ; ST(0) = π
FMUL radius         ; ST(0) = π × radius
```

---

### 16. Risposta: **d) Tutte le precedenti (equivalenti)**
**Spiegazione**: Modi calcolare a + b:

```assembly
; Metodo 1
FLD a
FADD b              ; ST(0) = a + b

; Metodo 2
FLD a
FLD b
FADDP ST(1), ST(0)  ; ST(1) += ST(0), POP
; ST(0) = a + b

; Metodo 3 (esplicito)
FLD a
FLD b
FADD ST(0), ST(1)   ; ST(0) += ST(1)
FSTP ST(1)          ; POP ST(1)
```

Tutti producono stesso risultato.

---

### 17. Risposta: **b) FSQRT**
**Spiegazione**: `FSQRT` calcola √ST(0):

```assembly
FLD x               ; ST(0) = x
FSQRT               ; ST(0) = √x
```

Altre funzioni matematiche:
- `FSIN`: seno
- `FCOS`: coseno
- `FPTAN`: tangente
- `FPATAN`: arcotangente
- `F2XM1`: 2^x - 1

---

### 18. Risposta: **b) FCOMP**
**Spiegazione**: Confronto FPU:
- **FCOM**: confronta ST(0), mantiene stack
- **FCOMP**: confronta ST(0), **POP** ✓
- **FCOMPP**: confronta ST(0) vs ST(1), POP 2×

```assembly
FLD a
FCOMP b             ; Confronta a vs b, POP
FSTSW AX            ; Status → AX
SAHF                ; AX → CPU flags
JA greater          ; a > b
```

---

### 19. Risposta: **d) 65536**
**Spiegazione**: Fixed-point **16.16**:
- 16 bit parte intera
- 16 bit parte frazionaria

**1.0** = 1 << 16 = **65536**

Altri esempi:
- 2.0 = 131072 (2 × 65536)
- 0.5 = 32768 (0.5 × 65536)
- 1.5 = 98304 (1.5 × 65536)

Formula: `valore_fixed = valore_float × 65536`

---

### 20. Risposta: **b) Range e precisione limitati**
**Spiegazione**: Fixed-point 16.16:

| Proprietà | Fixed 16.16 | Float 32-bit |
|-----------|-------------|--------------|
| Range | ±32K | ±3.4E38 |
| Precisione | ~0.000015 (1/65536) | 7 cifre |
| Velocità | Veloce | Lento (senza FPU) |

**Vantaggi fixed**: veloce, deterministico.  
**Svantaggi**: range/precisione limitati, overflow facile.

---

## Riepilogo Punteggi

- **18-20 corrette**: Eccellente! Padronanza interfacciamento, ottimizzazione e FPU
- **15-17 corrette**: Ottimo! Buona comprensione, rivedere dettagli FPU
- **12-14 corrette**: Buono. Approfondire tecniche ottimizzazione
- **9-11 corrette**: Sufficiente. Ripassare cdecl e istruzioni FPU
- **< 9 corrette**: Insufficiente. Studiare approfonditamente tutto il modulo

## Concetti Chiave da Ripassare

### Se hai sbagliato domande 1-5:
- Rileggi [Interfacciamento Assembly-C](modulo7_01_interfacciamento_c.md)
- Studia convenzioni cdecl vs Pascal
- Pratica chiamate funzioni C da Assembly
- Esercitati con passaggio parametri su stack

### Se hai sbagliato domande 6-12:
- Rileggi [Ottimizzazione](modulo7_02_ottimizzazione.md)
- Confronta istruzioni lente vs veloci
- Studia loop unrolling, hoisting, strength reduction
- Benchmark codice ottimizzato vs non ottimizzato

### Se hai sbagliato domande 13-20:
- Rileggi [Coprocessore 8087](modulo7_03_coprocessore_8087.md)
- Studia stack FPU e istruzioni base
- Pratica con calcoli floating-point
- Confronta floating-point vs fixed-point

## Esercizi Consigliati

1. **Interfacciamento**: Scrivi libreria Assembly con 5 funzioni matematiche, chiama da C
2. **Ottimizzazione**: Implementa 3 versioni `strlen` (base, ottimizzata, SCASB), benchmark
3. **Loop unrolling**: Ottimizza loop copia array 1000 elementi (unroll 4×, 8×)
4. **FPU**: Calcola area cerchio (π × r²) con 8087
5. **Fixed-point**: Implementa moltiplicazione/divisione 16.16, confronta velocità con FPU

---

**Congratulazioni!** Hai completato il **Modulo 7**!

**Prossimo modulo**: [Modulo 8 - Progetti Pratici](../README.md#modulo-8)
