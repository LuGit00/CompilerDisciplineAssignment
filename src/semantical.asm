; semantical.asm – corrected, with explicit fatal messages and protected inheritance

; =========================
; Global scope bookkeeping
; =========================

%push global
%assign depth 0

%assign %$array_count    0
%assign %$struct_count   0
%assign %$function_count 0

%assign array_count    0
%assign struct_count   0
%assign function_count 0
%assign label_count    0

; =========================
; Helper: load NUMBER/STRING/ID into a register
; =========================

%macro value_to_reg 2
    %ifnum %2
        mov %1, %2
    %elifstr %2
        %%str_%1_%2: db %2, 0
        mov %1, %%str_%1_%2
    %elifid %2
        %assign counter 0
        %rep %$array_count
            %ifidni %$array_%[counter]_identifier, %2
                mov %1, [%$array_%[counter]_address]
                %exitrep
            %endif
            %assign counter counter + 1
        %endrep
    %else
        %fatal "value_to_reg: invalid operand"
    %endif
%endmacro

; =========================
; array
; =========================

%macro array 2
    %ifctx global
    %elifctx struct
    %elifctx function
    %elifctx block
    %else
        %fatal "array: invalid context"
    %endif

    %ifnid %1
        %fatal "array: first parameter must be identifier"
    %endif

    ; only forbid obvious strings, everything else NASM will evaluate
    %ifstr %2
        %fatal "array: second parameter must NOT be string"
    %endif

    ; register in current scope
    %xdefine %$array_%[%$array_count]_identifier %1
    %xdefine %$array_%[%$array_count]_address    %1
    %ifctx struct
        %xdefine %$array_%[%$array_count]_access_modifier %$access_modifier
    %endif
    %xdefine %$array_%[%$array_count]_depth      depth
    %assign %$array_count %$array_count + 1

    ; allocation / layout
    %ifctx struct
        absolute %$size
        %assign %$size %$size + %2
    %else
        section .bss
        %1: resb %2
    %endif
%endmacro


; =========================
; struct – with protected inheritance
; =========================

%macro struct 1
    ; Scope check
    %ifctx global
    %elifctx struct
        %fatal "struct: illegal in struct scope"
    %elifctx function
        %fatal "struct: illegal in function scope"
    %elifctx block
        %fatal "struct: illegal in block scope"
    %else
        %fatal "struct: invalid context"
    %endif

    ; Param 1: struct identifier
    %ifnid %1
        %fatal "struct: first parameter must be identifier"
    %endif

    ; Enter struct scope
    %push struct
    %assign depth depth + 1

    ; Per-struct locals (visible to end)
    %xdefine %$struct_name %1
    %assign %$size 0
    %assign %$array_count    0
    %assign %$function_count 0
    %xdefine %$access_modifier private
%endmacro

; =========================
; access modifiers
; =========================

%macro private 0
    %ifctx global
        %fatal "private: illegal in global scope"
    %elifctx struct
    %elifctx function
        %fatal "private: illegal in function scope"
    %elifctx block
        %fatal "private: illegal in block scope"
    %else
        %fatal "private: invalid context"
    %endif

    %xdefine %$access_modifier private
%endmacro

%macro protected 0
    %ifctx global
        %fatal "protected: illegal in global scope"
    %elifctx struct
    %elifctx function
        %fatal "protected: illegal in function scope"
    %elifctx block
        %fatal "protected: illegal in block scope"
    %else
        %fatal "protected: invalid context"
    %endif

    %xdefine %$access_modifier protected
%endmacro

%macro public 0
    %ifctx global
        %fatal "public: illegal in global scope"
    %elifctx struct
    %elifctx function
        %fatal "public: illegal in function scope"
    %elifctx block
        %fatal "public: illegal in block scope"
    %else
        %fatal "public: invalid context"
    %endif

    %xdefine %$access_modifier public
%endmacro

; =========================
; function
; =========================

