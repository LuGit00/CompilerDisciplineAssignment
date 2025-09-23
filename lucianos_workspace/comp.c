#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <assert.h>

static uint8_t *parse(register uint8_t*);

void main(register uint64_t argc, register uint8_t **argv)
{
	assert(argv);
	register enum:uint8_t
	{
		default_parameter_state,
		output_parameter_state
	}parameter_state=default_parameter_state;
	register uint64_t input_files_count=0;
	register uint64_t *input_files=NULL;
	register uint8_t *output_filename=NULL;
	for(register uint64_t argument_index=1; argument_index<argc; argument_index++)
		switch(parameter_state)
		{
		case default_parameter_state:
			if(!strcmp(argv[argument_index], "-o"))
				if(output_filename)
				{
					assert(puts("ERROR: Output file already set.")!=EOF);
					exit(1);
				}
				else if((argument_index+1)>=argc)
				{
					assert(puts("ERROR: Expected output file after -o.")!=EOF);
					exit(1);
				}
				else
				{
					parameter_state=output_parameter_state;
					continue;
				}
			assert(++input_files_count);
			assert(input_files=realloc(input_files, input_files_count*sizeof(uint64_t)));
			input_files[input_files_count-1]=argument_index;
			break;
		case output_parameter_state:
			output_filename=argv[argument_index];
			parameter_state=default_parameter_state;
			break;
		default: assert(NULL);
		}
	if(!input_files_count)
	{
		assert(puts("ERROR: No input file provided.")!=EOF);
		exit(1);
	}
	auto void relay(register uint8_t *input_filename)
	{
		assert(input_filename);
		register FILE *file;
		assert(file=fopen(input_filename, "r"));
		assert(!fseek(file, 0, SEEK_END));
		register uint64_t input_file_size=0;
		assert((input_file_size=ftell(file))!=-1L);
		assert(!fseek(file, 0, SEEK_SET));
		auto uint8_t input_file_string[++input_file_size];
		input_file_string[fread(input_file_string, sizeof(uint8_t), input_file_size-1, file)]='\0';
		assert(fclose(file)!=EOF);
		assert(file=fopen(output_filename, "w"));
		register uint8_t *output_file_string;
		assert(output_file_string=parse(input_file_string));
		register uint64_t output_file_string_size;
		assert(fwrite(output_file_string, sizeof(uint8_t), output_file_string_size=strlen(output_file_string), file)>=output_file_string_size);
		assert(fclose(file)!=EOF);
		free(output_file_string);
	}
	if(output_filename)
	{
		if(input_files_count>1)
		{
			assert(puts("ERROR: Cannot use '-o' with multiple input files.")!=EOF);
			exit(1);
		}
		assert(input_files);
		relay(argv[input_files[0]]);
		return;
	}
	for(register uint64_t input_file_index=0; input_file_index<input_files_count; input_file_index++)
	{
		register uint8_t *input_filename;
		register uint64_t output_filename_size;
		assert(input_files);
		assert(output_filename=malloc((output_filename_size=strlen(input_filename=argv[input_files[input_file_index]])+5)*sizeof(uint8_t)));
		output_filename[snprintf(output_filename, output_filename_size, "%s.asm", input_filename)]='\0';
		relay(input_filename);
		free(output_filename);
	}
}

static uint8_t *parse(register uint8_t *language_input)
{
	assert(language_input);
	register enum:bool
	{
		whitespace_character_state,
		nonwhitespace_character_state
	}character_state=whitespace_character_state;
	register uint64_t token_count=0;
	register uint8_t **tokens=NULL;
	register uint64_t token_buffer_size;
	register uint8_t *token_buffer;
	auto void tokens_push(void)
	{
		assert(++token_buffer_size);
		assert(token_buffer=realloc(token_buffer, token_buffer_size*sizeof(uint8_t)));
		token_buffer[token_buffer_size-1]='\0';
		assert(++token_count);
		assert(tokens=realloc(tokens, token_count*sizeof(uint8_t*)));
		tokens[token_count-1]=token_buffer;
	}
	for(register uint64_t character_index=0, language_input_size=strlen(language_input); character_index<language_input_size; character_index++)
		if(character_state)	switch(language_input[character_index])
		{
		case ' ':
		case '\t':
		case '\n':
		case '\r':
			tokens_push();
			character_state=whitespace_character_state;
			break;
		default:
			assert(++token_buffer_size);
			assert(token_buffer=realloc(token_buffer, token_buffer_size*sizeof(uint8_t)));
			token_buffer[token_buffer_size-1]=language_input[character_index];
		}
		else switch(language_input[character_index])
		{
		case ' ':
		case '\t':
		case '\n':
		case '\r':
			break;
		default:
			token_buffer_size=1;
			assert(token_buffer=malloc(sizeof(uint8_t)));
			token_buffer[0]=language_input[character_index];
			character_state=nonwhitespace_character_state;
		}
	if(character_state) tokens_push();
	puts("STARTING:\n");
	for(register uint64_t token_index=0; token_index<token_count; token_index++)
		printf("TOKEN %lu(%lu/%hhu): %s\n", token_index, strlen(tokens[token_index]), tokens[token_index][0], tokens[token_index]);
	puts("\nENDING\n\n\n");
	return NULL;
}