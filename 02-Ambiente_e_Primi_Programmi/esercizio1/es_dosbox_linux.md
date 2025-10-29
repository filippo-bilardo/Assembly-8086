# Lavorare con DOSBox su Linux

Ecco una guida completa per usare DOSBox su Linux per il tuo lavoro di sviluppo Assembly 8086:

## 📦 **Installazione DOSBox**

### Ubuntu/Debian/Linux Mint
DOSBox è disponibile nei repository della maggior parte delle distribuzioni:

```bash
sudo apt update
sudo apt install dosbox
```

### Fedora/RHEL/CentOS
```bash
sudo dnf install dosbox
```

### Arch Linux
```bash
sudo pacman -S dosbox
```

### Via Snap (alternativa universale)
Per installare tramite Snap:

```bash
sudo apt install snapd
sudo snap install dosbox-x
```

## 🚀 **Primo Avvio e Configurazione**

### 1. Avviare DOSBox
```bash
dosbox
```

La prima esecuzione è essenziale perché crea il file di configurazione. Puoi chiudere DOSBox digitando:
```
exit
```

### 2. File di Configurazione
Il file di configurazione si trova in ~/.dosbox/dosbox-[versione].conf

Per modificarlo:
```bash
nano ~/.dosbox/dosbox-0.74-3.conf
```

## 📁 **Setup per Assembly 8086**

### 1. Creare la Struttura delle Directory

```bash
# Crea le cartelle nel tuo home
mkdir -p ~/dosbox/tasm
mkdir -p ~/dosbox/work
```

### 2. Installare TASM
- Scarica TASM (vedi le opzioni della ricerca precedente)
- Estrai i file in `~/dosbox/tasm/`

### 3. Configurazione Automatica

Modifica il file di configurazione DOSBox:

```bash
nano ~/.dosbox/dosbox-0.74-3.conf
```

Alla fine del file, nella sezione [autoexec], aggiungi questi comandi:

```ini
[autoexec]
# Monta automaticamente le directory
mount c ~/dosbox
c:
set path=c:\tasm
cd work
```

## 🔧 **Uso Pratico**

### Workflow Tipico

1. **Scrivi il codice** con il tuo editor preferito (VS Code, Vim, Gedit, etc.) nella cartella `~/dosbox/work/`

2. **Avvia DOSBox**:
```bash
dosbox
```

3. **Compila ed esegui** (già nella directory work grazie all'autoexec):
```dos
tasm hello.asm
tlink /t hello.obj
hello.com
```

### Comandi DOSBox Utili

```dos
# Montare manualmente una directory
mount c ~/dosbox

# Cambiare drive
c:

# Navigazione directory (come DOS)
dir
cd work
cd ..

# Uscire
exit
```

## ⚙️ **Ottimizzazioni Utili**

Nel file di configurazione (`~/.dosbox/dosbox-0.74-3.conf`):

```ini
[cpu]
core=auto
cycles=max          # Velocità massima

[render]
scaler=normal2x     # Migliore qualità video

[sdl]
fullscreen=false
output=opengl       # Migliori prestazioni su Linux
```

## 🎯 **Alternativa: DOSBox-X** (Raccomandato per sviluppo)

DOSBox-X è disponibile in vari formati per Linux, incluso Flatpak che è supportato dalla maggior parte delle distribuzioni:

```bash
# Via Flatpak (universale)
flatpak install flathub com.dosbox_x.DOSBox-X
flatpak run com.dosbox_x.DOSBox-X

# Via Snap
sudo snap install dosbox-x

# Aggiornare Flatpak
flatpak update
```

**Vantaggi di DOSBox-X:**
- Più features per lo sviluppo
- Migliore emulazione
- Supporto per debugger avanzati

## 📝 **Script Utile per Compilazione Rapida**

Crea uno script `compile.sh` nella tua directory work:

```bash
#!/bin/bash
# Salva come ~/dosbox/work/compile.sh

if [ -z "$1" ]; then
    echo "Uso: ./compile.sh nomefile (senza estensione)"
    exit 1
fi

dosbox -c "mount c ~/dosbox" \
       -c "c:" \
       -c "set path=c:\tasm" \
       -c "cd work" \
       -c "tasm $1.asm" \
       -c "tlink /t $1.obj" \
       -c "$1.com" \
       -c "exit"
```

Rendilo eseguibile:
```bash
chmod +x ~/dosbox/work/compile.sh
```

Uso:
```bash
./compile.sh hello
```

## 🔍 **Tips per il Mapping della Tastiera**

Se vuoi modificare i keybinding, puoi eseguire questo comando dal terminale:

```bash
dosbox -startmapper
```

Oppure dentro DOSBox premi `CTRL + F1` per aprire il mapper.

## 📚 **Integrazione con il Tuo Workflow di Scrittura**

Per i tuoi libri, puoi:
1. Scrivere esempi in VS Code con syntax highlighting Assembly
2. Testarli rapidamente in DOSBox
3. Fare screenshot con `CTRL + F5` (salva in `~/.dosbox/capture/`)
4. Includere gli esempi testati nel libro

Hai bisogno di aiuto per configurare qualche aspetto specifico?