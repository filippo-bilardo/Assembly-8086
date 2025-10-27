# Appendice A: Quick Reference del Set di Istruzioni 8086

## Tabella Completa Istruzioni

### Istruzioni di Trasferimento Dati

| Istruzione | Sintassi | Descrizione | Flag | Cicli |
|------------|----------|-------------|------|-------|
| **MOV** | MOV dest, source | Copia source → dest | - | 2-4 |
| **XCHG** | XCHG op1, op2 | Scambia op1 ↔ op2 | - | 3-4 |
| **LEA** | LEA reg, mem | Carica indirizzo effettivo | - | 2 |
| **LDS** | LDS reg, mem | Carica DS:reg da mem (4 byte) | - | 16 |
| **LES** | LES reg, mem | Carica ES:reg da mem (4 byte) | - | 16 |
| **PUSH** | PUSH source | Inserisce source su stack | - | 11-15 |
| **POP** | POP dest | Estrae da stack → dest | - | 8-12 |
| **PUSHF** | PUSHF | Push FLAGS su stack | - | 10 |
| **POPF** | POPF | Pop stack → FLAGS | Tutti | 8 |
| **XLATB** | XLATB | AL = DS:[BX+AL] | - | 11 |
| **IN** | IN AL/AX, port | Input da porta I/O | - | 10-14 |
| **OUT** | OUT port, AL/AX | Output a porta I/O | - | 10-14 |

**Note MOV:**
- Non permette: mem→mem, seg→seg, imm→seg, CS come destinazione
- Permette: reg→reg, reg→mem, mem→reg, imm→reg, imm→mem, seg→reg/mem, reg/mem→seg

### Istruzioni Aritmetiche

| Istruzione | Sintassi | Descrizione | Flag | Cicli |
|------------|----------|-------------|------|-------|
| **ADD** | ADD dest, source | dest = dest + source | OSZAPC | 3-4 |
| **ADC** | ADC dest, source | dest = dest + source + CF | OSZAPC | 3-4 |
| **SUB** | SUB dest, source | dest = dest - source | OSZAPC | 3-4 |
| **SBB** | SBB dest, source | dest = dest - source - CF | OSZAPC | 3-4 |
| **INC** | INC dest | dest = dest + 1 | OSZAP | 2-3 |
| **DEC** | DEC dest | dest = dest - 1 | OSZAP | 2-3 |
| **NEG** | NEG dest | dest = -dest (complemento a 2) | OSZAPC | 3 |
| **CMP** | CMP op1, op2 | op1 - op2 (solo flag) | OSZAPC | 3-4 |
| **MUL** | MUL source | AX = AL × source (byte)<br>DX:AX = AX × source (word) | OC | 70-77<br>118-133 |
| **IMUL** | IMUL source | Come MUL ma signed | OC | 80-98<br>128-154 |
| **DIV** | DIV source | AL = AX / source, AH = resto (byte)<br>AX = DX:AX / source, DX = resto (word) | - | 80-90<br>144-162 |
| **IDIV** | IDIV source | Come DIV ma signed | - | 101-112<br>165-184 |
| **CBW** | CBW | AX = estensione segno AL | - | 2 |
| **CWD** | CWD | DX:AX = estensione segno AX | - | 5 |
| **AAA** | AAA | ASCII Adjust After Addition | SZPC | 4 |
| **AAS** | AAS | ASCII Adjust After Subtraction | SZPC | 4 |
| **AAM** | AAM | ASCII Adjust After Multiply | SZPC | 83 |
| **AAD** | AAD | ASCII Adjust Before Division | SZPC | 60 |
| **DAA** | DAA | Decimal Adjust After Addition | SZAPC | 4 |
| **DAS** | DAS | Decimal Adjust After Subtraction | SZAPC | 4 |

**Note:**
- **INC/DEC**: non modificano CF (utile in loop con ADC/SBB)
- **MUL/IMUL**: OF=CF=1 se risultato > 16-bit
- **DIV/IDIV**: INT 00h se divisore=0 o quoziente troppo grande

### Istruzioni Logiche

| Istruzione | Sintassi | Descrizione | Flag | Cicli |
|------------|----------|-------------|------|-------|
| **AND** | AND dest, source | dest = dest AND source | SZPC (OF=CF=0) | 3-4 |
| **OR** | OR dest, source | dest = dest OR source | SZPC (OF=CF=0) | 3-4 |
| **XOR** | XOR dest, source | dest = dest XOR source | SZPC (OF=CF=0) | 3-4 |
| **NOT** | NOT dest | dest = ~dest (complemento a 1) | - | 3 |
| **TEST** | TEST op1, op2 | op1 AND op2 (solo flag) | SZPC (OF=CF=0) | 3-4 |

