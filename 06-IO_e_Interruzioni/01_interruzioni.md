# Interruzioni e Interrupt Vector Table

## Introduzione

Le **interruzioni** sono meccanismi fondamentali per gestire eventi hardware e fornire servizi di sistema. Permettono al processore di sospendere temporaneamente l'esecuzione del programma corrente per gestire eventi urgenti.

### Concetti Chiave

- **Interruzione**: segnale che causa la sospensione del programma corrente
- **ISR** (Interrupt Service Routine): procedura che gestisce l'interruzione
- **IVT** (Interrupt Vector Table): tabella degli indirizzi delle ISR
- **INT n**: istruzione per invocare interruzione software
- **IRET**: ritorno da interruzione

## Tipi di Interruzioni

### 1. Interruzioni Hardware

Generate da dispositivi esterni:
- **Timer** (IRQ 0): genera interruzione periodica
- **Tastiera** (IRQ 1): pressione tasto
- **Porta seriale** (IRQ 3, 4): dati ricevuti
- **Disco** (IRQ 6, 14, 15): operazione completata
- **Mouse** (IRQ 12): movimento/click

**Caratteristiche**:
- Asincrone (imprevedibili)
- Non mascherabili (NMI) o mascherabili
- Priorità hardware

### 2. Interruzioni Software

Invocate esplicitamente dal programma con `INT n`:
- **INT 10h**: BIOS Video
- **INT 13h**: BIOS Disk
- **INT 16h**: BIOS Keyboard
- **INT 21h**: DOS Services
- **INT 33h**: Mouse Driver

**Caratteristiche**:
- Sincrone (controllate dal programma)
- Usate per chiamare servizi sistema
- Equivalente a chiamata procedura privilegiata

### 3. Eccezioni

Generate dal processore per errori:
- **INT 0**: Division by Zero
- **INT 1**: Single Step (debug)
- **INT 3**: Breakpoint
- **INT 4**: Overflow

**Caratteristiche**:
- Sincrone
- Indicano condizioni anomale
- Possono essere fatali

## Interrupt Vector Table (IVT)

### Struttura

L'**IVT** si trova nei primi **1024 byte** (0000:0000h - 0000:03FFh) della memoria.

Ogni interruzione (0-255) ha un **vettore** di 4 byte:
- **2 byte**: Offset dell'ISR
- **2 byte**: Segmento dell'ISR

```
Indirizzo fisico IVT = tipo_int × 4

INT 0:  [0000:0000] = offset, [0000:0002] = segmento
INT 1:  [0000:0004] = offset, [0000:0006] = segmento
INT 2:  [0000:0008] = offset, [0000:000A] = segmento
...
INT 21h: [0000:0084] = offset, [0000:0086] = segmento
...
INT FFh: [0000:03FC] = offset, [0000:03FE] = segmento
```

### Lettura Vettore

```assembly
; Leggi vettore INT 21h
get_int21_vector PROC
    PUSH ES
    
    XOR AX, AX
    MOV ES, AX              ; ES = 0 (segmento IVT)
    
    MOV BX, 21h
    SHL BX, 2               ; BX = 21h × 4 = 84h (offset nella IVT)
    
    MOV AX, ES:[BX]         ; AX = offset ISR
    MOV DX, ES:[BX+2]       ; DX = segmento ISR
    ; DX:AX = indirizzo ISR di INT 21h
    
    POP ES
    RET
get_int21_vector ENDP
```

### Modifica Vettore (Pericoloso!)

```assembly
; Installa nuovo handler per INT 08h (timer)
install_timer_handler PROC
    PUSH ES
    PUSH DS
    
    ; Salva vecchio vettore
    MOV AX, 3508h           ; DOS: Get Interrupt Vector (INT 08h)
    INT 21h                 ; ES:BX = vecchio handler
    MOV old_timer_seg, ES
    MOV old_timer_off, BX
    
    ; Installa nuovo vettore
    LEA DX, new_timer_isr   ; DS:DX = nuovo handler
    MOV AX, 2508h           ; DOS: Set Interrupt Vector (INT 08h)
    INT 21h
    
    POP DS
    POP ES
    RET
install_timer_handler ENDP

; Ripristina vecchio handler
restore_timer_handler PROC
    PUSH DS
    
    MOV DX, old_timer_off
    MOV DS, old_timer_seg
    MOV AX, 2508h           ; Ripristina INT 08h
    INT 21h
    
    POP DS
    RET
restore_timer_handler ENDP

.DATA
    old_timer_seg DW ?
    old_timer_off DW ?
```

## Istruzione INT

