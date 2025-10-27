# Quiz Modulo 4: Strutture di Controllo e Procedure

## Istruzioni

Questo quiz verifica la comprensione di:
- Istruzioni di salto (condizionato e incondizionato)
- Strutture di controllo (if, switch, loop)
- Procedure e chiamate
- Gestione dello stack
- Ricorsione

**Modalità**:
- 20 domande a risposta multipla
- 1 sola risposta corretta
- Soluzioni dettagliate alla fine

---

## Domande

### 1. Quale istruzione esegue un salto incondizionato?
a) JE  
b) JMP  
c) CALL  
d) LOOP

---

### 2. Quale flag viene testata da JZ (Jump if Zero)?
a) CF (Carry Flag)  
b) SF (Sign Flag)  
c) ZF (Zero Flag)  
d) OF (Overflow Flag)

---

### 3. Dopo `CMP AX, BX` seguito da `JA label`, quando si salta?
a) Sempre  
b) Se AX > BX (confronto unsigned)  
c) Se AX > BX (confronto signed)  
d) Se AX = BX

---

### 4. Quale coppia di istruzioni è equivalente?
a) JE e JNZ  
b) JZ e JE  
c) JA e JG  
d) JL e JB

---

### 5. Cosa fa l'istruzione `LOOP label`?
a) Decrementa CX, salta se CX ≠ 0  
b) Incrementa CX, salta se CX = 0  
c) Salta sempre a label  
d) Salta se ZF = 1

---

### 6. In un costrutto if-then-else, come si salta al blocco else?
a) Si testa la condizione e si salta se VERA  
b) Si testa la condizione INVERTITA e si salta se VERA  
c) Si usa sempre JMP  
d) Non si può implementare in assembly

---

### 7. Quale tecnica è più efficiente per uno switch con 10 casi contigui?
a) Confronti sequenziali con CMP  
b) Jump table (tabella di indirizzi)  
c) Ricorsione  
d) Nested loops

---

### 8. In un loop while, dove si posiziona il test della condizione?
a) All'inizio (prima del corpo del loop)  
b) Alla fine (dopo il corpo del loop)  
c) Sia all'inizio che alla fine  
d) Non c'è test

---

### 9. Differenza tra while e do-while?
a) Nessuna  
b) do-while esegue il corpo almeno una volta  
c) while è sempre più veloce  
d) do-while non può avere break

---

### 10. Cosa fa l'istruzione `CALL procedura`?
a) Salta a procedura (come JMP)  
b) PUSH IP, poi salta a procedura  
c) POP IP, poi salta a procedura  
d) Non fa nulla

---

### 11. Cosa fa l'istruzione `RET`?
a) POP IP (NEAR) o POP IP + POP CS (FAR)  
b) PUSH IP  
c) JMP a indirizzo fisso  
d) Termina il programma

---

### 12. Quale registro punta alla cima dello stack?
a) BP (Base Pointer)  
b) SP (Stack Pointer)  
c) IP (Instruction Pointer)  
d) SI (Source Index)

---

### 13. In quale direzione cresce lo stack?
a) Verso indirizzi crescenti (alto → basso)  
b) Verso indirizzi decrescenti (alto → basso)  
c) Dipende dal processore  
d) Non cresce

---

### 14. Dopo `PUSH AX` e `PUSH BX`, quale sequenza li ripristina correttamente?
a) POP AX, POP BX  
b) POP BX, POP AX  
c) POP AX due volte  
d) Non si possono ripristinare

---

### 15. In una procedura con stack frame, [BP+4] tipicamente contiene:
a) Variabile locale  
b) Primo parametro (se NEAR call con 1 param)  
c) Indirizzo di ritorno  
d) Vecchio valore di BP

---

### 16. Quale istruzione serve per allocare variabili locali nello stack?
a) PUSH variabile  
b) SUB SP, n (dove n = byte da allocare)  
c) ADD SP, n  
d) MOV BP, SP

---

### 17. In una procedura ricorsiva, cosa DEVE esserci?
a) Almeno due parametri  
b) Caso base (condizione di terminazione)  
c) LOOP invece di CALL  
d) Jump table

---

