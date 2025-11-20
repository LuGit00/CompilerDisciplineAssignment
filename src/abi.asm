;scopes: global, struct, function, block
;function parameters: rdi, rsi, rdx, rcx, r8, r9

%macro _ASSERT_IF_NOT_IN_SCOPE 1-*
	%rep %0
		%ifctx %1
			%fatal
		%endif
		%rotate 1
	%endrep
%endmacro
%macro _IF_IN_SCOPE 1-*
	%undef if_found
	%rep %0
		%ifctx %1
			%xdefine if_found
			%exitrep
		%endif
		%rotate 1
	%endrep
	%ifdef if_found
%endmacro

%macro _ASSERT_IF_NOT_STATIC 0
	%ifdef %$if_static
		%fatal
	%endif
%endmacro
%macro _IF_STATIC 0
	%ifdef %$if_static
%endmacro
%macro _IF_STRUCT_STATIC 0
	%ifdef %$if_struct_static
%endmacro

%macro _ASSERT_IF_INTEGER 1
	%ifnnum %1
		%fatal
	%endif
%endmacro
%macro _IF_INTEGER 1
	%ifnum %1
%endmacro
%macro _ASSERT_IF_STRING 1
	%ifnstr %1
		%fatal
	%endif
%endmacro
%macro _IF_STRING 1
	%ifstr %1
%endmacro
%macro _ASSERT_IF_IDENTIFIER 1
	%ifnid %1
		%fatal
	%endif
%endmacro
%macro _IF_IDENTIFIER 1
	%ifid %1
%endmacro

%macro _ELSE 0
	%else
%endmacro
%macro _ENDIF 0
	%endif
%endmacro

%macro _FETCH_REPRESENTATION 3
	%undef if_found
	%assign buffer0 %[%$%1.count] - 1
	%rep %[%$%1.count]
		%ifidni %[%$%1.%[buffer0].identifier], %3
			%xdefine if_found
			%exitrep
		%endif
		%assign buffer0 %[buffer0] - 1
	%endrep
	%ifdef if_found
		%xdefine %2 %[%$%1.%[buffer0].representation]
	%else
		%fatal
	%endif
%endmacro
%macro _APPEND_SYMBOL 3-5
	_ASSERT_IF_IDENTIFIER %1
	_ASSERT_IF_IDENTIFIER %2
	%xdefine %$%1.%[%$%1.count].identifier %2
	%xdefine %$%1.%[%$%1.count].representation %3
	%if %0 > 3
		_ASSERT_IF_IDENTIFIER %4
		%xdefine %$%1.%[%$%1.count].access_modifier %4
		_ASSERT_IF_INTEGER %5
		%xdefine %$%1.%[%$%1.count].struct %5
	%endif
	%assign %$%1.count %[%$%1.count] + 1
%endmacro
%macro _COPY_SYMBOLS 1
	%ifidni %1, members
		%rep %[%$$%1.count]
			_APPEND_SYMBOL %1, %[%$$%1.%[%$%1.count].identifier], %[%$$%1.%[%$%1.count].representation], %[%$$members.%[%$members.count].access_modifier], %[%$$members.%[%$members.count].struct]
		%endrep
	%else
		%rep %[%$$%1.count]
			_APPEND_SYMBOL %1, %[%$$%1.%[%$%1.count].identifier], %[%$$%1.%[%$%1.count].representation]
		%endrep
	%endif
%endmacro

%macro _OPEN_SCOPE 3
	%push %1
	%assign %$arrays.count 0
	%assign %$structs.count 0
	%assign %$members.count 0
	%assign %$functions.count 0
	%assign %$base_pointer %2
	%assign %$labels.count 0
	%assign %$struct_id %3
	%xdefine %$access_modifier private
%endmacro
%macro _CLOSE_SCOPE 0
	%pop
%endmacro

_OPEN_SCOPE global, 0, 0

%macro static 0
	_ASSERT_IF_NOT_IN_SCOPE struct
	_ASSERT_IF_NOT_STATIC
	%xdefine %$if_static
%endmacro

