# Domande di Autovalutazione - Modulo 2

## Ambiente di Sviluppo e Primi Programmi

### Domanda 1: Emulatori

**Quale emulatore è specificamente progettato per l'8086 con debugger integrato?**

A) DOSBox  
B) QEMU  
C) EMU8086  
D) VirtualBox  

<details>
<summary>Visualizza risposta</summary>

**Risposta corretta: C**

**Spiegazione:**

**EMU8086** è un ambiente integrato specifico per l'8086 che include:
- Editor con syntax highlighting
- Emulatore 8086 completo
- Debugger visuale con visualizzazione registri, memoria e stack
- Esempi e tutorial

**DOSBox** è un emulatore DOS completo ma senza debugger integrato specifico per assembly. **QEMU** è un emulatore generico per vari sistemi. **VirtualBox** è per virtualizzazione completa di sistemi operativi.

Per principianti che vogliono vedere in tempo reale cosa succede nei registri durante l'esecuzione, EMU8086 è la scelta migliore.

</details>

---

### Domanda 2: Assembler

**Quale assembler usa sintassi case-sensitive?**

A) MASM  
B) TASM  
C) NASM  
D) Tutti gli assembler  

<details>
<summary>Visualizza risposta</summary>

**Risposta corretta: C**

**Spiegazione:**

**NASM** (Netwide Assembler) è **case-sensitive**:
```assembly
MOV AX, BX      # Diverso da
mov ax, bx      # Questo (NASM accetta entrambi)

label:          # Diverso da
Label:          # Questo
```

**MASM** e **TASM** sono **case-insensitive** di default:
```assembly
MOV AX, BX      ; Uguale a
mov ax, bx      ; Questo
MoV aX, Bx      ; E anche questo
```

MASM/TASM possono essere resi case-sensitive con la direttiva `.MSFIRST` o opzione `/ml`, ma non è lo standard.

</details>

---

### Domanda 3: Modelli di Memoria

**Nel modello SMALL, quali sono i limiti di dimensione?**

A) Codice + Dati ≤ 64KB totale  
B) Codice ≤ 64KB, Dati ≤ 64KB (segmenti separati)  
C) Codice ≤ 128KB, Dati ≤ 64KB  
D) Nessun limite  

<details>
<summary>Visualizza risposta</summary>

**Risposta corretta: B**

**Spiegazione:**

Il modello **SMALL** ha:
- **Un segmento di codice**: ≤ 64KB
- **Un segmento di dati**: ≤ 64KB (include dati + stack)
- Segmenti **separati** (non come TINY dove tutto è insieme)

Confronto modelli:
- **TINY**: Tutto in un segmento (≤ 64KB totale) - file .COM
- **SMALL**: Un segmento codice, un segmento dati (≤ 64KB ciascuno)
- **COMPACT**: Un segmento codice, multipli segmenti dati
- **MEDIUM**: Multipli segmenti codice, un segmento dati
- **LARGE/HUGE**: Multipli segmenti per entrambi

La maggior parte dei programmi didattici usa SMALL perché sufficiente e semplice.

</details>

---

### Domanda 4: File .COM vs .EXE

**Quale affermazione sui file .COM è CORRETTA?**

A) Possono essere più grandi di 64KB  
B) Richiedono un header complesso  
C) Iniziano sempre all'offset 100h  
D) Hanno segmenti separati per codice e dati  

<details>
<summary>Visualizza risposta</summary>

**Risposta corretta: C**

**Spiegazione:**

File **.COM**:
- **Massimo 64KB** (codice + dati + stack)
- **Nessun header** (binario puro)
- Caricati sempre a **offset 100h** (primi 256 byte = PSP)
- **Un solo segmento** (CS = DS = ES = SS)
- Più semplici ma limitati

Struttura memoria:
```
0000h - 00FFh: PSP (Program Segment Prefix)
0100h - ????h: Programma (.COM inizia qui)
```

Per .COM serve `ORG 100h`:
```assembly
ORG 100h        ; Obbligatorio!
start:
    ; codice
```

File **.EXE**:
- Possono superare 64KB
- Hanno header MZ (28+ byte)
- Segmenti separati
- Più flessibili

</details>

---

### Domanda 5: Interruzione DOS 21h

**Qual è la funzione dell'interruzione DOS INT 21h con AH=09h?**

