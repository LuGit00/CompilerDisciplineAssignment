
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











%assign _scope.depth 0
%macro _scope.open 1
	%push %1
	%xdefine %$access_modifier private
	%xdefine %$storage_class auto
	%xdefine %$type void
	%assign %$variables.count 0
	%if %[_scope.depth] > 0
		%rep %[%$$variables.count]
			%xdefine %$variables.%[%$variables.count] %[%$$variables.%[%$variables.count]]
			%xdefine %$variables.%[%$variables.count].access_modifier %[%$$variables.%[%$variables.count].access_modifier]
			%xdefine %$variables.%[%$variables.count].storage_class %[%$$variables.%[%$variables.count].storage_class]
			%xdefine %$variables.%[%$variables.count].type %[%$$variables.%[%$variables.count].type]
			%assign %$variables.count %[%$variables.count] + 1
		%endrep
	%endif
	%assign %$labels.count 0
	%if %[_scope.depth] > 0
		%rep %[%$$labels.count]
			%xdefine %$labels.%[%$labels.count] %[%$$labels.%[%$labels.count]]
			%assign %$labels.count %[%$labels.count] + 1
		%endrep
	%endif
	%assign _scope.depth %[_scope.depth] + 1
%endmacro
%macro _scope.close 0
	%assign _scope.depth %[_scope.depth] - 1
	%rep %[%$labels.count]
		%undef %$labels.%[%$labels.count]
		%assign %$labels.count %[%$labels.count] - 1
	%endrep
	%undef %$labels.count
	%rep %[%$variables.count]
		%undef %$variables.%[%$variables.count].type
		%undef %$variables.%[%$variables.count].storage_class
		%undef %$variables.%[%$variables.count].access_modifier
		%undef %$variables.%[%$variables.count]
		%assign %$variables.count %[%$variables.count] - 1
	%endrep
	%undef %$variables.count
	%undef %$type
	%undef %$storage_class
	%undef %$access_modifier
	%pop
%endmacro

_scope.open global







%macro private 0
	%xdefine %$access_modifier %??
%endmacro

%macro protected 0
	%xdefine %$access_modifier %??
%endmacro

%macro public 0
	%xdefine %$access_modifier %??
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

%macro void 0
	%xdefine %$type %??
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

%macro var 1-*
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

	%xdefine %$access_modifier private
	%xdefine %$storage_class auto
	%xdefine %$type void

%endmacro

%macro struct 1-*
	_scope.open %??
	struc %1
%endmacro

%macro function 1-*
	_scope.open %??
	section .text.%1
	%1:
%endmacro

%macro end 0-*
	%ifctx global
		%fatal
	%elifctx struct
		%fatal
	%elifctx function
		%fatal
	%else
		%fatal
	%endif

	%xdefine %$access_modifier private
	%xdefine %$storage_class auto
	%xdefine %$type void

%endmacro



