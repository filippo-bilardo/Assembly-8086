# File I/O con DOS

## Introduzione

DOS offre servizi completi per gestire file tramite **INT 21h**. Questo modulo esplora apertura, lettura, scrittura, chiusura file e gestione errori.

## Handle vs FCB

DOS supporta due metodi di accesso file:

1. **Handle** (file handle): moderno, preferito, funzioni 3Ch-42h
2. **FCB** (File Control Block): obsoleto, retro-compatibilità CP/M

Useremo esclusivamente **handle**.

## File Handle

Un **file handle** è un numero di 16 bit che identifica un file aperto.

**Handle Predefiniti**:

| Handle | Dispositivo | Descrizione |
|--------|-------------|-------------|
| 0 | stdin | Standard Input (tastiera) |
| 1 | stdout | Standard Output (schermo) |
| 2 | stderr | Standard Error (schermo) |
| 3 | stdaux | Auxiliary (porta seriale) |
| 4 | stdprn | Printer (stampante) |

**Nota**: handle 0-4 sempre disponibili; handle 5+ per file aperti dall'utente.

## Funzioni File DOS (INT 21h)

### 3Ch - Create File

```assembly
MOV AH, 3Ch
MOV CX, attributes
LEA DX, filename           ; DS:DX = nome file (ASCIIZ)
INT 21h
; CF = 0: successo, AX = file handle
; CF = 1: errore, AX = codice errore
```

**Attributi File** (CX):

| Bit | Maschera | Significato |
|-----|----------|-------------|
| 0 | 01h | Read-Only |
| 1 | 02h | Hidden |
| 2 | 04h | System |
| 5 | 20h | Archive |

**Esempio: Crea File Normale**:
```assembly
.DATA
    filename DB 'output.txt', 0
    handle DW ?

.CODE
    MOV AH, 3Ch
    MOV CX, 0               ; Attributo normale
    LEA DX, filename
    INT 21h
    JC create_error         ; CF = 1, errore
    
    MOV handle, AX          ; Salva handle
    ; File creato con successo
```

**Attenzione**: se file esiste, viene **troncato** a 0 byte!

### 3Dh - Open File

```assembly
MOV AH, 3Dh
MOV AL, access_mode
LEA DX, filename
INT 21h
; CF = 0: AX = file handle
; CF = 1: AX = error code
```

**Access Mode** (AL):

| Valore | Modo | Descrizione |
|--------|------|-------------|
| 00h | Read | Sola lettura |
| 01h | Write | Sola scrittura |
| 02h | Read/Write | Lettura e scrittura |

**Sharing Mode** (AL, bit 4-6, DOS 3.0+):

| Bits | Modo | Descrizione |
|------|------|-------------|
| 000 | Compatibility | Compatibilità (default) |
| 001 | Deny all | Nega tutti gli accessi |
| 010 | Deny write | Nega scrittura |
| 011 | Deny read | Nega lettura |
| 100 | Deny none | Permetti tutto |

**Esempio: Apri File in Lettura**:
```assembly
.DATA
    filename DB 'input.txt', 0
    handle DW ?

.CODE
    MOV AH, 3Dh
    MOV AL, 0               ; Read-only
    LEA DX, filename
    INT 21h
    JC open_error
    
    MOV handle, AX          ; Salva handle
```

### 3Eh - Close File

```assembly
MOV AH, 3Eh
MOV BX, file_handle
INT 21h
; CF = 0: successo
; CF = 1: errore (handle invalido)
```

**Esempio**:
```assembly
    MOV AH, 3Eh
    MOV BX, handle
    INT 21h
    JC close_error
    ; File chiuso
```

**Importante**: **SEMPRE** chiudere file prima di uscire!

### 3Fh - Read File

