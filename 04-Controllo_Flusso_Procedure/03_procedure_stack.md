# Procedure e Gestione dello Stack

## Introduzione

Le **procedure** (o subroutine, funzioni) permettono di organizzare il codice in blocchi riutilizzabili, migliorando:
- **Modularità**: codice organizzato in unità logiche
- **Riusabilità**: stesso codice chiamato da più punti
- **Manutenibilità**: modifiche localizzate
- **Leggibilità**: nomi significativi invece di codice ripetuto

Concetti chiave:
- **CALL/RET**: chiamata e ritorno da procedura
- **Stack**: memoria LIFO per salvataggio dati
- **Parametri**: passaggio dati alla procedura
- **Variabili locali**: dati temporanei della procedura
- **Convenzioni**: regole per preservare registri

## Lo Stack

### Concetto di Stack

Lo **stack** è una regione di memoria gestita con politica **LIFO** (Last In, First Out):
- **PUSH**: inserisce elemento in cima
- **POP**: rimuove elemento dalla cima

```
Stack growth direction: verso il BASSO (indirizzi decrescenti)

    ┌──────────┐ ← Indirizzi alti
    │          │
    │  Stack   │
    │          │
    ├──────────┤ ← SP (Stack Pointer)
    │ Top item │   Ultimo elemento inserito
    ├──────────┤
    │  Item 2  │
    ├──────────┤
    │  Item 1  │
    ├──────────┤
    │  Free    │
    │  Space   │
    └──────────┘ ← Indirizzi bassi
```

### Registri per lo Stack

- **SS** (Stack Segment): segmento stack
- **SP** (Stack Pointer): offset cima stack
- Indirizzo fisico: `SS:SP`

### Operazioni Stack

**PUSH** (inserimento):
```assembly
PUSH AX
; 1. SP = SP - 2
; 2. [SS:SP] = AX
```

**POP** (estrazione):
```assembly
POP BX
; 1. BX = [SS:SP]
; 2. SP = SP + 2
```

**Esempio sequenza**:
```assembly
; Stato iniziale: SP = 1000h

PUSH AX         ; SP = 0FFEh, [SS:0FFEh] = AX
PUSH BX         ; SP = 0FFCh, [SS:0FFCh] = BX
PUSH CX         ; SP = 0FFAh, [SS:0FFAh] = CX

; Stack:
;   [0FFAh] = CX ← SP
;   [0FFCh] = BX
;   [0FFEh] = AX

POP DX          ; DX = CX, SP = 0FFCh
POP SI          ; SI = BX, SP = 0FFEh
POP DI          ; DI = AX, SP = 1000h

; Ordine inverso: LIFO!
```

### Dimensione Stack

Definita con `.STACK` nel programma:

```assembly
.STACK 100h     ; Stack di 256 byte (128 word)
```

**Stack Overflow**: se usi più spazio del disponibile!

```assembly
; Stack piccolo (4 byte)
.STACK 4

; Troppi PUSH
PUSH AX         ; OK
PUSH BX         ; OK (stack pieno!)
PUSH CX         ; OVERFLOW! Sovrascrive dati!
```

**Prevenzione**: dimensiona stack adeguatamente, considera:
- Profondità massima chiamate (ricorsione!)
- Numero variabili locali
- PUSH temporanei

## CALL e RET

### CALL - Chiamata Procedura

**CALL** salta a una procedura e **salva l'indirizzo di ritorno** nello stack.

**Sintassi**:
```assembly
CALL nome_procedura
```

**Operazione**:
```assembly
; CALL = PUSH IP + JMP
PUSH IP             ; Salva indirizzo istruzione successiva
JMP procedura       ; Salta alla procedura
```

**Tipi di CALL**:
- **NEAR CALL**: stessa segmento (salva solo IP)
- **FAR CALL**: altro segmento (salva CS:IP)

### RET - Ritorno da Procedura

**RET** ritorna dalla procedura, ripristinando l'indirizzo di ritorno.

**Sintassi**:
```assembly
RET             ; NEAR return
RET n           ; NEAR return, pulisce n byte dallo stack
RETF            ; FAR return
RETF n          ; FAR return, pulisce n byte
```

