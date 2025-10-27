# Ricorsione in Assembly 8086

## Introduzione

La **ricorsione** è una tecnica di programmazione in cui una procedura chiama **se stessa** per risolvere un problema suddividendolo in sottoproblemi più semplici.

### Caratteristiche Ricorsione

**Elementi fondamentali**:
1. **Caso base**: condizione di terminazione (no chiamata ricorsiva)
2. **Passo ricorsivo**: chiamata a se stessa con input ridotto
3. **Progresso**: ogni chiamata deve avvicinarsi al caso base

**Vantaggi**:
- Codice elegante e conciso
- Soluzione naturale per problemi ricorsivi (alberi, grafi, divide-et-impera)
- Mapping diretto da definizioni matematiche

**Svantaggi**:
- Overhead di chiamate (CALL/RET, gestione stack)
- Consumo memoria stack (stack overflow per ricorsioni profonde)
- Spesso meno efficiente della versione iterativa

## Meccanismo della Ricorsione

### Stack e Chiamate Ricorsive

Ogni chiamata ricorsiva crea un **nuovo stack frame** contenente:
- Parametri della chiamata
- Indirizzo di ritorno
- Variabili locali
- Registri salvati

**Esempio**: factorial(3)

```
Stack growth:

factorial(3):
  ┌─────────────┐
  │ n = 3       │
  │ Ret Addr    │
  └─────────────┘
  ↓ call factorial(2)
  
  ┌─────────────┐
  │ n = 2       │
  │ Ret Addr    │
  ├─────────────┤
  │ n = 3       │
  │ Ret Addr    │
  └─────────────┘
  ↓ call factorial(1)
  
  ┌─────────────┐
  │ n = 1       │ ← Caso base!
  │ Ret Addr    │
  ├─────────────┤
  │ n = 2       │
  │ Ret Addr    │
  ├─────────────┤
  │ n = 3       │
  │ Ret Addr    │
  └─────────────┘
  
  ↑ return 1
  ↑ return 1×2 = 2
  ↑ return 2×3 = 6
```

### Spazio Stack Richiesto

```
Spazio = profondità_massima × dimensione_stack_frame
```

**Esempio**:
- factorial(100): profondità = 100
- Stack frame = 8 byte (param + ret addr + old BP + local)
- Spazio = 100 × 8 = 800 byte

**Attenzione**: `.STACK 100h` (256 byte) non basta per factorial(100)!

## Esempio 1: Fattoriale

### Definizione Matematica

```
factorial(n) = { 1                    se n ≤ 1  (caso base)
               { n × factorial(n-1)   se n > 1  (passo ricorsivo)
```

### Implementazione

```assembly
; Calcola n!
; Parametro: n (word) in stack
; Ritorna: n! in AX

factorial PROC
    PUSH BP
    MOV BP, SP
    
    ; [BP+4] = n
    
    MOV CX, [BP+4]          ; CX = n
    CMP CX, 1
    JG ricorsione           ; Se n > 1, continua ricorsione
    
    ; Caso base: n ≤ 1
    MOV AX, 1               ; return 1
    JMP fine
    
ricorsione:
    ; Passo ricorsivo: n × factorial(n-1)
    
    ; 1. Calcola factorial(n-1)
    DEC CX                  ; CX = n - 1
    PUSH CX                 ; Parametro per chiamata ricorsiva
    CALL factorial          ; AX = factorial(n-1)
    ADD SP, 2               ; Pulisci parametro
    
    ; 2. Moltiplica per n
    MUL WORD PTR [BP+4]     ; AX = n × factorial(n-1)
    
fine:
    POP BP
    RET 2                   ; Pulisci parametro n
factorial ENDP
```

### Uso

```assembly
.CODE
main PROC
    ; Calcola 5!
    PUSH 5
    CALL factorial
    ; AX = 120 (5! = 5×4×3×2×1)
    
    ; Stampa risultato (codice omesso)
    
    MOV AH, 4Ch
    INT 21h
main ENDP
```

### Traccia Esecuzione

```
factorial(5):
  n=5 > 1 → ricorsione
  call factorial(4):
    n=4 > 1 → ricorsione
    call factorial(3):
      n=3 > 1 → ricorsione
      call factorial(2):
        n=2 > 1 → ricorsione
        call factorial(1):
          n=1 ≤ 1 → return 1
        return 1×2 = 2
      return 2×3 = 6
    return 6×4 = 24
  return 24×5 = 120

Risultato: 120
```

## Esempio 2: Fibonacci

