%macro system.registers.arguments.initialize 1-*
	%assign system.registers.arguments.count %0
	%assign counter 0
	%rep %0
		%xdefine system.registers.arguments.%[counter] %1
		%rotate 1
		%assign counter %[counter] + 1
	%endrep
%endmacro
system.registers.arguments.initialize rdi, rsi, rdx, rcx, r8, r9

;scopes: global, function, block, struct

%macro register 0
	%ifctx global
		%fatal
	%elifctx function
	%elifctx block
	%elifctx struct
		%fatal
	%else
		%fatal
	%endif
	%ifdef %$storage_class
		%fatal
	%endif
	%xdefine %$storage_class
	%xdefine %$storage_class.identifier %??
%endmacro
%macro auto 0
	%ifctx global
		%fatal
	%elifctx function
	%elifctx block
	%elifctx struct
		%fatal
	%else
		%fatal
	%endif
	%ifdef %$storage_class
		%fatal
	%endif
	%xdefine %$storage_class
	%xdefine %$storage_class.identifier %??
%endmacro
%macro static 0
	%ifctx global
	%elifctx function
	%elifctx block
	%elifctx struct
		%fatal
	%else
		%fatal
	%endif

	%ifdef %$storage_class
		%fatal
	%endif
	%xdefine %$storage_class
	%xdefine %$storage_class.identifier %??
%endmacro

%macro var 1
	%ifctx global
	%elifctx function
	%elifctx block
	%elifctx struct
	%else
		%fatal
	%endif
	array 1, %1
%endmacro

%macro array 2
	%ifctx global
	%elifctx function
	%elifctx block
	%elifctx struct
	%else
		%fatal
	%endif
	%assign counter 0
	%rep %[%$variables.count]
		%ifidni %[%$variables.%[counter].identifier], %2
			%fatal
		%endif
		%assign counter %[counter] + 1
	%endrep
	%xdefine %$variables.%[%$variables.count]
	%xdefine %$variables.%[%$variables.count].identifier %2
	%ifidni %[%$storage_class], register
		%if %[%$variables.callee_saved_register.count] == 0
			%xdefine %$variables.%[%$variables.count].value rbx
			section .text.%[%$functions.%[%$functions.count].id]
		%elif %[%$variables.callee_saved_register.count] == 1
			%xdefine %$variables.%[%$variables.count].value r12
			section .text.%[%$functions.%[%$functions.count].id]
		%elif %[%$variables.callee_saved_register.count] == 2
			%xdefine %$variables.%[%$variables.count].value r13
			section .text.%[%$functions.%[%$functions.count].id]
		%elif %[%$variables.callee_saved_register.count] == 3
			%xdefine %$variables.%[%$variables.count].value r14
			section .text.%[%$functions.%[%$functions.count].id]
		%elif %[%$variables.callee_saved_register.count] == 4
			%xdefine %$variables.%[%$variables.count].value r15
		%else
			%fatal
		%endif
		section .text.%[%$functions.%[%$functions.count].id]
		push %[%$variables.%[%$variables.count].value]
		%assign %$variables.callee_saved_register.count %[%$variables.callee_saved_register.count] + 1
	%elifidni %[%$storage_class], auto
		%xdefine %$variables.%[%$variables.count].identifier %2
		%assign %$variables.auto.offset %[%$variables.auto.offset] + (8 * %1)
		section .text.%[%$functions.%[%$functions.count].id]
		sub rsp, 8 * %1
		%xdefine %$variables.%[%$variables.count].value qword [rbp-%[%$variables.auto.offset]]
	%elifidni %[%$storage_class], static
		section .bss
		%%address: resq %1
		%xdefine %$variables.%[%$variables.count].value qword [%%address]
	%else
		%fatal
	%endif
	%assign %$variables.count %[%$variables.count] + 1
	%undef %$storage_class
%endmacro

%macro label 1
	%ifctx global
		%fatal
	%elifctx function
	%elifctx block
	%elifctx struct
		%fatal
	%else
		%fatal
	%endif
	%assign counter 0
	%rep %[%$labels.count]
		%ifidni %[%$labels.%[counter].identifier], %1
			%fatal
		%endif
		%assign counter %[counter] + 1
	%endrep
	%xdefine %$labels.%[%$labels.count]
	%xdefine %$labels.%[%$labels.count].identifier %1
	section .text.%[%$functions.%[%$functions.count].id]
	%1:
	%xdefine %$labels.%[%$labels.count].value %[%1]
	%assign %$labels.count %[%$labels.count] + 1
%endmacro
%macro goto 1
	%ifctx global
		%fatal
	%elifctx function
	%elifctx block
	%elifctx struct
		%fatal
	%else
		%fatal
	%endif
	%undef if_found
	%assign counter 0
	%rep %[%$labels.count]
		%ifidni %[%$labels.%[counter].identifier], %1
			%xdefine if_found
			%exitrep
		%endif
		%assign counter %[counter] + 1
	%endrep
	%ifndef if_found
		%fatal
	%endif
	section .text.%[%$functions.%[%$functions.count].id]
	jmp %[%$labels.%[counter].value]
%endmacro

%macro block 0
	%ifctx global
		%fatal
	%elifctx function
	%elifctx block
	%elifctx struct
		%fatal
	%else
		%fatal
	%endif
	%push %??
	section .text.%[%$functions.%[%$functions.count].id]
	push rbp
	mov rbp, rsp
	%assign %$functions.count 0
	%rep %[%$$functions.count]
		%xdefine %$functions.%[%$functions.count].identifier %[%$$functions.%[%$functions.count].identifier]
		%xdefine %$functions.%[%$functions.count].value      %[%$$functions.%[%$functions.count].value]
		%xdefine %$functions.%[%$functions.count].id         %[%$$functions.%[%$functions.count].id]
		%assign %$functions.count %[%$functions.count] + 1
	%endrep
	%assign %$variables.count 0
	%rep %[%$$variables.count]
		%xdefine %$variables.%[%$variables.count].identifier %[%$$variables.%[%$variables.count].identifier]
		%xdefine %$variables.%[%$variables.count].value      %[%$$variables.%[%$variables.count].value]
		%assign %$variables.count %[%$variables.count] + 1
	%endrep
	%assign %$variables.callee_saved_register.count %[%$$variables.callee_saved_register.count]
	%assign %$variables.auto.offset %[%$$variables.auto.offset]
	%assign %$labels.count 0
	%rep %[%$$labels.count]
		%xdefine %$labels.%[%$labels.count].identifier %[%$$labels.%[%$labels.count].identifier]
		%xdefine %$labels.%[%$labels.count].value      %[%$$labels.%[%$labels.count].value]
		%assign %$labels.count %[%$labels.count] + 1
	%endrep
	%assign %$callee_saved.entry %[%$variables.callee_saved_register.count]