**Operazione NEAR**:
```assembly
; RET = POP IP + JMP
POP IP              ; Ripristina indirizzo ritorno
```

**Operazione FAR**:
```assembly
; RETF = POP IP + POP CS + JMP
POP IP
POP CS
```

### Esempio Base

```assembly
.CODE
main:
    MOV AX, 5
    CALL stampa_numero  ; Chiama procedura
    ; Esecuzione continua qui dopo RET
    
    MOV AH, 4Ch
    INT 21h

; Procedura
stampa_numero PROC
    ; Codice procedura
    ; AX contiene numero da stampare
    ; ...
    
    RET                 ; Ritorna a chiamante
stampa_numero ENDP
```

**Cosa succede**:
```
1. CALL stampa_numero:
   - PUSH indirizzo_dopo_call
   - JMP stampa_numero

2. Esecuzione procedura

3. RET:
   - POP indirizzo_ritorno
   - JMP indirizzo_ritorno

4. Esecuzione continua dopo CALL
```

## PROC e ENDP

### Definizione Procedura

**PROC/ENDP** delimitano una procedura in MASM/TASM:

```assembly
nome_procedura PROC [NEAR|FAR]
    ; Corpo procedura
    RET
nome_procedura ENDP
```

**NEAR** (default): stessa segmento
**FAR**: può essere in altro segmento

### Esempio Completo

```assembly
.MODEL SMALL
.STACK 100h

.DATA
    numero DW 42

.CODE
main PROC
    MOV AX, @DATA
    MOV DS, AX
    
    MOV AX, numero
    CALL raddoppia      ; Chiama procedura
    ; AX ora contiene 84
    
    MOV AH, 4Ch
    INT 21h
main ENDP

; Procedura: raddoppia AX
raddoppia PROC
    SHL AX, 1           ; AX = AX × 2
    RET
raddoppia ENDP

END main
```

## Preservazione Registri

### Problema: Registri Condivisi

```assembly
main PROC
    MOV AX, 10
    MOV BX, 20
    CALL calcola
    ; BX è cambiato? Non si sa!
    ADD AX, BX          ; Risultato imprevedibile!
main ENDP

calcola PROC
    MOV BX, 100         ; Modifica BX!
    ; ...
    RET
calcola ENDP
```

### Soluzione: Salva e Ripristina

**Regola**: la procedura deve preservare i registri che **non** usa per valore di ritorno.

```assembly
calcola PROC
    PUSH BX             ; Salva registri usati
    PUSH CX
    
    ; Corpo procedura
    MOV BX, 100
    MOV CX, 50
    ; ...
    
    POP CX              ; Ripristina in ordine inverso
    POP BX
    RET
calcola ENDP
```

### Pattern Standard: Prologo ed Epilogo

**Prologo** (inizio procedura):
```assembly
nome_proc PROC
    PUSH BP             ; Salva BP del chiamante
    MOV BP, SP          ; BP punta alla base dello stack frame
    ; PUSH altri registri
    ; Alloca variabili locali: SUB SP, n
```

**Epilogo** (fine procedura):
```assembly
    ; Dealloca variabili locali: ADD SP, n (o MOV SP, BP)
    ; POP altri registri
    POP BP              ; Ripristina BP
    RET
nome_proc ENDP
```

### Convenzioni Comuni

**Caller-saved** (salvati dal chiamante):
- AX, CX, DX: spesso usati per valori di ritorno/parametri

**Callee-saved** (salvati dalla procedura):
- BX, SI, DI, BP: preservati dalla procedura

**Esempio**:
```assembly
chiamante PROC
    MOV AX, 10
    PUSH AX             ; Salva AX (caller-saved)
    CALL proc
    POP AX              ; Ripristina AX
    ; Uso AX
chiamante ENDP

proc PROC
    PUSH BX             ; Salva BX (callee-saved)
    MOV BX, 100
    ; ...
    POP BX              ; Ripristina BX
    RET
proc ENDP
```

## Passaggio Parametri

### Metodo 1: Tramite Registri

**Pro**: veloce, semplice
**Contro**: limitato a pochi parametri (solo 8 registri generali)

