# Appendice C: Interruzioni BIOS e DOS

## INT 10h - Video BIOS Services

### Funzioni Modalità Video

| AH | Funzione | Input | Output | Descrizione |
|----|----------|-------|--------|-------------|
| **00h** | Set Video Mode | AL = mode | - | Imposta modalità video |
| **0Fh** | Get Video Mode | - | AL = mode, AH = cols, BH = page | Leggi modalità corrente |

**Modalità Video Comuni:**
| Mode | Risoluzione | Colori | Tipo |
|------|-------------|--------|------|
| 00h | 40×25 | 16 | Testo B&W |
| 01h | 40×25 | 16 | Testo |
| 02h | 80×25 | 16 | Testo B&W |
| 03h | 80×25 | 16 | Testo (default) |
| 04h | 320×200 | 4 | Grafica CGA |
| 06h | 640×200 | 2 | Grafica CGA |
| 0Dh | 320×200 | 16 | Grafica EGA |
| 0Eh | 640×200 | 16 | Grafica EGA |
| 10h | 640×350 | 16 | Grafica EGA |
| 12h | 640×480 | 16 | Grafica VGA |
| 13h | 320×200 | 256 | Grafica VGA |

### Funzioni Cursore

| AH | Funzione | Input | Output | Descrizione |
|----|----------|-------|--------|-------------|
| **01h** | Set Cursor Shape | CH = start line, CL = end line | - | Forma cursore |
| **02h** | Set Cursor Position | DH = row, DL = col, BH = page | - | Posiziona cursore |
| **03h** | Get Cursor Position | BH = page | DH = row, DL = col, CX = shape | Leggi posizione |

**Esempi Forma Cursore:**
```assembly
; Cursore normale (linee 6-7)
MOV AH, 01h
MOV CH, 6
MOV CL, 7
INT 10h

; Cursore blocco (linee 0-7)
MOV CH, 0
MOV CL, 7
INT 10h

; Nasconde cursore
MOV CH, 20h             ; Bit 5 = hide
INT 10h
```

### Funzioni Output Caratteri

| AH | Funzione | Input | Output | Descrizione |
|----|----------|-------|--------|-------------|
| **09h** | Write Char+Attr | AL = char, BH = page, BL = attr, CX = count | - | Scrive carattere con attributo |
| **0Ah** | Write Char Only | AL = char, BH = page, CX = count | - | Scrive carattere (mantiene attr) |
| **0Eh** | Teletype Output | AL = char, BH = page, BL = fg color | - | Scrive con avanzamento |
| **13h** | Write String | ES:BP → string, CX = length, DH/DL = pos, AL = mode, BL = attr | - | Scrive stringa |

**Mode per INT 10h/13h:**
- Bit 0: aggiorna cursore
- Bit 1: string contiene char+attr alternati

**Esempio:**
```assembly
; Scrive "HELLO" rosso su nero in (10,20)
MOV AH, 13h
MOV AL, 01h             ; Aggiorna cursore
LEA BP, msg
PUSH DS
POP ES
MOV CX, 5               ; Lunghezza
MOV DH, 10              ; Row
MOV DL, 20              ; Col
MOV BL, 0Ch             ; Rosso brillante
INT 10h

msg DB 'HELLO'
```

### Funzioni Scroll

| AH | Funzione | Input | Output | Descrizione |
|----|----------|-------|--------|-------------|
| **06h** | Scroll Up | AL = lines, BH = attr, CH/CL = top-left, DH/DL = bottom-right | - | Scroll su / Clear |
| **07h** | Scroll Down | AL = lines, BH = attr, CH/CL = top-left, DH/DL = bottom-right | - | Scroll giù |

**Esempio Clear Screen:**
```assembly
MOV AH, 06h
MOV AL, 0               ; Clear all
MOV BH, 07h             ; White on black
XOR CX, CX              ; Top-left (0,0)
MOV DH, 24              ; Bottom row
MOV DL, 79              ; Right col
INT 10h
```

### Funzioni Pixel (Modalità Grafica)

| AH | Funzione | Input | Output | Descrizione |
|----|----------|-------|--------|-------------|
| **0Ch** | Write Pixel | AL = color, CX = x, DX = y, BH = page | - | Disegna pixel |
| **0Dh** | Read Pixel | CX = x, DX = y, BH = page | AL = color | Leggi pixel |

---

## INT 16h - Keyboard BIOS Services

