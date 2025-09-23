%ifndef pass.0
%xdefine pass.0

%assign pass.0.macros.count 0

%elifndef pass.1
%xdefine pass.1

%assign pass.1.macros.count 0

%assign counter 0
%rep %[pass.0.macros.count]
	%ifidni %[pass.0.macros.%[counter]],
	%else
		%fatal "Unknown token at pass 0."
	%endif
	%undef pass.0.macros.%[counter]
	%assign counter %[counter] + 1
%endrep
%undef counter
%undef pass.0.macros.count

%endmacro