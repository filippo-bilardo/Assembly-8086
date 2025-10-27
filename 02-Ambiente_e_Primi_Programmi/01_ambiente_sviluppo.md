# Ambiente di Sviluppo per Assembly 8086

## Introduzione

Prima di iniziare a programmare in assembly per l'8086, è necessario configurare un ambiente di sviluppo appropriato. Poiché l'8086 è un processore degli anni '70, non possiamo eseguirne il codice direttamente sui moderni computer. Useremo quindi **emulatori** e **assembler** specifici.

## Emulatori e Ambienti di Esecuzione

### DOSBox

**DOSBox** è un emulatore completo di sistema DOS, ideale per eseguire programmi 16-bit reali.

#### Caratteristiche
- ✅ Emula completamente l'ambiente DOS
- ✅ Supporta hardware vintage (scheda video, audio, ecc.)
- ✅ Multipiattaforma (Windows, Linux, macOS)
- ✅ Gratuito e open source
- ✅ Ottimo per programmi DOS reali

#### Installazione

**Windows:**
```bash
# Scarica da: https://www.dosbox.com/download.php?main=1
# Oppure con Chocolatey:
choco install dosbox
```

**Linux (Ubuntu/Debian):**
```bash
sudo apt-get update
sudo apt-get install dosbox
```

**Linux (Fedora):**
```bash
sudo dnf install dosbox
```

**macOS (Homebrew):**
```bash
brew install dosbox
```

#### Configurazione Base

1. Crea una cartella per i tuoi progetti:
```bash
mkdir ~/asm8086
```

2. Avvia DOSBox e monta la cartella:
```
mount c ~/asm8086
c:
```

3. (Opzionale) Crea un file di configurazione automatico:
```bash
# Modifica dosbox.conf (posizione varia per sistema)
# Aggiungi alla fine del file [autoexec]:
mount c ~/asm8086
c:
```

#### Comandi Utili DOSBox

```
MOUNT <lettera> <percorso>    Monta una cartella
DIR                           Lista file
CD <directory>                Cambia directory
TYPE <file>                   Visualizza file
CLS                           Pulisce lo schermo
EXIT                          Esci da DOSBox
```

### EMU8086

**EMU8086** è un ambiente integrato con emulatore, editor e debugger specifico per l'8086.

#### Caratteristiche
- ✅ Editor integrato con syntax highlighting
- ✅ Debugger visuale (registri, memoria, stack)
- ✅ Emulatore 8086 completo
- ✅ Esempi inclusi
- ✅ Interfaccia user-friendly
- ❌ Solo Windows (funziona con Wine su Linux)
- ❌ Non gratuito (versione trial disponibile)

#### Vantaggi per Principianti
- Visualizzazione in tempo reale di registri e memoria
- Step-by-step debugging
- Messaggi di errore chiari
- Include esempi e tutorial

#### Download
```
Sito ufficiale: http://www.emu8086.com/
Versione trial: funzionalità complete ma limitata nel tempo
```

### MASM (Microsoft Macro Assembler)

L'assembler originale Microsoft, ancora disponibile.

#### Installazione con MASM32
```
1. Scarica MASM32 SDK da: http://www.masm32.com/
2. Esegui l'installer
3. Aggiungi al PATH: C:\masm32\bin
```

### Alternative Moderne

#### NASM + QEMU
Per chi preferisce strumenti moderni:

```bash
# Linux
sudo apt-get install nasm qemu-system-x86

# macOS
brew install nasm qemu

# Windows
choco install nasm qemu
```

## Assembler: MASM, TASM, NASM

### MASM (Microsoft Macro Assembler)

**MASM** è l'assembler storico di Microsoft, molto usato per l'8086.

#### Sintassi
```assembly
.MODEL SMALL
.STACK 100h
.DATA
    messaggio DB 'Hello World!$'
.CODE
main PROC
    MOV AX, @DATA
    MOV DS, AX
    
    MOV AH, 09h
    LEA DX, messaggio
    INT 21h
    
    MOV AH, 4Ch
    INT 21h
main ENDP
END main
```

#### Caratteristiche
- Usa direttive `.MODEL`, `.DATA`, `.CODE`
- Sintassi Intel (destinazione prima, sorgente dopo)
- Supporto macro avanzato
- Case-insensitive di default

#### Processo di Build
```bash
# Assemblaggio
MASM programma.asm;

# Linking
LINK programma.obj;

# Esecuzione
programma.exe
```

### TASM (Turbo Assembler)

**TASM** è l'assembler di Borland, compatibile con MASM ma con estensioni.

#### Sintassi
```assembly
.MODEL SMALL
.STACK 100h
.DATA
    messaggio DB 'Hello with TASM!$'
.CODE
.STARTUP
    MOV AH, 09h
    LEA DX, messaggio
    INT 21h
.EXIT
END
```

#### Caratteristiche
- Molto simile a MASM
- Direttiva `.STARTUP` e `.EXIT` per semplificare
- Messaggi di errore più chiari
- Veloce compilazione

