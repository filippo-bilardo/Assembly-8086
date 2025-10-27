# Le Interruzioni DOS: Il Sistema Operativo a Portata di Assembly

Quando programmiamo in assembly per sistemi DOS, le interruzioni rappresentano il nostro principale mezzo di comunicazione con il sistema operativo. Pensate alle interruzioni DOS come a una biblioteca di funzioni predefinite che ci risparmiano il lavoro di scrivere da zero operazioni complesse come leggere dalla tastiera, scrivere su disco o gestire i file. È come avere un assistente esperto a cui possiamo chiedere di fare certi compiti per noi, semplicemente chiamandolo con il numero giusto.

## Il Concetto di Interruzione Software

Prima di addentrarci nelle specifiche interruzioni DOS, è importante capire cos'è un'interruzione software e come funziona. In assembly, l'istruzione INT seguita da un numero provoca un'interruzione. Quando il processore esegue questa istruzione, interrompe temporaneamente il flusso normale del programma e salta a una routine speciale del sistema operativo, identificata da quel numero. Questa routine esegue il compito richiesto e poi restituisce il controllo al nostro programma, esattamente all'istruzione successiva all'INT.

Il meccanismo funziona così: quando il processore incontra INT 21h, salva automaticamente sullo stack i flag, CS e IP (in modo da sapere dove tornare), poi consulta una tabella in memoria chiamata Interrupt Vector Table che si trova ai primi indirizzi della memoria RAM. Ogni interruzione ha un'entrata in questa tabella contenente l'indirizzo della routine da eseguire. Il processore carica questo indirizzo in CS:IP e comincia l'esecuzione della routine di servizio. Quando la routine termina con IRET (Return from Interrupt), il processore ripristina i valori salvati sullo stack e riprende l'esecuzione del nostro codice.

## L'Interruzione 21h: Il Cuore dei Servizi DOS

L'interruzione 21h è senza dubbio la più importante e utilizzata quando programmiamo in assembly DOS. Rappresenta il gateway verso tutti i servizi principali del sistema operativo. La particolarità di questa interruzione è che non fa una sola cosa: il registro AH deve contenere un codice che specifica quale servizio vogliamo invocare. È come chiamare un centralino e dire "passami l'interno 09" per raggiungere un ufficio specifico.

## Servizi per Input e Output su Console

Cominciamo con le operazioni più basilari: leggere caratteri dalla tastiera e scrivere caratteri sullo schermo. Il servizio 01h dell'INT 21h legge un carattere dalla tastiera con echo, cioè il carattere appare sullo schermo mentre lo digitiamo. Per usarlo, mettiamo 01h in AH e chiamiamo INT 21h. Il carattere letto viene restituito in AL. Ecco un esempio pratico che mostra come implementare questa operazione:

```assembly
; Legge un carattere dalla tastiera e lo visualizza
MOV AH, 01h        ; Servizio 01h: leggi carattere con echo
INT 21h            ; Chiama DOS
; Ora AL contiene il codice ASCII del carattere digitato
MOV carattere, AL  ; Salva il carattere in memoria
```

Questo servizio si blocca aspettando che l'utente prema un tasto, quindi è perfetto per situazioni in cui vogliamo che il programma attenda un input. Tuttavia, ha una limitazione: visualizza automaticamente il carattere sullo schermo. Se vogliamo leggere una password senza mostrarla, dobbiamo usare un servizio diverso.

Il servizio 08h fa esattamente questo: legge un carattere senza visualizzarlo. È identico nell'uso al servizio 01h ma non produce alcun output video. Questo è utile non solo per password ma anche per input in giochi o programmi interattivi dove vogliamo controllare noi come e dove appare il feedback all'utente.

Per scrivere sullo schermo abbiamo diverse opzioni. Il servizio 02h visualizza un singolo carattere il cui codice ASCII deve essere in DL. Questo è il modo più semplice e diretto per output di base:

```assembly
; Visualizza il carattere 'A' sullo schermo
MOV AH, 02h        ; Servizio 02h: scrivi carattere
MOV DL, 'A'        ; Carattere da visualizzare
INT 21h            ; Chiama DOS
```