%macro array 2
	_ASSERT_IF_IDENTIFIER %1
	_ASSERT_IF_INTEGER %2
	_IF_IN_SCOPE global
		section .bss
		%%address: resb %2
		_APPEND_SYMBOL arrays, %1, %[%%address]
		_IF_STATIC
			%undef %$if_static
			%xdefine %$if_struct_static
		_ELSE
			global %[%%address]
		_ENDIF
	_ENDIF
	_IF_IN_SCOPE struct
		_ASSERT_IF_NOT_STATIC
		_APPEND_SYMBOL members, %1, %[%$structs.%[%$structs.count].representation] + %2, %[%$access_modifier], %[%$struct_id]
	_ENDIF
	_IF_IN_SCOPE function, block
		_IF_STATIC
			%undef %$if_static
			%xdefine %$if_struct_static
			section .bss
			%%address: resb %2
			section %[%$section]
			_APPEND_SYMBOL arrays, %1, %[%%address]
		_ELSE
			%assign %$base_pointer %[%$base_pointer] + %2
			_APPEND_SYMBOL arrays, %1, [rsp-%[%$base_pointer]]
		_ENDIF
	_ENDIF
%endmacro

%macro struct 1-*
	_ASSERT_IF_IDENTIFIER %1
	; TODO
	_APPEND_SYMBOL structs, %1, 0
	_OPEN_SCOPE %??, %[%$$base_pointer], %[%$structs.count]
	_COPY_SYMBOLS arrays
	_COPY_SYMBOLS structs
	_COPY_SYMBOLS members
	_COPY_SYMBOLS functions
%endmacro
%macro public 0
	_ASSERT_IF_NOT_IN_SCOPE global, function, block
	_ASSERT_IF_NOT_STATIC
	%xdefine %$access_modifier %??
%endmacro
%macro protected 0
	_ASSERT_IF_NOT_IN_SCOPE global, function, block
	_ASSERT_IF_NOT_STATIC
	%xdefine %$access_modifier %??
%endmacro
%macro private 0
	_ASSERT_IF_NOT_IN_SCOPE global, function, block
	_ASSERT_IF_NOT_STATIC
	%xdefine %$access_modifier %??
%endmacro

%macro function 1-*
	_IF_IN_SCOPE global
		_IF_STATIC
			_ASSERT_IF_IDENTIFIER %1
			; TODO
			%xdefine %$section .text.%[%$functions.count]
			section %[%$section]
			%%address:
			_APPEND_SYMBOL functions, %1, %[%%address]
			push rbp
			mov rbp, rsp
			_OPEN_SCOPE %??, %[%$base_pointer], %[%$struct_id]
			_COPY_SYMBOLS arrays
			_COPY_SYMBOLS structs
			_COPY_SYMBOLS members
			_COPY_SYMBOLS functions
		_ELSE
			_ASSERT_IF_IDENTIFIER %1
			; TODO
			%xdefine %$section .text.%[%$functions.count]
			section %[%$section]
			%%address:
			_APPEND_SYMBOL functions, %1, %[%%address]
			push rbp
			mov rbp, rsp
			_OPEN_SCOPE %??, %[%$base_pointer], %[%$struct_id]
			_COPY_SYMBOLS arrays
			_COPY_SYMBOLS structs
			_COPY_SYMBOLS members
			_COPY_SYMBOLS functions
			global %[%%address]
		_ENDIF
	_ENDIF
	_IF_IN_SCOPE struct
		_ASSERT_IF_NOT_STATIC
		_ASSERT_IF_IDENTIFIER %1
		; TODO
		%xdefine %$section .text.%[%$functions.count]
		section %[%$section]
		%%address:
		_APPEND_SYMBOL functions, %1, %[%%address]
		_APPEND_SYMBOL members, %1, %[%%address], %[%$access_modifier], %[%$struct_id]
		push rbp
		mov rbp, rsp
		_OPEN_SCOPE %??, %[%$base_pointer], %[%$struct_id]
		_COPY_SYMBOLS arrays
		_COPY_SYMBOLS structs
		_COPY_SYMBOLS members
		_COPY_SYMBOLS functions
	_ENDIF
	_IF_IN_SCOPE function, block
		_ASSERT_IF_IDENTIFIER %1
		; TODO
		%xdefine %$section .text.%[%$functions.count]
		section %[%$section]
		%%address:
		_APPEND_SYMBOL functions, %1, %[%%address]
		_APPEND_SYMBOL members, %1, %[%%address], %[%$access_modifier], %[%$struct_id]
		push rbp
		mov rbp, rsp
		_OPEN_SCOPE %??, %[%$base_pointer], %[%$struct_id]
		_COPY_SYMBOLS arrays
		_COPY_SYMBOLS structs
		_COPY_SYMBOLS members
		_COPY_SYMBOLS functions
	_ENDIF
