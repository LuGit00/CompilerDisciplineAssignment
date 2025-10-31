/*
 * Parser
 * Copyright (C) 2025 by Luciano Alves do Brasil Schindel Machado
 * 
 * This file is shared publicly.
 * No license is granted.
 * Everything but discredit shall be permitted, use it at your own risk.
 *
 * This file is compilable and includable in the GCC C23 language.
 * This file provides a convenient way to parse a lisp language.
 * Compilation example: $ gcc -std=c23 -DTEST parser.c -o parser
 *						$ ./parser
 *
 */
#ifndef __GNUC__
#error GCC required.
#elif __STDC_VERSION__ < 202000L
#error Version >= 202000L required.
#elif __INCLUDE_LEVEL__ == 1 // FILE INTERFACE (HEADER)
#elif __INCLUDE_LEVEL__ == 0 // FILE INTERFACE IMPLEMENTATION (SOURCE)

#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <setjmp.h>
#include <stdint.h>
#include <assert.h>

#include <pthread.h>

static enum:uint8_t{ UNDEFINED_COMPILER_MODE, INTERPRET, X86, COMMODORE64_BASED, C }compiler_mode;
static void *translate(register void*);

uint8_t main(register uint64_t argc, register uint8_t **argv)
{
	assert(argc>1);
	assert(argv);
	register uint8_t *output=NULL;
	register uint64_t input_count=0;
	register uint64_t *inputs=NULL;
	for(register uint64_t argument_index=1; argument_index<argc; argument_index++)
		if(!strcmp(argv[argument_index], "-o"))
		{
			assert((++argument_index)<argc);
			assert(!output);
			assert(input_count<2);
			output=argv[argument_index];
		}
		else if(!strcmp(argv[argument_index], "-target"))
		{
			assert(!compiler_mode);
			assert((++argument_index)<argc);
			if(!strcmp(argv[argument_index], "-interpret"))
				compiler_mode=INTERPRET;
			else if(!strcmp(argv[argument_index], "-x86"))
				compiler_mode=X86;
			else if(!strcmp(argv[argument_index], "-commodore64_based"))
				compiler_mode=COMMODORE64_BASED;
			else if(!strcmp(argv[argument_index], "-c"))
				compiler_mode=C;
			else assert(NULL);
		}
		else
		{
			assert(++input_count);
			assert(inputs=realloc(inputs, input_count*sizeof(uint64_t)));
			inputs[input_count-1]=argument_index;
		}
	for(register uint64_t input_index0=0; input_index0<input_count; input_index0++)
		for(register uint64_t input_index1=input_index0+1; input_index1<input_count; input_index1++)
			assert(strcmp(argv[inputs[input_index0]], argv[inputs[input_index1]]));
	auto pthread_t threads[input_count];
	for(register uint64_t input_index=0; input_index<input_count; input_index++)
		assert(!pthread_create(&threads[input_index], NULL, translate, argv[inputs[input_index]]));
	for(register uint64_t input_index=0; input_index<input_count; input_index++)
		assert(!pthread_join(threads[input_index], NULL));
	return 0;
}

