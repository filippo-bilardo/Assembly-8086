# Strutture di Controllo di Alto Livello

## Introduzione

Anche se l'assembly è un linguaggio di basso livello, possiamo implementare le stesse strutture di controllo dei linguaggi ad alto livello (C, Java, Pascal). Questo modulo mostra come tradurre costrutti familiari in assembly 8086.

Strutture coperte:
- **if-then-else** (selezione semplice)
- **switch-case** (selezione multipla)
- **while** (ciclo con controllo iniziale)
- **do-while** (ciclo con controllo finale)
- **for** (ciclo con contatore)
- **break / continue** (uscita anticipata)

## Pattern Fondamentale: Salti Invertiti

**Regola d'oro**: in assembly, per implementare "se condizione allora", usiamo il salto **inverso**:

```c
// Alto livello
if (condizione) {
    // codice se vero
}
```

```assembly
; Assembly: salta se condizione FALSA
    test_condizione
    J<inverso> skip_blocco   ; Salta se condizione falsa
    ; codice se vero
skip_blocco:
```

**Esempio concreto**:
```c
if (x > 10) {
    y = 5;
}
```

```assembly
; Traduzione assembly
    CMP x, 10
    JLE skip        ; Salta se x ≤ 10 (inverso di >)
    MOV y, 5        ; Eseguito solo se x > 10
skip:
```

## if-then-else

### Forma Base: if-then

**Alto livello**:
```c
if (condizione) {
    // blocco_vero
}
// continua
```

**Assembly**:
```assembly
    ; Test condizione
    CMP operando1, operando2
    J<inverso> fine_if      ; Salta se condizione falsa
    
    ; blocco_vero (eseguito se condizione vera)
    
fine_if:
    ; continua
```

**Esempio 1: if (AL > 0)**
```assembly
    TEST AL, AL
    JLE fine_if         ; Salta se AL ≤ 0
    
    ; Codice per AL > 0
    INC BL
    
fine_if:
```

**Esempio 2: if (AX == BX)**
```assembly
    CMP AX, BX
    JNE fine_if         ; Salta se AX ≠ BX
    
    ; Codice per AX = BX
    MOV CX, 100
    
fine_if:
```

### Forma Completa: if-then-else

**Alto livello**:
```c
if (condizione) {
    // blocco_vero
} else {
    // blocco_falso
}
```

**Assembly**:
```assembly
    ; Test condizione
    CMP operando1, operando2
    J<inverso> else_blocco  ; Salta a else se falso
    
    ; blocco_vero
    JMP fine_if             ; Salta oltre else
    
else_blocco:
    ; blocco_falso
    
fine_if:
```

**Esempio 1: Valore assoluto**
```c
// |x|
if (x >= 0) {
    abs = x;
} else {
    abs = -x;
}
```

```assembly
    MOV AX, x
    TEST AX, AX
    JNS non_negativo    ; Salta se AX ≥ 0
    
    ; Negativo: nega AX
    NEG AX
    JMP fine
    
non_negativo:
    ; Già positivo, AX invariato
    
fine:
    MOV abs, AX
```

**Esempio 2: Massimo tra due numeri**
```c
if (a > b) {
    max = a;
} else {
    max = b;
}
```

```assembly
    MOV AX, a
    CMP AX, b
    JG a_maggiore       ; Salta se a > b
    
    ; a ≤ b
    MOV AX, b
    JMP salva_max
    
a_maggiore:
    ; a > b (AX già contiene a)
    
salva_max:
    MOV max, AX
```

### if-else-if Annidati

**Alto livello**:
```c
if (x < 0) {
    result = -1;
} else if (x == 0) {
    result = 0;
} else {
    result = 1;
}
```

**Assembly**:
```assembly
    MOV AX, x
    TEST AX, AX
    JNS non_negativo    ; Salta se x ≥ 0
    
    ; x < 0
    MOV result, -1
    JMP fine
    
non_negativo:
    JNZ positivo        ; Salta se x ≠ 0
    
    ; x = 0
    MOV result, 0
    JMP fine
    
positivo:
    ; x > 0
    MOV result, 1
    
fine:
```

