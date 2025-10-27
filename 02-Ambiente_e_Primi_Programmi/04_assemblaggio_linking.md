# Processo di Assemblaggio e Linking

## Introduzione

Trasformare codice assembly in un programma eseguibile richiede due fasi principali:
1. **Assemblaggio**: conversione da codice assembly a codice oggetto
2. **Linking**: combinazione dei moduli oggetto in un eseguibile

Comprendere questo processo aiuta a debuggare errori e ottimizzare il workflow di sviluppo.

## Panoramica del Processo

```
┌─────────────────┐
│  file.asm       │  Codice sorgente Assembly
│  (testo)        │
└────────┬────────┘
         │
         ▼
    ┌────────┐
    │  ASM   │  Assembler (MASM, TASM, NASM)
    └────┬───┘
         │
         ▼
┌─────────────────┐
│  file.obj       │  File oggetto (codice macchina + metadata)
│  (binario)      │
└────────┬────────┘
         │
         ▼
    ┌────────┐
    │  LINK  │  Linker (LINK, TLINK, ALINK)
    └────┬───┘
         │
         ▼
┌─────────────────┐
│  file.exe/.com  │  Programma eseguibile
│  (binario)      │
└─────────────────┘
```

## Fase 1: Assemblaggio

### Cos'è l'Assemblaggio?

L'**assembler** converte codice assembly (leggibile dall'uomo) in **codice macchina** (eseguibile dal processore).

**Input**: File .ASM (testo)
**Output**: File .OBJ (binario)

### Come Funziona l'Assembler

#### Pass 1: Scansione Simboli

L'assembler legge il codice e:
1. Costruisce la **symbol table** (tabella dei simboli)
2. Assegna indirizzi a etichette e variabili
3. Calcola dimensioni di dati e istruzioni

**Esempio:**
```assembly
.DATA
    var1 DB 10          ; Offset: 0000h, Size: 1
    var2 DW 1234h       ; Offset: 0001h, Size: 2
    array DB 10 DUP(0)  ; Offset: 0003h, Size: 10

.CODE
main PROC              ; Offset: 0000h
    MOV AX, 1          ; Offset: 0000h, Size: 3
    ADD AX, 2          ; Offset: 0003h, Size: 3
main ENDP
```

**Symbol Table generata:**
```
Simbolo    Tipo      Segmento  Offset  Dimensione
-------    ----      --------  ------  ----------
var1       BYTE      DATA      0000h   1
var2       WORD      DATA      0001h   2
array      BYTE      DATA      0003h   10
main       PROC      CODE      0000h   -
```

#### Pass 2: Generazione Codice

L'assembler genera il codice macchina:
1. Traduce ogni istruzione in opcode
2. Risolve riferimenti a simboli
3. Genera il file .OBJ

**Esempio di traduzione:**
```assembly
MOV AX, 1       →  B8 01 00
ADD AX, 2       →  05 02 00
```

Breakdown:
```
MOV AX, imm16:
    Opcode: B8
    Immediate: 01 00 (little-endian)

ADD AX, imm16:
    Opcode: 05
    Immediate: 02 00 (little-endian)
```

### Formati di Output

#### File .OBJ (Object File)

Contiene:
- **Codice macchina**: istruzioni tradotte
- **Dati inizializzati**: valori delle variabili
- **Symbol table**: nomi e indirizzi dei simboli
- **Relocation table**: riferimenti da risolvere nel linking
- **Debug information**: informazioni per il debugger (opzionale)

**Struttura semplificata:**
```
┌──────────────────────┐
│  Header              │  Informazioni sul file
├──────────────────────┤
│  Code Segment        │  Codice macchina
├──────────────────────┤
│  Data Segment        │  Dati inizializzati
├──────────────────────┤
│  Symbol Table        │  Simboli definiti/richiesti
├──────────────────────┤
│  Relocation Table    │  Riferimenti da aggiustare
├──────────────────────┤
│  Debug Info          │  Opzionale
└──────────────────────┘
```

#### File .COM (Direct Binary)

Per file .COM, NASM può generare direttamente il binario:
```bash
nasm -f bin file.asm -o file.com
```

**Caratteristiche .COM:**
- Binario puro, nessun header
- Massimo 64KB (codice + dati + stack)
- Caricato sempre a offset 100h
- Più semplice ma limitato

**Struttura in memoria .COM:**
```
0000h - 00FFh: PSP (Program Segment Prefix)
0100h - ????h: Codice + Dati
```

## Fase 2: Linking

### Cos'è il Linking?