### Definizione Matematica

```
fib(n) = { 0                     se n = 0  (caso base)
         { 1                     se n = 1  (caso base)
         { fib(n-1) + fib(n-2)  se n > 1  (passo ricorsivo)
```

Sequenza: 0, 1, 1, 2, 3, 5, 8, 13, 21, 34, ...

### Implementazione

```assembly
; Calcola n-esimo numero di Fibonacci
; Parametro: n (word) in stack
; Ritorna: fib(n) in AX

fibonacci PROC
    PUSH BP
    MOV BP, SP
    
    ; [BP+4] = n
    
    MOV CX, [BP+4]          ; CX = n
    
    ; Caso base: n = 0
    CMP CX, 0
    JNE non_zero
    XOR AX, AX              ; return 0
    JMP fine
    
non_zero:
    ; Caso base: n = 1
    CMP CX, 1
    JNE ricorsione
    MOV AX, 1               ; return 1
    JMP fine
    
ricorsione:
    ; Passo ricorsivo: fib(n-1) + fib(n-2)
    
    ; 1. Calcola fib(n-1)
    MOV BX, CX
    DEC BX                  ; BX = n - 1
    PUSH BX
    CALL fibonacci          ; AX = fib(n-1)
    ADD SP, 2
    PUSH AX                 ; Salva fib(n-1) nello stack
    
    ; 2. Calcola fib(n-2)
    MOV BX, CX
    SUB BX, 2               ; BX = n - 2
    PUSH BX
    CALL fibonacci          ; AX = fib(n-2)
    ADD SP, 2
    
    ; 3. Somma fib(n-1) + fib(n-2)
    POP BX                  ; BX = fib(n-1)
    ADD AX, BX              ; AX = fib(n-1) + fib(n-2)
    
fine:
    POP BP
    RET 2
fibonacci ENDP
```

### Uso

```assembly
main PROC
    ; Calcola fib(7)
    PUSH 7
    CALL fibonacci
    ; AX = 13
    ; fib(7) = fib(6) + fib(5)
    ;        = 8 + 5 = 13
main ENDP
```

### Problema: Doppia Ricorsione

Fibonacci ricorsivo è **molto inefficiente**:

```
fib(5):
  ├─ fib(4):
  │   ├─ fib(3):
  │   │   ├─ fib(2):
  │   │   │   ├─ fib(1) → 1
  │   │   │   └─ fib(0) → 0
  │   │   └─ fib(1) → 1
  │   └─ fib(2):      ← RIPETUTO!
  │       ├─ fib(1) → 1
  │       └─ fib(0) → 0
  └─ fib(3):          ← RIPETUTO!
      ├─ fib(2):      ← RIPETUTO!
      │   ├─ fib(1) → 1
      │   └─ fib(0) → 0
      └─ fib(1) → 1
```

**Chiamate**: 15 per fib(5), 177 per fib(10), **21.891** per fib(20)!

**Complessità**: O(2^n) - esponenziale

**Soluzione**: usa versione iterativa (O(n)) o memoizzazione.

## Esempio 3: Torre di Hanoi

### Il Problema

Spostare n dischi dalla torre A alla torre C usando la torre B come ausiliaria, con le regole:
1. Spostare un disco alla volta
2. Non mettere un disco grande sopra uno piccolo

```
Inizio (n=3):         Obiettivo:

A    B    C           A    B    C
|    |    |           |    |    |
▅    |    |           |    |    ▅
███  |    |           |    |   ███
█████|    |           |    |  █████
```

### Soluzione Ricorsiva

**Strategia**:
1. Sposta n-1 dischi da A a B (usando C come ausiliaria)
2. Sposta disco grande da A a C
3. Sposta n-1 dischi da B a C (usando A come ausiliaria)

**Casi base**: n = 0 (nessuna mossa)

### Implementazione

