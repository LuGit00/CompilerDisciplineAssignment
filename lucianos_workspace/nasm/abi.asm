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

%macro system.registers.saved_callee.initialize 1-*
	%assign system.registers.saved_callee.count %0
	%assign counter 0
	%rep %0
		%xdefine system.registers.saved_callee.%[counter] %1
		%rotate 1
		%assign counter %[counter] + 1
	%endrep
%endmacro
system.registers.saved_callee.initialize rbx, rbp, r12, r13, r14, r15


%push global
%xdefine %$section
%assign %$depth 0
%assign %$variables.count 0
%assign %$structs.count 0
%assign %$functions.count 0

%macro register 0

	%ifctx global
		%fatal
	%elifctx struct
		%fatal
	%elifctx function
	%else
		%fatal
	%endif

	%ifdef %$storage_class
		%fatal	
	%endif

	%xdefine %$storage_class %??

%endmacro

%macro auto 0

	%ifctx global
		%fatal
	%elifctx struct
		%fatal
	%elifctx function
	%else
		%fatal
	%endif

	%ifdef %$storage_class
		%fatal	
	%endif

	%xdefine %$storage_class %??

%endmacro

%macro static 0

	%ifctx global
	%elifctx struct
	%elifctx function
	%else
		%fatal
	%endif

	%ifdef %$storage_class
		%fatal	
	%endif

	%xdefine %$storage_class %??

%endmacro

%macro void 0

	%ifctx global
	%elifctx struct
	%elifctx function
	%else
		%fatal
	%endif

	%ifdef %$type
		%fatal
	%endif

	%xdefine %$type %??

%endmacro

%macro uint8_t 0

	%ifctx global
	%elifctx struct
	%elifctx function
	%else
		%fatal
	%endif

	%ifdef %$type
		%fatal
	%endif

	%xdefine %$type %??

%endmacro

%macro uint16_t 0

	%ifctx global
	%elifctx struct
	%elifctx function
	%else
		%fatal
	%endif

	%ifdef %$type
		%fatal
	%endif

	%xdefine %$type %??

%endmacro

%macro uint32_t 0

	%ifctx global
	%elifctx struct
	%elifctx function
	%else
		%fatal
	%endif

	%ifdef %$type
		%fatal
	%endif

	%xdefine %$type %??

%endmacro

%macro uint64_t 0

	%ifctx global
	%elifctx struct
	%elifctx function
	%else
		%fatal
	%endif

	%ifdef %$type
		%fatal
	%endif

	%xdefine %$type %??

%endmacro

%macro int8_t 0

	%ifctx global
	%elifctx struct
	%elifctx function
	%else
		%fatal
	%endif

	%ifdef %$type
		%fatal
	%endif

	%xdefine %$type %??

%endmacro

%macro int16_t 0

	%ifctx global
	%elifctx struct
	%elifctx function
	%else
		%fatal
	%endif

	%ifdef %$type
		%fatal
	%endif

	%xdefine %$type %??

%endmacro

%macro int32_t 0

	%ifctx global
	%elifctx struct
	%elifctx function
	%else
		%fatal
	%endif

	%ifdef %$type
		%fatal
	%endif

	%xdefine %$type %??

%endmacro

%macro int64_t 0

	%ifctx global
	%elifctx struct
	%elifctx function
	%else
		%fatal
	%endif

	%ifdef %$type
		%fatal
	%endif

	%xdefine %$type %??

%endmacro