Il **linker** combina uno o più file .OBJ in un eseguibile.

**Input**: Uno o più file .OBJ + librerie
**Output**: File .EXE o .COM

### Compiti del Linker

1. **Risoluzione simboli**: collega chiamate a definizioni
2. **Relocation**: aggiusta indirizzi per il caricamento
3. **Combinazione segmenti**: unisce segmenti da file multipli
4. **Generazione header**: crea header .EXE

### Risoluzione dei Simboli

#### Simboli Interni

Definiti e usati nello stesso modulo:
```assembly
; file1.asm
.DATA
    var DB 10
.CODE
    MOV AL, var     ; Risolto dall'assembler
```

#### Simboli Esterni

Definiti in un modulo, usati in altri:

**Modulo 1 (funzioni.asm):**
```assembly
PUBLIC calcola       ; Esporta 'calcola'

.CODE
calcola PROC
    MOV AX, 100
    RET
calcola ENDP
```

**Modulo 2 (main.asm):**
```assembly
EXTRN calcola:PROC   ; Importa 'calcola'

.CODE
main PROC
    CALL calcola     ; Risolto dal linker
    MOV AH, 4Ch
    INT 21h
main ENDP
END main
```

**Processo di linking:**
```
1. Linker legge main.obj:
   - Trova riferimento non risolto: 'calcola'

2. Linker legge funzioni.obj:
   - Trova definizione di 'calcola' a offset XYZ

3. Linker aggiorna main.obj:
   - CALL calcola → CALL [indirizzo di calcola]
```

### Relocation

Il linker deve aggiustare indirizzi per il caricamento in memoria.

**Problema**: Il codice .OBJ assume offset da 0, ma il programma potrebbe essere caricato altrove.

**Soluzione**: Tabella di relocation + aggiustamenti.

**Esempio:**
```assembly
; Codice originale
MOV AX, [var]       ; var a offset 0100h

; Nel .OBJ
; MOV AX, [0100h]   ; Indirizzo fisso

; Il linker crea:
; Relocation entry: "aggiusta offset 0100h con base segmento dati"

; Quando caricato (es. DS=2000h):
; Indirizzo effettivo: 2000:0100
```

### File .EXE

#### Struttura File .EXE

```
┌──────────────────────┐
│  EXE Header          │  28 byte + relocation table
├──────────────────────┤
│  Code Segment        │  Codice del programma
├──────────────────────┤
│  Data Segment        │  Dati del programma
├──────────────────────┤
│  Stack Segment       │  Stack (se definito)
└──────────────────────┘
```

#### Header .EXE (Semplificato)

```
Offset  Size  Description
------  ----  -----------
00h     2     Signature ('MZ' = 4D 5A)
02h     2     Bytes in last page
04h     2     Pages in file
06h     2     Relocation items
08h     2     Header size in paragraphs
0Ah     2     Minimum paragraphs needed
0Ch     2     Maximum paragraphs needed
0Eh     2     Initial SS value
10h     2     Initial SP value
12h     2     Checksum
14h     2     Initial IP value
16h     2     Initial CS value
18h     2     Relocation table offset
```

#### Processo di Caricamento .EXE

1. DOS legge l'header
2. Alloca memoria (MIN paragraphs)
3. Carica codice e dati
4. Applica relocation (aggiusta indirizzi)
5. Imposta CS:IP e SS:SP
6. Trasferisce controllo al programma

## Comandi di Assemblaggio e Linking

### MASM (Microsoft Macro Assembler)

#### Assemblaggio

```batch
REM Sintassi base
MASM file.asm;

REM Con opzioni
MASM file.asm, file.obj, file.lst, file.crf;

REM Opzioni utili
MASM /Zi file.asm;        REM Debug info
MASM /Zd file.asm;        REM Line numbers only
MASM /D_DEBUG file.asm;   REM Define simbolo _DEBUG
```

**Opzioni comuni:**
- `/Zi`: Includi informazioni complete di debug
- `/Zd`: Includi solo numeri di linea
- `/D<name>`: Definisci simbolo
- `/I<path>`: Directory per INCLUDE

#### Linking

```batch
REM Sintassi base
LINK file.obj;

REM Con opzioni
LINK file1.obj + file2.obj, program.exe, program.map;

REM Con librerie
LINK file.obj, , , library.lib;
```

**Opzioni comuni:**
- `/CO`: Informazioni per CodeView debugger
- `/MAP`: Genera file .MAP
- `/NOI`: Case-sensitive

### TASM (Turbo Assembler)

#### Assemblaggio

