# Progetto 2: Gioco Snake

## Obiettivo

Implementare il classico gioco **Snake** con:
- Grafica testuale (modalità 80×25)
- Movimento serpente (frecce direzionali)
- Generazione cibo casuale
- Collisioni (muro, auto-collisione)
- Punteggio
- Velocità crescente

## Specifiche Funzionali

### Gameplay

1. **Serpente**: inizia lunghezza 3, cresce mangiando cibo
2. **Cibo**: appare casualmente, +10 punti
3. **Movimento**: frecce (↑↓←→), continuo
4. **Game Over**: collisione muro o se stesso
5. **Velocità**: aumenta ogni 50 punti

### Controlli

| Tasto | Azione |
|-------|--------|
| ↑ | Su |
| ↓ | Giù |
| ← | Sinistra |
| → | Destra |
| ESC | Esci |
| P | Pausa |

## Progettazione

### Strutture Dati

```assembly
.DATA
    ; Campo gioco 78×23 (bordo escluso)
    FIELD_WIDTH EQU 78
    FIELD_HEIGHT EQU 23
    
    ; Serpente (max 200 segmenti)
    MAX_SNAKE_LEN EQU 200
    snake_x DB MAX_SNAKE_LEN DUP(?)
    snake_y DB MAX_SNAKE_LEN DUP(?)
    snake_len DW 3              ; Lunghezza corrente
    
    ; Direzione (0=destra, 1=su, 2=sinistra, 3=giù)
    direction DB 0
    
    ; Cibo
    food_x DB ?
    food_y DB ?
    
    ; Punteggio
    score DW 0
    
    ; Velocità (delay in tick)
    speed DW 5                  ; Iniziale
    
    ; Timer
    last_tick DW ?
```

### Algoritmo Principale

```
1. Inizializza (serpente, campo, cibo)
2. Loop principale:
   a. Leggi input (non bloccante)
   b. Se tempo elapsed > delay:
      - Muovi serpente
      - Controlla collisioni
      - Controlla se mangiato cibo
      - Aggiorna schermo
   c. Ripeti fino Game Over
3. Mostra punteggio finale
```

## Implementazione

### Inizializzazione

```assembly
init_game PROC
    ; Clear screen
    CALL clear_screen
    
    ; Disegna bordo
    CALL draw_border
    
    ; Inizializza serpente (centro schermo)
    MOV snake_x[0], 40
    MOV snake_y[0], 12
    MOV snake_x[1], 39
    MOV snake_y[1], 12
    MOV snake_x[2], 38
    MOV snake_y[2], 12
    MOV snake_len, 3
    
    ; Direzione iniziale: destra
    MOV direction, 0
    
    ; Genera primo cibo
    CALL generate_food
    
    ; Reset punteggio
    MOV score, 0
    MOV speed, 5
    
    ; Timer
    CALL get_tick
    MOV last_tick, AX
    
    RET
init_game ENDP

clear_screen PROC
    MOV AH, 06h                 ; Scroll up
    MOV AL, 0                   ; Clear all
    MOV BH, 07h                 ; White on black
    XOR CX, CX                  ; Top-left (0,0)
    MOV DH, 24
    MOV DL, 79
    INT 10h
    RET
clear_screen ENDP

draw_border PROC
    ; Top border
    MOV DH, 0                   ; Row
    MOV DL, 0                   ; Col
    MOV CX, 80                  ; Width
    MOV AL, '═'
    MOV BL, 0Fh                 ; Bright white
    CALL draw_hline
    
    ; Bottom border
    MOV DH, 24
    CALL draw_hline
    
    ; Left border
    MOV DH, 1
    MOV DL, 0
    MOV CX, 23                  ; Height
    MOV AL, '║'
    CALL draw_vline
    
    ; Right border
    MOV DL, 79
    CALL draw_vline
    
    ; Corners
    CALL set_cursor, 0, 0
    MOV AL, '╔'
    CALL draw_char, 0Fh
    
    CALL set_cursor, 0, 79
    MOV AL, '╗'
    CALL draw_char, 0Fh
    
    CALL set_cursor, 24, 0
    MOV AL, '╚'
    CALL draw_char, 0Fh
    
    CALL set_cursor, 24, 79
    MOV AL, '╝'
    CALL draw_char, 0Fh
    
    RET
draw_border ENDP

draw_hline PROC
    ; DH=row, DL=col, CX=length, AL=char, BL=attr
    PUSH CX
hline_loop:
    CALL set_cursor
    CALL draw_char, BL
    INC DL
    LOOP hline_loop
    POP CX
    RET
draw_hline ENDP

set_cursor PROC
    ; DH=row, DL=col
    PUSH AX
    PUSH BX
    MOV AH, 02h
    MOV BH, 0
    INT 10h
    POP BX
    POP AX
    RET
set_cursor ENDP

draw_char PROC
    ; AL=char, BL=attr
    PUSH AX
    PUSH BX
    PUSH CX
    MOV AH, 09h
    MOV BH, 0
    MOV CX, 1
    INT 10h
    POP CX
    POP BX
    POP AX
    RET
draw_char ENDP
```