### Operatori Logici: AND, OR, NOT

**AND logico (&&)**:
```c
if (x > 0 && x < 10) {
    // codice
}
```

```assembly
; Metodo 1: due test
    CMP x, 0
    JLE fine_if         ; Salta se x ≤ 0
    CMP x, 10
    JGE fine_if         ; Salta se x ≥ 10
    
    ; Codice (x è in (0, 10))
    
fine_if:

; Metodo 2: salto corto-circuito
    CMP x, 0
    JLE fine_if         ; Se prima condizione falsa, esci
    CMP x, 10
    JGE fine_if         ; Se seconda condizione falsa, esci
    ; Entrambe vere
    
fine_if:
```

**OR logico (||)**:
```c
if (x == 0 || x == 10) {
    // codice
}
```

```assembly
    CMP x, 0
    JE blocco_vero      ; Salta al codice se x = 0
    CMP x, 10
    JNE fine_if         ; Salta oltre se x ≠ 10
    
blocco_vero:
    ; Codice (x = 0 OR x = 10)
    
fine_if:
```

**NOT logico (!)**:
```c
if (!(x > 10)) {
    // equivalente a: if (x <= 10)
}
```

```assembly
; Inverti la condizione
    CMP x, 10
    JLE blocco_vero     ; NOT (>) = ≤
    JMP fine_if
    
blocco_vero:
    ; Codice
    
fine_if:
```

## switch-case

### Implementazione 1: Confronti Sequenziali

Per pochi casi (2-4), confronti sequenziali sono efficienti.

**Alto livello**:
```c
switch (x) {
    case 1:
        // codice caso 1
        break;
    case 2:
        // codice caso 2
        break;
    case 3:
        // codice caso 3
        break;
    default:
        // codice default
}
```

**Assembly**:
```assembly
    MOV AL, x
    
    CMP AL, 1
    JE caso_1
    CMP AL, 2
    JE caso_2
    CMP AL, 3
    JE caso_3
    JMP caso_default
    
caso_1:
    ; Codice caso 1
    JMP fine_switch
    
caso_2:
    ; Codice caso 2
    JMP fine_switch
    
caso_3:
    ; Codice caso 3
    JMP fine_switch
    
caso_default:
    ; Codice default
    
fine_switch:
```

### Implementazione 2: Jump Table

Per molti casi **contigui** (0, 1, 2, 3...), jump table è molto più efficiente.

**Alto livello**:
```c
switch (operazione) {  // 0, 1, 2, 3
    case 0: addizione(); break;
    case 1: sottrazione(); break;
    case 2: moltiplicazione(); break;
    case 3: divisione(); break;
}
```

**Assembly**:
```assembly
.DATA
    jump_table DW offset addizione
               DW offset sottrazione
               DW offset moltiplicazione
               DW offset divisione

.CODE
    MOV BX, operazione      ; BX = 0, 1, 2, o 3
    
    ; Validazione range
    CMP BX, 3
    JA default_case         ; Se BX > 3, caso default
    
    ; Jump indiretto tramite tabella
    SHL BX, 1               ; BX *= 2 (word = 2 byte)
    JMP [jump_table + BX]   ; Salto all'indirizzo nella tabella
    
addizione:
    ; Codice addizione
    JMP fine_switch
    
sottrazione:
    ; Codice sottrazione
    JMP fine_switch
    
moltiplicazione:
    ; Codice moltiplicazione
    JMP fine_switch
    
divisione:
    ; Codice divisione
    JMP fine_switch
    
default_case:
    ; Caso non valido
    
fine_switch:
```

**Vantaggi jump table**:
- **O(1)**: tempo costante, indipendente dal numero di casi
- Molto veloce per switch densi (casi consecutivi)

