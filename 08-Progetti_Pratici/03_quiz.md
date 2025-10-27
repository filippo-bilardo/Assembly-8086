# Quiz Modulo 8 - Progetti Pratici

## Domande

### 1. Nel progetto calcolatore, quale tecnica converte una stringa in numero?

A) Moltiplicazione per 10 e somma digit  
B) Lookup table ASCII  
C) Conversione esadecimale  
D) Shift left di 3 bit

<details>
<summary>Risposta</summary>

**A** - Moltiplicazione per 10 e somma digit

**Spiegazione:**
```assembly
; "123" → 123
result = 0
for each char in string:
    digit = char - '0'
    result = result × 10 + digit
    
; Esempio: "123"
; '1': 0×10 + 1 = 1
; '2': 1×10 + 2 = 12
; '3': 12×10 + 3 = 123
```
</details>

---

### 2. Quale interrupt legge tastiera **non-bloccante** (Snake)?

A) INT 21h AH=01h  
B) INT 16h AH=01h  
C) INT 10h AH=00h  
D) INT 16h AH=00h

<details>
<summary>Risposta</summary>

**B** - INT 16h AH=01h

**Spiegazione:**
```assembly
; Non-bloccante (ritorna subito)
MOV AH, 01h                 ; Check keystroke
INT 16h
JZ no_key                   ; ZF=1 → nessun tasto

; Se tasto presente, leggi
MOV AH, 00h
INT 16h                     ; AL=ASCII, AH=scan

; INT 21h AH=01h è bloccante
; INT 10h è video, non tastiera
```
</details>

---

### 3. Nel Snake, come prevenire inversione istantanea (su→giù)?

A) Ignora input opposto alla direzione corrente  
B) Delay tra cambi direzione  
C) Buffer input  
D) Disabilita tasti

<details>
<summary>Risposta</summary>

**A** - Ignora input opposto alla direzione corrente

**Spiegazione:**
```assembly
; direction: 0=destra, 1=su, 2=sinistra, 3=giù

set_up:
    CMP direction, 3            ; Già giù?
    JE no_change                ; Ignora
    MOV direction, 1
    
set_down:
    CMP direction, 1            ; Già su?
    JE no_change
    MOV direction, 3
    
; Senza controllo: serpente collide con se stesso
```

**Opposte:** 0↔2 (destra-sinistra), 1↔3 (su-giù)
</details>

---

### 4. Quale area memoria per video testo VGA?

A) A000:0000  
B) B000:0000  
C) B800:0000  
D) C000:0000

<details>
<summary>Risposta</summary>

**C** - B800:0000

**Spiegazione:**
| Modalità | Segmento | Uso |
|----------|----------|-----|
| Testo (80×25) | B800h | Modalità 03h |
| Monocromo | B000h | MDA |
| Grafica VGA | A000h | 320×200×256 |

Struttura memoria testo:
```
Offset = (row × 80 + col) × 2
[char][attr][char][attr]...

Esempio: char 'A' rosso su nero in (0,0)
B800:0000 = 41h         ; 'A'
B800:0001 = 0Ch         ; Attr (rosso brillante)
```
</details>

---

### 5. Per generare numeri random in DOS Assembly?

A) Timer tick BIOS (0040:006C)  
B) INT 1Ah AH=00h  
C) Entrambe A e B  
D) Libreria stdlib.h

<details>
<summary>Risposta</summary>

**C** - Entrambe A e B

**Spiegazione:**
```assembly
; Metodo 1: Lettura diretta tick
MOV AX, 40h
MOV ES, AX
MOV AX, ES:[6Ch]            ; Timer (aggiornato 18.2/sec)

; Metodo 2: INT 1Ah
MOV AH, 00h                 ; Get system time
INT 1Ah                     ; CX:DX = tick count

; Per range [0..N):
MOV BL, N
DIV BL                      ; AL = AX % N

; Migliorare con LCG:
; seed = (seed × 1103515245 + 12345) & 0x7FFF
```

**D** è C, non Assembly.
</details>

---

### 6. Nel calcolatore, overflow 16-bit su moltiplicazione rilevato con?

A) Flag OF  
B) Flag CF  
C) Entrambi OF e CF  
D) Confronto risultato