static void *translate(register void *filename)
{
	auto struct tokens
	{
		uint64_t token_count;
		uint8_t **tokens;
	}*tokenize(register uint8_t*);
	assert(filename);
	register struct tokens *preprocessed_tokens=tokenize(filename);
	{
		register uint8_t *main_directory=NULL;
		{
			register uint8_t *last_slash=NULL;
			for(register uint8_t *character_index=filename; *character_index; character_index++)
				if(*character_index=='/')
					last_slash=character_index;
			if(last_slash)
			{
				register uint8_t byte_buffer;
				assert(byte_buffer=*(last_slash+1));
				*(last_slash+1)='\0';
				assert(main_directory=strdup(filename));
				*(last_slash+1)=byte_buffer;
			}
		}
		register struct tokens *processed_tokens;
		assert(processed_tokens=calloc(1, sizeof(struct tokens)));
		for(register bool if_preprocessor_needed=true; if_preprocessor_needed;)
		{
			if_preprocessor_needed=false;
			for(register uint64_t token_index=0; token_index<preprocessed_tokens->token_count; token_index++)
				if(!strcmp(preprocessed_tokens->tokens[token_index], "include"))
				{
					if_preprocessor_needed=true;
					assert((++token_index)<preprocessed_tokens->token_count);
					register uint64_t string_buffer_size;
					register struct tokens *sub_preprocessed_tokens;
					if(main_directory)
					{
						auto uint8_t string_buffer[string_buffer_size=strlen(main_directory)+strlen(preprocessed_tokens->tokens[token_index])+2];
						string_buffer[snprintf(string_buffer, (string_buffer_size-1)*sizeof(uint8_t), "%s%s", main_directory, preprocessed_tokens->tokens[token_index])]='\0';
						sub_preprocessed_tokens=tokenize(string_buffer);
					}
					else sub_preprocessed_tokens=tokenize(preprocessed_tokens->tokens[token_index]);
					for(register uint64_t token_index_aux=0; token_index_aux<sub_preprocessed_tokens->token_count; token_index_aux++)
					{
						assert(++processed_tokens->token_count);
						assert(processed_tokens->tokens=realloc(processed_tokens->tokens, processed_tokens->token_count*sizeof(uint8_t*)));
						processed_tokens->tokens[processed_tokens->token_count-1]=sub_preprocessed_tokens->tokens[token_index_aux];
					}
					free(sub_preprocessed_tokens->tokens);
					free(sub_preprocessed_tokens);
				}
				else
				{
					assert(++processed_tokens->token_count);
					assert(processed_tokens->tokens=realloc(processed_tokens->tokens, processed_tokens->token_count*sizeof(uint8_t*)));
					processed_tokens->tokens[processed_tokens->token_count-1]=preprocessed_tokens->tokens[token_index];
				}
			free(preprocessed_tokens->tokens);
			free(preprocessed_tokens);
			preprocessed_tokens=processed_tokens;
			assert(processed_tokens=calloc(1, sizeof(struct tokens)));
		}
		free(processed_tokens);
	}
	register uint64_t section_offset;
	register uint64_t section_count=0;
	register uint8_t **sections;
	assert(sections=calloc(3, sizeof(uint8_t*)));
	assert(sections[0]=calloc(1, sizeof(uint8_t))); // .rodata
	assert(sections[1]=calloc(1, sizeof(uint8_t))); // .bss
	assert(sections[2]=calloc(1, sizeof(uint8_t))); // .data
	register struct scope
	{
		enum:uint8_t{ UNDEFINED_SCOPE_TYPE, GLOBAL_SCOPE_TYPE, BLOCK_SCOPE_TYPE, FUNCTION_SCOPE_TYPE, STRUCT_SCOPE_TYPE }scope_type;
		enum meta_type:uint8_t{ UNDEFINED_META_TYPE, VARIABLE_META_TYPE, FUNCTION_META_TYPE, LABEL_META_TYPE, STRUCT_META_TYPE }meta_type;
		enum storage_class:uint8_t{ UNDEFINED_STORAGE_CLASS, REGISTER_STORAGE_CLASS, AUTO_STORAGE_CLASS, STATIC_STORAGE_CLASS }storage_class;
		uint64_t symbol_count;
		struct symbol
		{
			enum meta_type meta_type;
			enum storage_class storage_class;
			uint8_t *identifier;
		}**symbols;
		struct scope *previous;
	}*global_scope, *current_scope;
	assert(global_scope=current_scope=calloc(1, sizeof(struct scope)));
	global_scope->scope_type=GLOBAL_SCOPE_TYPE;
	for(register uint64_t token_index=0; token_index<preprocessed_tokens->token_count; token_index++)
		if(!strcmp(preprocessed_tokens->tokens[token_index], "register"))
		{
			switch(current_scope->scope_type)
			{
			case BLOCK_SCOPE_TYPE:
			case FUNCTION_SCOPE_TYPE:
				break;
			case UNDEFINED_SCOPE_TYPE:
			case GLOBAL_SCOPE_TYPE:
			case STRUCT_SCOPE_TYPE:
			default: assert(NULL);
			}
			switch(current_scope->storage_class)
			{
			case UNDEFINED_STORAGE_CLASS:
				break;
			case REGISTER_STORAGE_CLASS:
			case AUTO_STORAGE_CLASS:
			case STATIC_STORAGE_CLASS:
			default: assert(NULL);
			}
			switch(current_scope->meta_type)
			{
			case UNDEFINED_META_TYPE:
			case VARIABLE_META_TYPE:
				break;
			case FUNCTION_META_TYPE:
			case LABEL_META_TYPE:
			case STRUCT_META_TYPE:
			default: assert(NULL);
			}
			current_scope->storage_class=REGISTER;
		}
		else if(!strcmp(preprocessed_tokens->tokens[token_index], "auto"))
		{
			switch(current_scope->scope_type)
			{
			case BLOCK_SCOPE_TYPE:
			case FUNCTION_SCOPE_TYPE:
				break;
			case UNDEFINED_SCOPE_TYPE:
			case GLOBAL_SCOPE_TYPE:
			case STRUCT_SCOPE_TYPE:
			default: assert(NULL);
			}
			switch(current_scope->storage_class)
			{
			case UNDEFINED_STORAGE_CLASS:
				break;
			case REGISTER_STORAGE_CLASS:
			case AUTO_STORAGE_CLASS:
			case STATIC_STORAGE_CLASS:
			default: assert(NULL);
			}
			switch(current_scope->meta_type)
			{
			case UNDEFINED_META_TYPE:
			case VARIABLE_META_TYPE:
				break;
			case FUNCTION_META_TYPE:
			case LABEL_META_TYPE:
			case STRUCT_META_TYPE:
			default: assert(NULL);
			}
			current_scope->storage_class=AUTO;
		}
		else if(!strcmp(preprocessed_tokens->tokens[token_index], "static"))
		{
			switch(current_scope->scope_type)
			{
			case GLOBAL_SCOPE_TYPE:
			case BLOCK_SCOPE_TYPE:
			case FUNCTION_SCOPE_TYPE:
				break;
			case UNDEFINED_SCOPE_TYPE:
			case STRUCT_SCOPE_TYPE:
			default: assert(NULL);
			}
			switch(current_scope->storage_class)
			{
			case UNDEFINED_STORAGE_CLASS:
				break;
			case REGISTER_STORAGE_CLASS:
			case AUTO_STORAGE_CLASS:
			case STATIC_STORAGE_CLASS:
			default: assert(NULL);
			}
			switch(current_scope->meta_type)
			{
			case UNDEFINED_META_TYPE:
			case VARIABLE_META_TYPE:
			case FUNCTION_META_TYPE:
			case STRUCT_META_TYPE:
				break;
			case LABEL_META_TYPE:
			default: assert(NULL);
			}
			current_scope->storage_class=STATIC_STORAGE_CLASS;
		}
		else if(!strcmp(preprocessed_tokens->tokens[token_index], "variable"))
		{
			switch(current_scope->scope_type)
			{
			case GLOBAL_SCOPE_TYPE:
			case BLOCK_SCOPE_TYPE:
			case FUNCTION_SCOPE_TYPE:
			case STRUCT_SCOPE_TYPE:
				break;
			case UNDEFINED_SCOPE_TYPE:
			default: assert(NULL);
			}
			switch(current_scope->storage_class)
			{
			case UNDEFINED_STORAGE_CLASS:
			case REGISTER_STORAGE_CLASS:
			case AUTO_STORAGE_CLASS:
			case STATIC_STORAGE_CLASS:
				break;
			default: assert(NULL);
			}
			switch(current_scope->meta_type)
			{
			case UNDEFINED_META_TYPE:
				break;
			case VARIABLE_META_TYPE:
			case FUNCTION_META_TYPE:
			case STRUCT_META_TYPE:
			case LABEL_META_TYPE:
			default: assert(NULL);
			}
			current_scope->meta_type=VARIABLE_META_TYPE;
		}
		else if(!strcmp(preprocessed_tokens->tokens[token_index], "function"))
		{
			switch(current_scope->scope_type)
			{
			case GLOBAL_SCOPE_TYPE:
			case BLOCK_SCOPE_TYPE:
			case FUNCTION_SCOPE_TYPE:
			case STRUCT_SCOPE_TYPE:
				break;
			case UNDEFINED_SCOPE_TYPE:
			default: assert(NULL);
			}
			switch(current_scope->storage_class)
			{
			case UNDEFINED_STORAGE_CLASS:
			case STATIC_STORAGE_CLASS:
				break;
			case REGISTER_STORAGE_CLASS:
			case AUTO_STORAGE_CLASS:
			default: assert(NULL);
			}
			switch(current_scope->meta_type)
			{
			case UNDEFINED_META_TYPE:
				break;
			case VARIABLE_META_TYPE:
			case FUNCTION_META_TYPE:
			case STRUCT_META_TYPE:
			case LABEL_META_TYPE:
			default: assert(NULL);
			}
			current_scope->meta_type=FUNCTION_META_TYPE;
		}
		else if(!strcmp(preprocessed_tokens->tokens[token_index], "struct"))
		{
			switch(current_scope->scope_type)
			{
			case GLOBAL_SCOPE_TYPE:
			case BLOCK_SCOPE_TYPE:
			case FUNCTION_SCOPE_TYPE:
			case STRUCT_SCOPE_TYPE:
				break;
			case UNDEFINED_SCOPE_TYPE:
			default: assert(NULL);
			}
			switch(current_scope->storage_class)
			{
			case UNDEFINED_STORAGE_CLASS:
			case AUTO_STORAGE_CLASS:
			case STATIC_STORAGE_CLASS:
				break;
			case REGISTER_STORAGE_CLASS:
			default: assert(NULL);
			}
			switch(current_scope->meta_type)
			{
			case UNDEFINED_META_TYPE:
				break;
			case VARIABLE_META_TYPE:
			case FUNCTION_META_TYPE:
			case STRUCT_META_TYPE:
			case LABEL_META_TYPE:
			default: assert(NULL);
			}
			current_scope->meta_type=STRUCT_META_TYPE;
		}
		else if(!strcmp(preprocessed_tokens->tokens[token_index], "declare"))
		{
			switch(current_scope->scope_type)
			{
			case GLOBAL_SCOPE_TYPE:
			case BLOCK_SCOPE_TYPE:
			case FUNCTION_SCOPE_TYPE:
			case STRUCT_SCOPE_TYPE:
				break;
			case UNDEFINED_SCOPE_TYPE:
			default: assert(NULL);
			}
			switch(current_scope->storage_class)
			{
			case UNDEFINED_STORAGE_CLASS:
				current_scope->storage_class=AUTO;
			case AUTO_STORAGE_CLASS:
			case STATIC_STORAGE_CLASS:
			case REGISTER_STORAGE_CLASS:
				break;
			default: assert(NULL);
			}
			switch(current_scope->meta_type)
			{
			case VARIABLE_META_TYPE:
			case FUNCTION_META_TYPE:
			case STRUCT_META_TYPE:
			case LABEL_META_TYPE:
				break;
			case UNDEFINED_META_TYPE:
			default: assert(NULL);
			}

			register uint8_t *op0;
			assert(op0=preprocessed_tokens->tokens[++token_index]);

			register uint64_t op0_size;
			assert(op0_size=strlen(op0));

			if(isdigit(op0[0]))
				assert(NULL);
			else if(islower(op0[0])||isupper(op0[0])||(op0[0]=='_')||(op0[0]=='.'))
			{
				for(register uint64_t character_index=1; character_index<op0_size; character_index++)
					assert(isdigit(op0[character_index])||islower(op0[character_index])||isupper(op0[character_index])||(op0[character_index]=='_')||(op0[character_index]=='.'));
				for(register uint64_t symbol_index=0; symbol_index<current_scope->symbol_count; symbol_index++)
					assert(strcmp(op0, current_scope->symbols[symbol_index]->identifier));

				assert(++current_scope->symbol_count);
				assert(current_scope->symbols=realloc(current_scope->symbols, current_scope->symbol_count*sizeof(struct symbol*)));
				register struct symbol *symbol_buffer;
				assert(symbol_buffer=current_scope->symbols[current_scope->symbol_count-1]=calloc(1, sizeof(struct symbol)));
				symbol_buffer->meta_type=current_scope->meta_type;
				symbol_buffer->storage_class=current_scope->storage_class;
				symbol_buffer->identifier=op0;
				current_scope->meta_type=UNDEFINED_META_TYPE;
				current_scope->storage_class=UNDEFINED_STORAGE_CLASS;
			}
			else if(op0[0]=='\"')
				assert(NULL);
			else assert(NULL);
		}
		else if(!strcmp(preprocessed_tokens->tokens[token_index], "assign"))
		{
			switch(current_scope->scope_type)
			{
			case BLOCK_SCOPE_TYPE:
			case FUNCTION_SCOPE_TYPE:
				break;
			case UNDEFINED_SCOPE_TYPE:
			case GLOBAL_SCOPE_TYPE:
			case STRUCT_SCOPE_TYPE:
			default: assert(NULL);
			}

			register uint8_t *op0, *op1;
			assert(op0=preprocessed_tokens->tokens[++token_index]);
			assert(op1=preprocessed_tokens->tokens[++token_index]);

			register uint64_t op0_size, op1_size;
			assert(op0_size=strlen(op0));
			assert(op1_size=strlen(op1));

			if(isdigit(op0[0]))
				assert(NULL);
			else if(islower(op0[0])||isupper(op0[0])||(op0[0]=='_')||(op0[0]=='.'))
			{
				for(register uint64_t character_index=1; character_index<op0_size; character_index++)
					assert(isdigit(op0[character_index])||islower(op0[character_index])||isupper(op0[character_index])||(op0[character_index]=='_')||(op0[character_index]=='.'));
				for(register uint64_t symbol_index=0; symbol_index<current_scope->symbol_count; symbol_index++)
					assert(strcmp(op0, current_scope->symbols[symbol_index]->identifier));
			}
			else if(op0[0]=='\"')
				assert(NULL);
			else assert(NULL);

			if(isdigit(op1[0]))
			{
				for(register uint64_t character_index=1; character_index<op1_size; character_index++)
					assert(isdigit(op1[character_index])||islower(op1[character_index])||isupper(op1[character_index])||(op1[character_index]=='_')||(op1[character_index]=='.'));
				auto uint8_t string_buffer[16];
				string_buffer[snprintf(string_buffer, sizeof(string_buffer), "\tmov %s, %llu", op0, atoll(op1))]='\0';
			}
			else if(islower(op1[0])||isupper(op1[0])||(op1[0]=='_')||(op1[0]=='.'))
			{
				for(register uint64_t character_index=1; character_index<op1_size; character_index++)
					assert(isdigit(op1[character_index])||islower(op1[character_index])||isupper(op1[character_index])||(op1[character_index]=='_')||(op1[character_index]=='.'));
				for(register uint64_t symbol_index=0; symbol_index<current_scope->symbol_count; symbol_index++)
					assert(strcmp(op1, current_scope->symbols[symbol_index]->identifier));
				auto uint8_t string_buffer[16];
				string_buffer[snprintf(string_buffer, sizeof(string_buffer), "\tmov %s, %s", op0, op1)]='\0';
			}
			else if(op1[0]=='\"')
				assert(NULL);
			else assert(NULL);
		}
		else assert(NULL);
	return NULL;

	auto struct tokens *tokenize(register uint8_t *filename)
	{
		assert(filename);
		register FILE *file;
		assert(file=fopen(filename, "r"));
		register uint64_t file_size;
		assert(!fseek(file, 0, SEEK_END));
		assert((file_size=ftell(file))!=-1L);
		assert(!fseek(file, 0, SEEK_SET));
		auto uint8_t file_string[file_size+1];
		file_string[fread(file_string, sizeof(uint8_t), file_size, file)]='\0';
		assert(fclose(file)!=EOF);

		register struct tokens *tokens_buffer;
		assert(tokens_buffer=calloc(1, sizeof(struct tokens)));
		register uint64_t string_buffer_size=0;
		register uint8_t *string_buffer=NULL;

		for(register uint64_t character_index=0; character_index<file_size; character_index++)
			switch(file_string[character_index])
			{
			case ' ':
			case '\t':
			case '\n':
			case '\r':
				if(string_buffer_size)
				{
					assert(++string_buffer_size);
					assert(string_buffer=realloc(string_buffer, string_buffer_size*sizeof(uint8_t)));
					string_buffer[string_buffer_size-1]='\0';
					assert(++tokens_buffer->token_count);
					assert(tokens_buffer->tokens=realloc(tokens_buffer->tokens, tokens_buffer->token_count*sizeof(uint8_t*)));
					tokens_buffer->tokens[tokens_buffer->token_count-1]=string_buffer;
					string_buffer_size=0;
					string_buffer=NULL;
				}
				break;
			case '\'':
			case '\"':
				if(string_buffer_size)
				{
					assert(++string_buffer_size);
					assert(string_buffer=realloc(string_buffer, string_buffer_size*sizeof(uint8_t)));
					string_buffer[string_buffer_size-1]='\0';
					assert(++tokens_buffer->token_count);
					assert(tokens_buffer->tokens=realloc(tokens_buffer->tokens, tokens_buffer->token_count*sizeof(uint8_t*)));
					tokens_buffer->tokens[tokens_buffer->token_count-1]=string_buffer;
					string_buffer_size=0;
					string_buffer=NULL;
				}
				assert(++string_buffer_size);
				assert(string_buffer=realloc(string_buffer, string_buffer_size*sizeof(uint8_t)));
				string_buffer[string_buffer_size-1]=file_string[character_index];
				for(character_index++; character_index<file_size; character_index++)
					if(file_string[character_index]==string_buffer[0])
					{
						assert(++string_buffer_size);
						assert(string_buffer=realloc(string_buffer, string_buffer_size*sizeof(uint8_t)));
						string_buffer[string_buffer_size-1]=file_string[character_index];
						assert(++string_buffer_size);
						assert(string_buffer=realloc(string_buffer, string_buffer_size*sizeof(uint8_t)));
						string_buffer[string_buffer_size-1]='\0';
						assert(++tokens_buffer->token_count);
						assert(tokens_buffer->tokens=realloc(tokens_buffer->tokens, tokens_buffer->token_count*sizeof(uint8_t*)));
						tokens_buffer->tokens[tokens_buffer->token_count-1]=string_buffer;
						string_buffer_size=0;
						string_buffer=NULL;
						break;
					}
					else if(file_string[character_index]=='\\')
					{
						assert((++character_index)<file_size);
						assert(++string_buffer_size);
						assert(string_buffer=realloc(string_buffer, string_buffer_size*sizeof(uint8_t)));
						switch(file_string[character_index])
						{
						case '0': string_buffer[string_buffer_size-1]='\0'; break;
						case 't': string_buffer[string_buffer_size-1]='\t'; break;
						case 'n': string_buffer[string_buffer_size-1]='\n'; break;
						case 'r': string_buffer[string_buffer_size-1]='\r'; break;
						case '\'': string_buffer[string_buffer_size-1]='\''; break;
						case '\"': string_buffer[string_buffer_size-1]='\"'; break;
						default:
							string_buffer[string_buffer_size-1]='\\';
							assert(++string_buffer_size);
							assert(string_buffer=realloc(string_buffer, string_buffer_size*sizeof(uint8_t)));
							string_buffer[string_buffer_size-1]=file_string[character_index];
						}
					}
					else
					{
						assert(++string_buffer_size);
						assert(string_buffer=realloc(string_buffer, string_buffer_size*sizeof(uint8_t)));
						string_buffer[string_buffer_size-1]=file_string[character_index];
					}
				break;
			case '\0':
			default:
				assert(++string_buffer_size);
				assert(string_buffer=realloc(string_buffer, string_buffer_size*sizeof(uint8_t)));
				string_buffer[string_buffer_size-1]=file_string[character_index];
			}
		if(string_buffer_size)
		{
			assert(++string_buffer_size);
			assert(string_buffer=realloc(string_buffer, string_buffer_size*sizeof(uint8_t)));
			string_buffer[string_buffer_size-1]='\0';
			assert(++tokens_buffer->token_count);
			assert(tokens_buffer->tokens=realloc(tokens_buffer->tokens, tokens_buffer->token_count*sizeof(uint8_t*)));
			tokens_buffer->tokens[tokens_buffer->token_count-1]=string_buffer;
		}
		return tokens_buffer;
	}
}

#endif//#if __INCLUDE_LEVEL__ == 0

/*
<global_struct_declaration> ::= 'struct' ( <function_parameter_declarations> 'declare' <identifier> | <function_parameter_declarations> 'declare_assign' <identifier> <function_statements> 'end' )
<global_function_declaration> ::= 'function' ( <function_parameter_declarations> 'declare' <identifier> | <function_parameter_declarations> 'declare_assign' <identifier> <function_statements> 'end' )
<global_variable_declaration> ::= 'variable' ( 'declare' <identifier> | 'declare_assign' <identifier> ( <identifier> | <integer> | <string> ) )
<global_declaration> ::= ( 'static' | empty ) ( <global_variable_declaration> | <global_function_declaration> | <global_struct_declaration> )
<program> ::= <global_declaration> ( <program> | empty )
*/