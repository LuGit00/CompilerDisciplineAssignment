; array_declaration : ARRAY ID NUMBER { ; }
; struct_declaration : STRUCT ID IDs struct_scope END IDs { ; }
; function_declaration : FUNCTION ID function_scope END { ; }
; num_str_id : NUMBER | STRING | 
; function_scope :
;     array_declaration { $$ = $1 ; }
;     | struct_declaration { $$ = $1 ; }
;     | function_declaration { $$ = $1 ; }
;     | EXECUTE ID
;     | RETURN ID
;     | LABEL ID
;     | GOTO ID
;     | BLOCK ID
;     | IF ID
;     | ELIF ID
;     | ELSE ID
;     | ASSIGN ID
;     | ASSIGN_ADD ID
;     | ASSIGN_SUBTRACT ID
;     | ASSIGN_MULTIPLY ID
;     | ASSIGN_IF_LESS_THAN ID
;     | ASSIGN_IF_MORE_THAN ID
;     | ASSIGN_IF_LESS_OR_EQUAL_THAN ID
;     | ASSIGN_IF_MORE_OR_EQUAL_THAN ID
;     | ASSIGN_IF_EQUAL ID
;     | ASSIGN_IF_NOT_EQUAL ID
;     | ASM STRING
;     | ASSIGN_SIZEOF ID ID
;     | END
;     ;
; struct_scope :
;     array_declaration { $$ = $1 ; }
;     | struct_declaration { $$ = $1 ; }
;     | function_declaration { $$ = $1 ; }
;     ;
; global_statement :
;     array_declaration { $$ = $1 ; }
;     | struct_declaration { $$ = $1 ; }
;     | function_declaration { $$ = $1 ; }
;     ;
; global_scope :
;     global_statement { $$ = $1 ; }
;     | global_statement global_scope { $$ = $1 $2 ; }
;     ;

; Create Scope
%push global
%assign depth 0

; Initialize Scope Variables
%assign %$array_count 0
%assign %$struct_count 0
%assign %$function_count 0

%macro array 2

	; Scope Checking
	%ifctx global
	%elifctx struct
	%elifctx function
	%elifctx block
	%endif

	; Parameter Checking
	%ifnum %1
		%fatal
	%elifstr %1
		%fatal
	%elifid %1
	%endif
	%ifnum %2
	%elifstr %2
		%fatal
	%elifid %2
		%fatal
	%endif

	; Append array Symbol
	%xdefine %$array_%[%$array_count]_identifier %1
	%xdefine %$array_%[%$array_count]_address array%[array_count]
	%ifctx structy
		%xdefine %$array_%[%$array_count]_access_modifier %$access_modifier
	%endif
	%xdefine %$array_%[%$array_count]_depth %[depth]
	%assign %$array_count %$array_count + 1

	; Set Section For Runtime
	%ifctx struct
		absolute %$size
		%assign %$size %$size + %2
	%else
		section .bss
	%endif

	; Runtime - Create Label, Reserve Bytes
	array%[array_count]: resb %2

	; Increment ID
	%assign array_count %[array_count] + 1