<details>
<summary>Risposta</summary>

**C** - Entrambi OF e CF

**Spiegazione:**
```assembly
; MUL source (unsigned)
MOV AX, 1000
MOV BX, 100
MUL BX                      ; DX:AX = 100000

; Se DX ≠ 0 → overflow 16-bit
; OF=1, CF=1 se risultato > 16-bit

JC overflow                 ; CF=1

; IMUL (signed)
MOV AX, -32768
MOV BX, 2
IMUL BX

; OF=1 se risultato non rappresentabile in 16-bit
JO overflow
```

**Differenza MUL/IMUL:**
- `MUL`: OF=CF=1 se DX ≠ 0
- `IMUL`: OF=1 se risultato esteso ≠ estensione segno AX
</details>

---

### 7. Conversione numero→stringa: quale algoritmo?

A) Divisione ripetuta per 10, cifre in ordine inverso  
B) Moltiplicazione per 10  
C) Shift right  
D) Lookup table

<details>
<summary>Risposta</summary>

**A** - Divisione ripetuta per 10, cifre in ordine inverso

**Spiegazione:**
```assembly
; 1234 → "1234"
; Divisioni:
; 1234 / 10 = 123 R 4  → '4'
;  123 / 10 = 12  R 3  → '3'
;   12 / 10 = 1   R 2  → '2'
;    1 / 10 = 0   R 1  → '1'

print_decimal PROC
    MOV BX, 10
    XOR CX, CX              ; Contatore cifre
    
extract_loop:
    XOR DX, DX
    DIV BX                  ; AX = AX / 10, DX = resto
    PUSH DX                 ; Salva cifra
    INC CX
    TEST AX, AX
    JNZ extract_loop
    
print_loop:
    POP DX
    ADD DL, '0'             ; Digit → ASCII
    MOV AH, 02h
    INT 21h
    LOOP print_loop
    RET
print_decimal ENDP
```

Cifre salvate su **stack** per invertire ordine.
</details>

---

### 8. Snake: come implementare velocità crescente?

A) Diminuire delay tra aggiornamenti  
B) Aumentare dimensione serpente  
C) Ridurre campo gioco  
D) Aumentare framerate

<details>
<summary>Risposta</summary>

**A** - Diminuire delay tra aggiornamenti

**Spiegazione:**
```assembly
speed DW 5                  ; Tick delay iniziale

game_loop:
    CALL get_tick
    SUB AX, last_tick
    CMP AX, speed           ; Elapsed >= speed?
    JB game_loop            ; Attendi
    
    ; Aggiorna serpente
    CALL move_snake
    
    ; Ogni 50 punti
    MOV AX, score
    MOV BL, 50
    DIV BL
    CMP AL, 0
    JE no_speed_up
    
    CMP speed, 1            ; Min
    JLE no_speed_up
    DEC speed               ; Più veloce!
```

**Timer tick:** 18.2 Hz (1 tick ≈ 55ms)
- `speed=5` → 5×55ms = 275ms/frame
- `speed=1` → 55ms/frame (max velocità)
</details>

---

### 9. Quale struttura dati migliore per serpente dinamico?

A) Array circolare  
B) Lista linkata  
C) Stack  
D) Array fisso

<details>
<summary>Risposta</summary>

**A** - Array circolare (o **D** array fisso per semplicità)

**Spiegazione:**

**Array fisso** (semplice):
```assembly
MAX_LEN EQU 200
snake_x DB MAX_LEN DUP(?)
snake_y DB MAX_LEN DUP(?)
snake_len DW 3

; Pro: semplice, veloce
; Contro: limite fisso
```

**Array circolare** (migliore):
```assembly
head DW 0
tail DW 0
snake_x DB 200 DUP(?)

; Crescita: avanza head
INC head
MOV SI, head
MOV snake_x[SI], new_x

; Movimento: avanza tail
INC tail
```

**Lista linkata:**
- Troppo complessa in Assembly
- Overhead puntatori
- Frammentazione memoria

**Stack:** ordine LIFO inadatto.
</details>

---

### 10. Ottimizzazione INT 10h: quanto più veloce accesso diretto VGA?

A) 2-3×  
B) 5-10×  
C) 10-20×  
D) Nessuna differenza