**Svantaggi**:
- Richiede casi **contigui** (0,1,2,3... non 1,5,10,20)
- Spreco memoria se ci sono "buchi" nei valori

### Implementazione 3: Jump Table con Offset

Per casi **non contigui** ma densi, usa tabella di traduzione.

**Alto livello**:
```c
switch (carattere) {
    case 'A': /* caso A */; break;
    case 'B': /* caso B */; break;
    case 'C': /* caso C */; break;
    // ...
    case 'Z': /* caso Z */; break;
}
```

**Assembly**:
```assembly
.DATA
    ; Tabella: carattere → indice
    char_to_index DB 'A', 0
                  DB 'B', 1
                  DB 'C', 2
                  ; ... fino a Z
    
    jump_table DW offset caso_A, offset caso_B, offset caso_C
               ; ... fino a caso_Z

.CODE
    ; 1. Converti carattere in indice
    MOV AL, carattere
    CMP AL, 'A'
    JB default_case
    CMP AL, 'Z'
    JA default_case
    
    ; 2. Calcola indice (A=0, B=1, ..., Z=25)
    SUB AL, 'A'         ; AL = 0-25
    
    ; 3. Salto tramite tabella
    XOR AH, AH
    MOV BX, AX
    SHL BX, 1
    JMP [jump_table + BX]
    
caso_A:
    ; ...
    JMP fine_switch
    
; ... altri casi ...

default_case:
fine_switch:
```

## while Loop

**Alto livello**:
```c
while (condizione) {
    // corpo loop
}
```

**Assembly**:
```assembly
while_inizio:
    ; Test condizione
    CMP operando1, operando2
    J<inverso> while_fine   ; Esci se condizione falsa
    
    ; Corpo loop
    
    JMP while_inizio        ; Torna all'inizio
    
while_fine:
```

**Esempio 1: Somma 1 a N**
```c
sum = 0;
i = 1;
while (i <= N) {
    sum += i;
    i++;
}
```

```assembly
    XOR AX, AX          ; sum = 0
    MOV CX, 1           ; i = 1
    
while_loop:
    CMP CX, N
    JG while_fine       ; Esci se i > N
    
    ADD AX, CX          ; sum += i
    INC CX              ; i++
    
    JMP while_loop
    
while_fine:
    MOV sum, AX
```

**Esempio 2: Ricerca in stringa**
```c
char *p = str;
while (*p != '\0') {
    if (*p == cercato)
        return p;
    p++;
}
```

```assembly
    LEA SI, str
    MOV AL, cercato
    
while_loop:
    CMP BYTE PTR [SI], 0
    JE non_trovato      ; Fine stringa
    
    CMP [SI], AL
    JE trovato          ; Carattere trovato
    
    INC SI
    JMP while_loop
    
trovato:
    ; SI punta al carattere
    JMP fine
    
non_trovato:
    ; Non trovato
    
fine:
```

## do-while Loop

**Alto livello**:
```c
do {
    // corpo loop
} while (condizione);
```

**Assembly**:
```assembly
do_inizio:
    ; Corpo loop (eseguito almeno una volta)
    
    ; Test condizione
    CMP operando1, operando2
    J<condizione_vera> do_inizio    ; Ripeti se condizione vera
    
    ; Fine loop
```

**Differenza con while**: il corpo è eseguito **almeno una volta**.

**Esempio 1: Input validato**
```c
do {
    leggi_input();
} while (input < 0 || input > 100);
```

```assembly
do_inizio:
    ; Leggi input
    CALL leggi_input
    ; Risultato in AX
    
    ; Valida: deve essere in [0, 100]
    TEST AX, AX
    JS do_inizio        ; Ripeti se negativo
    CMP AX, 100
    JA do_inizio        ; Ripeti se > 100
    
    ; Input valido
    MOV input, AX
```

**Esempio 2: Menu**
```c
do {
    mostra_menu();
    scelta = leggi_scelta();
    elabora(scelta);
} while (scelta != 'Q');
```