```assembly
MOV AH, 3Fh
MOV BX, file_handle
MOV CX, bytes_to_read
LEA DX, buffer             ; DS:DX = buffer destinazione
INT 21h
; CF = 0: AX = bytes letti effettivamente
; CF = 1: AX = error code
; AX = 0: fine file (EOF)
```

**Esempio: Leggi 512 Byte**:
```assembly
.DATA
    handle DW ?
    buffer DB 512 DUP(?)
    bytes_read DW ?

.CODE
    MOV AH, 3Fh
    MOV BX, handle
    MOV CX, 512             ; Leggi 512 byte
    LEA DX, buffer
    INT 21h
    JC read_error
    
    MOV bytes_read, AX      ; AX = byte letti
    CMP AX, 0
    JE end_of_file
```

**Attenzione**: AX può essere < CX se:
- Fine file raggiunta
- Dispositivo (es. tastiera) ha meno dati disponibili

### 40h - Write File

```assembly
MOV AH, 40h
MOV BX, file_handle
MOV CX, bytes_to_write
LEA DX, buffer             ; DS:DX = buffer sorgente
INT 21h
; CF = 0: AX = bytes scritti
; CF = 1: AX = error code
```

**Esempio: Scrivi Stringa**:
```assembly
.DATA
    handle DW ?
    text DB 'Hello, File!', 13, 10
    text_len EQU $ - text

.CODE
    MOV AH, 40h
    MOV BX, handle
    MOV CX, text_len
    LEA DX, text
    INT 21h
    JC write_error
    
    CMP AX, text_len        ; Tutti i byte scritti?
    JNE disk_full
```

**Attenzione**: se AX < CX, disco potrebbe essere pieno!

### 42h - Seek File

```assembly
MOV AH, 42h
MOV AL, origin
MOV BX, file_handle
MOV CX, offset_high        ; Word alto offset (32-bit)
MOV DX, offset_low         ; Word basso offset
INT 21h
; CF = 0: DX:AX = nuova posizione assoluta
; CF = 1: AX = error code
```

**Origin** (AL):

| Valore | Origine | Descrizione |
|--------|---------|-------------|
| 00h | Beginning | Dall'inizio file |
| 01h | Current | Dalla posizione corrente |
| 02h | End | Dalla fine file |

**Esempio: Seek Inizio File**:
```assembly
    MOV AH, 42h
    MOV AL, 0               ; Origine: inizio
    MOV BX, handle
    XOR CX, CX              ; Offset = 0
    XOR DX, DX
    INT 21h
    ; Posizione ora a byte 0
```

**Esempio: Seek Fine File (Determina Dimensione)**:
```assembly
get_file_size PROC
    ; BX = file handle
    ; Ritorna DX:AX = dimensione file
    
    MOV AH, 42h
    MOV AL, 2               ; Origine: fine
    MOV CX, 0               ; Offset = 0
    MOV DX, 0
    INT 21h
    JC seek_error
    
    ; DX:AX = dimensione
    RET
get_file_size ENDP
```

### 41h - Delete File

```assembly
MOV AH, 41h
LEA DX, filename
INT 21h
; CF = 0: successo
; CF = 1: errore (file non trovato, read-only, ecc.)
```

**Esempio**:
```assembly
.DATA
    filename DB 'temp.dat', 0

.CODE
    MOV AH, 41h
    LEA DX, filename
    INT 21h
    JC delete_error
```

### 56h - Rename File

```assembly
MOV AH, 56h
LEA DX, old_name           ; DS:DX = vecchio nome
LEA DI, new_name           ; ES:DI = nuovo nome
INT 21h
; CF = 0: successo
; CF = 1: errore
```

**Esempio**:
```assembly
.DATA
    old_name DB 'old.txt', 0
    new_name DB 'new.txt', 0

.CODE
    PUSH DS
    POP ES                  ; ES = DS
    
    MOV AH, 56h
    LEA DX, old_name
    LEA DI, new_name
    INT 21h
    JC rename_error
```

## Gestione Errori

