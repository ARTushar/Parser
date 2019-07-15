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
extern int line_count;
FILE *logout  = fopen("1605070_log.txt","w");

SymbolTable *table;


void yyerror(char *s)
{
	//write your code
}

%}

%union {
	SymbolInfo* info;
}

%token IF ELSE FOR WHILE  ASSIGNOP COMMA INCOP DECOP FLOAT CHAR INT LCURL LPAREN LTHIRD  NOT PRINTLN RCURL RETURN SEMICOLON RTHIRD RPAREN VOID DOUBLE

%token <info> ADDOP CONST_FLOAT CONST_INT ID LOGICOP MULOP RELOP

%type <info> program unit var_declaration func_declaration func_definition type_specifier parameter_list compound_statement statements declaration_list statement expression_statement expression variable logic_expression rel_expression simple_expression term unary_expression factor argument_list arguments

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%

start : program {
	// fprintf(logout, "At line no: %d start : program\n", line_count);
}
	;

program : program unit {
	fprintf(logout, "At line no: %d program : program unit\n", line_count);
	$$ = new SymbolInfo();
	string str = $1->getName() + $2->getName();
	$$->setName(str);
	fprintf(logout, "\n%s\n\n", str.c_str());
}
	| unit {
		fprintf(logout, "At line no: %d program : unit\n", line_count);
		$$ = new SymbolInfo();
		string str = $1->getName();
		$$->setName(str);
		fprintf(logout, "\n%s\n\n", str.c_str());
 	}
	;

unit : var_declaration {
	fprintf(logout, "At line no: %d unit : var_declaration\n", line_count);
	$$ = new SymbolInfo();
	string str = $1->getName() ;
	$$->setName(str);
	fprintf(logout, "\n%s\n\n", str.c_str());
}
     | func_declaration {
		 fprintf(logout, "At line no: %d unit : func_declaration\n", line_count);
		 $$ = new SymbolInfo();
		 string str = $1->getName();
		 $$->setName(str);
		 fprintf(logout, "\n%s\n\n", str.c_str());
	 }
     | func_definition {
		 fprintf(logout, "At line no: %d unit : func_definition\n", line_count);
		 $$ = new SymbolInfo();
		 string str = $1->getName();
		 $$->setName(str);
		 fprintf(logout, "\n%s\n\n", str.c_str());
	 }
     ;

func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON {
	fprintf(logout, "At line no: %d func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON\n", line_count);
	$$ = new SymbolInfo();
	string str = $1->getName() + " " + $2->getName() + "(" + $4->getName() + ")" + ";\n";
	$$->setName(str);
	fprintf(logout, "\n%s\n\n", str.c_str());
}
		| type_specifier ID LPAREN RPAREN SEMICOLON {
			fprintf(logout, "At line no: %d func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON\n", line_count);
			$$ = new SymbolInfo();
			string str = $1->getName() + " " + $2->getName() + "()" + ";\n";
			$$->setName(str);
			fprintf(logout, "\n%s\n\n", str.c_str());
		}
		;

func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement {
	fprintf(logout, "At line no: %d func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement\n", line_count);
	$$ = new SymbolInfo();
	string str = $1->getName() + " " + $2->getName() + "(" + $4->getName() + ")" + $6->getName();
	$$->setName(str);
	fprintf(logout, "\n%s\n\n", str.c_str());
}
		| type_specifier ID LPAREN RPAREN compound_statement {
			fprintf(logout, "At line no: %d func_definition : type_specifier ID LPAREN RPAREN compound_statement\n", line_count);
			$$ = new SymbolInfo();
			string str = $1->getName() + " " + $2->getName() + "()" + $5->getName();
			$$->setName(str);
			fprintf(logout, "\n%s\n\n", str.c_str());
		}
 		;


