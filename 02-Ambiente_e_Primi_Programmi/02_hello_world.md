# Primo Programma: Hello World in Assembly 8086

## Introduzione

Il classico programma "Hello World" è il punto di partenza per imparare qualsiasi linguaggio di programmazione. In assembly 8086, scriverlo richiede di comprendere diversi concetti fondamentali: interruzioni DOS, segmentazione della memoria e direttive dell'assembler.

In questo capitolo analizzeremo tre versioni del programma Hello World usando sintassi diverse (MASM/TASM e NASM) e spiegheremo ogni singola linea di codice.

## Versione 1: MASM/TASM - Programma .EXE

### Codice Completo

```assembly
; ====================================
; HELLO.ASM - Primo programma in Assembly 8086
; Stampa "Hello, World!" sullo schermo
; Assembler: MASM o TASM
; Tipo: .EXE
; ====================================

.MODEL SMALL        ; Modello di memoria Small
.STACK 100h         ; Stack di 256 byte
.DATA               ; Inizio segmento dati
    messaggio DB 'Hello, World!$'   ; Stringa con terminatore $
    
.CODE               ; Inizio segmento codice
main PROC           ; Inizio procedura principale
    ; Inizializza il segmento dati
    MOV AX, @DATA   ; Carica indirizzo segmento dati in AX
    MOV DS, AX      ; Imposta DS al segmento dati
    
    ; Stampa la stringa
    MOV AH, 09h     ; Funzione 09h: stampa stringa
    LEA DX, messaggio   ; Carica offset della stringa in DX
    INT 21h         ; Chiama interruzione DOS
    
    ; Termina il programma
    MOV AH, 4Ch     ; Funzione 4Ch: termina programma
    INT 21h         ; Chiama interruzione DOS
main ENDP           ; Fine procedura principale
END main            ; Fine programma, entry point: main
```

### Analisi Linea per Linea

#### Direttive di Modello e Segmenti

```assembly
.MODEL SMALL
```
- **Scopo**: Definisce il modello di memoria del programma
- **SMALL**: Codice ≤ 64KB, Dati+Stack ≤ 64KB (un segmento per ciascuno)
- **Alternative**: TINY, COMPACT, MEDIUM, LARGE, HUGE

```assembly
.STACK 100h
```
- **Scopo**: Alloca spazio per lo stack
- **100h** = 256 byte (sufficiente per programmi semplici)
- Lo stack cresce verso il basso (da indirizzi alti a bassi)

```assembly
.DATA
```
- **Scopo**: Inizia il segmento dati
- Qui si dichiarano variabili e costanti
- Il segmento DS punterà a quest'area

```assembly
messaggio DB 'Hello, World!$'
```
- **DB**: Define Byte - direttiva per allocare byte
- **'Hello, World!'**: stringa ASCII
- **$**: terminatore richiesto dall'interruzione 09h del DOS
- In memoria: `48h 65h 6Ch 6Ch 6Fh 2Ch 20h ... 24h`

```assembly
.CODE
```
- **Scopo**: Inizia il segmento codice
- Il segmento CS punterà a quest'area
- Contiene le istruzioni eseguibili

#### Procedura Principale

```assembly
main PROC
```
- **PROC**: inizia una procedura
- **main**: nome della procedura (entry point del programma)

```assembly
MOV AX, @DATA
```
- **@DATA**: macro che restituisce l'indirizzo del segmento dati
- Non si può fare `MOV DS, @DATA` direttamente (DS non accetta immediati)
- Dobbiamo passare attraverso AX

```assembly
MOV DS, AX
```
- Imposta il registro DS al segmento dati
- Ora DS:offset punta correttamente alle variabili dichiarate in .DATA

#### Stampa della Stringa

```assembly
MOV AH, 09h
```
- Carica 09h nella parte alta di AX
- 09h = funzione DOS "Print String"
- Convenzione: numero di funzione sempre in AH

```assembly
LEA DX, messaggio
```
- **LEA**: Load Effective Address
- Carica in DX l'**offset** della stringa nel segmento dati
- Alternativa: `MOV DX, OFFSET messaggio`
- L'indirizzo completo sarà DS:DX

```assembly
INT 21h
```
- **INT**: Interrupt (interruzione software)
- **21h**: interruzione DOS (servizi del sistema operativo)
- Con AH=09h, stampa la stringa puntata da DS:DX fino al carattere '$'

