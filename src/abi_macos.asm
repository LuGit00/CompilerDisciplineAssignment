; abi_macos.asm - Adapted for macOS
; Includes the ABI macros and provides a macOS entry point

%include "src/abi.asm"

; Define a simple main function using the ABI macros to test
function main
    ; Return 0
    return
    end

section .text
    global _start

_start:
    ; Entry point
    execute main
    
    ; Exit syscall (macOS)
    ; syscall number 0x2000001 (exit)
    mov rax, 0x2000001 
    mov rdi, 0         ; status 0
    syscall
