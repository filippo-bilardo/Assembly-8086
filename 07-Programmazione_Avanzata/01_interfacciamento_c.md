# Interfacciamento Assembly e C

## Introduzione

L'**interfacciamento** tra Assembly e C permette di:
- Ottimizzare sezioni critiche in Assembly
- Accedere a istruzioni specifiche CPU
- Usare librerie C da Assembly
- Debuggare con strumenti C

Questo modulo copre convenzioni di chiamata, passaggio parametri e esempi pratici.

## Convenzioni di Chiamata

### 1. cdecl (C Declaration)

**Standard C** per DOS/Windows 16-bit.

**Caratteristiche**:
- Parametri passati su **stack** (destra → sinistra)
- **Caller** pulisce stack
- Valore ritorno in **AX** (16-bit) o **DX:AX** (32-bit)
- Registri **AX, CX, DX** volatile (caller-save)
- Registri **BX, SI, DI, BP** non-volatile (callee-save)

**Esempio Chiamata C**:
```c
int sum(int a, int b);
// Chiamata: result = sum(3, 5);
```

**Assembly Equivalente (caller)**:
```assembly
; sum(3, 5)
    PUSH 5              ; Secondo parametro
    PUSH 3              ; Primo parametro
    CALL sum
    ADD SP, 4           ; Pulisce stack (2 param × 2 byte)
    ; AX = risultato
```

**Assembly Funzione (callee)**:
```assembly
sum PROC
    PUSH BP
    MOV BP, SP          ; Setup stack frame
    
    ; Parametri:
    ; [BP+4] = a (primo)
    ; [BP+6] = b (secondo)
    
    MOV AX, [BP+4]      ; AX = a
    ADD AX, [BP+6]      ; AX += b
    
    POP BP
    RET                 ; AX = risultato
sum ENDP
```

**Stack Layout**:
```
    ┌──────────┐
    │ b (5)    │ ← [BP+6]
    ├──────────┤
    │ a (3)    │ ← [BP+4]
    ├──────────┤
    │ ret addr │ ← [BP+2]
    ├──────────┤
    │ old BP   │ ← [BP], SP (dopo MOV BP,SP)
    └──────────┘
```

### 2. Pascal Calling Convention

**Usata da Turbo Pascal, OS/2**.

**Caratteristiche**:
- Parametri passati **sinistra → destra**
- **Callee** pulisce stack
- Più efficiente (meno codice caller)

**Esempio**:
```assembly
; Pascal: function sum(a, b: integer): integer;
sum PROC
    PUSH BP
    MOV BP, SP
    
    MOV AX, [BP+4]      ; a (primo)
    ADD AX, [BP+6]      ; b (secondo)
    
    POP BP
    RET 4               ; Pulisce 4 byte (2 parametri)
sum ENDP

; Chiamata:
    PUSH 3              ; a
    PUSH 5              ; b
    CALL sum
    ; Stack già pulito da RET 4
```

### 3. fastcall (Non Standard 16-bit)

**Primi parametri in registri**, resto su stack.

**Varianti**:
- Watcom: **AX, DX, BX, CX**
- Borland: **AX, DX, CX**

**Esempio Watcom**:
```assembly
; fastcall sum(a, b): a in AX, b in DX
sum PROC
    ADD AX, DX          ; AX = a + b
    RET
sum ENDP

; Chiamata:
    MOV AX, 3           ; a
    MOV DX, 5           ; b
    CALL sum
    ; AX = risultato
```

## Scrivere Funzioni Assembly per C

### Skeleton Funzione

```assembly
.MODEL SMALL
.CODE

PUBLIC _myfunc          ; Nome con underscore _ (cdecl)

_myfunc PROC
    PUSH BP
    MOV BP, SP
    ; Salva registri non-volatili se usati
    PUSH BX
    PUSH SI
    PUSH DI
    
    ; Corpo funzione
    ; Parametri: [BP+4], [BP+6], [BP+8], ...
    
    ; Valore ritorno in AX (o DX:AX)
    
    ; Ripristina registri
    POP DI
    POP SI
    POP BX
    POP BP
    RET
_myfunc ENDP

END
```

**Compilazione**:
```bash
# MASM
masm myfunc.asm;
# TASM
tasm myfunc.asm

# Link con C
tcc myprogram.c myfunc.obj
```