```assembly
; Torre di Hanoi
; Parametri (stack): n (num dischi), from (torre origine),
;                    aux (torre ausiliaria), to (torre destinazione)
; Stampa le mosse

hanoi PROC
    PUSH BP
    MOV BP, SP
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    
    ; [BP+10] = n
    ; [BP+8]  = from
    ; [BP+6]  = aux
    ; [BP+4]  = to
    
    MOV CX, [BP+10]         ; CX = n
    
    ; Caso base: n = 0
    CMP CX, 0
    JE fine_hanoi
    
    ; Passo 1: sposta n-1 dischi da 'from' a 'aux' usando 'to'
    DEC CX                  ; CX = n - 1
    PUSH CX                 ; n-1
    PUSH WORD PTR [BP+8]    ; from
    PUSH WORD PTR [BP+4]    ; to (usata come aux)
    PUSH WORD PTR [BP+6]    ; aux (usata come to)
    CALL hanoi
    
    ; Passo 2: sposta disco grande da 'from' a 'to'
    ; Stampa mossa (codice semplificato)
    MOV DL, BYTE PTR [BP+8]     ; DL = from
    ADD DL, '0'
    MOV AH, 02h
    INT 21h                     ; Stampa from
    
    MOV DL, ' '
    INT 21h
    MOV DL, '-'
    INT 21h
    MOV DL, '>'
    INT 21h
    MOV DL, ' '
    INT 21h
    
    MOV DL, BYTE PTR [BP+4]     ; DL = to
    ADD DL, '0'
    INT 21h                     ; Stampa to
    
    ; Newline
    MOV DL, 13
    INT 21h
    MOV DL, 10
    INT 21h
    
    ; Passo 3: sposta n-1 dischi da 'aux' a 'to' usando 'from'
    MOV CX, [BP+10]
    DEC CX                  ; CX = n - 1
    PUSH CX                 ; n-1
    PUSH WORD PTR [BP+6]    ; aux (usata come from)
    PUSH WORD PTR [BP+8]    ; from (usata come aux)
    PUSH WORD PTR [BP+4]    ; to
    CALL hanoi
    
fine_hanoi:
    POP DX
    POP CX
    POP BX
    POP AX
    POP BP
    RET 8                   ; Pulisci 4 parametri (8 byte)
hanoi ENDP
```

### Uso

```assembly
main PROC
    MOV AX, @DATA
    MOV DS, AX
    
    ; Risolvi Torre di Hanoi con 3 dischi
    ; Torri: 1 (from), 2 (aux), 3 (to)
    PUSH 3                  ; n dischi
    PUSH 1                  ; from (torre A)
    PUSH 2                  ; aux (torre B)
    PUSH 3                  ; to (torre C)
    CALL hanoi
    
    MOV AH, 4Ch
    INT 21h
main ENDP
```

### Output

```
1 -> 3
1 -> 2
3 -> 2
1 -> 3
2 -> 1
2 -> 3
1 -> 3
```

7 mosse per 3 dischi (2^3 - 1 = 7).

### Complessità

- **Mosse**: 2^n - 1
- **Chiamate ricorsive**: 2^n - 1
- **Complessità temporale**: O(2^n)
- **Complessità spaziale**: O(n) - profondità stack

Per n=10 dischi: **1023 mosse**!

## Ricorsione vs Iterazione

### Fattoriale Iterativo

```assembly
factorial_iter PROC
    PUSH BP
    MOV BP, SP
    
    ; [BP+4] = n
    
    MOV CX, [BP+4]          ; CX = n
    MOV AX, 1               ; Risultato = 1
    
    ; Se n ≤ 1, return 1
    CMP CX, 1
    JLE fine_iter
    
fact_loop:
    MUL CX                  ; AX = AX × CX
    LOOP fact_loop          ; CX--, ripeti se CX > 0
    
fine_iter:
    POP BP
    RET 2
factorial_iter ENDP
```

**Vantaggi iterativo**:
- Nessun overhead CALL/RET
- Nessun consumo stack (eccetto parametri)
- Più veloce
- Nessun rischio stack overflow

**Svantaggi iterativo**:
- Codice meno elegante per problemi intrinsecamente ricorsivi (es. Torre di Hanoi)

### Fibonacci Iterativo

```assembly
fibonacci_iter PROC
    PUSH BP
    MOV BP, SP
    PUSH BX
    PUSH CX
    
    ; [BP+4] = n
    
    MOV CX, [BP+4]          ; CX = n
    
    ; Casi base
    CMP CX, 0
    JNE non_zero_iter
    XOR AX, AX              ; return 0
    JMP fine_fib_iter
    
non_zero_iter:
    CMP CX, 1
    JNE calcola_iter
    MOV AX, 1               ; return 1
    JMP fine_fib_iter
    
calcola_iter:
    ; fib(0) = 0, fib(1) = 1
    MOV BX, 0               ; BX = fib(i-2)
    MOV AX, 1               ; AX = fib(i-1)
    DEC CX                  ; CX = n - 1 (già fatto fib(1))
    
fib_loop:
    ; Calcola fib(i) = fib(i-1) + fib(i-2)
    PUSH AX                 ; Salva fib(i-1)
    ADD AX, BX              ; AX = fib(i-1) + fib(i-2) = fib(i)
    POP BX                  ; BX = vecchio fib(i-1) = nuovo fib(i-2)
    LOOP fib_loop
    
fine_fib_iter:
    POP CX
    POP BX
    POP BP
    RET 2
fibonacci_iter ENDP
```