%endmacro

%macro execute 1-*
	_ASSERT_IF_NOT_IN_SCOPE global, struct
	_ASSERT_IF_NOT_STATIC
	_ASSERT_IF_IDENTIFIER %1
	%assign buffer0 %[%$functions.count] - 1
	%undef if_found
	%rep %[%$functions.count]
		%ifidni %[%$functions.%[buffer0].identifier], %1
			%xdefine if_found
			%exitrep
		%endif
		%assign buffer0 %[buffer0] - 1
	%endrep
	%ifdef if_found
		%rotate 1
		%assign buffer1 0
		%rep %0 - 1
			%if %[buffer1] == 0
				mov rdi, %1
			%elif %[buffer1] == 1
				mov rsi, %1
			%elif %[buffer1] == 2
				mov rdx, %1
			%elif %[buffer1] == 3
				mov rcx, %1
			%elif %[buffer1] == 4
				mov r8, %1
			%elif %[buffer1] == 5
				mov r9, %1
			%endif
			%assign buffer1 %[buffer1] + 1
			%rotate 1
		%endrep
		call %[%$functions.%[buffer0].representation]
	%else
		%fatal
	%endif
%endmacro
%macro return 0-1
	_ASSERT_IF_NOT_IN_SCOPE global, struct
	_ASSERT_IF_NOT_STATIC
	%if %0 == 0
		ret
	%else
		_IF_INTEGER %1
	        mov rax, %1
	    _ENDIF
	    _IF_STRING %1
	        %%address: db %1, 0
	        mov rax, %[%%address]
	    _ENDIF
	    _IF_IDENTIFIER %1
	        _FETCH_REPRESENTATION arrays, op0, %1
	        mov rax, op0
	    _ENDIF
	    ret
	%endif
%endmacro

%macro label 1
	_ASSERT_IF_NOT_IN_SCOPE global, struct
	_ASSERT_IF_NOT_STATIC
	_ASSERT_IF_IDENTIFIER %1
	%%address:
	_APPEND_SYMBOL labels, %1, %[%%address]
%endmacro
%macro goto 1
	_ASSERT_IF_NOT_IN_SCOPE global, struct
	_ASSERT_IF_NOT_STATIC
	_ASSERT_IF_IDENTIFIER %1
	%assign buffer0 %[%$labels.count] - 1
	%undef if_found
	%rep %[%$labels.count]
		%ifidni %[%$labels.%[buffer0].identifier], %1
			%xdefine if_found
			%exitrep
		%endif
		%assign buffer0 %[buffer0] - 1
	%endrep
	%ifdef if_found
		jmp %[%$labels.%[buffer0].representation]
	%else
		%fatal
	%endif
%endmacro

%macro block 0
	_ASSERT_IF_NOT_IN_SCOPE global, struct
	_ASSERT_IF_NOT_STATIC
	_OPEN_SCOPE %??, %[%$base_pointer], %[%$struct_id]
	_COPY_SYMBOLS arrays
	_COPY_SYMBOLS structs
	_COPY_SYMBOLS members
	_COPY_SYMBOLS functions
	_COPY_SYMBOLS labels
%endmacro

%macro if 1
	_ASSERT_IF_NOT_IN_SCOPE global, struct
	_ASSERT_IF_NOT_STATIC
	block
	cmp %1, 0
	jz %$if_not
%endmacro
%macro elif 1
	_ASSERT_IF_NOT_IN_SCOPE global, struct
	_ASSERT_IF_NOT_STATIC
	%$if_not:
	end
	block
	cmp %1, 0
	jz %$if_not
%endmacro
%macro else 0
	_ASSERT_IF_NOT_IN_SCOPE global, struct
	_ASSERT_IF_NOT_STATIC
	%$if_not:
	end
%endmacro