%endmacro
%macro struct 1-*
	
	; Scope Checking
	%ifctx global
	%elifctx struct
	%elifctx function
	%elifctx block
	%endif

	; Parameter Checking
	%ifnum %1
		%fatal
	%elifstr %1
		%fatal
	%elifid %1
	%endif

	; Append struct Symbol
	%xdefine %$struct_%[%$struct_count]_identifier %1
	%xdefine %$struct_%[%$struct_count]_address struct%[struct_count]
	%assign %$struct_%[%$struct_count]_size 0
	%ifctx struct
		%xdefine %$struct_%[%$struct_count]_access_modifier %$access_modifier
	%endif
	%xdefine %$struct_%[%$struct_count]_depth %[depth]
	%assign %$struct_count %$struct_count + 1

	; Create Scope
	%push %??
	%assign depth %[depth] + 1

	; Initialize Scope Variables
	%assign %$array_count 0
	%assign %$struct_count 0
	%assign %$function_count 0
	%assign %$size 0
	%xdefine %$access_modifier private
	%assign %$id %[struct_count]

	; Copy Symbol Tables
	%rep %$$array_count
		%xdefine %$array_%[%$array_count]identifier %$$array%[%$array_count]_identifier
		%xdefine %$array_%[%$array_count]address %$$array%[%$array_count]_address
		%xdefine %$array_%[%$array_count]depth %$$array%[%$array_count]_depth
		%assign %$array_count %$array_count + 1
	%endrep
	%rep %$$struct_count
		%xdefine %$struct_%[%$struct_count]identifier %$$struct%[%$struct_count]_identifier
		%xdefine %$struct_%[%$struct_count]address %$$struct%[%$struct_count]_address
		%xdefine %$struct_%[%$struct_count]size %$$struct%[%$struct_count]_size
		%xdefine %$struct_%[%$struct_count]depth %$$struct%[%$struct_count]_depth
		%assign %$struct_count %$struct_count + 1
	%endrep
	%rep %$$function_count
		%xdefine %$function_%[%$function_count]identifier %$$function%[%$function_count]_identifier
		%xdefine %$function_%[%$function_count]address %$$function%[%$function_count]_address
		%xdefine %$function_%[%$function_count]depth %$$function%[%$function_count]_depth
		%assign %$function_count %$function_count + 1
	%endrep

	; Inherit
	%rep %0 - 1
		%rotate 1

		; Parameter Checking
		%ifnum %1
			%fatal
		%elifstr %1
			%fatal
		%elifid %1
		%endif

		; TODO

	%endrep

	; Set Section For Runtime
	absolute %$size

	; Runtime - Create Label
	struct%[struct_count]:

	; Increment ID
	%assign struct_count %[struct_count] + 1

%endmacro
%macro private 0
	
	; Scope Checking
	%ifctx global
		%fatal
	%elifctx struct
	%elifctx function
		%fatal
	%elifctx block
		%fatal
	%endif

	; Set Scope Access Modifier
	%xdefine %$access_modifier %??

%endmacro
%macro protected 0
	
	; Scope Checking
	%ifctx global
		%fatal
	%elifctx struct
	%elifctx function
		%fatal
	%elifctx block
		%fatal
	%endif

	; Set Scope Access Modifier
	%xdefine %$access_modifier %??

%endmacro
%macro public 0
	
	; Scope Checking
	%ifctx global
		%fatal
	%elifctx struct
	%elifctx function
		%fatal
	%elifctx block
		%fatal
	%endif

	; Set Scope Access Modifier
	%xdefine %$access_modifier %??