**Complessità**: O(n) - lineare (vs O(2^n) ricorsivo)!

### Confronto Prestazioni

| Algoritmo | Ricorsivo | Iterativo |
|-----------|-----------|-----------|
| Fattoriale | O(n) tempo, O(n) stack | O(n) tempo, O(1) stack |
| Fibonacci | O(2^n) tempo, O(n) stack | O(n) tempo, O(1) stack |
| Hanoi | O(2^n) tempo, O(n) stack | Difficile da implementare |

**Regola pratica**: usa ricorsione quando:
- Soluzione naturalmente ricorsiva (alberi, grafi, divide-et-impera)
- Semplicità codice prevale su prestazioni
- Input piccoli (nessun rischio stack overflow)

Altrimenti, preferisci iterazione.

## Tail Recursion

### Concetto

**Tail recursion**: chiamata ricorsiva è l'**ultima operazione** della procedura (nessun calcolo dopo il ritorno).

**Esempio tail recursive**:
```assembly
; Fattoriale con accumulatore (tail recursive)
fact_tail PROC
    ; [BP+4] = n
    ; [BP+6] = accumulatore
    
    MOV CX, [BP+4]
    CMP CX, 1
    JG tail_rec
    
    ; Caso base: return accumulatore
    MOV AX, [BP+6]
    JMP fine_tail
    
tail_rec:
    ; acc_new = n × acc
    MOV AX, [BP+6]
    MUL CX
    
    ; call fact_tail(n-1, acc_new)
    DEC CX
    PUSH CX                 ; n-1
    PUSH AX                 ; acc_new
    CALL fact_tail
    ; return fact_tail(n-1, acc_new) - TAIL CALL!
    
fine_tail:
    RET 4
fact_tail ENDP
```

### Ottimizzazione Tail Call

**Tail call optimization**: il compilatore può trasformare la tail recursion in un loop, eliminando overhead ricorsivo.

**Trasformazione** (manuale):
```assembly
; Ottimizzato: iterativo equivalente
fact_tail_opt PROC
    ; [BP+4] = n
    ; [BP+6] = acc
    
loop_tail:
    MOV CX, [BP+4]
    CMP CX, 1
    JLE return_acc
    
    ; acc = n × acc
    MOV AX, [BP+6]
    MUL CX
    MOV [BP+6], AX      ; Aggiorna acc
    
    ; n = n - 1
    DEC CX
    MOV [BP+4], CX      ; Aggiorna n
    
    JMP loop_tail       ; Ripeti invece di CALL
    
return_acc:
    MOV AX, [BP+6]
    RET 4
fact_tail_opt ENDP
```

**Vantaggi**: prestazioni iterative con stile ricorsivo.

**MASM/TASM**: non ottimizzano automaticamente (fatto a mano).

## Stack Overflow

### Causa

Stack overflow si verifica quando:
- Ricorsione troppo profonda
- Stack troppo piccolo (`.STACK`)
- Ricorsione infinita (nessun caso base)

### Esempio: Ricorsione Infinita

```assembly
; ERRORE: ricorsione infinita!
infinito PROC
    CALL infinito           ; Nessun caso base!
infinito ENDP
```

**Risultato**: programma crash (stack overflow).

### Prevenzione

1. **Caso base corretto**:
```assembly
✓ Sempre raggiungibile:
    CMP n, 0
    JE caso_base

✗ Mai raggiunto:
    CMP n, -1           ; Se n inizia positivo, mai -1!
    JE caso_base
```

2. **Dimensiona stack**:
```assembly
; Per ricorsione profonda
.STACK 1000h            ; 4KB invece di default 256 byte
```

3. **Limita profondità**:
```assembly
; Aggiungi check profondità
MAX_DEPTH EQU 100

proc_safe PROC
    ; [BP+4] = depth
    
    MOV CX, [BP+4]
    CMP CX, MAX_DEPTH
    JAE troppo_profondo     ; Abort se depth ≥ MAX_DEPTH
    
    ; Continua ricorsione...
    INC CX
    PUSH CX                 ; depth + 1
    CALL proc_safe
```

4. **Usa iterazione** per input grandi.

