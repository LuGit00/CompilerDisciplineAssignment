array buffer, 256
array flag, 8
array size, 8
struct Pair
array tmp, 2
end pair1, pair2
function sizecheck
assign_sizeof size, Pair
return
end
function exit0
asm "mov rax, 60"
asm "mov rdi, 0"
asm "syscall"
end
function puts
asm "mov rax, 1"
asm "mov rdi, 1"
asm "mov rsi, hello_msg"
asm "mov rdx, hello_len"
asm "syscall"
return
end
function putcA
asm "mov rax, 1"
asm "mov rdi, 1"
asm "mov rsi, char_A"
asm "mov rdx, 1"
asm "syscall"
return
end
function main
assign_if_less_than flag, 1, 2
execute sizecheck
execute puts
execute putcA
execute exit0
end

