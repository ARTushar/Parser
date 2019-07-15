%{

#include<iostream>
#include<cstdlib>
#include<string>
#include<cmath>
#include "1605070_SymbolTable.h"

// #define YYSTYPE SymbolInfo*

using namespace std;

int yyparse(void);
extern "C" int yylex();
extern FILE *yyin;

SymbolTable *table;


void yyerror(char *s)
{
	//write your code
}


%}

%union {
	SymbolInfo* info;
}

%token IF ELSE FOR WHILE  ASSIGNOP COMMA   DECOP FLOAT CHAR INT LCURL LPAREN LTHIRD  NOT PRINTLN RCURL RETURN SEMICOLON RTHIRD RPAREN VOID DOUBLE

%token <info> ADDOP CONST_FLOAT CONST_INT ID INCOP LOGICOP MULOP RELOP

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%

start : program
	{
		//write your code in this block in all the similar blocks below
	}
	;

program : program unit 
	| unit
	;
	
unit : var_declaration
     | func_declaration
     | func_definition
     ;
     
func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON
		| type_specifier ID LPAREN RPAREN SEMICOLON
		;
		 
func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement
		| type_specifier ID LPAREN RPAREN compound_statement
 		;				


parameter_list  : parameter_list COMMA type_specifier ID
		| parameter_list COMMA type_specifier
 		| type_specifier ID
		| type_specifier
 		;

 		
compound_statement : LCURL statements RCURL
 		    | LCURL RCURL
 		    ;
 		    
var_declaration : type_specifier declaration_list SEMICOLON { cout << "var declared " << endl;}
 		 ;
 		 
type_specifier	: INT {cout << "milgaya int" << endl;}
 		| FLOAT
 		| VOID
		| CHAR
		| DOUBLE
 		;
 		
declaration_list : declaration_list COMMA ID
 		  | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD
 		  | ID {cout << "id found : " << yylval.info->getName() << endl;}
 		  | ID LTHIRD CONST_INT RTHIRD
 		  ;
 		  
statements : statement
	   | statements statement
	   ;
	   

statement : var_declaration
	  | expression_statement
	  | compound_statement
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement
	  | IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE
	  | IF LPAREN expression RPAREN statement ELSE statement
	  | WHILE LPAREN expression RPAREN statement
	  | PRINTLN LPAREN ID RPAREN SEMICOLON
	  | RETURN expression SEMICOLON
	  ;
	  
expression_statement 	: SEMICOLON			
			| expression SEMICOLON 
			;
	  
variable : ID 		{cout << "id found : "<< yylval.info->getName() << endl;}
	 | ID LTHIRD expression RTHIRD 
	 ;
	 
expression : logic_expression	
	   | variable ASSIGNOP logic_expression { cout << "assignment operator is matched :D " << endl;} 	
	   ;
			
logic_expression : rel_expression 	
		 | rel_expression LOGICOP rel_expression 	
		 ;
			
rel_expression	: simple_expression 
		| simple_expression RELOP simple_expression	
		;
				
simple_expression : term 
		  | simple_expression ADDOP term 
		  ;
					
term :	unary_expression
     |  term MULOP unary_expression
     ;

unary_expression : ADDOP unary_expression  
		 | NOT unary_expression 
		 | factor 
		 ;
	
factor	: variable 
	| ID LPAREN argument_list RPAREN
	| LPAREN expression RPAREN
	| CONST_INT { cout << "digit milgaya " << endl;}
	| CONST_FLOAT
	| variable INCOP 
	| variable DECOP
	;
	
argument_list : arguments
			  |
			  ;
	
arguments : arguments COMMA logic_expression
	      | logic_expression
	      ;
 

%%
int main(int argc,char *argv[])
{
	FILE* fp;

	if((fp=fopen(argv[1],"r"))==NULL)
	{
		printf("Cannot Open Input File.\n");
		exit(1);
	}

/* 	fp2= fopen(argv[2],"w");
	fclose(fp2);
	fp3= fopen(argv[3],"w");
	fclose(fp3);
	
	fp2= fopen(argv[2],"a");
	fp3= fopen(argv[3],"a");
	 */

	yyin=fp;
	yyparse();

	// fclose(fp2);
	// fclose(fp3);
	fclose(fp);

	return 0;
}