A) Legge un carattere dalla tastiera  
B) Stampa una stringa terminata con '$'  
C) Termina il programma  
D) Pulisce lo schermo  

<details>
<summary>Visualizza risposta</summary>

**Risposta corretta: B**

**Spiegazione:**

**INT 21h, AH=09h**: Stampa stringa

**Input:**
- AH = 09h
- DS:DX = indirizzo della stringa
- Stringa deve terminare con **'$' (24h)**

**Esempio:**
```assembly
.DATA
    msg DB 'Hello, World!$'

.CODE
    MOV AH, 09h
    LEA DX, msg         ; o MOV DX, OFFSET msg
    INT 21h             ; Stampa fino al '$'
```

**Altre funzioni INT 21h comuni:**
- **AH=01h**: Input carattere (con echo)
- **AH=02h**: Output carattere singolo
- **AH=4Ch**: Termina programma
- **AH=0Ah**: Input stringa (buffer)

Il terminatore '$' è specifico di questa funzione. Altre funzioni usano terminatori diversi (null per stringhe C, lunghezza esplicita, ecc.).

</details>

---

### Domanda 6: Direttiva .STACK

**Cosa fa la direttiva .STACK 100h?**

A) Definisce uno stack di 100 byte  
B) Definisce uno stack di 256 byte  
C) Definisce uno stack di 100 KB  
D) Alloca 100h word per lo stack  

<details>
<summary>Visualizza risposta</summary>

**Risposta corretta: B**

**Spiegazione:**

```assembly
.STACK 100h
```

- **100h** è esadecimale = **256** decimale
- Alloca **256 byte** per lo stack
- Sufficiente per programmi semplici

Esempi:
```assembly
.STACK 100h     ; 256 byte
.STACK 200h     ; 512 byte
.STACK 1000h    ; 4096 byte (4KB)
.STACK 10h      ; Solo 16 byte (troppo poco!)
```

**Dimensionamento stack:**
- Programmi semplici: 100h-200h
- Procedure ricorsive: ≥ 1000h
- Ogni PUSH usa 2 byte
- Ogni CALL salva IP (2 byte) o CS:IP (4 byte)

**Attenzione**: Stack troppo piccolo causa stack overflow!

</details>

---

### Domanda 7: Inizializzazione DS

**Perché è necessario inizializzare DS all'inizio di un programma .EXE?**

A) Non è necessario, DS è già corretto  
B) DS punta a un segmento casuale all'avvio  
C) Per compatibilità con DOS  
D) Solo per convenzione  

<details>
<summary>Visualizza risposta</summary>

**Risposta corretta: B**

**Spiegazione:**

Quando un programma .EXE viene caricato:
- **CS** è impostato correttamente (punta al codice)
- **SS:SP** è impostato correttamente (punta allo stack)
- **DS ed ES** puntano al **PSP** (Program Segment Prefix), NON al segmento dati!

**Codice necessario:**
```assembly
.CODE
main PROC
    MOV AX, @DATA       ; @DATA = indirizzo segmento dati
    MOV DS, AX          ; Imposta DS
    
    ; Ora possiamo accedere alle variabili
    MOV AL, variabile   ; DS:offset di variabile
```

**Perché non MOV DS, @DATA direttamente?**
```assembly
MOV DS, @DATA       ; ✗ ERRORE!
```
I registri di segmento non accettano valori immediati. Dobbiamo passare attraverso un registro generale (AX, BX, CX, o DX).

**File .COM non richiedono questo** perché CS = DS = ES = SS.

</details>

---

### Domanda 8: Direttive Dati

**Quale direttiva definisce una word (16 bit)?**

A) DB  
B) DW  
C) DD  
D) WORD  

<details>
<summary>Visualizza risposta</summary>

**Risposta corretta: B**

**Spiegazione:**

Direttive per allocazione dati:

| Direttiva | Nome          | Dimensione | Esempio          |
|-----------|---------------|------------|------------------|
| **DB**    | Define Byte   | 8 bit      | `var DB 42`      |
| **DW**    | Define Word   | 16 bit     | `var DW 1234h`   |
| **DD**    | Define DWord  | 32 bit     | `var DD 12345678h` |
| **DQ**    | Define QWord  | 64 bit     | `var DQ ...`     |
| **DT**    | Define TByte  | 80 bit     | `var DT ...`     |