%macro assign 2
    _ASSERT_IF_NOT_IN_SCOPE global, struct
    _ASSERT_IF_NOT_STATIC
    _ASSERT_IF_IDENTIFIER %1
    _FETCH_REPRESENTATION arrays, op0, %1
    _IF_INTEGER %2
        mov op0, %2
    _ENDIF
    _IF_STRING %2
        %%address: db %2, 0
        mov op0, %[%%address]
    _ENDIF
    _IF_IDENTIFIER %2
        _FETCH_REPRESENTATION arrays, op1, %2
        mov op0, op1
    _ENDIF
%endmacro
%macro assign_add 3
    _ASSERT_IF_NOT_IN_SCOPE global, struct
    _ASSERT_IF_NOT_STATIC
    _ASSERT_IF_IDENTIFIER %1
    _FETCH_REPRESENTATION arrays, op0, %1
    _IF_INTEGER %2
        add op0, %2
    _ENDIF
    _IF_STRING %2
        %%address: db %2, 0
        add op0, %[%%address]
    _ENDIF
    _IF_IDENTIFIER %2
        _FETCH_REPRESENTATION arrays, op1, %2
        add op0, op1
    _ENDIF
%endmacro
%macro assign_subtract 3
    _ASSERT_IF_NOT_IN_SCOPE global, struct
    _ASSERT_IF_NOT_STATIC
    _ASSERT_IF_IDENTIFIER %1
    _FETCH_REPRESENTATION arrays, op0, %1
    _IF_INTEGER %2
        sub op0, %2
    _ENDIF
    _IF_STRING %2
        %%address: db %2, 0
        sub op0, %[%%address]
    _ENDIF
    _IF_IDENTIFIER %2
        _FETCH_REPRESENTATION arrays, op1, %2
        sub op0, op1
    _ENDIF
%endmacro
%macro assign_multiply 3
    _ASSERT_IF_NOT_IN_SCOPE global, struct
    _ASSERT_IF_NOT_STATIC
    _ASSERT_IF_IDENTIFIER %1
    _FETCH_REPRESENTATION arrays, op0, %1
    _IF_INTEGER %2
        imul op0, %2
    _ENDIF
    _IF_STRING %2
        %%address: db %2, 0
    _ENDIF
    _IF_IDENTIFIER %2
        _FETCH_REPRESENTATION arrays, op1, %2
        imul op0, op1
    _ENDIF
%endmacro
;%macro assign_divide 3
;    _ASSERT_IF_NOT_IN_SCOPE global, struct
;    _ASSERT_IF_NOT_STATIC
;    _ASSERT_IF_IDENTIFIER %1
;    _FETCH_REPRESENTATION arrays, op0, %1
;    _IF_INTEGER %2
;    _ENDIF
;    _IF_STRING %2
;        %%address: db %2, 0
;    _ENDIF
;    _IF_IDENTIFIER %2
;        _FETCH_REPRESENTATION arrays, op1, %2
;    _ENDIF
;%endmacro
;%macro assign_modulo 3
;    _ASSERT_IF_NOT_IN_SCOPE global, struct
;    _ASSERT_IF_NOT_STATIC
;    _ASSERT_IF_IDENTIFIER %1
;    _FETCH_REPRESENTATION arrays, op0, %1
;    _IF_INTEGER %2
;    _ENDIF
;    _IF_STRING %2
;        %%address: db %2, 0
;    _ENDIF
;    _IF_IDENTIFIER %2
;        _FETCH_REPRESENTATION arrays, op1, %2
;    _ENDIF
;%endmacro
%macro assign_if_less_than 3
	_ASSERT_IF_NOT_IN_SCOPE global, struct
	_ASSERT_IF_NOT_STATIC
	_ASSERT_IF_IDENTIFIER %1
	_FETCH_REPRESENTATION arrays, op0, %1
	mov r10, 0
	_IF_INTEGER %2
		mov rax, %2
	_ENDIF
	_IF_STRING %2
		%%address2: db %2, 0
		mov rax, %[%%address2]
	_ENDIF
	_IF_IDENTIFIER %2
		_FETCH_REPRESENTATION arrays, op1, %2
		mov rax, op1
	_ENDIF
	_IF_INTEGER %3
		mov rbx, %3
	_ENDIF
	_IF_STRING %3
		%%address3: db %3, 0
		mov rbx, %[%%address3]
	_ENDIF
	_IF_IDENTIFIER %3
		_FETCH_REPRESENTATION arrays, op2, %3
		mov rbx, op2
	_ENDIF
	cmp rax, rbx
	setl r10b
	movzx r10, r10b
	mov op0, r10