**Cosa succede internamente:**
1. Il processore salva IP e CS nello stack
2. Salta alla routine DOS per la funzione 09h
3. La routine legge i byte da DS:DX fino a trovare '$'
4. Ogni byte viene stampato sullo schermo
5. Ritorna al programma (IRET)

#### Terminazione del Programma

```assembly
MOV AH, 4Ch
```
- Funzione DOS 4Ch: "Terminate Program"
- Modo standard per uscire da un programma DOS

```assembly
INT 21h
```
- Chiama l'interruzione DOS
- Il programma termina e ritorna al DOS
- Eventuali risorse vengono liberate

```assembly
main ENDP
```
- **ENDP**: End Procedure
- Chiude la definizione della procedura main

```assembly
END main
```
- **END**: Fine del codice sorgente assembly
- **main**: specifica il punto di ingresso (entry point)
- Il linker userà questa informazione

### Compilazione ed Esecuzione

#### Con MASM

```batch
REM Assemblaggio
MASM hello.asm;

REM Se ci sono errori, MASM li mostrerà qui

REM Linking
LINK hello.obj;

REM Esecuzione
hello.exe
```

#### Con TASM

```batch
REM Assemblaggio
TASM hello.asm

REM Linking
TLINK hello.obj

REM Esecuzione
hello.exe
```

### Output Atteso

```
Hello, World!
```

## Versione 2: NASM - Programma .COM

I file .COM sono più semplici dei .EXE: hanno un unico segmento e iniziano sempre all'offset 100h.

### Codice Completo

```assembly
; ====================================
; HELLO.ASM - Hello World in NASM
; Tipo: .COM (formato più semplice)
; ====================================

BITS 16             ; Codice a 16 bit
ORG 100h            ; Origine a 100h (richiesto per .COM)

section .data       ; Sezione dati
    messaggio db 'Hello, World!$'

section .text       ; Sezione codice
start:
    ; Stampa la stringa
    mov ah, 09h     ; Funzione DOS: stampa stringa
    mov dx, messaggio   ; Offset della stringa
    int 21h         ; Chiama DOS
    
    ; Termina il programma
    mov ah, 4Ch     ; Funzione DOS: termina
    int 21h         ; Chiama DOS
```

### Differenze Rispetto a MASM

#### Direttive Iniziali

```assembly
BITS 16
```
- Dice a NASM di generare codice a 16 bit
- Necessario perché NASM supporta anche 32 e 64 bit

```assembly
ORG 100h
```
- **ORG**: Origin (origine)
- I file .COM vengono caricati all'offset 100h
- I primi 100h byte (256 byte) sono riservati al PSP (Program Segment Prefix)
- Tutte le etichette sono calcolate a partire da 100h

**Struttura memoria .COM:**
```
0000h - 00FFh: PSP (Program Segment Prefix)
0100h - ????h: Codice del programma
```

#### Sezioni vs Segmenti

```assembly
section .data
section .text
```
- NASM usa `section` invece di `.DATA`/`.CODE`
- Sintassi più Unix-like
- `.data` = dati, `.text` = codice (terminologia UNIX)

#### Nessuna Inizializzazione DS

Nel formato .COM:
- CS = DS = ES = SS (tutti i segmenti coincidono)
- Non serve inizializzare DS
- Tutto è nello stesso segmento da 64KB

#### Etichette invece di PROC

```assembly
start:
```
- NASM usa etichette semplici (con `:`)
- Non c'è bisogno di `PROC`/`ENDP`

#### Caricamento Diretto in DX

```assembly
mov dx, messaggio
```
- In formato .COM, `messaggio` è già un offset valido
- Non serve `LEA` o `OFFSET`

### Compilazione ed Esecuzione

```bash
# Assemblaggio
nasm -f bin hello.asm -o hello.com

# Esecuzione (in DOSBox)
dosbox hello.com -exit
```

**Opzioni NASM:**
- `-f bin`: formato binario grezzo (per .COM)
- `-o hello.com`: nome del file di output

## Versione 3: MASM con .STARTUP/.EXIT

TASM offre macro semplificate per l'inizializzazione e la terminazione.

### Codice Completo