parameter_list  : parameter_list COMMA type_specifier ID {
	fprintf(logout, "At line no: %d parameter_list  : parameter_list COMMA type_specifier ID\n", line_count);
	$$ = new SymbolInfo();
	string str = $1->getName() + ", " + $3->getName() + " "+ $4->getName();
	$$->setName(str);
	fprintf(logout, "\n%s\n\n", str.c_str());
}
		| parameter_list COMMA type_specifier {
			fprintf(logout, "At line no: %d parameter_list  : parameter_list COMMA type_specifier\n", line_count);
			$$ = new SymbolInfo();
			string str = $1->getName() + ", " + $3->getName();
			$$->setName(str);
			fprintf(logout, "\n%s\n\n", str.c_str());
		}
 		| type_specifier ID {
			 fprintf(logout, "At line no: %d parameter_list  : type_specifier ID\n", line_count);
			 $$ = new SymbolInfo();
			 string str = $1->getName() + " " + $2->getName();
			 $$->setName(str);
			 fprintf(logout, "\n%s\n\n", str.c_str());
		 }
		| type_specifier {
			fprintf(logout, "At line no: %d parameter_list  : type_specifier\n", line_count);
			$$ = new SymbolInfo();
			string str = $1->getName();
			$$->setName(str);
			fprintf(logout, "\n%s\n\n", str.c_str());
		}
 		;


compound_statement : LCURL statements RCURL {
	fprintf(logout, "At line no: %d compound_statement : LCURL statements RCURL\n", line_count);
	$$ = new SymbolInfo();
	string str = "{\n" + $2->getName() + "}\n";
	$$->setName(str);
	fprintf(logout, "\n%s\n\n", str.c_str());
}
 		    | LCURL RCURL {
				 fprintf(logout, "At line no: %d compound_statement : LCURL RCURL\n", line_count);
				 $$ = new SymbolInfo();
			 	 string str = "{\n}\n";
			 	 $$->setName(str);
			 	 fprintf(logout, "\n%s\n\n", str.c_str());
			 }
 		    ;

var_declaration : type_specifier declaration_list SEMICOLON
	{
		fprintf(logout, "At line no: %d var_declaration : type_specifier declaration_list SEMICOLON\n", line_count);
		$$ = new SymbolInfo();
		string str = $1->getName() + " " + $2->getName() + ";\n";
		$$->setName(str);
		fprintf(logout, "\n%s\n\n", str.c_str());
	}
 		 ;

type_specifier : INT {
	fprintf(logout, "At line no: %d type_specifier : INT\n", line_count);
	$$ = new SymbolInfo();
	$$->setName("int");
	fprintf(logout, "\nint\n\n");
}
 		| FLOAT {
			 fprintf(logout, "At line no: %d type_specifier	: FLOAT\n", line_count);
			 $$ = new SymbolInfo();
			 $$->setName("float");
			 fprintf(logout, "\nfloat\n\n");
		 }
 		| VOID {
			 fprintf(logout, "At line no: %d type_specifier : VOID\n", line_count);
			 $$ = new SymbolInfo();
			 $$->setName("void");
			 fprintf(logout, "\nvoid\n\n");
		 }
		| CHAR {
			fprintf(logout, "At line no: %d type_specifier : CHAR\n", line_count);
			$$ = new SymbolInfo();
			$$->setName("char");
			fprintf(logout, "\nchar\n\n");
		}
		| DOUBLE {
			fprintf(logout, "At line no: %d type_specifier : DOUBLE\n", line_count);
			$$ = new SymbolInfo();
			$$->setName("double");
			fprintf(logout, "\ndouble\n\n");

		}
 		;

declaration_list : declaration_list COMMA ID {
	fprintf(logout, "At line no: %d declaration_list : declaration_list COMMA ID\n", line_count);
	$$ = new SymbolInfo();
	string str = $1->getName() + "," + $3->getName();
	$$->setName(str);
	fprintf(logout, "\n%s\n\n", str.c_str());
}
 		  | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD {
			   fprintf(logout, "At line no: %d declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD\n", line_count);
			   $$ = new SymbolInfo();
			   string str = $1->getName() + "," + $3->getName() + "[" + $5->getName() + "]";
			   $$->setName(str);
			   fprintf(logout, "\n%s\n\n", str.c_str());
		   }
 		  | ID {
			   fprintf(logout, "At line no: %d declaration_list : ID\n", line_count);
			   $$ = new SymbolInfo();
			   string str = $1->getName();
			   $$->setName(str);
			   fprintf(logout, "\n%s\n\n", str.c_str());

		   }
 		  | ID LTHIRD CONST_INT RTHIRD {
			   fprintf(logout, "At line no: %d declaration_list : ID LTHIRD CONST_INT RTHIRD\n", line_count);
			   $$ = new SymbolInfo();
			   string str = $1->getName() + "[" + $3->getName() + "]";
			   $$->setName(str);
			   fprintf(logout, "\n%s\n\n", str.c_str());
		   }
 		  ;