### Generazione Cibo Casuale

```assembly
generate_food PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    
gen_food_loop:
    ; Random X (1..78)
    CALL random
    MOV BL, FIELD_WIDTH
    DIV BL                      ; AL = AX % 78
    INC AL                      ; 1..78
    MOV food_x, AL
    
    ; Random Y (1..23)
    CALL random
    MOV BL, FIELD_HEIGHT
    DIV BL
    INC AL
    MOV food_y, AL
    
    ; Controlla se non su serpente
    CALL check_food_on_snake
    JC gen_food_loop            ; Riprova se su serpente
    
    ; Disegna cibo
    MOV DH, food_y
    MOV DL, food_x
    CALL set_cursor
    MOV AL, '$'                 ; Simbolo cibo
    MOV BL, 0Eh                 ; Giallo
    CALL draw_char
    
    POP DX
    POP CX
    POP BX
    POP AX
    RET
generate_food ENDP

random PROC
    ; Genera numero pseudo-random in AX
    ; Usa timer tick (0040:006C)
    
    PUSH ES
    MOV AX, 40h
    MOV ES, AX
    MOV AX, ES:[6Ch]            ; Timer low word
    POP ES
    
    ; LCG: seed = (seed × 1103515245 + 12345) & 0x7FFFFFFF
    ; Semplificato: usa solo tick
    RET
random ENDP

check_food_on_snake PROC
    ; Ritorna CF=1 se cibo su serpente
    PUSH SI
    
    MOV CX, snake_len
    XOR SI, SI
    
check_loop:
    MOV AL, snake_x[SI]
    CMP AL, food_x
    JNE check_next
    MOV AL, snake_y[SI]
    CMP AL, food_y
    JNE check_next
    
    ; Cibo su serpente
    STC
    POP SI
    RET
    
check_next:
    INC SI
    LOOP check_loop
    
    ; Cibo ok
    CLC
    POP SI
    RET
check_food_on_snake ENDP
```

### Input Non-Bloccante

```assembly
read_input PROC
    ; Leggi tasto (non bloccante)
    ; Aggiorna 'direction' se freccia premuta
    
    MOV AH, 01h                 ; Check keystroke
    INT 16h
    JZ no_key                   ; ZF=1, nessun tasto
    
    ; Tasto disponibile, leggi
    MOV AH, 00h
    INT 16h                     ; AL=ASCII, AH=scan
    
    CMP AL, 27                  ; ESC?
    JE exit_game
    
    CMP AL, 'p'                 ; Pausa?
    JE pause_game
    
    ; Controlla frecce (AL=0, AH=scan)
    CMP AL, 0
    JNE no_key
    
    CMP AH, 48h                 ; Arrow Up
    JE set_up
    CMP AH, 50h                 ; Arrow Down
    JE set_down
    CMP AH, 4Bh                 ; Arrow Left
    JE set_left
    CMP AH, 4Dh                 ; Arrow Right
    JE set_right
    JMP no_key
    
set_up:
    CMP direction, 3            ; Non invertire (su ≠ giù)
    JE no_key
    MOV direction, 1
    JMP no_key
    
set_down:
    CMP direction, 1
    JE no_key
    MOV direction, 3
    JMP no_key
    
set_left:
    CMP direction, 0
    JE no_key
    MOV direction, 2
    JMP no_key
    
set_right:
    CMP direction, 2
    JE no_key
    MOV direction, 0
    
no_key:
    CLC                         ; Continue game
    RET
    
exit_game:
    STC                         ; Exit flag
    RET
    
pause_game:
    ; Attendi tasto
    MOV AH, 00h
    INT 16h
    CLC
    RET
read_input ENDP
```

