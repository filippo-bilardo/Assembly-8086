# Interrupt Service Routines Personalizzate

## Introduzione

Creare **ISR (Interrupt Service Routine) personalizzate** permette di estendere il sistema, intercettare interruzioni e implementare driver. Questo modulo copre installazione, sviluppo e best practices per ISR sicure.

## Quando Creare ISR Personalizzate

### Casi d'Uso

1. **Hook Interruzioni Esistenti**: intercettare INT 21h, INT 10h, ecc.
2. **Gestione Hardware**: driver per dispositivi personalizzati
3. **TSR (Terminate and Stay Resident)**: utility residenti in memoria
4. **Debugging**: tracciare chiamate sistema
5. **Emulazione**: simulare hardware assente

### Rischi

⚠️ ISR errate possono:
- **Crashare** il sistema
- **Corrompere** dati
- **Bloccare** il computer
- **Perdere** interruzioni hardware

## Anatomia ISR

### Struttura Minima

```assembly
my_isr PROC FAR
    ; 1. SALVA REGISTRI
    PUSH AX
    PUSH BX
    ; ... altri registri usati ...
    
    ; 2. SETUP SEGMENTI (se necessario)
    PUSH DS
    MOV AX, @DATA
    MOV DS, AX
    
    ; 3. CORPO ISR
    ; ... gestione interruzione ...
    
    ; 4. RIPRISTINA REGISTRI
    POP DS
    POP BX
    POP AX
    
    ; 5. RITORNO
    IRET                    ; NON RET!
my_isr ENDP
```

### ISR con Chain (Catena)

Se vuoi **eseguire anche vecchia ISR**:

```assembly
my_chained_isr PROC FAR
    PUSH AX
    PUSH BX
    PUSH DS
    
    MOV AX, @DATA
    MOV DS, AX
    
    ; Pre-processing
    ; ... codice prima vecchia ISR ...
    
    POP DS
    POP BX
    POP AX
    
    ; Chiama vecchia ISR (jump indiretto FAR)
    JMP DWORD PTR CS:[old_isr_vector]
    ; NON USARE IRET QUI!
my_chained_isr ENDP

.DATA
    old_isr_vector DD ?     ; Offset:Segment (4 byte)
```

**Oppure post-processing**:
```assembly
my_isr_post PROC FAR
    ; Salva registri
    PUSHF                   ; Simula INT: salva FLAGS
    
    ; Chiama vecchia ISR
    CALL DWORD PTR CS:[old_isr_vector]
    ; Vecchia ISR esegue IRET, ritorna qui
    
    ; Post-processing
    PUSH AX
    PUSH DS
    MOV AX, @DATA
    MOV DS, AX
    
    ; ... codice dopo vecchia ISR ...
    
    POP DS
    POP AX
    
    IRET
my_isr_post ENDP
```

## Installazione ISR

### Metodo 1: Accesso Diretto IVT (Non Raccomandato)

```assembly
install_direct PROC
    PUSH ES
    
    ; Leggi vecchio vettore
    XOR AX, AX
    MOV ES, AX              ; ES = 0 (IVT)
    
    MOV BX, int_num
    SHL BX, 2               ; BX = int_num × 4
    
    ; Salva vecchio vettore
    MOV AX, ES:[BX]         ; Offset
    MOV old_isr_off, AX
    MOV AX, ES:[BX+2]       ; Segmento
    MOV old_isr_seg, AX
    
    ; Scrivi nuovo vettore
    LEA AX, my_isr
    MOV ES:[BX], AX         ; Offset
    MOV AX, SEG my_isr
    MOV ES:[BX+2], AX       ; Segmento
    
    POP ES
    RET
install_direct ENDP

.DATA
    int_num EQU 08h         ; Esempio: INT 08h (timer)
    old_isr_off DW ?
    old_isr_seg DW ?
```

**Problemi**:
- Race condition (interruzione può arrivare durante installazione)
- Richiede CLI/STI

### Metodo 2: DOS Get/Set Vector (Raccomandato)