```assembly
.MODEL SMALL
.STACK 100h
.DATA
    messaggio DB 'Hello with shortcuts!$'
    
.CODE
.STARTUP            ; Macro: inizializza DS e entry point
    MOV AH, 09h
    LEA DX, messaggio
    INT 21h
.EXIT               ; Macro: termina il programma
END
```

### Macro .STARTUP

Si espande in:
```assembly
main PROC
    MOV AX, @DATA
    MOV DS, AX
```

### Macro .EXIT

Si espande in:
```assembly
    MOV AH, 4Ch
    INT 21h
main ENDP
END main
```

**Vantaggi:**
- Meno codice boilerplate
- Meno errori per principianti

**Svantaggi:**
- Nasconde ciò che accade realmente
- Meno controllo
- Non standard (specifico TASM)

## Interruzioni DOS - Approfondimento

### INT 21h - Servizi DOS

L'interruzione 21h fornisce numerosi servizi del sistema operativo.

#### Funzioni Comuni

| AH   | Funzione                    | Input            | Output        |
|------|-----------------------------|------------------|---------------|
| 01h  | Input carattere con echo    | -                | AL=carattere  |
| 02h  | Output carattere            | DL=carattere     | -             |
| 09h  | Output stringa              | DS:DX=stringa    | -             |
| 0Ah  | Input stringa               | DS:DX=buffer     | Stringa letta |
| 4Ch  | Termina programma           | AL=exit code     | -             |

### Esempio: Stampa Carattere Singolo

```assembly
MOV AH, 02h     ; Funzione 02h: stampa carattere
MOV DL, 'A'     ; Carattere da stampare
INT 21h         ; Stampa 'A'
```

### Esempio: Input Carattere

```assembly
MOV AH, 01h     ; Funzione 01h: leggi carattere
INT 21h         ; Attende input
; AL contiene il carattere premuto
```

## INT 10h - Servizi Video BIOS

Interruzione del BIOS per controllo video.

### Esempio: Stampa con INT 10h

```assembly
.MODEL SMALL
.CODE
main PROC
    MOV AH, 0Eh     ; Funzione 0Eh: teletype output
    MOV AL, 'H'     ; Carattere da stampare
    MOV BH, 0       ; Pagina video
    INT 10h         ; Stampa 'H'
    
    MOV AL, 'i'
    INT 10h         ; Stampa 'i'
    
    MOV AH, 4Ch
    INT 21h
main ENDP
END main
```

**Differenza da INT 21h/09h:**
- INT 10h stampa un carattere alla volta
- Più controllo (colore, posizione cursore)
- INT 21h/09h è più veloce per stringhe

## Programmi di Esempio Aggiuntivi

### Esempio 1: Stampa Multipla

```assembly
.MODEL SMALL
.STACK 100h
.DATA
    msg1 DB 'Prima riga$'
    msg2 DB 13, 10, 'Seconda riga$'  ; 13=CR, 10=LF (a capo)
    msg3 DB 13, 10, 'Terza riga$'
    
.CODE
main PROC
    MOV AX, @DATA
    MOV DS, AX
    
    ; Stampa prima riga
    MOV AH, 09h
    LEA DX, msg1
    INT 21h
    
    ; Stampa seconda riga
    LEA DX, msg2
    INT 21h
    
    ; Stampa terza riga
    LEA DX, msg3
    INT 21h
    
    MOV AH, 4Ch
    INT 21h
main ENDP
END main
```

**Output:**
```
Prima riga
Seconda riga
Terza riga
```

### Esempio 2: Stampa con Loop

```assembly
.MODEL SMALL
.STACK 100h
.DATA
    carattere DB 'A'
    
.CODE
main PROC
    MOV AX, @DATA
    MOV DS, AX
    
    MOV CX, 26      ; 26 lettere dell'alfabeto
    MOV DL, 'A'     ; Inizia da 'A'
    
stampa_loop:
    MOV AH, 02h     ; Funzione: stampa carattere
    INT 21h
    INC DL          ; Prossimo carattere
    LOOP stampa_loop
    
    MOV AH, 4Ch
    INT 21h
main ENDP
END main
```

**Output:**
```
ABCDEFGHIJKLMNOPQRSTUVWXYZ
```

### Esempio 3: Input e Output