%macro function 1
    %ifctx global
    %elifctx struct
    %elifctx function
    %elifctx block
    %else
        %fatal "function: invalid context"
    %endif

    %ifnid %1
        %fatal "function: parameter must be identifier"
    %endif

    %xdefine %$function_%[%$function_count]_identifier %1
    %xdefine %$function_%[%$function_count]_address    function%[function_count]
    %ifctx struct
        %xdefine %$function_%[%$function_count]_access_modifier %$access_modifier
    %endif
    %xdefine %$function_%[%$function_count]_depth      depth
    %assign %$function_count %$function_count + 1

    %push %??
    %assign depth depth + 1

    %assign %$array_count    0
    %assign %$struct_count   0
    %assign %$function_count 0
    %assign %$label_count    0

    %ifidni %1, _start
        %xdefine %$section .text
    %else
        %xdefine %$section .text.%1
    %endif

    %rep %$$array_count
        %xdefine %$array_%[%$array_count]_identifier %$$array_%[%$array_count]_identifier
        %xdefine %$array_%[%$array_count]_address    %$$array_%[%$array_count]_address
        %xdefine %$array_%[%$array_count]_depth      %$$array_%[%$array_count]_depth
        %assign %$array_count %$array_count + 1
    %endrep

    %rep %$$struct_count
        %xdefine %$struct_%[%$struct_count]_identifier %$$struct_%[%$struct_count]_identifier
        %xdefine %$struct_%[%$struct_count]_address    %$$struct_%[%$struct_count]_address
        %xdefine %$struct_%[%$struct_count]_size       %$$struct_%[%$struct_count]_size
        %xdefine %$struct_%[%$struct_count]_depth      %$$struct_%[%$struct_count]_depth
        %assign %$struct_count %$struct_count + 1
    %endrep

    %rep %$$function_count
        %xdefine %$function_%[%$function_count]_identifier %$$function_%[%$function_count]_identifier
        %xdefine %$function_%[%$function_count]_address    %$$function_%[%$function_count]_address
        %xdefine %$function_%[%$function_count]_depth      %$$function_%[%$function_count]_depth
        %assign %$function_count %$function_count + 1
    %endrep
    section %$section
    function%[function_count]:
    %assign function_count function_count + 1
%endmacro

; =========================
; execute
; =========================

%macro execute 1
    %ifctx global
        %fatal "execute: illegal in global scope"
    %elifctx struct
        %fatal "execute: illegal in struct scope"
    %elifctx function
    %elifctx block
    %else
        %fatal "execute: invalid context"
    %endif

    %ifnid %1
        %fatal "execute: parameter must be identifier"
    %endif

    section %$section

    %assign counter 0
    %rep %$function_count
        %ifidni %$function_%[counter]_identifier, %1
            call %$function_%[counter]_address
            %exitrep
        %endif
        %assign counter counter + 1
    %endrep
%endmacro

; =========================
; return
; =========================

%macro return 0-1
    %ifctx global
        %fatal "return: illegal in global scope"
    %elifctx struct
        %fatal "return: illegal in struct scope"
    %elifctx function
    %elifctx block
    %else
        %fatal "return: invalid context"
    %endif

    section %$section
    
    ret
%endmacro

; =========================
; label / goto
; =========================

%macro label 1
    %ifctx global
        %fatal "label: illegal in global scope"
    %elifctx struct
        %fatal "label: illegal in struct scope"
    %elifctx function
    %elifctx block
    %else
        %fatal "label: invalid context"
    %endif

    %ifnid %1
        %fatal "label: parameter must be identifier"
    %endif

    %xdefine %$label_%[%$label_count]_identifier %1
    %xdefine %$label_%[%$label_count]_address    label%[label_count]
    %assign %$label_count %$label_count + 1

    section %$section
    label%[label_count]:
    %assign label_count label_count + 1
%endmacro

%macro goto 1
    %ifctx global
        %fatal "goto: illegal in global scope"
    %elifctx struct
        %fatal "goto: illegal in struct scope"
    %elifctx function
    %elifctx block
    %else
        %fatal "goto: invalid context"
    %endif

    %ifnid %1
        %fatal "goto: parameter must be identifier"
    %endif

    section %$section

    %assign counter 0
    %rep %$label_count
        %ifidni %$label_%[counter]_identifier, %1
            jmp %$label_%[counter]_address
            %exitrep
        %endif
        %assign counter counter + 1
    %endrep
%endmacro

; =========================
; block
; =========================