Se dobbiamo visualizzare un carattere che abbiamo in AL invece che in DL, possiamo trasferirlo con MOV DL, AL prima della chiamata. Notate che questo servizio interpreta alcuni caratteri in modo speciale: se scriviamo il carattere 07h (BEL), sentiremo un beep; se scriviamo 0Ah (Line Feed), il cursore scende di una riga; se scriviamo 0Dh (Carriage Return), il cursore torna all'inizio della riga corrente.

## Gestione di Stringhe

Quando dobbiamo visualizzare un'intera stringa invece di un singolo carattere, carattere per carattere diventa rapidamente tedioso. Il servizio 09h ci viene in aiuto permettendoci di visualizzare un'intera stringa in una volta sola. La stringa deve terminare con il carattere speciale dollaro (24h o '$'). Dobbiamo mettere l'indirizzo della stringa in DS:DX. Ecco come funziona nella pratica:

```assembly
.DATA
messaggio DB 'Benvenuto nel programma!$'  ; Il $ segna la fine

.CODE
MOV AH, 09h           ; Servizio 09h: visualizza stringa
LEA DX, messaggio     ; Carica l'indirizzo del messaggio in DX
INT 21h               ; Chiama DOS e visualizza la stringa
```

L'istruzione LEA (Load Effective Address) carica in DX l'offset di 'messaggio' all'interno del segmento dati. Alcuni programmatori preferiscono usare MOV DX, OFFSET messaggio che ha lo stesso effetto. La stringa può contenere caratteri speciali come 0Dh e 0Ah per andare a capo, permettendoci di formattare l'output su più righe.

Un dettaglio importante: il carattere '$' non viene visualizzato, serve solo come terminatore. Se la vostra stringa deve contenere un dollaro effettivo, dovrete usare un approccio diverso, ad esempio visualizzando carattere per carattere con il servizio 02h.

Per leggere una stringa dalla tastiera il DOS offre il servizio 0Ah. Questo servizio è più complesso perché richiede di preparare un buffer in memoria con una struttura particolare. Il primo byte deve contenere la dimensione massima del buffer (quanti caratteri possiamo accettare al massimo), il DOS scriverà nel secondo byte il numero effettivo di caratteri letti, e dal terzo byte in poi verranno memorizzati i caratteri digitati:

```assembly
.DATA
buffer DB 50          ; Massimo 50 caratteri
       DB ?           ; Il DOS scriverà qui la lunghezza effettiva
       DB 50 DUP(?)   ; Spazio per i caratteri

.CODE
MOV AH, 0Ah           ; Servizio 0Ah: leggi stringa
LEA DX, buffer        ; Indirizzo del buffer
INT 21h               ; Chiama DOS
; Ora buffer+1 contiene il numero di caratteri letti
; e da buffer+2 in poi ci sono i caratteri
```

Questo servizio permette all'utente di usare i tasti backspace per correggere errori, e termina quando viene premuto Invio. Il carattere di Invio (0Dh) non viene incluso nella stringa memorizzata. Questa è una funzione molto utile perché il DOS gestisce automaticamente l'editing basilare della linea di input.

## Gestione dei File

Le operazioni su file rappresentano uno degli aspetti più potenti delle interruzioni DOS. Il sistema operativo gestisce per noi tutti i dettagli complicati dell'accesso al disco, della gestione del filesystem e del buffering. Vediamo il ciclo tipico di lavoro con un file: aprirlo, leggerlo o scriverlo, e infine chiuderlo.

Per aprire un file usiamo il servizio 3Dh. Dobbiamo specificare il nome del file (come stringa terminata da zero, non da dollaro come per la visualizzazione) e la modalità di apertura: sola lettura (AL=0), sola scrittura (AL=1) o lettura/scrittura (AL=2). Il DOS restituisce in AX un numero chiamato file handle, che è essenzialmente un identificativo univoco per quel file aperto. Useremo questo handle in tutte le successive operazioni sul file:

```assembly
.DATA
nomefile DB 'DATI.TXT', 0  ; Nome file terminato da zero
handle   DW ?              ; Variabile per memorizzare l'handle

.CODE
MOV AH, 3Dh               ; Servizio 3Dh: apri file
MOV AL, 0                 ; Modalità: sola lettura
LEA DX, nomefile          ; Indirizzo del nome file
INT 21h                   ; Chiama DOS
JC errore_apertura        ; Se CF=1 c'è stato un errore
MOV handle, AX            ; Salva l'handle del file
```