**Esempi pratici:**
```assembly
byte_var    DB 255          ; 1 byte
word_var    DW 65535        ; 2 byte (FFFFh)
dword_var   DD 123456789    ; 4 byte

; Array
array_byte  DB 10, 20, 30   ; 3 byte
array_word  DW 100, 200     ; 4 byte (2 word)

; Stringhe (byte)
stringa     DB 'Hello$'     ; 6 byte
```

**Note:**
- 8086 è a 16 bit, quindi DW è la dimensione "naturale"
- DD usato per numeri grandi o puntatori FAR
- NASM usa minuscolo: `db`, `dw`, `dd`

</details>

---

### Domanda 9: Operatore DUP

**Cosa genera questa dichiarazione: `buffer DB 10 DUP(0)`?**

A) Un byte con valore 100  
B) 10 byte, tutti a zero  
C) Un byte duplicato 10 volte  
D) Errore di sintassi  

<details>
<summary>Visualizza risposta</summary>

**Risposta corretta: B**

**Spiegazione:**

**DUP** (DUPlicate) ripete valori:

```assembly
buffer DB 10 DUP(0)
```
Genera: **10 byte**, ciascuno con valore **0**
```
In memoria: 00 00 00 00 00 00 00 00 00 00
```

**Altri esempi:**
```assembly
; 100 byte a zero
buffer1 DB 100 DUP(0)

; 50 word a -1 (FFFFh)
array DW 50 DUP(-1)

; Pattern ripetuto
pattern DB 5 DUP(1, 2, 3)   ; 1,2,3,1,2,3,1,2,3,1,2,3,1,2,3

; Non inizializzato
temp DB 256 DUP(?)          ; 256 byte indefiniti
```

**DUP annidati:**
```assembly
; Matrice 10x10
matrice DB 10 DUP(10 DUP(0))    ; 100 byte totali
```

Molto utile per allocare buffer, array e tabelle senza scrivere centinaia di valori.

</details>

---

### Domanda 10: Direttiva EQU

**Qual è la differenza principale tra EQU e = (uguale)?**

A) Nessuna differenza  
B) EQU definisce costanti, = definisce variabili  
C) EQU non può essere ridefinito, = può  
D) EQU è per numeri, = per stringhe  

<details>
<summary>Visualizza risposta</summary>

**Risposta corretta: C**

**Spiegazione:**

**EQU** (EQUate):
- Definisce costante **non modificabile**
- Sostituita dall'assembler (come #define)
- **Non può essere ridefinita**

```assembly
MAX_SIZE EQU 100
; MAX_SIZE EQU 200    ; ✗ ERRORE! Ridefinizione
```

**= (uguale)**:
- Definisce simbolo **modificabile**
- **Può essere ridefinito**
- Usato in macro e contatori

```assembly
counter = 0
counter = counter + 1   ; ✓ OK (ora vale 1)
counter = counter + 1   ; ✓ OK (ora vale 2)
```

**Uso pratico:**
```assembly
; Costanti con EQU
CR EQU 13
LF EQU 10
MAX_BUFFER EQU 512

buffer DB MAX_BUFFER DUP(0)

; Contatore con =
item_count = 0
item_count = item_count + 1
```

**Best practice**: Usa **EQU** per costanti vere, **=** solo quando serve ridefinizione (raro).

</details>

---

### Domanda 11: Procedura PROC/ENDP

**Cosa indica NEAR in una dichiarazione di procedura?**

A) La procedura è piccola  
B) La procedura è nello stesso segmento di codice  
C) La procedura è vicina nel file  
D) È un'opzione di ottimizzazione  

<details>
<summary>Visualizza risposta</summary>

**Risposta corretta: B**

**Spiegazione:**

**NEAR** (default):
- Procedura nello **stesso segmento di codice**
- **CALL** salva solo **IP** (2 byte nello stack)
- **RET** ripristina solo **IP**
- Più veloce e usa meno stack

```assembly
procedura PROC NEAR     ; o solo PROC
    ; ...
    RET                 ; Ritorna nello stesso segmento
procedura ENDP
```

**FAR**:
- Procedura può essere in **segmento diverso**
- **CALL** salva **CS:IP** (4 byte nello stack)
- **RETF** (o RET in FAR PROC) ripristina **CS:IP**
- Necessario in modelli MEDIUM, LARGE, HUGE

```assembly
procedura PROC FAR
    ; ...
    RET                 ; Automaticamente RETF
procedura ENDP
```

