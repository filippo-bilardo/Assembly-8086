# Indice del Corso: Assembly 8086

## Modulo 1: Fondamenti dell'Architettura 8086

Il primo modulo introduce l'architettura del processore Intel 8086, spiegando come questo microprocessore rappresenti la base storica dell'architettura x86 moderna. Comprendere la struttura interna del processore è fondamentale prima di iniziare a programmare in assembly.

Gli argomenti trattati includono l'organizzazione dei registri interni (AX, BX, CX, DX e le loro suddivisioni in registri a 8 bit), i registri di segmento (CS, DS, SS, ES), i registri puntatori (SP, BP, SI, DI) e il registro dei flag. Viene inoltre spiegato il modello di memoria segmentata, caratteristica distintiva dell'8086, con il calcolo degli indirizzi fisici attraverso la formula: indirizzo fisico = segmento × 16 + offset.

Questo modulo affronta anche l'architettura del bus, la pipeline di istruzioni e le modalità di indirizzamento disponibili nel processore.

### Contenuti del Modulo 1:

1. **[Introduzione all'Architettura 8086](01-Fondamenti_Architettura_8086/01_introduzione_architettura_8086.md)**
   - Panoramica storica e caratteristiche principali
   - Architettura interna: BIU ed EU
   - Pipeline di istruzioni
   - Organizzazione della memoria segmentata
   - Calcolo degli indirizzi fisici
   - Modelli di memoria (Tiny, Small, Compact, Medium, Large, Huge)

2. **[Registri dell'Intel 8086](01-Fondamenti_Architettura_8086/02_registri_8086.md)**
   - Registri generali (AX, BX, CX, DX)
   - Registri puntatori e indice (SP, BP, SI, DI)
   - Registro dei flag (FLAGS)
   - Registro IP (Instruction Pointer)
   - Convenzioni e best practices

3. **[Modalità di Indirizzamento](01-Fondamenti_Architettura_8086/03_modalita_indirizzamento.md)**
   - Indirizzamento immediato
   - Indirizzamento a registro
   - Indirizzamento diretto
   - Indirizzamento indiretto a registro
   - Indirizzamento indicizzato
   - Indirizzamento basato
   - Indirizzamento basato indicizzato
   - Indirizzamento relativo
   - Segment override

4. **[Domande di Autovalutazione Modulo 1](01-Fondamenti_Architettura_8086/04_quiz.md)**
   - 20 domande a scelta multipla con risposte spiegate
   - Verifica della comprensione degli argomenti
   - Esercizi pratici di calcolo

## Modulo 2: Ambiente di Sviluppo e Primi Programmi

Il secondo modulo guida lo studente nella configurazione dell'ambiente di sviluppo, presentando emulatori come DOSBox ed EMU8086, oltre agli assembler più diffusi come MASM, TASM e NASM. Vengono spiegate le differenze sintattiche tra questi assembler per permettere allo studente di scegliere consapevolmente.

Si procede con la scrittura del primo programma "Hello World", analizzando ogni direttiva e istruzione. Vengono introdotti i concetti di direttive dell'assembler (ORG, END, SEGMENT), la struttura di un programma completo, le chiamate alle interruzioni del BIOS e del DOS (INT 21h, INT 10h), e il processo di assemblaggio, linking ed esecuzione.

Il modulo include numerosi esempi pratici di programmi semplici con spiegazioni dettagliate linea per linea, mostrando come tradurre la logica del programma in istruzioni assembly.

### Contenuti del Modulo 2:

1. **[Ambiente di Sviluppo per Assembly 8086](02-Ambiente_e_Primi_Programmi/01_ambiente_sviluppo.md)**
   - Emulatori: DOSBox, EMU8086, QEMU
   - Assembler: MASM, TASM, NASM (confronto e differenze)
   - Strumenti di debug: DEBUG.EXE, Turbo Debugger
   - Configurazione VS Code per Assembly
   - Script di automazione e Makefile
   - Template di progetto

2. **[Primo Programma: Hello World](02-Ambiente_e_Primi_Programmi/02_hello_world.md)**
   - Versione MASM/TASM (.EXE)
   - Versione NASM (.COM)
   - Analisi linea per linea del codice
   - Interruzioni DOS (INT 21h) e BIOS (INT 10h)
   - Programmi di esempio con input/output
   - Errori comuni e soluzioni
   - Esercizi pratici

3. **[Direttive dell'Assembler](02-Ambiente_e_Primi_Programmi/03_direttive_assembler.md)**
   - Direttive di segmentazione (.MODEL, .STACK, .DATA, .CODE)
   - Allocazione dati (DB, DW, DD, DUP)
   - Definizione simboli (EQU, =)
   - Procedure (PROC/ENDP, NEAR/FAR)
   - Direttive di controllo (ORG, ALIGN, INCLUDE)
   - Macro (MACRO/ENDM, LOCAL)
   - Direttive condizionali (IF/ENDIF)
   - Differenze MASM/TASM/NASM

4. **[Processo di Assemblaggio e Linking](02-Ambiente_e_Primi_Programmi/04_assemblaggio_linking.md)**
   - Fasi dell'assemblaggio (Pass 1 e Pass 2)
   - File oggetto (.OBJ) e eseguibili (.EXE, .COM)
   - Symbol table e relocation table
   - Processo di linking e risoluzione simboli
   - Comandi MASM, TASM, NASM
   - File ausiliari (.LST, .MAP, .CRF)
   - Progetti multi-file
   - Makefile e automazione

5. **[Domande di Autovalutazione Modulo 2](02-Ambiente_e_Primi_Programmi/05_quiz.md)**
   - 20 domande a scelta multipla con risposte spiegate
   - Copertura completa degli argomenti del modulo
   - Verifica comprensione ambiente, direttive e processo build

## Modulo 3: Set di Istruzioni Base

Questo modulo costituisce il cuore del corso, presentando sistematicamente il set di istruzioni dell'8086. Le istruzioni vengono organizzate per categorie funzionali: istruzioni di trasferimento dati (MOV, XCHG, LEA, LDS, LES), istruzioni aritmetiche (ADD, SUB, MUL, DIV, INC, DEC, NEG), istruzioni logiche (AND, OR, XOR, NOT, TEST), istruzioni di shift e rotate (SHL, SHR, SAL, SAR, ROL, ROR, RCL, RCR).

Ogni istruzione viene spiegata con la sintassi, gli effetti sui flag, esempi pratici di utilizzo e best practice. Particolare attenzione viene dedicata alle differenze tra operazioni su dati a 8 e 16 bit, alla gestione del segno nelle operazioni aritmetiche e alle tecniche di ottimizzazione del codice.

Il modulo include trucchi e tecniche avanzate, come l'uso di XOR per azzerare un registro (più veloce di MOV), o l'uso di LEA per calcoli aritmetici veloci.

1. **[Istruzioni di Trasferimento Dati](03-Set_Istruzioni_Base/01_istruzioni_trasferimento_dati.md)**
   - MOV (move) - operandi validi e non validi
   - XCHG (exchange) - scambio valori
   - LEA (load effective address) - calcolo indirizzi
   - PUSH/POP - gestione stack
   - PUSHF/POPF - salvataggio flag
   - XLATB - traduzione byte con tabelle
   - LDS/LES - caricamento puntatori FAR
   - Best practices e ottimizzazioni

2. **[Istruzioni Aritmetiche](03-Set_Istruzioni_Base/02_istruzioni_aritmetiche.md)**
   - ADD/ADC (addition with carry)
   - SUB/SBB (subtraction with borrow)
   - INC/DEC (increment/decrement)
   - NEG (negate) - complemento a due
   - MUL/IMUL (multiplication unsigned/signed)
   - DIV/IDIV (division unsigned/signed)
   - CMP (compare) - confronto senza salvataggio
   - CBW/CWD - estensione segno
   - Aritmetica multi-precisione (32, 64 bit)
   - Gestione overflow e flag

3. **[Istruzioni Logiche](03-Set_Istruzioni_Base/03_istruzioni_logiche.md)**
   - AND (logical and) - mascheramento bit
   - OR (logical or) - impostazione bit
   - XOR (exclusive or) - toggle e azzeramento
   - NOT (logical not) - complemento a 1
   - TEST (logical compare) - test senza modifiche
   - Manipolazione bit e campi
   - Conversioni maiuscole/minuscole
   - Checksum e crittografia XOR
   - Pattern e idiomi comuni

4. **[Istruzioni di Shift e Rotate](03-Set_Istruzioni_Base/04_istruzioni_shift_rotate.md)**
   - SHL/SAL (shift left) - moltiplicazione per 2ⁿ
   - SHR (shift logical right) - divisione unsigned
   - SAR (shift arithmetic right) - divisione signed
   - ROL (rotate left) - rotazione circolare
   - ROR (rotate right)
   - RCL (rotate through carry left) - shift multi-word
   - RCR (rotate through carry right)
   - Estrazione e inserimento campi bit
   - Moltiplicazioni/divisioni ottimizzate
   - Aritmetica multi-precisione con shift

5. **[Domande di Autovalutazione Modulo 3](03-Set_Istruzioni_Base/05_quiz.md)**
   - 20 domande a scelta multipla con risposte dettagliate
   - Copertura completa di tutte le categorie di istruzioni
   - Focus su ottimizzazioni, flag e casi particolari
   - Esempi pratici e confronti tra istruzioni simili

## Modulo 4: Controllo di Flusso e Procedure

Il quarto modulo tratta le strutture di controllo che permettono di implementare algoritmi complessi. Vengono spiegate le istruzioni di salto condizionato e incondizionato (JMP, JE, JNE, JG, JL, JA, JB e tutte le varianti), il confronto tra dati (CMP, TEST) e la costruzione di strutture equivalenti ai costrutti di alto livello come if-then-else, switch-case, while, do-while e for.

La parte sulle procedure introduce CALL e RET, la gestione dello stack, il passaggio dei parametri (tramite registri, stack o memoria), il valore di ritorno, le convenzioni di chiamata e la differenza tra NEAR e FAR procedure. Vengono discusse tecniche avanzate come le procedure ricorsive con esempi pratici (fattoriale, Fibonacci, Torre di Hanoi).

Il modulo sottolinea l'importanza di preservare i registri utilizzati e mostra pattern comuni di prologo ed epilogo delle procedure.

1. **[Istruzioni di Salto Condizionato](04-Controllo_Flusso_Procedure/01_salti_condizionati.md)**
   - Salto incondizionato: JMP (SHORT, NEAR, FAR, indiretto)
   - Salti condizionati su singoli flag (JZ, JNZ, JS, JC, JO, JP, ...)
   - Confronti unsigned: JA, JAE, JB, JBE (Above/Below)
   - Confronti signed: JG, JGE, JL, JLE (Greater/Less)
   - Istruzioni LOOP: LOOP, LOOPE, LOOPNE, JCXZ
   - Tabelle di riferimento complete per tutti i salti
   - Formule per le condizioni dei flag
   - Best practices per la scelta del salto corretto

2. **[Strutture di Controllo](04-Controllo_Flusso_Procedure/02_strutture_controllo.md)**
   - Traduzione if-then-else in assembly (pattern salto invertito)
   - Switch-case: implementazione con confronti sequenziali
   - Switch-case ottimizzato: jump table per casi contigui
   - Loop while: test all'inizio del ciclo
   - Loop do-while: test alla fine (esecuzione garantita)
   - Loop for: equivalente a while con inizializzazione e incremento
   - Break e continue: salti a etichette specifiche
   - Loop annidati: gestione con stack o registri multipli

3. **[Procedure e Gestione dello Stack](04-Controllo_Flusso_Procedure/03_procedure_stack.md)**
   - Concetto di stack: LIFO, PUSH/POP, crescita verso il basso
   - CALL e RET: NEAR vs FAR, meccanismo di salvataggio IP
   - Definizione procedure: PROC/ENDP
   - Preservazione registri: caller-saved vs callee-saved
   - Pattern prologo/epilogo: PUSH BP, MOV BP,SP, SUB SP
   - Passaggio parametri: registri, memoria globale, stack
   - Stack frame: [BP+n] per parametri, [BP-n] per locali
   - Variabili locali: allocazione con SUB SP
   - RET n: pulizia automatica stack
   - Convenzioni: C (chiamante pulisce) vs Pascal (procedura pulisce)

4. **[Ricorsione](04-Controllo_Flusso_Procedure/04_ricorsione.md)**
   - Elementi fondamentali: caso base, passo ricorsivo, progresso
   - Meccanismo: stack frame multipli, crescita stack
   - Esempio completo: fattoriale ricorsivo
   - Esempio completo: Fibonacci ricorsivo (e problemi di efficienza)
   - Esempio avanzato: Torre di Hanoi
   - Ricorsione vs iterazione: confronto prestazioni
   - Tail recursion: ottimizzazione manuale a loop
   - Stack overflow: cause e prevenzione
   - Best practices: dimensionamento stack, caso base corretto

5. **[Domande di Autovalutazione Modulo 4](04-Controllo_Flusso_Procedure/05_quiz.md)**
   - 20 domande a scelta multipla con risposte dettagliate
   - Copertura salti condizionati, strutture controllo, procedure, stack, ricorsione
   - Focus su jump table, stack frame, LIFO, efficienza ricorsione
   - Esempi pratici di debugging e ottimizzazione

## Modulo 5: Gestione della Memoria e delle Stringhe

Questo modulo approfondisce la gestione della memoria nell'8086, spiegando come dichiarare e utilizzare variabili in memoria (DB, DW, DD), gli array, le stringhe e l'allocazione dinamica della memoria attraverso le chiamate DOS.

Le istruzioni per operazioni su stringhe (MOVS, CMPS, SCAS, LODS, STOS) vengono presentate in dettaglio, mostrando come il prefisso REP e le sue varianti (REPE, REPNE) permettano operazioni efficienti su blocchi di dati. Vengono forniti esempi pratici di manipolazione di stringhe: copia, confronto, ricerca di caratteri, conversione maiuscole/minuscole.

Il modulo include tecniche di gestione efficiente della memoria, pattern per strutture dati complesse e best practice per evitare errori comuni come buffer overflow o accessi fuori dai limiti degli array.

1. **[Variabili e Gestione della Memoria](05-Memoria_e_Stringhe/01_variabili_memoria.md)**
   - Direttive allocazione: DB, DW, DD, DQ, DT (byte, word, doubleword, quadword, ten bytes)
   - Operatore DUP: ripetizione pattern, array non inizializzati (?)
   - Stringhe: C-style (null-terminated), Pascal-style (length-prefixed), multilinea, caratteri speciali
   - Array: byte, word, matrice 2D (row-major), calcolo offset
   - Allineamento memoria: EVEN, ALIGN per prestazioni ottimali
   - Puntatori: LEA, OFFSET, SEG, dereferenziazione
   - Strutture (STRUCT): record, array di strutture
   - Allocazione dinamica DOS: INT 21h AH=48h/49h/4Ah (alloca/libera/ridimensiona)

2. **[Istruzioni per Stringhe](05-Memoria_e_Stringhe/02_istruzioni_stringhe.md)**
   - Registri: SI (source), DI (destination), CX (contatore), Direction Flag (DF)
   - CLD/STD: controllo direzione (incremento/decremento)
   - MOVSB/W: copia byte/word da DS:SI a ES:DI
   - CMPSB/W: confronta DS:SI con ES:DI, aggiorna flag
   - SCASB/W: cerca AL/AX in ES:DI
   - LODSB/W: carica DS:SI in AL/AX
   - STOSB/W: memorizza AL/AX in ES:DI
   - Prefissi: REP (ripeti CX volte), REPE/REPZ (finché uguale), REPNE/REPNZ (finché diverso)
   - Esempi: copia array, confronto stringhe, ricerca carattere, fill buffer

3. **[Manipolazione Avanzata di Stringhe](05-Memoria_e_Stringhe/03_manipolazione_stringhe.md)**
   - Funzioni standard: strlen, strcpy, strcmp, strcat, strchr, strstr
   - Conversioni: toupper/tolower, strupr/strlwr, strrev (inversione)
   - Trim: ltrim, rtrim (rimozione spazi)
   - Conversione numero ↔ stringa: atoi, itoa (decimale), itoh/htoi (esadecimale)
   - Tokenizzazione: strtok (split by delimiter)
   - Sicurezza: safe_strcpy con limite, validazione input, prevenzione buffer overflow
   - Implementazioni ottimizzate con istruzioni stringhe
   - Gestione errori e casi limite

4. **[Gestione Buffer e Ottimizzazioni](05-Memoria_e_Stringhe/04_buffer_performance.md)**
   - Buffer circolari: FIFO con wrapping, cbuf_write/read, uso per input buffering
   - Buffer dinamici: allocazione crescente, espansione automatica, dbuf_append/grow/free
   - Ottimizzazioni: MOVSW vs MOVSB (~2× veloce), loop unrolling, allineamento memoria
   - Buffering I/O: line buffering, block buffering per file
   - Memory pool: allocazione da pool pre-allocato (O(1)), pool_alloc/reset
   - Copy-on-write: condivisione buffer fino a modifica
   - Prevenzione errori: overflow check, memory leak tracking, null pointer check
   - Best practices: validazione dimensioni, inizializzazione, costanti per size

5. **[Domande di Autovalutazione Modulo 5](05-Memoria_e_Stringhe/05_quiz.md)**
   - 20 domande a scelta multipla con risposte dettagliate
   - Copertura: dichiarazione memoria, istruzioni stringhe, prefissi REP, manipolazione, buffer
   - Focus su little-endian, allineamento, prestazioni MOVSW, terminazione stringhe
   - Esempi pratici di conversioni, buffer circolari, prevenzione overflow

## Modulo 6: Input/Output e Interruzioni

Il sesto modulo esplora l'interazione con il mondo esterno attraverso operazioni di input/output. Vengono spiegate le interruzioni hardware e software, il vettore delle interruzioni (Interrupt Vector Table), e le principali interruzioni BIOS e DOS utilizzate per I/O su tastiera, video, porta seriale e parallela.

Si approfondiscono le tecniche di I/O: polling, interrupt-driven I/O, e DMA. Esempi pratici mostrano come leggere caratteri dalla tastiera con e senza echo, come scrivere testo colorato sullo schermo in modalità testo, come gestire il cursore e come lavorare con i file (apertura, lettura, scrittura, chiusura) attraverso le chiamate DOS.

Il modulo include la creazione di gestori di interruzioni personalizzati (ISR - Interrupt Service Routine) e l'installazione di nuovi handler nella IVT, con tutti i caveat necessari per operazioni così delicate.

1. **[Interruzioni e Interrupt Vector Table](06-IO_e_Interruzioni/01_interruzioni.md)**
   - Tipi interruzioni: hardware (timer, tastiera, disco), software (INT n), eccezioni (div/0, overflow)
   - IVT: struttura 1024 byte (256 vettori × 4 byte), indirizzo fisico = tipo_int × 4
   - Vettore: 2 byte offset + 2 byte segmento ISR
   - Istruzione INT: PUSHF, CLI, PUSH CS, PUSH IP, jump a ISR
   - Istruzione IRET: POP IP, POP CS, POPF (ripristina FLAGS)
   - ISR: struttura (salva registri, gestione, EOI, ripristina, IRET)
   - Interrupt Flag: CLI/STI, sezioni critiche, save/restore IF
   - PIC 8259: EOI (OUT 20h, 20h), mascheramento IRQ
   - INT 21h (DOS): funzioni principali (01h, 02h, 09h, 0Ah, 3Ch-42h, 4Ch)
   - INT 10h (Video BIOS), INT 16h (Keyboard BIOS), INT 13h (Disk BIOS)

2. **[Input/Output Tastiera e Video](06-IO_e_Interruzioni/02_io_tastiera_video.md)**
   - INT 21h keyboard: 01h (echo), 06h/FFh (polling), 07h/08h (no echo), 0Ah (buffered)
   - INT 21h video: 02h (write char), 09h (write string '$'-terminated)
   - INT 16h: 00h (read key), 01h (check no-wait), 02h (shift status)
   - Scan codes: tasti speciali (F1-F12, frecce) hanno AL=0, scan code in AH
   - INT 10h mode: 00h (set video mode 00h-13h)
   - INT 10h cursor: 01h (shape), 02h (position), 03h (get position)
   - INT 10h output: 09h (char+attribute), 0Eh (teletype), 06h/07h (scroll)
   - Attributo video: bit 7 blink, bit 6-4 background BGR, bit 3 intensity, bit 2-0 foreground BGR
   - Esempi: menu interattivo, input password, box colorato
   - Best practices: portabilità BIOS, gestione tasti speciali, save/restore stato video

3. **[File I/O con DOS](06-IO_e_Interruzioni/03_file_io.md)**
   - Handle predefiniti: 0 stdin, 1 stdout, 2 stderr, 3 stdaux, 4 stdprn
   - INT 21h/3Ch: Create file (CX attributi), tronca se esiste
   - INT 21h/3Dh: Open file (AL: 0=read, 1=write, 2=read/write)
   - INT 21h/3Eh: Close file (sempre chiudere!)
   - INT 21h/3Fh: Read (AX=byte letti, AX=0 → EOF)
   - INT 21h/40h: Write (AX=byte scritti, AX<CX → disco pieno)
   - INT 21h/42h: Seek (AL: 0=begin, 1=current, 2=end), ritorna DX:AX posizione
   - INT 21h/41h: Delete, INT 21h/56h: Rename
   - Gestione errori: CF=1, codici (02h not found, 05h access denied)
   - Esempi: copia file, conta righe, append, leggi riga
   - Redirect I/O: 45h (dup handle), 46h (force handle)

4. **[Interrupt Service Routines Personalizzate](06-IO_e_Interruzioni/04_isr_custom.md)**
   - Quando creare ISR: hook interruzioni, driver hardware, TSR, debugging, emulazione
   - Struttura ISR: salva registri, setup DS, corpo, ripristina, IRET (non RET!)
   - ISR con chain: JMP a vecchia ISR (pre-processing) o CALL+post-processing
   - Installazione: DOS Get/Set Vector (35h/25h) preferito vs accesso diretto IVT
   - Esempi: hook INT 21h (logger), timer INT 08h, keyboard filter INT 09h, watchdog INT 1Ch
   - TSR: INT 21h/31h (Keep Process), parte residente + inizializzazione
   - Regole sicurezza: salva tutti registri, ISR veloce, NO DOS in HW ISR, EOI obbligatorio
   - CLI/STI: brevi sezioni critiche, CS: per dati in TSR
   - Debugging ISR: LED, beep, video diretto, contatori
   - Best practices: IRET non RET, chain se necessario, ripristina sempre vettore

5. **[Domande di Autovalutazione Modulo 6](06-IO_e_Interruzioni/05_quiz.md)**
   - 20 domande a scelta multipla con risposte dettagliate
   - Copertura: INT/IRET, IVT, INT 21h tastiera/file, INT 16h, INT 10h, ISR personalizzate
   - Focus su differenze funzioni input (01h/06h/07h/08h), access mode file, attributi video
   - EOI al PIC, installazione vettori (25h/35h), gestione EOF, seek file
   - Esempi pratici hook interruzioni, TSR, file I/O, video colorato

## Modulo 7: Programmazione Avanzata

Il settimo modulo presenta tecniche avanzate di programmazione assembly. Si tratta dell'interfacciamento tra assembly e linguaggi di alto livello come C, spiegando le convenzioni di chiamata (cdecl, stdcall, fastcall), come scrivere funzioni assembly chiamabili da C e viceversa, e come debuggare codice misto.

Vengono introdotte tecniche di ottimizzazione: loop unrolling, inlining manuale, uso efficiente della cache, riduzione delle dipendenze tra istruzioni e minimizzazione degli accessi in memoria. Il modulo mostra come leggere e interpretare il codice assembly generato dai compilatori per imparare ulteriori ottimizzazioni.

Altri argomenti avanzati includono la programmazione dei coprocessori matematici (8087), operazioni su numeri floating-point, gestione di precisione estesa e tecniche di calcolo numerico in virgola fissa come alternativa più veloce.

### Contenuti del Modulo 7:

1. **[Interfacciamento con C](07-Programmazione_Avanzata/01_interfacciamento_c.md)**
   - Convenzioni di chiamata: cdecl (caller cleanup, _underscore), Pascal (callee cleanup, UPPERCASE), fastcall (parametri in registri)
   - Stack frame layout: parametri [BP+4], [BP+6], ..., preservazione BP, allocazione locali
   - Chiamare funzioni C da Assembly: EXTRN dichiarazioni, PUBLIC exports, passaggio parametri su stack, AX per return value
   - Chiamare Assembly da C: prototipo C, implementazione Assembly, pulizia stack corretta
   - Inline assembly: Turbo C (asm{}), Microsoft C (_asm{})
   - Condivisione struct: allineamento, offset field, extern struct
   - Gestione errno: variabile globale C accessibile da Assembly
   - Best practices: documentazione convenzione, preservare registri (BX/SI/DI/BP), gestione stack bilanciata

2. **[Tecniche di Ottimizzazione](07-Programmazione_Avanzata/02_ottimizzazione.md)**
   - Scelta istruzioni: XOR AX,AX (3 cicli) vs MOV AX,0 (4 cicli), TEST vs CMP/AND, LEA per aritmetica
   - Shift per mul/div: SHL AX,3 = ×8, SHR AX,1 = ÷2, SAR per signed
   - Loop unrolling: replicazione corpo loop (4×, 8×), riduzione overhead LOOP, trade-off code size
   - Hoisting: spostare calcoli invarianti fuori loop
   - Strength reduction: MUL→ADD in loop (i×5 → i+i+i+i+i), moltiplicazioni con shift+add
   - LEA tricks: LEA AX,[BX+BX*2] = ×3, LEA AX,[BX+BX*4] = ×5, LEA AX,[BX+SI+10]
   - Allocazione registri: preferire registri vs memoria, riutilizzo, minimizzare PUSH/POP
   - Ottimizzazione memoria: allineamento word, accessi sequenziali, REP STOSB/MOVSB
   - Lookup table: precalcolo vs ricalcolo, jump table per switch
   - Pipeline: ridurre dipendenze, interleaving istruzioni
   - Benchmark: macro timing, confronto approcci, profiling

3. **[Coprocessore Matematico 8087](07-Programmazione_Avanzata/03_coprocessore_8087.md)**
   - Architettura 8087: 8 registri 80-bit ST(0)-ST(7) organizzati a stack, control/status/tag word
   - Formati dati: word/short/long integer (16/32/64-bit), short/long/temp real (32/64/80-bit), packed BCD
   - Inizializzazione: FINIT/FNINIT
   - Load/Store: FLD/FILD (push stack), FST/FIST (copy top), FSTP/FISTP (pop)
   - Aritmetica: FADD/FSUB/FMUL/FDIV (opera su ST(0)), FADDP/FMULP (pop), FIADD/FISUB
   - Confronti: FCOMP (compare+pop), FSTSW AX (status→AX), SAHF (AH→FLAGS), salti condizionati
   - Funzioni trascendenti: FSIN/FCOS/FPTAN, FPATAN, FSQRT, F2XM1/FYL2X per exp/log
   - Costanti: FLDPI, FLD1, FLDZ, FLDL2E
   - Gestione stack: FXCH (exchange ST(i)), FFREE (libera registro)
   - Aritmetica fixed-point: formato 16.16 (1.0=65536), moltiplicazioni/divisioni con shift
   - Rilevamento FPU: INT 11h bit 1, esecuzione test
   - Best practices: FINIT sempre, controllo eccezioni, pulizia stack, uso costanti built-in

4. **[Domande di Autovalutazione Modulo 7](07-Programmazione_Avanzata/04_quiz.md)**
   - 20 domande a scelta multipla con risposte dettagliate
   - Copertura: convenzioni chiamata (cdecl/Pascal/fastcall), stack frame, ottimizzazioni, FPU 8087
   - Focus su stack cleanup, naming convention, preservazione registri, XOR zero, shift mul/div
   - Loop unrolling, hoisting, strength reduction, LEA arithmetic
   - FPU: 80-bit registers, stack organization, FLDPI, FCOMP, FSQRT, fixed-point 16.16
   - Esempi pratici interfacciamento C, benchmark, calcoli floating-point

## Modulo 8: Progetti Pratici e Casi d'Uso

L'ultimo modulo consolida le conoscenze acquisite attraverso progetti completi e realistici. Ogni progetto viene sviluppato incrementalmente, partendo da specifiche semplici e aggiungendo progressivamente funzionalità.

I progetti proposti dimostrano l'applicazione pratica di tutti i concetti appresi: gestione I/O, parsing, algoritmi, ottimizzazione, debugging. Ogni progetto è accompagnato da codice completo commentato, casi di test, estensioni suggerite e riflessioni sulle scelte progettuali.

Il modulo fornisce un'esperienza hands-on che prepara lo studente a sviluppare applicazioni reali in assembly, comprendendo il processo completo dallo sviluppo al debugging, dall'ottimizzazione alla manutenzione del codice.

### Contenuti del Modulo 8:

1. **[Progetto 1: Calcolatore a Riga di Comando](08-Progetti_Pratici/01_calcolatore.md)**
   - Obiettivi: parser input utente, 4 operazioni (+,-,*,/), gestione errori (div/0, overflow, input invalido)
   - Architettura: main loop (prompt→parse→calculate→print), funzioni modulari
   - Parsing: read_line, skip_spaces, read_number (conversione ASCII→binario con segno), read_operator
   - Implementazione operazioni: add (overflow detection), subtract, multiply (16×16→32 DX:AX), divide (controllo divisore zero)
   - Conversione output: print_decimal ricorsivo (divisioni per 10, stack per inversione)
   - Versione 32-bit: read_number32 (DX:AX), add32 (ADC), mul32, print_decimal32
   - Estensioni: espressioni multiple, parentesi (Shunting Yard), floating-point (8087/fixed-point), funzioni (sqrt/sin), variabili (hash table)
   - Debugging: breakpoint, trace registri, test cases, profiling
   - Testing: tabella casi test con valori attesi

2. **[Progetto 2: Gioco Snake](08-Progetti_Pratici/02_gioco_snake.md)**
   - Obiettivi: grafica testuale 80×25, movimento serpente (frecce), cibo casuale, collisioni, punteggio, velocità crescente
   - Strutture dati: array snake_x/snake_y (max 200), direction (0-3), food_x/food_y, score, speed (delay tick)
   - Inizializzazione: clear_screen (INT 10h/06h), draw_border (═║╔╗╚╝), serpente iniziale (3 segmenti), genera cibo
   - Input non-bloccante: INT 16h/01h (check keystroke), controllo frecce (scan code), prevenzione inversione direzione
   - Movimento: calcola nuova testa, check collisioni (bordi, auto-collisione O(n)), shift serpente, disegna/cancella
   - Generazione cibo: random da timer tick (0040:006Ch), verifica non su serpente, riprova se collisione
   - Crescita: eat_food incrementa lunghezza, punteggio +10, velocità aumenta ogni 50 punti
   - Game loop: timing con get_tick, delay basato su speed (5→1 tick)
   - Ottimizzazioni: accesso diretto VGA (B800:0000, 10-20× più veloce), doppio buffering, V-Sync
   - Estensioni: livelli con muri, power-up, multiplayer (WASD+frecce), high score su file

3. **[Domande di Autovalutazione Modulo 8](08-Progetti_Pratici/03_quiz.md)**
   - 20 domande a scelta multipla con risposte dettagliate
   - Copertura progetti: parsing (conversione stringa→numero), input non-bloccante (INT 16h/01h)
   - Snake: prevenzione inversione direzione, VGA B800:0000, generazione random (timer tick)
   - Calcolatore: overflow detection (OF/CF flags), conversione numero→stringa (divisioni ripetute)
   - Ottimizzazioni: accesso diretto video (10-20× speedup), velocità crescente (diminuzione delay)
   - Strutture dati: array circolare vs fisso, collision detection O(n)
   - Multi-precisione: ADD+ADC per 32-bit, gestione carry
   - Flicker: doppio buffering, V-Sync, ridisegno parziale
   - Parsing espressioni: Shunting Yard, ricorsione discendente, precedenza operatori
   - Debugging: breakpoint INT 03h, trace, Turbo Debugger, print intermediate
   - REP MOVSW: ~2× veloce, microcode, auto-decremento

---

## Appendici

### [Appendice A: Quick Reference del Set di Istruzioni](appendice_a_reference_istruzioni.md)

Una tabella di riferimento rapido completa con tutte le istruzioni dell'8086, organizzate per categoria:
- **Trasferimento dati**: MOV, XCHG, LEA, PUSH/POP, IN/OUT
- **Aritmetiche**: ADD, SUB, MUL, DIV, INC, DEC, NEG, CMP
- **Logiche**: AND, OR, XOR, NOT, TEST
- **Shift e Rotate**: SHL, SHR, SAL, SAR, ROL, ROR, RCL, RCR
- **Salti condizionati**: tabella completa con condizioni flag (JE, JNE, JG, JL, JA, JB, ecc.)
- **Salti incondizionati e loop**: JMP, CALL, RET, LOOP, JCXZ
- **Stringhe**: MOVS, CMPS, SCAS, LODS, STOS con prefissi REP
- **Controllo**: INT, IRET, CLI, STI, HLT
- **Coprocessore 8087**: FINIT, FLD, FADD, FMUL, FSIN, FCOS, FSQRT

Per ogni istruzione: sintassi, descrizione, effetti sui flag, cicli di clock. Include registro FLAGS dettagliato, formato codifica istruzioni, e note su performance.

### [Appendice B: Tabella ASCII](appendice_b_tabella_ascii.md)

La tabella completa dei caratteri ASCII con tutte le codifiche:
- **Caratteri di controllo (0-31)**: NUL, CR, LF, ESC, BS, ecc.
- **Caratteri stampabili (32-126)**: simboli, numeri, lettere maiuscole/minuscole
- **ASCII esteso (128-255)**: caratteri grafici, internazionali, box drawing
- **Conversioni utili**: maiuscole↔minuscole, ASCII↔numero, validazione cifre
- **Scan codes tastiera**: tasti funzione (F1-F12), frecce, combinazioni Ctrl
- **Codifiche colori video**: formato attributo byte, tabella colori VGA (0-15)
- **Caratteri speciali DOS**: terminatori stringa ($, \0), EOF (Ctrl+Z), CR+LF

Include codici in decimale, esadecimale, ottale e binario. Esempi pratici per manipolazione caratteri in Assembly.

### [Appendice C: Interruzioni BIOS e DOS](appendice_c_interruzioni.md)

Elenco completo delle interruzioni più utilizzate con parametri e valori restituiti:
- **INT 10h (Video BIOS)**: modalità video, cursore, output caratteri, scroll, pixel
- **INT 16h (Keyboard BIOS)**: lettura tasti bloccante/non-bloccante, shift status, scan codes
- **INT 21h (DOS Services)**: 
  - I/O caratteri: lettura/scrittura console, stringhe, buffered input
  - File I/O: create, open, close, read, write, seek, delete, rename
  - Directory: create/remove/change directory, find files
  - Memoria: allocate, free, resize
  - Sistema: interrupt vectors, data/ora, TSR, exit
- **INT 13h (Disk BIOS)**: read/write sectors, parametri disco
- **INT 1Ah (Time Services)**: tick count, RTC date/time
- **INT 11h (Equipment Check)**: configurazione hardware
- **INT 12h (Memory Size)**: memoria base disponibile
- **INT 15h (System Services)**: wait, memoria estesa

Include tabelle complete funzioni, esempi codice, codici errore DOS e disco.

### [Appendice D: Glossario dei Termini](appendice_d_glossario.md)

Dizionario completo dei termini tecnici Assembly e architettura 8086:
- **Termini alfabetici A-Z**: oltre 200 definizioni dettagliate
- **Acronimi comuni**: ALU, BIOS, CPU, FPU, ISR, IVT, MASM, NASM, PSP, TSR, VGA
- **Convenzioni di notazione**: [ ], h, b, d, $, ?, →, ↔
- **Concetti chiave**: 
  - Architettura: BIU, EU, pipeline, prefetch queue
  - Memoria: segmentation, addressing modes, alignment
  - Istruzioni: opcode, operand, mnemonic, flag effects
  - Programmazione: calling conventions, stack frame, recursion
  - Ottimizzazione: hoisting, loop unrolling, strength reduction

Ogni termine include definizione chiara, contesto d'uso e riferimenti correlati. Strumento essenziale per consultazione rapida durante lo studio e la programmazione.