# Introduzione all'Architettura Intel 8086

## Panoramica Storica

L'Intel 8086, introdotto nel 1978, rappresenta un punto di svolta nella storia dell'informatica. Questo microprocessore a 16 bit ha dato origine alla famiglia di processori x86, architettura che ancora oggi domina il mercato dei personal computer e dei server.

### Caratteristiche Principali

- **Architettura**: 16 bit
- **Bus dati**: 16 bit
- **Bus indirizzi**: 20 bit (può indirizzare fino a 1 MB di memoria)
- **Velocità di clock**: 5-10 MHz (nelle versioni originali)
- **Numero di transistor**: circa 29.000
- **Tecnologia**: HMOS (High-density Metal-Oxide Semiconductor)

### Evoluzione dell'Architettura x86

```
1978 - Intel 8086/8088 (16 bit)
1982 - Intel 80286 (16 bit con protezione)
1985 - Intel 80386 (32 bit)
1989 - Intel 80486 (32 bit con cache)
1993 - Intel Pentium (32 bit superscalare)
...
2003 - AMD64/Intel 64 (estensione a 64 bit)
```

Ogni generazione ha mantenuto la compatibilità con le precedenti, permettendo di eseguire software scritto per l'8086 anche sui processori moderni (modalità Real Mode o Virtual 8086 Mode).

## Architettura Interna del Processore

L'8086 utilizza un'architettura con **due unità funzionali separate** che lavorano in parallelo:

### Bus Interface Unit (BIU)

La BIU gestisce tutti i trasferimenti di dati tra il processore e la memoria o le periferiche di I/O.