### Codici Errore Comuni

| AX | Errore | Descrizione |
|----|--------|-------------|
| 02h | File not found | File non trovato |
| 03h | Path not found | Percorso non trovato |
| 04h | Too many open files | Troppi file aperti |
| 05h | Access denied | Accesso negato |
| 06h | Invalid handle | Handle non valido |
| 0Ch | Invalid access | Modo accesso non valido |

### Controllo Errori

```assembly
open_file PROC
    MOV AH, 3Dh
    MOV AL, 0
    LEA DX, filename
    INT 21h
    JC error_occurred       ; CF = 1, errore
    
    ; Successo
    MOV handle, AX
    CLC                     ; CF = 0 (ok)
    RET
    
error_occurred:
    ; AX = codice errore
    CMP AX, 2
    JE file_not_found
    CMP AX, 5
    JE access_denied
    ; ... altri errori ...
    
    STC                     ; CF = 1 (errore)
    RET
open_file ENDP
```

## Esempi Completi

### Copia File

```assembly
.MODEL SMALL
.STACK 100h

.DATA
    src_name DB 'source.txt', 0
    dst_name DB 'dest.txt', 0
    src_handle DW ?
    dst_handle DW ?
    buffer DB 4096 DUP(?)   ; Buffer 4 KB
    bytes_read DW ?
    
    err_open_src DB 'Errore apertura file sorgente.$'
    err_create_dst DB 'Errore creazione file destinazione.$'
    err_read DB 'Errore lettura.$'
    err_write DB 'Errore scrittura.$'
    msg_success DB 'Copia completata.$'

.CODE
main PROC
    MOV AX, @DATA
    MOV DS, AX
    
    ; Apri file sorgente
    MOV AH, 3Dh
    MOV AL, 0               ; Read
    LEA DX, src_name
    INT 21h
    JC error_open_src
    MOV src_handle, AX
    
    ; Crea file destinazione
    MOV AH, 3Ch
    MOV CX, 0               ; Attributo normale
    LEA DX, dst_name
    INT 21h
    JC error_create_dst
    MOV dst_handle, AX
    
copy_loop:
    ; Leggi chunk
    MOV AH, 3Fh
    MOV BX, src_handle
    MOV CX, 4096
    LEA DX, buffer
    INT 21h
    JC error_read
    
    MOV bytes_read, AX
    CMP AX, 0               ; EOF?
    JE copy_done
    
    ; Scrivi chunk
    MOV AH, 40h
    MOV BX, dst_handle
    MOV CX, bytes_read
    LEA DX, buffer
    INT 21h
    JC error_write
    
    CMP AX, bytes_read      ; Tutto scritto?
    JNE error_write         ; No, disco pieno?
    
    JMP copy_loop
    
copy_done:
    ; Chiudi file
    MOV AH, 3Eh
    MOV BX, src_handle
    INT 21h
    
    MOV AH, 3Eh
    MOV BX, dst_handle
    INT 21h
    
    ; Successo
    LEA DX, msg_success
    MOV AH, 09h
    INT 21h
    JMP exit_program
    
error_open_src:
    LEA DX, err_open_src
    JMP print_error
    
error_create_dst:
    LEA DX, err_create_dst
    ; Chiudi sorgente
    MOV AH, 3Eh
    MOV BX, src_handle
    INT 21h
    JMP print_error
    
error_read:
    LEA DX, err_read
    JMP cleanup_and_error
    
error_write:
    LEA DX, err_write
    
cleanup_and_error:
    ; Chiudi entrambi i file
    MOV AH, 3Eh
    MOV BX, src_handle
    INT 21h
    MOV AH, 3Eh
    MOV BX, dst_handle
    INT 21h
    
print_error:
    MOV AH, 09h
    INT 21h
    
exit_program:
    MOV AH, 4Ch
    INT 21h
main ENDP
END main
```

### Conta Righe File

