# Quiz Modulo 6 - Input/Output e Interruzioni

## Domande

### 1. Quale istruzione si usa per invocare un'interruzione software?
a) CALL  
b) INT  
c) JMP  
d) INTR  

### 2. Dove si trova l'Interrupt Vector Table (IVT)?
a) Segmento FFFFh  
b) Primi 1024 byte memoria (0000:0000h - 0000:03FFh)  
c) Segmento di codice  
d) Stack  

### 3. Quanti byte occupa ogni vettore nella IVT?
a) 2 byte  
b) 4 byte  
c) 8 byte  
d) 16 byte  

### 4. Quale differenza principale tra RET e IRET?
a) IRET ripristina FLAGS, RET no  
b) IRET è più veloce  
c) RET ripristina FLAGS, IRET no  
d) Nessuna differenza  

### 5. Quale funzione INT 21h per leggere carattere CON echo?
a) AH = 00h  
b) AH = 01h  
c) AH = 07h  
d) AH = 08h  

### 6. Quale funzione INT 21h per leggere carattere SENZA echo e SENZA gestire Ctrl+C?
a) AH = 01h  
b) AH = 06h (DL = 0FFh)  
c) AH = 07h  
d) AH = 08h  

### 7. Quale carattere termina stringa con INT 21h/09h (Write String)?
a) NUL (00h)  
b) '$' (24h)  
c) CR (0Dh)  
d) LF (0Ah)  

### 8. Quale interruzione BIOS per funzioni video?
a) INT 10h  
b) INT 13h  
c) INT 16h  
d) INT 21h  

### 9. Quale funzione INT 16h per leggere tasto (con attesa)?
a) AH = 00h  
b) AH = 01h  
c) AH = 02h  
d) AH = 10h  

### 10. Quale valore in AL se tasto speciale (F1-F12, frecce) con INT 16h/00h?
a) AL = 0  
b) AL = 0FFh  
c) AL = scan code  
d) AL = 1  

### 11. Quale funzione INT 10h per stampare carattere con attributo colore?
a) AH = 02h  
b) AH = 09h  
c) AH = 0Eh  
d) AH = 13h  

### 12. Nell'attributo video (modalità testo), qual è il bit per Blink?
a) Bit 0  
b) Bit 3  
c) Bit 7  
d) Bit 15  

### 13. Quale funzione INT 21h per creare nuovo file?
a) AH = 3Ch  
b) AH = 3Dh  
c) AH = 3Eh  
d) AH = 3Fh  

### 14. Quale funzione INT 21h per aprire file esistente?
a) AH = 3Ch  
b) AH = 3Dh  
c) AH = 3Eh  
d) AH = 40h  

### 15. Quale funzione INT 21h per chiudere file?
a) AH = 3Ch  
b) AH = 3Dh  
c) AH = 3Eh  
d) AH = 3Fh  

### 16. Quale valore in AL per aprire file in sola lettura (INT 21h/3Dh)?
a) AL = 0  
b) AL = 1  
c) AL = 2  
d) AL = 3  

### 17. Dopo INT 21h/3Fh (Read File), cosa indica AX = 0?
a) Errore  
b) Fine file (EOF)  
c) File vuoto  
d) Nessun byte richiesto  

### 18. Quale funzione INT 21h/42h (Seek) per posizionarsi alla fine file?
a) AL = 0  
b) AL = 1  
c) AL = 2  
d) AL = 3  

### 19. In un'ISR hardware, cosa DEVE essere inviato al PIC prima di IRET?
a) NOP  
b) STI  
c) EOI (20h a porta 20h)  
d) Nulla  

### 20. Quale funzione DOS per installare nuovo vettore interruzione?
a) INT 21h/AH = 25h  
b) INT 21h/AH = 35h  
c) INT 21h/AH = 31h  
d) INT 21h/AH = 4Ch  

---

## Soluzioni

### 1. Risposta: **b) INT**
**Spiegazione**: L'istruzione `INT n` invoca interruzione software numero `n`. Esempio: `INT 21h` chiama servizi DOS.

---

### 2. Risposta: **b) Primi 1024 byte memoria (0000:0000h - 0000:03FFh)**
**Spiegazione**: IVT occupa primi 1 KB di RAM. 256 vettori × 4 byte = 1024 byte.

---

### 3. Risposta: **b) 4 byte**
**Spiegazione**: Ogni vettore contiene:
- 2 byte: offset ISR
- 2 byte: segmento ISR