%endmacro

%macro if 1
	%ifctx global
		%fatal
	%elifctx function
	%elifctx block
	%elifctx struct
		%fatal
	%else
		%fatal
	%endif
	block
	section .text.%[%$functions.%[%$functions.count].id]
	cmp %1, 0
	jz %$if_not
%endmacro
%macro elif 1
	%ifctx global
		%fatal
	%elifctx function
	%elifctx block
	%elifctx struct
		%fatal
	%else
		%fatal
	%endif
	%$if_not:
	end
	block
	section .text.%[%$functions.%[%$functions.count].id]
	test %1, %1
	jnz %$if_not
%endmacro
%macro else 0
	%ifctx global
		%fatal
	%elifctx function
	%elifctx block
	%elifctx struct
		%fatal
	%else
		%fatal
	%endif
	%$if_not:
	end
	block
%endmacro

%macro assign 2
	%ifctx global
		%fatal
	%elifctx function
	%elifctx block
	%elifctx struct
		%fatal
	%else
		%fatal
	%endif
	%ifnum %1
		%fatal
	%elifstr %1
		%fatal
	%elifid %1
		%undef if_found
		%assign counter 0
		%rep %[%$variables.count]
			%ifidni %[%$variables.%[counter].identifier], %1
				%xdefine if_found
				%exitrep
			%endif
			%assign counter %[counter] + 1
		%endrep
		%ifndef if_found
			%fatal
		%endif
		%xdefine destination %[%$variables.%[counter].value]
	%else
		%fatal
	%endif
	%ifnum %2
		section .text.%[%$functions.%[%$functions.count].id]
		mov %[destination], %2
	%elifstr %2
		section .rodata
		%%address: db %2, 0
		section .text.%[%$functions.%[%$functions.count].id]
		lea rax, [rel %%address]
		mov %[destination], rax
	%elifid %2
		%undef if_found
		%assign counter 0
		%rep %[%$variables.count]
			%ifidni %[%$variables.%[counter].identifier], %2
				%xdefine if_found
				%exitrep
			%endif
			%assign counter %[counter] + 1
		%endrep
		%ifndef if_found
			%fatal
		%endif
		section .text.%[%$functions.%[%$functions.count].id]
		mov %[destination], %[%$variables.%[counter].value]
	%else
		%fatal
	%endif
%endmacro
%macro add 3
	%ifctx global
		%fatal
	%elifctx function
	%elifctx block
	%elifctx struct
		%fatal
	%else
		%fatal
	%endif
	%ifnum %1
		%fatal
	%elifstr %1
		%fatal
	%elifid %1
		%undef if_found
		%assign counter 0
		%rep %[%$variables.count]
			%ifidni %[%$variables.%[counter].identifier], %1
				%xdefine if_found
				%exitrep
			%endif
			%assign counter %[counter] + 1
		%endrep
		%ifndef if_found
			%fatal
		%endif
		%xdefine destination %[%$variables.%[counter].value]
	%else
		%fatal
	%endif
	%ifnum %2
		section .text.%[%$functions.%[%$functions.count].id]
		mov %[destination], %2
	%elifstr %2
		section .rodata
		%%address_add: db %2, 0
		section .text.%[%$functions.%[%$functions.count].id]
		lea rax, [rel %%address_add]
		mov %[destination], rax
	%elifid %2
		%undef if_found
		%assign counter 0
		%rep %[%$variables.count]
			%ifidni %[%$variables.%[counter].identifier], %2
				%xdefine if_found
				%exitrep
			%endif
			%assign counter %[counter] + 1
		%endrep
		%ifndef if_found
			%fatal
		%endif
		section .text.%[%$functions.%[%$functions.count].id]
		mov %[destination], %[%$variables.%[counter].value]
	%else
		%fatal
	%endif
	%ifnum %3
		section .text.%[%$functions.%[%$functions.count].id]
		add %[destination], %3
	%elifstr %3
		%fatal
	%elifid %3
		%undef if_found
		%assign counter 0
		%rep %[%$variables.count]
			%ifidni %[%$variables.%[counter].identifier], %3
				%xdefine if_found
				%exitrep
			%endif
			%assign counter %[counter] + 1
		%endrep
		%ifndef if_found
			%fatal
		%endif
		section .text.%[%$functions.%[%$functions.count].id]
		add %[destination], %[%$variables.%[counter].value]
	%else
		%fatal
	%endif
%endmacro
%macro subtract 3
	%ifctx global
		%fatal
	%elifctx function
	%elifctx block
	%elifctx struct
		%fatal
	%else
		%fatal
	%endif
	%ifnum %1
		%fatal
	%elifstr %1
		%fatal
	%elifid %1
		%undef if_found
		%assign counter 0
		%rep %[%$variables.count]
			%ifidni %[%$variables.%[counter].identifier], %1
				%xdefine if_found
				%exitrep
			%endif
			%assign counter %[counter] + 1
		%endrep
		%ifndef if_found
			%fatal
		%endif
		%xdefine destination %[%$variables.%[counter].value]
	%else
		%fatal
	%endif
	%ifnum %2
		section .text.%[%$functions.%[%$functions.count].id]
		mov %[destination], %2
	%elifstr %2
		section .rodata
		%%address_sub: db %2, 0
		section .text.%[%$functions.%[%$functions.count].id]
		lea rax, [rel %%address_sub]
		mov %[destination], rax
	%elifid %2
		%undef if_found
		%assign counter 0
		%rep %[%$variables.count]
			%ifidni %[%$variables.%[counter].identifier], %2
				%xdefine if_found
				%exitrep
			%endif
			%assign counter %[counter] + 1
		%endrep
		%ifndef if_found
			%fatal
		%endif
		section .text.%[%$functions.%[%$functions.count].id]
		mov %[destination], %[%$variables.%[counter].value]
	%else
		%fatal
	%endif
	%ifnum %3
		section .text.%[%$functions.%[%$functions.count].id]
		sub %[destination], %3
	%elifstr %3
		%fatal
	%elifid %3
		%undef if_found
		%assign counter 0
		%rep %[%$variables.count]
			%ifidni %[%$variables.%[counter].identifier], %3
				%xdefine if_found
				%exitrep
			%endif
			%assign counter %[counter] + 1
		%endrep
		%ifndef if_found
			%fatal
		%endif
		section .text.%[%$functions.%[%$functions.count].id]
		sub %[destination], %[%$variables.%[counter].value]
	%else
		%fatal
	%endif