### Esempio 1: Funzione Somma

**sum.asm**:
```assembly
.MODEL SMALL
.CODE

PUBLIC _sum

; int sum(int a, int b)
_sum PROC
    PUSH BP
    MOV BP, SP
    
    MOV AX, [BP+4]      ; a
    ADD AX, [BP+6]      ; b
    ; AX = risultato
    
    POP BP
    RET
_sum ENDP

END
```

**main.c**:
```c
#include <stdio.h>

extern int sum(int a, int b);

int main(void) {
    int result = sum(10, 20);
    printf("10 + 20 = %d\n", result);
    return 0;
}
```

### Esempio 2: Funzione con Array

**strlen_asm.asm**:
```assembly
.MODEL SMALL
.CODE

PUBLIC _strlen_asm

; int strlen_asm(const char *str)
_strlen_asm PROC
    PUSH BP
    MOV BP, SP
    PUSH SI
    
    MOV SI, [BP+4]      ; SI = str
    XOR AX, AX          ; AX = length = 0
    
strlen_loop:
    CMP BYTE PTR [SI], 0
    JE strlen_done
    INC SI
    INC AX
    JMP strlen_loop
    
strlen_done:
    POP SI
    POP BP
    RET
_strlen_asm ENDP

END
```

**test.c**:
```c
#include <stdio.h>

extern int strlen_asm(const char *str);

int main(void) {
    char *msg = "Hello, Assembly!";
    printf("Length: %d\n", strlen_asm(msg));
    return 0;
}
```

### Esempio 3: Ritorno 32-bit

**multiply_long.asm**:
```assembly
.MODEL SMALL
.CODE

PUBLIC _mul32

; long mul32(int a, int b)
; Ritorna DX:AX
_mul32 PROC
    PUSH BP
    MOV BP, SP
    
    MOV AX, [BP+4]      ; a
    IMUL WORD PTR [BP+6] ; DX:AX = a × b (signed)
    ; DX:AX = risultato
    
    POP BP
    RET
_mul32 ENDP

END
```

**test.c**:
```c
#include <stdio.h>

extern long mul32(int a, int b);

int main(void) {
    long result = mul32(1000, 2000);
    printf("1000 * 2000 = %ld\n", result);
    return 0;
}
```

## Chiamare Funzioni C da Assembly

### Esempio 1: printf

**asm_printf.asm**:
```assembly
.MODEL SMALL
.STACK 100h

EXTRN _printf:NEAR      ; Dichiarazione esterna

.DATA
    fmt DB 'Hello from Assembly! %d', 10, 0
    value DW 42

.CODE
main PROC
    MOV AX, @DATA
    MOV DS, AX
    
    ; printf(fmt, value) - cdecl
    PUSH value
    LEA AX, fmt
    PUSH AX
    CALL _printf
    ADD SP, 4           ; Pulisce stack
    
    MOV AH, 4Ch
    INT 21h
main ENDP
END main
```

**Compilazione**:
```bash
tasm asm_printf.asm
tlink /Tdc asm_printf.obj, asm_printf.exe, , c:\tc\lib\cs.lib
```

### Esempio 2: malloc/free

```assembly
.MODEL SMALL
.STACK 100h

EXTRN _malloc:NEAR
EXTRN _free:NEAR

.DATA
    ptr DW ?

.CODE
main PROC
    MOV AX, @DATA
    MOV DS, AX
    
    ; malloc(100)
    PUSH 100
    CALL _malloc
    ADD SP, 2
    ; AX = pointer
    
    MOV ptr, AX
    OR AX, AX           ; NULL check
    JZ alloc_failed
    
    ; Usa memoria...
    
    ; free(ptr)
    PUSH ptr
    CALL _free
    ADD SP, 2
    
alloc_failed:
    MOV AH, 4Ch
    INT 21h
main ENDP
END main
```

### Esempio 3: fopen/fread/fclose