%endmacro
%macro function 1
	
	; Scope Checking
	%ifctx global
	%elifctx struct
	%elifctx function
	%elifctx block
	%endif

	; Parameter Checking
	%ifnum %1
		%fatal
	%elifstr %1
		%fatal
	%elifid %1
	%endif

	; Append function Symbol
	%xdefine %$function_%[%$function_count]_identifier %1
	%xdefine %$function_%[%$function_count]_address function%[function_count]
	%ifctx struct
		%xdefine %$function_%[%$function_count]_access_modifier %$access_modifier
	%endif
	%xdefine %$function_%[%$function_count]_depth %[depth]
	%assign %$function_count %$function_count + 1

	; Create Scope
	%push %??
	%assign depth %[depth] + 1

	; Initialize Scope Variables
	%assign %$array_count 0
	%assign %$struct_count 0
	%assign %$function_count 0
	%assign %$label_count 0
	%ifidni %1, _start
		%xdefine %$section .text
	%else
		%xdefine %$section .text.%1
	%endif

	; Copy Symbol Tables
	%rep %$$array_count
		%xdefine %$array_%[%$array_count]identifier %$$array%[%$array_count]_identifier
		%xdefine %$array_%[%$array_count]address %$$array%[%$array_count]_address
		%xdefine %$array_%[%$array_count]depth %$$array%[%$array_count]_depth
		%assign %$array_count %$array_count + 1
	%endrep
	%rep %$$struct_count
		%xdefine %$struct_%[%$struct_count]identifier %$$struct%[%$struct_count]_identifier
		%xdefine %$struct_%[%$struct_count]address %$$struct%[%$struct_count]_address
		%xdefine %$struct_%[%$struct_count]size %$$struct%[%$struct_count]_size
		%xdefine %$struct_%[%$struct_count]depth %$$struct%[%$struct_count]_depth
		%assign %$struct_count %$struct_count + 1
	%endrep
	%rep %$$function_count
		%xdefine %$function_%[%$function_count]identifier %$$function%[%$function_count]_identifier
		%xdefine %$function_%[%$function_count]address %$$function%[%$function_count]_address
		%xdefine %$function_%[%$function_count]depth %$$function%[%$function_count]_depth
		%assign %$function_count %$function_count + 1
	%endrep

	; Set Section For Runtime
	section %$section

	; Runtime - Create Label
	function%[function_count]:

	; Increment ID
	%assign function_count %[function_count] + 1

%endmacro
%macro execute 1
	
	; Scope Checking
	%ifctx global
		%fatal
	%elifctx struct
		%fatal
	%elifctx function
	%elifctx block
	%endif

	; Parameter Checking
	%ifnum %1
		%fatal
	%elifstr %1
		%fatal
	%elifid %1
	%endif

	; Set Section For Runtime
	section %$section

	; Runtime - Fetch function and call it
	%assign counter 0
	%rep %$function_count
		%ifidni %$function_%[counter]_identifier, %1
			call %$function_%[counter]_address
			%exitrep
		%endif
		%assign counter %[counter] + 1
	%endrep

%endmacro
%macro return 0-1
	
	; Scope Checking
	%ifctx global
		%fatal
	%elifctx struct
		%fatal
	%elifctx function
	%elifctx block
	%endif

	; Set Section For Runtime
	section %$section

	; Runtime - Fetch Return Value, Epilogue and Return
	%if %0 == 1
		%ifnum %1
		%elifstr %1
		%elifid %1
			%assign counter 0
			%rep %$array_count
				%ifidni %$array_%[counter]_identifier, %1
					mov rax, %$array_%[counter]_address
					%exitrep
				%endif
				%assign counter %[counter] + 1
			%endrep
		%endif
		mov rax, %1
	%endif
	leave
	ret

%endmacro
%macro label 1
	
	; Scope Checking
	%ifctx global
		%fatal
	%elifctx struct
		%fatal
	%elifctx function
	%elifctx block
	%endif

	; Parameter Checking
	%ifnum %1
		%fatal
	%elifstr %1
		%fatal
	%elifid %1
	%endif

	; Append label Symbol
	%xdefine %$label_%[%$label_count]_identifier %1
	%xdefine %$label_%[%$label_count]_address label%[label_count]
	%assign %$label_count %$label_count + 1

	; Set Section For Runtime
	section %$section

	; Runtime - Create Label
	label%[label_count]:

	; Increment ID
	%assign label_count %[label_count] + 1

%endmacro
%macro goto 1
	
	; Scope Checking
	%ifctx global
		%fatal
	%elifctx struct
		%fatal
	%elifctx function
	%elifctx block
	%endif

	; Parameter Checking
	%ifnum %1
		%fatal
	%elifstr %1
		%fatal
	%elifid %1
	%endif

	; Set Section For Runtime
	section %$section

	; Runtime - Fetch label and jump to it
	%assign counter 0
	%rep %$label_count
		%ifidni %$label_%[counter]_identifier, %1
			jmp %$label_%[counter]_address
			%exitrep
		%endif
		%assign counter %[counter] + 1
	%endrep