### Movimento Serpente

```assembly
move_snake PROC
    PUSH SI
    
    ; Calcola nuova posizione testa
    MOV AL, snake_x[0]          ; Testa X
    MOV AH, snake_y[0]          ; Testa Y
    
    CMP direction, 0            ; Destra
    JE move_right
    CMP direction, 1            ; Su
    JE move_up
    CMP direction, 2            ; Sinistra
    JE move_left
    ; Giù
    INC AH
    JMP check_collision
    
move_right:
    INC AL
    JMP check_collision
    
move_up:
    DEC AH
    JMP check_collision
    
move_left:
    DEC AL
    
check_collision:
    ; Controlla bordi
    CMP AL, 1
    JL collision
    CMP AL, FIELD_WIDTH
    JG collision
    CMP AH, 1
    JL collision
    CMP AH, FIELD_HEIGHT
    JG collision
    
    ; Controlla auto-collisione
    PUSH AX
    CALL check_self_collision
    POP AX
    JC collision
    
    ; Controlla se mangiato cibo
    CMP AL, food_x
    JNE no_food
    CMP AH, food_y
    JNE no_food
    
    ; Cibo mangiato!
    CALL eat_food
    JMP move_done
    
no_food:
    ; Cancella coda (no crescita)
    MOV SI, snake_len
    DEC SI
    MOV DL, snake_x[SI]
    MOV DH, snake_y[SI]
    CALL set_cursor
    MOV AL, ' '
    MOV BL, 07h
    CALL draw_char
    
move_done:
    ; Shift serpente (coda → testa)
    MOV CX, snake_len
    DEC CX
    MOV SI, CX                  ; Ultimo segmento
    
shift_loop:
    CMP SI, 0
    JE shift_done
    
    DEC SI
    MOV BL, snake_x[SI]
    INC SI
    MOV snake_x[SI], BL
    DEC SI
    
    MOV BL, snake_y[SI]
    INC SI
    MOV snake_y[SI], BL
    DEC SI
    
    LOOP shift_loop
    
shift_done:
    ; Nuova testa
    MOV snake_x[0], AL
    MOV snake_y[0], AH
    
    ; Disegna testa
    MOV DL, AL
    MOV DH, AH
    CALL set_cursor
    MOV AL, 'O'                 ; Testa
    MOV BL, 0Ah                 ; Verde brillante
    CALL draw_char
    
    ; Disegna corpo (segmento 1)
    MOV DL, snake_x[1]
    MOV DH, snake_y[1]
    CALL set_cursor
    MOV AL, 'o'                 ; Corpo
    MOV BL, 02h                 ; Verde scuro
    CALL draw_char
    
    CLC                         ; Continua
    POP SI
    RET
    
collision:
    STC                         ; Game over
    POP SI
    RET
move_snake ENDP

check_self_collision PROC
    ; AL=new_x, AH=new_y
    ; Ritorna CF=1 se collisione con corpo
    
    PUSH SI
    PUSH CX
    
    MOV CX, snake_len
    DEC CX                      ; Escludi testa
    MOV SI, 1
    
coll_loop:
    CMP AL, snake_x[SI]
    JNE coll_next
    CMP AH, snake_y[SI]
    JE coll_found
    
coll_next:
    INC SI
    LOOP coll_loop
    
    CLC                         ; No collisione
    POP CX
    POP SI
    RET
    
coll_found:
    STC
    POP CX
    POP SI
    RET
check_self_collision ENDP

eat_food PROC
    ; Incrementa lunghezza, punteggio, genera nuovo cibo
    
    INC snake_len
    
    ADD score, 10
    
    ; Aumenta velocità ogni 50 punti
    MOV AX, score
    MOV BL, 50
    DIV BL                      ; AL = score / 50
    CMP AL, 0
    JE no_speed_up
    
    CMP speed, 1                ; Min speed
    JLE no_speed_up
    DEC speed
    
no_speed_up:
    ; Genera nuovo cibo
    CALL generate_food
    
    ; Aggiorna punteggio su schermo
    CALL display_score
    
    RET
eat_food ENDP

display_score PROC
    PUSH DX
    
    ; Posizione (riga 0, col 60)
    MOV DH, 0
    MOV DL, 60
    CALL set_cursor
    
    ; Stampa "Score: "
    LEA SI, score_msg
    CALL print_string
    
    ; Stampa valore
    MOV AX, score
    CALL print_decimal
    
    POP DX
    RET
    
score_msg DB 'Score: $'
display_score ENDP
```