```assembly
install_dos PROC
    PUSH ES
    
    ; Leggi vecchio vettore
    MOV AH, 35h             ; Get Interrupt Vector
    MOV AL, int_num
    INT 21h
    ; ES:BX = vecchio handler
    
    MOV old_isr_seg, ES
    MOV old_isr_off, BX
    
    ; Installa nuovo vettore
    PUSH DS
    MOV AH, 25h             ; Set Interrupt Vector
    MOV AL, int_num
    LEA DX, my_isr
    MOV DS, DX
    SHR DS, 4               ; DS = segmento
    AND DX, 0Fh             ; DX = offset
    INT 21h
    POP DS
    
    POP ES
    RET
install_dos ENDP

restore_dos PROC
    PUSH DS
    
    ; Ripristina vecchio vettore
    MOV AH, 25h
    MOV AL, int_num
    MOV DX, old_isr_off
    MOV DS, old_isr_seg
    INT 21h
    
    POP DS
    RET
restore_dos ENDP
```

**Vantaggi**:
- Atomico (DOS disabilita interruzioni)
- Portabile
- Sicuro

### Metodo 2 Semplificato

```assembly
install_simple PROC
    ; Salva vecchio vettore
    MOV AX, 3500h + int_num ; Get Vector
    INT 21h
    MOV old_isr_seg, ES
    MOV old_isr_off, BX
    
    ; Installa nuovo
    MOV AX, 2500h + int_num ; Set Vector
    LEA DX, my_isr
    INT 21h
    RET
install_simple ENDP

restore_simple PROC
    PUSH DS
    MOV AX, 2500h + int_num
    MOV DX, old_isr_off
    MOV DS, old_isr_seg
    INT 21h
    POP DS
    RET
restore_simple ENDP
```

## Esempio 1: Hook INT 21h (DOS Logger)

```assembly
.MODEL SMALL
.STACK 100h

.DATA
    old_21h_seg DW ?
    old_21h_off DW ?
    
    log_count DW 0
    log_msg DB 'INT 21h chiamata: $'

.CODE
main PROC
    MOV AX, @DATA
    MOV DS, AX
    
    ; Installa hook
    CALL install_int21_hook
    
    ; Test: chiama DOS
    MOV AH, 02h
    MOV DL, 'A'
    INT 21h                 ; Trigger hook
    
    ; Ripristina
    CALL restore_int21
    
    ; Stampa statistiche
    LEA DX, log_msg
    MOV AH, 09h
    INT 21h
    
    MOV AX, log_count
    CALL print_number
    
    MOV AH, 4Ch
    INT 21h
main ENDP

install_int21_hook PROC
    MOV AX, 3521h           ; Get INT 21h
    INT 21h
    MOV old_21h_seg, ES
    MOV old_21h_off, BX
    
    MOV AX, 2521h           ; Set INT 21h
    LEA DX, my_int21_handler
    INT 21h
    RET
install_int21_hook ENDP

restore_int21 PROC
    PUSH DS
    MOV AX, 2521h
    MOV DX, old_21h_off
    MOV DS, old_21h_seg
    INT 21h
    POP DS
    RET
restore_int21 ENDP

my_int21_handler PROC FAR
    PUSH AX
    PUSH DS
    
    ; Setup DS
    MOV AX, SEG log_count
    MOV DS, AX
    
    ; Incrementa contatore
    INC log_count
    
    POP DS
    POP AX
    
    ; Chain a vecchio handler
    JMP DWORD PTR CS:[old_21h_off]
my_int21_handler ENDP

print_number PROC
    ; AX = numero da stampare (semplificato)
    ; ... implementazione omessa ...
    RET
print_number ENDP

END main
```

## Esempio 2: Timer Personalizzato (INT 08h)