%endmacro
%macro multiply 3
	%ifctx global
		%fatal
	%elifctx function
	%elifctx block
	%elifctx struct
		%fatal
	%else
		%fatal
	%endif
	%ifnum %1
		%fatal
	%elifstr %1
		%fatal
	%elifid %1
		%undef if_found
		%assign counter 0
		%rep %[%$variables.count]
			%ifidni %[%$variables.%[counter].identifier], %1
				%xdefine if_found
				%exitrep
			%endif
			%assign counter %[counter] + 1
		%endrep
		%ifndef if_found
			%fatal
		%endif
		%xdefine destination %[%$variables.%[counter].value]
	%else
		%fatal
	%endif
	%ifnum %2
		section .text.%[%$functions.%[%$functions.count].id]
		mov %[destination], %2
	%elifstr %2
		section .rodata
		%%address_mul: db %2, 0
		section .text.%[%$functions.%[%$functions.count].id]
		lea rax, [rel %%address_mul]
		mov %[destination], rax
	%elifid %2
		%undef if_found
		%assign counter 0
		%rep %[%$variables.count]
			%ifidni %[%$variables.%[counter].identifier], %2
				%xdefine if_found
				%exitrep
			%endif
			%assign counter %[counter] + 1
		%endrep
		%ifndef if_found
			%fatal
		%endif
		section .text.%[%$functions.%[%$functions.count].id]
		mov %[destination], %[%$variables.%[counter].value]
	%else
		%fatal
	%endif
	%ifnum %3
		section .text.%[%$functions.%[%$functions.count].id]
		mov rax, %[destination]
		imul rax, %3
		mov %[destination], rax
	%elifstr %3
		%fatal
	%elifid %3
		%undef if_found
		%assign counter 0
		%rep %[%$variables.count]
			%ifidni %[%$variables.%[counter].identifier], %3
				%xdefine if_found
				%exitrep
			%endif
			%assign counter %[counter] + 1
		%endrep
		%ifndef if_found
			%fatal
		%endif
		section .text.%[%$functions.%[%$functions.count].id]
		mov rax, %[destination]
		imul rax, %[%$variables.%[counter].value]
		mov %[destination], rax
	%else
		%fatal
	%endif
%endmacro

%macro divide 3
	%ifctx global
		%fatal
	%elifctx function
	%elifctx block
	%elifctx struct
		%fatal
	%else
		%fatal
	%endif
	%ifnum %1
		%fatal
	%elifstr %1
		%fatal
	%elifid %1
		%undef if_found
		%assign counter 0
		%rep %[%$variables.count]
			%ifidni %[%$variables.%[counter].identifier], %1
				%xdefine if_found
				%exitrep
			%endif
			%assign counter %[counter] + 1
		%endrep
		%ifndef if_found
			%fatal
		%endif
		%xdefine destination %[%$variables.%[counter].value]
	%else
		%fatal
	%endif
	%ifnum %2
		section .text.%[%$functions.%[%$functions.count].id]
		mov %[destination], %2
	%elifstr %2
		section .rodata
		%%address_div: db %2, 0
		section .text.%[%$functions.%[%$functions.count].id]
		lea rax, [rel %%address_div]
		mov %[destination], rax
	%elifid %2
		%undef if_found
		%assign counter 0
		%rep %[%$variables.count]
			%ifidni %[%$variables.%[counter].identifier], %2
				%xdefine if_found
				%exitrep
			%endif
			%assign counter %[counter] + 1
		%endrep
		%ifndef if_found
			%fatal
		%endif
		section .text.%[%$functions.%[%$functions.count].id]
		mov %[destination], %[%$variables.%[counter].value]
	%else
		%fatal
	%endif
	%ifnum %3
		section .text.%[%$functions.%[%$functions.count].id]
		mov rax, %[destination]
		cqo
		mov rcx, %3
		idiv rcx
		mov %[destination], rax
	%elifstr %3
		%fatal
	%elifid %3
		%undef if_found
		%assign counter 0
		%rep %[%$variables.count]
			%ifidni %[%$variables.%[counter].identifier], %3
				%xdefine if_found
				%exitrep
			%endif
			%assign counter %[counter] + 1
		%endrep
		%ifndef if_found
			%fatal
		%endif
		section .text.%[%$functions.%[%$functions.count].id]
		mov rax, %[destination]
		cqo
		mov rcx, %[%$variables.%[counter].value]
		idiv rcx
		mov %[destination], rax
	%else
		%fatal
	%endif