<details>
<summary>Risposta</summary>

**C** - 10-20× più veloce

**Spiegazione:**

**INT 10h** (lento):
```assembly
MOV AH, 02h                 ; Set cursor
MOV DX, 0050h               ; Row 0, col 80
INT 10h                     ; ~1000 cicli

MOV AH, 09h                 ; Write char
MOV AL, 'A'
INT 10h                     ; ~500 cicli
```

**Accesso diretto** (veloce):
```assembly
MOV AX, 0B800h
MOV ES, AX
MOV DI, 160                 ; Offset (0,80)×2
MOV AX, 0C41h               ; 'A' attr 0Ch
MOV ES:[DI], AX             ; ~5 cicli
```

**Benchmark** (80×25 clear):
- INT 10h: ~500ms
- Accesso diretto: ~25ms

**Speedup:** 20×
</details>

---

### 11. Calcolatore: quale errore per "5 / 0"?

A) Division by zero (gestito)  
B) Crash INT 00h  
C) Risultato errato  
D) Overflow

<details>
<summary>Risposta</summary>

**A** - Division by zero (gestito nel codice)

**Spiegazione:**
```assembly
divide PROC
    ; AX = num1, BX = num2
    TEST BX, BX
    JZ div_by_zero
    
    CWD                         ; DX:AX = estensione segno
    IDIV BX                     ; AX = quoziente
    RET
    
div_by_zero:
    LEA DX, err_div_zero
    CALL print_error
    STC                         ; Errore
    RET
    
err_div_zero DB 'Errore: divisione per zero$'
divide ENDP
```

**Senza controllo:**
```assembly
XOR DX, DX
MOV AX, 5
XOR BX, BX
DIV BX                      ; INT 00h → crash!
```

**INT 00h**: ISR divide error (non gestito in DOS → crash).
</details>

---

### 12. Snake: come evitare flicker durante aggiornamento schermo?

A) Doppio buffering  
B) V-Sync  
C) Ridisegna solo celle cambiate  
D) Tutte

<details>
<summary>Risposta</summary>

**D** - Tutte le tecniche aiutano

**Spiegazione:**

**Doppio buffering:**
```assembly
; Buffer offscreen
buffer DB 80*25*2 DUP(?)

; Disegna su buffer
LEA DI, buffer
; ... scritture ...

; Copia buffer → video
MOV AX, 0B800h
MOV ES, AX
XOR DI, DI
LEA SI, buffer
MOV CX, 80*25
REP MOVSW                   ; Copia tutto
```

**V-Sync** (attendi retrace):
```assembly
vsync PROC
    MOV DX, 03DAh           ; VGA status
wait_end:
    IN AL, DX
    TEST AL, 08h            ; Bit 3 = V-retrace
    JNZ wait_end
wait_start:
    IN AL, DX
    TEST AL, 08h
    JZ wait_start
    RET
vsync ENDP
```

**Ridisegno parziale:**
```assembly
; Solo coda (cancella) e testa (disegna)
```

**Migliore:** combinazione tutte.
</details>

---

### 13. Parsing espressione "2+3*4": quale algoritmo?

A) Shunting Yard  
B) Ricorsione discendente  
C) Stack operatori  
D) Tutte

<details>
<summary>Risposta</summary>

**D** - Tutte valide

**Spiegazione:**

**Shunting Yard** (Dijkstra):
```
Input: 2 + 3 * 4
Output (RPN): 2 3 4 * +

1. 2       → output
2. +       → stack
3. 3       → output
4. * (>+)  → stack     [+, *]
5. 4       → output
6. EOF     → pop all   → *, +

Valuta RPN:
2 3 4 * +
→ 2 (3*4) +
→ 2 12 +
→ 14
```

**Ricorsione discendente:**
```c
expr   = term (('+' | '-') term)*
term   = factor (('*' | '/') factor)*
factor = number | '(' expr ')'
```

**Stack operatori:**
```assembly
; Simile Shunting Yard
; Stack: operatori
; Output: postfix
```

Tutti producono risultato corretto rispettando precedenza.
</details>

---

### 14. Quale tecnica migliore per gestire buffer input 80 char?