#### Processo di Build
```bash
# Assemblaggio
TASM programma.asm

# Linking
TLINK programma.obj

# Esecuzione
programma.exe
```

### NASM (Netwide Assembler)

**NASM** è un assembler moderno, multipiattaforma e open source.

#### Sintassi
```assembly
BITS 16
ORG 100h

section .data
    messaggio db 'Hello from NASM!$'

section .text
    mov ah, 09h
    mov dx, messaggio
    int 21h
    
    mov ah, 4Ch
    int 21h
```

#### Caratteristiche
- Sintassi più "pulita" e moderna
- Multipiattaforma (Windows, Linux, macOS)
- Open source e attivamente mantenuto
- Case-sensitive
- Ottima documentazione

#### Processo di Build
```bash
# Assemblaggio (file COM)
nasm -f bin programma.asm -o programma.com

# Assemblaggio (file OBJ)
nasm -f obj programma.asm -o programma.obj

# Linking (se necessario)
alink programma.obj -o programma.com

# Esecuzione (in DOSBox)
programma.com
```

## Confronto tra Assembler

| Caratteristica        | MASM          | TASM          | NASM          |
|-----------------------|---------------|---------------|---------------|
| **Piattaforma**       | Windows       | Windows/DOS   | Multi         |
| **Licenza**           | Proprietaria  | Proprietaria  | BSD (libera)  |
| **Case Sensitivity**  | No            | No            | Sì            |
| **Sintassi**          | Intel         | Intel         | Intel/AT&T    |
| **Macro**             | Avanzate      | Avanzate      | Buone         |
| **Documentazione**    | Buona         | Buona         | Eccellente    |
| **Curva Apprendimento** | Media       | Media         | Facile        |
| **Uso Moderno**       | Limitato      | Limitato      | Molto usato   |

## Differenze Sintattiche Principali

### Dichiarazione Segmenti

**MASM/TASM:**
```assembly
.MODEL SMALL
.STACK 100h
.DATA
    var1 DB 10
.CODE
main PROC
    ; codice
main ENDP
END main
```

**NASM:**
```assembly
BITS 16
ORG 100h

section .data
    var1 db 10

section .text
start:
    ; codice
```

### Direttive Dati

**MASM/TASM:**
```assembly
byte_var    DB 42           ; Define Byte
word_var    DW 1234h        ; Define Word
dword_var   DD 12345678h    ; Define Double Word
string_var  DB 'Hello$'
array_var   DB 10, 20, 30
```

**NASM:**
```assembly
byte_var    db 42           ; define byte (lowercase)
word_var    dw 1234h        ; define word
dword_var   dd 12345678h    ; define double word
string_var  db 'Hello$'
array_var   db 10, 20, 30
```

### Etichette e Procedure

**MASM/TASM:**
```assembly
procedura PROC
    PUSH BP
    MOV BP, SP
    ; corpo
    POP BP
    RET
procedura ENDP
```

**NASM:**
```assembly
procedura:
    push bp
    mov bp, sp
    ; corpo
    pop bp
    ret
```

### Offset e Segment

**MASM/TASM:**
```assembly
MOV AX, OFFSET variabile    ; Ottiene offset
MOV AX, SEG variabile       ; Ottiene segmento
LEA BX, variabile           ; Load Effective Address
```

**NASM:**
```assembly
mov ax, variabile           ; Offset automatico in .COM
lea bx, [variabile]         ; Sintassi più esplicita
```

## Strumenti di Debug

### DEBUG.EXE (DOS)

Debugger a riga di comando incluso in DOS.

#### Comandi Principali
```
R               Visualizza/modifica registri
D [indirizzo]   Dump memoria
U [indirizzo]   Unassemble (disassembla)
G [indirizzo]   Go (esegui)
T               Trace (step)
A [indirizzo]   Assemble inline
Q               Quit
```

#### Esempio di Sessione
```
C:\> debug programma.com
-r                  ; Mostra registri
-u 100              ; Disassembla da CS:100
-t                  ; Esegui un'istruzione
-g                  ; Esegui fino al breakpoint
-q                  ; Esci
```

### TD (Turbo Debugger)

Debugger avanzato di Borland.

#### Caratteristiche
- Interfaccia full-screen
- Visualizzazione codice, registri, memoria, stack
- Breakpoint condizionali
- Watch expressions

### EMU8086 Debugger

Debugger integrato visuale.

#### Caratteristiche
- Visualizzazione grafica di registri
- Memory viewer esadecimale
- Stack viewer
- Step into/over/out
- Breakpoint con click

## Configurazione Ambiente Consigliata

### Per Principianti

**Opzione 1: EMU8086 (più semplice)**
```
1. Installa EMU8086
2. Usa l'editor integrato
3. Debug visuale
4. Ideale per imparare
```

**Opzione 2: DOSBox + TASM**
```
1. Installa DOSBox
2. Scarica TASM
3. Usa un editor esterno (VS Code, Notepad++)
4. Compila e testa in DOSBox
```

### Per Utenti Avanzati