Indirizzo fisico IVT per INT n = n × 4.

---

### 4. Risposta: **a) IRET ripristina FLAGS, RET no**
**Spiegazione**:
- **RET**: `POP IP` (o `POP IP, POP CS` per RETF)
- **IRET**: `POP IP, POP CS, POPF` (ripristina anche FLAGS)

IRET obbligatorio per ISR!

---

### 5. Risposta: **b) AH = 01h**
**Spiegazione**:
```assembly
MOV AH, 01h
INT 21h
; AL = carattere letto, visualizzato (echo)
```
Gestisce Ctrl+C (termina programma).

---

### 6. Risposta: **c) AH = 07h**
**Spiegazione**:
- **01h**: echo, gestisce Ctrl+C
- **06h/DL=FFh**: no echo, no wait, no Ctrl+C
- **07h**: no echo, wait, NO Ctrl+C ✓
- **08h**: no echo, wait, gestisce Ctrl+C

---

### 7. Risposta: **b) '$' (24h)**
**Spiegazione**:
```assembly
.DATA
    msg DB 'Hello$'
.CODE
    LEA DX, msg
    MOV AH, 09h
    INT 21h             ; Stampa fino '$'
```
**Non** NUL (00h) come in C!

---

### 8. Risposta: **a) INT 10h**
**Spiegazione**:
- **INT 10h**: Video BIOS (mode, cursor, print)
- **INT 13h**: Disk BIOS
- **INT 16h**: Keyboard BIOS
- **INT 21h**: DOS services

---

### 9. Risposta: **a) AH = 00h**
**Spiegazione**:
```assembly
MOV AH, 00h
INT 16h
; AL = ASCII, AH = scan code
```
- **00h**: read (wait) ✓
- **01h**: check (no wait)
- **02h**: get shift status

---

### 10. Risposta: **a) AL = 0**
**Spiegazione**:
Tasti speciali (F1-F12, frecce, ecc.):
- **AL = 0** (nessun ASCII)
- **AH = scan code** (esempio: F1 = 3Bh, Arrow Up = 48h)

```assembly
MOV AH, 00h
INT 16h
CMP AL, 0
JE special_key      ; Tasto speciale
; AL != 0: tasto normale
```

---

### 11. Risposta: **b) AH = 09h**
**Spiegazione**:
```assembly
MOV AH, 09h
MOV AL, 'A'         ; Carattere
MOV BH, 0           ; Pagina
MOV BL, 0Eh         ; Attributo (giallo su nero)
MOV CX, 1           ; Ripetizioni
INT 10h
```
**0Eh**: teletype (avanza cursore, no colore).

---

### 12. Risposta: **c) Bit 7**
**Spiegazione**:
```
Attributo byte:
  7 6 5 4 3 2 1 0
 ┌─┬─────┬─┬─────┐
 │B│ BGR │I│ BGR │
 └─┴─────┴─┴─────┘
  │   │   │   └─ Foreground (colore carattere)
  │   │   └───── Intensity (luminoso)
  │   └───────── Background
  └───────────── Blink (lampeggiante)
```
Bit 7 = 1: carattere lampeggia.

---

### 13. Risposta: **a) AH = 3Ch**
**Spiegazione**:
```assembly
MOV AH, 3Ch         ; Create File
MOV CX, 0           ; Attributo normale
LEA DX, filename
INT 21h
; CF=0: AX = handle
```
**Attenzione**: tronca file se esiste!

---

### 14. Risposta: **b) AH = 3Dh**
**Spiegazione**:
```assembly
MOV AH, 3Dh         ; Open File
MOV AL, 0           ; Read-only
LEA DX, filename
INT 21h
; CF=0: AX = handle
```
- AL=0: read, AL=1: write, AL=2: read/write

---

### 15. Risposta: **c) AH = 3Eh**
**Spiegazione**:
```assembly
MOV AH, 3Eh
MOV BX, file_handle
INT 21h
; CF=0: successo
```
**SEMPRE** chiudere file prima di uscire!

---

### 16. Risposta: **a) AL = 0**
**Spiegazione**:
Access mode (AL):
- **0**: Read-only ✓
- **1**: Write-only
- **2**: Read/Write

```assembly
MOV AH, 3Dh
MOV AL, 0           ; Sola lettura
INT 21h
```

---