| AH | Funzione | Input | Output | Descrizione |
|----|----------|-------|--------|-------------|
| **00h** | Read Key (wait) | - | AH = scan, AL = ASCII | Leggi tasto (bloccante) |
| **01h** | Check Key | - | ZF=1: no key, ZF=0: AH/AL = key | Controlla (non-bloccante) |
| **02h** | Get Shift Status | - | AL = flags | Stato tasti modificatori |
| **03h** | Set Repeat Rate | AL = 05h, BH = delay, BL = rate | - | Velocità ripetizione |
| **05h** | Store Keystroke | CH = scan, CL = ASCII | AL = status | Inserisci tasto in buffer |
| **10h** | Read Key Extended | - | AH = scan, AL = ASCII | Leggi (supporta >83 tasti) |
| **11h** | Check Key Extended | - | ZF, AH/AL | Controlla (esteso) |
| **12h** | Get Extended Status | - | AL/AH = flags | Stato esteso |

**Shift Status Flags (AH=02h):**
```
Bit 7: Insert attivo
Bit 6: Caps Lock attivo
Bit 5: Num Lock attivo
Bit 4: Scroll Lock attivo
Bit 3: Alt premuto
Bit 2: Ctrl premuto
Bit 1: Left Shift premuto
Bit 0: Right Shift premuto
```

**Esempio Lettura Non-Bloccante:**
```assembly
check_key:
    MOV AH, 01h
    INT 16h
    JZ no_key               ; ZF=1, nessun tasto
    
    ; Tasto disponibile, leggi
    MOV AH, 00h
    INT 16h
    ; AH = scan code, AL = ASCII
    
    CMP AL, 27              ; ESC?
    JE exit_program
    
no_key:
    ; Continua...
```

---

## INT 21h - DOS Services

### Funzioni I/O Caratteri

| AH | Funzione | Input | Output | Descrizione |
|----|----------|-------|--------|-------------|
| **01h** | Read Char Echo | - | AL = char | Leggi con echo |
| **02h** | Write Char | DL = char | - | Scrivi carattere |
| **06h** | Direct Console I/O | DL = char/FFh | AL = char (se DL=FFh) | I/O diretto |
| **07h** | Read Char No Echo | - | AL = char | Leggi senza echo |
| **08h** | Read Char No Echo | - | AL = char | Come 07h, controlla Ctrl+C |
| **09h** | Write String | DS:DX → string | - | Scrive stringa terminata '$' |
| **0Ah** | Buffered Input | DS:DX → buffer | - | Leggi riga buffered |
| **0Bh** | Check Input Status | - | AL = FFh/00h | Controlla se tasto disponibile |
| **0Ch** | Flush and Read | AL = func (01/06/07/08/0A) | - | Svuota buffer e leggi |

**Buffered Input (0Ah):**
```assembly
; Struttura buffer
buffer DB 80            ; Max length
       DB ?             ; Actual length (output)
       DB 80 DUP(?)     ; String data

; Lettura
MOV AH, 0Ah
LEA DX, buffer
INT 21h

; buffer+1 contiene lunghezza letta
; buffer+2..buffer+2+len contiene stringa
```

### Funzioni File

#### Apertura/Creazione/Chiusura

| AH | Funzione | Input | Output | Descrizione |
|----|----------|-------|--------|-------------|
| **3Ch** | Create File | DS:DX → filename, CX = attr | AX = handle/error | Crea file (tronca se esiste) |
| **3Dh** | Open File | DS:DX → filename, AL = mode | AX = handle/error | Apre file |
| **3Eh** | Close File | BX = handle | CF, AX = error | Chiude file |
| **41h** | Delete File | DS:DX → filename | CF, AX = error | Elimina file |
| **43h** | Get/Set File Attr | DS:DX → filename, AL = 00h/01h, CX = attr | CX = attr, CF | Gestione attributi |
| **56h** | Rename File | DS:DX → old, ES:DI → new | CF, AX = error | Rinomina file |

**Access Mode (AL per INT 21h/3Dh):**
```
Bit 6-4: Sharing mode
  000 = Compatibility
  001 = Exclusive
  010 = Deny write
  011 = Deny read
  100 = Deny none
  
Bit 2-0: Access mode
  000 = Read only
  001 = Write only
  010 = Read/Write
```

**Attributi File (CX):**
```
Bit 0: Read Only
Bit 1: Hidden
Bit 2: System
Bit 3: Volume Label
Bit 4: Directory
Bit 5: Archive
```