A) Array fisso DB 80 DUP(?)  
B) Allocazione dinamica  
C) Lista linkata  
D) Stack

<details>
<summary>Risposta</summary>

**A** - Array fisso DB 80 DUP(?)

**Spiegazione:**
```assembly
.DATA
input_buffer DB 80 DUP(?)   ; Buffer fisso
input_len DW ?

read_line PROC
    LEA DX, input_buffer
    MOV AH, 0Ah             ; Buffered input
    INT 21h
    RET
read_line ENDP

; Pro:
; - Semplice
; - Veloce
; - Nessuna frammentazione
; - Dimensione nota (80 = max riga DOS)

; Contro:
; - Limite fisso (ok per questo caso)
```

**B** (dinamica): overhead, complessità
**C** (lista): troppo complessa
**D** (stack): inadatto (LIFO)
</details>

---

### 15. Snake collision detection: complessità algoritmo?

A) O(1)  
B) O(n)  
C) O(n²)  
D) O(log n)

<details>
<summary>Risposta</summary>

**B** - O(n) dove n = lunghezza serpente

**Spiegazione:**
```assembly
check_self_collision PROC
    ; Nuova testa in AL, AH
    ; Confronta con corpo (n segmenti)
    
    MOV CX, snake_len
    MOV SI, 0
    
check_loop:
    CMP AL, snake_x[SI]
    JNE next
    CMP AH, snake_y[SI]
    JE collision            ; Trovata!
    
next:
    INC SI
    LOOP check_loop         ; n iterazioni
    
    ; No collision
    CLC
    RET
```

**Worst case:** confronta con tutti n segmenti = O(n)

**Ottimizzazione O(1):**
```assembly
; Bitmap 78×23
collision_map DB 78*23 DUP(0)

; Set bit quando serpente passa
; Check bit per nuova posizione
; → O(1) ma 1794 byte memoria
```
</details>

---

### 16. Calcolatore multi-precisione 32-bit: come gestire ADD?

A) ADD + ADC  
B) Solo ADD due volte  
C) XADD  
D) Solo ADC

<details>
<summary>Risposta</summary>

**A** - ADD + ADC (add with carry)

**Spiegazione:**
```assembly
add32 PROC
    ; num1 in DX:AX, num2 in CX:BX
    ; Risultato in DX:AX
    
    ADD AX, BX              ; Low word (setta CF)
    ADC DX, CX              ; High word + carry
    
    JC overflow             ; CF=1 → overflow 32-bit
    RET
    
overflow:
    ; Gestisci errore
    STC
    RET
add32 ENDP

; Esempio: 0x0001:0000 + 0x0000:FFFF
; ADD AX, BX: 0x0000 + 0xFFFF = 0xFFFF (CF=0)
; Errore! Dovrebbe essere 0x0001:FFFF

; Corretto:
; 0x0001:0000
; + 0x0000:FFFF
; = 0x0001:FFFF ✓
```

**ADC**: add with carry (considera CF da ADD precedente).
</details>

---

### 17. Implementare pause in Snake: quale approccio migliore?

A) Loop attesa tasto  
B) Disabilita aggiornamenti, continua loop  
C) Ferma timer  
D) Sleep DOS

<details>
<summary>Risposta</summary>

**A** - Loop attesa tasto (semplice), **B** anche valido

**Spiegazione:**

**Approccio A** (semplice):
```assembly
pause_game:
    ; Mostra "PAUSED"
    CALL display_pause
    
    ; Attendi tasto qualsiasi
    MOV AH, 00h
    INT 16h                 ; Bloccante
    
    ; Rimuovi "PAUSED"
    CALL clear_pause
    RET
```

**Approccio B** (flag):
```assembly
paused DB 0

game_loop:
    CMP paused, 1
    JE skip_update
    
    ; Aggiorna gioco
    CALL move_snake
    
skip_update:
    ; Leggi input (check 'P' toggle)
    CALL read_input
    JMP game_loop
```

**C**: timer continua (18.2 Hz non fermabile facilmente)
**D**: `INT 15h AH=86h` blocca tutto.
</details>

---

### 18. Quale vantaggio REP MOVSW vs loop manuale copia memoria?