%endmacro
%macro assign_if_more_than 3
	_ASSERT_IF_NOT_IN_SCOPE global, struct
	_ASSERT_IF_NOT_STATIC
	_ASSERT_IF_IDENTIFIER %1
	_FETCH_REPRESENTATION arrays, op0, %1
	mov r10, 0
	_IF_INTEGER %2
		mov rax, %2
	_ENDIF
	_IF_STRING %2
		%%address2: db %2, 0
		mov rax, %[%%address2]
	_ENDIF
	_IF_IDENTIFIER %2
		_FETCH_REPRESENTATION arrays, op1, %2
		mov rax, op1
	_ENDIF
	_IF_INTEGER %3
		mov rbx, %3
	_ENDIF
	_IF_STRING %3
		%%address3: db %3, 0
		mov rbx, %[%%address3]
	_ENDIF
	_IF_IDENTIFIER %3
		_FETCH_REPRESENTATION arrays, op2, %3
		mov rbx, op2
	_ENDIF
	cmp rax, rbx
	setg r10b
	movzx r10, r10b
	mov op0, r10
%endmacro
%macro assign_if_less_or_equal_than 3
	_ASSERT_IF_NOT_IN_SCOPE global, struct
	_ASSERT_IF_NOT_STATIC
	_ASSERT_IF_IDENTIFIER %1
	_FETCH_REPRESENTATION arrays, op0, %1
	mov r10, 0
	_IF_INTEGER %2
		mov rax, %2
	_ENDIF
	_IF_STRING %2
		%%address2: db %2, 0
		mov rax, %[%%address2]
	_ENDIF
	_IF_IDENTIFIER %2
		_FETCH_REPRESENTATION arrays, op1, %2
		mov rax, op1
	_ENDIF
	_IF_INTEGER %3
		mov rbx, %3
	_ENDIF
	_IF_STRING %3
		%%address3: db %3, 0
		mov rbx, %[%%address3]
	_ENDIF
	_IF_IDENTIFIER %3
		_FETCH_REPRESENTATION arrays, op2, %3
		mov rbx, op2
	_ENDIF
	cmp rax, rbx
	setle r10b
	movzx r10, r10b
	mov op0, r10
%endmacro
%macro assign_if_more_or_equal_than 3
	_ASSERT_IF_NOT_IN_SCOPE global, struct
	_ASSERT_IF_NOT_STATIC
	_ASSERT_IF_IDENTIFIER %1
	_FETCH_REPRESENTATION arrays, op0, %1
	mov r10, 0
	_IF_INTEGER %2
		mov rax, %2
	_ENDIF
	_IF_STRING %2
		%%address2: db %2, 0
		mov rax, %[%%address2]
	_ENDIF
	_IF_IDENTIFIER %2
		_FETCH_REPRESENTATION arrays, op1, %2
		mov rax, op1
	_ENDIF
	_IF_INTEGER %3
		mov rbx, %3
	_ENDIF
	_IF_STRING %3
		%%address3: db %3, 0
		mov rbx, %[%%address3]
	_ENDIF
	_IF_IDENTIFIER %3
		_FETCH_REPRESENTATION arrays, op2, %3
		mov rbx, op2
	_ENDIF
	cmp rax, rbx
	setge r10b
	movzx r10, r10b
	mov op0, r10
%endmacro
%macro assign_if_equal 3
	_ASSERT_IF_NOT_IN_SCOPE global, struct
	_ASSERT_IF_NOT_STATIC
	_ASSERT_IF_IDENTIFIER %1
	_FETCH_REPRESENTATION arrays, op0, %1
	mov r10, 0
	_IF_INTEGER %2
		mov rax, %2
	_ENDIF
	_IF_STRING %2
		%%address2: db %2, 0
		mov rax, %[%%address2]
	_ENDIF
	_IF_IDENTIFIER %2
		_FETCH_REPRESENTATION arrays, op1, %2
		mov rax, op1
	_ENDIF
	_IF_INTEGER %3
		mov rbx, %3
	_ENDIF
	_IF_STRING %3
		%%address3: db %3, 0
		mov rbx, %[%%address3]
	_ENDIF
		_IF_IDENTIFIER %3
		_FETCH_REPRESENTATION arrays, op2, %3
		mov rbx, op2
	_ENDIF
	cmp rax, rbx
	sete r10b
	movzx r10, r10b
	mov op0, r10