```assembly
count_lines PROC
    ; DS:DX = filename
    ; Ritorna AX = numero righe
    
    LOCAL handle:WORD, line_count:WORD
    
    ; Apri file
    MOV AH, 3Dh
    MOV AL, 0
    INT 21h
    JC count_error
    MOV handle, AX
    
    MOV line_count, 0
    
read_loop:
    ; Leggi 1 byte
    MOV AH, 3Fh
    MOV BX, handle
    MOV CX, 1
    LEA DX, char_buffer
    INT 21h
    JC count_error
    
    CMP AX, 0               ; EOF?
    JE count_done
    
    ; Controlla se LF (0Ah)
    MOV AL, char_buffer
    CMP AL, 0Ah
    JNE read_loop
    
    INC line_count
    JMP read_loop
    
count_done:
    ; Chiudi file
    MOV AH, 3Eh
    MOV BX, handle
    INT 21h
    
    MOV AX, line_count
    CLC
    RET
    
count_error:
    STC
    RET
    
char_buffer DB ?
count_lines ENDP
```

### Append a File

```assembly
append_to_file PROC
    ; DS:DX = filename
    ; ES:SI = data to append
    ; CX = data length
    
    LOCAL handle:WORD
    
    PUSH SI
    PUSH CX
    
    ; Apri file in read/write
    MOV AH, 3Dh
    MOV AL, 2               ; Read/Write
    INT 21h
    JC append_error
    MOV handle, AX
    
    ; Seek fine file
    MOV AH, 42h
    MOV AL, 2               ; End
    MOV BX, handle
    XOR CX, CX
    XOR DX, DX
    INT 21h
    JC append_error_close
    
    ; Scrivi dati
    POP CX
    POP SI
    PUSH DS
    PUSH ES
    POP DS                  ; DS = ES
    MOV DX, SI
    
    MOV AH, 40h
    MOV BX, handle
    INT 21h
    
    POP DS
    JC append_error_close
    
    ; Chiudi
    MOV AH, 3Eh
    MOV BX, handle
    INT 21h
    
    CLC
    RET
    
append_error_close:
    MOV AH, 3Eh
    MOV BX, handle
    INT 21h
    
append_error:
    POP CX
    POP SI
    STC
    RET
append_to_file ENDP
```

### Leggi Riga da File

```assembly
read_line PROC
    ; BX = file handle
    ; ES:DI = buffer destinazione (max 255 caratteri)
    ; Ritorna AX = numero caratteri letti (escluso CR/LF)
    
    PUSH DI
    XOR CX, CX              ; Contatore caratteri
    
read_char:
    PUSH CX
    PUSH DI
    
    ; Leggi 1 byte
    MOV AH, 3Fh
    MOV CX, 1
    LEA DX, temp_char
    INT 21h
    
    POP DI
    POP CX
    
    JC read_error
    CMP AX, 0               ; EOF?
    JE read_done
    
    MOV AL, temp_char
    CMP AL, 0Ah             ; LF?
    JE read_done
    CMP AL, 0Dh             ; CR?
    JE read_char            ; Ignora CR
    
    ; Salva carattere
    STOSB                   ; ES:[DI] = AL, DI++
    INC CX
    CMP CX, 255             ; Max lunghezza
    JB read_char
    
read_done:
    ; Termina stringa
    MOV BYTE PTR ES:[DI], 0
    
    MOV AX, CX              ; AX = lunghezza
    POP DI
    CLC
    RET
    
read_error:
    POP DI
    STC
    RET
    
temp_char DB ?
read_line ENDP
```

## Redirect I/O Standard

### Duplica Handle (45h)

```assembly
MOV AH, 45h
MOV BX, existing_handle
INT 21h
; CF = 0: AX = nuovo handle (duplicato)
```

### Forza Handle (46h)

```assembly
MOV AH, 46h
MOV BX, source_handle
MOV CX, target_handle
INT 21h
; CF = 0: CX ora punta allo stesso file di BX
```

