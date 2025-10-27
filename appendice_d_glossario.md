# Appendice D: Glossario dei Termini

## A

**AAA (ASCII Adjust After Addition)** - Istruzione che corregge il risultato di un'addizione BCD in formato ASCII.

**AAD (ASCII Adjust Before Division)** - Istruzione che prepara operandi ASCII per una divisione.

**AAM (ASCII Adjust After Multiply)** - Istruzione che corregge il risultato di una moltiplicazione in formato ASCII/BCD.

**AAS (ASCII Adjust After Subtraction)** - Istruzione che corregge il risultato di una sottrazione BCD in formato ASCII.

**Absolute Address** - Indirizzo fisico completo nella memoria, calcolato come `Segment × 16 + Offset`.

**Accumulator** - Registro AX (o AL/AH), usato principalmente per operazioni aritmetiche e I/O.

**ADC (Add with Carry)** - Addizione che include il flag Carry, usata per aritmetica multi-precisione.

**Address Bus** - Bus a 20 bit dell'8086 che trasporta indirizzi di memoria (0-FFFFFh).

**Addressing Mode** - Metodo usato per specificare la posizione di un operando (immediato, diretto, indiretto, ecc.).

**AF (Auxiliary Flag)** - Flag che indica riporto/prestito dal bit 3 al bit 4, usato per aritmetica BCD.

**Alignment** - Allineamento dati in memoria a confini di word (indirizzi pari) per migliorare performance.

**Assembler** - Programma che traduce codice assembly in codice macchina (es. MASM, TASM, NASM).

**ASSUME** - Direttiva che informa l'assembler quali registri di segmento puntano a quali segmenti.

## B

**Base Pointer (BP)** - Registro usato per accedere parametri e variabili locali nello stack frame.

**Base Register** - Registro BX o BP usato in modalità di indirizzamento basato.

**BCD (Binary Coded Decimal)** - Rappresentazione decimale dove ogni cifra usa 4 bit (0-9).

**Big Endian** - Formato dove byte più significativo è all'indirizzo più basso (opposto di Intel).

**BIOS (Basic Input/Output System)** - Firmware che fornisce servizi hardware di basso livello.

**BIU (Bus Interface Unit)** - Parte dell'8086 che gestisce bus e prefetch delle istruzioni.

**Breakpoint** - Punto nel codice dove l'esecuzione si ferma per debugging (INT 03h).

**Buffer** - Area di memoria usata per memorizzare temporaneamente dati durante I/O.

**Byte** - Unità di 8 bit (0-255 unsigned, -128 a +127 signed).

## C

**Calling Convention** - Regole per passaggio parametri e pulizia stack (cdecl, Pascal, fastcall).

**Carry Flag (CF)** - Flag che indica riporto/prestito in operazioni unsigned o errori.

**CBW (Convert Byte to Word)** - Estende segno di AL in AX.

**cdecl** - Convenzione C dove chiamante pulisce stack, parametri right-to-left.

**CLI (Clear Interrupt Flag)** - Disabilita interruzioni mascherabili (IF=0).

**Clock Cycle** - Periodo base del processore (200ns per 8086 a 5 MHz).

**CMP (Compare)** - Sottrazione che aggiorna solo flag, non modifica operandi.

**Code Page** - Set di caratteri per ASCII esteso (es. CP437 = DOS USA).

**Code Segment (CS)** - Registro di segmento che punta al codice eseguibile.

**COM File** - Eseguibile DOS con single-segment model, max 64KB, ORG 100h.

**Coprocessor** - Chip separato (8087) per calcoli floating-point.

**CS:IP** - Coppia che punta all'istruzione corrente da eseguire.

**CWD (Convert Word to Doubleword)** - Estende segno di AX in DX:AX.

## D

**DAA (Decimal Adjust After Addition)** - Corregge addizione BCD in formato packed.

**DAS (Decimal Adjust After Subtraction)** - Corregge sottrazione BCD in formato packed.