%endmacro
%macro assign_if_not_equal 3
	_ASSERT_IF_NOT_IN_SCOPE global, struct
	_ASSERT_IF_NOT_STATIC
	_ASSERT_IF_IDENTIFIER %1
	_FETCH_REPRESENTATION arrays, op0, %1
	mov r10, 0
	_IF_INTEGER %2
		mov rax, %2
	_ENDIF
	_IF_STRING %2
		%%address2: db %2, 0
		mov rax, %[%%address2]
	_ENDIF
	_IF_IDENTIFIER %2
		_FETCH_REPRESENTATION arrays, op1, %2
		mov rax, op1
	_ENDIF
	_IF_INTEGER %3
		mov rbx, %3
	_ENDIF
	_IF_STRING %3
		%%address3: db %3, 0
		mov rbx, %[%%address3]
	_ENDIF
	_IF_IDENTIFIER %3
		_FETCH_REPRESENTATION arrays, op2, %3
		mov rbx, op2
	_ENDIF
	cmp rax, rbx
	setne r10b
	movzx r10, r10b
	mov op0, r10
%endmacro

%macro sizeof 2
	_ASSERT_IF_NOT_IN_SCOPE global, struct
	_ASSERT_IF_NOT_STATIC
	_ASSERT_IF_IDENTIFIER %1
	_FETCH_REPRESENTATION arrays, op0, %1
	_FETCH_REPRESENTATION structs, op1, %2
	mov op0, op1
%endmacro

%macro end 0-*
	_ASSERT_IF_NOT_IN_SCOPE global
	_ASSERT_IF_NOT_STATIC
	_IF_IN_SCOPE struct
		%assign buffer0 0
		%assign buffer1 0
		%rep %[%$members.count]
			%if %[%$members.%[buffer0].struct] == %[%$struct_id]
				%ifidni %[%$members.%[buffer0].access_modifier], public
					%xdefine saved_members.public.%[buffer1].identifier %$%members.%[buffer0].identifier
					%xdefine saved_members.public.%[buffer1].representation %$%members.%[buffer0].representation
					%assign buffer1 %[buffer1] + 1
				%elifidni %[%$members.%[buffer0].access_modifier], protected

					%assign buffer1 %[buffer1] + 1
				%endif
			%endif
			%assign buffer0 %[buffer0] + 1
		%endrep
		%assign size %[%$structs.%[%$structs.count].representation]
		_CLOSE_SCOPE
		_IF_STRUCT_STATIC
			%undef %$if_struct_static
			%rep %0
				static array %1, %[size]
				%assign buffer0 0
				%rep %[buffer1]
					_APPEND_SYMBOL members, %1.%[saved_members.public.%[buffer0].identifier], %[saved_members.public.%[buffer0].representation], %[%$access_modifier], %[%$struct_id]
					%assign buffer0 %[buffer0] + 1
				%endrep
				%rotate 1
			%endrep
		_ELSE
			%rep %0
				array %1, %[size]
				%assign buffer0 0
				%rep %[buffer1]
					_APPEND_SYMBOL members, %1.%[saved_members.public.%[buffer0].identifier], %[saved_members.public.%[buffer0].representation], %[saved_members.public.%[buffer0].access_modifier], %[%$struct_id]
					%assign buffer0 %[buffer0] + 1
				%endrep
				%rotate 1
			%endrep
		_ENDIF
	_ENDIF
	_IF_IN_SCOPE function
		ret
		_CLOSE_SCOPE
		%rep %0
			%fatal
		%endrep
		section %[%$section]
	_ENDIF
	_IF_IN_SCOPE block
		%$if_not:
		_CLOSE_SCOPE
		%rep %0
			%fatal
		%endrep
	_ENDIF
%endmacro