%macro var 1-*

	%ifctx global
	%elifctx struct
	%elifctx function
	%else
		%fatal
	%endif

	%ifndef %$storage_class
		%xdefine %$storage_class auto
	%endif
	%ifndef %$type
		%xdefine %$type int32_t
	%endif

	%ifidni %[%$storage_class], static
		section .bss
	%endif
	
	%rep %0

		%assign counter 0
		%rep %[%$variables.count]
			%if %[%$variables.%[counter].depth] == %[%$depth]
				%ifidni %[%$variables.%[counter].identifier], %1
					%fatal
				%endif
			%else
				%exitrep
			%endif
			%assign counter %[counter] + 1
		%endrep
		%ifidni %[%$storage_class], register
			%xdefine %$variables.%[%$variables.count].identifier %1
			%xdefine %$variables.%[%$variables.count].depth %[%$depth]
			%if %$
			%xdefine %$variables.%[%$variables.count].value
			%assign %$variables.count %[%$variables.count] + 1
		%elifidni %[%$storage_class], auto
			%xdefine %$variables.%[%$variables.count].identifier %1
			%xdefine %$variables.%[%$variables.count].depth %[%$depth]
			%xdefine %$variables.%[%$variables.count].value %2
			%assign %$variables.count %[%$variables.count] + 1
		%elifidni %[%$storage_class], static
			%xdefine %$variables.%[%$variables.count].identifier %1
			%xdefine %$variables.%[%$variables.count].depth %[%$depth]
			%xdefine %$variables.%[%$variables.count].value %2
			%assign %$variables.count %[%$variables.count] + 1
		%endif

		%rotate 1
	%endrep

	%undef %$storage_class
	%undef %$type

%endmacro

%macro struct 1-*

	%ifctx global
	%elifctx struct
	%elifctx function
	%else
		%fatal
	%endif

	%assign counter 0
	%rep %[%$structs.count]
		%if %[%$structs.%[counter].depth] == %[%$depth]
			%ifidni %[%$structs.%[counter].identifier], %1
				%fatal
			%endif
		%else
			%exitrep
		%endif
		%assign counter %[counter] + 1
	%endrep
	%xdefine %$structs.%[%$structs.count].identifier %1
	%xdefine %$structs.%[%$structs.count].depth %[%$depth]
	%assign %$structs.count %[%$structs.count] + 1
	%push %??
	%xdefine %$section %[%$$section]
	%assign %$depth %[%$$depth] + 1
	%xdefine %$storage_class auto
	%xdefine %$type int32_t
	%assign %$variables.count 0
	%rep %[%$$variables.count]
		%xdefine %$variables.%[%$variables.count].identifier %[%$$variables.%[%$variables.count].identifier]
		%xdefine %$variables.%[%$variables.count].depth %[%$$variables.%[%$variables.count].depth]
		%assign %$variables.count %[%$variables.count] + 1
	%endrep
	%assign %$structs.count 0
	%rep %[%$$structs.count]
		%xdefine %$structs.%[%$structs.count].identifier %[%$$structs.%[%$structs.count].identifier]
		%xdefine %$structs.%[%$structs.count].depth %[%$$structs.%[%$structs.count].depth]
		%assign %$structs.count %[%$structs.count] + 1
	%endrep
	%assign %$functions.count 0
	%rep %[%$$functions.count]
		%xdefine %$functions.%[%$functions.count].identifier %[%$$functions.%[%$functions.count].identifier]
		%xdefine %$functions.%[%$functions.count].depth %[%$$functions.%[%$functions.count].depth]
		%assign %$functions.count %[%$functions.count] + 1
	%endrep
	%xdefine %$access_modifier private

%endmacro

%macro private 0

	%ifctx global
		%fatal
	%elifctx struct
	%elifctx function
		%fatal
	%else
		%fatal
	%endif

	%xdefine %$access_modifier %??

%endmacro

%macro protected 0

	%ifctx global
		%fatal
	%elifctx struct
	%elifctx function
		%fatal
	%else
		%fatal
	%endif

	%xdefine %$access_modifier %??

%endmacro

%macro public 0

	%ifctx global
		%fatal
	%elifctx struct
	%elifctx function
		%fatal
	%else
		%fatal
	%endif

	%xdefine %$access_modifier %??

%endmacro