**Esempio: Redirect stdout a File**:
```assembly
; Redirect stdout (handle 1) a file
redirect_stdout PROC
    ; Apri/crea file output
    MOV AH, 3Ch
    MOV CX, 0
    LEA DX, output_file
    INT 21h
    JC redir_error
    MOV file_handle, AX
    
    ; Duplica stdout originale
    MOV AH, 45h
    MOV BX, 1               ; stdout
    INT 21h
    JC redir_error
    MOV saved_stdout, AX
    
    ; Forza stdout su file
    MOV AH, 46h
    MOV BX, file_handle
    MOV CX, 1               ; stdout
    INT 21h
    JC redir_error
    
    ; Ora printf, INT 21h/02h, ecc. scrivono su file!
    RET
    
redir_error:
    ; Gestione errore
    RET
redirect_stdout ENDP

restore_stdout PROC
    ; Ripristina stdout originale
    MOV AH, 46h
    MOV BX, saved_stdout
    MOV CX, 1
    INT 21h
    
    ; Chiudi duplicato e file
    MOV AH, 3Eh
    MOV BX, saved_stdout
    INT 21h
    MOV AH, 3Eh
    MOV BX, file_handle
    INT 21h
    RET
restore_stdout ENDP

.DATA
    output_file DB 'output.txt', 0
    file_handle DW ?
    saved_stdout DW ?
```

## File Binari vs Testo

### Modo Testo (Default)

- **CR+LF** (0Dh,0Ah) → **LF** (0Ah) in lettura
- **LF** → **CR+LF** in scrittura
- **Ctrl+Z** (1Ah) = EOF

### Modo Binario

- Nessuna conversione
- Trasferimento byte esatto

**DOS non distingue esplicitamente**: programma deve gestire conversioni.

## Best Practices

### 1. Sempre Chiudi File

```assembly
✓ Corretto:
    CALL open_file
    ; ... usa file ...
    CALL close_file         ; SEMPRE chiudi

✗ Dimenticato:
    CALL open_file
    ; ... usa file ...
    ; Non chiuso! Handle perso, buffer non svuotati
```

### 2. Controlla TUTTI gli Errori

```assembly
✓ Completo:
    MOV AH, 3Dh
    LEA DX, filename
    INT 21h
    JC handle_error         ; CF = 1
    ; ... successo ...

✗ Incompleto:
    INT 21h
    MOV handle, AX          ; Se errore, handle invalido!
```

### 3. Usa Buffer Grandi

```assembly
✓ Efficiente:
    buffer DB 4096 DUP(?)   ; Leggi 4 KB per volta

✗ Inefficiente:
    buffer DB 1 DUP(?)      ; Leggi 1 byte per volta (lento!)
```

### 4. Verifica Byte Scritti

```assembly
✓ Sicuro:
    MOV AH, 40h
    MOV CX, data_len
    INT 21h
    JC write_error
    CMP AX, CX              ; Tutti scritti?
    JNE disk_full

✗ Incompleto:
    INT 21h
    ; Ignora AX, assume successo
```

### 5. Cleanup in Caso di Errore

```assembly
✓ Cleanup:
error_handler:
    ; Chiudi file aperti
    MOV AH, 3Eh
    MOV BX, handle
    INT 21h
    ; Elimina file parziali
    MOV AH, 41h
    LEA DX, temp_file
    INT 21h
    RET
```

## Esercizi Pratici

1. Scrivi programma che conta parole in un file di testo
2. Implementa `grep` semplice (cerca stringa in file)
3. Crea programma che divide file grande in chunk da 1 MB
4. Scrivi utility che unisce più file in uno solo
5. Implementa `tail -n 10` (ultime 10 righe file)

---

**Prossimo argomento:** [Interrupt Service Routines Personalizzate](modulo6_04_isr_custom.md)
