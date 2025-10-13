%push global
section .bss
vstack: resb 16*1024*1024
section .text
lea rbp,[rel vstack]
xor rsp,rsp

%macro function 1-*
	%ifnctx global
		%fatal
	%endif
	%push %??
	%assign %$stack.variables.count 0
	%assign %$stack.total 0
	%1:
	mov r12,rsp
	section .text
%endmacro

%macro execute 1-*
	%ifnctx function
		%fatal
	%endif
	lea rax,[rel %%ret%=]
	%assign __argc %0-1
	%if __argc > 0
		%assign __i 2
		%rep __argc
			mov rdx,%[%__i]
			mov [rbp+rsp],rdx
			add rsp,8
			%assign __i __i+1
		%endrep
	%endif
	mov [rbp+rsp],r12
	add rsp,8
	mov [rbp+rsp],rax
	add rsp,8
	%if __argc > 0
		lea rsi,[rbp+rsp-16-8*__argc]
		mov rdi,__argc
	%else
		lea rsi,[rbp+rsp-16]
		xor rdi,rdi
	%endif
	jmp %1
%%ret%=:
%endmacro


%macro return 0
	%ifnctx function
		%fatal
	%endif
	sub rsp,8
	mov rax, [rbp+rsp]
	sub rsp,8
	mov r12,[rbp+rsp]
	jmp rax
%endmacro

%macro label 1-*
	%ifnctx function
		%fatal
	%endif
	%rep %0
		%1:
		%rotate 1
	%endrep
%endmacro

%macro goto 1
	%ifnctx function
		%fatal
	%endif
	jmp %1
%endmacro

%macro immediate 1
	%ifnctx function
		%fatal
	%endif
	mov rax, %1
%endmacro

%macro var 2-*
	%assign size %1
	%rotate 1
	%ifctx global
		%rep %0 - 1
			section .bss
			%1: resb %[size]
			%rotate 1
		%endrep
	%elifctx function
		%rep %0 - 1
			%assign %$stack.variables.count %$stack.variables.count + %[size]
			%xdefine %1 [rbp+r12+%$stack.variables.count-%[size]]
			%rotate 1
		%endrep
	%elifctx struct
		%rep %0 - 1
			.%1 resb %[size]
			%rotate 1
		%endrep
	%else
		%fatal
	%endif
	%undef size
%endmacro

%macro struct 1
	%push %??
	struc %1
%endmacro

%macro assign 1
	mov qword %1, rax
%endmacro

%macro add 1
	add rax, %1
%endmacro
%macro subtract 1
	sub rax, %1
%endmacro
%macro multiply 1
	imul rax, %1
%endmacro
%macro divide 1
	mov rcx,%1
	cqo
	idiv rcx
%endmacro

%macro if_less_than 1
	cmp rax, %1
	setl al
	movzx rax, al
%endmacro
%macro if_more_than 1
	cmp rax, %1
	setg al
	movzx rax, al
%endmacro
%macro if_less_or_equal_than 1
	cmp rax, %1
	setle al
	movzx rax, al
%endmacro
%macro if_more_or_equal_than 1
	cmp rax, %1
	setge al
	movzx rax, al
%endmacro
%macro if_equals 1
	cmp rax, %1
	sete al
	movzx rax, al
%endmacro
%macro if_not_equals 1
	cmp rax, %1
	setne al
	movzx rax, al
%endmacro

%macro if 0
	%ifndef %$ifseq
		%assign %$ifseq 0
	%endif
	%assign %$ifseq %$ifseq+1
	%xdefine %$if_else .if_else%$ifseq
	%xdefine %$if_end  .if_end%$ifseq
	test rax, rax
	jz %$if_else
	%push function
%endmacro

%macro else 0
	%pop
	jmp %$if_end
%$if_else:
	%push function
%endmacro

%macro end 0
	%ifctx struct
		endstruc
	%endif
%$if_end:
	%pop
%endmacro

%macro asm 1-*
	%rep %0
		%1
		%rotate 1
	%endrep
%endmacro