%macro function 1-*

	%ifctx global
	%elifctx struct
	%elifctx function
	%else
		%fatal
	%endif

	%assign counter 0
	%rep %[%$functions.count]
		%if %[%$functions.%[counter].depth] == %[%$depth]
			%ifidni %[%$functions.%[counter].identifier], %1
				%fatal
			%endif
		%else
			%exitrep
		%endif
		%assign counter %[counter] + 1
	%endrep
	%xdefine %$functions.%[%$functions.count].identifier %1
	%xdefine %$functions.%[%$functions.count].depth %[%$depth]
	%assign %$functions.count %[%$functions.count] + 1
	%push %??
	%xdefine %$section .text.%[%$$functions.count]
	%assign %$depth %[%$$depth] + 1
	%xdefine %$storage_class auto
	%xdefine %$type int32_t
	%assign %$variables.count 0
	%assign %$structs.count 0
	%assign %$functions.count 0
	%rep %[%$$variables.count]
		%xdefine %$variables.%[%$variables.count].identifier %[%$$variables.%[%$variables.count].identifier]
		%xdefine %$variables.%[%$variables.count].depth %[%$$variables.%[%$variables.count].depth]
		%assign %$variables.count %[%$variables.count] + 1
	%endrep
	%rep %[%$$structs.count]
		%xdefine %$structs.%[%$structs.count].identifier %[%$$structs.%[%$structs.count].identifier]
		%xdefine %$structs.%[%$structs.count].depth %[%$$structs.%[%$structs.count].depth]
		%assign %$structs.count %[%$structs.count] + 1
	%endrep
	%rep %[%$$functions.count]
		%xdefine %$functions.%[%$functions.count].identifier %[%$$functions.%[%$functions.count].identifier]
		%xdefine %$functions.%[%$functions.count].depth %[%$$functions.%[%$functions.count].depth]
		%assign %$functions.count %[%$functions.count] + 1
	%endrep

%endmacro

%macro execute 1-*

	%ifctx global
		%fatal
	%elifctx struct
		%fatal
	%elifctx function
	%else
		%fatal
	%endif

	%assign counter %[%$functions.count] - 1
	%rep %[%$functions.count]
		%ifidni %[%$functions.%[counter].identifier], %1
			%assign function_found %[counter]
			%exitrep
		%endif
		%assign counter %[counter] - 1
	%endrep
	%ifndef function_found
		%fatal
	%endif
	


%endmacro

%macro return 0

	%ifctx global
		%fatal
	%elifctx struct
		%fatal
	%elifctx function
	%else
		%fatal
	%endif

%endmacro

%macro label 1-*

	%ifctx global
		%fatal
	%elifctx struct
		%fatal
	%elifctx function
	%else
		%fatal
	%endif

%endmacro

%macro goto 1

	%ifctx global
		%fatal
	%elifctx struct
		%fatal
	%elifctx function
	%else
		%fatal
	%endif

%endmacro

%macro block 0

	%ifctx global
		%fatal
	%elifctx struct
		%fatal
	%elifctx function
	%else
		%fatal
	%endif

%endmacro

%macro if 0

	%ifctx global
		%fatal
	%elifctx struct
		%fatal
	%elifctx function
	%else
		%fatal
	%endif

%endmacro

%macro then 0

	%ifctx global
		%fatal
	%elifctx struct
		%fatal
	%elifctx function
	%else
		%fatal
	%endif

%endmacro

%macro else 0

	%ifctx global
		%fatal
	%elifctx struct
		%fatal
	%elifctx function
	%else
		%fatal
	%endif

%endmacro

%macro immediate 1

	%ifctx global
	%elifctx struct
		%fatal
	%elifctx function
	%else
		%fatal
	%endif

	%ifnum %1
		mov rax, %1
	%elifstr %1
		section .rodata
		%%address: db %1, 0
		section %[%$section]
		mov rax, %%address
	%elifid %1
	%else
		%fatal
	%endif

%endmacro

%macro assign 0
%endmacro
%macro add 0
%endmacro
%macro subtract 0
%endmacro
%macro multiply 0
%endmacro
%macro divide 0
%endmacro
%macro module 0
%endmacro
%macro bit_shift_left 0
%endmacro
%macro bit_shift_right 0
%endmacro
%macro not 0
%endmacro
%macro or 0
%endmacro
%macro and 0
%endmacro
%macro with 0
%endmacro
%macro sizeof 1
%endmacro
%macro asm 1-*
%endmacro

%macro end 0-*
%endmacro