### Sintassi

```assembly
INT numero_interruzione     ; numero_interruzione = 0..255
```

### Operazione

```assembly
INT n
; Equivalente a:
; 1. PUSHF               ; Salva flag
; 2. CLI                 ; Disabilita interruzioni
; 3. PUSH CS             ; Salva CS
; 4. PUSH IP             ; Salva IP (indirizzo dopo INT)
; 5. Leggi vettore da IVT: indirizzo = [0000:n×4]
; 6. CS:IP = indirizzo ISR
; 7. Esegui ISR
```

**Stato stack dopo INT**:
```
    ┌──────────┐
    │ FLAGS    │ ← [SP+4]
    ├──────────┤
    │ CS       │ ← [SP+2]
    ├──────────┤
    │ IP       │ ← [SP], SP
    └──────────┘
```

### Esempio: Invocare Interruzione

```assembly
; Chiama INT 10h (BIOS Video) per stampare carattere
    MOV AH, 0Eh             ; Funzione: Teletype output
    MOV AL, 'A'             ; Carattere da stampare
    MOV BH, 0               ; Pagina video
    INT 10h                 ; Invoca BIOS Video
    ; Carattere 'A' stampato sullo schermo
```

## Istruzione IRET

### Sintassi

```assembly
IRET            ; Interrupt RETurn
```

### Operazione

```assembly
IRET
; Equivalente a:
; POP IP                 ; Ripristina IP
; POP CS                 ; Ripristina CS
; POPF                   ; Ripristina FLAGS (include IF)
```

**Nota**: IRET ripristina **FLAGS** (incluso Interrupt Flag), mentre RET no.

### Differenza RET vs IRET

| Istruzione | Stack | Ripristina FLAGS | Uso |
|------------|-------|------------------|-----|
| RET | POP IP | No | Procedure normali |
| RETF | POP IP, POP CS | No | Procedure FAR |
| IRET | POP IP, POP CS, POPF | Sì | Interrupt Service Routine |

## Interrupt Service Routine (ISR)

### Struttura Tipica

```assembly
my_isr PROC FAR
    ; 1. SALVA CONTESTO (registri usati)
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI
    PUSH DS
    PUSH ES
    
    ; 2. SETUP SEGMENTI DATI (se necessario)
    MOV AX, @DATA
    MOV DS, AX
    
    ; 3. CORPO ISR
    ; ... gestione interruzione ...
    
    ; 4. ACK INTERRUPT (solo per hardware!)
    ; (es. invia EOI a PIC: OUT 20h, 20h)
    
    ; 5. RIPRISTINA CONTESTO
    POP ES
    POP DS
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    
    ; 6. RITORNO
    IRET                    ; Ripristina CS:IP e FLAGS
my_isr ENDP
```

### Esempio: ISR per Tastiera

```assembly
; ISR personalizzata per INT 09h (tastiera hardware)
keyboard_isr PROC FAR
    PUSH AX
    PUSH BX
    
    ; Leggi scancode da porta tastiera
    IN AL, 60h              ; AL = scancode
    
    ; Elabora scancode
    ; (es. conta pressioni tasti, filtra input, ...)
    
    ; Invia EOI (End Of Interrupt) al PIC
    MOV AL, 20h
    OUT 20h, AL             ; PIC: interruzione gestita
    
    POP BX
    POP AX
    IRET
keyboard_isr ENDP
```

### Regole Importanti ISR

1. **Salva tutti i registri** modificati
2. **Breve esecuzione**: ISR deve essere veloce
3. **Non usare DOS/BIOS** in ISR hardware (non rientranti!)
4. **Invia EOI** al PIC per interruzioni hardware
5. **IRET** invece di RET
6. **CLI/STI**: gestione Interrupt Flag se necessario

## Interrupt Flag (IF)

### Controllo

**IF = 1**: interruzioni hardware **abilitate**  
**IF = 0**: interruzioni hardware **disabilitate** (mascherate)

**Istruzioni**:
```assembly
STI             ; Set Interrupt Flag (IF = 1, abilita)
CLI             ; Clear Interrupt Flag (IF = 0, disabilita)
```

### Uso: Sezione Critica

```assembly
; Sezione critica (non interrompibile)
critical_section PROC
    CLI                     ; Disabilita interruzioni
    
    ; Codice critico (es. aggiornamento strutture condivise)
    INC shared_counter
    MOV shared_flag, 1
    
    STI                     ; Riabilita interruzioni
    RET
critical_section ENDP
```

**Attenzione**: non lasciare interruzioni disabilitate troppo a lungo!