```batch
REM Sintassi base
TASM file.asm

REM Con opzioni
TASM /zi /l file.asm

REM Opzioni utili
TASM /zi file.asm         REM Debug info
TASM /l file.asm          REM Genera listing
TASM /m2 file.asm         REM Multi-pass per forward reference
```

**Opzioni comuni:**
- `/zi`: Debug information
- `/l`: Genera file listing (.LST)
- `/m<n>`: Numero di pass (1-9)
- `/d<name>`: Definisci simbolo

#### Linking

```batch
REM Sintassi base
TLINK file.obj

REM Con opzioni
TLINK /v file.obj

REM Moduli multipli
TLINK file1.obj file2.obj
```

**Opzioni comuni:**
- `/v`: Include debug info
- `/m`: Genera map file
- `/t`: Genera .COM invece di .EXE

### NASM (Netwide Assembler)

#### Assemblaggio

```bash
# Sintassi base
nasm file.asm

# Specificare formato output
nasm -f bin file.asm -o file.com      # Binario (.COM)
nasm -f obj file.asm -o file.obj      # Object (.OBJ)
nasm -f elf file.asm -o file.o        # ELF (Linux)

# Con listing
nasm -f bin file.asm -o file.com -l file.lst

# Con simboli di debug
nasm -f obj -g file.asm -o file.obj
```

**Formati output (-f):**
- `bin`: Binario puro (.COM)
- `obj`: Microsoft OMF object file
- `elf`: ELF (Linux)
- `coff`: COFF (Windows)
- `win32`/`win64`: PE executables

**Opzioni comuni:**
- `-o <file>`: Specifica output file
- `-l <file>`: Genera listing
- `-g`: Include debug info
- `-D<name>`: Definisci macro
- `-I<path>`: Include path

#### Linking (con ALINK)

```bash
# Sintassi base
alink file.obj -o file.com

# Formato .EXE
alink file.obj -oPE file.exe

# Moduli multipli
alink file1.obj file2.obj -o program.exe
```

## File Ausiliari

### Listing File (.LST)

File di testo che mostra il codice generato.

**Esempio:**
```
Microsoft (R) Macro Assembler Version 6.11          12/01/24 10:30:00
file.asm                                             Page 1-1

                                .MODEL SMALL
                                .STACK 100h
                                .DATA
 0000 0A                        var DB 10
                                .CODE
                                main PROC
 0000  B8 ---- R                   MOV AX, @DATA
 0003  8E D8                       MOV DS, AX
 0005  A0 0000 R                   MOV AL, var
 0008  B4 4C                       MOV AH, 4Ch
 000A  CD 21                       INT 21h
                                main ENDP
                                END main
```

**Contenuto:**
- Offset di ogni istruzione
- Codice macchina generato
- Codice sorgente originale
- Simboli con `R` (relocatable)

### Map File (.MAP)

Mostra la disposizione dei segmenti in memoria.

**Esempio:**
```
Start  Stop   Length Name               Class
00000H 00009H 0000AH _TEXT              CODE
00010H 00010H 00001H _DATA              DATA
00020H 0011FH 00100H STACK              STACK

Program entry point at 0000:0000
```

**Informazioni incluse:**
- Indirizzo e dimensione di ogni segmento
- Entry point del programma
- Simboli pubblici e loro indirizzi

### Cross-Reference File (.CRF)

Elenca dove ogni simbolo viene definito e usato.

**Generazione:**
```batch
MASM file.asm,,,file.crf;
CREF file.crf, file.ref;
```

**Contenuto .REF:**
```
Symbol    Type    Defined   Referenced
------    ----    -------   ----------
var       BYTE    3         7, 12
main      PROC    5         23
calcola   PROC    15        9, 11, 20
```

## Processo Completo: Esempio Pratico

### Progetto Multi-File

**File 1: math.asm**
```assembly
; math.asm - Funzioni matematiche
PUBLIC somma, sottrai

.CODE
somma PROC
    ; AX = primo numero
    ; BX = secondo numero
    ; Ritorna: AX = somma
    ADD AX, BX
    RET
somma ENDP

sottrai PROC
    ; AX = primo numero
    ; BX = secondo numero
    ; Ritorna: AX = differenza
    SUB AX, BX
    RET
sottrai ENDP
END
```

**File 2: main.asm**
```assembly
; main.asm - Programma principale
EXTRN somma:PROC, sottrai:PROC

.MODEL SMALL
.STACK 100h
.DATA
    num1 DW 50
    num2 DW 30
    risultato DW ?

.CODE
main PROC
    MOV AX, @DATA
    MOV DS, AX
    
    ; Calcola somma
    MOV AX, num1
    MOV BX, num2
    CALL somma          ; Chiamata esterna
    MOV risultato, AX
    
    ; Termina
    MOV AH, 4Ch
    INT 21h
main ENDP
END main
```

