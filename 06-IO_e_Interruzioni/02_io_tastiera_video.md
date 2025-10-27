# Input/Output Tastiera e Video

## Introduzione

Le funzioni BIOS e DOS per tastiera e video sono fondamentali per l'interazione utente. Questo modulo esplora le principali interruzioni per input da tastiera e output su schermo.

## INT 21h - DOS Keyboard/Screen

### Funzioni Input Tastiera

#### 01h - Read Character with Echo

```assembly
MOV AH, 01h
INT 21h
; AL = carattere ASCII letto
; Carattere visualizzato (echo)
```

**Caratteristiche**:
- Attende pressione tasto
- Echo automatico sullo schermo
- Gestisce Ctrl+C (termina programma)
- Gestisce Ctrl+Break

**Esempio**:
```assembly
.DATA
    prompt DB 'Premi un tasto: $'

.CODE
    LEA DX, prompt
    MOV AH, 09h
    INT 21h                 ; Stampa prompt
    
    MOV AH, 01h
    INT 21h                 ; Leggi con echo
    ; AL = carattere letto
    
    MOV saved_char, AL
```

#### 06h - Direct Console I/O

```assembly
MOV AH, 06h
MOV DL, 0FFh               ; 0FFh = input mode
INT 21h
; ZF = 1: nessun carattere disponibile
; ZF = 0: AL = carattere letto
```

**Caratteristiche**:
- **Non** attende (polling)
- **Non** fa echo
- **Non** gestisce Ctrl+C
- Utile per input non bloccante

**Esempio: Polling Tastiera**:
```assembly
; Loop finché non premuto tasto
wait_key:
    MOV AH, 06h
    MOV DL, 0FFh
    INT 21h
    JZ wait_key             ; ZF=1, nessun tasto
    ; AL = carattere letto
```

#### 07h - Direct Input without Echo

```assembly
MOV AH, 07h
INT 21h
; AL = carattere letto
```

**Caratteristiche**:
- Attende pressione
- **Non** fa echo
- **Non** gestisce Ctrl+C

#### 08h - Read Character without Echo

```assembly
MOV AH, 08h
INT 21h
; AL = carattere letto
```

**Caratteristiche**:
- Attende pressione
- **Non** fa echo
- Gestisce Ctrl+C

#### 0Ah - Buffered String Input

```assembly
.DATA
    input_buffer DB 80      ; Lunghezza massima
                 DB ?       ; Caratteri letti effettivi
                 DB 80 DUP(?) ; Buffer

.CODE
    LEA DX, input_buffer
    MOV AH, 0Ah
    INT 21h
    ; input_buffer+1 = numero caratteri letti
    ; input_buffer+2.. = stringa (senza CR)
```

**Caratteristiche**:
- Legge intera linea (fino ENTER)
- Gestisce backspace, editing
- Non include CR (0Dh) finale

**Esempio: Input Nome**:
```assembly
.DATA
    name_buf DB 50          ; Max 50 caratteri
             DB ?           ; Caratteri effettivi
             DB 50 DUP(?)   ; Buffer

.CODE
    LEA DX, name_buf
    MOV AH, 0Ah
    INT 21h
    
    ; Leggi numero caratteri
    MOV BL, name_buf+1      ; BL = lunghezza
    XOR BH, BH              ; BX = lunghezza
    
    ; Termina stringa con NUL
    LEA SI, name_buf+2
    ADD SI, BX
    MOV BYTE PTR [SI], 0
```

### Funzioni Output Video

#### 02h - Write Character

```assembly
MOV AH, 02h
MOV DL, carattere
INT 21h
; Stampa carattere in DL
```

**Esempio**:
```assembly
; Stampa 'A'
    MOV AH, 02h
    MOV DL, 'A'
    INT 21h
```

#### 09h - Write String

```assembly
.DATA
    msg DB 'Hello, World!$'

.CODE
    LEA DX, msg
    MOV AH, 09h
    INT 21h
; Stampa stringa fino '$'
```

**Attenzione**: stringa DEVE terminare con `'$'` (24h).

#### Caratteri Speciali

| Codice | ASCII | Funzione |
|--------|-------|----------|
| 07h | BEL | Beep |
| 08h | BS | Backspace |
| 09h | TAB | Tab |
| 0Ah | LF | Line Feed (a capo) |
| 0Dh | CR | Carriage Return (inizio linea) |

