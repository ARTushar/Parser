%{

#include <iostream>
#include <cstdlib>
#include <string>
#include "1605070_SymbolTable.h"

// #define YYSTYPE SymbolInfo*

using namespace std;

int yyparse(void);
extern "C" int yylex();
extern FILE *yyin;
extern int line_count;
FILE *logout  = fopen("1605070_log.txt","w");

SymbolTable *table = new SymbolTable(30, logout);


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

%type <info> program unit var_declaration func_declaration func_definition type_specifier parameter_list compound_statement statements declaration_list statement expression_statement expression variable logic_expression rel_expression simple_expression term unary_expression factor argument_list arguments function_first_part_1 function_first_part_2

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%

start : program {
	// fprintf(logout, "At line no: %d start : program\n", line_count);
	fprintf(logout, "\t\t Symbol Table:\n\n");
	table->printAll();
	delete $1;
}
	;

program : program unit {
	fprintf(logout, "At line no: %d program : program unit\n", line_count);
	$$ = new SymbolInfo();
	string str = $1->getName() + $2->getName();
	$$->setName(str);
	fprintf(logout, "\n%s\n\n", str.c_str());
	delete $1;
	delete $2;
}
	| unit {
		fprintf(logout, "At line no: %d program : unit\n", line_count);
		$$ = new SymbolInfo();
		string str = $1->getName();
		$$->setName(str);
		fprintf(logout, "\n%s\n\n", str.c_str());
		delete $1;
 	}
	;

unit : var_declaration {
	fprintf(logout, "At line no: %d unit : var_declaration\n", line_count);
	$$ = new SymbolInfo();
	string str = $1->getName() ;
	$$->setName(str);
	fprintf(logout, "\n%s\n\n", str.c_str());
	delete $1;
}
     | func_declaration {
		 fprintf(logout, "At line no: %d unit : func_declaration\n", line_count);
		 $$ = new SymbolInfo();
		 string str = $1->getName();
		 $$->setName(str);
		 fprintf(logout, "\n%s\n\n", str.c_str());

		 delete $1;
	 }
     | func_definition {
		 fprintf(logout, "At line no: %d unit : func_definition\n", line_count);
		 $$ = new SymbolInfo();
		 string str = $1->getName();
		 $$->setName(str);
		 fprintf(logout, "\n%s\n\n", str.c_str());

		 delete $1;
	 }
     ;

func_declaration : function_first_part_1 SEMICOLON {
	fprintf(logout, "At line no: %d func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON\n", line_count);
	$$ = new SymbolInfo();
	string str = $1->getName() + ";\n";
	$$->setName(str);
	fprintf(logout, "\n%s\n\n", str.c_str());

	delete $1;
}
		| function_first_part_2 SEMICOLON {
			fprintf(logout, "At line no: %d func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON\n", line_count);
			$$ = new SymbolInfo();
			string str = $1->getName() + ";\n";
			$$->setName(str);
			fprintf(logout, "\n%s\n\n", str.c_str());

			delete $1;
		}
		;

func_definition : function_first_part_1 compound_statement {
	fprintf(logout, "At line no: %d func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement\n", line_count);
	$$ = new SymbolInfo();
	string str = $1->getName() + " " + $2->getName();
	$$->setName(str);
	fprintf(logout, "\n%s\n\n", str.c_str());

	delete $1;
	delete $2;
}
		| function_first_part_2  compound_statement {
			fprintf(logout, "At line no: %d func_definition : type_specifier ID LPAREN RPAREN compound_statement\n", line_count);
			$$ = new SymbolInfo();
			string str = $1->getName() + " " + $2->getName();
			$$->setName(str);
			fprintf(logout, "\n%s\n\n", str.c_str());

			delete $1;
			delete $2;
		}
 		;

function_first_part_1 : type_specifier ID LPAREN parameter_list RPAREN {

	$$ = new SymbolInfo();
	string str = $1->getName() + " " + $2->getName() + "(" + $4->getName() + ")";
	$$->setName(str);

	SymbolInfo* symbol = new SymbolInfo($2->getName(), "ID");
	symbol->parameterList.push_back($1->getName());
	symbol->parameterList.insert(symbol->parameterList.end(), $4->parameterList.begin(), $4->parameterList.end());

	table->insert(symbol);

	delete $1;
	delete $2;
	delete $4;
}
			;

function_first_part_2:  type_specifier ID LPAREN RPAREN {

	$$ = new SymbolInfo();
	string str = $1->getName() + " " + $2->getName() + "()";
	$$->setName(str);
	SymbolInfo* symbol = new SymbolInfo($2->getName(), "ID");
	symbol->parameterList.push_back($1->getName());

	table->insert(symbol);

	delete $1;
	delete $2;

}
					;


parameter_list  : parameter_list COMMA type_specifier ID {
	fprintf(logout, "At line no: %d parameter_list  : parameter_list COMMA type_specifier ID\n", line_count);
	$$ = new SymbolInfo();
	string str = $1->getName() + ", " + $3->getName() + " "+ $4->getName();
	$$->setName(str);
	$$->parameterList.insert($$->parameterList.end(), $1->parameterList.begin(), $1->parameterList.end());
	$$->parameterList.push_back($3->getName());
	fprintf(logout, "\n%s\n\n", str.c_str());
	delete $1;
	delete $3;
	delete $4;
}
		| parameter_list COMMA type_specifier {
			fprintf(logout, "At line no: %d parameter_list  : parameter_list COMMA type_specifier\n", line_count);
			$$ = new SymbolInfo();
			string str = $1->getName() + ", " + $3->getName();
			$$->setName(str);
			$$->parameterList.insert($$->parameterList.end(), $1->parameterList.begin(), $1->parameterList.end());
			$$->parameterList.push_back($3->getName());
			fprintf(logout, "\n%s\n\n", str.c_str());
			delete $1;
			delete $3;
		}
 		| type_specifier ID {
			 fprintf(logout, "At line no: %d parameter_list  : type_specifier ID\n", line_count);
			 $$ = new SymbolInfo();
			 string str = $1->getName() + " " + $2->getName();
			 $$->setName(str);
			 $$->parameterList.push_back($1->getName());
			 fprintf(logout, "\n%s\n\n", str.c_str());
			 delete $1;
			 delete $2;
		 }
		| type_specifier {
			fprintf(logout, "At line no: %d parameter_list  : type_specifier\n", line_count);
			$$ = new SymbolInfo();
			string str = $1->getName();
			$$->setName(str);
			$$->parameterList.push_back($1->getName());
			fprintf(logout, "\n%s\n\n", str.c_str());
			delete $1;
		}
 		;


compound_statement : LCURL statements RCURL {
	fprintf(logout, "At line no: %d compound_statement : LCURL statements RCURL\n", line_count);
	$$ = new SymbolInfo();
	string str = "{\n" + $2->getName() + "}\n";
	$$->setName(str);
	fprintf(logout, "\n%s\n\n", str.c_str());
	table->printAll();
	table->exitScope();
	delete $2;
}
 		    | LCURL RCURL {
				 fprintf(logout, "At line no: %d compound_statement : LCURL RCURL\n", line_count);
				 $$ = new SymbolInfo();
			 	 string str = "{\n}\n";
			 	 $$->setName(str);
			 	 fprintf(logout, "\n%s\n\n", str.c_str());

				 table->printAll();
				 table->exitScope();
			 }
 		    ;

var_declaration : type_specifier declaration_list SEMICOLON
	{
		fprintf(logout, "At line no: %d var_declaration : type_specifier declaration_list SEMICOLON\n", line_count);
		$$ = new SymbolInfo();
		string str = $1->getName() + " " + $2->getName() + ";\n";
		$$->setName(str);
		fprintf(logout, "\n%s\n\n", str.c_str());
		delete $1;
		delete $2;
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

	table->insert($3->getName(), "ID");

	delete $1;
	delete $3;
}
 		  | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD {
			   fprintf(logout, "At line no: %d declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD\n", line_count);
			   $$ = new SymbolInfo();
			   string str = $1->getName() + "," + $3->getName() + "[" + $5->getName() + "]";
			   $$->setName(str);
			   fprintf(logout, "\n%s\n\n", str.c_str());

			   table->insert($3->getName(), "ID");

			   delete $1;
			   delete $3;
			   delete $5;
		   }
 		  | ID {
			   fprintf(logout, "At line no: %d declaration_list : ID\n", line_count);
			   $$ = new SymbolInfo();
			   string str = $1->getName();
			   $$->setName(str);
			   fprintf(logout, "\n%s\n\n", str.c_str());

			   table->insert($1->getName(), "ID");

			   delete $1;

		   }
 		  | ID LTHIRD CONST_INT RTHIRD {
			   fprintf(logout, "At line no: %d declaration_list : ID LTHIRD CONST_INT RTHIRD\n", line_count);
			   $$ = new SymbolInfo();
			   string str = $1->getName() + "[" + $3->getName() + "]";
			   $$->setName(str);
			   fprintf(logout, "\n%s\n\n", str.c_str());
			   
			   SymbolInfo *symbol = new SymbolInfo($1->getName(), "ID");
			   symbol->parameterList.push_back($3->getName());
			   table->insert(symbol);

			   delete $1;
			   delete $3;
		   }
 		  ;

statements : statement {
	fprintf(logout, "At line no: %d statements : statement\n", line_count);
	$$ = new SymbolInfo();
	string str = $1->getName();
	$$->setName(str);
	fprintf(logout, "\n%s\n\n", str.c_str());
	delete $1;
}
	   | statements statement {
		   fprintf(logout, "At line no: %d statements : statements statement\n", line_count);
		   $$ = new SymbolInfo();
		   string str = $1->getName() + $2->getName();
		   $$->setName(str);
		   fprintf(logout, "\n%s\n\n", str.c_str());
		   delete $1;
		   delete $2;
	   }
	   ;


statement : var_declaration {
	fprintf(logout, "At line no: %d statement : var_declaration\n", line_count);
	$$ = new SymbolInfo();
	string str = $1->getName();
	$$->setName(str);
	fprintf(logout, "\n%s\n\n", str.c_str());
	delete $1;
}
	  | expression_statement {
		  fprintf(logout, "At line no: %d statement : expression_statement\n", line_count);
		  $$ = new SymbolInfo();
		  string str = $1->getName() + "\n";
		  $$->setName(str);
		  fprintf(logout, "\n%s\n\n", str.c_str());
		  delete $1;
	  }
	  | compound_statement {
		  fprintf(logout, "At line no: %d statement : compound_statement\n", line_count);
		  $$ = new SymbolInfo();
		  string str = $1->getName();
		  $$->setName(str);
		  fprintf(logout, "\n%s\n\n", str.c_str());
		  delete $1;
	  }
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement {
		  fprintf(logout, "At line no: %d statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement\n", line_count);
		  $$ = new SymbolInfo();
		  string str = "for(" + $3->getName() + $4->getName() + $5->getName() +") " + $7->getName();
		  $$->setName(str);
		  fprintf(logout, "\n%s\n\n", str.c_str());
		  delete $3;
		  delete $4;
		  delete $5;
		  delete $7;
	  }
	  | IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE {
		  fprintf(logout, "At line no: %d statement : IF LPAREN expression RPAREN statement\n", line_count);
		  $$ = new SymbolInfo();
		  string str = "if(" + $3->getName() + ") " + $5->getName();
		  $$->setName(str);
		  fprintf(logout, "\n%s\n\n", str.c_str());
		  delete $3;
		  delete $5;
	  }
	  | IF LPAREN expression RPAREN statement ELSE statement {
		  fprintf(logout, "At line no: %d statement : IF LPAREN expression RPAREN statement ELSE statement\n", line_count);
		  $$ = new SymbolInfo();
		  string str = "if(" + $3->getName() + ") " + $5->getName() + "else " + $7->getName();
		  $$->setName(str);
		  fprintf(logout, "\n%s\n\n", str.c_str());
		  delete $3;
		  delete $5;
		  delete $7;
	  }
	  | WHILE LPAREN expression RPAREN statement {
		  fprintf(logout, "At line no: %d statement : WHILE LPAREN expression RPAREN statement\n", line_count);
		  $$ = new SymbolInfo();
		  string str = "while(" + $3->getName() + ") " + $5->getName();
		  $$->setName(str);
		  fprintf(logout, "\n%s\n\n", str.c_str());
		  delete $3;
		  delete $5;
	  }
	  | PRINTLN LPAREN ID RPAREN SEMICOLON {
		  fprintf(logout, "At line no: %d statement : PRINTLN LPAREN ID RPAREN SEMICOLON\n", line_count);
		  $$ = new SymbolInfo();
		  string str = "println(" + $3->getName() + ") " +";\n ";
		  $$->setName(str);
		  fprintf(logout, "\n%s\n\n", str.c_str());
		  
		  table->insert($3->getName(), "ID");

		  delete $3;
	  }
	  | RETURN expression SEMICOLON {
		  fprintf(logout, "At line no: %d statement : RETURN expression SEMICOLON\n", line_count);
		  $$ = new SymbolInfo();
		  string str = "return " + $2->getName() + ";\n";
		  $$->setName(str);
		  fprintf(logout, "\n%s\n\n", str.c_str());
		  delete $2;
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
				delete $1;
			}
			;

variable : ID {
	fprintf(logout, "At line no: %d variable : ID\n", line_count);
	$$ = new SymbolInfo();
	string str = $1->getName();
	$$->setName(str);
	fprintf(logout, "\n%s\n\n", str.c_str());
	
	table->insert($1->getName(), "ID");

	delete $1;
}
	 | ID LTHIRD expression RTHIRD {
		 fprintf(logout, "At line no: %d variable : ID LTHIRD expression RTHIRD\n", line_count);
		 $$ = new SymbolInfo();
		 string str = $1->getName() + "[" + $3->getName() + "]";
		 $$->setName(str);
		 fprintf(logout, "\n%s\n\n", str.c_str());
		 
		 table->insert($1->getName(), "ID");
		 
		 delete $1;
		 delete $3;
	 }
	 ;

expression : logic_expression {
	fprintf(logout, "At line no: %d expression : logic_expression\n", line_count);
	$$ = new SymbolInfo();
	string str = $1->getName();
	$$->setName(str);
	fprintf(logout, "\n%s\n\n", str.c_str());
	delete $1;
}
	   | variable ASSIGNOP logic_expression {
		   fprintf(logout, "At line no: %d expression : variable ASSIGNOP logic_expression\n", line_count);
		   $$ = new SymbolInfo();
		   string str = $1->getName() + " = " + $3->getName();
		   $$->setName(str);
		   fprintf(logout, "\n%s\n\n", str.c_str());
		   delete $1;
		   delete $3;
	   }
	   ;

logic_expression : rel_expression {
	fprintf(logout, "At line no: %d logic_expression : rel_expression\n", line_count);
	$$ = new SymbolInfo();
	string str = $1->getName();
	$$->setName(str);
	fprintf(logout, "\n%s\n\n", str.c_str());
	delete $1;
}
		 | rel_expression LOGICOP rel_expression {
			 fprintf(logout, "At line no: %d logic_expression : rel_expression LOGICOP rel_expression\n", line_count);
			 $$ = new SymbolInfo();
		  	 string str = $1->getName() + " " + $2->getName() + " " + $3->getName();
		  	 $$->setName(str);
		  	 fprintf(logout, "\n%s\n\n", str.c_str());
			 delete $1;
			 delete $2;
			 delete $3;
		 }
		 ;

rel_expression	: simple_expression {
	fprintf(logout, "At line no: %d rel_expression	: simple_expression\n", line_count);
	$$ = new SymbolInfo();
	string str = $1->getName();
	$$->setName(str);
	fprintf(logout, "\n%s\n\n", str.c_str());
	delete $1;
}
		| simple_expression RELOP simple_expression {
			fprintf(logout, "At line no: %d rel_expression	: simple_expression RELOP simple_expression\n", line_count);
			$$ = new SymbolInfo();
		  	string str = $1->getName() + " " + $2->getName() + " " + $3->getName();
		  	$$->setName(str);
		  	fprintf(logout, "\n%s\n\n", str.c_str());
			delete $1;
			delete $2;
			delete $3;
		}
		;

simple_expression : term {
	fprintf(logout, "At line no: %d simple_expression : term\n", line_count);
	$$ = new SymbolInfo();
	string str = $1->getName();
	$$->setName(str);
	fprintf(logout, "\n%s\n\n", str.c_str());
	delete $1;
}
		  | simple_expression ADDOP term {
			  fprintf(logout, "At line no: %d simple_expression : simple_expression ADDOP term\n", line_count);
			  $$ = new SymbolInfo();
		  	  string str = $1->getName() + " " + $2->getName() + " " + $3->getName();
		  	  $$->setName(str);
		  	  fprintf(logout, "\n%s\n\n", str.c_str());
			  delete $1;
			  delete $2;
			  delete $3;
		  }
		  ;

term :	unary_expression {
	fprintf(logout, "At line no: %d term : unary_expression\n", line_count);
	$$ = new SymbolInfo();
	string str = $1->getName();
	$$->setName(str);
	fprintf(logout, "\n%s\n\n", str.c_str());
	delete $1;
}
     |  term MULOP unary_expression {
		 fprintf(logout, "At line no: %d term : term MULOP unary_expression\n", line_count);
		 $$ = new SymbolInfo();
		 string str = $1->getName() + $2->getName() + $3->getName();
		 $$->setName(str);
		 fprintf(logout, "\n%s\n\n", str.c_str());
		 delete $1;
		 delete $2;
		 delete $3;
	 }
     ;

unary_expression : ADDOP unary_expression {
	fprintf(logout, "At line no: %d unary_expression : ADDOP unary_expression\n", line_count);
	$$ = new SymbolInfo();
	string str = $1->getName() + $2->getName();
	$$->setName(str);
	fprintf(logout, "\n%s\n\n", str.c_str());
	delete $1;
	delete $2;
}
		 | NOT unary_expression {
			 fprintf(logout, "At line no: %d unary_expression : NOT unary_expression\n", line_count);
			 $$ = new SymbolInfo();
		  	 string str = "!" + $2->getName();
		  	 $$->setName(str);
		  	 fprintf(logout, "\n%s\n\n", str.c_str());
			 delete $2;
		 }
		 | factor {
			 fprintf(logout, "At line no: %d unary_expression : factor\n", line_count);
			 $$ = new SymbolInfo();
		  	 string str = $1->getName();
		  	 $$->setName(str);
		  	 fprintf(logout, "\n%s\n\n", str.c_str());
			 delete $1;
		 }
		 ;

factor	: variable {
	fprintf(logout, "At line no: %d factor : variable\n", line_count);
	$$ = new SymbolInfo();
	string str = $1->getName();
	$$->setName(str);
	fprintf(logout, "\n%s\n\n", str.c_str());
	delete $1;
}
	| ID LPAREN argument_list RPAREN {
		fprintf(logout, "At line no: %d factor : ID LPAREN argument_list RPAREN\n", line_count);
		$$ = new SymbolInfo();
		string str = $1->getName() + "(" + $3->getName() + ")";
		$$->setName(str);
		fprintf(logout, "\n%s\n\n", str.c_str());
		
		table->insert($1->getName(), "ID");

		delete $1;
		delete $3;
	}
	| LPAREN expression RPAREN {
		fprintf(logout, "At line no: %d factor : LPAREN expression RPAREN\n", line_count);
		$$ = new SymbolInfo();
		string str = "(" + $2->getName() + ")";
		$$->setName(str);
		fprintf(logout, "\n%s\n\n", str.c_str());
		delete $2;
	}
	| CONST_INT {
		fprintf(logout, "At line no: %d factor : CONST_INT\n", line_count);
		$$ = new SymbolInfo();
		string str = $1->getName();
		$$->setName(str);
		fprintf(logout, "\n%s\n\n", str.c_str());
		delete $1;
	}
	| CONST_FLOAT {
		fprintf(logout, "At line no: %d factor : CONST_FLOAT\n", line_count);
		$$ = new SymbolInfo();
		string str = $1->getName();
		$$->setName(str);
		fprintf(logout, "\n%s\n\n", str.c_str());
		delete $1;
	}
	| variable INCOP {
		fprintf(logout, "At line no: %d factor : variable INCOP\n", line_count);
		$$ = new SymbolInfo();
		string str = $1->getName() + "++";
		$$->setName(str);
		fprintf(logout, "\n%s\n\n", str.c_str());
		delete $1;
	}
	| variable DECOP {
		fprintf(logout, "At line no: %d factor : variable DECOP\n", line_count);
		$$ = new SymbolInfo();
		string str = $1->getName() + "--";
		$$->setName(str);
		fprintf(logout, "\n%s\n\n", str.c_str());
		delete $1;
	}
	;

argument_list : arguments {
	fprintf(logout, "At line no: %d argument_list : arguments\n", line_count);
	$$ = new SymbolInfo();
	string str = $1->getName();
	$$->setName(str);
	fprintf(logout, "\n%s\n\n", str.c_str());
	delete $1;
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
	delete $1;
	delete $3;
}
	      | logic_expression {
			  fprintf(logout, "At line no: %d arguments : logic_expression\n", line_count);
			  $$ = new SymbolInfo();
			  string str = $1->getName();
			  $$->setName(str);
			  fprintf(logout, "\n%s\n\n", str.c_str());
			  delete $1;
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
	fprintf(logout, "Total lines: %d\n", line_count);
    // fprintf(logout, "Total errors: %d\n", total_error);
	fclose(yyin);
	fclose(logout);
	fclose(fp);

	return 0;
}