**Idiomi comuni:**
- `XOR AX, AX` - Azzera AX (più veloce di MOV AX,0)
- `TEST AL, AL` - Verifica se AL=0 (setta ZF)
- `OR AX, AX` - Come TEST ma più raro

### Istruzioni di Shift e Rotate

| Istruzione | Sintassi | Descrizione | Flag | Cicli |
|------------|----------|-------------|------|-------|
| **SHL/SAL** | SHL dest, count | Shift Left (×2 per ogni bit) | OSZAPC | 2+n |
| **SHR** | SHR dest, count | Shift Right Unsigned (÷2) | OSZAPC | 2+n |
| **SAR** | SAR dest, count | Shift Arithmetic Right (÷2 signed) | OSZAPC | 2+n |
| **ROL** | ROL dest, count | Rotate Left (circolare) | OC | 2+n |
| **ROR** | ROR dest, count | Rotate Right (circolare) | OC | 2+n |
| **RCL** | RCL dest, count | Rotate Left through Carry | OC | 2+n |
| **RCR** | RCR dest, count | Rotate Right through Carry | OC | 2+n |

**Note:**
- `count` può essere: 1 (immediato) o CL (registro)
- Con count=1: 2 cicli; con CL: 8+4n cicli
- CF contiene ultimo bit shiftato/ruotato
- OF settato solo se count=1

**Esempi:**
```assembly
SHL AX, 1       ; AX = AX × 2
SHL AX, 3       ; AX = AX × 8
SHR BX, 1       ; BX = BX / 2 (unsigned)
SAR CX, 2       ; CX = CX / 4 (signed)
MOV CL, 4
ROL DX, CL      ; Rotate DX left 4 bit
```

### Istruzioni di Salto Condizionato

| Istruzione | Condizione | Flag | Descrizione |
|------------|------------|------|-------------|
| **JE/JZ** | ZF=1 | Equal / Zero | op1 = op2 |
| **JNE/JNZ** | ZF=0 | Not Equal / Not Zero | op1 ≠ op2 |
| **JS** | SF=1 | Sign | Risultato negativo |
| **JNS** | SF=0 | Not Sign | Risultato positivo |
| **JO** | OF=1 | Overflow | Overflow aritmetico |
| **JNO** | OF=0 | Not Overflow | Nessun overflow |
| **JC/JB/JNAE** | CF=1 | Carry / Below / Not Above or Equal | op1 < op2 (unsigned) |
| **JNC/JAE/JNB** | CF=0 | Not Carry / Above or Equal / Not Below | op1 ≥ op2 (unsigned) |
| **JP/JPE** | PF=1 | Parity / Parity Even | Parity pari |
| **JNP/JPO** | PF=0 | Not Parity / Parity Odd | Parity dispari |

#### Salti per Confronti Unsigned (dopo CMP)

| Istruzione | Condizione | Flag | Significato |
|------------|------------|------|-------------|
| **JA/JNBE** | CF=0 AND ZF=0 | Above / Not Below or Equal | op1 > op2 |
| **JAE/JNB** | CF=0 | Above or Equal / Not Below | op1 ≥ op2 |
| **JB/JNAE** | CF=1 | Below / Not Above or Equal | op1 < op2 |
| **JBE/JNA** | CF=1 OR ZF=1 | Below or Equal / Not Above | op1 ≤ op2 |

#### Salti per Confronti Signed (dopo CMP)

| Istruzione | Condizione | Flag | Significato |
|------------|------------|------|-------------|
| **JG/JNLE** | ZF=0 AND SF=OF | Greater / Not Less or Equal | op1 > op2 |
| **JGE/JNL** | SF=OF | Greater or Equal / Not Less | op1 ≥ op2 |
| **JL/JNGE** | SF≠OF | Less / Not Greater or Equal | op1 < op2 |
| **JLE/JNG** | ZF=1 OR SF≠OF | Less or Equal / Not Greater | op1 ≤ op2 |

#### Istruzioni di Loop

| Istruzione | Sintassi | Descrizione | Cicli |
|------------|----------|-------------|-------|
| **LOOP** | LOOP label | CX--, salta se CX≠0 | 17/5 |
| **LOOPE/LOOPZ** | LOOPE label | CX--, salta se CX≠0 AND ZF=1 | 18/6 |
| **LOOPNE/LOOPNZ** | LOOPNE label | CX--, salta se CX≠0 AND ZF=0 | 19/5 |
| **JCXZ** | JCXZ label | Salta se CX=0 | 18/6 |