**Data Bus** - Bus a 16 bit per trasferimento dati tra CPU e memoria/I/O.

**Data Segment (DS)** - Registro di segmento che punta ai dati del programma.

**DB (Define Byte)** - Direttiva per allocare 1 byte in memoria.

**DD (Define Doubleword)** - Direttiva per allocare 4 byte (32 bit).

**Debugger** - Tool per debugging (es. DEBUG.EXE, Turbo Debugger).

**DEC (Decrement)** - Sottrae 1, non modifica CF.

**DF (Direction Flag)** - Controlla direzione istruzioni stringhe (0=increment, 1=decrement).

**Directive** - Comando per l'assembler, non genera codice macchina (es. DB, EQU, PROC).

**Displacement** - Offset aggiunto all'indirizzo base in modalità indirizzamento indicizzato/basato.

**DIV (Divide)** - Divisione unsigned: AX/source (byte) o DX:AX/source (word).

**DMA (Direct Memory Access)** - Trasferimento dati senza coinvolgere CPU.

**DOS (Disk Operating System)** - Sistema operativo Microsoft per IBM PC.

**Doubleword (DWORD)** - 32 bit (4 byte), range 0-4,294,967,295.

**DTA (Disk Transfer Area)** - Buffer DOS per operazioni su file.

**DUP (Duplicate)** - Operatore per ripetere pattern in allocazione dati.

**DW (Define Word)** - Direttiva per allocare 2 byte (16 bit).

## E

**Effective Address** - Indirizzo finale calcolato da modalità indirizzamento (es. [BX+SI+10]).

**ENDP** - Direttiva che termina definizione procedura.

**ENDS** - Direttiva che termina definizione segmento.

**EOF (End Of File)** - Fine file, segnalato da Ctrl+Z (1Ah) o byte letti = 0.

**EQU (Equate)** - Direttiva per definire costanti simboliche.

**ES (Extra Segment)** - Registro di segmento extra, usato per istruzioni stringhe.

**EU (Execution Unit)** - Parte dell'8086 che esegue istruzioni.

**EXE File** - Eseguibile DOS multi-segment, con header e relocation table.

**EXTRN (External)** - Direttiva per dichiarare simboli definiti in altri moduli.

## F

**FAR** - Attributo per puntatori/procedure che includono segmento (4 byte: segment:offset).

**Fastcall** - Convenzione con parametri in registri (più veloce ma meno parametri).

**Flag** - Bit nel registro FLAGS che indica stato operazione o controlla CPU.

**Floating-Point** - Rappresentazione numeri reali (IEEE 754), gestita da 8087.

**FPU (Floating-Point Unit)** - Coprocessore matematico 8087 per calcoli floating-point.

## G

**General-Purpose Register** - AX, BX, CX, DX usabili per vari scopi.

**GDT (Global Descriptor Table)** - Tabella per memoria protetta (usata in 286+, non 8086 real mode).

## H

**Handle** - Numero identificativo file aperto (0=stdin, 1=stdout, 2=stderr).

**Hexadecimal** - Base 16 (0-9, A-F), prefisso: 0x o suffisso h.

**High Byte** - Byte superiore di una word (AH in AX, BH in BX, ecc.).

**Hoisting** - Ottimizzazione che sposta calcoli invarianti fuori da loop.

## I

**IDIV (Integer Divide)** - Divisione signed.

**IF (Interrupt Flag)** - Flag che abilita/disabilita interruzioni mascherabili.

**Immediate** - Operando valore costante nell'istruzione stessa.

**IMUL (Integer Multiply)** - Moltiplicazione signed.

**INC (Increment)** - Aggiunge 1, non modifica CF.

**Index Register** - SI o DI, usati per accesso array e istruzioni stringhe.

**Indirect Addressing** - Operando in memoria puntato da registro (es. [BX]).

**Instruction Pointer (IP)** - Registro che punta alla prossima istruzione da eseguire.