#### Lettura/Scrittura

| AH | Funzione | Input | Output | Descrizione |
|----|----------|-------|--------|-------------|
| **3Fh** | Read File | BX = handle, CX = bytes, DS:DX → buffer | AX = bytes read, CF | Leggi dati |
| **40h** | Write File | BX = handle, CX = bytes, DS:DX → buffer | AX = bytes written, CF | Scrivi dati |
| **42h** | Seek | BX = handle, AL = mode, CX:DX = offset | DX:AX = position, CF | Sposta file pointer |

**Seek Mode (AL):**
- 00h = From beginning
- 01h = From current position
- 02h = From end

**Handle Predefiniti:**
- 0000h = STDIN (standard input)
- 0001h = STDOUT (standard output)
- 0002h = STDERR (standard error)
- 0003h = STDAUX (auxiliary, porta seriale)
- 0004h = STDPRN (printer, porta parallela)

**Esempio Lettura File:**
```assembly
; Apri file
MOV AH, 3Dh
MOV AL, 0               ; Read only
LEA DX, filename
INT 21h
JC open_error
MOV file_handle, AX

; Leggi 100 byte
MOV AH, 3Fh
MOV BX, file_handle
MOV CX, 100
LEA DX, buffer
INT 21h
JC read_error
CMP AX, 0               ; EOF?
JE end_of_file

; Chiudi file
MOV AH, 3Eh
MOV BX, file_handle
INT 21h

filename DB 'test.txt',0
file_handle DW ?
buffer DB 100 DUP(?)
```

### Funzioni Directory

| AH | Funzione | Input | Output | Descrizione |
|----|----------|-------|--------|-------------|
| **39h** | Create Directory | DS:DX → dirname | CF, AX = error | Crea directory |
| **3Ah** | Remove Directory | DS:DX → dirname | CF, AX = error | Rimuove directory (vuota) |
| **3Bh** | Change Directory | DS:DX → dirname | CF, AX = error | Cambia directory corrente |
| **47h** | Get Current Dir | DL = drive (0=default), DS:SI → buffer | CF, AX = error | Leggi directory corrente |
| **4Eh** | Find First File | DS:DX → filespec, CX = attr | CF, DTA filled | Cerca primo file |
| **4Fh** | Find Next File | - | CF, DTA filled | Cerca prossimo file |

**DTA (Disk Transfer Area) per Find:**
```
Offset  Size  Descrizione
00h     21    Reserved
15h     1     Attributo file
16h     2     Ora modifica (packed)
18h     2     Data modifica (packed)
1Ah     4     Dimensione file
1Eh     13    Nome file (ASCIIZ)
```

### Funzioni Memoria

| AH | Funzione | Input | Output | Descrizione |
|----|----------|-------|--------|-------------|
| **48h** | Allocate Memory | BX = paragraphs | AX = segment, CF | Alloca memoria |
| **49h** | Free Memory | ES = segment | CF, AX = error | Libera memoria |
| **4Ah** | Resize Memory | ES = segment, BX = new size | CF, BX = max, AX = error | Ridimensiona blocco |

**Esempio:**
```assembly
; Alloca 1KB (64 paragraphs)
MOV AH, 48h
MOV BX, 64              ; 64 × 16 = 1024 byte
INT 21h
JC alloc_error
MOV mem_segment, AX

; Usa memoria
MOV ES, AX
; ... operazioni su ES:0 ...

; Libera memoria
MOV AH, 49h
MOV ES, mem_segment
INT 21h
```

### Funzioni Sistema

| AH | Funzione | Input | Output | Descrizione |
|----|----------|-------|--------|-------------|
| **25h** | Set Interrupt Vector | AL = int num, DS:DX → handler | - | Imposta vettore ISR |
| **35h** | Get Interrupt Vector | AL = int num | ES:BX → handler | Leggi vettore ISR |
| **2Ah** | Get Date | - | CX = year, DH = month, DL = day, AL = dow | Data sistema |
| **2Bh** | Set Date | CX = year, DH = month, DL = day | AL = status | Imposta data |
| **2Ch** | Get Time | - | CH = hour, CL = min, DH = sec, DL = centisec | Ora sistema |
| **2Dh** | Set Time | CH = hour, CL = min, DH = sec, DL = centisec | AL = status | Imposta ora |
| **31h** | TSR (Keep) | AL = return code, DX = paragraphs | - | Termina e resta residente |
| **4Ch** | Exit Program | AL = return code | - | Termina programma |

