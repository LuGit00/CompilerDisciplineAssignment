%push global
section .bss
vstack: resb 16*1024*1024
section .text
lea rbp,[rel vstack]
xor rsp,rsp

<<<<<<< Updated upstream
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
    LEA RAX,[REL %%RET%=]
    %assign __argc %0-1
    %if __argc > 0
        %assign __i 2
        %rep __argc
            MOV RDX,%[%__i]
            MOV [RBP+RSP],RDX
            ADD RSP,8
            %assign __i __i+1
        %endrep
    %endif
    MOV [RBP+RSP],R12
    ADD RSP,8
    MOV [RBP+RSP],RAX
    ADD RSP,8
    %if __argc > 0
        LEA RSI,[RBP+RSP-16-8*__argc]
        MOV RDI,__argc
    %else
        LEA RSI,[RBP+RSP-16]
        XOR RDI,RDI
    %endif
    JMP %1
%%RET%=:
%endmacro




%macro return 0
    %ifnctx function
        %fatal
    %endif
    SUB RSP,8
    MOV RAX,[RBP+RSP]
    SUB RSP,8
    MOV R12,[RBP+RSP]
    JMP RAX
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
	%1
%endmacro
=======
%macro include 1-*
%endmacro

%macro struct 1
%endmacro

%macro namespace 1
%endmacro

%macro public 0
%endmacro

%macro protected 0
%endmacro

%macro private 0
%endmacro

%macro function 1-*
%endmacro

%macro execute 1-*
%endmacro

%macro return 1
%endmacro

%macro label 1-*
%endmacro

%macro goto 1
%endmacro

%macro block 0
%endmacro

%macro var 1-*
%endmacro

%macro end 0
%endmacro

%elifndef pass.1
%xdefine pass.1
>>>>>>> Stashed changes