%endmacro
%macro modulo 3
	%ifctx global
		%fatal
	%elifctx function
	%elifctx block
	%elifctx struct
		%fatal
	%else
		%fatal
	%endif
	%ifnum %1
		%fatal
	%elifstr %1
		%fatal
	%elifid %1
		%undef if_found
		%assign counter 0
		%rep %[%$variables.count]
			%ifidni %[%$variables.%[counter].identifier], %1
				%xdefine if_found
				%exitrep
			%endif
			%assign counter %[counter] + 1
		%endrep
		%ifndef if_found
			%fatal
		%endif
		%xdefine destination %[%$variables.%[counter].value]
	%else
		%fatal
	%endif
	%ifnum %2
		section .text.%[%$functions.%[%$functions.count].id]
		mov %[destination], %2
	%elifstr %2
		section .rodata
		%%address_mod: db %2, 0
		section .text.%[%$functions.%[%$functions.count].id]
		lea rax, [rel %%address_mod]
		mov %[destination], rax
	%elifid %2
		%undef if_found
		%assign counter 0
		%rep %[%$variables.count]
			%ifidni %[%$variables.%[counter].identifier], %2
				%xdefine if_found
				%exitrep
			%endif
			%assign counter %[counter] + 1
		%endrep
		%ifndef if_found
			%fatal
		%endif
		section .text.%[%$functions.%[%$functions.count].id]
		mov %[destination], %[%$variables.%[counter].value]
	%else
		%fatal
	%endif
	%ifnum %3
		section .text.%[%$functions.%[%$functions.count].id]
		mov rax, %[destination]
		cqo
		mov rcx, %3
		idiv rcx
		mov %[destination], rdx
	%elifstr %3
		%fatal
	%elifid %3
		%undef if_found
		%assign counter 0
		%rep %[%$variables.count]
			%ifidni %[%$variables.%[counter].identifier], %3
				%xdefine if_found
				%exitrep
			%endif
			%assign counter %[counter] + 1
		%endrep
		%ifndef if_found
			%fatal
		%endif
		section .text.%[%$functions.%[%$functions.count].id]
		mov rax, %[destination]
		cqo
		mov rcx, %[%$variables.%[counter].value]
		idiv rcx
		mov %[destination], rdx
	%else
		%fatal
	%endif
%endmacro
%macro bit_shift_left 3
	%ifctx global
		%fatal
	%elifctx function
	%elifctx block
	%elifctx struct
		%fatal
	%else
		%fatal
	%endif
	%ifnum %1
		%fatal
	%elifstr %1
		%fatal
	%elifid %1
		%undef if_found
		%assign counter 0
		%rep %[%$variables.count]
			%ifidni %[%$variables.%[counter].identifier], %1
				%xdefine if_found
				%exitrep
			%endif
			%assign counter %[counter] + 1
		%endrep
		%ifndef if_found
			%fatal
		%endif
		%xdefine destination %[%$variables.%[counter].value]
	%else
		%fatal
	%endif
	%ifnum %2
		section .text.%[%$functions.%[%$functions.count].id]
		mov %[destination], %2
	%elifstr %2
		section .rodata
		%%address_shl: db %2, 0
		section .text.%[%$functions.%[%$functions.count].id]
		lea rax, [rel %%address_shl]
		mov %[destination], rax
	%elifid %2
		%undef if_found
		%assign counter 0
		%rep %[%$variables.count]
			%ifidni %[%$variables.%[counter].identifier], %2
				%xdefine if_found
				%exitrep
			%endif
			%assign counter %[counter] + 1
		%endrep
		%ifndef if_found
			%fatal
		%endif
		section .text.%[%$functions.%[%$functions.count].id]
		mov %[destination], %[%$variables.%[counter].value]
	%else
		%fatal
	%endif
	%ifnum %3
		section .text.%[%$functions.%[%$functions.count].id]
		shl %[destination], %3
	%elifstr %3
		%fatal
	%elifid %3
		%undef if_found
		%assign counter 0
		%rep %[%$variables.count]
			%ifidni %[%$variables.%[counter].identifier], %3
				%xdefine if_found
				%exitrep
			%endif
			%assign counter %[counter] + 1
		%endrep
		%ifndef if_found
			%fatal
		%endif
		section .text.%[%$functions.%[%$functions.count].id]
		mov rcx, %[%$variables.%[counter].value]
		shl %[destination], cl
	%else
		%fatal
	%endif
%endmacro
%macro bit_shift_right 3
	%ifctx global
		%fatal
	%elifctx function
	%elifctx block
	%elifctx struct
		%fatal
	%else
		%fatal
	%endif
	%ifnum %1
		%fatal
	%elifstr %1
		%fatal
	%elifid %1
		%undef if_found
		%assign counter 0
		%rep %[%$variables.count]
			%ifidni %[%$variables.%[counter].identifier], %1
				%xdefine if_found
				%exitrep
			%endif
			%assign counter %[counter] + 1
		%endrep
		%ifndef if_found
			%fatal
		%endif
		%xdefine destination %[%$variables.%[counter].value]
	%else
		%fatal
	%endif
	%ifnum %2
		section .text.%[%$functions.%[%$functions.count].id]
		mov %[destination], %2
	%elifstr %2
		section .rodata
		%%address_shr: db %2, 0
		section .text.%[%$functions.%[%$functions.count].id]
		lea rax, [rel %%address_shr]
		mov %[destination], rax
	%elifid %2
		%undef if_found
		%assign counter 0
		%rep %[%$variables.count]
			%ifidni %[%$variables.%[counter].identifier], %2
				%xdefine if_found
				%exitrep
			%endif
			%assign counter %[counter] + 1
		%endrep
		%ifndef if_found
			%fatal
		%endif
		section .text.%[%$functions.%[%$functions.count].id]
		mov %[destination], %[%$variables.%[counter].value]
	%else
		%fatal
	%endif
	%ifnum %3
		section .text.%[%$functions.%[%$functions.count].id]
		shr %[destination], %3
	%elifstr %3
		%fatal
	%elifid %3
		%undef if_found
		%assign counter 0
		%rep %[%$variables.count]
			%ifidni %[%$variables.%[counter].identifier], %3
				%xdefine if_found
				%exitrep
			%endif
			%assign counter %[counter] + 1
		%endrep
		%ifndef if_found
			%fatal
		%endif
		section .text.%[%$functions.%[%$functions.count].id]
		mov rcx, %[%$variables.%[counter].value]
		shr %[destination], cl
	%else
		%fatal
	%endif
%endmacro
%macro not 2
	%ifctx global
		%fatal
	%elifctx function
	%elifctx block
	%elifctx struct
		%fatal
	%else
		%fatal
	%endif
	%ifnum %1
		%fatal
	%elifstr %1
		%fatal
	%elifid %1
		%undef if_found
		%assign counter 0
		%rep %[%$variables.count]
			%ifidni %[%$variables.%[counter].identifier], %1
				%xdefine if_found
				%exitrep
			%endif
			%assign counter %[counter] + 1
		%endrep
		%ifndef if_found
			%fatal
		%endif
		%xdefine destination %[%$variables.%[counter].value]
	%else
		%fatal
	%endif
	%ifnum %2
		section .text.%[%$functions.%[%$functions.count].id]
		neg %[destination]
	%elifstr %2
		%fatal
	%elifid %2
		section .text.%[%$functions.%[%$functions.count].id]
		not %[destination]
	%else
		%fatal
	%endif