%endmacro
%macro block 0
	
	; Scope Checking
	%ifctx global
		%fatal
	%elifctx struct
		%fatal
	%elifctx function
	%elifctx block
	%endif

	; Create Scope
	%push %??
	%assign depth %[depth] + 1

	; Initialize Scope Variables
	%assign %$array_count 0
	%assign %$struct_count 0
	%assign %$function_count 0
	%assign %$label_count 0
	%xdefine %$section %$$section

	; Copy Symbol Tables
	%rep %$$array_count
		%xdefine %$array_%[%$array_count]identifier %$$array%[%$array_count]_identifier
		%xdefine %$array_%[%$array_count]address %$$array%[%$array_count]_address
		%xdefine %$array_%[%$array_count]depth %$$array%[%$array_count]_depth
		%assign %$array_count %$array_count + 1
	%endrep
	%rep %$$struct_count
		%xdefine %$struct_%[%$struct_count]identifier %$$struct%[%$struct_count]_identifier
		%xdefine %$struct_%[%$struct_count]address %$$struct%[%$struct_count]_address
		%xdefine %$struct_%[%$struct_count]size %$$struct%[%$struct_count]_size
		%xdefine %$struct_%[%$struct_count]depth %$$struct%[%$struct_count]_depth
		%assign %$struct_count %$struct_count + 1
	%endrep
	%rep %$$function_count
		%xdefine %$function_%[%$function_count]identifier %$$function%[%$function_count]_identifier
		%xdefine %$function_%[%$function_count]address %$$function%[%$function_count]_address
		%assign %$function_count %$function_count + 1
	%endrep
	%rep %$$label_count
		%xdefine %$label_%[%$label_count]identifier %$$label%[%$label_count]_identifier
		%xdefine %$label_%[%$label_count]address %$$label%[%$label_count]_address
		%assign %$label_count %$label_count + 1
	%endrep

%endmacro
%macro if 1
	
	; Scope Checking
	%ifctx global
		%fatal
	%elifctx struct
		%fatal
	%elifctx function
	%elifctx block
	%endif

	; Set Section For Runtime
	section %$section

	; Runtime - Create Block and Compare
	block
	cmp %1, 0
	jz %$if_not

%endmacro
%macro elif 1
	
	; Scope Checking
	%ifctx global
		%fatal
	%elifctx struct
		%fatal
	%elifctx function
	%elifctx block
	%endif

	; Set Section For Runtime
	section %$section

	; End, Create Block and Compare
	end
	block
	cmp %1, 0
	jz %$if_not

%endmacro
%macro else 0
	
	; Scope Checking
	%ifctx global
		%fatal
	%elifctx struct
		%fatal
	%elifctx function
	%elifctx block
	%endif

	; End and Create Block
	end
	block

%endmacro

%macro assign 2
	
	; Scope Checking
	%ifctx global
		%fatal
	%elifctx struct
		%fatal
	%elifctx function
	%elifctx block
	%endif

	; Parameter Checking
	%ifnum %1
		%fatal
	%elifstr %1
		%fatal
	%elifid %1
	%endif

%endmacro
%macro assign_add 3
	; Scope Checking
	%ifctx global
		%fatal
	%elifctx struct
		%fatal
	%elifctx function
	%elifctx block
	%endif

	; Parameter Checking
	%ifnum %1
		%fatal
	%elifstr %1
		%fatal
	%elifid %1
	%endif
%endmacro
%macro assign_subtract 3
	; Scope Checking
	%ifctx global
		%fatal
	%elifctx struct
		%fatal
	%elifctx function
	%elifctx block
	%endif

	; Parameter Checking
	%ifnum %1
		%fatal
	%elifstr %1
		%fatal
	%elifid %1
	%endif
%endmacro
%macro assign_multiply 3
	; Scope Checking
	%ifctx global
		%fatal
	%elifctx struct
		%fatal
	%elifctx function
	%elifctx block
	%endif

	; Parameter Checking
	%ifnum %1
		%fatal
	%elifstr %1
		%fatal
	%elifid %1
	%endif
