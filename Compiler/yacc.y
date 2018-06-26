%{
	/*void yyerror (char *s);*/

	/* C declarations used in actions*/
	#include <stdio.h>
	#include <stdlib.h>
	#include "nodes.h"
%}

%token SEMICOLON COLON COMMA OPEN_CURLY_BRACES CLOSE_CURLY_BRACES LESS_THAN GREATER_THAN OPEN_PARENTHESES CLOSE_PARENTHESES OPEN_BRACKET CLOSE_BRACKET
%token PLUS MINUS MULTIPLY DIVIDE MOD EQUAL NUMERAL NOT_EQUAL GREATER_OR_EQUAL LESS_OR_EQUAL AND OR
%token RETURN DEFINE FOR WHILE IF ELSE ELSE_IF MAIN

%token BOOLEAN
%token INTEGER
%token NAME
%token STRING

%start Program

%left PLUS MINUS MULTIPLY DIVIDE MOD
%left EQUAL NOT_EQUAL GREATER_OR_EQUAL GREATER_THAN LESS_THAN LESS_OR_EQUAL
%left OR AND

/* Descriptions of expected inputs corresponding actions (in C)*/
%%

Program: Defines Functions  {$$ = new_program_node($1, $2); }

Defines: Define Defines  { $$ = new_defines_node($1, $2); }
        | /* empty */ {$$ = NULL;}

Define: NUMERAL DEFINE NAME BOOLEAN { $$ = new_define_node(DEFINE_INTEGER, $3, $4, NULL); }
        | NUMERAL DEFINE NAME INTEGER {$$ = new_define_node(DEFINE_INTEGER, $3, $4, NULL); }
        | NUMERAL DEFINE NAME STRING {$$ = new_define_node(DEFINE_STRING, $3, NULL, $4); }

Functions: Function Functions {$$ = new_functions_node($1, $2); }
        | Main {$$ = new_functions_node($1, NULL);}

Function: NAME OPEN_PARENTHESES Arguments CLOSE_PARENTHESES OPEN_CURLY_BRACES Block CLOSE_CURLY_BRACES	{$$ = new_function_node($1, $3, $6);}

Main: MAIN OPEN_PARENTHESES Arguments CLOSE_PARENTHESES OPEN_CURLY_BRACES Block CLOSE_CURLY_BRACES	{$$ = new_function_node("main", $3, $6); }

Arguments: /* empty */	{$$ = NULL;}
				|	Parameters	{$$ = $1;}

Parameters: NAME {$$ = new_parameters_node($1, NULL); }
				| NAME COMMA Parameters {$$ = new_parameters_node($1, $3); }

Block: /* empty */ {$$ = NULL; }
				| Sentences {$$ = $1;}

Sentences: Sentence {$$ = new_sentences_node($1, NULL); }
				| Sentence Sentences {$$ = new_sentences_node($1, $2); }

Sentence: VariableOperation SentenceEnd { $$ = new_sentence_node(SENTENCE_VARIABLE, $1, $2, NULL, NULL, NULL, NULL, NULL); }
				| For {$$ = new_sentence_node(SENTENCE_FOR, NULL, NULL, $1, NULL, NULL, NULL, NULL); }
				| While {$$ = new_sentence_node(SENTENCE_WHILE, NULL, NULL, NULL, $1, NULL, NULL, NULL); }
				| If {$$ = new_sentence_node(SENTENCE_IF, NULL, NULL, NULL, NULL, $1, NULL, NULL); }
				| FunctionExecute SentenceEnd {$$ = new_sentence_node(SENTENCE_FUNCTION, NULL, $2, NULL, NULL, NULL, $1, NULL); }
				| Return SentenceEnd {$$ = new_sentence_node(SENTENCE_RETURN, NULL, $2, NULL, NULL, NULL, NULL, $1); }

SentenceEnd: /* empty */ {$$ = '\0'; }
				| SEMICOLON {$$ = ';';}

VariableOperation: Assignments {$$ = new_variable_operation_node(VARIABLE_ASSIGNMENT, $1, NULL); }
				| Increment {$$ = new_variable_operation_node(VARIABLE_INCREMENT, NULL, $1);}
				| Decrement {$$ = new_variable_operation_node(VARIABLE_DECREMENT, NULL, $1);}

Assignments: Assignment COMMA Assignments {$$ = new_assignments_node($1, $3); }
				| Assignment {$$ = new_assignments_node($1, NULL); }

Assignment: NAME EQUAL STRING {$$ = new_assignment_node(ASSIGNMENT_STRING, $1, $3, NULL, NULL, NULL); }
				| NAME EQUAL Queue {$$ = new_assignment_node(ASSIGNMENT_QUEUE, $1, NULL, $3, NULL, NULL); }
				| NAME EQUAL Stack {$$ = new_assignment_node(ASSIGNMENT_STACK, $1, NULL, $3, NULL, NULL); }
				| NAME AssignmentOperation Expression {$$ = new_assignment_node(ASSIGNMENT_EXPRESSION, $1, NULL, NULL, $2, $3);}

Queue: OPEN_BRACKET ElementList CLOSE_BRACKET {$$ = new_queue_stack_node($2); }

Stack: LESS_THAN ElementList GREATER_THAN {$$ = new_queue_stack_node($2); }

ElementList: /* empty */ {$$ = NULL; }
				| Elements {$$ = $1; }

Elements: Element COMMA Elements {$$ = new_elements_node($1, $3); }
				| Element {$$ = new_elements_node($1, NULL); }

