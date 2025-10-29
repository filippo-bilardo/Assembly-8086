# Installare TASM su DOSBox

Ecco la procedura completa per installare e configurare TASM (Turbo Assembler) su DOSBox in Windows 11:

## 1. **Installare DOSBox**

- Scarica DOSBox da [dosbox.com](https://www.dosbox.com)
- Installa normalmente su Windows 11

## 2. **Scaricare TASM**

- Cerca "TASM download" o "Turbo Assembler Borland"
- Scarica il pacchetto TASM (tipicamente tasm.zip o simile)
- Puoi trovare versioni come TASM 3.0, 4.0 o 5.0
- [link](https://sourceforge.net/projects/assemblydocdownload/)

## 3. **Preparare la cartella**

Crea una struttura di cartelle sul tuo PC:

```
C:\ASM\
    ├── TASM\      (qui metterai TASM.EXE, TLINK.EXE, ecc.)
    └── WORK\      (qui metterai i tuoi programmi .asm)
```

Estrai i file di TASM nella cartella `C:\ASM\TASM\`

## 4. **Configurare DOSBox**

Apri DOSBox e digita i seguenti comandi:

```dos
mount c c:\asm
c:
cd tasm
```

## 5. **Testare l'installazione**

```dos
tasm
```

Dovresti vedere le informazioni sulla versione di TASM.

## 6. **Configurazione automatica (opzionale)**

Per non dover digitare i comandi ogni volta, modifica il file di configurazione di DOSBox:

- Trova il file `dosbox-[versione].conf` (di solito in `C:\Users\[tuonome]\AppData\Local\DOSBox\`)
- Apri con un editor di testo
- Alla fine del file, nella sezione `[autoexec]`, aggiungi:

```ini
[autoexec]
mount c c:\asm
c:
set path=c:\tasm
cd work
```

## 7. **Workflow tipico**

Crea un file di test `hello.asm` in `C:\ASM\WORK\`:

```assembly
.model small
.stack 100h
.data
    msg db 'Hello, World!$'
.code
main proc
    mov ax, @data
    mov ds, ax
    
    mov ah, 09h
    lea dx, msg
    int 21h
    
    mov ah, 4ch
    int 21h
main endp
end main
```

In DOSBox:

```dos
cd work
tasm hello.asm
tlink hello.obj
hello.exe
```

## 8. **Comandi utili**

```dos
tasm hello.asm          ; Assembla
tlink hello.obj         ; Collega
tasm /zi hello.asm      ; Assembla con info di debug
td hello.exe            ; Debug con Turbo Debugger (se disponibile)
```

## Troubleshooting

**Se TASM non viene trovato:**
```dos
set path=c:\tasm
```

**Per vedere il PATH corrente:**
```dos
path
```

**Per velocizzare DOSBox** (modifica nel file .conf):
```ini
cycles=max
```

## Alternativa: Pacchetto preconfigurato

Alcuni sviluppatori offrono pacchetti DOSBox + TASM già pronti. Cerca "DOSBox TASM package" per soluzioni preconfigurate che includono tutto il necessario.

Hai bisogno di aiuto per qualche passaggio specifico?