Notate l'istruzione JC (Jump if Carry). Quando un'operazione su file fallisce, il DOS segnala l'errore settando il flag Carry e mettendo in AX un codice che indica il tipo di errore. È fondamentale controllare sempre il flag Carry dopo operazioni su file, perché il file potrebbe non esistere, potrebbe essere protetto, o il disco potrebbe essere pieno.

Una volta aperto il file, possiamo leggerlo con il servizio 3Fh. Specifichiamo quanti byte vogliamo leggere in CX, dove metterli in memoria (DS:DX), e quale file leggere tramite il suo handle in BX. Il DOS restituisce in AX il numero di byte effettivamente letti, che potrebbe essere minore di quanto richiesto se raggiungiamo la fine del file:

```assembly
.DATA
buffer_lettura DB 100 DUP(?)  ; Buffer per 100 byte
bytes_letti    DW ?

.CODE
MOV AH, 3Fh                ; Servizio 3Fh: leggi da file
MOV BX, handle             ; Handle del file
MOV CX, 100                ; Vogliamo leggere 100 byte
LEA DX, buffer_lettura     ; Dove mettere i dati letti
INT 21h                    ; Chiama DOS
JC errore_lettura          ; Controlla errori
MOV bytes_letti, AX        ; Salva quanti byte sono stati letti
CMP AX, 0                  ; Se AX=0 abbiamo raggiunto la fine
JE fine_file               ; Salta se fine file
```

Scrivere su file è speculare alla lettura, usando il servizio 40h. Mettiamo in CX quanti byte scrivere, in DS:DX dove sono i dati da scrivere, e in BX l'handle del file. Il DOS restituisce in AX il numero di byte effettivamente scritti. Se questo numero è diverso da quello richiesto, probabilmente il disco è pieno:

```assembly
.DATA
dati_da_scrivere DB 'Questa riga verrà scritta nel file', 0Dh, 0Ah
lunghezza EQU $ - dati_da_scrivere

.CODE
MOV AH, 40h                    ; Servizio 40h: scrivi su file
MOV BX, handle                 ; Handle del file
MOV CX, lunghezza              ; Quanti byte scrivere
LEA DX, dati_da_scrivere       ; Indirizzo dei dati
INT 21h                        ; Chiama DOS
JC errore_scrittura            ; Controlla errori
CMP AX, CX                     ; Verifica che tutti i byte siano stati scritti
JNE disco_pieno                ; Se diverso, probabile disco pieno
```

Quando abbiamo finito con un file, dobbiamo sempre chiuderlo con il servizio 3Eh. Questo è fondamentale perché assicura che tutti i dati bufferizzati vengano effettivamente scritti su disco e che le strutture interne del sistema operativo vengano aggiornate correttamente. Non chiudere un file può causare perdita di dati:

```assembly
MOV AH, 3Eh          ; Servizio 3Eh: chiudi file
MOV BX, handle       ; Handle del file da chiudere
INT 21h              ; Chiama DOS
JC errore_chiusura   ; Controlla errori (raro ma possibile)
```

Se vogliamo creare un nuovo file, usiamo il servizio 3Ch. Dobbiamo fornire il nome del file e gli attributi (normalmente 0 per un file normale). Se il file esiste già, viene troncato a lunghezza zero. Il DOS restituisce l'handle del file appena creato:

```assembly
.DATA
nuovo_file DB 'OUTPUT.TXT', 0

.CODE
MOV AH, 3Ch                ; Servizio 3Ch: crea file
MOV CX, 0                  ; Attributi: file normale
LEA DX, nuovo_file         ; Nome del file
INT 21h                    ; Chiama DOS
JC errore_creazione        ; Controlla errori
MOV handle, AX             ; Salva l'handle
```

Un servizio molto utile è il 41h che cancella un file. Basta fornire il nome del file e il DOS lo rimuove dal filesystem:

```assembly
.DATA
file_da_cancellare DB 'TEMP.DAT', 0

.CODE
MOV AH, 41h                      ; Servizio 41h: cancella file
LEA DX, file_da_cancellare       ; Nome del file
INT 21h                          ; Chiama DOS
JC errore_cancellazione          ; Controlla errori
```