**INT (Interrupt)** - Istruzione software interrupt o interruzione hardware.

**Interrupt Vector Table (IVT)** - Tabella a 0000:0000 con 256 puntatori ISR (1024 byte).

**IRET (Interrupt Return)** - Ritorno da ISR: POP IP, POP CS, POP FLAGS.

**ISR (Interrupt Service Routine)** - Handler per gestire un'interruzione.

**IVT** - Vedi Interrupt Vector Table.

## J

**JMP (Jump)** - Salto incondizionato a etichetta (SHORT/NEAR/FAR).

**Jump Table** - Array di indirizzi per implementare switch-case ottimizzato.

## K

**KB (Kilobyte)** - 1024 byte (2^10).

**Keyboard Buffer** - Buffer circolare BIOS per memorizzare tasti premuti.

## L

**Label** - Nome simbolico per indirizzo in codice o dati.

**LAHF (Load AH from Flags)** - Copia FLAGS[7:0] in AH.

**LEA (Load Effective Address)** - Carica indirizzo effettivo in registro.

**LDS (Load DS)** - Carica DS:registro da puntatore FAR in memoria.

**LES (Load ES)** - Carica ES:registro da puntatore FAR in memoria.

**LIFO (Last In, First Out)** - Struttura stack: ultimo inserito è primo estratto.

**Linker** - Programma che combina file .OBJ in eseguibile .EXE o .COM.

**Little Endian** - Formato Intel dove byte meno significativo è all'indirizzo più basso.

**LOCAL** - Direttiva per variabili locali in macro o procedure.

**LOOP** - Decrementa CX e salta se CX≠0.

**Low Byte** - Byte inferiore di una word (AL in AX, BL in BX, ecc.).

**LSB (Least Significant Bit)** - Bit meno significativo (bit 0).

## M

**MACRO** - Sequenza istruzioni definita una volta, espansa ogni uso.

**Masking** - Uso AND per isolare bit specifici (maschera).

**MASM (Macro Assembler)** - Assembler Microsoft per DOS/Windows.

**Memory Model** - Organizzazione memoria programma (Tiny, Small, Medium, Compact, Large, Huge).

**Mnemonic** - Nome simbolico istruzione (es. MOV, ADD, JMP).

**MOD-REG-R/M** - Byte codifica che specifica operandi e modalità indirizzamento.

**MOVSB/MOVSW** - Istruzione stringa per copiare byte/word da DS:SI a ES:DI.

**MSB (Most Significant Bit)** - Bit più significativo (bit 15 per word, bit 7 per byte).

**MUL (Multiply)** - Moltiplicazione unsigned: AL×source→AX o AX×source→DX:AX.

## N

**NASM (Netwide Assembler)** - Assembler open-source, sintassi Intel.

**NEAR** - Attributo per puntatori/procedure nello stesso segmento (2 byte: offset).

**NEG (Negate)** - Complemento a due, calcola -operando.

**NOP (No Operation)** - Istruzione che non fa nulla (3 cicli), equivale a XCHG AX,AX.

**NOT** - Complemento a uno, inverte tutti i bit.

## O

**OBJ File** - File oggetto output assembler, input linker.

**OF (Overflow Flag)** - Flag che indica overflow aritmetico signed.

**Offset** - Parte bassa indirizzo (16 bit) all'interno di un segmento.

**Opcode** - Byte che identifica univocamente un'istruzione.

**Operand** - Dato su cui opera un'istruzione (source/destination).

**ORG (Origin)** - Direttiva che imposta indirizzo base assemblaggio.

**Overflow** - Risultato fuori range rappresentabile (signed: OF=1).

## P

**Packed BCD** - Due cifre decimali in un byte (nibble alto e basso).

**Paragraph** - Unità 16 byte, confine allineamento segmenti.

**Parity** - Numero bit a 1 in byte basso: pari→PF=1, dispari→PF=0.

**Pascal Convention** - Chiamata con parametri left-to-right, procedura pulisce stack.