### 18. Quale algoritmo è intrinsecamente ricorsivo (difficile iterativo)?
a) Fattoriale  
b) Fibonacci  
c) Torre di Hanoi  
d) Somma array

---

### 19. Cosa causa uno stack overflow?
a) Troppi PUSH senza POP  
b) Ricorsione troppo profonda o infinita  
c) Stack troppo piccolo (.STACK insufficiente)  
d) Tutte le precedenti

---

### 20. Quale versione è più efficiente per calcolare Fibonacci di 30?
a) Ricorsiva semplice: fib(n) = fib(n-1) + fib(n-2)  
b) Iterativa: loop da 0 a n  
c) Entrambe uguali  
d) Dipende dal compilatore

---

## Soluzioni

### 1. Risposta: **b) JMP**

**Spiegazione**:
- **JMP**: salto incondizionato (sempre eseguito)
- **JE**: salto condizionato (se ZF=1)
- **CALL**: chiamata procedura (salva IP prima di saltare)
- **LOOP**: decrementa CX e salta se CX≠0

---

### 2. Risposta: **c) ZF (Zero Flag)**

**Spiegazione**:
- **JZ** (Jump if Zero) = **JE** (Jump if Equal)
- Salta se **ZF = 1** (risultato zero)
- Esempio: dopo `CMP AX, BX`, ZF=1 se AX=BX

---

### 3. Risposta: **b) Se AX > BX (confronto unsigned)**

**Spiegazione**:
- **JA** = Jump if Above (confronto **unsigned**)
- Condizione: CF=0 AND ZF=0 → primo operando > secondo
- Per confronti signed, usa **JG** (Jump if Greater)

**Esempio**:
```assembly
MOV AX, 200         ; AX = 200
MOV BX, 100         ; BX = 100
CMP AX, BX          ; 200 > 100 (unsigned)
JA maggiore         ; SALTA (AX > BX unsigned)
```

---

### 4. Risposta: **b) JZ e JE**

**Spiegazione**:
- **JZ** (Jump if Zero) e **JE** (Jump if Equal) sono **sinonimi**
- Entrambi testano **ZF = 1**
- **JA** (unsigned Above) ≠ **JG** (signed Greater)
- **JL** (signed Less) ≠ **JB** (unsigned Below)

---

### 5. Risposta: **a) Decrementa CX, salta se CX ≠ 0**

**Spiegazione**:
```assembly
LOOP label
; Equivalente a:
; DEC CX
; JNZ label
```
- Decrementa **CX**
- Salta a **label** se **CX ≠ 0**
- Usato per loop con contatore

---

### 6. Risposta: **b) Si testa la condizione INVERTITA e si salta se VERA**

**Spiegazione**:

**Pattern if-then-else**:
```assembly
; if (condizione) then blocco1 else blocco2

    TEST condizione
    Jcc else_label      ; Salto INVERTITO
    ; blocco1 (then)
    JMP fine_if
else_label:
    ; blocco2 (else)
fine_if:
```

**Esempio**:
```assembly
; if (AX == BX) then ... else ...

    CMP AX, BX
    JNE else_label      ; Salta se NON uguale (inverso di ==)
    ; codice then
    JMP fine
else_label:
    ; codice else
fine:
```

---

### 7. Risposta: **b) Jump table (tabella di indirizzi)**

**Spiegazione**:
- **Jump table**: array di indirizzi, accesso O(1)
- **Confronti sequenziali**: O(n) - lento per molti casi
- Efficiente per **casi contigui** (0,1,2,...,9)

**Esempio**:
```assembly
.DATA
    jump_table DW caso0, caso1, caso2, ..., caso9

.CODE
    MOV BX, valore      ; BX = 0..9
    SHL BX, 1           ; BX × 2 (word = 2 byte)
    JMP jump_table[BX]  ; Salto diretto
```

---

### 8. Risposta: **a) All'inizio (prima del corpo del loop)**

**Spiegazione**:

**While loop**:
```assembly
while_loop:
    ; TEST condizione
    CMP CX, 0
    JE fine_while       ; Esci se falso
    ; corpo loop
    JMP while_loop
fine_while:
```

