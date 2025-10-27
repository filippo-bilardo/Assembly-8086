# La Struttura della Memoria nei Programmi Assembly 8086

Quando un programma assembly viene caricato in memoria ed eseguito, occupa diverse aree distinte, ciascuna con uno scopo specifico. Comprendere questa organizzazione è fondamentale perché influenza direttamente come scriviamo il codice e come gestiamo i dati.

## Il Modello di Memoria Segmentata

L'8086 utilizza un approccio particolare alla memoria chiamato "segmentazione". A differenza dei processori moderni che vedono la memoria come un unico spazio lineare, l'8086 divide la memoria in segmenti da 64KB ciascuno. Questo deriva da una limitazione fisica: i registri sono a 16 bit e possono quindi indirizzare solo 65536 posizioni (64KB), ma Intel voleva permettere l'accesso a 1MB di memoria. La soluzione fu ingegnosa: usare due valori per ogni indirizzo, il segmento e l'offset.

Ogni indirizzo fisico viene calcolato moltiplicando il valore del segmento per 16 e sommando l'offset. Questa formula permette di raggiungere qualsiasi locazione nei primi 1.048.576 byte di memoria. Ad esempio, se il registro CS (Code Segment) contiene il valore 1000h e l'Instruction Pointer contiene 0050h, l'indirizzo fisico dell'istruzione corrente sarà 10000h + 0050h = 10050h.

## I Quattro Segmenti Fondamentali

Un programma assembly tipico organizza la propria memoria in quattro segmenti principali, ognuno gestito da un registro dedicato.

Il **segmento di codice** contiene le istruzioni del programma, quelle che la CPU esegue sequenzialmente. Il registro CS punta sempre all'inizio di questo segmento, mentre il registro IP (Instruction Pointer) contiene l'offset dell'istruzione corrente all'interno del segmento. Quando scriviamo le nostre procedure e funzioni, il codice macchina risultante finisce qui. È importante notare che in un programma ben scritto, il segmento di codice dovrebbe contenere solo istruzioni eseguibili e costanti, mai dati che devono essere modificati durante l'esecuzione.

Il **segmento dati** ospita le variabili globali del programma, quelle che dichiariamo nella sezione dati. Il registro DS (Data Segment) punta a questo segmento. Quando scriviamo `MOV AL, [variabile]`, il processore calcola l'indirizzo fisico combinando DS con l'offset di 'variabile'. Qui troviamo le nostre stringhe, i nostri array, i buffer per l'input/output e qualsiasi altra informazione che deve persistere per tutta la durata del programma. Possiamo dichiarare dati inizializzati usando direttive come DB (Define Byte) e DW (Define Word), oppure riservare spazio non inizializzato con direttive come RESB e RESW.

Il **segmento stack** è forse il più interessante dal punto di vista dinamico. Lo stack è una struttura dati di tipo LIFO (Last In, First Out) che cresce verso il basso in memoria, ovvero verso indirizzi decrescenti. Il registro SS (Stack Segment) indica dove inizia questo segmento, mentre SP (Stack Pointer) mantiene l'offset dell'elemento attualmente in cima allo stack. Ogni volta che eseguiamo un PUSH, il valore di SP diminuisce e il dato viene scritto nella nuova posizione. Con POP accade l'opposto: leggiamo il dato e incrementiamo SP.

Lo stack ha molteplici funzioni critiche. Quando chiamiamo una procedura con CALL, l'indirizzo di ritorno viene automaticamente salvato sullo stack. Se la procedura ha variabili locali, queste possono essere allocate sullo stack modificando temporaneamente SP. I parametri possono essere passati alle funzioni tramite lo stack, e i registri che vogliamo preservare durante una procedura vengono salvati qui. Pensate allo stack come a una pila di piatti: potete aggiungere piatti in cima o toglierli, ma sempre dall'alto, mai dal mezzo.

Il **segmento extra** (ES) è un quarto segmento utilizzato principalmente per operazioni che richiedono l'accesso a due aree di memoria diverse simultaneamente. Le istruzioni per operazioni su stringhe, come MOVS che copia blocchi di memoria, usano DS:SI come sorgente ed ES:DI come destinazione. Questo permette di copiare dati da un segmento all'altro in modo efficiente.