%macro block 0
    %ifctx global
        %fatal "block: illegal in global scope"
    %elifctx struct
        %fatal "block: illegal in struct scope"
    %elifctx function
    %elifctx block
        %fatal "block: nested blocks not supported"
    %else
        %fatal "block: invalid context"
    %endif

    %push %??
    %assign depth depth + 1

    %assign %$array_count    0
    %assign %$struct_count   0
    %assign %$function_count 0
    %assign %$label_count    0
    %xdefine %$section %$$section

    %rep %$$array_count
        %xdefine %$array_%[%$array_count]_identifier %$$array_%[%$array_count]_identifier
        %xdefine %$array_%[%$array_count]_address    %$$array_%[%$array_count]_address
        %xdefine %$array_%[%$array_count]_depth      %$$array_%[%$array_count]_depth
        %assign %$array_count %$array_count + 1
    %endrep

    %rep %$$struct_count
        %xdefine %$struct_%[%$struct_count]_identifier %$$struct_%[%$struct_count]_identifier
        %xdefine %$struct_%[%$struct_count]_address    %$$struct_%[%$struct_count]_address
        %xdefine %$struct_%[%$struct_count]_size       %$$struct_%[%$struct_count]_size
        %xdefine %$struct_%[%$struct_count]_depth      %$$struct_%[%$struct_count]_depth
        %assign %$struct_count %$struct_count + 1
    %endrep

    %rep %$$function_count
        %xdefine %$function_%[%$function_count]_identifier %$$function_%[%$function_count]_identifier
        %xdefine %$function_%[%$function_count]_address    %$$function_%[%$function_count]_address
        %assign %$function_count %$function_count + 1
    %endrep

    %rep %$$label_count
        %xdefine %$label_%[%$label_count]_identifier %$$label_%[%$label_count]_identifier
        %xdefine %$label_%[%$label_count]_address    %$$label_%[%$label_count]_address
        %assign %$label_count %$label_count + 1
    %endrep
%endmacro

; =========================
; if / elif / else
; =========================

%macro if 1
    %ifctx global
        %fatal "if: illegal in global scope"
    %elifctx struct
        %fatal "if: illegal in struct scope"
    %elifctx function
    %elifctx block
    %else
        %fatal "if: invalid context"
    %endif

    section %$section
    block
    cmp %1, 0
    jz %$if_not
%endmacro

%macro elif 1
    %ifctx global
        %fatal "elif: illegal in global scope"
    %elifctx struct
        %fatal "elif: illegal in struct scope"
    %elifctx function
    %elifctx block
    %else
        %fatal "elif: invalid context"
    %endif

    section %$section
    end
    block
    cmp %1, 0
    jz %$if_not
%endmacro

%macro else 0
    %ifctx global
        %fatal "else: illegal in global scope"
    %elifctx struct
        %fatal "else: illegal in struct scope"
    %elifctx function
    %elifctx block
    %else
        %fatal "else: invalid context"
    %endif

    end
    block
%endmacro

; =========================
; assign family
; =========================

%macro assign 2
    %ifctx global
        %fatal "assign: illegal in global scope"
    %elifctx struct
        %fatal "assign: illegal in struct scope"
    %elifctx function
    %elifctx block
    %else
        %fatal "assign: invalid context"
    %endif

    %ifnid %1
        %fatal "assign: first parameter must be identifier"
    %endif

    section %$section

    value_to_reg rax, %2
    %assign counter 0
    %rep %$array_count
        %ifidni %$array_%[counter]_identifier, %1
            mov [%$array_%[counter]_address], rax
            %exitrep
        %endif
        %assign counter counter + 1
    %endrep
%endmacro

%macro assign_add 3
    %ifctx global
        %fatal "assign_add: illegal in global scope"
    %elifctx struct
        %fatal "assign_add: illegal in struct scope"
    %elifctx function
    %elifctx block
    %else
        %fatal "assign_add: invalid context"
    %endif

    %ifnid %1
        %fatal "assign_add: first parameter must be identifier"
    %endif

    section %$section
    value_to_reg rax, %2
    value_to_reg rbx, %3
    add rax, rbx
    %assign counter 0
    %rep %$array_count
        %ifidni %$array_%[counter]_identifier, %1
            mov [%$array_%[counter]_address], rax
            %exitrep
        %endif
        %assign counter counter + 1
    %endrep
%endmacro