```assembly
; Chiamante
    MOV AX, param1
    MOV BX, param2
    CALL somma
    ; Risultato in AX

; Procedura
somma PROC
    ; AX = param1, BX = param2
    ADD AX, BX          ; AX = param1 + param2
    RET                 ; Ritorna risultato in AX
somma ENDP
```

**Esempio: Scambio valori**
```assembly
main PROC
    MOV AX, 10
    MOV BX, 20
    CALL scambia
    ; AX = 20, BX = 10
main ENDP

scambia PROC
    XCHG AX, BX
    RET
scambia ENDP
```

### Metodo 2: Tramite Memoria Globale

**Pro**: nessun limite numero parametri
**Contro**: non rientrante (problemi con ricorsione), meno flessibile

```assembly
.DATA
    param1 DW ?
    param2 DW ?
    risultato DW ?

.CODE
main PROC
    MOV param1, 10
    MOV param2, 20
    CALL somma
    MOV AX, risultato   ; AX = 30
main ENDP

somma PROC
    MOV AX, param1
    ADD AX, param2
    MOV risultato, AX
    RET
somma ENDP
```

### Metodo 3: Tramite Stack (Più Potente)

**Pro**: supporta ricorsione, molti parametri, rientrante
**Contro**: più complesso, overhead

**Convenzione C/Pascal**: parametri nello stack.

#### Passaggio Stack - Chiamante

```assembly
; Chiamante: PUSH parametri (ordine inverso per C)
    PUSH param2         ; Secondo parametro
    PUSH param1         ; Primo parametro
    CALL somma
    ADD SP, 4           ; Pulisci stack (2 parametri × 2 byte)
    ; Risultato in AX
```

#### Passaggio Stack - Procedura

```assembly
somma PROC
    PUSH BP             ; Salva BP
    MOV BP, SP          ; BP = base stack frame
    
    ; Stack frame:
    ; [BP+6] = param1
    ; [BP+4] = param2
    ; [BP+2] = indirizzo ritorno
    ; [BP+0] = vecchio BP
    
    MOV AX, [BP+6]      ; AX = param1
    ADD AX, [BP+4]      ; AX += param2
    
    POP BP
    RET                 ; o RET 4 per pulire stack
somma ENDP
```

**Stack frame visualizzato**:
```
Dopo CALL somma:
    ┌──────────┐
    │ param2   │ ← [BP+4]
    ├──────────┤
    │ param1   │ ← [BP+6]
    ├──────────┤
    │ Ret Addr │ ← [BP+2]
    ├──────────┤
    │ Old BP   │ ← [BP], SP
    └──────────┘
```

#### RET n - Pulizia Stack Automatica

**RET n** rimuove n byte dallo stack dopo il ritorno:

```assembly
somma PROC
    PUSH BP
    MOV BP, SP
    
    MOV AX, [BP+6]
    ADD AX, [BP+4]
    
    POP BP
    RET 4               ; Ritorna E rimuove 4 byte (2 parametri)
somma ENDP

; Chiamante:
    PUSH 20
    PUSH 10
    CALL somma
    ; Stack già pulito! Non serve ADD SP, 4
```

**Convenzioni**:
- **C convention**: chiamante pulisce stack (`ADD SP, n`)
- **Pascal/STDCALL**: procedura pulisce stack (`RET n`)

### Confronto Metodi

| Metodo | Velocità | Flessibilità | Ricorsione | Complessità |
|--------|----------|--------------|------------|-------------|
| Registri | ⭐⭐⭐ | ⭐ | ❌ | Bassa |
| Memoria | ⭐⭐ | ⭐⭐ | ❌ | Bassa |
| Stack | ⭐ | ⭐⭐⭐ | ✅ | Alta |

## Variabili Locali

### Allocazione nello Stack

Le variabili locali sono allocate nello stack frame:

```assembly
calcola PROC
    PUSH BP
    MOV BP, SP
    SUB SP, 6           ; Alloca 3 word locali (6 byte)
    
    ; Stack frame:
    ; [BP-2] = var1
    ; [BP-4] = var2
    ; [BP-6] = var3
    ; [BP+0] = old BP
    ; [BP+2] = return addr
    
    MOV WORD PTR [BP-2], 100    ; var1 = 100
    MOV WORD PTR [BP-4], 200    ; var2 = 200
    
    ; Calcoli usando var1, var2, var3
    
    MOV SP, BP          ; Dealloca variabili locali
    POP BP
    RET
calcola ENDP
```