### Build Process

```batch
REM 1. Assemblaggio
MASM math.asm;
MASM main.asm;

REM Genera:
REM   math.obj
REM   main.obj

REM 2. Linking
LINK main.obj + math.obj, program.exe;

REM Genera:
REM   program.exe
REM   program.map (opzionale)

REM 3. Esecuzione
program.exe
```

### Cosa Succede nel Linking

```
1. Linker legge main.obj:
   - Trova: EXTRN somma:PROC
   - Crea: "somma" nella lista simboli esterni

2. Linker legge math.obj:
   - Trova: PUBLIC somma
   - Definizione di somma all'offset 0000h di math.obj

3. Linker risolve:
   - CALL somma in main.obj
   - Sostituisce con indirizzo effettivo di somma

4. Linker combina segmenti:
   - CODE di main.obj
   - CODE di math.obj
   - Entrambi nello stesso segmento di codice

5. Linker genera .EXE:
   - Header con entry point (main)
   - Codice combinato
   - Dati
   - Tabella di relocation
```

## Makefile per Automazione

### Makefile per MASM

```makefile
# Makefile per MASM

ASM = masm
LINK = link
ASMFLAGS = /Zi
LINKFLAGS = /CO

OBJS = main.obj math.obj

program.exe: $(OBJS)
	$(LINK) $(LINKFLAGS) $(OBJS), program.exe;

main.obj: main.asm
	$(ASM) $(ASMFLAGS) main.asm;

math.obj: math.asm
	$(ASM) $(ASMFLAGS) math.asm;

clean:
	del *.obj
	del *.exe
	del *.map

run: program.exe
	dosbox program.exe -exit
```

### Makefile per NASM

```makefile
# Makefile per NASM

ASM = nasm
LINK = alink
ASMFLAGS = -f obj
LINKFLAGS = 

OBJS = main.obj math.obj

program.com: $(OBJS)
	$(LINK) $(LINKFLAGS) $(OBJS) -o program.com

%.obj: %.asm
	$(ASM) $(ASMFLAGS) $< -o $@

clean:
	rm -f *.obj *.com *.lst

run: program.com
	dosbox program.com -exit
```

## Debugging del Processo

### Errori Comuni di Assemblaggio

**Errore: "Undefined symbol"**
```
Causa: Simbolo usato ma non definito
Soluzione: Definisci il simbolo o aggiungi EXTRN
```

**Errore: "Phase error"**
```
Causa: Dimensione cambia tra pass 1 e 2
Soluzione: Usa SHORT/NEAR/FAR espliciti nei salti
```

**Errore: "Invalid instruction"**
```
Causa: Istruzione non valida per 8086
Soluzione: Verifica set istruzioni
```

### Errori Comuni di Linking

**Errore: "Unresolved external"**
```
Causa: Simbolo EXTRN non trovato in nessun .OBJ
Soluzione: Aggiungi modulo mancante o libreria
```

**Errore: "Duplicate symbol"**
```
Causa: Stesso simbolo PUBLIC in file multipli
Soluzione: Rimuovi duplicati o rinomina
```

**Errore: "Fixup overflow"**
```
Causa: Jump troppo lontano per SHORT
Soluzione: Usa NEAR o riorganizza codice
```

## Ottimizzazioni

### Riduci Dimensione .EXE

```assembly
; Usa .COM invece di .EXE per programmi piccoli
; .COM: no header, più piccolo

; Usa SHORT per salti vicini
JMP SHORT vicino    ; 2 byte invece di 3
```

### Tempo di Compilazione

```batch
REM TASM è più veloce di MASM
REM NASM è il più veloce
```

### Build Incrementale

```makefile
# Ricompila solo file modificati
program.exe: $(OBJS)
	$(LINK) $?      # Solo file cambiati
```

## Esercizi Pratici

1. Assembla e linka il programma Hello World con MASM
2. Crea un progetto multi-file (main + funzioni)
3. Genera e analizza il file .LST
4. Genera e analizza il file .MAP
5. Scrivi un Makefile per automatizzare il build

---

**Argomento precedente:** [Direttive dell'Assembler](modulo2_03_direttive_assembler.md)  
**Prossimo argomento:** [Domande di Autovalutazione - Modulo 2](modulo2_05_quiz.md)