**Funzioni principali:**
- Prelievo delle istruzioni dalla memoria (instruction prefetch)
- Lettura e scrittura di dati in memoria
- Gestione della coda delle istruzioni (6 byte nell'8086)
- Calcolo degli indirizzi fisici

**Componenti:**
- Registri di segmento (CS, DS, SS, ES)
- Puntatore all'istruzione (IP)
- Coda di prefetch (6 byte)
- Sommatore per il calcolo degli indirizzi fisici

### Execution Unit (EU)

L'EU esegue le istruzioni prelevate dalla BIU.

**Funzioni principali:**
- Decodifica delle istruzioni
- Esecuzione delle operazioni aritmetiche e logiche
- Gestione del controllo di flusso

**Componenti:**
- Registri generali (AX, BX, CX, DX)
- Registri puntatori e indice (SP, BP, SI, DI)
- Registro dei flag (FLAGS)
- ALU (Arithmetic Logic Unit)
- Unità di controllo

## Pipeline di Istruzioni

Una caratteristica innovativa dell'8086 è la **pipeline a due stadi**, che permette di sovrapporre le fasi di fetch ed esecuzione:

```
Tempo:    T1    T2    T3    T4    T5    T6
        ┌─────┬─────┬─────┬─────┬─────┬─────┐
BIU:    │ F1  │ F2  │ F3  │ F4  │ F5  │ F6  │  (Fetch)
        ├─────┼─────┼─────┼─────┼─────┼─────┤
EU:     │     │ E1  │ E2  │ E3  │ E4  │ E5  │  (Execute)
        └─────┴─────┴─────┴─────┴─────┴─────┘

F = Fetch (prelievo istruzione)
E = Execute (esecuzione istruzione)
```

**Vantaggi:**
- Miglioramento delle prestazioni del 30-40%
- Utilizzo più efficiente delle risorse del processore

**Svantaggi:**
- Penalità in caso di salti (branch penalty)
- Necessità di svuotare la coda quando il flusso cambia

## Organizzazione della Memoria

L'8086 utilizza un modello di **memoria segmentata** che permette di indirizzare 1 MB di memoria (2²⁰ byte) utilizzando registri a 16 bit.

### Principio della Segmentazione

La memoria è divisa concettualmente in **segmenti** di dimensione massima 64 KB. Ogni segmento inizia a un indirizzo multiplo di 16 byte (allineamento a paragrafo).

**Formato dell'indirizzo logico:**
```
Segmento:Offset
   16 bit : 16 bit
```

### Calcolo dell'Indirizzo Fisico

L'indirizzo fisico a 20 bit si ottiene con la formula:

```
Indirizzo Fisico = (Segmento × 16) + Offset
                 = (Segmento << 4) + Offset
```

**Esempio 1:**
```
Segmento = 1234h
Offset   = 5678h

Calcolo:
1234h × 10h = 12340h
12340h + 5678h = 179B8h

Indirizzo fisico = 179B8h
```

**Esempio 2:**
```
Segmento = FFFFh
Offset   = 0010h

Calcolo:
FFFFh × 10h = FFFF0h
FFFF0h + 0010h = 100000h

Nota: Risultato oltre 1 MB! (wrap-around in sistemi reali)
```

### Sovrapposizione dei Segmenti

Più coppie segmento:offset possono riferirsi allo stesso indirizzo fisico:

```
1000:0100 → 10100h
1010:0000 → 10100h
1008:0080 → 10100h
```

Questo offre flessibilità ma può creare confusione nella gestione della memoria.

## Registri di Segmento

L'8086 ha quattro registri di segmento a 16 bit, ognuno con uno scopo specifico:

### CS - Code Segment

Punta al segmento che contiene il codice del programma in esecuzione.

- Usato insieme a IP (Instruction Pointer)
- Indirizzo dell'istruzione corrente: CS:IP
- Non può essere modificato direttamente con MOV

**Modificabile con:**
- Istruzioni di salto (JMP, CALL, RET)
- Istruzioni di interrupt

### DS - Data Segment

Punta al segmento dati predefinito del programma.

- Usato per l'accesso ai dati
- Segmento di default per la maggior parte delle istruzioni
- Modificabile con MOV

**Esempio:**
```assembly
MOV AX, 2000h
MOV DS, AX        ; Imposta DS a 2000h
MOV BX, [1000h]   ; Legge da 2000:1000
```

### SS - Stack Segment

Punta al segmento dello stack.

- Usato insieme a SP (Stack Pointer) e BP (Base Pointer)
- Indirizzo del top dello stack: SS:SP
- Modificabile con MOV (ma attenzione!)

**Attenzione:** Modificare SS richiede precauzioni per evitare corruzione dello stack.

### ES - Extra Segment

Segmento extra per operazioni su dati aggiuntivi.

- Utilizzato dalle istruzioni di manipolazione stringhe
- Destinazione per MOVS, CMPS, SCAS, STOS
- Modificabile con MOV

**Esempio:**
```assembly
MOV AX, 3000h
MOV ES, AX        ; Imposta ES a 3000h
MOV DI, 0         ; Offset di destinazione
STOSB             ; Scrive in ES:DI
```

## Allineamento dei Segmenti

I segmenti devono iniziare a indirizzi **allineati a paragrafo** (multipli di 16 byte = 10h).

**Indirizzi validi per segmenti:**
```
0000h, 0010h, 0020h, ..., FFF0h
```

**Indirizzi non validi:**
```
0001h, 000Fh, 0123h (non multipli di 16)
```

Questo allineamento:
- Semplifica il calcolo degli indirizzi fisici (shift di 4 bit)
- Limita la granularità del posizionamento dei segmenti
- Permette sovrapposizioni controllate

## Modelli di Memoria

In base a come vengono utilizzati i segmenti, esistono diversi modelli di memoria:

### Tiny Model
- Tutti i segmenti coincidono (CS = DS = SS = ES)
- Programma + dati + stack ≤ 64 KB
- File .COM del DOS

### Small Model
- CS diverso da DS = SS = ES
- Codice ≤ 64 KB, dati + stack ≤ 64 KB

### Compact Model
- CS unico, DS può cambiare
- Codice ≤ 64 KB, dati > 64 KB

### Medium Model
- CS può cambiare, DS = SS = ES
- Codice > 64 KB, dati ≤ 64 KB

### Large Model
- CS e DS possono cambiare
- Codice e dati > 64 KB

### Huge Model
- Come Large, ma singoli array possono superare 64 KB

## Conclusione

L'architettura dell'8086, pur essendo semplice rispetto agli standard moderni, ha introdotto concetti fondamentali:

- Pipeline di istruzioni
- Memoria segmentata
- Organizzazione gerarchica dei registri
- Separazione tra fetch ed esecuzione

Comprendere questi concetti è essenziale prima di procedere con la programmazione assembly, poiché influenzano direttamente come si scrive e si organizza il codice.

## Esercizi di Verifica

1. Calcolare l'indirizzo fisico per le seguenti coppie segmento:offset:
   - a) 1000h:2000h
   - b) A000h:B000h
   - c) FFFFh:FFFFh

2. Trovare tre diverse coppie segmento:offset che puntano all'indirizzo fisico 12345h

3. Qual è la dimensione massima di un segmento nell'8086? Perché?

4. Spiegare perché l'8086 può indirizzare 1 MB di memoria nonostante utilizzi registri a 16 bit

5. Quali sono i vantaggi e gli svantaggi della memoria segmentata rispetto a un modello lineare?

---

**Prossimo argomento:** [Registri dell'8086](modulo1_02_registri_8086.md)