**Esempio: A capo**:
```assembly
; Stampa CR+LF (newline)
newline PROC
    MOV AH, 02h
    MOV DL, 0Dh             ; CR
    INT 21h
    MOV DL, 0Ah             ; LF
    INT 21h
    RET
newline ENDP
```

## INT 16h - BIOS Keyboard

### 00h - Read Keystroke

```assembly
MOV AH, 00h
INT 16h
; AL = ASCII character
; AH = scan code
```

**Caratteristiche**:
- Attende pressione tasto
- Ritorna ASCII + scan code
- Gestisce tasti speciali (F1-F12, arrow, ecc.)

**Scan Code Comuni**:

| Tasto | Scan Code (AH) | ASCII (AL) |
|-------|----------------|------------|
| ESC | 01h | 1Bh |
| F1 | 3Bh | 00h |
| F2 | 3Ch | 00h |
| Arrow Up | 48h | 00h |
| Arrow Down | 50h | 00h |
| Arrow Left | 4Bh | 00h |
| Arrow Right | 4Dh | 00h |
| Enter | 1Ch | 0Dh |
| Space | 39h | 20h |
| 'A' | 1Eh | 41h (se lowercase: 61h) |

**Esempio: Gestione Frecce**:
```assembly
read_key:
    MOV AH, 00h
    INT 16h                 ; AL = ASCII, AH = scan
    
    CMP AL, 0               ; Tasto speciale?
    JE special_key
    ; Tasto normale
    JMP process_normal
    
special_key:
    CMP AH, 48h             ; Arrow Up?
    JE arrow_up
    CMP AH, 50h             ; Arrow Down?
    JE arrow_down
    CMP AH, 4Bh             ; Arrow Left?
    JE arrow_left
    CMP AH, 4Dh             ; Arrow Right?
    JE arrow_right
    JMP read_key
    
arrow_up:
    ; Gestisci freccia su
    JMP read_key
    
arrow_down:
    ; Gestisci freccia giù
    JMP read_key
    
; ... ecc.
```

### 01h - Check Keystroke Status

```assembly
MOV AH, 01h
INT 16h
; ZF = 0: tasto disponibile (AL = ASCII, AH = scan)
; ZF = 1: nessun tasto
; Tasto NON rimosso dal buffer
```

**Caratteristiche**:
- Non bloccante (polling)
- Tasto rimane nel buffer (usa 00h per rimuoverlo)

**Esempio: Attendi Tasto con Timeout**:
```assembly
; Attendi tasto con timeout (approssimativo)
wait_key_timeout PROC
    MOV CX, 0FFFFh          ; Timeout counter
    
check_loop:
    MOV AH, 01h
    INT 16h
    JNZ key_pressed         ; ZF=0, tasto disponibile
    
    LOOP check_loop         ; Decrementa CX, ripeti
    
    ; Timeout
    STC                     ; CF = 1 (timeout)
    RET
    
key_pressed:
    ; Leggi tasto
    MOV AH, 00h
    INT 16h                 ; AL = carattere
    
    CLC                     ; CF = 0 (ok)
    RET
wait_key_timeout ENDP
```

### 02h - Get Shift Status

```assembly
MOV AH, 02h
INT 16h
; AL = shift status flags
```

**Shift Status Flags** (AL):

| Bit | Maschera | Significato |
|-----|----------|-------------|
| 7 | 80h | Insert attivo |
| 6 | 40h | Caps Lock attivo |
| 5 | 20h | Num Lock attivo |
| 4 | 10h | Scroll Lock attivo |
| 3 | 08h | Alt premuto |
| 2 | 04h | Ctrl premuto |
| 1 | 02h | Shift sinistro premuto |
| 0 | 01h | Shift destro premuto |

**Esempio: Controlla Caps Lock**:
```assembly
check_caps_lock PROC
    MOV AH, 02h
    INT 16h                 ; AL = flags
    TEST AL, 40h            ; Bit 6 = Caps Lock
    JZ caps_off
    ; Caps Lock attivo
    RET
    
caps_off:
    ; Caps Lock spento
    RET
check_caps_lock ENDP
```

