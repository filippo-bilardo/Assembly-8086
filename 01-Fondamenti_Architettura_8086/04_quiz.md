# Domande di Autovalutazione - Modulo 1

## Fondamenti dell'Architettura 8086

### Domanda 1: Caratteristiche dell'8086

**Quale delle seguenti affermazioni sull'Intel 8086 è CORRETTA?**

A) È un processore a 32 bit con bus dati a 16 bit  
B) Può indirizzare fino a 64 KB di memoria  
C) Ha un bus indirizzi a 20 bit e può indirizzare fino a 1 MB di memoria  
D) Non supporta la pipeline di istruzioni  

<details>
<summary>Visualizza risposta</summary>

**Risposta corretta: C**

**Spiegazione:**
- L'8086 è un processore a **16 bit** (non 32 bit)
- Ha un **bus indirizzi a 20 bit**, permettendo di indirizzare 2²⁰ = 1.048.576 byte = 1 MB
- Supporta una **pipeline a due stadi** (BIU e EU lavorano in parallelo)
- Un singolo segmento può essere di massimo 64 KB, ma la memoria totale indirizzabile è 1 MB

</details>

---

### Domanda 2: Bus Interface Unit (BIU)

**Quale delle seguenti NON è una funzione della BIU?**

A) Prelievo delle istruzioni dalla memoria  
B) Esecuzione delle operazioni aritmetiche  
C) Gestione della coda di prefetch  
D) Calcolo degli indirizzi fisici  

<details>
<summary>Visualizza risposta</summary>

**Risposta corretta: B**

**Spiegazione:**
La BIU (Bus Interface Unit) gestisce:
- Prelievo (fetch) delle istruzioni dalla memoria
- Coda di prefetch (6 byte nell'8086)
- Calcolo degli indirizzi fisici tramite segmento:offset

L'**esecuzione delle operazioni aritmetiche** è compito dell'**EU (Execution Unit)**, che contiene l'ALU.

</details>

---

### Domanda 3: Calcolo Indirizzi Fisici

**Qual è l'indirizzo fisico corrispondente a 2000h:1234h?**

A) 3234h  
B) 21234h  
C) 20001234h  
D) 32340h  

<details>
<summary>Visualizza risposta</summary>

**Risposta corretta: B**

**Spiegazione:**

Formula: `Indirizzo Fisico = (Segmento × 16) + Offset`

```
Segmento = 2000h
Offset = 1234h

Calcolo:
2000h × 10h = 20000h
20000h + 1234h = 21234h
```

Metodo alternativo (shift):
```
2000h << 4 = 20000h
20000h + 1234h = 21234h
```

</details>

---

### Domanda 4: Pipeline e Prestazioni

**Qual è il principale svantaggio della pipeline nell'8086?**

A) Aumenta il consumo di energia  
B) Riduce la velocità di esecuzione  
C) Causa penalità in caso di salti (branch)  
D) Richiede più transistor  

<details>
<summary>Visualizza risposta</summary>

**Risposta corretta: C**

**Spiegazione:**

Quando viene eseguita un'istruzione di salto (JMP, CALL, Jcc), la coda di prefetch deve essere **svuotata** perché contiene istruzioni che non verranno eseguite. Questo causa una **penalità di prestazioni** chiamata "branch penalty".

Esempio:
```assembly
    MOV AX, 1       ; Eseguita
    JMP skip        ; Salto! Coda svuotata
    MOV BX, 2       ; Nella coda ma non eseguita
    MOV CX, 3       ; Nella coda ma non eseguita
skip: MOV DX, 4     ; Deve essere fetchata di nuovo
```

La pipeline **aumenta** le prestazioni del 30-40% in condizioni normali, ma i salti ne riducono l'efficacia.

</details>

---

### Domanda 5: Registri Generali

**Quanti registri generali a 16 bit possiede l'8086?**

A) 2 (AX, BX)  
B) 4 (AX, BX, CX, DX)  
C) 8 (include anche SI, DI, SP, BP)  
D) 14 (tutti i registri)  

<details>
<summary>Visualizza risposta</summary>