```assembly
.MODEL SMALL
.STACK 100h

.DATA
    old_timer_seg DW ?
    old_timer_off DW ?
    
    tick_count DD 0         ; Contatore tick
    seconds DW 0            ; Secondi trascorsi
    
    TICKS_PER_SEC EQU 18    ; Timer tick ~18.2 Hz

.CODE
main PROC
    MOV AX, @DATA
    MOV DS, AX
    
    ; Installa timer handler
    CALL install_timer
    
    ; Loop: stampa secondi ogni secondo
    MOV CX, 10              ; 10 secondi
    
loop_wait:
    MOV AX, seconds
wait_change:
    CMP AX, seconds
    JE wait_change          ; Attendi cambio
    
    ; Stampa secondi
    CALL print_seconds
    
    LOOP loop_wait
    
    ; Ripristina
    CALL restore_timer
    
    MOV AH, 4Ch
    INT 21h
main ENDP

install_timer PROC
    CLI                     ; Disabilita interruzioni
    
    MOV AX, 3508h           ; Get INT 08h
    INT 21h
    MOV old_timer_seg, ES
    MOV old_timer_off, BX
    
    MOV AX, 2508h           ; Set INT 08h
    LEA DX, my_timer_isr
    INT 21h
    
    STI                     ; Riabilita
    RET
install_timer ENDP

restore_timer PROC
    CLI
    PUSH DS
    MOV AX, 2508h
    MOV DX, old_timer_off
    MOV DS, old_timer_seg
    INT 21h
    POP DS
    STI
    RET
restore_timer ENDP

my_timer_isr PROC FAR
    PUSH AX
    PUSH DX
    PUSH DS
    
    MOV AX, SEG tick_count
    MOV DS, AX
    
    ; Incrementa tick
    ADD WORD PTR tick_count, 1
    ADC WORD PTR tick_count+2, 0
    
    ; Controlla se passato 1 secondo
    MOV AX, WORD PTR tick_count
    MOV DX, WORD PTR tick_count+2
    
    CMP DX, 0
    JNE check_seconds       ; Overflow?
    CMP AX, TICKS_PER_SEC
    JB timer_done
    
check_seconds:
    ; Reset tick_count
    SUB WORD PTR tick_count, TICKS_PER_SEC
    SBB WORD PTR tick_count+2, 0
    
    ; Incrementa secondi
    INC seconds
    
timer_done:
    POP DS
    POP DX
    POP AX
    
    ; Chain a vecchio handler
    JMP DWORD PTR CS:[old_timer_off]
my_timer_isr ENDP

print_seconds PROC
    ; Stampa valore 'seconds' (implementazione omessa)
    RET
print_seconds ENDP

END main
```

## Esempio 3: Keyboard Filter (INT 09h)

```assembly
; ISR che converte automaticamente 'a'-'z' in maiuscolo

.DATA
    old_kb_seg DW ?
    old_kb_off DW ?
    
    caps_mode DB 0          ; 0 = off, 1 = on

.CODE
install_kb_filter PROC
    CLI
    MOV AX, 3509h           ; Get INT 09h
    INT 21h
    MOV old_kb_seg, ES
    MOV old_kb_off, BX
    
    MOV AX, 2509h           ; Set INT 09h
    LEA DX, kb_filter_isr
    INT 21h
    STI
    RET
install_kb_filter ENDP

kb_filter_isr PROC FAR
    PUSH AX
    PUSH BX
    PUSH DS
    
    MOV AX, SEG caps_mode
    MOV DS, AX
    
    ; Leggi scancode
    IN AL, 60h              ; AL = scancode
    
    ; Controlla se make code (bit 7 = 0)
    TEST AL, 80h
    JNZ kb_break_code
    
    ; Controlla se tasto lettera (scancode 10h-19h, 1Eh-26h, 2Ch-32h)
    ; (implementazione semplificata)
    
    ; Forza caps lock nel BIOS keyboard buffer
    ; (modifica buffer tastiera BIOS a 0040:001Eh)
    ; ... implementazione complessa omessa ...
    
kb_break_code:
    POP DS
    POP BX
    POP AX
    
    ; Chain
    JMP DWORD PTR CS:[old_kb_off]
kb_filter_isr ENDP
```

## Esempio 4: Software Watchdog (INT 1Ch)