## INT 10h - BIOS Video

### Modalità Video

#### 00h - Set Video Mode

```assembly
MOV AH, 00h
MOV AL, mode
INT 10h
```

**Modi Video Comuni**:

| Modo | Tipo | Risoluzione | Colori |
|------|------|-------------|--------|
| 00h | Text | 40×25 | 16 (B&W) |
| 01h | Text | 40×25 | 16 |
| 02h | Text | 80×25 | 16 (B&W) |
| 03h | Text | 80×25 | 16 |
| 04h | Graphics | 320×200 | 4 |
| 12h | Graphics | 640×480 | 16 (VGA) |
| 13h | Graphics | 320×200 | 256 (VGA) |

**Esempio: Imposta Modo Testo 80×25**:
```assembly
    MOV AH, 00h
    MOV AL, 03h             ; 80×25, 16 colori
    INT 10h
```

### Gestione Cursore

#### 01h - Set Cursor Shape

```assembly
MOV AH, 01h
MOV CH, start_line         ; Linea inizio (0-15)
MOV CL, end_line           ; Linea fine (0-15)
INT 10h
```

**Esempio: Cursore Normale**:
```assembly
    MOV AH, 01h
    MOV CH, 6               ; Inizio
    MOV CL, 7               ; Fine
    INT 10h
```

**Esempio: Cursore Invisibile**:
```assembly
    MOV AH, 01h
    MOV CH, 20h             ; Bit 5 = nascosto
    INT 10h
```

#### 02h - Set Cursor Position

```assembly
MOV AH, 02h
MOV BH, page               ; Pagina video (0-7)
MOV DH, row                ; Riga (0-24)
MOV DL, col                ; Colonna (0-79)
INT 10h
```

**Esempio: Cursore in Alto a Sinistra**:
```assembly
    MOV AH, 02h
    MOV BH, 0               ; Pagina 0
    MOV DH, 0               ; Riga 0
    MOV DL, 0               ; Colonna 0
    INT 10h
```

#### 03h - Get Cursor Position

```assembly
MOV AH, 03h
MOV BH, page
INT 10h
; DH = row, DL = col
; CH = start line, CL = end line
```

### Stampa Caratteri

#### 09h - Write Character and Attribute

```assembly
MOV AH, 09h
MOV AL, character
MOV BH, page
MOV BL, attribute          ; Colore
MOV CX, count              ; Ripetizioni
INT 10h
```

**Attributo Video** (BL, modalità testo):

```
  7 6 5 4 3 2 1 0
 ┌─┬───┬─┬─────┐
 │B│BGR│I│ BGR │
 └─┴───┴─┴─────┘
  │  │  │   │
  │  │  │   └─ Foreground (carattere)
  │  │  └───── Intensity (luminoso)
  │  └──────── Background
  └─────────── Blink

B = Blink (1 = lampeggiante)
I = Intensity (1 = luminoso)
BGR = Blue Green Red (3 bit colore)
```

**Colori**:

| Codice | Colore | Codice | Colore |
|--------|--------|--------|--------|
| 0 | Nero | 8 | Grigio scuro |
| 1 | Blu | 9 | Blu chiaro |
| 2 | Verde | A | Verde chiaro |
| 3 | Ciano | B | Ciano chiaro |
| 4 | Rosso | C | Rosso chiaro |
| 5 | Magenta | D | Magenta chiaro |
| 6 | Marrone | E | Giallo |
| 7 | Grigio chiaro | F | Bianco |

**Esempio: Stampa 'A' Rosso su Giallo**:
```assembly
    MOV AH, 09h
    MOV AL, 'A'             ; Carattere
    MOV BH, 0               ; Pagina
    MOV BL, 0CEh            ; 1100 1110b = Rosso chiaro su giallo
                           ; (Blink=1, BG=giallo, Intense=1, FG=rosso)
    MOV CX, 1               ; 1 carattere
    INT 10h
```

#### 0Eh - Teletype Output

```assembly
MOV AH, 0Eh
MOV AL, character
MOV BH, page
INT 10h
```

**Caratteristiche**:
- Stampa carattere e avanza cursore
- Gestisce CR, LF, BEL, BS, TAB
- Scrolling automatico