Element: BOOLEAN {$$ = new_element_node(ELEMENT_BOOLEAN, $1, NULL); }
				| STRING {$$ = new_element_node(ELEMENT_STRING, NULL, $1);}
				| INTEGER {$$ = new_element_node(ELEMENT_INTEGER, $1, NULL);}
				| NAME {$$ = new_element_node(ELEMENT_VARIABLE, NULL, $1);}

AssignmentOperation: PLUS EQUAL {$$ = "+="; }
 				| EQUAL {$$ = "="; }
				| MINUS EQUAL {$$ = "-="; }
				| DIVIDE EQUAL {$$ = "/=";}
				| MULTIPLY EQUAL {$$ = "*=";}

LogicalOperation: AND {$$ = "&&";}
				| OR {$$ = "||";}
				| NOT_EQUAL {$$ = "!=";}
				| EQUAL EQUAL {$$ = "==";}
				| GREATER_OR_EQUAL {$$ = ">=";}
				| GREATER_THAN {$$ = ">";}
				| LESS_OR_EQUAL {$$ = "<=";}
				| LESS_THAN {$$ = "<";}

Increment: NAME PLUS PLUS {$$ = $1;}

Decrement: NAME MINUS MINUS {$$ = $1;}

Expression: BOOLEAN {$$ = new_expression_node(EXPRESSION_BOOLEAN, NULL, NULL, NULL, NULL, $1, NULL); }
				| NAME {$$ = new_expression_node(EXPRESSION_VARIABLE, NULL, NULL,  NULL, NULL, NULL, $1); }
				| INTEGER {$$ = new_expression_node(EXPRESSION_INTEGER, NULL, NULL, NULL, NULL, $1, NULL);}
				| FunctionExecute { $$ = new_expression_node(EXPRESSION_FUNCTION, NULL, NULL, NULL, $1, NULL, NULL); }
				| Expression PLUS Expression {$$ = new_expression_node(EXPRESSION_OPERATION, $1, '+', $3, NULL, NULL, NULL);}
				| Expression MINUS Expression {$$ = new_expression_node(EXPRESSION_OPERATION, $1, '-', $3, NULL, NULL, NULL);} /*Para queue y array cuantos queres sacar - "Se redefine segun el tipo de dato" esto iria en {}, nos fijamos que tipo de dato estamos manejando y segun eso que es lo que hacemos ... */
				| Expression MOD Expression {$$ = new_expression_node(EXPRESSION_OPERATION, $1, '%', $3, NULL, NULL, NULL);}
				| Expression DIVIDE Expression {$$ = new_expression_node(EXPRESSION_OPERATION, $1, '/', $3, NULL, NULL, NULL);}
				| Expression MULTIPLY Expression {$$ = new_expression_node(EXPRESSION_OPERATION, $1, '*', $3, NULL, NULL, NULL);}

For: FOR OPEN_PARENTHESES Assignments SEMICOLON Condition SEMICOLON VariableOperation CLOSE_PARENTHESES OPEN_CURLY_BRACES Block CLOSE_CURLY_BRACES	{$$ = new_for_node(REGULAR_FOR, $3, $5, $7, $10, NULL, NULL); }
				| FOR OPEN_PARENTHESES NAME COLON NAME CLOSE_PARENTHESES OPEN_CURLY_BRACES Block CLOSE_CURLY_BRACES	{$$ = new_for_node(FOR_EACH, NULL, NULL, NULL, $8, $3, $5);}

Condition: Expression LogicalOperation Expression {$$ = new_condition_node(CONDITION_LOGICAL, $1, $2, $3, NULL); }
				| Expression {$$ = new_condition_node(CONDITION_EXPRESSION, $1, NULL, NULL, NULL);}
				| OPEN_PARENTHESES Condition CLOSE_PARENTHESES {$$ = new_condition_node(CONDITION_PARENTHESES, NULL, NULL, NULL, $2); }

While: WHILE OPEN_PARENTHESES Condition CLOSE_PARENTHESES OPEN_CURLY_BRACES Block CLOSE_CURLY_BRACES	{$$ = new_while_node($3, $6); }

If: IF OPEN_PARENTHESES Condition CLOSE_PARENTHESES OPEN_CURLY_BRACES Block CLOSE_CURLY_BRACES Else {$$ = new_if_node($3, $6, $8); }

Else: ELSE OPEN_CURLY_BRACES Block CLOSE_CURLY_BRACES	{$$ = new_if_node(NULL, $3, NULL); }
				| ELSE_IF OPEN_PARENTHESES Condition CLOSE_PARENTHESES OPEN_CURLY_BRACES Block CLOSE_CURLY_BRACES Else {$$ = new_if_node($3, $6, $8); }
				| /* empty */{$$ = NULL; }

FunctionExecute: NAME OPEN_PARENTHESES CallArguments CLOSE_PARENTHESES {$$ = new_function_execute_node($1, $3); }

CallArguments: /* empty */	{$$ = NULL; }
				|	CallParameters	{$$ = $1;}

CallParameters: CallParameter {$$ = new_call_parameters_node($1, NULL); }
				| CallParameter COMMA CallParameters {$$ = new_call_parameters_node($1, $3);}

CallParameter: STRING {$$ = new_call_parameter_node(PARAMERER_STRING, $1, NULL); }
				| Expression {$$ = new_call_parameter_node(PARAMETER_EXPRESSION, NULL, $1);}

Return: RETURN Expression {$$ = new_return_node(RETURN_EXPRESSION, NULL, $1); }
			| RETURN STRING {$$ = new_return_node(RETURN_STRING, $2, NULL); }

%%