**Confronto stack:**
```
NEAR CALL:          FAR CALL:
┌──────┐           ┌──────┐
│  IP  │           │  CS  │
└──────┘           ├──────┤
                   │  IP  │
                   └──────┘
```

**Quando usare FAR:**
- Chiamate tra moduli con segmenti di codice diversi
- Modelli di memoria grandi
- Librerie condivise

</details>

---

### Domanda 12: Direttiva ORG

**A cosa serve ORG 100h nei file .COM?**

A) Alloca 100h byte  
B) Imposta l'origine del codice a offset 100h  
C) Definisce la dimensione del programma  
D) È opzionale  

<details>
<summary>Visualizza risposta</summary>

**Risposta corretta: B**

**Spiegazione:**

**ORG** (ORiGin) imposta il **contatore di locazione** dell'assembler.

Per file **.COM**:
```assembly
ORG 100h            ; OBBLIGATORIO!
start:
    MOV AH, 09h
    ; ...
```

**Perché 100h?**
DOS carica i file .COM con questa struttura:
```
0000h - 00FFh: PSP (Program Segment Prefix) - 256 byte
0100h - ????h: Codice del programma (inizia qui!)
```

Il PSP contiene informazioni sul programma e l'ambiente DOS.

**Senza ORG 100h:**
```assembly
start:              ; Assembler assume offset 0
    MOV AX, var     ; Calcola indirizzo sbagliato!
; Al caricamento, il codice è a 100h, ma riferimenti sono calcolati da 0
```

**Con ORG 100h:**
```assembly
ORG 100h
start:              ; Assembler calcola da offset 100h
    MOV AX, var     ; Indirizzo corretto!
```

**File .EXE non richiedono ORG** perché il linker gestisce gli offset automaticamente.

</details>

---

### Domanda 13: LEA vs MOV OFFSET

**Qual è un vantaggio di LEA rispetto a MOV con OFFSET?**

A) LEA è più veloce  
B) LEA può calcolare indirizzi con espressioni  
C) MOV OFFSET non esiste  
D) Nessuna differenza  

<details>
<summary>Visualizza risposta</summary>

**Risposta corretta: B**

**Spiegazione:**

**MOV con OFFSET** (MASM/TASM):
```assembly
MOV BX, OFFSET variabile    ; Carica offset di variabile
```
- Carica l'**offset semplice**
- Calcolato in fase di assemblaggio
- Non può fare calcoli complessi

**LEA** (Load Effective Address):
```assembly
LEA BX, variabile           ; Equivalente a OFFSET
LEA BX, [SI+10]             ; Calcola SI+10
LEA BX, [BX+SI+5]           ; Calcola BX+SI+5
```
- Può **calcolare indirizzi complessi**
- Eseguito a runtime
- Non accede alla memoria (solo calcolo)

**Esempio pratico:**
```assembly
; Array di strutture
struc Persona
    nome    DB 20 DUP(?)
    eta     DB ?
    salario DW ?
ends    ; Totale: 23 byte

; Accesso al terzo elemento (indice 2)
MOV BX, OFFSET array        ; Base array
MOV AX, 23                  ; Dimensione struttura
MOV CX, 2                   ; Indice
MUL CX                      ; AX = 23 * 2 = 46
ADD BX, AX                  ; BX = array + 46

; Con LEA (più efficiente se offset noto):
LEA BX, [array + 46]        ; Un'istruzione sola!
```

**Uso come calcolo aritmetico:**
```assembly
; Calcolo AX = BX + SI + 10 senza ADD
LEA AX, [BX+SI+10]          ; Più veloce di 3 ADD!
```

</details>

---

### Domanda 14: INT 21h vs INT 10h

**Quando preferire INT 10h a INT 21h per output?**

A) Sempre, è più veloce  
B) Quando serve controllo su colore e posizione cursore  
C) Mai, INT 21h è migliore  
D) Solo in modalità grafica  

<details>
<summary>Visualizza risposta</summary>

**Risposta corretta: B**

**Spiegazione:**

**INT 21h** (DOS):
- Funzioni del **sistema operativo**
- Più alto livello
- **Gestione automatica** del cursore
- **Non controlla** colori o posizione

```assembly
MOV AH, 09h
LEA DX, stringa
INT 21h             ; Stampa stringa, cursore avanza
```