**Risposta corretta: B**

**Spiegazione:**

I **registri generali** (general purpose) dell'8086 sono **4**:
- **AX** (Accumulator)
- **BX** (Base)
- **CX** (Count)
- **DX** (Data)

Questi possono essere usati per operazioni aritmetiche/logiche generali e possono essere suddivisi in registri a 8 bit.

Gli altri registri hanno funzioni più specializzate:
- SI, DI, SP, BP: registri puntatori/indice
- CS, DS, SS, ES: registri di segmento
- IP, FLAGS: registri speciali

</details>

---

### Domanda 6: Registro AX

**Quale delle seguenti NON è un uso tipico del registro AX?**

A) Operazioni di moltiplicazione e divisione  
B) Operazioni di I/O (IN, OUT)  
C) Puntatore al top dello stack  
D) Accumulo di risultati aritmetici  

<details>
<summary>Visualizza risposta</summary>

**Risposta corretta: C**

**Spiegazione:**

Il **puntatore al top dello stack** è il registro **SP (Stack Pointer)**, non AX.

AX è usato per:
- Operazioni aritmetiche (accumulator)
- Moltiplicazione: `MUL` mette il risultato in AX o DX:AX
- Divisione: `DIV` usa DX:AX come dividendo, risultato in AX
- I/O: `IN AL, porta` e `OUT porta, AL`
- Interruzioni DOS/BIOS

</details>

---

### Domanda 7: Registro CX

**Per quale scopo è principalmente utilizzato il registro CX?**

A) Indirizzamento base della memoria  
B) Contatore per loop e operazioni ripetute  
C) Operazioni di I/O su porte  
D) Puntatore alle istruzioni  

<details>
<summary>Visualizza risposta</summary>

**Risposta corretta: B**

**Spiegazione:**

CX (Count Register) è il registro **contatore**:
- Istruzione `LOOP`: decrementa CX e salta se CX ≠ 0
- Prefisso `REP`: ripete l'istruzione CX volte
- Shift/rotate multipli: CL specifica il numero di shift

Esempi:
```assembly
MOV CX, 10
ciclo:
    ; ... codice ...
    LOOP ciclo      ; Ripeti 10 volte

MOV CX, 100
REP MOVSB           ; Copia 100 byte

MOV CL, 4
SHL AX, CL          ; Shift di 4 posizioni
```

</details>

---

### Domanda 8: Registri SI e DI

**Quale affermazione sui registri SI e DI è CORRETTA?**

A) Possono essere suddivisi in registri a 8 bit  
B) Sono usati principalmente nelle operazioni su stringhe  
C) SI punta sempre alla destinazione, DI alla sorgente  
D) Non possono essere usati per indirizzamento indiretto  

<details>
<summary>Visualizza risposta</summary>

**Risposta corretta: B**

**Spiegazione:**

- SI (Source Index) e DI (Destination Index) sono registri a 16 bit **non suddivisibili**
- Sono usati principalmente nelle **operazioni su stringhe**:
  - **SI** punta alla **sorgente** (DS:SI)
  - **DI** punta alla **destinazione** (ES:DI)
- Possono essere usati per **indirizzamento indiretto**: `MOV AL, [SI]`

Esempio:
```assembly
LEA SI, sorgente
LEA DI, destinazione
MOV CX, 10
REP MOVSB           ; Copia 10 byte da DS:SI a ES:DI
```

</details>

---

### Domanda 9: Registro BP

**Qual è la principale differenza tra BP e gli altri registri puntatori?**

A) BP è a 32 bit  
B) BP usa il segmento SS per default  
C) BP non può essere usato per indirizzamento  
D) BP è solo per operazioni aritmetiche  

<details>
<summary>Visualizza risposta</summary>

**Risposta corretta: B**

**Spiegazione:**

BP (Base Pointer) usa il segmento **SS (Stack Segment)** per default, mentre BX, SI, DI usano **DS (Data Segment)**.

Questo rende BP ideale per accedere a **parametri e variabili locali nello stack**:

```assembly
procedura PROC
    PUSH BP
    MOV BP, SP          ; BP punta al frame corrente
    MOV AX, [BP+4]      ; Accede a parametro (SS:BP+4)
    MOV [BP-2], BX      ; Accede a variabile locale
    POP BP
    RET
procedura ENDP
```

</details>

---

### Domanda 10: Flag Register

**Quale flag indica che il risultato di un'operazione è zero?**

A) CF (Carry Flag)  
B) SF (Sign Flag)  
C) ZF (Zero Flag)  
D) OF (Overflow Flag)  

<details>
<summary>Visualizza risposta</summary>

**Risposta corretta: C**

**Spiegazione:**

Il **ZF (Zero Flag)** è impostato a 1 quando il risultato di un'operazione è **zero**:

```assembly
MOV AX, 5
SUB AX, 5       ; AX = 0, ZF = 1

CMP BX, CX      ; Sottrazione implicita
JE uguale       ; Salta se ZF = 1 (BX = CX)
```

Gli altri flag:
- **CF**: riporto/prestito
- **SF**: segno (negativo se 1)
- **OF**: overflow aritmetico con segno

</details>

---

### Domanda 11: Carry Flag (CF)

**In quale situazione viene impostato il Carry Flag?**

A) Quando il risultato è negativo  
B) Quando c'è overflow in operazioni con segno  
C) Quando c'è riporto dal bit più significativo  
D) Quando il numero di bit '1' è pari  

<details>
<summary>Visualizza risposta</summary>

**Risposta corretta: C**

**Spiegazione:**

Il **CF (Carry Flag)** viene impostato quando c'è un **riporto** (carry) o **prestito** (borrow) dal bit più significativo:

```assembly
; Addizione con carry
MOV AL, FFh
ADD AL, 1       ; AL = 00h, CF = 1 (riporto)

; Sottrazione con borrow
MOV AL, 0
SUB AL, 1       ; AL = FFh, CF = 1 (prestito)
```

Usato per aritmetica multi-precisione:
```assembly
; Addizione a 32 bit: DX:AX + CX:BX
ADD AX, BX      ; Parte bassa
ADC DX, CX      ; Parte alta + carry
```

</details>

---

### Domanda 12: Overflow Flag (OF)

**Qual è la differenza tra CF e OF?**

A) CF è per operazioni a 8 bit, OF per 16 bit  
B) CF indica riporto senza segno, OF indica overflow con segno  
C) Non c'è differenza, sono sinonimi  
D) OF è usato solo per moltiplicazioni  

<details>
<summary>Visualizza risposta</summary>

**Risposta corretta: B**

**Spiegazione:**

- **CF (Carry Flag)**: riporto in operazioni **senza segno** (unsigned)
- **OF (Overflow Flag)**: overflow in operazioni **con segno** (signed)

Esempio:
```assembly
MOV AL, 7Fh     ; 127 (massimo positivo in signed 8-bit)
ADD AL, 1       ; AL = 80h

Interpretazione unsigned: 127 + 1 = 128 ✓ (CF = 0)
Interpretazione signed: 127 + 1 = -128 ✗ (OF = 1)
```

Quando controllare:
- **JC/JNC**: salta in base a CF (aritmetica unsigned)
- **JO/JNO**: salta in base a OF (aritmetica signed)

</details>

---

### Domanda 13: Direction Flag (DF)

**Cosa controlla il Direction Flag nelle operazioni su stringhe?**

A) La direzione del flusso di esecuzione del programma  
B) Se incrementare o decrementare SI e DI  
C) Se usare DS o ES come segmento  
D) Il numero di ripetizioni  

<details>
<summary>Visualizza risposta</summary>

**Risposta corretta: B**

**Spiegazione:**

Il **DF (Direction Flag)** controlla se SI e DI vengono **incrementati** o **decrementati** nelle operazioni su stringhe:

- **DF = 0** (CLD): SI e DI vengono **incrementati** → copia in avanti
- **DF = 1** (STD): SI e DI vengono **decrementati** → copia all'indietro