### Pattern Save/Restore IF

```assembly
; Salva stato IF e disabilita
save_and_disable_int PROC
    PUSHF                   ; Salva FLAGS (include IF)
    CLI                     ; Disabilita
    RET
save_and_disable_int ENDP

; Ripristina stato IF
restore_int PROC
    POPF                    ; Ripristina FLAGS (include IF)
    RET
restore_int ENDP
```

## PIC - Programmable Interrupt Controller

### 8259 PIC

Il **8259 PIC** gestisce interruzioni hardware (IRQ 0-15).

**Porte I/O**:
- **PIC Master**: 20h (command), 21h (data)
- **PIC Slave**: A0h (command), A1h (data) [PC AT, 286+]

### EOI - End Of Interrupt

Dopo gestire interruzione hardware, **DEVI** inviare EOI al PIC:

```assembly
; Invia EOI al PIC
    MOV AL, 20h             ; Comando EOI
    OUT 20h, AL             ; Porta comando PIC Master
```

**Per IRQ 8-15** (slave PIC, PC AT):
```assembly
; Invia EOI a entrambi i PIC
    MOV AL, 20h
    OUT 0A0h, AL            ; PIC Slave
    OUT 20h, AL             ; PIC Master
```

### Mascheramento IRQ

**Disabilita IRQ specifico**:
```assembly
; Disabilita IRQ 1 (tastiera)
disable_keyboard_irq PROC
    IN AL, 21h              ; Leggi maschera corrente (PIC Master)
    OR AL, 02h              ; Bit 1 = IRQ 1
    OUT 21h, AL             ; Scrivi maschera
    RET
disable_keyboard_irq ENDP
```

**Abilita IRQ**:
```assembly
; Abilita IRQ 1
enable_keyboard_irq PROC
    IN AL, 21h
    AND AL, 0FDh            ; Azzera bit 1 (11111101b)
    OUT 21h, AL
    RET
enable_keyboard_irq ENDP
```

## Interruzioni DOS (INT 21h)

### Principali Funzioni

INT 21h offre centinaia di funzioni DOS, alcune comuni:

| AH | Funzione | Descrizione |
|----|----------|-------------|
| 01h | Read char with echo | Leggi carattere da tastiera |
| 02h | Write char | Stampa carattere |
| 09h | Write string | Stampa stringa '$'-terminated |
| 0Ah | Buffered input | Input linea |
| 3Ch | Create file | Crea file |
| 3Dh | Open file | Apri file |
| 3Eh | Close file | Chiudi file |
| 3Fh | Read file | Leggi da file |
| 40h | Write file | Scrivi su file |
| 4Ch | Exit program | Termina programma |

### Esempio: Input Carattere

```assembly
; Leggi carattere con echo
    MOV AH, 01h
    INT 21h
    ; AL = carattere letto
```

### Esempio: Stampa Stringa

```assembly
.DATA
    msg DB 'Hello, World!$'    ; Terminata con '$'

.CODE
    LEA DX, msg
    MOV AH, 09h
    INT 21h                     ; Stampa stringa
```

## Interruzioni BIOS (INT 10h, 16h, 13h)

### INT 10h - Video BIOS

**Funzioni comuni**:

| AH | Funzione |
|----|----------|
| 00h | Set video mode |
| 01h | Set cursor shape |
| 02h | Set cursor position |
| 03h | Get cursor position |
| 06h | Scroll up |
| 07h | Scroll down |
| 09h | Write char with attribute |
| 0Eh | Teletype output |
| 13h | Write string |

**Esempio: Stampa carattere colorato**:
```assembly
    MOV AH, 09h             ; Write char + attribute
    MOV AL, 'A'             ; Carattere
    MOV BH, 0               ; Pagina video
    MOV BL, 0Eh             ; Attributo: giallo su nero
    MOV CX, 1               ; Ripetizioni
    INT 10h
```

### INT 16h - Keyboard BIOS

**Funzioni comuni**:

| AH | Funzione |
|----|----------|
| 00h | Read key (wait) |
| 01h | Check key (no wait) |
| 02h | Get shift status |

**Esempio: Leggi tasto**:
```assembly
    MOV AH, 00h
    INT 16h
    ; AL = ASCII char, AH = scan code
```

### INT 13h - Disk BIOS

**Funzioni comuni**:

| AH | Funzione |
|----|----------|
| 00h | Reset disk |
| 02h | Read sectors |
| 03h | Write sectors |
| 08h | Get drive parameters |