**Esempio: Stampa Stringa**:
```assembly
print_string PROC
    ; DS:SI = stringa (terminata con 0)
    PUSH SI
    
print_loop:
    LODSB                   ; AL = [SI], SI++
    OR AL, AL               ; Fine stringa?
    JZ print_done
    
    MOV AH, 0Eh
    MOV BH, 0
    INT 10h                 ; Stampa AL
    
    JMP print_loop
    
print_done:
    POP SI
    RET
print_string ENDP

; Uso:
.DATA
    msg DB 'Hello, World!', 0

.CODE
    LEA SI, msg
    CALL print_string
```

### Scrolling

#### 06h - Scroll Up

```assembly
MOV AH, 06h
MOV AL, lines              ; Numero linee (0 = clear window)
MOV BH, attribute          ; Attributo righe vuote
MOV CH, top_row
MOV CL, left_col
MOV DH, bottom_row
MOV DL, right_col
INT 10h
```

**Esempio: Clear Screen**:
```assembly
clear_screen PROC
    MOV AH, 06h
    MOV AL, 0               ; Scroll tutto
    MOV BH, 07h             ; Grigio su nero
    MOV CX, 0               ; Top-left (0,0)
    MOV DH, 24              ; Bottom row
    MOV DL, 79              ; Right col
    INT 10h
    
    ; Cursore in (0,0)
    MOV AH, 02h
    MOV BH, 0
    MOV DX, 0
    INT 10h
    RET
clear_screen ENDP
```

#### 07h - Scroll Down

Uguale a 06h, ma scroll verso il basso.

## Esempi Completi

### Menu Interattivo

```assembly
.MODEL SMALL
.STACK 100h

.DATA
    menu DB 13,10
         DB '===== MENU =====',13,10
         DB '1. Opzione 1',13,10
         DB '2. Opzione 2',13,10
         DB '3. Opzione 3',13,10
         DB '0. Esci',13,10
         DB 'Scelta: $'
    invalid DB 13,10,'Scelta non valida!',13,10,'$'

.CODE
main PROC
    MOV AX, @DATA
    MOV DS, AX
    
show_menu:
    ; Stampa menu
    LEA DX, menu
    MOV AH, 09h
    INT 21h
    
    ; Leggi scelta
    MOV AH, 01h
    INT 21h                 ; AL = scelta
    
    CMP AL, '0'
    JE exit_program
    CMP AL, '1'
    JE option1
    CMP AL, '2'
    JE option2
    CMP AL, '3'
    JE option3
    
    ; Scelta non valida
    LEA DX, invalid
    MOV AH, 09h
    INT 21h
    JMP show_menu
    
option1:
    ; Esegui opzione 1
    ; ...
    JMP show_menu
    
option2:
    ; Esegui opzione 2
    ; ...
    JMP show_menu
    
option3:
    ; Esegui opzione 3
    ; ...
    JMP show_menu
    
exit_program:
    MOV AH, 4Ch
    INT 21h
main ENDP
END main
```

### Input Password (senza echo)

```assembly
read_password PROC
    ; DS:SI = buffer output (max 50 caratteri)
    PUSH SI
    
    MOV CX, 0               ; Contatore caratteri
    
read_loop:
    MOV AH, 08h             ; Leggi senza echo
    INT 21h
    
    CMP AL, 0Dh             ; ENTER?
    JE read_done
    
    CMP AL, 08h             ; BACKSPACE?
    JE handle_backspace
    
    CMP CX, 50              ; Max 50 caratteri
    JAE read_loop
    
    ; Salva carattere
    MOV [SI], AL
    INC SI
    INC CX
    
    ; Stampa '*'
    MOV AH, 02h
    MOV DL, '*'
    INT 21h
    
    JMP read_loop
    
handle_backspace:
    CMP CX, 0               ; Buffer vuoto?
    JE read_loop
    
    DEC SI
    DEC CX
    
    ; Cancella '*' sullo schermo
    MOV AH, 02h
    MOV DL, 08h             ; BS
    INT 21h
    MOV DL, ' '
    INT 21h
    MOV DL, 08h
    INT 21h
    
    JMP read_loop
    
read_done:
    ; Termina stringa
    MOV BYTE PTR [SI], 0
    
    ; A capo
    MOV AH, 02h
    MOV DL, 0Dh
    INT 21h
    MOV DL, 0Ah
    INT 21h
    
    POP SI
    RET
read_password ENDP
```