**PF (Parity Flag)** - Flag parità byte basso risultato.

**Physical Address** - Indirizzo assoluto 20-bit memoria (0-FFFFFh).

**PIC (Programmable Interrupt Controller)** - Chip 8259 che gestisce IRQ hardware.

**Pipeline** - Tecnica CPU per sovrapporre fetch ed esecuzione istruzioni.

**Pointer** - Variabile contenente indirizzo (NEAR=2 byte, FAR=4 byte).

**POP** - Estrae word da stack e incrementa SP di 2.

**Prefetch Queue** - Buffer 6 byte dell'8086 per pre-caricamento istruzioni.

**PROC** - Direttiva inizio definizione procedura.

**PSP (Program Segment Prefix)** - Area 256 byte prima programma COM/EXE con info DOS.

**PUBLIC** - Direttiva per esportare simboli verso altri moduli.

**PUSH** - Decrementa SP di 2 e inserisce word su stack.

## Q

**Quadword (QWORD)** - 64 bit (8 byte).

## R

**RCL/RCR (Rotate through Carry)** - Rotazione attraverso Carry per shift multi-word.

**Real Mode** - Modalità 8086: accesso diretto memoria, nessuna protezione.

**Recursion** - Procedura che chiama se stessa (richiede stack).

**Register** - Locazione veloce CPU per dati temporanei (AX, BX, CX, DX, SI, DI, SP, BP).

**Relocation** - Processo di aggiustamento indirizzi durante caricamento programma.

**REP** - Prefisso per ripetere istruzione stringa CX volte.

**REPE/REPZ** - Ripeti mentre CX≠0 AND ZF=1.

**REPNE/REPNZ** - Ripeti mentre CX≠0 AND ZF=0.

**RET (Return)** - Ritorna da procedura: POP IP (NEAR) o POP IP, POP CS (FAR).

**ROL/ROR (Rotate Left/Right)** - Rotazione circolare bit.

## S

**SAHF (Store AH into Flags)** - Copia AH in FLAGS[7:0].

**SAL/SAR (Shift Arithmetic Left/Right)** - Shift preservando segno (SAR) o moltiplicazione (SAL).

**SBB (Subtract with Borrow)** - Sottrazione includendo Carry.

**Scan Code** - Codice hardware tastiera (diverso da ASCII).

**SCAS (Scan String)** - Cerca AL/AX in stringa ES:DI.

**Segment** - Blocco memoria 64KB (massimo offset FFFFh).

**Segment Override** - Prefisso per usare segmento diverso dal default (es. ES:[BX]).

**Segment Register** - CS, DS, SS, ES puntano a segmenti memoria.

**SF (Sign Flag)** - Copia MSB risultato (0=positivo, 1=negativo).

**SHL/SHR (Shift Left/Right)** - Shift logico, riempie con 0.

**Shunting Yard** - Algoritmo per parsing espressioni con precedenza operatori.

**Signed** - Rappresentazione con segno (complemento a due).

**Source** - Operando sorgente, fornisce valore operazione.

**SP (Stack Pointer)** - Registro punta top dello stack.

**SS (Stack Segment)** - Registro segmento per stack.

**SS:SP** - Coppia che punta a top dello stack.

**Stack** - Area memoria LIFO per parametri, return address, variabili locali.

**Stack Frame** - Struttura su stack per procedura: parametri, return address, BP salvato, locali.

**STI (Set Interrupt Flag)** - Abilita interruzioni mascherabili (IF=1).

**STOS (Store String)** - Memorizza AL/AX in ES:DI.

**String** - Sequenza byte/word in memoria.

**Strength Reduction** - Ottimizzazione sostituendo operazioni costose (MUL→ADD).

**STRUCT** - Direttiva per definire strutture dati (record).

## T

**TASM (Turbo Assembler)** - Assembler Borland compatibile MASM.

**TEST** - AND logico che aggiorna solo flag.

