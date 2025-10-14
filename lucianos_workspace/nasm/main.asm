%include "abi.asm"

; globals
var 8, heap_next
var 4096, heap

function main
    var 8, head
    immediate 0
    assign head
    execute push, head, 1
    execute push, head, 2
    execute push, head, 3
    asm mov rax,60
    asm xor rdi,rdi
    asm syscall
end

function alloc
    var 8, p, base, next
    immediate heap
    assign base
    immediate heap_next
    assign next
    immediate base
    add next
    assign p
    immediate p
    asm mov rax,[rax]
    return
end

function push
    var 8, hdr, val, node, tmp
    immediate rsi
    assign hdr
    immediate [rsi+8]
    assign val
    execute alloc
    asm mov [node],rax
    immediate hdr
    asm mov rdx,rax
    asm mov rdx,[rdx]
    immediate node
    asm mov rax,rax
    asm mov [rax],rdx
    immediate val
    asm mov rdx,rax
    immediate node
    add 8
    asm mov rax,rax
    asm mov [rax],rdx
    immediate hdr
    asm mov rcx,rax
    immediate node
    asm mov rax,rax
    asm mov [rcx],rax
    return
end

function print
    var 8, hdr, cur, ch
    immediate rsi
    assign hdr
    immediate hdr
    asm mov rdx,rax
    asm mov rdx,[rdx]
    asm mov [cur],rdx
label loop
    asm mov rax,[cur]
    if_equals 0
    if
        goto done
    end
    asm mov rax,[cur]
    add 8
    asm mov rax,[rax]
    add 48
    assign ch
    immediate ch
    asm mov rsi,rax
    asm mov rax,1
    asm mov rdi,1
    asm mov rdx,1
    asm syscall
    asm mov rax,[cur]
    asm mov rax,[rax]
    asm mov [cur],rax
    goto loop
label done
    return
end