```assembly
.MODEL SMALL
.STACK 100h
.DATA
    prompt DB 'Premi un tasto: $'
    msg DB 13, 10, 'Hai premuto: $'
    
.CODE
main PROC
    MOV AX, @DATA
    MOV DS, AX
    
    ; Stampa prompt
    MOV AH, 09h
    LEA DX, prompt
    INT 21h
    
    ; Leggi carattere
    MOV AH, 01h
    INT 21h         ; Carattere in AL
    MOV BL, AL      ; Salva in BL
    
    ; Stampa messaggio
    MOV AH, 09h
    LEA DX, msg
    INT 21h
    
    ; Stampa carattere letto
    MOV AH, 02h
    MOV DL, BL
    INT 21h
    
    MOV AH, 4Ch
    INT 21h
main ENDP
END main
```

**Esecuzione:**
```
Premi un tasto: K
Hai premuto: K
```

## Struttura Tipica di un Programma

### Template Base

```assembly
; ====================================
; Nome: TEMPLATE.ASM
; Descrizione: Template base per programmi 8086
; Autore: [Nome]
; Data: [Data]
; ====================================

.MODEL SMALL
.STACK 100h

.DATA
    ; Dichiarazione variabili e costanti
    ; ...

.CODE
main PROC
    ; Inizializzazione segmento dati
    MOV AX, @DATA
    MOV DS, AX
    
    ; --------------------------------
    ; Corpo principale del programma
    ; --------------------------------
    
    
    ; --------------------------------
    ; Terminazione
    ; --------------------------------
    MOV AH, 4Ch
    INT 21h
main ENDP

; ====================================
; Procedure aggiuntive
; ====================================

; procedura1 PROC
;     ...
;     RET
; procedura1 ENDP

END main
```

## Errori Comuni e Soluzioni

### Errore 1: Stringa senza '$'

```assembly
; ❌ ERRATO
messaggio DB 'Hello, World!'

; ✅ CORRETTO
messaggio DB 'Hello, World!$'
```
**Problema**: INT 21h/09h continua a leggere oltre la stringa  
**Sintomo**: Caratteri strani dopo il messaggio

### Errore 2: DS non inizializzato

```assembly
; ❌ ERRATO
main PROC
    MOV AH, 09h
    LEA DX, messaggio
    INT 21h
    ; DS punta a un segmento casuale!

; ✅ CORRETTO
main PROC
    MOV AX, @DATA
    MOV DS, AX
    MOV AH, 09h
    LEA DX, messaggio
    INT 21h
```

### Errore 3: Manca END

```assembly
; ❌ ERRATO
main PROC
    ; ...
main ENDP
; Manca END main!

; ✅ CORRETTO
main PROC
    ; ...
main ENDP
END main
```

### Errore 4: .COM senza ORG

```assembly
; ❌ ERRATO (NASM .COM)
section .text
start:
    ; Offsets sbagliati!

; ✅ CORRETTO
ORG 100h
section .text
start:
```

## Esercizi Pratici

1. **Hello Personalizzato**: Modifica il programma per stampare il tuo nome
2. **Righe Multiple**: Crea un programma che stampa 5 righe diverse
3. **Alfabeto**: Stampa tutte le lettere maiuscole da A a Z
4. **Echo**: Leggi un carattere e stampalo 5 volte
5. **Countdown**: Stampa i numeri da 9 a 0 (come caratteri ASCII)

### Soluzione Esercizio 5

```assembly
.MODEL SMALL
.STACK 100h
.CODE
main PROC
    MOV CX, 10      ; Conta da 9 a 0 (10 iterazioni)
    MOV DL, '9'     ; Inizia da '9'
    
countdown:
    MOV AH, 02h     ; Stampa carattere
    INT 21h
    
    MOV AH, 02h     ; Stampa spazio
    PUSH DX
    MOV DL, ' '
    INT 21h
    POP DX
    
    DEC DL          ; Decrementa carattere
    LOOP countdown
    
    MOV AH, 4Ch
    INT 21h
main ENDP
END main
```

**Output:** `9 8 7 6 5 4 3 2 1 0`

---

**Argomento precedente:** [Ambiente di Sviluppo](modulo2_01_ambiente_sviluppo.md)  
**Prossimo argomento:** [Direttive dell'Assembler](modulo2_03_direttive_assembler.md)