statements : statement {
	fprintf(logout, "At line no: %d statements : statement\n", line_count);
	$$ = new SymbolInfo();
	string str = $1->getName();
	$$->setName(str);
	fprintf(logout, "\n%s\n\n", str.c_str());
}
	   | statements statement {
		   fprintf(logout, "At line no: %d statements : statements statement\n", line_count);
		   $$ = new SymbolInfo();
		   string str = $1->getName() + $2->getName();
		   $$->setName(str);
		   fprintf(logout, "\n%s\n\n", str.c_str());
	   }
	   ;


statement : var_declaration {
	fprintf(logout, "At line no: %d statement : var_declaration\n", line_count);
	$$ = new SymbolInfo();
	string str = $1->getName();
	$$->setName(str);
	fprintf(logout, "\n%s\n\n", str.c_str());
}
	  | expression_statement {
		  fprintf(logout, "At line no: %d statement : expression_statement\n", line_count);
		  $$ = new SymbolInfo();
		  string str = $1->getName() + "\n";
		  $$->setName(str);
		  fprintf(logout, "\n%s\n\n", str.c_str());
	  }
	  | compound_statement {
		  fprintf(logout, "At line no: %d statement : compound_statement\n", line_count);
		  $$ = new SymbolInfo();
		  string str = $1->getName();
		  $$->setName(str);
		  fprintf(logout, "\n%s\n\n", str.c_str());
	  }
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement {
		  fprintf(logout, "At line no: %d statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement\n", line_count);
		  $$ = new SymbolInfo();
		  string str = "for(" + $3->getName() + $4->getName() + $5->getName() +") " + $7->getName();
		  $$->setName(str);
		  fprintf(logout, "\n%s\n\n", str.c_str());
	  }
	  | IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE {
		  fprintf(logout, "At line no: %d statement : IF LPAREN expression RPAREN statement\n", line_count);
		  $$ = new SymbolInfo();
		  string str = "if(" + $3->getName() + ") " + $5->getName();
		  $$->setName(str);
		  fprintf(logout, "\n%s\n\n", str.c_str());
	  }
	  | IF LPAREN expression RPAREN statement ELSE statement {
		  fprintf(logout, "At line no: %d statement : IF LPAREN expression RPAREN statement ELSE statement\n", line_count);
		  $$ = new SymbolInfo();
		  string str = "if(" + $3->getName() + ") " + $5->getName() + "else " + $7->getName();
		  $$->setName(str);
		  fprintf(logout, "\n%s\n\n", str.c_str());
	  }
	  | WHILE LPAREN expression RPAREN statement {
		  fprintf(logout, "At line no: %d statement : WHILE LPAREN expression RPAREN statement\n", line_count);
		  $$ = new SymbolInfo();
		  string str = "while(" + $3->getName() + ") " + $5->getName();
		  $$->setName(str);
		  fprintf(logout, "\n%s\n\n", str.c_str());
	  }
	  | PRINTLN LPAREN ID RPAREN SEMICOLON {
		  fprintf(logout, "At line no: %d statement : PRINTLN LPAREN ID RPAREN SEMICOLON\n", line_count);
		  $$ = new SymbolInfo();
		  string str = "println(" + $3->getName() + ") " +";\n ";
		  $$->setName(str);
		  fprintf(logout, "\n%s\n\n", str.c_str());
	  }
	  | RETURN expression SEMICOLON {
		  fprintf(logout, "At line no: %d statement : RETURN expression SEMICOLON\n", line_count);
		  $$ = new SymbolInfo();
		  string str = "return " + $2->getName() + ";\n";
		  $$->setName(str);
		  fprintf(logout, "\n%s\n\n", str.c_str());
	  }
	  ;

expression_statement : SEMICOLON {
	fprintf(logout, "At line no: %d expression_statement : SEMICOLON\n", line_count);
	$$ = new SymbolInfo();
	string str = "; ";
	$$->setName(str);
	fprintf(logout, "\n%s\n\n", str.c_str());
}
			| expression SEMICOLON {
				fprintf(logout, "At line no: %d expression_statement : expression SEMICOLON\n", line_count);
				$$ = new SymbolInfo();
		  		string str = $1->getName() + "; ";
		  		$$->setName(str);
		  		fprintf(logout, "\n%s\n\n", str.c_str());
			}
			;

