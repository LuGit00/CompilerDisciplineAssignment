; assemble: nasm -f elf64 sectdemo.asm -o sectdemo.o
; link: ld sectdemo.o -o sectdemo

global _start

section .text.start progbits alloc exec
_start:
    mov rdi,msg
    mov rsi,msglen
    call print
    mov rax,60
    xor rdi,rdi
    syscall

section .text.utils progbits alloc exec
print:
    mov rax,1
    mov rdx,rsi
    mov rsi,rdi
    mov rdi,1
    syscall
    ret

section .rodata.msg progbits alloc
msg: db "Hello from custom section",10
msglen: equ $-msg