%macro assign_subtract 3
    %ifctx global
        %fatal "assign_subtract: illegal in global scope"
    %elifctx struct
        %fatal "assign_subtract: illegal in struct scope"
    %elifctx function
    %elifctx block
    %else
        %fatal "assign_subtract: invalid context"
    %endif

    %ifnid %1
        %fatal "assign_subtract: first parameter must be identifier"
    %endif

    section %$section
    value_to_reg rax, %2
    value_to_reg rbx, %3
    sub rax, rbx
    %assign counter 0
    %rep %$array_count
        %ifidni %$array_%[counter]_identifier, %1
            mov [%$array_%[counter]_address], rax
            %exitrep
        %endif
        %assign counter counter + 1
    %endrep
%endmacro

%macro assign_multiply 3
    %ifctx global
        %fatal "assign_multiply: illegal in global scope"
    %elifctx struct
        %fatal "assign_multiply: illegal in struct scope"
    %elifctx function
    %elifctx block
    %else
        %fatal "assign_multiply: invalid context"
    %endif

    %ifnid %1
        %fatal "assign_multiply: first parameter must be identifier"
    %endif

    section %$section
    value_to_reg rax, %2
    value_to_reg rbx, %3
    imul rax, rbx
    %assign counter 0
    %rep %$array_count
        %ifidni %$array_%[counter]_identifier, %1
            mov [%$array_%[counter]_address], rax
            %exitrep
        %endif
        %assign counter counter + 1
    %endrep
%endmacro

%macro assign_if_less_than 3
    %ifctx global
        %fatal "assign_if_less_than: illegal in global scope"
    %elifctx struct
        %fatal "assign_if_less_than: illegal in struct scope"
    %elifctx function
    %elifctx block
    %else
        %fatal "assign_if_less_than: invalid context"
    %endif

    %ifnid %1
        %fatal "assign_if_less_than: first parameter must be identifier"
    %endif

    section %$section
    value_to_reg rax, %2
    value_to_reg rbx, %3
    cmp rax, rbx
    setl al
    movzx rax, al
    %assign counter 0
    %rep %$array_count
        %ifidni %$array_%[counter]_identifier, %1
            mov [%$array_%[counter]_address], rax
            %exitrep
        %endif
        %assign counter counter + 1
    %endrep
%endmacro

%macro assign_if_more_than 3
    %ifctx global
        %fatal "assign_if_more_than: illegal in global scope"
    %elifctx struct
        %fatal "assign_if_more_than: illegal in struct scope"
    %elifctx function
    %elifctx block
    %else
        %fatal "assign_if_more_than: invalid context"
    %endif

    %ifnid %1
        %fatal "assign_if_more_than: first parameter must be identifier"
    %endif

    section %$section
    value_to_reg rax, %2
    value_to_reg rbx, %3
    cmp rax, rbx
    setg al
    movzx rax, al
    %assign counter 0
    %rep %$array_count
        %ifidni %$array_%[counter]_identifier, %1
            mov [%$array_%[counter]_address], rax
            %exitrep
        %endif
        %assign counter counter + 1
    %endrep
%endmacro

%macro assign_if_less_or_equal_than 3
    %ifctx global
        %fatal "assign_if_less_or_equal_than: illegal in global scope"
    %elifctx struct
        %fatal "assign_if_less_or_equal_than: illegal in struct scope"
    %elifctx function
    %elifctx block
    %else
        %fatal "assign_if_less_or_equal_than: invalid context"
    %endif

    %ifnid %1
        %fatal "assign_if_less_or_equal_than: first parameter must be identifier"
    %endif

    section %$section
    value_to_reg rax, %2
    value_to_reg rbx, %3
    cmp rax, rbx
    setle al
    movzx rax, al
    %assign counter 0
    %rep %$array_count
        %ifidni %$array_%[counter]_identifier, %1
            mov [%$array_%[counter]_address], rax
            %exitrep
        %endif
        %assign counter counter + 1
    %endrep
%endmacro

%macro assign_if_more_or_equal_than 3
    %ifctx global
        %fatal "assign_if_more_or_equal_than: illegal in global scope"
    %elifctx struct
        %fatal "assign_if_more_or_equal_than: illegal in struct scope"
    %elifctx function
    %elifctx block
    %else
        %fatal "assign_if_more_or_equal_than: invalid context"
    %endif

    %ifnid %1
        %fatal "assign_if_more_or_equal_than: first parameter must be identifier"
    %endif

    section %$section
    value_to_reg rax, %2
    value_to_reg rbx, %3
    cmp rax, rbx
    setge al
    movzx rax, al
    %assign counter 0
    %rep %$array_count
        %ifidni %$array_%[counter]_identifier, %1
            mov [%$array_%[counter]_address], rax
            %exitrep
        %endif
        %assign counter counter + 1
    %endrep