%endmacro
%macro assign_if_less_than 3
	; Scope Checking
	%ifctx global
		%fatal
	%elifctx struct
		%fatal
	%elifctx function
	%elifctx block
	%endif

	; Parameter Checking
	%ifnum %1
		%fatal
	%elifstr %1
		%fatal
	%elifid %1
	%endif
%endmacro
%macro assign_if_more_than 3
	; Scope Checking
	%ifctx global
		%fatal
	%elifctx struct
		%fatal
	%elifctx function
	%elifctx block
	%endif

	; Parameter Checking
	%ifnum %1
		%fatal
	%elifstr %1
		%fatal
	%elifid %1
	%endif
%endmacro
%macro assign_if_less_or_equal_than 3
	; Scope Checking
	%ifctx global
		%fatal
	%elifctx struct
		%fatal
	%elifctx function
	%elifctx block
	%endif

	; Parameter Checking
	%ifnum %1
		%fatal
	%elifstr %1
		%fatal
	%elifid %1
	%endif
%endmacro
%macro assign_if_more_or_equal_than 3
	; Scope Checking
	%ifctx global
		%fatal
	%elifctx struct
		%fatal
	%elifctx function
	%elifctx block
	%endif

	; Parameter Checking
	%ifnum %1
		%fatal
	%elifstr %1
		%fatal
	%elifid %1
	%endif
%endmacro
%macro assign_if_equal 3
	; Scope Checking
	%ifctx global
		%fatal
	%elifctx struct
		%fatal
	%elifctx function
	%elifctx block
	%endif

	; Parameter Checking
	%ifnum %1
		%fatal
	%elifstr %1
		%fatal
	%elifid %1
	%endif
%endmacro
%macro assign_if_not_equal 3
	; Scope Checking
	%ifctx global
		%fatal
	%elifctx struct
		%fatal
	%elifctx function
	%elifctx block
	%endif

	; Parameter Checking
	%ifnum %1
		%fatal
	%elifstr %1
		%fatal
	%elifid %1
	%endif
%endmacro
%macro asm 1
	; Scope Checking
	%ifctx global
		%fatal
	%elifctx struct
		%fatal
	%elifctx function
	%elifctx block
	%endif

	; Parameter Checking
	%ifnum %1
	%elifstr %1
	%elifid %1
		%fatal
	%endif

	; Tokenize String
	%tok(%1)
%endmacro
%macro assign_sizeof 2
	
	; Scope Checking
	%ifctx global
		%fatal
	%elifctx struct
		%fatal
	%elifctx function
	%elifctx block
	%endif

	; Parameter Checking
	%ifnum %1
		%fatal
	%elifstr %1
		%fatal
	%elifid %1
	%endif
	%ifnum %2
		%fatal
	%elifstr %2
		%fatal
	%elifid %2
	%endif

%endmacro