%endmacro
%macro or 3
	%ifctx global
		%fatal
	%elifctx function
	%elifctx block
	%elifctx struct
		%fatal
	%else
		%fatal
	%endif
	%ifnum %1
		%fatal
	%elifstr %1
		%fatal
	%elifid %1
		%undef if_found
		%assign counter 0
		%rep %[%$variables.count]
			%ifidni %[%$variables.%[counter].identifier], %1
				%xdefine if_found
				%exitrep
			%endif
			%assign counter %[counter] + 1
		%endrep
		%ifndef if_found
			%fatal
		%endif
		%xdefine destination %[%$variables.%[counter].value]
	%else
		%fatal
	%endif

	%ifnum %2
		section .text.%[%$functions.%[%$functions.count].id]
		mov %[destination], %2
	%elifstr %2
		section .rodata
		%%address_or: db %2, 0
		section .text.%[%$functions.%[%$functions.count].id]
		lea rax, [rel %%address_or]
		mov %[destination], rax
	%elifid %2
		%undef if_found
		%assign counter 0
		%rep %[%$variables.count]
			%ifidni %[%$variables.%[counter].identifier], %2
				%xdefine if_found
				%exitrep
			%endif
			%assign counter %[counter] + 1
		%endrep
		%ifndef if_found
			%fatal
		%endif
		section .text.%[%$functions.%[%$functions.count].id]
		mov %[destination], %[%$variables.%[counter].value]
	%else
		%fatal
	%endif

	%ifnum %3
		section .text.%[%$functions.%[%$functions.count].id]
		or %[destination], %3
	%elifstr %3
		%fatal
	%elifid %3
		%undef if_found
		%assign counter 0
		%rep %[%$variables.count]
			%ifidni %[%$variables.%[counter].identifier], %3
				%xdefine if_found
				%exitrep
			%endif
			%assign counter %[counter] + 1
		%endrep
		%ifndef if_found
			%fatal
		%endif
		section .text.%[%$functions.%[%$functions.count].id]
		or %[destination], %[%$variables.%[counter].value]
	%else
		%fatal
	%endif
%endmacro
%macro and 3
	%ifctx global
		%fatal
	%elifctx function
	%elifctx block
	%elifctx struct
		%fatal
	%else
		%fatal
	%endif
	%ifnum %1
		%fatal
	%elifstr %1
		%fatal
	%elifid %1
		%undef if_found
		%assign counter 0
		%rep %[%$variables.count]
			%ifidni %[%$variables.%[counter].identifier], %1
				%xdefine if_found
				%exitrep
			%endif
			%assign counter %[counter] + 1
		%endrep
		%ifndef if_found
			%fatal
		%endif
		%xdefine destination %[%$variables.%[counter].value]
	%else
		%fatal
	%endif
	%ifnum %2
		section .text.%[%$functions.%[%$functions.count].id]
		mov %[destination], %2
	%elifstr %2
		section .rodata
		%%address_and: db %2, 0
		section .text.%[%$functions.%[%$functions.count].id]
		lea rax, [rel %%address_and]
		mov %[destination], rax
	%elifid %2
		%undef if_found
		%assign counter 0
		%rep %[%$variables.count]
			%ifidni %[%$variables.%[counter].identifier], %2
				%xdefine if_found
				%exitrep
			%endif
			%assign counter %[counter] + 1
		%endrep
		%ifndef if_found
			%fatal
		%endif
		section .text.%[%$functions.%[%$functions.count].id]
		mov %[destination], %[%$variables.%[counter].value]
	%else
		%fatal
	%endif
	%ifnum %3
		section .text.%[%$functions.%[%$functions.count].id]
		and %[destination], %3
	%elifstr %3
		%fatal
	%elifid %3
		%undef if_found
		%assign counter 0
		%rep %[%$variables.count]
			%ifidni %[%$variables.%[counter].identifier], %3
				%xdefine if_found
				%exitrep
			%endif
			%assign counter %[counter] + 1
		%endrep
		%ifndef if_found
			%fatal
		%endif
		section .text.%[%$functions.%[%$functions.count].id]
		and %[destination], %[%$variables.%[counter].value]
	%else
		%fatal
	%endif
%endmacro
%macro xor 3
	%ifctx global
		%fatal
	%elifctx function
	%elifctx block
	%elifctx struct
		%fatal
	%else
		%fatal
	%endif
	%ifnum %1
		%fatal
	%elifstr %1
		%fatal
	%elifid %1
		%undef if_found
		%assign counter 0
		%rep %[%$variables.count]
			%ifidni %[%$variables.%[counter].identifier], %1
				%xdefine if_found
				%exitrep
			%endif
			%assign counter %[counter] + 1
		%endrep
		%ifndef if_found
			%fatal
		%endif
		%xdefine destination %[%$variables.%[counter].value]
	%else
		%fatal
	%endif
	%ifnum %2
		section .text.%[%$functions.%[%$functions.count].id]
		mov %[destination], %2
	%elifstr %2
		section .rodata
		%%address_xor: db %2, 0
		section .text.%[%$functions.%[%$functions.count].id]
		lea rax, [rel %%address_xor]
		mov %[destination], rax
	%elifid %2
		%undef if_found
		%assign counter 0
		%rep %[%$variables.count]
			%ifidni %[%$variables.%[counter].identifier], %2
				%xdefine if_found
				%exitrep
			%endif
			%assign counter %[counter] + 1
		%endrep
		%ifndef if_found
			%fatal
		%endif
		section .text.%[%$functions.%[%$functions.count].id]
		mov %[destination], %[%$variables.%[counter].value]
	%else
		%fatal
	%endif
	%ifnum %3
		section .text.%[%$functions.%[%$functions.count].id]
		xor %[destination], %3
	%elifstr %3
		%fatal
	%elifid %3
		%undef if_found
		%assign counter 0
		%rep %[%$variables.count]
			%ifidni %[%$variables.%[counter].identifier], %3
				%xdefine if_found
				%exitrep
			%endif
			%assign counter %[counter] + 1
		%endrep
		%ifndef if_found
			%fatal
		%endif
		section .text.%[%$functions.%[%$functions.count].id]
		xor %[destination], %[%$variables.%[counter].value]
	%else
		%fatal
	%endif