A) Più veloce (microcode ottimizzato)  
B) Codice più compatto  
C) Automatico decremento CX  
D) Tutte

<details>
<summary>Risposta</summary>

**D** - Tutte

**Spiegazione:**

**Loop manuale:**
```assembly
MOV CX, 1000
LEA SI, source
LEA DI, dest

copy_loop:
    MOV AX, [SI]            ; 4 cicli
    MOV [DI], AX            ; 4 cicli
    ADD SI, 2               ; 2 cicli
    ADD DI, 2               ; 2 cicli
    LOOP copy_loop          ; 5 cicli
    ; Totale: 17 cicli/word
    ; 1000 word = 17000 cicli
```

**REP MOVSW:**
```assembly
MOV CX, 1000
LEA SI, source
LEA DI, dest
REP MOVSW                   ; ~8 cicli/word microcode
    ; 1000 word = 8000 cicli
```

**Speedup:** ~2×

**Vantaggi:**
- ✓ Velocità (microcode CPU)
- ✓ Compattezza (1 istruzione vs 5)
- ✓ Auto-decremento SI, DI, CX
</details>

---

### 19. Snake: generare cibo non su serpente, complessità?

A) O(1) sempre  
B) O(n) worst case  
C) O(∞) se serpente riempie campo  
D) B e C

<details>
<summary>Risposta</summary>

**D** - O(n) worst case, O(∞) se campo pieno

**Spiegazione:**
```assembly
generate_food PROC
gen_loop:
    CALL random             ; Genera X, Y
    
    ; Controlla se su serpente (O(n))
    CALL check_on_snake
    JC gen_loop             ; Riprova
    
    ; Ok, posiziona
    RET
generate_food ENDP
```

**Analisi:**
- Campo: 78×23 = 1794 celle
- Serpente: n celle occupate
- Probabilità hit: n / 1794
- Tentativi attesi: 1794 / (1794 - n)

**Casi:**
- n = 10: ~1.006 tentativi (praticamente O(1))
- n = 1700: ~19 tentativi (O(n))
- n = 1794: **loop infinito!** (campo pieno)

**Miglioramento:**
```assembly
; Conta celle libere, scegli random tra quelle
; O(n) costruzione + O(1) scelta = O(n) garantito
```
</details>

---

### 20. Quale tecnica debugging per calcolatore?

A) Breakpoint INT 03h  
B) Print intermediate values  
C) Debugger (TD, CodeView)  
D) Tutte

<details>
<summary>Risposta</summary>

**D** - Tutte valide

**Spiegazione:**

**INT 03h (breakpoint):**
```assembly
    MOV AX, 5
    INT 03h                 ; Debugger break
    ADD AX, BX
```

**Print debug:**
```assembly
DEBUG_PRINT MACRO msg
    PUSH AX
    PUSH DX
    LEA DX, msg
    MOV AH, 09h
    INT 21h
    POP DX
    POP AX
ENDM

    CALL parse_input
    DEBUG_PRINT debug_msg
    CALL calculate
    
debug_msg DB 'After parse$'
```

**Turbo Debugger:**
```
td calcolatore.exe

; Comandi:
; F7: Step into
; F8: Step over
; Ctrl+F7: Watch variable
; F4: Run to cursor
```

**Trace registro:**
```assembly
TRACE MACRO reg
    PUSH AX
    PUSH DX
    MOV AX, reg
    CALL print_hex
    POP DX
    POP AX
ENDM

    CALL divide
    TRACE AX                ; Mostra risultato
```

**Migliore:** combinazione debugger + print strategici.
</details>

---

## Valutazione

| Punteggio | Livello |
|-----------|---------|
| 18-20 | Ottimo - Padronanza progetti pratici |
| 15-17 | Buono - Competenze solide |
| 12-14 | Sufficiente - Rivedere implementazioni |
| <12 | Insufficiente - Ripetere modulo |

## Consigli Studio

1. **Implementa progetti:** teoria + pratica
2. **Debug sistematico:** TD/breakpoint
3. **Profiling:** misura performance
4. **Estendi progetti:** aggiungi feature
5. **Commenta codice:** comprensione

---

**Completato Modulo 8!** 🎉  
Prossimo: [Riepilogo Corso](../README.md)