**INT 10h** (BIOS):
- Funzioni **video hardware**
- Più basso livello
- **Controllo completo**: colore, posizione, modalità video
- Un carattere alla volta

```assembly
; Stampa 'A' in rosso su sfondo blu a posizione specifica
MOV AH, 02h         ; Funzione: imposta posizione cursore
MOV BH, 0           ; Pagina video
MOV DH, 10          ; Riga
MOV DL, 20          ; Colonna
INT 10h

MOV AH, 09h         ; Funzione: scrivi carattere con attributo
MOV AL, 'A'         ; Carattere
MOV BH, 0           ; Pagina
MOV BL, 1Ch         ; Attributo: rosso su blu
MOV CX, 1           ; Ripetizioni
INT 10h
```

**Quando usare INT 10h:**
- Giochi e grafica
- Interfacce colorate
- Posizionamento preciso
- Controllo modalità video

**Quando usare INT 21h:**
- Output testuale semplice
- Programmi utility
- Più veloce per testo puro

</details>

---

### Domanda 15: INCLUDE

**Cosa fa la direttiva INCLUDE?**

A) Linka un file oggetto  
B) Include un file binario  
C) Inserisce il contenuto di un file sorgente  
D) Carica una libreria  

<details>
<summary>Visualizza risposta</summary>

**Risposta corretta: C**

**Spiegazione:**

**INCLUDE** inserisce il **contenuto di un file** nel sorgente durante l'assemblaggio.

```assembly
; main.asm
INCLUDE 'macros.inc'
INCLUDE 'costanti.inc'

.MODEL SMALL
.CODE
main PROC
    PRINT_MSG saluto    ; Macro definita in macros.inc
    MOV AH, 4Ch
    INT 21h
main ENDP
END main
```

**File macros.inc:**
```assembly
; Definizioni macro
PRINT_MSG MACRO msg
    PUSH AX
    PUSH DX
    MOV AH, 09h
    LEA DX, msg
    INT 21h
    POP DX
    POP AX
ENDM
```

**Funzionamento:**
1. Assembler legge `INCLUDE 'macros.inc'`
2. Apre macros.inc
3. **Inserisce il contenuto** come se fosse scritto in main.asm
4. Continua l'assemblaggio

**Equivalente a:**
```assembly
; main.asm (dopo espansione INCLUDE)
PRINT_MSG MACRO msg
    ; ...
ENDM

.MODEL SMALL
; ...
```

**Vantaggi:**
- **Riuso codice**: macro, costanti, definizioni condivise
- **Organizzazione**: separa definizioni da logica
- **Manutenibilità**: modifica in un posto, effetto ovunque

**Non confondere con:**
- **Linking**: combina file .OBJ (dopo assemblaggio)
- **INCBIN** (NASM): include file binario raw

</details>

---

### Domanda 16: Macro ENDM

**Qual è la differenza principale tra una macro e una procedura?**

A) Nessuna differenza  
B) La macro è espansa inline, la procedura è chiamata con CALL  
C) La macro è più veloce  
D) Le macro non possono avere parametri  

<details>
<summary>Visualizza risposta</summary>

**Risposta corretta: B**

**Spiegazione:**

**MACRO**:
- **Espansa inline** dall'assembler
- Codice **duplicato** ogni volta che viene usata
- **Nessun CALL/RET**: nessun overhead di chiamata
- Aumenta dimensione codice

```assembly
SOMMA MACRO a, b
    MOV AX, a
    ADD AX, b
ENDM

; Uso
SOMMA 5, 10     ; Assembler espande qui
SOMMA BX, CX    ; E qui (codice duplicato)

; Diventa:
MOV AX, 5
ADD AX, 10
MOV AX, BX
ADD AX, CX      ; Codice ripetuto
```

**PROCEDURA**:
- **Chiamata** con CALL, **ritorno** con RET
- Codice esiste **una sola volta**
- **Overhead**: CALL salva IP, RET ripristina
- Dimensione codice minore

```assembly
somma PROC
    ; codice esiste una volta
    RET
somma ENDP

; Uso
CALL somma      ; Salta alla procedura
CALL somma      ; Salta di nuovo (stesso codice)
```

**Confronto:**

| Aspetto         | Macro              | Procedura          |
|-----------------|--------------------|--------------------|
| Espansione      | Inline (duplicata) | Una copia          |
| Velocità        | Più veloce         | Overhead CALL/RET  |
| Dimensione      | Più grande         | Più piccola        |
| Parametri       | Sostituiti inline  | Via registri/stack |