%endmacro
%macro if_less_than 3
	%ifctx global
		%fatal
	%elifctx function
	%elifctx block
	%elifctx struct
		%fatal
	%else
		%fatal
	%endif
	%ifnum %1
		%fatal
	%elifstr %1
		%fatal
	%elifid %1
		%undef if_found
		%assign counter 0
		%rep %[%$variables.count]
			%ifidni %[%$variables.%[counter].identifier], %1
				%xdefine if_found
				%exitrep
			%endif
			%assign counter %[counter] + 1
		%endrep
		%ifndef if_found
			%fatal
		%endif
		%xdefine destination %[%$variables.%[counter].value]
	%else
		%fatal
	%endif
	%ifnum %2
		section .text.%[%$functions.%[%$functions.count].id]
		mov %[destination], %2
	%elifstr %2
		section .rodata
		%%addr_lt_op2: db %2, 0
		section .text.%[%$functions.%[%$functions.count].id]
		lea rax, [rel %%addr_lt_op2]
		mov %[destination], rax
	%elifid %2
		%undef if_found2
		%assign counter 0
		%rep %[%$variables.count]
			%ifidni %[%$variables.%[counter].identifier], %2
				%xdefine if_found2
				%exitrep
			%endif
			%assign counter %[counter] + 1
		%endrep
		%ifndef if_found2
			%fatal
		%endif
		section .text.%[%$functions.%[%$functions.count].id]
		mov %[destination], %[%$variables.%[counter].value]
	%else
		%fatal
	%endif
	%ifnum %3
		section .text.%[%$functions.%[%$functions.count].id]
		cmp %[destination], %3
	%elifstr %3
		%fatal
	%elifid %3
		%undef if_found3
		%assign counter 0
		%rep %[%$variables.count]
			%ifidni %[%$variables.%[counter].identifier], %3
				%xdefine if_found3
				%exitrep
			%endif
			%assign counter %[counter] + 1
		%endrep
		%ifndef if_found3
			%fatal
		%endif
		section .text.%[%$functions.%[%$functions.count].id]
		cmp %[destination], %[%$variables.%[counter].value]
	%else
		%fatal
	%endif
	section .text.%[%$functions.%[%$functions.count].id]
	setl al
	movzx rax, al
	mov %[destination], rax
%endmacro
%macro if_more_than 3
	%ifctx global
		%fatal
	%elifctx function
	%elifctx block
	%elifctx struct
		%fatal
	%else
		%fatal
	%endif
	%ifnum %1
		%fatal
	%elifstr %1
		%fatal
	%elifid %1
		%undef if_found
		%assign counter 0
		%rep %[%$variables.count]
			%ifidni %[%$variables.%[counter].identifier], %1
				%xdefine if_found
				%exitrep
			%endif
			%assign counter %[counter] + 1
		%endrep
		%ifndef if_found
			%fatal
		%endif
		%xdefine destination %[%$variables.%[counter].value]
	%else
		%fatal
	%endif
	%ifnum %2
		section .text.%[%$functions.%[%$functions.count].id]
		mov %[destination], %2
	%elifstr %2
		section .rodata
		%%addr_gt_op2: db %2, 0
		section .text.%[%$functions.%[%$functions.count].id]
		lea rax, [rel %%addr_gt_op2]
		mov %[destination], rax
	%elifid %2
		%undef if_found2
		%assign counter 0
		%rep %[%$variables.count]
			%ifidni %[%$variables.%[counter].identifier], %2
				%xdefine if_found2
				%exitrep
			%endif
			%assign counter %[counter] + 1
		%endrep
		%ifndef if_found2
			%fatal
		%endif
		section .text.%[%$functions.%[%$functions.count].id]
		mov %[destination], %[%$variables.%[counter].value]
	%else
		%fatal
	%endif
	%ifnum %3
		section .text.%[%$functions.%[%$functions.count].id]
		cmp %[destination], %3
	%elifstr %3
		%fatal
	%elifid %3
		%undef if_found3
		%assign counter 0
		%rep %[%$variables.count]
			%ifidni %[%$variables.%[counter].identifier], %3
				%xdefine if_found3
				%exitrep
			%endif
			%assign counter %[counter] + 1
		%endrep
		%ifndef if_found3
			%fatal
		%endif
		section .text.%[%$functions.%[%$functions.count].id]
		cmp %[destination], %[%$variables.%[counter].value]
	%else
		%fatal
	%endif
	section .text.%[%$functions.%[%$functions.count].id]
	setg al
	movzx rax, al
	mov %[destination], rax
%endmacro
%macro if_less_or_equal_than 3
	%ifctx global
		%fatal
	%elifctx function
	%elifctx block
	%elifctx struct
		%fatal
	%else
		%fatal
	%endif
	%ifnum %1
		%fatal
	%elifstr %1
		%fatal
	%elifid %1
		%undef if_found
		%assign counter 0
		%rep %[%$variables.count]
			%ifidni %[%$variables.%[counter].identifier], %1
				%xdefine if_found
				%exitrep
			%endif
			%assign counter %[counter] + 1
		%endrep
		%ifndef if_found
			%fatal
		%endif
		%xdefine destination %[%$variables.%[counter].value]
	%else
		%fatal
	%endif
	%ifnum %2
		section .text.%[%$functions.%[%$functions.count].id]
		mov %[destination], %2
	%elifstr %2
		section .rodata
		%%addr_le_op2: db %2, 0
		section .text.%[%$functions.%[%$functions.count].id]
		lea rax, [rel %%addr_le_op2]
		mov %[destination], rax
	%elifid %2
		%undef if_found2
		%assign counter 0
		%rep %[%$variables.count]
			%ifidni %[%$variables.%[counter].identifier], %2
				%xdefine if_found2
				%exitrep
			%endif
			%assign counter %[counter] + 1
		%endrep
		%ifndef if_found2
			%fatal
		%endif
		section .text.%[%$functions.%[%$functions.count].id]
		mov %[destination], %[%$variables.%[counter].value]
	%else
		%fatal
	%endif
	%ifnum %3
		section .text.%[%$functions.%[%$functions.count].id]
		cmp %[destination], %3
	%elifstr %3
		%fatal
	%elifid %3
		%undef if_found3
		%assign counter 0
		%rep %[%$variables.count]
			%ifidni %[%$variables.%[counter].identifier], %3
				%xdefine if_found3
				%exitrep
			%endif
			%assign counter %[counter] + 1
		%endrep
		%ifndef if_found3
			%fatal
		%endif
		section .text.%[%$functions.%[%$functions.count].id]
		cmp %[destination], %[%$variables.%[counter].value]
	%else
		%fatal
	%endif
	section .text.%[%$functions.%[%$functions.count].id]
	setle al
	movzx rax, al
	mov %[destination], rax