```assembly
; INT 1Ch: chiamato da INT 08h (timer), 18.2 volte/sec

.DATA
    old_1ch_seg DW ?
    old_1ch_off DW ?
    
    watchdog_counter DW 182 ; Reset ogni ~10 secondi
    watchdog_active DB 1

.CODE
install_watchdog PROC
    MOV AX, 351Ch           ; Get INT 1Ch
    INT 21h
    MOV old_1ch_seg, ES
    MOV old_1ch_off, BX
    
    MOV AX, 251Ch           ; Set INT 1Ch
    LEA DX, watchdog_isr
    INT 21h
    RET
install_watchdog ENDP

watchdog_isr PROC FAR
    PUSH AX
    PUSH DS
    
    MOV AX, SEG watchdog_counter
    MOV DS, AX
    
    ; Decrementa contatore
    DEC watchdog_counter
    JNZ wd_done
    
    ; Timeout!
    CMP watchdog_active, 0
    JE wd_reset
    
    ; Azione watchdog (es. beep, reset, log)
    MOV AH, 02h
    MOV DL, 07h             ; BEL (beep)
    INT 21h
    
wd_reset:
    MOV watchdog_counter, 182   ; Reset 10 sec
    
wd_done:
    POP DS
    POP AX
    IRET                    ; INT 1Ch non chain
watchdog_isr ENDP

; Programma principale chiama periodicamente:
pet_watchdog PROC
    MOV watchdog_counter, 182
    RET
pet_watchdog ENDP
```

## TSR (Terminate and Stay Resident)

### Creazione TSR

```assembly
.MODEL TINY                 ; .COM program
.CODE
ORG 100h                    ; .COM start

start:
    JMP install_tsr         ; Salta a installazione

; ===== PARTE RESIDENTE =====
resident_start:

old_int_seg DW ?
old_int_off DW ?

my_tsr_isr PROC FAR
    ; ISR residente
    PUSH AX
    
    ; ... codice ISR ...
    
    POP AX
    JMP DWORD PTR CS:[old_int_off]
my_tsr_isr ENDP

resident_end:

; ===== PARTE INIZIALIZZAZIONE (NON RESIDENTE) =====
install_tsr:
    ; Controlla se già installato
    ; ... check omesso ...
    
    ; Installa ISR
    MOV AX, 3508h           ; Esempio: INT 08h
    INT 21h
    MOV old_int_seg, ES
    MOV old_int_off, BX
    
    MOV AX, 2508h
    LEA DX, my_tsr_isr
    INT 21h
    
    ; Stampa messaggio
    LEA DX, install_msg
    MOV AH, 09h
    INT 21h
    
    ; Termina e resta residente
    MOV AH, 31h             ; Keep Process
    MOV AL, 0               ; Exit code
    LEA DX, resident_end    ; DX = paragrafi da mantenere
    ADD DX, 15
    SHR DX, 4               ; Converti byte → paragrafi
    INT 21h                 ; NON RITORNA!

install_msg DB 'TSR installato.$'

END start
```

### Disinstallazione TSR (Complessa!)

```assembly
uninstall_tsr PROC
    ; Controlla se TSR è ultimo nella catena
    MOV AX, 3508h
    INT 21h
    ; Confronta ES:BX con my_tsr_isr
    
    ; Se non ultimo, NON disinstallare (pericoloso!)
    ; ...
    
    ; Ripristina vettore
    PUSH DS
    MOV AX, 2508h
    MOV DX, old_int_off
    MOV DS, old_int_seg
    INT 21h
    POP DS
    
    ; Libera memoria (INT 21h/49h)
    ; ... complesso, omesso ...
    
    RET
uninstall_tsr ENDP
```

## Regole Sicurezza ISR

### 1. Salva TUTTI i Registri Usati

```assembly
✓ Completo:
my_isr:
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI
    PUSH DS
    PUSH ES
    ; ... codice ...
    POP ES
    POP DS
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    IRET

✗ Incompleto:
my_isr:
    ; Modifica AX senza salvare!
    MOV AX, 100
    IRET                    ; BUG: AX corrotto!
```

### 2. ISR Deve Essere VELOCE

```assembly
✓ Veloce:
timer_isr:
    INC tick_count
    IRET

✗ Lento:
timer_isr:
    ; Loop lungo blocca sistema!
    MOV CX, 1000
loop1:
    PUSH CX
    MOV CX, 1000
loop2:
    LOOP loop2
    POP CX
    LOOP loop1
    IRET                    ; Sistema bloccato!
```