variable : ID {
	fprintf(logout, "At line no: %d variable : ID\n", line_count);
	$$ = new SymbolInfo();
	string str = $1->getName();
	$$->setName(str);
	fprintf(logout, "\n%s\n\n", str.c_str());
}
	 | ID LTHIRD expression RTHIRD {
		 fprintf(logout, "At line no: %d variable : ID LTHIRD expression RTHIRD\n", line_count);
		 $$ = new SymbolInfo();
		 string str = $1->getName() + "[" + $3->getName() + "]";
		 $$->setName(str);
		 fprintf(logout, "\n%s\n\n", str.c_str());
	 }
	 ;

expression : logic_expression {
	fprintf(logout, "At line no: %d expression : logic_expression\n", line_count);
	$$ = new SymbolInfo();
	string str = $1->getName();
	$$->setName(str);
	fprintf(logout, "\n%s\n\n", str.c_str());
}
	   | variable ASSIGNOP logic_expression {
		   fprintf(logout, "At line no: %d expression : variable ASSIGNOP logic_expression\n", line_count);
		   $$ = new SymbolInfo();
		   string str = $1->getName() + " = " + $3->getName();
		   $$->setName(str);
		   fprintf(logout, "\n%s\n\n", str.c_str());
	   }
	   ;

logic_expression : rel_expression {
	fprintf(logout, "At line no: %d logic_expression : rel_expression\n", line_count);
	$$ = new SymbolInfo();
	string str = $1->getName();
	$$->setName(str);
	fprintf(logout, "\n%s\n\n", str.c_str());
}
		 | rel_expression LOGICOP rel_expression {
			 fprintf(logout, "At line no: %d logic_expression : rel_expression LOGICOP rel_expression\n", line_count);
			 $$ = new SymbolInfo();
		  	 string str = $1->getName() + " " + $2->getName() + " " + $3->getName();
		  	 $$->setName(str);
		  	 fprintf(logout, "\n%s\n\n", str.c_str());
		 }
		 ;

rel_expression	: simple_expression {
	fprintf(logout, "At line no: %d rel_expression	: simple_expression\n", line_count);
	$$ = new SymbolInfo();
	string str = $1->getName();
	$$->setName(str);
	fprintf(logout, "\n%s\n\n", str.c_str());
}
		| simple_expression RELOP simple_expression {
			fprintf(logout, "At line no: %d rel_expression	: simple_expression RELOP simple_expression\n", line_count);
			$$ = new SymbolInfo();
		  	string str = $1->getName() + " " + $2->getName() + " " + $3->getName();
		  	$$->setName(str);
		  	fprintf(logout, "\n%s\n\n", str.c_str());
		}
		;

simple_expression : term {
	fprintf(logout, "At line no: %d simple_expression : term\n", line_count);
	$$ = new SymbolInfo();
	string str = $1->getName();
	$$->setName(str);
	fprintf(logout, "\n%s\n\n", str.c_str());
}
		  | simple_expression ADDOP term {
			  fprintf(logout, "At line no: %d simple_expression : simple_expression ADDOP term\n", line_count);
			  $$ = new SymbolInfo();
		  	  string str = $1->getName() + " " + $2->getName() + " " + $3->getName();
		  	  $$->setName(str);
		  	  fprintf(logout, "\n%s\n\n", str.c_str());
		  }
		  ;

term :	unary_expression {
	fprintf(logout, "At line no: %d term : unary_expression\n", line_count);
	$$ = new SymbolInfo();
	string str = $1->getName();
	$$->setName(str);
	fprintf(logout, "\n%s\n\n", str.c_str());
}
     |  term MULOP unary_expression {
		 fprintf(logout, "At line no: %d term : term MULOP unary_expression\n", line_count);
		 $$ = new SymbolInfo();
		 string str = $1->getName() + $2->getName() + $3->getName();
		 $$->setName(str);
		 fprintf(logout, "\n%s\n\n", str.c_str());
	 }
     ;