### Istruzioni di Salto Incondizionato

| Istruzione | Sintassi | Descrizione | Cicli |
|------------|----------|-------------|-------|
| **JMP** | JMP label | Salto SHORT (-128..+127) | 15 |
| | JMP label | Salto NEAR (stesso segmento) | 15 |
| | JMP FAR label | Salto FAR (altro segmento) | 15 |
| | JMP reg | Salto indiretto (IP=reg) | 11 |
| | JMP [mem] | Salto indiretto NEAR | 18 |
| | JMP FAR [mem] | Salto indiretto FAR | 24 |

### Istruzioni per Stringhe

| Istruzione | Sintassi | Descrizione | Flag | Cicli |
|------------|----------|-------------|------|-------|
| **MOVSB** | MOVSB | ES:[DI] = DS:[SI], SI±1, DI±1 | - | 18 |
| **MOVSW** | MOVSW | ES:[DI] = DS:[SI], SI±2, DI±2 | - | 18 |
| **CMPSB** | CMPSB | CMP DS:[SI], ES:[DI], SI±1, DI±1 | OSZAPC | 22 |
| **CMPSW** | CMPSW | CMP DS:[SI], ES:[DI], SI±2, DI±2 | OSZAPC | 22 |
| **SCASB** | SCASB | CMP AL, ES:[DI], DI±1 | OSZAPC | 15 |
| **SCASW** | SCASW | CMP AX, ES:[DI], DI±2 | OSZAPC | 15 |
| **LODSB** | LODSB | AL = DS:[SI], SI±1 | - | 12 |
| **LODSW** | LODSW | AX = DS:[SI], SI±2 | - | 12 |
| **STOSB** | STOSB | ES:[DI] = AL, DI±1 | - | 11 |
| **STOSW** | STOSW | ES:[DI] = AX, DI±2 | - | 11 |

**Prefissi:**
- **REP** - Ripeti mentre CX≠0 (con MOVS, STOS, LODS)
- **REPE/REPZ** - Ripeti mentre CX≠0 AND ZF=1 (con CMPS, SCAS)
- **REPNE/REPNZ** - Ripeti mentre CX≠0 AND ZF=0 (con CMPS, SCAS)

**Direzione:**
- **CLD** - Clear Direction Flag (incremento SI/DI)
- **STD** - Set Direction Flag (decremento SI/DI)

### Istruzioni di Controllo

| Istruzione | Sintassi | Descrizione | Flag | Cicli |
|------------|----------|-------------|------|-------|
| **CALL** | CALL proc | PUSH IP, salta NEAR | - | 19 |
| | CALL FAR proc | PUSH CS, PUSH IP, salta FAR | - | 28 |
| | CALL reg | Chiamata indiretta | - | 16 |
| | CALL [mem] | Chiamata indiretta NEAR | - | 21 |
| **RET** | RET | POP IP | - | 8 |
| | RET n | POP IP, SP=SP+n | - | 12 |
| | RETF | POP IP, POP CS | - | 18 |
| | RETF n | POP IP, POP CS, SP=SP+n | - | 17 |
| **INT** | INT n | Software interrupt | All | 51 |
| **INTO** | INTO | INT 04h se OF=1 | - | 53/4 |
| **IRET** | IRET | POP IP, POP CS, POP FLAGS | All | 24 |

### Istruzioni per Flag

| Istruzione | Descrizione | Flag | Cicli |
|------------|-------------|------|-------|
| **CLC** | Clear Carry Flag | CF=0 | 2 |
| **STC** | Set Carry Flag | CF=1 | 2 |
| **CMC** | Complement Carry Flag | CF=~CF | 2 |
| **CLD** | Clear Direction Flag | DF=0 | 2 |
| **STD** | Set Direction Flag | DF=1 | 2 |
| **CLI** | Clear Interrupt Flag | IF=0 | 2 |
| **STI** | Set Interrupt Flag | IF=1 | 2 |
| **LAHF** | Load AH from Flags | AH=FLAGS[7:0] | - | 4 |
| **SAHF** | Store AH into Flags | FLAGS[7:0]=AH | SZAPC | 4 |

### Istruzioni Speciali