### 17. Risposta: **b) Fine file (EOF)**
**Spiegazione**:
```assembly
MOV AH, 3Fh
MOV BX, handle
MOV CX, 100         ; Leggi 100 byte
LEA DX, buffer
INT 21h
; AX = byte letti effettivamente
; AX = 0 → EOF
; CF = 1 → errore
```

---

### 18. Risposta: **c) AL = 2**
**Spiegazione**:
Origin (AL):
- **0**: Beginning (inizio file)
- **1**: Current (posizione corrente)
- **2**: End (fine file) ✓

```assembly
; Determina dimensione file
MOV AH, 42h
MOV AL, 2           ; Fine
MOV BX, handle
XOR CX, CX          ; Offset = 0
XOR DX, DX
INT 21h
; DX:AX = dimensione file
```

---

### 19. Risposta: **c) EOI (20h a porta 20h)**
**Spiegazione**:
ISR hardware **DEVE** inviare EOI (End Of Interrupt) al PIC:
```assembly
hardware_isr PROC FAR
    ; ... gestione interruzione ...
    
    MOV AL, 20h
    OUT 20h, AL         ; EOI al PIC Master
    IRET
hardware_isr ENDP
```
Senza EOI, PIC blocca altre interruzioni stesso livello!

**Per IRQ 8-15 (slave PIC)**:
```assembly
    MOV AL, 20h
    OUT 0A0h, AL        ; Slave
    OUT 20h, AL         ; Master
```

---

### 20. Risposta: **a) INT 21h/AH = 25h**
**Spiegazione**:
- **25h**: Set Interrupt Vector (installa)
- **35h**: Get Interrupt Vector (leggi)

```assembly
; Salva vecchio vettore
MOV AX, 3508h       ; Get INT 08h
INT 21h
MOV old_seg, ES
MOV old_off, BX

; Installa nuovo
MOV AX, 2508h       ; Set INT 08h
LEA DX, my_isr
INT 21h
```

**31h**: Terminate and Stay Resident (TSR)  
**4Ch**: Exit program

---

## Riepilogo Punteggi

- **18-20 corrette**: Eccellente! Padronanza completa di I/O e interruzioni
- **15-17 corrette**: Ottimo! Buona comprensione, rivedere dettagli
- **12-14 corrette**: Buono. Approfondire interruzioni hardware e ISR
- **9-11 corrette**: Sufficiente. Ripassare funzioni INT 21h, INT 10h, INT 16h
- **< 9 corrette**: Insufficiente. Studiare approfonditamente tutto il modulo

## Concetti Chiave da Ripassare

### Se hai sbagliato domande 1-4:
- Rileggi [Interruzioni e IVT](modulo6_01_interruzioni.md)
- Studia differenza INT/IRET
- Esercitati con lettura/scrittura IVT

### Se hai sbagliato domande 5-7:
- Rileggi [I/O Tastiera (DOS)](modulo6_02_io_tastiera_video.md#int-21h---dos-keyboardscreen)
- Confronta AH=01h vs 06h vs 07h vs 08h
- Pratica con input tastiera

### Se hai sbagliato domande 8-12:
- Rileggi [I/O Video BIOS](modulo6_02_io_tastiera_video.md#int-10h---bios-video)
- Studia attributi video e colori
- Esercitati con INT 10h/09h, INT 16h/00h

### Se hai sbagliato domande 13-18:
- Rileggi [File I/O](modulo6_03_file_io.md)
- Studia ciclo: create/open → read/write → close
- Pratica con esempi file I/O

### Se hai sbagliato domande 19-20:
- Rileggi [ISR Personalizzate](modulo6_04_isr_custom.md)
- Studia installazione vettori (INT 21h/25h, 35h)
- Impara EOI al PIC
- Esercitati con ISR semplici

## Esercizi Consigliati

1. **I/O Tastiera**: Scrivi programma menu con gestione frecce (INT 16h/00h)
2. **I/O Video**: Crea box colorato con testo (INT 10h/09h)
3. **File I/O**: Implementa `wc` (word count): conta righe, parole, caratteri file
4. **ISR**: Hook INT 21h per contare chiamate DOS
5. **Completo**: Editor testo semplice (10 righe, salvataggio su file)

---

**Congratulazioni!** Hai completato il **Modulo 6**!

**Prossimo modulo**: [Modulo 7 - Ottimizzazione e Tecniche Avanzate](../README.md#modulo-7)