```assembly
CLD                 ; DF = 0
MOV CX, 10
REP MOVSB           ; Copia in avanti (SI++, DI++)

STD                 ; DF = 1
MOV CX, 10
REP MOVSB           ; Copia all'indietro (SI--, DI--)
```

**Best practice**: impostare sempre DF esplicitamente prima di operazioni su stringhe!

</details>

---

### Domanda 14: Registri di Segmento

**Quale registro di segmento NON può essere modificato direttamente con MOV?**

A) DS  
B) ES  
C) CS  
D) SS  

<details>
<summary>Visualizza risposta</summary>

**Risposta corretta: C**

**Spiegazione:**

**CS (Code Segment)** non può essere modificato con `MOV CS, valore` perché cambierebbe il segmento del codice in esecuzione, causando comportamenti imprevedibili.

CS viene modificato indirettamente da:
- Salti FAR: `JMP FAR etichetta` cambia CS:IP
- Chiamate FAR: `CALL FAR procedura`
- Interruzioni: `INT numero`
- Ritorno da FAR: `RETF`

DS, ES, SS possono essere modificati con MOV:
```assembly
MOV AX, 2000h
MOV DS, AX          ; ✓ OK
MOV ES, AX          ; ✓ OK
MOV SS, AX          ; ✓ OK (ma attenzione!)

MOV CS, AX          ; ✗ ERRORE!
```

</details>

---

### Domanda 15: Segmentazione della Memoria

**Qual è la dimensione massima di un segmento nell'8086?**

A) 1 MB  
B) 256 KB  
C) 64 KB  
D) 32 KB  

<details>
<summary>Visualizza risposta</summary>

**Risposta corretta: C**

**Spiegazione:**

Un segmento ha dimensione massima di **64 KB (65.536 byte)** perché l'offset è un valore a **16 bit**:

```
Offset minimo: 0000h = 0
Offset massimo: FFFFh = 65.535
Dimensione segmento = 65.536 byte = 64 KB
```

Anche se la memoria totale indirizzabile è 1 MB (con bus indirizzi a 20 bit), ogni singolo segmento è limitato a 64 KB.

Per accedere a più di 64 KB di dati, è necessario cambiare il registro di segmento:
```assembly
; Accesso a memoria oltre 64 KB
MOV AX, 1000h
MOV DS, AX
; ... lavora con DS:offset ...
MOV AX, 2000h
MOV DS, AX
; ... nuovo segmento ...
```

</details>

---

### Domanda 16: Indirizzamento Immediato

**Quale delle seguenti istruzioni usa indirizzamento immediato?**

A) `MOV AX, BX`  
B) `MOV AX, [1234h]`  
C) `MOV AX, 1234h`  
D) `MOV AX, [BX]`  

<details>
<summary>Visualizza risposta</summary>

**Risposta corretta: C**

**Spiegazione:**

**Indirizzamento immediato**: l'operando è una **costante** nell'istruzione.

```assembly
MOV AX, 1234h       ; ✓ Immediato (valore 1234h)
MOV AL, 42          ; ✓ Immediato (valore 42)
ADD BX, 100         ; ✓ Immediato (valore 100)

MOV AX, BX          ; Registro
MOV AX, [1234h]     ; Diretto (indirizzo)
MOV AX, [BX]        ; Indiretto
```

Il valore immediato fa parte del **codice macchina** dell'istruzione e non richiede accessi alla memoria per recuperare l'operando.

</details>

---

### Domanda 17: Indirizzamento Indiretto

**Quali registri possono essere usati per indirizzamento indiretto?**

A) Solo AX, BX, CX, DX  
B) Solo BX, SI, DI, BP  
C) Tutti i registri a 16 bit  
D) Solo i registri di segmento  

<details>
<summary>Visualizza risposta</summary>

**Risposta corretta: B**

**Spiegazione:**

Solo **BX, SI, DI, BP** possono essere usati per indirizzamento indiretto:

```assembly
; VALIDO
MOV AL, [BX]        ; ✓
MOV AL, [SI]        ; ✓
MOV AL, [DI]        ; ✓
MOV AL, [BP]        ; ✓

; NON VALIDO
MOV AL, [AX]        ; ✗ ERRORE
MOV AL, [CX]        ; ✗ ERRORE
MOV AL, [DX]        ; ✗ ERRORE
MOV AL, [SP]        ; ✗ ERRORE
```