```assembly
do_inizio:
    CALL mostra_menu
    CALL leggi_scelta   ; Risultato in AL
    
    CALL elabora
    
    CMP AL, 'Q'
    JNE do_inizio       ; Ripeti se scelta ≠ 'Q'
    
    ; Uscita
```

## for Loop

**Alto livello**:
```c
for (init; condizione; incremento) {
    // corpo loop
}
```

**Equivalente a while**:
```c
init;
while (condizione) {
    // corpo loop
    incremento;
}
```

**Assembly**:
```assembly
    ; Inizializzazione
    MOV CX, valore_iniziale
    
for_loop:
    ; Test condizione
    CMP CX, valore_finale
    J<inverso> for_fine
    
    ; Corpo loop
    
    ; Incremento
    INC CX              ; o altro incremento
    
    JMP for_loop
    
for_fine:
```

**Esempio 1: for (i = 0; i < 10; i++)**
```assembly
    MOV CX, 0           ; i = 0
    
for_loop:
    CMP CX, 10
    JGE for_fine        ; Esci se i ≥ 10
    
    ; Corpo loop (usa CX)
    
    INC CX              ; i++
    JMP for_loop
    
for_fine:
```

**Esempio 2: for (i = 10; i > 0; i--)**
```assembly
    MOV CX, 10          ; i = 10
    
for_loop:
    TEST CX, CX
    JLE for_fine        ; Esci se i ≤ 0
    
    ; Corpo loop
    
    DEC CX              ; i--
    JMP for_loop
    
for_fine:
```

### for con LOOP

Se usi CX come contatore, puoi ottimizzare con `LOOP`:

```assembly
    MOV CX, 10          ; Ripeti 10 volte
    
for_loop:
    ; Corpo loop
    
    LOOP for_loop       ; DEC CX; JNZ for_loop
```

**Attenzione**: `LOOP` decrementa CX **dopo** il corpo, quindi conta alla rovescia.

**Esempio: Array processing**
```assembly
.DATA
    array DW 10, 20, 30, 40, 50
    len = ($ - array) / 2

.CODE
    LEA SI, array
    MOV CX, len         ; CX = 5
    
process_loop:
    MOV AX, [SI]        ; Carica elemento
    ; Processa AX
    ADD SI, 2           ; Next word
    LOOP process_loop
```

## break e continue

### break - Uscita Anticipata

**Alto livello**:
```c
while (condizione) {
    if (esci)
        break;
    // altro codice
}
```

**Assembly**:
```assembly
while_inizio:
    ; Test condizione principale
    CMP operando1, operando2
    J<inverso> while_fine
    
    ; Test condizione break
    CMP esci, 1
    JE while_fine       ; break: esce dal loop
    
    ; Altro codice
    
    JMP while_inizio
    
while_fine:
```

**Esempio: Ricerca con break**
```c
for (i = 0; i < N; i++) {
    if (array[i] == valore) {
        trovato = 1;
        break;
    }
}
```

```assembly
    LEA SI, array
    MOV CX, N
    MOV AL, valore
    MOV trovato, 0
    
for_loop:
    CMP CX, 0
    JE for_fine
    
    CMP [SI], AL
    JNE non_trovato
    
    ; Trovato!
    MOV trovato, 1
    JMP for_fine        ; break
    
non_trovato:
    ADD SI, 2
    DEC CX
    JMP for_loop
    
for_fine:
```

### continue - Prossima Iterazione

**Alto livello**:
```c
for (i = 0; i < N; i++) {
    if (skip_condizione)
        continue;
    // codice normale
}
```

**Assembly**:
```assembly
    MOV CX, 0           ; i = 0
    
for_loop:
    CMP CX, N
    JGE for_fine
    
    ; Test skip
    CMP skip_condizione, 1
    JE incremento       ; continue: salta al prossimo
    
    ; Codice normale
    
incremento:
    INC CX
    JMP for_loop
    
for_fine:
```

**Esempio: Somma solo positivi**
```c
sum = 0;
for (i = 0; i < N; i++) {
    if (array[i] < 0)
        continue;
    sum += array[i];
}
```