```assembly
.MODEL SMALL
.STACK 100h

EXTRN _fopen:NEAR
EXTRN _fread:NEAR
EXTRN _fclose:NEAR

.DATA
    filename DB 'data.bin', 0
    mode DB 'rb', 0
    buffer DB 512 DUP(?)
    file_ptr DW ?

.CODE
main PROC
    MOV AX, @DATA
    MOV DS, AX
    
    ; fopen(filename, mode)
    LEA AX, mode
    PUSH AX
    LEA AX, filename
    PUSH AX
    CALL _fopen
    ADD SP, 4
    
    MOV file_ptr, AX
    OR AX, AX
    JZ file_error
    
    ; fread(buffer, 1, 512, file_ptr)
    PUSH file_ptr
    PUSH 512
    PUSH 1
    LEA AX, buffer
    PUSH AX
    CALL _fread
    ADD SP, 8
    ; AX = byte letti
    
    ; fclose(file_ptr)
    PUSH file_ptr
    CALL _fclose
    ADD SP, 2
    
file_error:
    MOV AH, 4Ch
    INT 21h
main ENDP
END main
```

## Inline Assembly in C

### Turbo C / Borland C

```c
#include <stdio.h>

int add_asm(int a, int b) {
    int result;
    
    asm {
        MOV AX, a
        ADD AX, b
        MOV result, AX
    }
    
    return result;
}

void beep(void) {
    asm {
        MOV AH, 02h
        MOV DL, 07h     ; BEL character
        INT 21h
    }
}

int main(void) {
    printf("Result: %d\n", add_asm(10, 20));
    beep();
    return 0;
}
```

### Microsoft C

```c
void reverse_string(char *str) {
    _asm {
        MOV SI, str
        MOV DI, SI
        
        ; Trova fine stringa
    find_end:
        CMP BYTE PTR [DI], 0
        JE found_end
        INC DI
        JMP find_end
        
    found_end:
        DEC DI
        
        ; Inverti
    reverse_loop:
        CMP SI, DI
        JGE reverse_done
        
        MOV AL, [SI]
        MOV BL, [DI]
        MOV [SI], BL
        MOV [DI], AL
        
        INC SI
        DEC DI
        JMP reverse_loop
        
    reverse_done:
    }
}
```

## Strutture Dati Condivise

### Struct in C e Assembly

**data.h**:
```c
typedef struct {
    int x;
    int y;
    char name[20];
} Point;
```

**point_asm.asm**:
```assembly
.MODEL SMALL
.CODE

PUBLIC _point_distance

; Struttura Point: offset layout
; +0: x (int, 2 byte)
; +2: y (int, 2 byte)
; +4: name (char[20], 20 byte)
; Totale: 22 byte

; int point_distance(Point *p1, Point *p2)
_point_distance PROC
    PUSH BP
    MOV BP, SP
    PUSH SI
    PUSH DI
    
    MOV SI, [BP+4]      ; p1
    MOV DI, [BP+6]      ; p2
    
    ; dx = p2->x - p1->x
    MOV AX, [DI+0]      ; p2->x
    SUB AX, [SI+0]      ; - p1->x
    IMUL AX             ; AX = dx²
    MOV BX, AX
    
    ; dy = p2->y - p1->y
    MOV AX, [DI+2]      ; p2->y
    SUB AX, [SI+2]      ; - p1->y
    IMUL AX             ; AX = dy²
    
    ADD AX, BX          ; AX = dx² + dy²
    ; (Semplificato: ritorna distanza²)
    
    POP DI
    POP SI
    POP BP
    RET
_point_distance ENDP

END
```

## Gestione Errori

### Errno in C

```assembly
.MODEL SMALL
.CODE

EXTRN __errno:NEAR      ; Indirizzo variabile errno

PUBLIC _divide_safe

; int divide_safe(int a, int b, int *result)
; Ritorna 0 se ok, -1 se errore (divisione per 0)
_divide_safe PROC
    PUSH BP
    MOV BP, SP
    PUSH BX
    
    MOV AX, [BP+4]      ; a
    MOV BX, [BP+6]      ; b
    OR BX, BX
    JZ div_by_zero
    
    CWD                 ; Estendi segno AX → DX:AX
    IDIV BX             ; AX = a / b
    
    ; Salva risultato
    MOV BX, [BP+8]      ; result pointer
    MOV [BX], AX
    
    XOR AX, AX          ; Ritorna 0 (successo)
    JMP div_done
    
div_by_zero:
    ; errno = 33 (EDOM)
    CALL __errno        ; AX = &errno
    MOV BX, AX
    MOV WORD PTR [BX], 33
    
    MOV AX, -1          ; Ritorna -1 (errore)
    
div_done:
    POP BX
    POP BP
    RET
_divide_safe ENDP

END
```