- Test **prima** del corpo
- Se condizione falsa inizialmente, **corpo non eseguito**

---

### 9. Risposta: **b) do-while esegue il corpo almeno una volta**

**Spiegazione**:

**While**: test prima → può non eseguire corpo
```assembly
while_loop:
    CMP CX, 0
    JE fine             ; Test PRIMA
    ; corpo
    JMP while_loop
fine:
```

**Do-while**: test dopo → esegue corpo almeno 1 volta
```assembly
do_while:
    ; corpo (eseguito subito)
    CMP CX, 0           ; Test DOPO
    JNE do_while
```

---

### 10. Risposta: **b) PUSH IP, poi salta a procedura**

**Spiegazione**:
```assembly
CALL procedura
; Equivalente a:
; PUSH IP (indirizzo istruzione dopo CALL)
; JMP procedura
```
- Salva **indirizzo di ritorno** nello stack
- Salta alla procedura
- **RET** ripristina IP (ritorna)

**NEAR CALL**: salva solo IP  
**FAR CALL**: salva CS:IP

---

### 11. Risposta: **a) POP IP (NEAR) o POP IP + POP CS (FAR)**

**Spiegazione**:
```assembly
RET             ; NEAR return
; Equivalente a: POP IP

RETF            ; FAR return
; Equivalente a: POP IP, POP CS
```
- Ripristina indirizzo di ritorno dallo stack
- Ritorna al chiamante

---

### 12. Risposta: **b) SP (Stack Pointer)**

**Spiegazione**:
- **SP**: punta alla **cima dello stack** (ultimo elemento inserito)
- **BP**: usato come **base dello stack frame** (accesso parametri/locali)
- Indirizzo fisico stack: **SS:SP**

---

### 13. Risposta: **b) Verso indirizzi decrescenti (alto → basso)**

**Spiegazione**:
```
Stack cresce verso il BASSO:

    0FFFFh ┌──────┐ ← Indirizzi alti
           │      │
           ├──────┤
           │ TOP  │ ← SP (decrementa con PUSH)
           ├──────┤
           │      │
    0000h  └──────┘ ← Indirizzi bassi
```

- **PUSH**: SP = SP - 2 (decrementa)
- **POP**: SP = SP + 2 (incrementa)

---

### 14. Risposta: **b) POP BX, POP AX**

**Spiegazione**:

**Stack è LIFO** (Last In, First Out):
```assembly
PUSH AX         ; Stack: [AX]
PUSH BX         ; Stack: [BX, AX]

; Ordine inverso!
POP BX          ; BX ripristinato, Stack: [AX]
POP AX          ; AX ripristinato, Stack: []
```

**Regola**: POP in **ordine inverso** rispetto a PUSH.

---

### 15. Risposta: **b) Primo parametro (se NEAR call con 1 param)**

**Spiegazione**:

**Stack frame** dopo CALL e PUSH BP:
```
    ┌──────────┐
    │ param1   │ ← [BP+4]
    ├──────────┤
    │ Ret Addr │ ← [BP+2]
    ├──────────┤
    │ Old BP   │ ← [BP] (BP punta qui)
    └──────────┘ ← SP
```

- **[BP+0]**: vecchio BP (salvato con PUSH BP)
- **[BP+2]**: indirizzo di ritorno (salvato da CALL)
- **[BP+4]**: primo parametro (se passato via stack)

---

### 16. Risposta: **b) SUB SP, n (dove n = byte da allocare)**

**Spiegazione**:
```assembly
proc PROC
    PUSH BP
    MOV BP, SP
    SUB SP, 6       ; Alloca 3 word (6 byte) locali
    
    ; Usa variabili:
    ; [BP-2] = var1
    ; [BP-4] = var2
    ; [BP-6] = var3
    
    MOV SP, BP      ; Dealloca (ripristina SP)
    POP BP
    RET
proc ENDP
```

**Allocazione**: `SUB SP, n` (sposta SP verso il basso)  
**Deallocazione**: `MOV SP, BP` (ripristina SP)

---

### 17. Risposta: **b) Caso base (condizione di terminazione)**

**Spiegazione**:

**Elementi ricorsione**:
1. **Caso base**: condizione che termina la ricorsione (OBBLIGATORIO)
2. **Passo ricorsivo**: chiamata a se stessa con input ridotto
3. **Progresso**: avvicinamento al caso base

**Senza caso base** → ricorsione infinita → **stack overflow**!

**Esempio**:
```assembly
factorial PROC
    ; Caso base: n ≤ 1 → return 1
    CMP n, 1
    JLE caso_base
    
    ; Ricorsione: n × factorial(n-1)
    ; ...
caso_base:
    MOV AX, 1
    RET
factorial ENDP
```

---

### 18. Risposta: **c) Torre di Hanoi**

**Spiegazione**:

**Torre di Hanoi**: soluzione naturalmente ricorsiva
```
hanoi(n, from, aux, to):
  if n > 0:
    hanoi(n-1, from, to, aux)     # Sposta n-1 dischi
    muovi disco da from a to       # Sposta disco grande
    hanoi(n-1, aux, from, to)      # Sposta n-1 dischi
```

Versione iterativa **molto complessa** (richiede simulazione stack).

**Fattoriale, Fibonacci, somma array**: facilmente iterativi.

---

### 19. Risposta: **d) Tutte le precedenti**

**Spiegazione**:

**Cause stack overflow**:

1. **Troppi PUSH senza POP**:
```assembly
loop_infinito:
    PUSH AX         ; Riempie stack!
    JMP loop_infinito
```

2. **Ricorsione troppo profonda**:
```assembly
; factorial(1000) con stack piccolo
.STACK 100h         ; Solo 256 byte!
```

3. **Ricorsione infinita** (nessun caso base):
```assembly
proc PROC
    CALL proc       ; Nessuna terminazione!
proc ENDP
```

4. **Stack troppo piccolo**:
```assembly
.STACK 10h          ; Solo 16 byte (insufficiente)
```

**Prevenzione**: dimensiona stack adeguatamente, verifica caso base, bilancia PUSH/POP.

---

### 20. Risposta: **b) Iterativa: loop da 0 a n**

**Spiegazione**:

**Ricorsiva semplice**: complessità **O(2^n)** - esponenziale!
```
fib(30) → ~2.000.000 chiamate ricorsive
```

**Iterativa**: complessità **O(n)** - lineare
```assembly
; Loop da 0 a n: solo 30 iterazioni
```

**Differenza prestazioni**:
- Ricorsiva fib(30): **secondi**
- Iterativa fib(30): **millisecondi**

**Regola**: per Fibonacci, sempre **iterativo** (o ricorsivo con memoizzazione).

---

## Riepilogo Punteggi

- **18-20 corrette**: Eccellente! Padronanza completa
- **15-17 corrette**: Molto bene, approfondisci qualche dettaglio
- **12-14 corrette**: Buono, rivedi jump condizionati e ricorsione
- **9-11 corrette**: Sufficiente, studia stack frame e parametri
- **< 9 corrette**: Ripassa tutto il modulo 4

---

## Concetti Chiave da Ricordare

### Salti
- **JMP**: incondizionato
- **Jcc**: condizionato (JE, JNE, JG, JL, JA, JB, ...)
- **Unsigned**: JA, JAE, JB, JBE (Above/Below)
- **Signed**: JG, JGE, JL, JLE (Greater/Less)

### Strutture Controllo
- **if-then-else**: salto invertito + JMP finale
- **switch**: jump table (contigui) o confronti sequenziali
- **while**: test prima del corpo
- **do-while**: test dopo il corpo (esegue almeno 1 volta)
- **for**: equivalente a while con init e increment

### Procedure
- **CALL**: PUSH IP (o CS:IP) + JMP
- **RET**: POP IP (o CS:IP)
- **Stack frame**: [BP+n] = parametri, [BP-n] = locali
- **Preservazione**: PUSH/POP registri usati

### Ricorsione
- **Caso base**: OBBLIGATORIO
- **Passo ricorsivo**: chiamata con input ridotto
- **Overhead**: consumo stack, prestazioni
- **Preferisci iterativo** se semplice e efficiente

---

**Modulo completato!** Procedi al [Modulo 5](../modulo5_01_intro.md)