%endmacro
%macro if_more_or_equal_than 3
	%ifctx global
		%fatal
	%elifctx function
	%elifctx block
	%elifctx struct
		%fatal
	%else
		%fatal
	%endif
	%ifnum %1
		%fatal
	%elifstr %1
		%fatal
	%elifid %1
		%undef if_found
		%assign counter 0
		%rep %[%$variables.count]
			%ifidni %[%$variables.%[counter].identifier], %1
				%xdefine if_found
				%exitrep
			%endif
			%assign counter %[counter] + 1
		%endrep
		%ifndef if_found
			%fatal
		%endif
		%xdefine destination %[%$variables.%[counter].value]
	%else
		%fatal
	%endif
	%ifnum %2
		section .text.%[%$functions.%[%$functions.count].id]
		mov %[destination], %2
	%elifstr %2
		section .rodata
		%%addr_ge_op2: db %2, 0
		section .text.%[%$functions.%[%$functions.count].id]
		lea rax, [rel %%addr_ge_op2]
		mov %[destination], rax
	%elifid %2
		%undef if_found2
		%assign counter 0
		%rep %[%$variables.count]
			%ifidni %[%$variables.%[counter].identifier], %2
				%xdefine if_found2
				%exitrep
			%endif
			%assign counter %[counter] + 1
		%endrep
		%ifndef if_found2
			%fatal
		%endif
		section .text.%[%$functions.%[%$functions.count].id]
		mov %[destination], %[%$variables.%[counter].value]
	%else
		%fatal
	%endif
	%ifnum %3
		section .text.%[%$functions.%[%$functions.count].id]
		cmp %[destination], %3
	%elifstr %3
		%fatal
	%elifid %3
		%undef if_found3
		%assign counter 0
		%rep %[%$variables.count]
			%ifidni %[%$variables.%[counter].identifier], %3
				%xdefine if_found3
				%exitrep
			%endif
			%assign counter %[counter] + 1
		%endrep
		%ifndef if_found3
			%fatal
		%endif
		section .text.%[%$functions.%[%$functions.count].id]
		cmp %[destination], %[%$variables.%[counter].value]
	%else
		%fatal
	%endif
	section .text.%[%$functions.%[%$functions.count].id]
	setge al
	movzx rax, al
	mov %[destination], rax
%endmacro
%macro if_equal 3
	%ifctx global
		%fatal
	%elifctx function
	%elifctx block
	%elifctx struct
		%fatal
	%else
		%fatal
	%endif
	%ifnum %1
		%fatal
	%elifstr %1
		%fatal
	%elifid %1
		%undef if_found
		%assign counter 0
		%rep %[%$variables.count]
			%ifidni %[%$variables.%[counter].identifier], %1
				%xdefine if_found
				%exitrep
			%endif
			%assign counter %[counter] + 1
		%endrep
		%ifndef if_found
			%fatal
		%endif
		%xdefine destination %[%$variables.%[counter].value]
	%else
		%fatal
	%endif
	%ifnum %2
		section .text.%[%$functions.%[%$functions.count].id]
		mov %[destination], %2
	%elifstr %2
		section .rodata
		%%addr_eq_op2: db %2, 0
		section .text.%[%$functions.%[%$functions.count].id]
		lea rax, [rel %%addr_eq_op2]
		mov %[destination], rax
	%elifid %2
		%undef if_found2
		%assign counter 0
		%rep %[%$variables.count]
			%ifidni %[%$variables.%[counter].identifier], %2
				%xdefine if_found2
				%exitrep
			%endif
			%assign counter %[counter] + 1
		%endrep
		%ifndef if_found2
			%fatal
		%endif
		section .text.%[%$functions.%[%$functions.count].id]
		mov %[destination], %[%$variables.%[counter].value]
	%else
		%fatal
	%endif
	%ifnum %3
		section .text.%[%$functions.%[%$functions.count].id]
		cmp %[destination], %3
	%elifstr %3
		%fatal
	%elifid %3
		%undef if_found3
		%assign counter 0
		%rep %[%$variables.count]
			%ifidni %[%$variables.%[counter].identifier], %3
				%xdefine if_found3
				%exitrep
			%endif
			%assign counter %[counter] + 1
		%endrep
		%ifndef if_found3
			%fatal
		%endif
		section .text.%[%$functions.%[%$functions.count].id]
		cmp %[destination], %[%$variables.%[counter].value]
	%else
		%fatal
	%endif
	section .text.%[%$functions.%[%$functions.count].id]
	sete al
	movzx rax, al
	mov %[destination], rax