## Terminazione del Programma

Quando il nostro programma ha finito la sua esecuzione, deve restituire il controllo al DOS. Il modo corretto di farlo è usando il servizio 4Ch. Questo servizio non solo termina il programma ma permette anche di restituire un codice di uscita in AL, che può essere letto da programmi batch o altri programmi per sapere se l'esecuzione è andata a buon fine:

```assembly
MOV AH, 4Ch          ; Servizio 4Ch: termina programma
MOV AL, 0            ; Codice di uscita 0 (successo)
INT 21h              ; Chiama DOS - il programma termina qui
```

Per convenzione, un codice di uscita 0 significa successo, mentre valori diversi da zero indicano vari tipi di errore. Nei programmi COM più vecchi si usava anche INT 20h per terminare, ma 4Ch è decisamente superiore perché gestisce correttamente la chiusura di tutti i file aperti e la liberazione delle risorse.

## Gestione di Data e Ora

Il DOS offre servizi per leggere e impostare data e ora di sistema. Il servizio 2Ah legge la data corrente, restituendo l'anno in CX, il mese in DH, il giorno in DL e il giorno della settimana in AL (0=domenica, 1=lunedì, eccetera):

```assembly
MOV AH, 2Ah          ; Servizio 2Ah: leggi data
INT 21h              ; Chiama DOS
; CX = anno (1980-2099)
; DH = mese (1-12)
; DL = giorno (1-31)
; AL = giorno della settimana (0-6)
```

Analogamente, il servizio 2Ch legge l'ora restituendo le ore in CH, i minuti in CL, i secondi in DH e i centesimi di secondo in DL. Questi servizi sono utili per timestampare operazioni, calcolare intervalli di tempo, o semplicemente mostrare data e ora all'utente.

## Gestione della Memoria

Nei programmi più complessi potremmo aver bisogno di allocare memoria dinamicamente. Il servizio 48h richiede memoria aggiuntiva. Specifichiamo in BX quanti paragrafi (blocchi di 16 byte) vogliamo, e il DOS restituisce in AX il segmento di inizio dell'area allocata:

```assembly
MOV AH, 48h          ; Servizio 48h: alloca memoria
MOV BX, 1000h        ; Vogliamo 1000h paragrafi (64KB)
INT 21h              ; Chiama DOS
JC memoria_insufficiente  ; Se CF=1 non c'è abbastanza memoria
; AX contiene il segmento dell'area allocata
MOV ES, AX           ; Possiamo usarla tramite ES
```

Quando non ci serve più, liberiamo la memoria con il servizio 49h, passando in ES il segmento dell'area da liberare. Questo ciclo di allocazione e deallocazione è fondamentale per programmi che lavorano con quantità variabili di dati.

## Pattern Comuni e Best Practices

Nella programmazione DOS assembly, emergono alcuni pattern che vedrete ripetuti costantemente. Quando lavorate con file, strutturate sempre il codice in tre fasi distinte: apertura con controllo errori, elaborazione (lettura/scrittura) in un ciclo con controlli, e chiusura garantita anche in caso di errore. Usate sempre label per gestire i diversi tipi di errore in modo chiaro.

Per operazioni di I/O su console, tenete presente che il servizio 09h è più efficiente di chiamate ripetute al servizio 02h quando dovete visualizzare testo lungo. Preparate le stringhe in anticipo nel segmento dati con i terminatori corretti.

Quando leggete input dall'utente, validate sempre i dati. Non assumete che l'utente inserisca quello che vi aspettate. Controllate la lunghezza, i caratteri ammessi, i range numerici. L'assembly non ha eccezioni o sistemi di sicurezza automatici: ogni controllo deve essere esplicito nel vostro codice.

Infine, ricordate che le interruzioni DOS modificano alcuni registri. AX viene quasi sempre modificato (contiene il risultato o il codice di errore), e anche altri registri possono cambiare a seconda del servizio. Se avete valori importanti nei registri, salvateli sullo stack con PUSH prima della chiamata e ripristinateli con POP dopo. Questo è particolarmente importante nelle procedure che chiamate più volte, dove perdere il contenuto di un registro può causare bug difficilissimi da trovare.