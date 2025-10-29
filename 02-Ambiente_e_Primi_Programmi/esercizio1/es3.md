# Guida Completa: NASM su Shell Linux Debian Remota

## Indice
1. [Installazione e Setup](#installazione)
2. [Architetture e Sintassi](#architetture)
3. [Programmi Base](#programmi-base)
4. [Compilazione e Linking](#compilazione)
5. [Debugging con GDB](#debugging)
6. [System Calls Linux](#system-calls)
7. [Esempi Pratici](#esempi-pratici)
8. [Workflow Ottimizzato](#workflow)
9. [Best Practices](#best-practices)
10. [Troubleshooting](#troubleshooting)

---

## 1. Installazione e Setup {#installazione}

### Installazione Pacchetti Necessari

```bash
# Aggiorna il sistema
sudo apt update
sudo apt upgrade

# Installa NASM e strumenti di sviluppo
sudo apt install nasm

# Installa il linker e build tools
sudo apt install build-essential

# Installa debugger (opzionale ma consigliato)
sudo apt install gdb

# Installa strumenti per analisi binari
sudo apt install binutils hexdump strace

# Verifica installazione
nasm -version
ld --version
gcc --version
```

### Configurazione Directory di Lavoro

```bash
# Crea struttura organizzata
mkdir -p ~/assembly/{src,bin,lib,examples}
cd ~/assembly

# Imposta permessi
chmod 755 ~/assembly
```

### Editor di Testo Consigliati

```bash
# Installa un editor confortevole
sudo apt install vim nano

# O usa vim con syntax highlighting
echo "syntax on" >> ~/.vimrc
echo "filetype plugin indent on" >> ~/.vimrc
```

---

## 2. Architetture e Sintassi {#architetture}

### Differenze tra Architetture

| Caratteristica | 16-bit (8086) | 32-bit (i386) | 64-bit (x86-64) |
|----------------|---------------|---------------|-----------------|
| Registri | AX, BX, CX, DX | EAX, EBX, ECX, EDX | RAX, RBX, RCX, RDX |
| Formato Output | `-f bin`, `-f obj` | `-f elf32` | `-f elf64` |
| System Calls | INT 21h (DOS) | INT 80h (Linux) | SYSCALL (Linux) |
| Linker | `ld -m elf_i386` | `ld -m elf_i386` | `ld` |

### Sintassi NASM vs TASM

**TASM (Intel Syntax):**
```assembly
.model small
.stack 100h
.data
    msg db 'Hello$'
.code
main proc
    mov ax, @data
    mov ds, ax
    ; ...
main endp
end main
```

**NASM (Intel Syntax Moderno):**
```assembly
section .data
    msg db 'Hello', 0

section .text
    global _start
_start:
    ; ...
```

---

## 3. Programmi Base {#programmi-base}

### Hello World - 32 bit

**File: `hello32.asm`**

```assembly
; Hello World in 32-bit Linux Assembly (NASM)
section .data
    msg db 'Hello, World!', 0xA    ; messaggio con newline
    len equ $ - msg                ; calcola lunghezza

section .text
    global _start

_start:
    ; sys_write(stdout, msg, len)
    mov eax, 4          ; syscall: sys_write
    mov ebx, 1          ; file descriptor: stdout
    mov ecx, msg        ; puntatore al messaggio
    mov edx, len        ; lunghezza messaggio
    int 0x80            ; chiamata al kernel

    ; sys_exit(0)
    mov eax, 1          ; syscall: sys_exit
    xor ebx, ebx        ; exit code: 0
    int 0x80            ; chiamata al kernel
```

**Compilazione:**
```bash
nasm -f elf32 hello32.asm -o hello32.o
ld -m elf_i386 hello32.o -o hello32
./hello32
```

### Hello World - 64 bit

**File: `hello64.asm`**

```assembly
; Hello World in 64-bit Linux Assembly (NASM)
section .data
    msg db 'Hello, World!', 0xA
    len equ $ - msg

section .text
    global _start

_start:
    ; sys_write(stdout, msg, len)
    mov rax, 1          ; syscall: sys_write
    mov rdi, 1          ; file descriptor: stdout
    mov rsi, msg        ; puntatore al messaggio
    mov rdx, len        ; lunghezza
    syscall             ; chiamata al kernel

    ; sys_exit(0)
    mov rax, 60         ; syscall: sys_exit
    xor rdi, rdi        ; exit code: 0
    syscall
```

**Compilazione:**
```bash
nasm -f elf64 hello64.asm -o hello64.o
ld hello64.o -o hello64
./hello64
```

### Input da Tastiera - 32 bit

**File: `input32.asm`**

```assembly
section .data
    prompt db 'Inserisci il tuo nome: ', 0
    prompt_len equ $ - prompt
    hello db 'Ciao, ', 0
    hello_len equ $ - hello
    newline db 0xA

section .bss
    name resb 32        ; buffer per nome (32 byte)

section .text
    global _start

_start:
    ; Stampa prompt
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt
    mov edx, prompt_len
    int 0x80

    ; Leggi input
    mov eax, 3          ; sys_read
    mov ebx, 0          ; stdin
    mov ecx, name       ; buffer
    mov edx, 32         ; max caratteri
    int 0x80
    mov [name + eax - 1], byte 0  ; rimuovi newline

    ; Stampa "Ciao, "
    mov eax, 4
    mov ebx, 1
    mov ecx, hello
    mov edx, hello_len
    int 0x80

    ; Stampa nome
    mov eax, 4
    mov ebx, 1
    mov ecx, name
    mov edx, 32
    int 0x80

    ; Stampa newline
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    ; Exit
    mov eax, 1
    xor ebx, ebx
    int 0x80
```

---

## 4. Compilazione e Linking {#compilazione}

### Opzioni NASM Principali

```bash
# Compilazione base
nasm -f elf32 file.asm -o file.o

# Con debug symbols
nasm -f elf32 -g -F dwarf file.asm -o file.o

# Con preprocessor defines
nasm -f elf32 -DDEBUG=1 file.asm -o file.o

# Listing file (per vedere codice generato)
nasm -f elf32 file.asm -l file.lst

# Solo preprocessor
nasm -E file.asm -o file.i
```

### Opzioni Linker

```bash
# Linking standard 32-bit
ld -m elf_i386 file.o -o file

# Linking 64-bit
ld file.o -o file

# Con entry point custom
ld -m elf_i386 -e main file.o -o file

# Con librerie statiche
ld -m elf_i386 file.o -lc -o file

# Strip symbols (riduce dimensione)
ld -m elf_i386 -s file.o -o file
```

### Linking con GCC (per usare libc)

```bash
# 32-bit con libc
gcc -m32 -no-pie file.o -o file

# 64-bit con libc
gcc -no-pie file.o -o file
```

### Makefile per Automazione

**File: `Makefile`**

```makefile
# Makefile per progetti Assembly NASM

# Variabili
ASM = nasm
LD = ld
ASMFLAGS32 = -f elf32 -g -F dwarf
ASMFLAGS64 = -f elf64 -g -F dwarf
LDFLAGS32 = -m elf_i386
LDFLAGS64 =

# Target default
all: hello32 hello64

# Compila 32-bit
hello32: hello32.o
	$(LD) $(LDFLAGS32) $< -o $@

hello32.o: hello32.asm
	$(ASM) $(ASMFLAGS32) $< -o $@

# Compila 64-bit
hello64: hello64.o
	$(LD) $(LDFLAGS64) $< -o $@

hello64.o: hello64.asm
	$(ASM) $(ASMFLAGS64) $< -o $@

# Pulizia
clean:
	rm -f *.o hello32 hello64

# Esegui
run32: hello32
	./hello32

run64: hello64
	./hello64

.PHONY: all clean run32 run64
```

**Uso:**
```bash
make          # Compila tutti
make run32    # Compila ed esegui 32-bit
make clean    # Pulisci
```

---

## 5. Debugging con GDB {#debugging}

### Compilare con Debug Info

```bash
# Aggiungi simboli di debug
nasm -f elf32 -g -F dwarf program.asm -o program.o
ld -m elf_i386 program.o -o program
```

### Comandi GDB Base

```bash
# Avvia GDB
gdb ./program

# Comandi principali
(gdb) break _start          # Breakpoint all'inizio
(gdb) break *0x8048080      # Breakpoint a indirizzo
(gdb) run                   # Esegui programma
(gdb) stepi                 # Esegui una istruzione
(gdb) nexti                 # Prossima istruzione (skip call)
(gdb) continue              # Continua esecuzione
(gdb) info registers        # Mostra tutti i registri
(gdb) info registers eax    # Mostra registro specifico
(gdb) x/10x $esp            # Esamina stack (10 word esadecimali)
(gdb) x/s 0x8048000         # Esamina stringa a indirizzo
(gdb) disassemble _start    # Disassembla funzione
(gdb) quit                  # Esci
```

### Script GDB per Debug Automatico

**File: `.gdbinit`**

```gdb
# Configurazione GDB per Assembly

# Layout TUI
layout asm
layout regs

# Breakpoint automatici
break _start

# Mostra istruzioni dopo ogni step
define hook-stop
    x/3i $pc
end

# Alias utili
define reg32
    info registers eax ebx ecx edx esi edi ebp esp eip
end

define stack
    x/16x $esp
end

# Avvio automatico
run
```

---

## 6. System Calls Linux {#system-calls}

### System Calls 32-bit (INT 0x80)

| EAX | Chiamata | EBX | ECX | EDX | Descrizione |
|-----|----------|-----|-----|-----|-------------|
| 1 | sys_exit | exit_code | - | - | Termina programma |
| 3 | sys_read | fd | buffer | count | Leggi da file |
| 4 | sys_write | fd | buffer | count | Scrivi su file |
| 5 | sys_open | filename | flags | mode | Apri file |
| 6 | sys_close | fd | - | - | Chiudi file |

**Esempio:**
```assembly
; Scrivere su stdout
mov eax, 4          ; sys_write
mov ebx, 1          ; stdout
mov ecx, buffer     ; puntatore
mov edx, length     ; lunghezza
int 0x80            ; chiamata
```

### System Calls 64-bit (SYSCALL)

| RAX | Chiamata | RDI | RSI | RDX | Descrizione |
|-----|----------|-----|-----|-----|-------------|
| 0 | sys_read | fd | buffer | count | Leggi da file |
| 1 | sys_write | fd | buffer | count | Scrivi su file |
| 2 | sys_open | filename | flags | mode | Apri file |
| 3 | sys_close | fd | - | - | Chiudi file |
| 60 | sys_exit | exit_code | - | - | Termina programma |

**Esempio:**
```assembly
; Scrivere su stdout
mov rax, 1          ; sys_write
mov rdi, 1          ; stdout
mov rsi, buffer     ; puntatore
mov rdx, length     ; lunghezza
syscall             ; chiamata
```

---

## 7. Esempi Pratici {#esempi-pratici}

### Esempio 1: Calcolatrice Somma

**File: `somma.asm`**

```assembly
section .data
    msg1 db 'Risultato: ', 0
    msg1_len equ $ - msg1
    newline db 0xA

section .text
    global _start

_start:
    ; Calcola 5 + 3
    mov eax, 5
    add eax, 3
    
    ; Converti risultato in ASCII
    add eax, '0'
    mov [result], eax
    
    ; Stampa "Risultato: "
    mov eax, 4
    mov ebx, 1
    mov ecx, msg1
    mov edx, msg1_len
    int 0x80
    
    ; Stampa numero
    mov eax, 4
    mov ebx, 1
    mov ecx, result
    mov edx, 1
    int 0x80
    
    ; Stampa newline
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    
    ; Exit
    mov eax, 1
    xor ebx, ebx
    int 0x80

section .bss
    result resb 1
```

### Esempio 2: Loop e Array

**File: `loop.asm`**

```assembly
section .data
    array dd 1, 2, 3, 4, 5      ; Array di 5 numeri
    array_len equ ($ - array) / 4
    sum dd 0                     ; Somma

section .text
    global _start

_start:
    mov ecx, array_len          ; Contatore loop
    mov esi, array              ; Puntatore array
    mov eax, 0                  ; Accumulatore somma

loop_start:
    add eax, [esi]              ; Aggiungi elemento corrente
    add esi, 4                  ; Avanza al prossimo elemento
    loop loop_start             ; Decrementa ECX e ripeti se != 0

    mov [sum], eax              ; Salva risultato

    ; Exit
    mov eax, 1
    xor ebx, ebx
    int 0x80
```

### Esempio 3: Procedure e Stack

**File: `procedure.asm`**

```assembly
section .data
    result dd 0

section .text
    global _start

; Procedura: moltiplica per 2
; Input: EAX
; Output: EAX
double:
    push ebp                    ; Salva base pointer
    mov ebp, esp                ; Nuovo frame dello stack
    
    shl eax, 1                  ; Moltiplica per 2 (shift left)
    
    pop ebp                     ; Ripristina base pointer
    ret                         ; Ritorna

_start:
    mov eax, 5                  ; Numero da moltiplicare
    call double                 ; Chiama procedura
    mov [result], eax           ; Salva risultato
    
    ; Exit
    mov eax, 1
    xor ebx, ebx
    int 0x80
```

### Esempio 4: Gestione File

**File: `file.asm`**

```assembly
section .data
    filename db 'output.txt', 0
    text db 'Hello from Assembly!', 0xA
    text_len equ $ - text

section .text
    global _start

_start:
    ; Apri file (crea se non esiste)
    mov eax, 5                  ; sys_open
    mov ebx, filename
    mov ecx, 0x42               ; O_CREAT | O_WRONLY
    mov edx, 0644o              ; Permessi
    int 0x80
    
    mov edi, eax                ; Salva file descriptor
    
    ; Scrivi nel file
    mov eax, 4                  ; sys_write
    mov ebx, edi                ; File descriptor
    mov ecx, text
    mov edx, text_len
    int 0x80
    
    ; Chiudi file
    mov eax, 6                  ; sys_close
    mov ebx, edi
    int 0x80
    
    ; Exit
    mov eax, 1
    xor ebx, ebx
    int 0x80
```

---

## 8. Workflow Ottimizzato {#workflow}

### Script di Compilazione Rapida

**File: `build.sh`**

```bash
#!/bin/bash
# Script per compilazione rapida Assembly NASM

# Colori per output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Verifica argomenti
if [ $# -eq 0 ]; then
    echo -e "${RED}Uso: $0 <file.asm> [32|64]${NC}"
    echo "Esempio: $0 hello.asm 32"
    exit 1
fi

FILE=$1
BASENAME="${FILE%.asm}"
ARCH="${2:-32}"  # Default 32-bit

echo -e "${YELLOW}Compilazione di $FILE per ${ARCH}-bit...${NC}"

if [ "$ARCH" = "32" ]; then
    # 32-bit
    nasm -f elf32 -g -F dwarf "$FILE" -o "${BASENAME}.o"
    if [ $? -ne 0 ]; then
        echo -e "${RED}Errore durante l'assemblaggio!${NC}"
        exit 1
    fi
    
    ld -m elf_i386 "${BASENAME}.o" -o "$BASENAME"
    if [ $? -ne 0 ]; then
        echo -e "${RED}Errore durante il linking!${NC}"
        exit 1
    fi
elif [ "$ARCH" = "64" ]; then
    # 64-bit
    nasm -f elf64 -g -F dwarf "$FILE" -o "${BASENAME}.o"
    if [ $? -ne 0 ]; then
        echo -e "${RED}Errore durante l'assemblaggio!${NC}"
        exit 1
    fi
    
    ld "${BASENAME}.o" -o "$BASENAME"
    if [ $? -ne 0 ]; then
        echo -e "${RED}Errore durante il linking!${NC}"
        exit 1
    fi
else
    echo -e "${RED}Architettura non valida: $ARCH${NC}"
    exit 1
fi

echo -e "${GREEN}Compilazione completata: $BASENAME${NC}"
echo -e "${GREEN}Esegui con: ./$BASENAME${NC}"
```

**Rendi eseguibile:**
```bash
chmod +x build.sh
```

**Uso:**
```bash
./build.sh hello.asm 32
./build.sh hello64.asm 64
```

### Template per Nuovi Progetti

**File: `template32.asm`**

```assembly
; Template per programmi Assembly 32-bit
; Autore: [Il tuo nome]
; Data: [Data]
; Descrizione: [Descrizione del programma]

section .data
    ; Dati inizializzati

section .bss
    ; Dati non inizializzati

section .text
    global _start

_start:
    ; Il tuo codice qui
    
    ; Exit
    mov eax, 1
    xor ebx, ebx
    int 0x80
```

**Script per creare nuovo progetto:**

```bash
#!/bin/bash
# new_project.sh - Crea nuovo progetto Assembly

PROJECT_NAME=$1

if [ -z "$PROJECT_NAME" ]; then
    echo "Uso: $0 <nome_progetto>"
    exit 1
fi

mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME"

cp ~/assembly/template32.asm "${PROJECT_NAME}.asm"
echo "Progetto $PROJECT_NAME creato!"
echo "File: ${PROJECT_NAME}.asm"
```

---

## 9. Best Practices {#best-practices}

### Convenzioni di Codifica

```assembly
; 1. COMMENTI CHIARI
; Usa commenti per spiegare la logica, non l'ovvio

; MALE:
mov eax, 5          ; muove 5 in eax

; BENE:
mov eax, 5          ; inizializza contatore loop

; 2. INDENTAZIONE CONSISTENTE
section .text
    global _start

_start:
    mov eax, 1      ; 4 spazi di indentazione
    mov ebx, 0
    int 0x80

; 3. NOMI SIGNIFICATIVI PER ETICHETTE
; MALE:
label1:
    mov eax, 4
    jmp label2

; BENE:
print_message:
    mov eax, 4
    jmp cleanup

; 4. SEPARAZIONE LOGICA
section .data
    ; Costanti e messaggi
    msg1 db 'Hello', 0
    msg2 db 'World', 0

section .bss
    ; Buffer e variabili
    buffer resb 100
    counter resd 1

section .text
    ; Codice principale
    global _start

; 5. PROCEDURE BEN DEFINITE
; Documenta input/output
; Input: EAX = numero
; Output: EAX = numero * 2
; Modifica: nessun altro registro
double_number:
    shl eax, 1
    ret
```

### Gestione degli Errori

```assembly
section .data
    error_msg db 'Errore durante l\'operazione', 0xA
    error_len equ $ - error_msg

section .text

; Procedura per stampare errore ed uscire
print_error:
    mov eax, 4
    mov ebx, 2              ; stderr invece di stdout
    mov ecx, error_msg
    mov edx, error_len
    int 0x80
    
    mov eax, 1              ; exit
    mov ebx, 1              ; exit code 1 (errore)
    int 0x80

; Esempio di utilizzo
_start:
    ; Tenta un'operazione
    mov eax, 5
    mov ebx, 0
    
    ; Verifica divisione per zero
    cmp ebx, 0
    je print_error          ; Salta a errore se zero
    
    div ebx                 ; Altrimenti dividi
```

### Ottimizzazione

```assembly
; 1. USA ISTRUZIONI PIÙ VELOCI

; LENTO:
mov eax, 0

; VELOCE:
xor eax, eax            ; Azzera EAX (più veloce)

; 2. EVITA ACCESSI MEMORIA INUTILI

; LENTO:
mov [var], eax
mov ebx, [var]

; VELOCE:
mov [var], eax
mov ebx, eax            ; Usa il registro invece di rileggere

; 3. USA SHIFT INVECE DI MUL/DIV PER POTENZE DI 2

; LENTO:
mov eax, 5
mov ebx, 4
mul ebx                 ; 5 * 4

; VELOCE:
mov eax, 5
shl eax, 2              ; 5 * 4 (shift left 2 = * 4)

; 4. ALLINEA DATI IMPORTANTI

section .data
    align 4                 ; Allinea a 4 byte
    important_var dd 0
```

---

## 10. Troubleshooting {#troubleshooting}

### Errori Comuni e Soluzioni

#### Errore: "No such file or directory"

```bash
# Problema: file non trovato
$ nasm -f elf32 hello.asm
nasm: fatal: unable to open input file `hello.asm'

# Soluzione: verifica il percorso
$ ls -la hello.asm
$ pwd
```

#### Errore: "undefined reference to `_start`"

```bash
# Problema: entry point non definito
$ ld -m elf_i386 hello.o -o hello
ld: warning: cannot find entry symbol _start

# Soluzione: assicurati di avere
section .text
    global _start
_start:
    ; codice
```

#### Errore: Segmentation Fault

```bash
# Debug con GDB
$ gdb ./program
(gdb) run
Program received signal SIGSEGV, Segmentation fault.

# Cause comuni:
# 1. Accesso a memoria non valida
# 2. Stack overflow
# 3. Puntatore non inizializzato

# Verifica con:
(gdb) info registers
(gdb) x/10x $esp
```