%macro end 0-*
	
	; Scope Checking
	%ifctx global
		%fatal
	%elifctx struct
	%elifctx function
	%elifctx block
	%endif

	; Parameter Checking
	%if %0 > 0
		%ifnctx struct
			%fatal
		%endif
	%endif

	; Pre Destroying Processing
	%ifctx struct
		%assign size %$size
		%assign %$struct_%[%$id]_size %$size

		; Initialize Temporary Variables
		%assign array_public_count 0
		%assign struct_public_count 0
		%assign function_public_count 0
		%assign array_protected_count 0
		%assign struct_protected_count 0
		%assign function_protected_count 0

		; Save publics and protecteds
		%assign counter 0
		%rep %$array_count
			%if %$array_%[counter]_depth == %[depth]
				%ifidni %$array_%[counter]_access_modifier, public
					%xdefine array_public_%[array_public_count]identifier %$array%[counter]_identifier
					%xdefine array_public_%[array_public_count]address %$array%[counter]_address
					%assign array_public_count %[array_public_count] + 1
				%elifidni %$array_%[counter]_access_modifier, protected
					%xdefine array_protected_%[array_protected_count]identifier %$array%[counter]_identifier
					%xdefine array_protected_%[array_protected_count]address %$array%[counter]_address
					%assign array_protected_count %[array_protected_count] + 1
				%endif
			%endif
			%assign counter %[counter] + 1
		%endrep
		%assign counter 0
		%rep %$struct_count
			%if %$struct_%[counter]_depth == %[depth]
				%ifidni %$struct_%[counter]_access_modifier, public
					%xdefine struct_public_%[struct_public_count]identifier %$struct%[counter]_identifier
					%xdefine struct_public_%[struct_public_count]address %$struct%[counter]_address
					%xdefine struct_public_%[struct_public_count]size %$struct%[counter]_size
					%assign struct_public_count %[struct_public_count] + 1
				%elifidni %$struct_%[counter]_access_modifier, protected
					%xdefine struct_protected_%[struct_protected_count]identifier %$struct%[counter]_identifier
					%xdefine struct_protected_%[struct_protected_count]address %$struct%[counter]_address
					%xdefine struct_protected_%[struct_protected_count]size %$struct%[counter]_size
					%assign struct_protected_count %[struct_protected_count] + 1
				%endif
			%endif
			%assign counter %[counter] + 1
		%endrep
		%assign counter 0
		%rep %$function_count
			%if %$function_%[counter]_depth == %[depth]
				%ifidni %$function_%[counter]_access_modifier, public
					%xdefine function_public_%[function_public_count]identifier %$function%[counter]_identifier
					%xdefine function_public_%[function_public_count]address %$function%[counter]_address
					%assign function_public_count %[function_public_count] + 1
				%elifidni %$function_%[counter]_access_modifier, protected
					%xdefine function_protected_%[function_protected_count]identifier %$function%[counter]_identifier
					%xdefine function_protected_%[function_protected_count]address %$function%[counter]_address
					%assign function_protected_count %[function_protected_count] + 1
				%endif
			%endif
			%assign counter %[counter] + 1
		%endrep

	%elifctx function
	%elifctx block

		; Set Section For Runtime
		section %$section

		%$if_not:
	%endif

	; Destroy Scope
	%pop
	%assign depth %[depth] - 1

	; Post Destroying Processing
	%ifctx struct
		%rep %0

			; Parameter Checking
			%ifnum %1
				%fatal
			%elifstr %1
				%fatal
			%elifid %1
			%endif

			array %1, %[size]
			%rotate 1
		%endrep

		; Redeclare Public Variables
		%assign counter 0
		%rep %[array_public_count]
			%xdefine %$array_%[%$array_count]identifier array_public%[counter]_identifier
			%xdefine %$array_%[%$array_count]address array_public%[counter]_address
			%xdefine %$array_%[%$array_count]_depth %[depth]
			%assign %$array_count %$array_count + 1
			%assign counter %[counter] + 1
		%endrep
		%assign counter 0
		%rep %[struct_public_count]
			%xdefine %$struct_%[%$struct_count]identifier struct_public%[counter]_identifier
			%xdefine %$struct_%[%$struct_count]address struct_public%[counter]_address
			%xdefine %$struct_%[%$struct_count]size struct_public%[counter]_size
			%xdefine %$struct_%[%$struct_count]_depth %[depth]
			%assign %$struct_count %$struct_count + 1
			%assign counter %[counter] + 1
		%endrep
		%assign counter 0
		%rep %[function_public_count]
			%xdefine %$function_%[%$function_count]identifier function_public%[counter]_identifier
			%xdefine %$function_%[%$function_count]address function_public%[counter]_address
			%xdefine %$function_%[%$function_count]_depth %[depth]
			%assign %$function_count %$function_count + 1
			%assign counter %[counter] + 1
		%endrep

	%elifctx function
	%elifctx block
	%endif

%endmacro