**TF (Trap Flag)** - Flag single-step per debugging (INT 01h dopo ogni istruzione).

**TSR (Terminate and Stay Resident)** - Programma che resta in memoria dopo terminazione.

**Two's Complement** - Rappresentazione numeri negativi (complemento a uno + 1).

## U

**Unrolling** - Ottimizzazione loop replicando corpo per ridurre overhead.

**Unsigned** - Rappresentazione senza segno (byte: 0-255, word: 0-65535).

## V

**VGA (Video Graphics Array)** - Standard video IBM: testo 80×25, grafica 640×480.

**Video Memory** - Area B800:0000 (testo) o A000:0000 (grafica VGA).

## W

**WAIT** - Istruzione che attende segnale TEST# da coprocessore.

**Word** - 16 bit (2 byte), range 0-65535 unsigned, -32768 a +32767 signed.

## X

**XCHG (Exchange)** - Scambia due operandi.

**XLATB (Translate)** - Traduce byte usando tabella: AL = DS:[BX+AL].

**XOR (Exclusive OR)** - OR esclusivo, idioma comune: XOR AX,AX per azzerare.

## Z

**Zero Page** - Primi 256 byte memoria (0000:0000-0000:00FF), contiene IVT.

**ZF (Zero Flag)** - 1 se risultato è zero, 0 altrimenti.

---

## Acronimi Comuni

- **ALU**: Arithmetic Logic Unit
- **ASCII**: American Standard Code for Information Interchange
- **BCD**: Binary Coded Decimal
- **BIOS**: Basic Input/Output System
- **BIU**: Bus Interface Unit
- **CF**: Carry Flag
- **CLI**: Clear Interrupt Flag
- **CPU**: Central Processing Unit
- **CS**: Code Segment
- **DF**: Direction Flag
- **DMA**: Direct Memory Access
- **DOS**: Disk Operating System
- **DS**: Data Segment
- **DWORD**: Doubleword (32-bit)
- **EOF**: End Of File
- **ES**: Extra Segment
- **EU**: Execution Unit
- **FAR**: Far pointer (segment:offset)
- **FPU**: Floating-Point Unit
- **IF**: Interrupt Flag
- **INT**: Interrupt
- **IP**: Instruction Pointer
- **IRQ**: Interrupt Request
- **ISR**: Interrupt Service Routine
- **IVT**: Interrupt Vector Table
- **KB**: Kilobyte (1024 bytes)
- **LSB**: Least Significant Bit
- **MASM**: Microsoft Macro Assembler
- **MSB**: Most Significant Bit
- **NASM**: Netwide Assembler
- **NEAR**: Near pointer (offset only)
- **NOP**: No Operation
- **OF**: Overflow Flag
- **PC**: Program Counter (IP)
- **PF**: Parity Flag
- **PIC**: Programmable Interrupt Controller
- **PSP**: Program Segment Prefix
- **QWORD**: Quadword (64-bit)
- **RTC**: Real-Time Clock
- **SF**: Sign Flag
- **SP**: Stack Pointer
- **SS**: Stack Segment
- **TASM**: Turbo Assembler
- **TF**: Trap Flag
- **TSR**: Terminate and Stay Resident
- **VGA**: Video Graphics Array
- **WORD**: 16-bit value
- **ZF**: Zero Flag

---

## Convenzioni di Notazione

- **[ ]**: Indirizzamento indiretto memoria (es. [BX])
- **h**: Suffisso esadecimale (es. 0FFh)
- **b**: Suffisso binario (es. 10110101b)
- **d**: Suffisso decimale (opzionale, es. 255d)
- **$**: Indirizzo corrente (es. JMP $+5)
- **?**: Valore non inizializzato (es. DB ?)
- **×**: Moltiplicazione in formule
- **÷**: Divisione in formule
- **→**: Assegnamento/trasferimento
- **↔**: Scambio
- **≠**: Diverso
- **≥**: Maggiore o uguale
- **≤**: Minore o uguale