## Disposizione Tipica in Memoria

Quando il DOS carica un programma COM (il formato più semplice), tutti e quattro i registri di segmento vengono inizializzati allo stesso valore. L'intero programma sta in un unico segmento da 64KB. I primi 256 byte sono riservati al PSP (Program Segment Prefix), una struttura dati che il DOS usa per gestire il programma. Il nostro codice inizia a offset 100h, e possiamo mischiare codice, dati e stack come preferiamo, purché stiamo attenti a non sovrascrivere nulla.

I programmi EXE (il formato più strutturato) hanno una organizzazione più complessa ma anche più flessibile. Il caricatore del DOS legge l'intestazione EXE, che specifica dove collocare i vari segmenti, e inizializza CS, DS, SS ed ES di conseguenza. Questo permette di avere programmi più grandi di 64KB, con segmenti di codice, dati e stack ben separati e protetti l'uno dall'altro. Un programma EXE può avere un segmento di codice da 64KB, un segmento dati da 64KB e uno stack da 4KB, per esempio.

## La Crescita dello Stack: un Aspetto Critico

Un punto che spesso crea confusione è la direzione di crescita dello stack. Quando inizializziamo lo stack, impostiamo SP al valore massimo dell'area riservata (ad esempio, se abbiamo riservato 100h byte per lo stack, SP inizia a 100h). Ogni PUSH decrementa SP prima di scrivere il valore. Quindi se lo stack inizia a 100h e facciamo PUSH AX (dove AX è a 16 bit, quindi 2 byte), SP diventa 0FEh e il valore di AX viene scritto agli indirizzi 0FEh e 0FFh.

Questa crescita verso il basso ha una conseguenza importante: se non dimensioniamo correttamente lo stack, questo può "invadere" il segmento dati sovrapponendosi ad esso. Immaginate di avere i dati che partono da offset 0 e crescono verso l'alto, e lo stack che parte dall'alto e cresce verso il basso. Se usiamo troppa memoria dati o troppo stack, prima o poi si incontreranno, causando corruzione dei dati e comportamenti imprevedibili. Questa è una delle cause più comuni e difficili da debuggare nei programmi assembly.

## Un Esempio Pratico di Strutturazione

Consideriamo un programma che legge dei numeri, li somma e stampa il risultato. Nel segmento dati dichiareremmo il messaggio di prompt per l'utente, un buffer per leggere l'input, la variabile per contenere la somma parziale e il messaggio con il risultato. Nel segmento codice avremmo il ciclo principale che legge i numeri, la procedura per convertire le stringhe in numeri, la procedura per sommare, e la procedura per convertire il risultato in stringa stampabile. Lo stack ci servirebbe per salvare i registri quando chiamiamo le procedure e per passare eventualmente i parametri.

Durante l'esecuzione, il segmento dati conterrebbe sempre le stesse zone di memoria (anche se i loro contenuti cambiano), il codice resterebbe immutato, mentre lo stack crescerebbe e si restringerebbe dinamicamente man mano che chiamiamo e ritorniamo dalle procedure.

## Considerazioni sulla Dimensione dei Segmenti

La dimensione di ciascun segmento deve essere scelta con attenzione. Un codice troppo complesso potrebbe non entrare in 64KB, richiedendo l'uso di procedure FAR e segmenti di codice multipli. Troppi dati globali hanno lo stesso problema. Lo stack deve essere dimensionato considerando la profondità massima delle chiamate annidate e lo spazio per le variabili locali. Una regola empirica è riservare almeno 200h byte (512 byte) per lo stack nei programmi semplici, ma programmi con ricorsione profonda o molte variabili locali possono richiedere diversi kilobyte.

Questa comprensione della struttura della memoria vi permette non solo di scrivere programmi corretti, ma anche di capire perché certi errori accadono (come il classico stack overflow) e come ottimizzare l'uso delle risorse limitate del sistema.s