**Quando usare macro:**
- Sequenze brevi usate spesso
- Prestazioni critiche
- Parametri semplici

**Quando usare procedure:**
- Codice lungo
- Usato raramente
- Risparmio memoria

</details>

---

### Domanda 17: Assembler Pass

**Quanti "pass" fa tipicamente un assembler?**

A) Uno  
B) Due  
C) Tre  
D) Dipende dalla complessità  

<details>
<summary>Visualizza risposta</summary>

**Risposta corretta: B**

**Spiegazione:**

La maggior parte degli assembler usa **due pass** (passate):

**Pass 1**: Analisi e costruzione tabelle
- Legge tutto il sorgente
- Costruisce **symbol table** (etichette, variabili)
- Assegna **indirizzi** a simboli
- Calcola **dimensioni** istruzioni e dati
- Non genera codice ancora

```assembly
.DATA
var1 DB 10          ; Pass 1: var1 a offset 0000h
var2 DW 20          ; Pass 1: var2 a offset 0001h

.CODE
start:              ; Pass 1: start a offset 0000h
    MOV AX, var1    ; Pass 1: dimensione 3 byte
    JMP fine        ; Pass 1: fine non ancora definito!
fine:               ; Pass 1: fine a offset 0006h
    RET
```

**Pass 2**: Generazione codice
- Rilegge il sorgente
- Usa symbol table del Pass 1
- Genera **codice macchina**
- Risolve tutti i riferimenti

```assembly
start:
    MOV AX, var1    ; Pass 2: genera B8 00 00 (offset di var1)
    JMP fine        ; Pass 2: genera EB 03 (jump a fine)
fine:
    RET             ; Pass 2: genera C3
```

**Perché due pass?**

**Forward reference**: riferimenti a etichette definite dopo:
```assembly
    JMP avanti      ; Usato prima della definizione
    ; ...
avanti:             ; Definito dopo
```

Nel Pass 1, `avanti` non è ancora noto. Nel Pass 2, è nella symbol table.

**Alcuni assembler usano più pass** per:
- Ottimizzazioni complesse
- Macro elaborate
- Ma lo standard è **2 pass**

</details>

---

### Domanda 18: File Listing (.LST)

**Cosa mostra un file listing (.LST)?**

A) Solo il codice sorgente  
B) Solo il codice macchina  
C) Codice sorgente con codice macchina corrispondente  
D) Errori di compilazione  

<details>
<summary>Visualizza risposta</summary>

**Risposta corretta: C**

**Spiegazione:**

Il file **.LST** (listing) mostra codice sorgente **allineato** con il codice macchina generato.

**Generazione:**
```batch
MASM /Fl file.asm       ; MASM
TASM /l file.asm        ; TASM
nasm -f obj file.asm -l file.lst    ; NASM
```

**Esempio file.lst:**
```
Microsoft (R) Macro Assembler Version 6.11
file.asm                                             Page 1-1

                                .MODEL SMALL
                                .STACK 100h
                                .DATA
 0000 0A                        var DB 10
 0001 0014                      num DW 20
                                
                                .CODE
                                main PROC
 0000  B8 ---- R                   MOV AX, @DATA
 0003  8E D8                       MOV DS, AX
 0005  A0 0000 R                   MOV AL, var
 0008  8B 1E 0001 R                MOV BX, num
 000C  B4 4C                       MOV AH, 4Ch
 000E  CD 21                       INT 21h
                                main ENDP
                                END main
```

**Colonne:**
- **Offset**: posizione nel segmento
- **Codice macchina**: byte esadecimali generati
- **R**: relocatable (da aggiustare nel linking)
- **Sorgente**: codice assembly originale

**Utilità:**
- **Debugging**: vedere cosa genera ogni istruzione
- **Ottimizzazione**: confrontare alternative
- **Apprendimento**: capire codice macchina
- **Verifica**: controllare dimensioni e offset

**Esempio pratico:**
```
Voglio vedere quanto occupa un'istruzione:
 0005  A0 0000 R      MOV AL, var     ; 3 byte
 0008  8B 1E 0001 R   MOV BX, num     ; 4 byte
```

</details>

---

### Domanda 19: Symbol Table

**Cosa contiene la symbol table generata dall'assembler?**