---

## INT 13h - Disk BIOS Services

| AH | Funzione | Input | Output | Descrizione |
|----|----------|-------|--------|-------------|
| **00h** | Reset Disk | DL = drive | CF, AH = status | Reset controller |
| **02h** | Read Sectors | AL = count, CH = cylinder, CL = sector, DH = head, DL = drive, ES:BX → buffer | AL = count, CF | Leggi settori |
| **03h** | Write Sectors | AL = count, CH/CL/DH/DL, ES:BX → buffer | AL = count, CF | Scrivi settori |
| **08h** | Get Drive Params | DL = drive | CF, DL = drives, DH = heads, CX = cyl/sec | Parametri disco |
| **15h** | Get Disk Type | DL = drive | AH = type, CF | Tipo disco |

**Drive Numbers:**
- 00h-7Fh = Floppy (0=A:, 1=B:)
- 80h-FFh = Hard disk (80h=C:, 81h=D:)

---

## INT 1Ah - Time Services

| AH | Funzione | Input | Output | Descrizione |
|----|----------|-------|--------|-------------|
| **00h** | Get System Time | - | CX:DX = tick count, AL = midnight flag | Tick count (18.2 Hz) |
| **01h** | Set System Time | CX:DX = tick count | - | Imposta tick |
| **02h** | Get RTC Time | - | CH = hour, CL = min, DH = sec (BCD) | Real-Time Clock |
| **03h** | Set RTC Time | CH = hour, CL = min, DH = sec (BCD) | - | Imposta RTC |
| **04h** | Get RTC Date | - | CH = century, CL = year, DH = month, DL = day (BCD) | Data RTC |
| **05h** | Set RTC Date | CH = century, CL = year, DH = month, DL = day (BCD) | - | Imposta data RTC |

**Tick Count:** Incrementato 18.2 volte/sec, reset a midnight.

---

## INT 11h - Equipment Check

| Input | Output | Descrizione |
|-------|--------|-------------|
| - | AX = equipment flags | Configurazione hardware |

**Equipment Flags:**
```
Bit 15-14: Numero stampanti
Bit 13: Serial port presente
Bit 12: Game adapter
Bit 11-9: Numero porte seriali
Bit 8: DMA presente (0 su PC)
Bit 7-6: Numero drive floppy
Bit 5-4: Modalità video iniziale
Bit 3: (unused)
Bit 2: Pointing device (PS/2 mouse)
Bit 1: Math coprocessor
Bit 0: Floppy presente
```

---

## INT 12h - Memory Size

| Input | Output | Descrizione |
|-------|--------|-------------|
| - | AX = KB | Memoria base (max 640KB) |

---

## INT 15h - System Services

| AH | Funzione | Input | Output | Descrizione |
|----|----------|-------|--------|-------------|
| **86h** | Wait | CX:DX = microsec | CF | Delay (polling) |
| **87h** | Move Block | CX = words, ES:SI → GDT | CF | Copia memoria estesa |
| **88h** | Get Extended Mem | - | AX = KB | Memoria estesa (>1MB) |
| **C0h** | Get System Config | - | ES:BX → config | Configurazione sistema |

---

## Codici di Errore Comuni

### Errori DOS (CF=1, codice in AX)

| Codice | Nome | Descrizione |
|--------|------|-------------|
| 01h | Invalid function | Funzione non valida |
| 02h | File not found | File non trovato |
| 03h | Path not found | Path non trovato |
| 04h | Too many open files | Troppi file aperti |
| 05h | Access denied | Accesso negato |
| 06h | Invalid handle | Handle non valido |
| 08h | Insufficient memory | Memoria insufficiente |
| 0Fh | Invalid drive | Drive non valido |
| 13h | Write protect | Disco protetto |

### Errori Disco (INT 13h, status in AH)

| Codice | Descrizione |
|--------|-------------|
| 00h | Success |
| 01h | Invalid command |
| 02h | Address mark not found |
| 03h | Write protect |
| 04h | Sector not found |
| 08h | DMA overrun |
| 09h | DMA boundary error |
| 10h | CRC error |
| 20h | Controller failure |
| 40h | Seek failure |
| 80h | Timeout |

---

**Note:**
- Sempre controllare CF dopo chiamate DOS/BIOS
- Handle file: chiudere sempre con INT 21h/3Eh
- Interruzioni INT 20h-2Fh riservate DOS
- INT 00h-1Fh: CPU exceptions e BIOS