## Best Practices

### 1. Documenta Caso Base

```assembly
fibonacci PROC
    ; Caso base: n=0 → return 0
    ; Caso base: n=1 → return 1
    ; Ricorsione: fib(n) = fib(n-1) + fib(n-2)
```

### 2. Verifica Progresso

Ogni chiamata deve avvicinarsi al caso base:
```assembly
✓ DEC n, SUB n, 2, ...
✗ n non cambia → infinito loop!
```

### 3. Preserva Stato

Salva nello stack i valori necessari dopo chiamate ricorsive:
```assembly
CALL ricorsiva
; AX modificato!
PUSH AX                 ; Salva risultato prima di altra call
CALL altra_ricorsiva
POP BX                  ; Ripristina primo risultato
```

### 4. Preferisci Iterazione per Prestazioni

Se l'iterativo è semplice, usalo:
```assembly
✓ Iterativo per fattoriale, Fibonacci
✗ Ricorsivo solo per Hanoi, traversal alberi, ...
```

### 5. Testa con Input Piccoli

Ricorsione profonda esaurisce stack:
```assembly
; Testa con n piccolo prima!
PUSH 5              ; OK
; PUSH 1000        ; Rischio overflow!
CALL factorial
```

## Esercizi Pratici

1. Converti `fibonacci` ricorsivo in iterativo
2. Scrivi procedura ricorsiva per somma cifre di un numero
3. Implementa ricerca binaria ricorsiva in array ordinato
4. Calcola MCD (massimo comun divisore) con algoritmo di Euclide ricorsivo
5. Stampa i numeri da n a 1 usando ricorsione

### Soluzione Esercizio 2

```assembly
; Somma cifre di un numero (ricorsivo)
; Parametro: numero (word) in stack
; Ritorna: somma cifre in AX

somma_cifre PROC
    PUSH BP
    MOV BP, SP
    PUSH BX
    PUSH DX
    
    ; [BP+4] = numero
    
    MOV AX, [BP+4]          ; AX = numero
    
    ; Caso base: numero < 10 (una cifra)
    CMP AX, 10
    JL una_cifra
    
    ; Passo ricorsivo: somma_cifre(n/10) + n%10
    XOR DX, DX
    MOV BX, 10
    DIV BX                  ; AX = n/10, DX = n%10
    
    PUSH DX                 ; Salva ultima cifra (n%10)
    PUSH AX                 ; Parametro per ricorsione (n/10)
    CALL somma_cifre
    ADD SP, 2
    
    POP DX                  ; Ripristina ultima cifra
    ADD AX, DX              ; AX = somma_cifre(n/10) + n%10
    JMP fine_sc
    
una_cifra:
    ; AX già contiene la cifra
    
fine_sc:
    POP DX
    POP BX
    POP BP
    RET 2
somma_cifre ENDP

; Esempio: somma_cifre(1234) = 1+2+3+4 = 10
```

### Soluzione Esercizio 4 (MCD Euclide)

```assembly
; MCD ricorsivo (algoritmo di Euclide)
; MCD(a, b) = MCD(b, a mod b)
; MCD(a, 0) = a
; Parametri: a, b (word) in stack
; Ritorna: MCD in AX

mcd PROC
    PUSH BP
    MOV BP, SP
    PUSH BX
    PUSH DX
    
    ; [BP+6] = a
    ; [BP+4] = b
    
    MOV BX, [BP+4]          ; BX = b
    
    ; Caso base: b = 0 → return a
    CMP BX, 0
    JNE ricorsione_mcd
    MOV AX, [BP+6]          ; return a
    JMP fine_mcd
    
ricorsione_mcd:
    ; Calcola a mod b
    MOV AX, [BP+6]          ; AX = a
    XOR DX, DX
    DIV BX                  ; AX = a/b, DX = a mod b
    
    ; MCD(b, a mod b)
    PUSH BX                 ; b (diventa nuovo 'a')
    PUSH DX                 ; a mod b (diventa nuovo 'b')
    CALL mcd
    ADD SP, 4
    
fine_mcd:
    POP DX
    POP BX
    POP BP
    RET 4
mcd ENDP

; Esempio: MCD(48, 18)
;   MCD(18, 48 mod 18) = MCD(18, 12)
;   MCD(12, 18 mod 12) = MCD(12, 6)
;   MCD(6, 12 mod 6) = MCD(6, 0)
;   return 6
```

---

**Prossimo argomento:** [Quiz Modulo 4](05_quiz.md)