**Esempio: Leggi settore**:
```assembly
    MOV AH, 02h             ; Read sectors
    MOV AL, 1               ; Numero settori
    MOV CH, 0               ; Cilindro
    MOV CL, 1               ; Settore
    MOV DH, 0               ; Testina
    MOV DL, 00h             ; Drive A:
    LEA BX, buffer          ; ES:BX = buffer
    INT 13h
    JC disk_error           ; CF = 1 se errore
```

## Best Practices

### 1. Salva Sempre Contesto in ISR

```assembly
✓ Completo:
my_isr:
    PUSH AX
    PUSH BX
    ; ...
    ; codice ISR
    ; ...
    POP BX
    POP AX
    IRET

✗ Dimenticato:
my_isr:
    ; Modifica AX senza salvare!
    MOV AX, 100
    IRET                    ; Programma principale trova AX cambiato!
```

### 2. ISR Breve

```assembly
✓ Veloce:
    ; Segnala evento
    MOV event_flag, 1
    IRET

✗ Lento:
    ; Elaborazione complessa in ISR
    CALL long_processing
    IRET                    ; Blocca altre interruzioni!
```

### 3. Non Usare DOS in ISR Hardware

```assembly
✗ PERICOLOSO:
keyboard_isr:
    ; DOS non è rientrante!
    MOV AH, 02h
    MOV DL, 'A'
    INT 21h                 ; Può crashare se DOS già in uso!
    IRET
```

### 4. Sempre EOI per Hardware

```assembly
✓ Corretto:
timer_isr:
    ; ... gestione ...
    MOV AL, 20h
    OUT 20h, AL             ; EOI
    IRET

✗ Dimenticato EOI:
    ; ... gestione ...
    IRET                    ; PIC bloccato, nessuna altra INT 08h!
```

### 5. Ripristina Vettori Prima di Uscire

```assembly
✓ Cleanup:
main:
    CALL install_my_isr
    ; ... programma ...
    CALL restore_old_isr    ; IMPORTANTE!
    MOV AH, 4Ch
    INT 21h

✗ Memoria persa:
    ; Non ripristina!
    MOV AH, 4Ch
    INT 21h                 ; ISR punta a memoria deallocata!
```

## Esercizi Pratici

1. Scrivi ISR che conta quante volte viene premuto un tasto
2. Implementa timer (INT 08h) che beep ogni secondo
3. Crea ISR INT 09h che converte automaticamente Caps Lock
4. Leggi vettore INT 21h e stampa indirizzo
5. Scrivi programma che disabilita/riabilita tastiera (maschera IRQ 1)

### Soluzione Esercizio 1

```assembly
.MODEL SMALL
.STACK 100h

.DATA
    key_count DW 0
    old_kb_seg DW ?
    old_kb_off DW ?
    msg DB 'Tasti premuti: $'

.CODE
main PROC
    MOV AX, @DATA
    MOV DS, AX
    
    ; Salva vecchio handler INT 09h
    MOV AX, 3509h
    INT 21h
    MOV old_kb_seg, ES
    MOV old_kb_off, BX
    
    ; Installa nuovo handler
    LEA DX, keyboard_counter_isr
    MOV AX, 2509h
    INT 21h
    
    ; Attendi ESC
wait_esc:
    MOV AH, 01h
    INT 21h
    CMP AL, 27              ; ESC?
    JNE wait_esc
    
    ; Ripristina vecchio handler
    MOV DX, old_kb_off
    MOV DS, old_kb_seg
    MOV AX, 2509h
    INT 21h
    
    ; Stampa contatore
    MOV AX, @DATA
    MOV DS, AX
    LEA DX, msg
    MOV AH, 09h
    INT 21h
    
    MOV AX, key_count
    CALL print_number
    
    MOV AH, 4Ch
    INT 21h
main ENDP

; ISR: conta pressioni tasti
keyboard_counter_isr PROC FAR
    PUSH AX
    PUSH DS
    
    MOV AX, @DATA
    MOV DS, AX
    
    ; Leggi scancode
    IN AL, 60h
    
    ; Incrementa se make code (bit 7 = 0)
    TEST AL, 80h
    JNZ kb_break            ; Break code, ignora
    
    INC key_count
    
kb_break:
    ; EOI
    MOV AL, 20h
    OUT 20h, AL
    
    POP DS
    POP AX
    IRET
keyboard_counter_isr ENDP

print_number PROC
    ; AX = numero da stampare (decimale)
    ; (codice omesso per brevità)
    RET
print_number ENDP

END main
```

---

**Prossimo argomento:** [Input/Output Tastiera e Video](modulo6_02_io_tastiera_video.md)
