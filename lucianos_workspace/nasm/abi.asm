
;
;%macro include 1-*
;	%ifnctx global
;		%fatal
;	%endif
;	%rep %0
;		%include %1
;		%rotate 1
;	%endrep
;%endmacro
;%macro namespace 1-*
;	%push %??
;	%xdefine %$access_type private
;	%rotate 1
;	%rep %0
;		;
;		%rotate 1
;	%endrep
;%endmacro
;%macro public 0
;	%ifnctx namespace
;		%fatal 
;	%endif
;	%xdefine %$access_type %??
;%endmacro
;%macro protected 0
;	%ifnctx namespace
;		%fatal
;	%endif
;	%xdefine %$access_type %??
;%endmacro
;%macro private 0
;	%ifnctx namespace
;		%fatal
;	%endif
;	%xdefine %$access_type %??
;%endmacro
;%macro static 0
;	%ifctx struct
;		%fatal
;	%endif
;%endmacro




; scopes: global, function, struct
%push global

var 3, a, b, c

struct gisdhkh
	var 8, dsjfbusydg
	var 1, ufgisdgf
end

function fdsfkhs
	var 8, hfbksdhjf
	var 7, khvsfjkhd
end

%macro function 1-*
	%ifctx struct
		%fatal
	%elifctx function
		%fatal
	%endif

	%push %??
	[section .text]
%endmacro

%macro return 0
	%ifnctx function
		%fatal
	%endif

	ret
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

%macro var 1-*
	%ifctx global
		%rep %0
			[section .data]
			%1: times
			%rotate 1
		%endrep
	%elifctx function
		%rep %0
			%rotate 1
		%endrep
	%elifctx struct
		%rep %0
			.resq %1
			%rotate 1
		%endrep
	%else
		%fatal
	%endrep
%endmacro

%macro struct 1
	%push %??

	struc %1
%endmacro

%macro assign 1
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

a->b.c->d
immediate b.c->d->e->f
assign g;

%macro if 0
	%push function
%endmacro
%macro then 0
	%pop
	%push function
%endmacro
%macro elif 0
	%pop
	%push function
%endmacro
%macro else 0
	%pop
	%push function
%endmacro
%macro while 0
	%push function
%endmacro
%macro do 0
	%push function
%endmacro
%macro end 0-*
	%pop
%endmacro
%macro asm 1-*
	%rep %0
		%1
		%rotate 1
	%endrep
%endmacro