**Stack frame completo**:
```
    ┌──────────┐
    │ param2   │ ← [BP+6]
    ├──────────┤
    │ param1   │ ← [BP+4]
    ├──────────┤
    │ Ret Addr │ ← [BP+2]
    ├──────────┤
    │ Old BP   │ ← [BP]
    ├──────────┤
    │ var1     │ ← [BP-2]
    ├──────────┤
    │ var2     │ ← [BP-4]
    ├──────────┤
    │ var3     │ ← [BP-6]
    └──────────┘ ← SP
```

### Macro LOCAL (MASM/TASM)

MASM/TASM offrono `LOCAL` per dichiarare variabili locali:

```assembly
calcola PROC
    LOCAL var1:WORD, var2:WORD, var3:WORD
    
    ; Prologo generato automaticamente:
    ; PUSH BP
    ; MOV BP, SP
    ; SUB SP, 6
    
    MOV var1, 100       ; Tradotto in [BP-2]
    MOV var2, 200
    
    ; Epilogo manuale:
    MOV SP, BP
    POP BP
    RET
calcola ENDP
```

## Esempio Completo: Procedura con Parametri e Locali

```assembly
; Procedura: calcola area rettangolo
; Parametri: base (word), altezza (word)
; Ritorna: area in AX
; Locali: temp (word)

calcola_area PROC
    PUSH BP
    MOV BP, SP
    SUB SP, 2           ; Alloca temp
    
    ; [BP+4] = altezza
    ; [BP+6] = base
    ; [BP-2] = temp
    
    MOV AX, [BP+6]      ; AX = base
    MOV BX, [BP+4]      ; BX = altezza
    MUL BX              ; AX = base × altezza
    
    ; Usa temp per qualcosa
    MOV [BP-2], AX      ; temp = area
    
    ; Risultato già in AX
    
    MOV SP, BP          ; Dealloca locali
    POP BP
    RET 4               ; Pulisci parametri (2×2 byte)
calcola_area ENDP

; Chiamata:
main PROC
    PUSH 30             ; altezza
    PUSH 50             ; base
    CALL calcola_area
    ; AX = 1500 (area)
    ; Stack pulito
main ENDP
```

## Ricorsione

### Concetto

Una procedura **ricorsiva** chiama **se stessa**.

**Requisiti**:
- **Caso base**: condizione di terminazione
- **Passo ricorsivo**: chiamata a se stessa con problema ridotto
- **Stack**: per salvare contesto di ogni chiamata

### Esempio 1: Fattoriale

```
factorial(n) = n × factorial(n-1)
factorial(0) = 1  (caso base)
```

```assembly
; Fattoriale ricorsivo
; Parametro: n in stack
; Ritorna: n! in AX

factorial PROC
    PUSH BP
    MOV BP, SP
    
    ; [BP+4] = n
    
    MOV CX, [BP+4]      ; CX = n
    CMP CX, 1
    JG ricorsione       ; Se n > 1, ricorsione
    
    ; Caso base: n ≤ 1
    MOV AX, 1           ; return 1
    JMP fine
    
ricorsione:
    ; Calcola factorial(n-1)
    DEC CX              ; CX = n - 1
    PUSH CX             ; Parametro per chiamata ricorsiva
    CALL factorial      ; AX = factorial(n-1)
    ADD SP, 2           ; Pulisci parametro
    
    ; AX = factorial(n-1)
    ; Moltiplica per n
    MUL WORD PTR [BP+4] ; AX = n × factorial(n-1)
    
fine:
    POP BP
    RET 2
factorial ENDP

; Chiamata:
    PUSH 5              ; Calcola 5!
    CALL factorial
    ; AX = 120
```

**Cosa succede nello stack**:
```
factorial(5):
  push 4 → factorial(4):
    push 3 → factorial(3):
      push 2 → factorial(2):
        push 1 → factorial(1):
          return 1
        return 1×2 = 2
      return 2×3 = 6
    return 6×4 = 24
  return 24×5 = 120
```