| Istruzione | Descrizione | Cicli |
|------------|-------------|-------|
| **NOP** | No Operation (equivale a XCHG AX,AX) | 3 |
| **HLT** | Halt (ferma CPU fino a interrupt) | 2 |
| **WAIT** | Attendi segnale TEST# (per coprocessore) | 3+ |
| **ESC** | Escape (istruzione coprocessore) | 2 |
| **LOCK** | Prefisso: blocca bus durante istruzione | +2 |

### Istruzioni Coprocessore 8087

| Istruzione | Sintassi | Descrizione |
|------------|----------|-------------|
| **FINIT** | FINIT | Inizializza FPU |
| **FLD** | FLD mem/ST(i) | Push su stack FPU |
| **FST** | FST mem/ST(i) | Copia ST(0) |
| **FSTP** | FSTP mem/ST(i) | Pop da stack FPU |
| **FILD** | FILD mem | Load integer → float |
| **FIST** | FIST mem | Store float → integer |
| **FADD** | FADD [mem/ST(i)] | ST(0) = ST(0) + operando |
| **FSUB** | FSUB [mem/ST(i)] | ST(0) = ST(0) - operando |
| **FMUL** | FMUL [mem/ST(i)] | ST(0) = ST(0) × operando |
| **FDIV** | FDIV [mem/ST(i)] | ST(0) = ST(0) / operando |
| **FADDP** | FADDP ST(i),ST(0) | ST(i) += ST(0), pop |
| **FCOM** | FCOM [mem/ST(i)] | Compare ST(0) con operando |
| **FCOMP** | FCOMP | Compare e pop |
| **FSQRT** | FSQRT | ST(0) = √ST(0) |
| **FSIN** | FSIN | ST(0) = sin(ST(0)) |
| **FCOS** | FCOS | ST(0) = cos(ST(0)) |
| **FPTAN** | FPTAN | ST(0) = tan(ST(0)) |
| **FPATAN** | FPATAN | ST(1) = atan(ST(1)/ST(0)), pop |
| **FLDPI** | FLDPI | Push π |
| **FLD1** | FLD1 | Push 1.0 |
| **FLDZ** | FLDZ | Push 0.0 |
| **FSTSW** | FSTSW AX/mem | Status word → AX |
| **FXCH** | FXCH ST(i) | Exchange ST(0) ↔ ST(i) |

## Registro FLAGS

```
15 14 13 12 11 10  9  8  7  6  5  4  3  2  1  0
 -  -  -  - OF DF IF TF SF ZF  - AF  - PF  - CF
```

| Flag | Nome | Descrizione |
|------|------|-------------|
| **CF** | Carry Flag | Riporto/prestito operazioni unsigned |
| **PF** | Parity Flag | 1 se numero pari di bit a 1 in byte basso |
| **AF** | Auxiliary Flag | Riporto/prestito bit 3→4 (BCD) |
| **ZF** | Zero Flag | 1 se risultato = 0 |
| **SF** | Sign Flag | Copia bit più significativo (MSB) |
| **TF** | Trap Flag | 1 = single-step mode (debug) |
| **IF** | Interrupt Flag | 1 = interruzioni abilitate |
| **DF** | Direction Flag | 0 = incremento SI/DI, 1 = decremento |
| **OF** | Overflow Flag | Overflow operazioni signed |

## Codifiche Istruzioni (Formato)

### Formato Generale
```
[Prefisso] [Opcode] [Mod-Reg-R/M] [Displacement] [Immediate]
   0-4 byte  1-2 byte    0-1 byte     0-2 byte     0-2 byte
```

### Byte Mod-Reg-R/M
```
7  6  5  4  3  2  1  0
Mod   Reg     R/M
```

**Mod** (modalità):
- 00 = memoria, nessun displacement
- 01 = memoria, displacement 8-bit
- 10 = memoria, displacement 16-bit
- 11 = registro

**Reg** (registro):
- 000=AL/AX, 001=CL/CX, 010=DL/DX, 011=BL/BX
- 100=AH/SP, 101=CH/BP, 110=DH/SI, 111=BH/DI

**R/M** (registro o memoria):
- Con Mod=11: codice registro
- Con Mod≠11: modalità indirizzamento

## Cicli di Clock

**Note:**
- Cicli indicati sono per 8086 a 5 MHz
- Tempi reali variano con accessi memoria (wait states)
- Prefissi REP moltiplicano cicli per CX
- MOVSW con REP: 9+17×CX cicli

---

**Legenda:**
- dest/source: destinazione/sorgente
- op1/op2: operando 1/2
- reg: registro
- mem: memoria
- imm: valore immediato
- n: numero di shift/rotate