unary_expression : ADDOP unary_expression {
	fprintf(logout, "At line no: %d unary_expression : ADDOP unary_expression\n", line_count);
	$$ = new SymbolInfo();
	string str = $1->getName() + $2->getName();
	$$->setName(str);
	fprintf(logout, "\n%s\n\n", str.c_str());
}
		 | NOT unary_expression {
			 fprintf(logout, "At line no: %d unary_expression : NOT unary_expression\n", line_count);
			 $$ = new SymbolInfo();
		  	 string str = "!" + $2->getName();
		  	 $$->setName(str);
		  	 fprintf(logout, "\n%s\n\n", str.c_str());
		 }
		 | factor {
			 fprintf(logout, "At line no: %d unary_expression : factor\n", line_count);
			 $$ = new SymbolInfo();
		  	 string str = $1->getName();
		  	 $$->setName(str);
		  	 fprintf(logout, "\n%s\n\n", str.c_str());
		 }
		 ;

factor	: variable {
	fprintf(logout, "At line no: %d factor : variable\n", line_count);
	$$ = new SymbolInfo();
	string str = $1->getName();
	$$->setName(str);
	fprintf(logout, "\n%s\n\n", str.c_str());
}
	| ID LPAREN argument_list RPAREN {
		fprintf(logout, "At line no: %d factor : ID LPAREN argument_list RPAREN\n", line_count);
		$$ = new SymbolInfo();
		string str = $1->getName() + "(" + $3->getName() + ")";
		$$->setName(str);
		fprintf(logout, "\n%s\n\n", str.c_str());
	}
	| LPAREN expression RPAREN {
		fprintf(logout, "At line no: %d factor : LPAREN expression RPAREN\n", line_count);
		$$ = new SymbolInfo();
		string str = "(" + $2->getName() + ")";
		$$->setName(str);
		fprintf(logout, "\n%s\n\n", str.c_str());
	}
	| CONST_INT {
		fprintf(logout, "At line no: %d factor : CONST_INT\n", line_count);
		$$ = new SymbolInfo();
		string str = $1->getName();
		$$->setName(str);
		fprintf(logout, "\n%s\n\n", str.c_str());
	}
	| CONST_FLOAT {
		fprintf(logout, "At line no: %d factor : CONST_FLOAT\n", line_count);
		$$ = new SymbolInfo();
		string str = $1->getName();
		$$->setName(str);
		fprintf(logout, "\n%s\n\n", str.c_str());
	}
	| variable INCOP {
		fprintf(logout, "At line no: %d factor : variable INCOP\n", line_count);
		$$ = new SymbolInfo();
		string str = $1->getName() + "++";
		$$->setName(str);
		fprintf(logout, "\n%s\n\n", str.c_str());
	}
	| variable DECOP {
		fprintf(logout, "At line no: %d factor : variable DECOP\n", line_count);
		$$ = new SymbolInfo();
		string str = $1->getName() + "--";
		$$->setName(str);
		fprintf(logout, "\n%s\n\n", str.c_str());
	}
	;

argument_list : arguments {
	fprintf(logout, "At line no: %d argument_list : arguments\n", line_count);
	$$ = new SymbolInfo();
	string str = $1->getName();
	$$->setName(str);
	fprintf(logout, "\n%s\n\n", str.c_str());
}
			  | {
				  fprintf(logout, "At line no: %d argument_list : \n", line_count);
				  $$ = new SymbolInfo();
				  string str = "";
				  $$->setName(str);
				  fprintf(logout, "\n%s\n\n", str.c_str());
			  }
			  ;

arguments : arguments COMMA logic_expression {
	fprintf(logout, "At line no: %d arguments : arguments COMMA logic_expression\n", line_count);
	$$ = new SymbolInfo();
	string str = $1->getName() + ", " + $3->getName();
	$$->setName(str);
	fprintf(logout, "\n%s\n\n", str.c_str());
}
	      | logic_expression {
			  fprintf(logout, "At line no: %d arguments : logic_expression\n", line_count);
			  $$ = new SymbolInfo();
			  string str = $1->getName();
			  $$->setName(str);
			  fprintf(logout, "\n%s\n\n", str.c_str());
		  }
	      ;


%%
int main(int argc,char *argv[])
{
	FILE* fp;

	if((fp=fopen(argv[1],"r"))==NULL) {
		printf("Cannot Open Input File.\n");
		exit(1);
	}
	
	yyin=fp;
	yyparse();
	fclose(fp);

	return 0;
}