```assembly
    LEA SI, array
    MOV CX, N
    XOR AX, AX          ; sum = 0
    
for_loop:
    TEST CX, CX
    JZ for_fine
    
    MOV BX, [SI]
    TEST BX, BX
    JS skip_negativo    ; continue se negativo
    
    ADD AX, BX          ; sum += array[i]
    
skip_negativo:
    ADD SI, 2
    DEC CX
    JMP for_loop
    
for_fine:
    MOV sum, AX
```

## Loop Annidati

**Alto livello**:
```c
for (i = 0; i < righe; i++) {
    for (j = 0; j < colonne; j++) {
        // matrice[i][j]
    }
}
```

**Assembly**: usa registri diversi per contatori o salva CX nello stack.

**Metodo 1: Registri diversi**
```assembly
    MOV DI, 0           ; i (outer)
    
outer_loop:
    CMP DI, righe
    JGE outer_fine
    
    MOV SI, 0           ; j (inner)
    
inner_loop:
    CMP SI, colonne
    JGE inner_fine
    
    ; Accesso matrice[DI][SI]
    ; Calcolo indirizzo...
    
    INC SI
    JMP inner_loop
    
inner_fine:
    INC DI
    JMP outer_loop
    
outer_fine:
```

**Metodo 2: Stack per salvare CX**
```assembly
    MOV CX, righe
    
outer_loop:
    PUSH CX             ; Salva contatore outer
    
    MOV CX, colonne
inner_loop:
    ; Corpo inner loop
    
    LOOP inner_loop
    
    POP CX              ; Ripristina contatore outer
    LOOP outer_loop
```

## Best Practices

### 1. Etichette Descrittive

```assembly
; ❌ Poco chiaro
l1:
    CMP AX, 10
    JG l2
    INC BX
l2:

; ✓ Chiaro
verifica_limite:
    CMP AX, limite_max
    JG oltre_limite
    INC contatore
oltre_limite:
```

### 2. Commenti per Strutture Complesse

```assembly
; if (x > 0 && x < 100)
    CMP x, 0
    JLE fine_if         ; Salta se x ≤ 0
    CMP x, 100
    JGE fine_if         ; Salta se x ≥ 100
    
    ; x è in (0, 100)
    MOV valido, 1
    
fine_if:
```

### 3. Usa LOOP per Semplicità

```assembly
; ❌ Verbose
    MOV CX, 10
for_loop:
    ; ...
    DEC CX
    JNZ for_loop

; ✓ Compatto
    MOV CX, 10
for_loop:
    ; ...
    LOOP for_loop
```

### 4. JCXZ per Protezione

```assembly
; ✓ Proteggi loop da CX=0
    MOV CX, contatore
    JCXZ skip_loop
loop_inizio:
    ; ...
    LOOP loop_inizio
skip_loop:
```

## Esercizi Pratici

1. Implementa: `if (x >= 10 && x <= 20) y = 5; else y = 0;`
2. Switch-case con jump table per operazioni (+, -, *, /)
3. Ciclo while che trova il primo carattere maiuscolo in una stringa
4. for loop che calcola fattoriale di N
5. Loop annidato per sommare tutti gli elementi di una matrice 3×3

### Soluzione Esercizio 4

```assembly
; Fattoriale di N (iterativo)
.DATA
    N DW 5
    fattoriale DW ?

.CODE
    MOV AX, 1           ; Risultato = 1
    MOV CX, N           ; Contatore = N
    
    ; Protezione per N = 0 o 1
    CMP CX, 1
    JBE salva_risultato
    
calcola_loop:
    MUL CX              ; AX = AX × CX
    DEC CX
    CMP CX, 1
    JG calcola_loop     ; Continua se CX > 1
    
salva_risultato:
    MOV fattoriale, AX
```

---

**Prossimo argomento:** [Procedure e Stack](modulo4_03_procedure_stack.md)
