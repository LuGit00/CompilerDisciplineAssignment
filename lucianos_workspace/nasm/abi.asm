
; Initialize argument register list
%macro system.registers.arguments.initialize 1-*
	%assign system.registers.arguments.count %0
	%assign counter 0
	%rep %0
		%xdefine system.registers.arguments.%[counter] %1
		%rotate 1
		%assign counter %[counter] + 1
	%endrep
	%undef counter
%endmacro
system.registers.arguments.initialize rdi, rsi, rdx, rcx, r8, r9
%undef system.registers.arguments.initialize

; Initialize saved-callee register list
%macro system.registers.saved_callee.initialize 1-*
	%assign system.registers.saved_callee.count %0
	%assign counter 0
	%rep %0
		%xdefine system.registers.saved_callee.%[counter] %1
		%rotate 1
		%assign counter %[counter] + 1
	%endrep
	%undef counter
%endmacro
system.registers.saved_callee.initialize rbx, rbp, r12, r13, r14, r15
%undef system.registers.saved_callee.initialize


; Initialize global scope
%push global
%xdefine %$storage_class undefined
%xdefine %$type undefined

%macro struct 1-*
	%push %??
	%xdefine %$storage_class undefined
	%xdefine %$type undefined
%endmacro

%macro function 1-*
	%push %??
	%xdefine %$storage_class undefined
	%xdefine %$type undefined
%endmacro

%macro register 0
	%xdefine %$storage_class %??
%endmacro

%macro auto 0
	%xdefine %$storage_class %??
%endmacro

%macro static 0
	%xdefine %$storage_class %??
%endmacro

%macro uint8_t 0
	%xdefine %$type %??
%endmacro

%macro uint16_t 0
	%xdefine %$type %??
%endmacro

%macro uint32_t 0
	%xdefine %$type %??
%endmacro

%macro uint64_t 0
	%xdefine %$type %??
%endmacro

%macro var 2-*
	%assign size %1
	%rotate 1
	%assign counter 0
	%rep %0 - 1

		; 27 block conditions, 3x3x3:scopesXstorageXtype
		; use %ifctx and %ifdef accordingly.
		; fill where it makes sense to you, as much as C as possible
		; leave %fatal where it should not work
		; The symbol table are the macro themselves, which can be defined

		%rotate 1
		%assign counter %[counter] + 1
	%endrep
	%undef counter
	%undef size

	; Reset symbol table buffers
	%xdefine %$storage_class undefined
	%xdefine %$type undefined

%endmacro




