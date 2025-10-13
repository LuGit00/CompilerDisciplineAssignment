; scopes: global, function, struct



%macro function 1-*
	%ifnctx global
		%fatal
	%endif

	%push %??
	%assign %$stack.variables.count 0
	%assign %$stack.total 0
	%assign %$frame.base %[%rsp]
	%1:
	section .text
%endmacro

%macro execute 1-*
	%ifnctx function
		%fatal
	%endif

	lea rax, %%return_address
    mov [rbp+rsp], rax
    add rsp, 8
    jmp %1
%%return_address:
%endmacro

%macro return 0
	%ifnctx function
		%fatal
	%endif

	sub rsp, 8
    mov rax, [rbp+rsp]
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
			%xdefine %1 [rsp - %$stack.variables.count]
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
	mov qword [%1], rax
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
	mov rcx, %1
	cqo
	idiv rcx
%endmacro
%macro if_less_than 1
	cmp rax, %1
%endmacro
%macro if_more_than 1
	cmp rax, %1
%endmacro
%macro if_less_or_equal_than 1
	cmp rax, %1
%endmacro
%macro if_more_or_equal_than 1
	cmp rax, %1
%endmacro
%macro if_equals 1
	cmp rax, %1
%endmacro
%macro if_not_equals 1
	cmp rax, %1
%endmacro

%macro if 0
	%push function
%endmacro
%macro then 0
	%pop
	%push function
%endmacro
%macro else 0
	%pop
	%push function
%endmacro

%macro end 0
	%ifctx function
	%elifctx struct
		endstruc
	%else
		%fatal
	%endif
	%pop
%endmacro

%macro asm 1-*
	%rep %0
		%1
		%rotate 1
	%endrep
%endmacro

%push global