### 3. NON Usare DOS in ISR Hardware

```assembly
✗ PERICOLOSO:
kb_isr:
    ; DOS non è rientrante!
    MOV AH, 02h
    MOV DL, 'A'
    INT 21h                 ; CRASH se DOS già in uso!
    IRET
```

**Eccezione**: INT 1Ch, chiamata da INT 08h, può usare DOS (vedi BIOS).

### 4. EOI Obbligatorio per Hardware

```assembly
✓ EOI:
hardware_isr:
    ; ... gestione ...
    
    MOV AL, 20h
    OUT 20h, AL             ; EOI a PIC
    IRET

✗ Dimenticato:
hardware_isr:
    ; ... gestione ...
    IRET                    ; BUG: PIC bloccato!
```

### 5. CLI/STI con Attenzione

```assembly
✓ Breve:
critical_section:
    CLI
    ; Operazione critica (poche istruzioni)
    INC shared_var
    STI
    RET

✗ Lungo:
    CLI
    ; Blocca interruzioni troppo a lungo!
    CALL complex_function   ; Secondi con INT disabilitati!
    STI
```

### 6. Usa CS: per Dati in ISR

```assembly
✓ CS-relative (TSR):
my_isr:
    INC CS:[counter]        ; Accesso dati in code segment
    IRET

counter DW 0                ; Nello stesso segmento di ISR

✗ DS-relative (può essere sbagliato):
my_isr:
    INC counter             ; DS può puntare altrove!
    IRET
```

## Debugging ISR

### Tecniche

1. **LED diagnostici**: OUT su porte I/O per debug visivo
2. **Beep**: speaker PC (porta 61h, 42h, 43h)
3. **Video diretto**: scrivere in B800:0000 (VGA text)
4. **Log su file** (solo INT 1Ch o simili)
5. **Contatori**: incrementa variabili, leggi dopo

### Esempio: Debug LED

```assembly
debug_isr PROC FAR
    ; Accendi/spegni LED tastiera
    PUSH AX
    
    IN AL, 60h              ; Leggi porta tastiera
    
    ; Toggle Scroll Lock LED
    IN AL, 61h
    XOR AL, 01h
    OUT 61h, AL
    
    POP AX
    IRET
debug_isr ENDP
```

### Esempio: Beep Debug

```assembly
debug_beep PROC
    ; Beep speaker PC
    PUSH AX
    
    IN AL, 61h
    OR AL, 03h
    OUT 61h, AL             ; Abilita speaker
    
    ; Aspetta (delay)
    MOV CX, 0FFFFh
delay_loop:
    LOOP delay_loop
    
    IN AL, 61h
    AND AL, 0FCh
    OUT 61h, AL             ; Disabilita speaker
    
    POP AX
    RET
debug_beep ENDP
```

## Best Practices Riassunto

| Regola | Descrizione |
|--------|-------------|
| **Salva registri** | PUSH/POP tutti i registri usati |
| **IRET, non RET** | IRET ripristina FLAGS |
| **ISR veloce** | Poche istruzioni, nessun loop lungo |
| **No DOS in HW ISR** | DOS non è rientrante |
| **EOI per HW** | Invia EOI (20h) al PIC |
| **CLI/STI brevi** | Non bloccare INT troppo a lungo |
| **Chain se necessario** | JMP a vecchia ISR se serve |
| **Ripristina sempre** | Restore vecchio vettore prima uscire |
| **Controlla installazione** | Verifica se TSR già attivo |
| **CS: per dati** | Usa CS-relative per TSR |

## Esercizi Pratici

1. Scrivi TSR che conta INT 21h chiamate, visualizza con hotkey
2. Implementa screen saver: dopo N secondi inattività, cancella schermo
3. Crea ISR INT 09h che emette beep ad ogni tasto premuto
4. Hook INT 10h per loggare tutte chiamate video
5. TSR orologio: mostra ora in angolo schermo (aggiornamento ogni secondo)

---

**Prossimo argomento:** [Quiz Modulo 6](modulo6_05_quiz.md)