Segmenti di default:
- BX, SI, DI → DS
- BP → SS

</details>

---

### Domanda 18: Indirizzamento Basato Indicizzato

**Quale delle seguenti combinazioni è VALIDA per indirizzamento basato indicizzato?**

A) `[BX + CX]`  
B) `[BX + SI]`  
C) `[SI + DI]`  
D) `[BP + SP]`  

<details>
<summary>Visualizza risposta</summary>

**Risposta corretta: B**

**Spiegazione:**

Nell'indirizzamento basato indicizzato, devi combinare:
- Un **registro base** (BX o BP)
- Con un **registro indice** (SI o DI)

**Combinazioni valide:**
```assembly
[BX + SI]           ; ✓
[BX + DI]           ; ✓
[BP + SI]           ; ✓
[BP + DI]           ; ✓
```

**Combinazioni non valide:**
```assembly
[BX + CX]           ; ✗ CX non è indice
[SI + DI]           ; ✗ Entrambi indici
[BX + BP]           ; ✗ Entrambi base
[BP + SP]           ; ✗ SP non utilizzabile
```

</details>

---

### Domanda 19: Segment Override

**Quale segmento viene usato di default per `MOV AL, [BP+2]`?**

A) CS  
B) DS  
C) SS  
D) ES  

<details>
<summary>Visualizza risposta</summary>

**Risposta corretta: C**

**Spiegazione:**

**BP usa sempre SS (Stack Segment) per default**, a differenza di BX, SI, DI che usano DS.

```assembly
; Default segments
MOV AL, [BX]        ; DS:BX
MOV AL, [SI]        ; DS:SI
MOV AL, [DI]        ; DS:DI
MOV AL, [BP]        ; SS:BP ← ATTENZIONE!

; Segment override
MOV AL, DS:[BP]     ; Forza uso di DS invece di SS
MOV AL, ES:[BX]     ; Forza uso di ES invece di DS
```

Questo rende BP ideale per accedere a dati nello stack (parametri e variabili locali di procedure).

</details>

---

### Domanda 20: Modalità di Indirizzamento - Applicazione

**Quale modalità di indirizzamento useresti per accedere al campo di una struttura a un offset fisso da un indirizzo base variabile?**

A) Immediato  
B) Diretto  
C) Indicizzato o Basato  
D) Relativo  

<details>
<summary>Visualizza risposta</summary>

**Risposta corretta: C**

**Spiegazione:**

Per accedere a campi di strutture con offset fisso da una base variabile, usa **indirizzamento indicizzato o basato**:

```assembly
; Struttura Persona
; Offset 0: nome (20 byte)
; Offset 20: età (1 byte)
; Offset 21: stipendio (2 byte)

; Indicizzato con displacement
MOV SI, OFFSET persona1     ; Base variabile
MOV AL, [SI+20]             ; Accede al campo età
MOV BX, [SI+21]             ; Accede al campo stipendio

; Alternativa con BX
MOV BX, OFFSET persona1
MOV AL, [BX+20]
```

**Vantaggi:**
- Base (SI/BX) può cambiare per accedere a diverse strutture
- Offset è fisso (campo specifico della struttura)
- Efficiente e leggibile

</details>

---

## Riepilogo Punteggi

- **18-20 risposte corrette**: Eccellente! Padronanza completa del modulo.
- **15-17 risposte corrette**: Ottimo! Buona comprensione, rivedere gli errori.
- **12-14 risposte corrette**: Buono! Comprensione base solida, approfondire alcuni aspetti.
- **9-11 risposte corrette**: Sufficiente! Rivedere i concetti fondamentali.
- **< 9 risposte corrette**: Ripassa il modulo prima di procedere.

---

**Argomento precedente:** [Modalità di Indirizzamento](modulo1_03_modalita_indirizzamento.md)  
**Torna all'indice:** [README - Corso Assembly 8086](README.md)