%endmacro

%macro assign_if_equal 3
    %ifctx global
        %fatal "assign_if_equal: illegal in global scope"
    %elifctx struct
        %fatal "assign_if_equal: illegal in struct scope"
    %elifctx function
    %elifctx block
    %else
        %fatal "assign_if_equal: invalid context"
    %endif

    %ifnid %1
        %fatal "assign_if_equal: first parameter must be identifier"
    %endif

    section %$section
    value_to_reg rax, %2
    value_to_reg rbx, %3
    cmp rax, rbx
    sete al
    movzx rax, al
    %assign counter 0
    %rep %$array_count
        %ifidni %$array_%[counter]_identifier, %1
            mov [%$array_%[counter]_address], rax
            %exitrep
        %endif
        %assign counter counter + 1
    %endrep
%endmacro

%macro assign_if_not_equal 3
    %ifctx global
        %fatal "assign_if_not_equal: illegal in global scope"
    %elifctx struct
        %fatal "assign_if_not_equal: illegal in struct scope"
    %elifctx function
    %elifctx block
    %else
        %fatal "assign_if_not_equal: invalid context"
    %endif

    %ifnid %1
        %fatal "assign_if_not_equal: first parameter must be identifier"
    %endif

    section %$section
    value_to_reg rax, %2
    value_to_reg rbx, %3
    cmp rax, rbx
    setne al
    movzx rax, al
    %assign counter 0
    %rep %$array_count
        %ifidni %$array_%[counter]_identifier, %1
            mov [%$array_%[counter]_address], rax
            %exitrep
        %endif
        %assign counter counter + 1
    %endrep
%endmacro

; =========================
; asm
; =========================

%macro asm 1
    %ifctx global
        %fatal "asm: illegal in global scope"
    %elifctx struct
        %fatal "asm: illegal in struct scope"
    %elifctx function
    %elifctx block
    %else
        %fatal "asm: invalid context"
    %endif

    %ifnum %1
        %fatal "asm: argument must be string literal"
    %elifstr %1
    %elifid %1
        %fatal "asm: argument must be string literal, not identifier"
    %else
        %fatal "asm: invalid argument"
    %endif

    %tok(%1)
%endmacro

; =========================
; assign_sizeof
; =========================

%macro assign_sizeof 2
    %ifctx global
        %fatal "assign_sizeof: illegal in global scope"
    %elifctx struct
        %fatal "assign_sizeof: illegal in struct scope"
    %elifctx function
    %elifctx block
    %else
        %fatal "assign_sizeof: invalid context"
    %endif

    %ifnid %1
        %fatal "assign_sizeof: first parameter must be identifier"
    %endif

    section %$section

    ; get sizeof(struct)
    %ifdef sizeof_%2
        mov rax, sizeof_%2
    %else
        %fatal "assign_sizeof: unknown struct"
    %endif

    ; store into array %1
    %assign counter 0
    %rep %$array_count
        %ifidni %$array_%[counter]_identifier, %1
            mov [%$array_%[counter]_address], rax
            %exitrep
        %endif
        %assign counter counter + 1
    %endrep
%endmacro

; =========================
; end – scope close, protected tables
; =========================

%macro end 0-*
    %ifctx global
        %fatal "end: illegal in global scope"
    %elifctx struct
        ; Freeze sizeof for this struct
        %xdefine sizeof_%$struct_name %$size

        ; Leave struct scope
        %pop
        %assign depth depth - 1

        ; Instantiate arrays of this struct in parent scope
        %rep %0
            %ifnid %1
                %fatal "end: instance name must be identifier"
            %endif
            array %1, sizeof_%$struct_name
            %rotate 1
        %endrep

    %elifctx function
        return
        %pop
        %assign depth depth - 1

    %elifctx block
        section %$section
        %$if_not:
        %pop
        %assign depth depth - 1

    %else
        %fatal "end: invalid context"
    %endif
%endmacro