A) Solo nomi di variabili  
B) Solo etichette di codice  
C) Nomi, tipi, segmenti e offset di tutti i simboli  
D) Solo simboli pubblici  

<details>
<summary>Visualizza risposta</summary>

**Risposta corretta: C**

**Spiegazione:**

La **symbol table** (tabella dei simboli) è creata nel **Pass 1** e contiene informazioni su tutti i simboli definiti:

**Informazioni per simbolo:**
- **Nome**: identificatore
- **Tipo**: BYTE, WORD, DWORD, PROC, LABEL, ecc.
- **Segmento**: DATA, CODE, STACK
- **Offset**: posizione nel segmento
- **Attributi**: PUBLIC, EXTRN, NEAR, FAR

**Esempio:**
```assembly
.DATA
    var1 DB 10
    var2 DW 1234h
    array DB 100 DUP(0)

.CODE
main PROC
    ; ...
main ENDP

stampa PROC
    ; ...
stampa ENDP
```

**Symbol Table:**
```
Nome      Tipo    Segmento  Offset  Attributi
------    ----    --------  ------  ---------
var1      BYTE    _DATA     0000h   
var2      WORD    _DATA     0001h   
array     BYTE    _DATA     0003h   
main      PROC    _TEXT     0000h   NEAR
stampa    PROC    _TEXT     0010h   NEAR
```

**Usi:**
- **Pass 2**: risolvere riferimenti
- **Linker**: risolvere simboli esterni
- **Debugger**: mostrare nomi simbolici
- **Programmatore**: file .MAP, cross-reference

**Visualizzazione:**
Nel file .MAP o con opzioni assembler:
```batch
MASM /Fm file.asm       ; Genera .MAP
```

</details>

---

### Domanda 20: Errore "Undefined symbol"

**Quando si verifica l'errore "Undefined symbol"?**

A) Solo durante il linking  
B) Durante il Pass 2 dell'assemblaggio  
C) Durante il Pass 1  
D) Mai con assembler moderni  

<details>
<summary>Visualizza risposta</summary>

**Risposta corretta: B**

**Spiegazione:**

L'errore **"Undefined symbol"** si verifica nel **Pass 2** dell'assemblaggio quando:
- Un simbolo è **usato** ma **mai definito**
- E non è dichiarato **EXTRN** (esterno)

**Esempio errato:**
```assembly
.CODE
main PROC
    MOV AL, variabile   ; ✗ variabile non definita!
    JMP etichetta       ; ✗ etichetta non definita!
main ENDP
END main
```

**Pass 1**:
- Costruisce symbol table
- `variabile` e `etichetta` non trovati
- Non genera errore ancora (potrebbero essere dopo)

**Pass 2**:
- Cerca `variabile` e `etichetta` nella symbol table
- **Non trovati** → **Errore: Undefined symbol**

**Correzione 1: Definire i simboli**
```assembly
.DATA
    variabile DB 10     ; ✓ Definito

.CODE
main PROC
    MOV AL, variabile   ; ✓ OK
    JMP etichetta       ; ✓ OK
etichetta:
    RET
main ENDP
END main
```

**Correzione 2: Dichiarare EXTRN**
```assembly
EXTRN variabile:BYTE    ; ✓ Definito in altro modulo
EXTRN etichetta:PROC    ; ✓ Definito in altro modulo

.CODE
main PROC
    MOV AL, variabile   ; ✓ OK (risolto dal linker)
    JMP etichetta       ; ✓ OK (risolto dal linker)
main ENDP
END main
```

**Typo comuni:**
```assembly
messaggio DB 'Hello$'
MOV DX, messagio        ; ✗ Typo! (messagio vs messaggio)
```

</details>

---

## Riepilogo Punteggi

- **18-20 risposte corrette**: Eccellente! Padronanza completa del modulo.
- **15-17 risposte corrette**: Ottimo! Buona comprensione, rivedere gli errori.
- **12-14 risposte corrette**: Buono! Comprensione base solida, approfondire alcuni aspetti.
- **9-11 risposte corrette**: Sufficiente! Rivedere i concetti fondamentali.
- **< 9 risposte corrette**: Ripassa il modulo prima di procedere.

---

**Argomento precedente:** [Processo di Assemblaggio e Linking](04_assemblaggio_linking.md)  
**Torna all'indice:** [README - Corso Assembly 8086](../README.md)