**Opzione: NASM + DOSBox/QEMU**
```
1. Installa NASM (nativo nel tuo OS)
2. Scrivi codice in un editor moderno
3. Compila con NASM
4. Testa in DOSBox o QEMU
5. Maggior controllo e portabilità
```

## Configurazione VS Code per Assembly

### Installazione Estensioni

```json
// Estensioni consigliate:
"extensions": [
    "13xforever.language-x86-64-assembly",
    "maziac.asm-code-lens",
    "blindtiger.masm"
]
```

### Configurazione tasks.json

```json
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "Assemble with NASM",
            "type": "shell",
            "command": "nasm",
            "args": [
                "-f", "bin",
                "${file}",
                "-o", "${fileDirname}/${fileBasenameNoExtension}.com"
            ],
            "group": {
                "kind": "build",
                "isDefault": true
            }
        },
        {
            "label": "Run in DOSBox",
            "type": "shell",
            "command": "dosbox",
            "args": [
                "${fileDirname}/${fileBasenameNoExtension}.com"
            ],
            "dependsOn": "Assemble with NASM"
        }
    ]
}
```

## Script di Automazione

### Build Script (build.bat)

```batch
@echo off
echo Assembling %1.asm...
nasm -f bin %1.asm -o %1.com
if errorlevel 1 goto error

echo Running in DOSBox...
dosbox %1.com -exit
goto end

:error
echo Assembly failed!
pause

:end
```

### Build Script Linux (build.sh)

```bash
#!/bin/bash
if [ -z "$1" ]; then
    echo "Usage: ./build.sh filename (without .asm)"
    exit 1
fi

echo "Assembling $1.asm..."
nasm -f bin "$1.asm" -o "$1.com"

if [ $? -eq 0 ]; then
    echo "Running in DOSBox..."
    dosbox "$1.com" -exit
else
    echo "Assembly failed!"
    exit 1
fi
```

## Template di Progetto

### Struttura Consigliata

```
mio-progetto/
├── src/
│   ├── main.asm
│   ├── utils.asm
│   └── data.asm
├── include/
│   └── macros.inc
├── build/
│   └── (file compilati)
├── docs/
│   └── README.md
└── Makefile
```

### Makefile Esempio

```makefile
# Makefile per progetti Assembly 8086

ASM = nasm
ASMFLAGS = -f bin
SRC_DIR = src
BUILD_DIR = build

SOURCES = $(wildcard $(SRC_DIR)/*.asm)
TARGETS = $(patsubst $(SRC_DIR)/%.asm,$(BUILD_DIR)/%.com,$(SOURCES))

all: $(TARGETS)

$(BUILD_DIR)/%.com: $(SRC_DIR)/%.asm
	@mkdir -p $(BUILD_DIR)
	$(ASM) $(ASMFLAGS) $< -o $@

clean:
	rm -f $(BUILD_DIR)/*

run: all
	dosbox $(BUILD_DIR)/main.com -exit

.PHONY: all clean run
```

## Risoluzione Problemi Comuni

### Problema: "Illegal instruction"
**Causa:** Istruzione non supportata dall'8086  
**Soluzione:** Verifica la compatibilità delle istruzioni

### Problema: "Segment not defined"
**Causa:** Segmento non dichiarato  
**Soluzione:** Aggiungi `.MODEL`, `.DATA`, `.CODE` (MASM/TASM)

### Problema: File .COM non si avvia
**Causa:** Formato errato o ORG mancante  
**Soluzione:** Aggiungi `ORG 100h` per file .COM

### Problema: Caratteri strani in output
**Causa:** Codepage DOS diversa  
**Soluzione:** Usa solo ASCII standard o configura codepage

## Risorse Online

### Documentazione
- **Intel 8086 Manual**: http://www.intel.com (archivio storico)
- **NASM Documentation**: https://www.nasm.us/doc/
- **Art of Assembly**: http://www.plantation-productions.com/Webster/

### Tutorial e Guide
- **OSDev Wiki**: https://wiki.osdev.org/
- **x86 Assembly Guide**: http://www.cs.virginia.edu/~evans/cs216/guides/x86.html

### Strumenti Online
- **Compiler Explorer (Godbolt)**: https://godbolt.org/
- **OnlineGDB**: https://www.onlinegdb.com/ (supporto assembly)

## Checklist: Ambiente Pronto

Prima di iniziare a programmare, verifica:

- [ ] Emulatore installato (DOSBox o EMU8086)
- [ ] Assembler installato (MASM, TASM o NASM)
- [ ] Editor configurato (VS Code, Notepad++ o altro)
- [ ] Primo test compilato ed eseguito con successo
- [ ] Debugger funzionante (opzionale ma consigliato)
- [ ] Documentazione di riferimento scaricata

## Esercizi Pratici

1. Installa DOSBox e verifica che funzioni
2. Installa almeno un assembler (consiglio NASM)
3. Compila uno dei programmi di esempio del prossimo capitolo
4. Esegui il programma in DOSBox
5. (Opzionale) Configura VS Code con syntax highlighting

---

**Torna all'indice:** [README - Corso Assembly 8086](../README.md)  
**Prossimo argomento:** [Primo Programma: Hello World](02_hello_world.md)