### Box Colorato

```assembly
draw_box PROC
    ; DH = row, DL = col
    ; CH = height, CL = width
    ; BL = color attribute
    
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    
    ; Posiziona cursore
    MOV AH, 02h
    MOV BH, 0
    INT 10h
    
    ; Salva posizione iniziale
    PUSH DX
    
    ; Top border
    MOV AL, 0C9h            ; ╔ (codepage 437)
    CALL draw_char
    MOV AL, 0CDh            ; ═
    PUSH CX
    XOR CH, CH
    DEC CL
    CALL draw_multiple
    POP CX
    MOV AL, 0BBh            ; ╗
    CALL draw_char
    
    ; Middle rows
    POP DX
    PUSH DX
    INC DH
    PUSH CX
    DEC CH
    
middle_loop:
    PUSH DX
    MOV AH, 02h
    MOV BH, 0
    INT 10h
    
    MOV AL, 0BAh            ; ║
    CALL draw_char
    MOV AL, ' '
    PUSH CX
    XOR CH, CH
    DEC CL
    CALL draw_multiple
    POP CX
    MOV AL, 0BAh            ; ║
    CALL draw_char
    
    POP DX
    INC DH
    LOOP middle_loop
    
    POP CX
    
    ; Bottom border
    MOV AH, 02h
    MOV BH, 0
    INT 10h
    
    MOV AL, 0C8h            ; ╚
    CALL draw_char
    MOV AL, 0CDh            ; ═
    PUSH CX
    XOR CH, CH
    DEC CL
    CALL draw_multiple
    POP CX
    MOV AL, 0BCh            ; ╝
    CALL draw_char
    
    POP DX
    POP DX
    POP CX
    POP BX
    POP AX
    RET

draw_char:
    ; AL = char, BL = attr
    MOV AH, 09h
    MOV BH, 0
    MOV CX, 1
    INT 10h
    ; Avanza cursore
    PUSH AX
    MOV AH, 03h
    MOV BH, 0
    INT 10h                 ; DH=row, DL=col
    INC DL
    MOV AH, 02h
    INT 10h
    POP AX
    RET

draw_multiple:
    ; AL = char, BL = attr, CL = count
    PUSH CX
    XOR CH, CH
draw_mult_loop:
    CALL draw_char
    LOOP draw_mult_loop
    POP CX
    RET
    
draw_box ENDP
```

## Best Practices

### 1. Usa BIOS per Portabilità

```assembly
✓ Portatile (BIOS):
    MOV AH, 00h
    INT 16h

✗ Non portatile (accesso diretto hardware):
    IN AL, 60h              ; Specifico IBM PC
```

### 2. Gestisci Tasti Speciali

```assembly
✓ Completo:
    MOV AH, 00h
    INT 16h
    CMP AL, 0               ; Tasto speciale?
    JE check_scan_code
    ; AL = ASCII normale
    RET
check_scan_code:
    ; AH = scan code (F1-F12, arrow, ecc.)
```

### 3. Salva/Ripristina Stato Video

```assembly
✓ Salva stato:
save_video_state:
    ; Salva modo video
    MOV AH, 0Fh
    INT 10h                 ; AL = mode
    MOV old_mode, AL
    
    ; Salva posizione cursore
    MOV AH, 03h
    MOV BH, 0
    INT 10h                 ; DH=row, DL=col
    MOV old_cursor, DX
    RET

restore_video_state:
    ; Ripristina modo
    MOV AH, 00h
    MOV AL, old_mode
    INT 10h
    
    ; Ripristina cursore
    MOV AH, 02h
    MOV BH, 0
    MOV DX, old_cursor
    INT 10h
    RET
```

## Esercizi Pratici

1. Scrivi programma che legge password e verifica (senza mostrare caratteri)
2. Implementa editor di testo semplice (max 10 righe)
3. Crea menu colorato con frecce per selezione
4. Stampa tabella moltiplicazione colorata
5. Scrivi gioco "indovina numero" con feedback colorato

---

**Prossimo argomento:** [File I/O con DOS](03_file_io.md)