### Loop Principale

```assembly
game_loop PROC
game_loop_start:
    ; Leggi input
    CALL read_input
    JC game_over                ; ESC premuto
    
    ; Controlla timer
    CALL get_tick
    MOV BX, last_tick
    SUB AX, BX
    CMP AX, speed               ; Elapsed >= speed?
    JB game_loop_start          ; No, attendi
    
    ; Aggiorna last_tick
    CALL get_tick
    MOV last_tick, AX
    
    ; Muovi serpente
    CALL move_snake
    JC game_over                ; Collisione
    
    JMP game_loop_start
    
game_over:
    ; Mostra "Game Over"
    CALL display_game_over
    
    ; Attendi tasto
    MOV AH, 00h
    INT 16h
    
    RET
game_loop ENDP

get_tick PROC
    ; Ritorna AX = timer tick
    PUSH ES
    MOV AX, 40h
    MOV ES, AX
    MOV AX, ES:[6Ch]
    POP ES
    RET
get_tick ENDP

display_game_over PROC
    MOV DH, 12                  ; Centro schermo
    MOV DL, 35
    CALL set_cursor
    
    LEA SI, game_over_msg
    CALL print_string
    
    MOV DH, 14
    MOV DL, 30
    CALL set_cursor
    
    LEA SI, final_score_msg
    CALL print_string
    
    MOV AX, score
    CALL print_decimal
    
    RET
    
game_over_msg DB 'GAME OVER!$'
final_score_msg DB 'Final Score: $'
display_game_over ENDP
```

## Testing

### Test Case

1. **Movimento base**: serpente si muove in tutte direzioni
2. **Crescita**: mangiando cibo, serpente cresce
3. **Collisione muro**: game over
4. **Auto-collisione**: game over
5. **Inversione proibita**: non può invertire direzione (su→giù)
6. **Velocità**: aumenta con punteggio
7. **Pausa**: gioco si ferma con 'P'
8. **Esci**: ESC termina

## Ottimizzazioni

### 1. Accesso Video Diretto

**INT 10h** è lento → scrivere direttamente in **B800:0000** (VGA text).

```assembly
draw_char_fast PROC
    ; DH=row, DL=col, AL=char, BL=attr
    PUSH ES
    PUSH DI
    
    MOV AX, 0B800h
    MOV ES, AX
    
    ; Offset = (row × 80 + col) × 2
    XOR AH, AH
    MOV AL, DH                  ; Row
    MOV DI, 80
    MUL DI                      ; AX = row × 80
    XOR DH, DH
    ADD AX, DX                  ; + col
    SHL AX, 1                   ; × 2 (char + attr)
    
    MOV DI, AX
    MOV AL, [char_to_draw]
    MOV AH, BL                  ; Attr
    MOV ES:[DI], AX
    
    POP DI
    POP ES
    RET
draw_char_fast ENDP
```

**Performance**: ~10-20× più veloce.

### 2. Doppio Buffering

Disegna su buffer offscreen, poi copia tutto (riduce flicker).

### 3. Lookup Table Movimento

Precalcola offset direzioni invece calcolare ogni volta.

## Estensioni

1. **Livelli**: muri interni, ostacoli
2. **Power-up**: velocità temporanea, invincibilità
3. **Multiplayer**: due serpenti (P1: WASD, P2: frecce)
4. **High score**: salva su file
5. **Grafica migliorata**: ASCII art, colori

---

**Prossimo progetto:** [Quiz Modulo 8](modulo8_03_quiz.md)