%endmacro
%macro if_not_equal 3
	%ifctx global
		%fatal
	%elifctx function
	%elifctx block
	%elifctx struct
		%fatal
	%else
		%fatal
	%endif
	%ifnum %1
		%fatal
	%elifstr %1
		%fatal
	%elifid %1
		%undef if_found
		%assign counter 0
		%rep %[%$variables.count]
			%ifidni %[%$variables.%[counter].identifier], %1
				%xdefine if_found
				%exitrep
			%endif
			%assign counter %[counter] + 1
		%endrep
		%ifndef if_found
			%fatal
		%endif
		%xdefine destination %[%$variables.%[counter].value]
	%else
		%fatal
	%endif
	%ifnum %2
		section .text.%[%$functions.%[%$functions.count].id]
		mov %[destination], %2
	%elifstr %2
		section .rodata
		%%addr_ne_op2: db %2, 0
		section .text.%[%$functions.%[%$functions.count].id]
		lea rax, [rel %%addr_ne_op2]
		mov %[destination], rax
	%elifid %2
		%undef if_found2
		%assign counter 0
		%rep %[%$variables.count]
			%ifidni %[%$variables.%[counter].identifier], %2
				%xdefine if_found2
				%exitrep
			%endif
			%assign counter %[counter] + 1
		%endrep
		%ifndef if_found2
			%fatal
		%endif
		section .text.%[%$functions.%[%$functions.count].id]
		mov %[destination], %[%$variables.%[counter].value]
	%else
		%fatal
	%endif
	%ifnum %3
		section .text.%[%$functions.%[%$functions.count].id]
		cmp %[destination], %3
	%elifstr %3
		%fatal
	%elifid %3
		%undef if_found3
		%assign counter 0
		%rep %[%$variables.count]
			%ifidni %[%$variables.%[counter].identifier], %3
				%xdefine if_found3
				%exitrep
			%endif
			%assign counter %[counter] + 1
		%endrep
		%ifndef if_found3
			%fatal
		%endif
		section .text.%[%$functions.%[%$functions.count].id]
		cmp %[destination], %[%$variables.%[counter].value]
	%else
		%fatal
	%endif
	section .text.%[%$functions.%[%$functions.count].id]
	setne al
	movzx rax, al
	mov %[destination], rax
%endmacro

%macro function 1
	%ifctx global
	%elifctx function
	%elifctx block
	%elifctx struct
	%else
		%fatal
	%endif
	%ifndef functions.count
		%assign functions.count 0
	%endif
	section .text.%[functions.count]
	%ifctx global
		%ifndef %$storage_class
			global %1
		%endif
	%endif
	%1:
	push rbp
	mov rbp, rsp
	%xdefine %$functions.%[%$functions.count].identifier %1
	%xdefine %$functions.%[%$functions.count].value %[%1]
	%xdefine %$functions.%[%$functions.count].id %[functions.count]
	%assign %$functions.count %[%$functions.count] + 1
	%push %??
	%assign %$functions.count 0
	%rep %[%$$functions.count]
		%xdefine %$functions.%[%$functions.count].identifier %[%$$functions.%[%$functions.count].identifier]
		%xdefine %$functions.%[%$functions.count].value      %[%$$functions.%[%$functions.count].value]
		%xdefine %$functions.%[%$functions.count].id         %[%$$functions.%[%$functions.count].id]
		%assign %$functions.count %[%$functions.count] + 1
	%endrep
	%assign %$variables.count 0
	%rep %[%$$variables.count]
		%xdefine %$variables.%[%$variables.count].identifier %[%$$variables.%[%$variables.count].identifier]
		%xdefine %$variables.%[%$variables.count].value      %[%$$variables.%[%$variables.count].value]
		%assign %$variables.count %[%$variables.count] + 1
	%endrep
	%assign %$variables.callee_saved_register.count 0
	%assign %$variables.auto.offset %[%$$variables.auto.offset]
	%assign %$labels.count 0
	%assign %$callee_saved.entry %[%$variables.callee_saved_register.count]
	%assign functions.count %[functions.count] + 1
%endmacro

%macro sizeof 2
	%ifctx global
		%fatal
	%elifctx function
	%elifctx block
	%elifctx struct
		%fatal
	%else
		%fatal
	%endif
	%ifnum %1
		%fatal
	%elifstr %1
		%fatal
	%elifid %1
		%undef if_found
		%assign counter 0
		%rep %[%$variables.count]
			%ifidni %[%$variables.%[counter].identifier], %1
				%xdefine if_found
				%exitrep
			%endif
			%assign counter %[counter] + 1
		%endrep
		%ifndef if_found
			%fatal
		%endif
		%xdefine destination %[%$variables.%[counter].value]
	%else
		%fatal
	%endif
	section .text.%[%$functions.%[%$functions.count].id]
	mov %[destination], 8
%endmacro

%macro end 0
	%ifctx global
		%fatal
	%elifctx function
	%elifctx block
	%elifctx struct
	%else
		%fatal
	%endif
	%rep %[%$labels.count]
		%undef %$labels.%[%$labels.count].identifier
		%undef %$labels.%[%$labels.count].value
		%assign %$labels.count %[%$labels.count] - 1
	%endrep
	%undef %$labels.count
	%undef %$variables.auto.offset
	%rep %[%$variables.callee_saved_register.count] - %[%$callee_saved.entry]
		%assign %$variables.callee_saved_register.count %[%$variables.callee_saved_register.count] - 1
		%if %[%$variables.callee_saved_register.count] == 0
			section .text.%[%$functions.%[%$functions.count].id]
			pop rbx
		%elif %[%$variables.callee_saved_register.count] == 1
			section .text.%[%$functions.%[%$functions.count].id]
			pop r12
		%elif %[%$variables.callee_saved_register.count] == 2
			section .text.%[%$functions.%[%$functions.count].id]
			pop r13
		%elif %[%$variables.callee_saved_register.count] == 3
			section .text.%[%$functions.%[%$functions.count].id]
			pop r14
		%elif %[%$variables.callee_saved_register.count] == 4
			section .text.%[%$functions.%[%$functions.count].id]
			pop r15
		%else
			%fatal
		%endif
	%endrep
	%undef %$variables.callee_saved_register.count
	%rep %[%$variables.count]
		%undef %$variables.%[%$variables.count].identifier
		%undef %$variables.%[%$variables.count].value
		%assign %$variables.count %[%$variables.count] - 1
	%endrep
	%undef %$variables.count
	section .text.%[%$functions.%[%$functions.count].id]
	mov rsp, rbp
	pop rbp
	%rep %[%$functions.count]
		%undef %$functions.%[%$functions.count].id
		%undef %$functions.%[%$functions.count].value
		%undef %$functions.%[%$functions.count].identifier
		%assign %$functions.count %[%$functions.count] - 1
	%endrep
	%undef %$functions.count
	%pop
%endmacro

%push global
%assign %$variables.count 0
%assign %$variables.callee_saved_register.count 0
%assign %$variables.auto.offset 0
%assign %$labels.count 0
%assign %$functions.count 0