### Esempio 2: Fibonacci

```
fib(n) = fib(n-1) + fib(n-2)
fib(0) = 0, fib(1) = 1  (casi base)
```

```assembly
fibonacci PROC
    PUSH BP
    MOV BP, SP
    
    MOV CX, [BP+4]      ; CX = n
    
    ; Casi base
    CMP CX, 0
    JNE non_zero
    XOR AX, AX          ; return 0
    JMP fine
    
non_zero:
    CMP CX, 1
    JNE ricorsione
    MOV AX, 1           ; return 1
    JMP fine
    
ricorsione:
    ; Calcola fib(n-1)
    MOV BX, CX
    DEC BX
    PUSH BX
    CALL fibonacci
    ADD SP, 2
    PUSH AX             ; Salva fib(n-1)
    
    ; Calcola fib(n-2)
    MOV BX, CX
    SUB BX, 2
    PUSH BX
    CALL fibonacci
    ADD SP, 2
    
    ; AX = fib(n-2)
    POP BX              ; BX = fib(n-1)
    ADD AX, BX          ; AX = fib(n-1) + fib(n-2)
    
fine:
    POP BP
    RET 2
fibonacci ENDP
```

### Problemi Ricorsione

**Stack overflow**: troppe chiamate ricorsive esauriscono lo stack.

```assembly
; Ricorsione infinita (ERRORE!)
infinito PROC
    CALL infinito       ; Nessun caso base!
infinito ENDP
```

**Soluzione**: assicurati che ci sia **sempre** un caso base raggiungibile.

## Best Practices

### 1. Usa BP per Accesso Parametri/Locali

```assembly
✓ Usa BP:
    PUSH BP
    MOV BP, SP
    MOV AX, [BP+4]      ; Chiaro: primo parametro
    POP BP

✗ Senza BP:
    MOV AX, [SP+2]      ; Confuso: SP cambia!
```

### 2. Commenta Stack Frame

```assembly
calcola PROC
    ; Stack frame:
    ; [BP+6] = param1
    ; [BP+4] = param2
    ; [BP+2] = return address
    ; [BP+0] = old BP
    ; [BP-2] = local1
```

### 3. Bilancia PUSH/POP

```assembly
✓ Bilanciato:
    PUSH AX
    PUSH BX
    ; ...
    POP BX
    POP AX
    RET

✗ Sbilanciato:
    PUSH AX
    ; DIMENTICATO POP!
    RET             ; Ritorna all'indirizzo sbagliato!
```

### 4. Dimensiona Stack Adeguatamente

```assembly
; Per ricorsione profonda, aumenta stack
.STACK 400h         ; 1KB invece di 256 byte
```

### 5. Preserva Registri Critici

```assembly
proc PROC
    ; Salva tutti i registri modificati
    PUSH AX
    PUSH BX
    PUSH SI
    PUSH DI
    
    ; Codice procedura
    
    ; Ripristina in ordine inverso
    POP DI
    POP SI
    POP BX
    POP AX
    RET
proc ENDP
```

## Esercizi Pratici

1. Scrivi procedura per calcolare potenza: pow(base, esponente)
2. Implementa procedura ricorsiva per somma array
3. Converti procedura ricorsiva fattoriale in iterativa
4. Procedura con 5 parametri passati via stack
5. Implementa Torre di Hanoi ricorsiva

### Soluzione Esercizio 1 (Iterativa)

```assembly
; pow(base, esponente) iterativo
; Parametri in stack: base, esponente
; Ritorna risultato in AX

pow PROC
    PUSH BP
    MOV BP, SP
    PUSH CX
    
    ; [BP+6] = base
    ; [BP+4] = esponente
    
    MOV AX, 1           ; Risultato = 1
    MOV CX, [BP+4]      ; CX = esponente
    
    ; Se esponente = 0, return 1
    JCXZ fine_pow
    
    MOV BX, [BP+6]      ; BX = base
    
pow_loop:
    MUL BX              ; AX = AX × base
    LOOP pow_loop
    
fine_pow:
    POP CX
    POP BP
    RET 4
pow ENDP
```

---

**Prossimo argomento:** [Quiz Modulo 4](modulo4_04_quiz.md)