**test.c**:
```c
#include <stdio.h>
#include <errno.h>

extern int divide_safe(int a, int b, int *result);

int main(void) {
    int result;
    
    if (divide_safe(10, 0, &result) == -1) {
        printf("Error: %d\n", errno);  // 33
    } else {
        printf("Result: %d\n", result);
    }
    
    return 0;
}
```

## Debugging Codice Misto

### Tecniche

1. **Symbol Files**: compilare con debug info (`-g` gcc, `/Zi` MSVC)
2. **Turbo Debugger (TD)**: step tra C e Assembly
3. **Printf Debugging**: output da Assembly
4. **Breakpoint**: `INT 3` in Assembly

### Esempio Debug

```assembly
_debug_func PROC
    PUSH BP
    MOV BP, SP
    
    INT 3               ; Breakpoint (se debugger attivo)
    
    ; Codice da debuggare
    MOV AX, [BP+4]
    
    ; Debug: stampa valore AX (via C)
    EXTRN _printf:NEAR
    PUSH AX
    PUSH OFFSET debug_fmt
    CALL _printf
    ADD SP, 4
    
    POP BP
    RET
_debug_func ENDP

.DATA
debug_fmt DB 'Debug: AX = %d', 10, 0
```

## Best Practices

### 1. Rispetta Convenzione Chiamata

```assembly
✓ Corretto (cdecl):
    PUSH param2
    PUSH param1
    CALL func
    ADD SP, 4           ; Caller pulisce

✗ Sbagliato:
    CALL func
    ; Stack non pulito! Crash o corruzione
```

### 2. Salva Registri Non-Volatili

```assembly
✓ Completo:
myfunc PROC
    PUSH BP
    PUSH BX
    PUSH SI
    ; ... usa BX, SI ...
    POP SI
    POP BX
    POP BP
    RET
myfunc ENDP

✗ Dimenticato:
    ; Usa BX senza salvare
    MOV BX, 100
    RET                 ; BX caller corrotto!
```

### 3. Prefisso _ per cdecl

```assembly
✓ Nome C:
PUBLIC _myfunc          ; int myfunc(...)

✗ Senza _:
PUBLIC myfunc           ; Linker non trova!
```

### 4. Valida Parametri

```assembly
_strcpy_safe PROC
    PUSH BP
    MOV BP, SP
    PUSH SI
    PUSH DI
    
    ; Valida puntatori non NULL
    MOV DI, [BP+4]      ; dest
    OR DI, DI
    JZ invalid_param
    
    MOV SI, [BP+6]      ; src
    OR SI, SI
    JZ invalid_param
    
    ; Copia...
    
invalid_param:
    POP DI
    POP SI
    POP BP
    RET
_strcpy_safe ENDP
```

## Esercizi Pratici

1. Scrivi funzione Assembly `memcpy(dest, src, count)` chiamabile da C
2. Implementa `strcmp` in Assembly, testa da C
3. Crea funzione C che chiama Assembly per calcolo CRC16
4. Scrivi Assembly che usa `fopen`/`fread`/`fclose` da libreria C
5. Implementa quicksort in Assembly con interfaccia C

### Soluzione Esercizio 1

**memcpy.asm**:
```assembly
.MODEL SMALL
.CODE

PUBLIC _memcpy_asm

; void* memcpy_asm(void *dest, const void *src, unsigned int count)
_memcpy_asm PROC
    PUSH BP
    MOV BP, SP
    PUSH SI
    PUSH DI
    PUSH DS
    PUSH ES
    
    ; Setup segmenti
    MOV AX, DS
    MOV ES, AX
    
    MOV DI, [BP+4]      ; dest
    MOV SI, [BP+6]      ; src
    MOV CX, [BP+8]      ; count
    
    ; Copia
    CLD
    REP MOVSB
    
    ; Ritorna dest
    MOV AX, [BP+4]
    
    POP ES
    POP DS
    POP DI
    POP SI
    POP BP
    RET
_memcpy_asm ENDP

END
```

---

**Prossimo argomento:** [Ottimizzazione Codice Assembly](modulo7_02_ottimizzazione.md)
