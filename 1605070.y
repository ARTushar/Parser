%{

#include <iostream>
#include <cstdlib>
#include <string>
#include <sstream>
#include "1605070_SymbolTable.h"

using namespace std;

int yyparse(void);
extern "C" int yylex();
extern FILE *yyin;
extern int line_count;
FILE *logout  = fopen("1605070_log.txt","w");
FILE *errorout = fopen("1605070_error.txt", "w");
int serror_count = 0;

SymbolTable *table = new SymbolTable(30, logout);
vector<pair<string, string>> parameters;
bool parameterSaved = false;
string functionReturnType = "";
bool matchFunction(vector<string> &, vector<string> &);


void yyerror(char *s)
{
	//write your code
	fprintf(logout, "%s at line %d\n\n", s, line_count);
}

%}

%union {
	SymbolInfo* info;
}

%token IF ELSE FOR WHILE  ASSIGNOP COMMA INCOP DECOP FLOAT CHAR INT LCURL LPAREN LTHIRD  NOT PRINTLN RCURL RETURN SEMICOLON RTHIRD RPAREN VOID DOUBLE

%token <info> ADDOP CONST_FLOAT CONST_INT ID LOGICOP MULOP RELOP

%type <info> program unit var_declaration func_declaration func_definition type_specifier parameter_list compound_statement statements declaration_list statement expression_statement expression variable logic_expression rel_expression simple_expression term unary_expression factor argument_list arguments function_first_part_1 function_first_part_2 left_curl

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
	if(parameterSaved){
		parameters.clear();
		parameterSaved = false;
	}
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
	parameterSaved = true;

	SymbolInfo* foundSymbol = table->lookUp($2->getName());

	if(foundSymbol){
		vector<string> list = foundSymbol->parameterList;
		vector<string> para;
		para.push_back($1->getName());
		para.insert(para.end(), $4->parameterList.begin(), $4->parameterList.end());
		para.push_back("function");
		if(list[list.size() - 1] == "function"){
			if(!matchFunction(list, para)){
				fprintf(errorout, "Erorr at line %d : conflicting types for  '%s'\n\n", line_count, $2->getName().c_str());
				serror_count++;
				$$->setName("error");
			} else functionReturnType = $1->getName();
		}
		else {
			fprintf(errorout, "Erorr at line %d : '%s' redeclared as different kind of symbol\n\n", line_count, $2->getName().c_str());
			serror_count++;
			$$->setName("error");
		}
	} else {

		SymbolInfo* symbol = new SymbolInfo($2->getName(), "ID");
		symbol->parameterList.push_back($1->getName());
		symbol->parameterList.insert(symbol->parameterList.end(), $4->parameterList.begin(), $4->parameterList.end());
		symbol->parameterList.push_back("function");
		functionReturnType = $1->getName();
		table->insert(symbol);
	}

	delete $1;
	delete $2;
	delete $4;
}
			;

function_first_part_2:  type_specifier ID LPAREN RPAREN {

	$$ = new SymbolInfo();
	string str = $1->getName() + " " + $2->getName() + "()";
	$$->setName(str);

	SymbolInfo* foundSymbol = table->lookUp($2->getName());

	if(foundSymbol){
		vector<string> list = foundSymbol->parameterList;
		if(list[list.size() - 1] == "function"){
			if(list.size() != 2){
				fprintf(errorout, "Erorr at line %d : conflicting types for  '%s'\n\n", line_count, $2->getName().c_str());
				$$->setName("error");
				serror_count++;
			} else functionReturnType = $1->getName();
		}
		else {
			fprintf(errorout, "Erorr at line %d : '%s' redeclared as different kind of symbol\n\n", line_count, $2->getName().c_str());
			$$->setName("error");
			serror_count++;
		}

	} else {
		SymbolInfo* symbol = new SymbolInfo($2->getName(), "ID");
		symbol->parameterList.push_back($1->getName());
		symbol->parameterList.push_back("function");
		functionReturnType = $1->getName();

		table->insert(symbol);
	}

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

	parameters.push_back(make_pair($4->getName(), $3->getName()));

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

			 parameters.push_back(make_pair($2->getName(), $1->getName()));

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


compound_statement : left_curl statements RCURL {
	fprintf(logout, "At line no: %d compound_statement : LCURL statements RCURL\n", line_count);
	$$ = new SymbolInfo();
	string str = "{\n" + $2->getName() + "}\n";
	$$->setName(str);
	fprintf(logout, "\n%s\n\n", str.c_str());
	table->printAll();
	table->exitScope();
	delete $2;
}
 		    | left_curl RCURL {
				 fprintf(logout, "At line no: %d compound_statement : LCURL RCURL\n", line_count);
				 $$ = new SymbolInfo();
			 	 string str = "{\n}\n";
			 	 $$->setName(str);
			 	 fprintf(logout, "\n%s\n\n", str.c_str());

				 table->printAll();
				 table->exitScope();
			 }
 		    ;

left_curl : LCURL {
	table->enterScope();

	for(int i = 0; i < parameters.size(); i++){
		SymbolInfo* symbol = new SymbolInfo(parameters[i].first, "ID");
		symbol->parameterList.push_back(parameters[i].second);
		symbol->parameterList.push_back("normal");
		table->insert(symbol);
	}
	if(parameters.size() != 0){
		parameters.clear();
	}
}
		;

var_declaration : type_specifier declaration_list SEMICOLON {
		fprintf(logout, "At line no: %d var_declaration : type_specifier declaration_list SEMICOLON\n", line_count);
		$$ = new SymbolInfo();
		string str = $1->getName() + " " + $2->getName() + ";\n";
		if($1->getName() == "void") {
			$$->setName("error");
			fprintf(errorout, "Error at line %d : variable declared void\n\n", line_count);
			serror_count++;
		} else {
			$$->setName(str);
			fprintf(logout, "\n%s\n\n", str.c_str());

			stringstream tokenize($2->getName());
			string temp;

			while(getline(tokenize, temp, ',')){
				int found = temp.find("[");
				if(found == -1) {
					SymbolInfo* got = table->lookUpCurrent(temp);
					if(got) {
						fprintf(errorout, "Error at line %d : redeclaration of '%s'\n\n", line_count, temp.c_str());
						serror_count++;
					} else {
						SymbolInfo* symbol = new SymbolInfo(temp, "ID");
						symbol->parameterList.push_back($1->getName());
						symbol->parameterList.push_back("normal");
						table->insert(symbol);
					}
				}
				else{
					int found2 = temp.find("]", found+1);
					string size = temp.substr(found+1, found2-found-1);
					string content = temp.substr(0,found);
					bool got = table->lookUpCurrent(content);
					if(got) {
						fprintf(errorout, "Error at line %d : redeclaration of '%s'\n\n", line_count, content.c_str());
						serror_count++;
					} else {
						SymbolInfo* symbol = new SymbolInfo(content, "ID");
						symbol->parameterList.push_back($1->getName());
						symbol->parameterList.push_back(size);
						symbol->parameterList.push_back("array");
						table->insert(symbol);
					}
				}
			}
		}

		delete $1;
		delete $2;
	}
	| type_specifier declaration_list error {
		fprintf(logout, "';' not provided after variable declaration\n\n");

		fprintf(logout, "At line no: %d var_declaration : type_specifier declaration_list SEMICOLON\n", line_count);
		$$ = new SymbolInfo();
		string str = $1->getName() + " " + $2->getName() + "; // corrected\n";
		$$->setName(str);
		fprintf(logout, "\n%s\n\n", str.c_str());

		stringstream tokenize($2->getName());
		string temp;

		while(getline(tokenize, temp, ',')){
			int found = temp.find("[");
			if(found == -1) {
				bool got = table->lookUpCurrent(temp);
				if(got) {
					fprintf(errorout, "Error at line %d : redeclaration of '%s'\n\n", line_count, temp.c_str());
					serror_count++;
				} else {
					SymbolInfo* symbol = new SymbolInfo(temp, "ID");
					symbol->parameterList.push_back($1->getName());
					symbol->parameterList.push_back("normal");
					table->insert(symbol);
				}
			}
			else{
				int found2 = temp.find("]", found+1);
				string size = temp.substr(found+1, found2-found-1);
				string content = temp.substr(0,found);
				bool got = table->lookUpCurrent(content);
				if(got) {
					fprintf(errorout, "Error at line %d : redeclaration of '%s'\n\n", line_count, content.c_str());
					serror_count++;
				} else {
					SymbolInfo* symbol = new SymbolInfo(content, "ID");
					symbol->parameterList.push_back($1->getName());
					symbol->parameterList.push_back(size);
					symbol->parameterList.push_back("array");
					table->insert(symbol);
				}
			}
		}

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
 		;

declaration_list : declaration_list COMMA ID {
	fprintf(logout, "At line no: %d declaration_list : declaration_list COMMA ID\n", line_count);
	$$ = new SymbolInfo();
	string str = $1->getName() + "," + $3->getName();
	$$->setName(str);
	fprintf(logout, "\n%s\n\n", str.c_str());

	delete $1;
	delete $3;
}
 		  | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD {
			   fprintf(logout, "At line no: %d declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD\n", line_count);
			   $$ = new SymbolInfo();
			   string str = $1->getName() + "," + $3->getName() + "[" + $5->getName() + "]";
			   $$->setName(str);
			   fprintf(logout, "\n%s\n\n", str.c_str());

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
			   delete $1;

		   }
 		  | ID LTHIRD CONST_INT RTHIRD {
			   fprintf(logout, "At line no: %d declaration_list : ID LTHIRD CONST_INT RTHIRD\n", line_count);
			   $$ = new SymbolInfo();
			   string str = $1->getName() + "[" + $3->getName() + "]";
			   $$->setName(str);
			   fprintf(logout, "\n%s\n\n", str.c_str());

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
		   string str = $1->getName()+ $2->getName();
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
		  string str = "println(" + $3->getName() + ")" +";\n";
		  $$->setName(str);
		  fprintf(logout, "\n%s\n\n", str.c_str());
		  
		  delete $3;
	  }
	  | PRINTLN LPAREN ID RPAREN error {
		  fprintf(logout, "';' not provided\n\n");
		  fprintf(logout, "At line no: %d statement : PRINTLN LPAREN ID RPAREN SEMICOLON\n", line_count);
		  $$ = new SymbolInfo();
		  string str = "println(" + $3->getName() + ")" +"; // corrected\n";
		  $$->setName(str);
		  fprintf(logout, "\n%s\n\n", str.c_str());
		  
		  delete $3;
	  }
	  | RETURN expression SEMICOLON {
		  fprintf(logout, "At line no: %d statement : RETURN expression SEMICOLON\n", line_count);
		  $$ = new SymbolInfo();
		  string str = "return " + $2->getName() + ";\n";
		  if(functionReturnType != $2->getType() && $2->getType() != "error"){
			  fprintf(errorout, "Error at line %d : function return type not matched(have '%s' and '%s')\n\n", line_count, functionReturnType.c_str(), $2->getType().c_str());
		  }
		  $$->setName(str);
		  fprintf(logout, "\n%s\n\n", str.c_str());
		  delete $2;
	  }
	  | RETURN expression error {
		  fprintf(logout, "';' not provided\n\n");
		  fprintf(logout, "At line no: %d statement : RETURN expression SEMICOLON\n", line_count);
		  $$ = new SymbolInfo();
		  string str = "return " + $2->getName() + "; // corrected\n";
		  $$->setName(str);
		  fprintf(logout, "\n%s\n\n", str.c_str());
		  delete $2;
	  }
	  ;

expression_statement : SEMICOLON {
	fprintf(logout, "At line no: %d expression_statement : SEMICOLON\n", line_count);
	$$ = new SymbolInfo();
	string str = ";";
	$$->setName(str);
	fprintf(logout, "\n%s\n\n", str.c_str());
}
			| expression SEMICOLON {
				fprintf(logout, "At line no: %d expression_statement : expression SEMICOLON\n", line_count);
				$$ = new SymbolInfo();
		  		string str = $1->getName() + ";";
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
	SymbolInfo* symbol = table->lookUp($1->getName());
	if(symbol){
		if(symbol->parameterList[symbol->parameterList.size()-1] == "normal") {
			$$->setType(symbol->parameterList[0]);
		}
		else{
			$$->setType("error");
			fprintf(errorout, "Error at line %d : lvalue required\n\n", line_count);
			serror_count++;
		}
	} else{
		$$->setType("error");
		serror_count++;
		fprintf(errorout, "Error at line %d : '%s' undeclared\n\n", line_count, $1->getName().c_str());
	}
	fprintf(logout, "\n%s\n\n", str.c_str());
	
	delete $1;
}
	 | ID LTHIRD expression RTHIRD {
		 fprintf(logout, "At line no: %d variable : ID LTHIRD expression RTHIRD\n", line_count);
		 $$ = new SymbolInfo();
		 string str = $1->getName() + "[" + $3->getName() + "]";
		 $$->setName(str);
		 fprintf(logout, "\n%s\n\n", str.c_str());
		 if($3->getType() != "int") {
			 $$->setType("error");
			 fprintf(errorout, "Error at line %d : array subscript is not an integer (have '%s')\n\n", line_count, $3->getType().c_str());
			 serror_count++;
		 } else {
			SymbolInfo* symbol = table->lookUp($1->getName());
			if(symbol){
				if(symbol->parameterList[symbol->parameterList.size()-1] == "array") {
					$$->setType(symbol->parameterList[0]);
					string size = symbol->parameterList[1];
					if(stoi($3->getName()) >= stoi(size)){
						fprintf(errorout, "Error at line %d : Array index out of bound (array size '%s', used index '%s')\n\n", line_count, size.c_str(), $3->getName().c_str());
						serror_count++;
					}
				}
				else{
					$$->setType("error");
					fprintf(errorout, "Error at line %d : subscripted value is not array\n\n", line_count);
					serror_count++;
				}
			}   else{
					$$->setType("error");
					fprintf(errorout, "Error at line %d : undeclared\n\n", line_count);
					serror_count++;
			}
		 }


		 delete $1;
		 delete $3;
	 }
	 ;

expression : logic_expression {
	fprintf(logout, "At line no: %d expression : logic_expression\n", line_count);
	$$ = new SymbolInfo();
	string str = $1->getName();
	$$->setName(str);
	$$->setType($1->getType());
	fprintf(logout, "\n%s\n\n", str.c_str());
	delete $1;
}
	   | variable ASSIGNOP logic_expression {
		   fprintf(logout, "At line no: %d expression : variable ASSIGNOP logic_expression\n", line_count);
		   $$ = new SymbolInfo();
		   string str = $1->getName() + " = " + $3->getName();
		   $$->setName(str);
		   $$->setType($1->getType());

		   if($1->getType() != $3->getType()) {
			   if($3->getType() == "void") {
					fprintf(errorout, "Error at line %d : 'void' type cannot be assigned\n\n", line_count);
					serror_count++;
			   } else if($3->getType() != "error" && $1->getType() != "error") {
			   		fprintf(errorout, "Error at line %d : operands types mismatch (have '%s' and '%s' )\n\n", line_count, $1->getType().c_str(), $3->getType().c_str());
					serror_count++;
			   }
			   $$->setType("error");
		   }

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
	$$->setType($1->getType());
	fprintf(logout, "\n%s\n\n", str.c_str());
	delete $1;
}
		 | rel_expression LOGICOP rel_expression {
			 fprintf(logout, "At line no: %d logic_expression : rel_expression LOGICOP rel_expression\n", line_count);
			 $$ = new SymbolInfo();
		  	 string str = $1->getName() + " " + $2->getName() + " " + $3->getName();
		  	 $$->setName(str);
			 $$->setType("int");
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
	$$->setType($1->getType());
	fprintf(logout, "\n%s\n\n", str.c_str());
	delete $1;
}
		| simple_expression RELOP simple_expression {
			fprintf(logout, "At line no: %d rel_expression	: simple_expression RELOP simple_expression\n", line_count);
			$$ = new SymbolInfo();
		  	string str = $1->getName() + " " + $2->getName() + " " + $3->getName();
		  	$$->setName(str);
			$$->setType("int");
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
	$$->setType($1->getType());
	fprintf(logout, "\n%s\n\n", str.c_str());
	delete $1;
}
		  | simple_expression ADDOP term {
			  fprintf(logout, "At line no: %d simple_expression : simple_expression ADDOP term\n", line_count);
			  $$ = new SymbolInfo();
		  	  string str = $1->getName() + " " + $2->getName() + " " + $3->getName();
		  	  $$->setName(str);

			  if($1->getType() == "float" || $2->getType() == "float")	$$->setType("float");
			  else $$->setType("int");

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
	$$->setType($1->getType());
	fprintf(logout, "\n%s\n\n", str.c_str());
	delete $1;
}
     |  term MULOP unary_expression {
		 fprintf(logout, "At line no: %d term : term MULOP unary_expression\n", line_count);
		 $$ = new SymbolInfo();
		 string str = $1->getName() + $2->getName() + $3->getName();
		 $$->setName(str);

		 if($1->getType() == "float" || $3->getType() == "float")	$$->setType("float");
		 else $$->setType("int");

		 if($2->getName() == "%" && ($1->getType() == "float" || $3->getType() == "float")) {
			$$->setType("error");
			fprintf(errorout, "Error at line %d : invalid operands to binary % (have '%s' and '%s')\n\n", line_count, $1->getType().c_str(), $3->getType().c_str());
			serror_count++;
		 }

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
	$$->setType($2->getType());

	fprintf(logout, "\n%s\n\n", str.c_str());
	delete $1;
	delete $2;
}
		 | NOT unary_expression {
			 fprintf(logout, "At line no: %d unary_expression : NOT unary_expression\n", line_count);
			 $$ = new SymbolInfo();
		  	 string str = "!" + $2->getName();
		  	 $$->setName(str);
			 $$->setType("int");
		  	 fprintf(logout, "\n%s\n\n", str.c_str());
			 delete $2;
		 }
		 | factor {
			 fprintf(logout, "At line no: %d unary_expression : factor\n", line_count);
			 $$ = new SymbolInfo();
		  	 string str = $1->getName();
		  	 $$->setName(str);
			 $$->setType($1->getType());
		  	 fprintf(logout, "\n%s\n\n", str.c_str());
			 delete $1;
		 }
		 ;

factor	: variable {
	fprintf(logout, "At line no: %d factor : variable\n", line_count);
	$$ = new SymbolInfo();
	string str = $1->getName();
	$$->setName(str);
	$$->setType($1->getType());
	fprintf(logout, "\n%s\n\n", str.c_str());
	delete $1;
}
	| ID LPAREN argument_list RPAREN {
		fprintf(logout, "At line no: %d factor : ID LPAREN argument_list RPAREN\n", line_count);
		$$ = new SymbolInfo();
		string str = $1->getName() + "(" + $3->getName() + ")";
		$$->setName(str);
		SymbolInfo* symbol = table->lookUp($1->getName());
		if(symbol){
			if(symbol->parameterList[symbol->parameterList.size() -1] == "function"){
				bool matched = true;
				for(int i = 0; i < $3->parameterList.size(); i++){
					if($3->parameterList[i] != symbol->parameterList[i+1]) matched = false;
				}
				if(matched == false) {
					fprintf(errorout , "Error at line %d : function arguments types not matched\n\n", line_count);
					$$->setType("error");
					serror_count++;
				} else $$->setType(symbol->parameterList[0]);
			} 
			else{
				$$->setType("error");
				fprintf(errorout, "Error at line %d : '%s' is not a function\n\n", line_count, $1->getName().c_str());
				serror_count++;
			}
		} else{
			$$->setType("error");
			fprintf(errorout, "Error at line %d : function '%s' not declared\n\n", line_count, $1->getName().c_str());
			serror_count++;
		}

		fprintf(logout, "\n%s\n\n", str.c_str());

		delete $1;
		delete $3;
	}
	| LPAREN expression RPAREN {
		fprintf(logout, "At line no: %d factor : LPAREN expression RPAREN\n", line_count);
		$$ = new SymbolInfo();
		string str = "(" + $2->getName() + ")";
		$$->setName(str);
		$$->setType($2->getType());
		fprintf(logout, "\n%s\n\n", str.c_str());
		delete $2;
	}
	| CONST_INT {
		fprintf(logout, "At line no: %d factor : CONST_INT\n", line_count);
		$$ = new SymbolInfo();
		string str = $1->getName();
		$$->setName(str);
		$$->setType("int");
		fprintf(logout, "\n%s\n\n", str.c_str());
		delete $1;
	}
	| CONST_FLOAT {
		fprintf(logout, "At line no: %d factor : CONST_FLOAT\n", line_count);
		$$ = new SymbolInfo();
		string str = $1->getName();
		$$->setName(str);
		$$->setType("float");
		fprintf(logout, "\n%s\n\n", str.c_str());
		delete $1;
	}
	| variable INCOP {
		fprintf(logout, "At line no: %d factor : variable INCOP\n", line_count);
		$$ = new SymbolInfo();
		string str = $1->getName() + "++";
		$$->setName(str);
		$$->setType($1->getType());
		fprintf(logout, "\n%s\n\n", str.c_str());
		delete $1;
	}
	| variable DECOP {
		fprintf(logout, "At line no: %d factor : variable DECOP\n", line_count);
		$$ = new SymbolInfo();
		string str = $1->getName() + "--";
		$$->setName(str);
		$$->setType($1->getType());
		fprintf(logout, "\n%s\n\n", str.c_str());
		delete $1;
	}
	;

argument_list : arguments {
	fprintf(logout, "At line no: %d argument_list : arguments\n", line_count);
	$$ = new SymbolInfo();
	string str = $1->getName();
	$$->setName(str);
	$$->parameterList.insert($$->parameterList.end(), $1->parameterList.begin(), $1->parameterList.end());
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
	$$->parameterList.insert($$->parameterList.end(), $1->parameterList.begin(), $1->parameterList.end());
	$$->parameterList.push_back($3->getType());
	fprintf(logout, "\n%s\n\n", str.c_str());
	delete $1;
	delete $3;
}
	      | logic_expression {
			  fprintf(logout, "At line no: %d arguments : logic_expression\n", line_count);
			  $$ = new SymbolInfo();
			  string str = $1->getName();
			  $$->setName(str);
			  $$->parameterList.push_back($1->getType());
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
	fprintf(logout, "Total lines: %d\n\n", line_count);
	fprintf(logout, "Total errors: %d\n", serror_count);
    fprintf(errorout, "Total errors: %d\n", serror_count);
	fclose(yyin);
	fclose(logout);
	fclose(fp);

	return 0;
}

bool matchFunction(vector<string> &a, vector<string> &b) {
	if(a.size() == b.size()) {
		for(int i = 0; i < a.size(); i++) {
			if(a[i] != b[i]) return false;
		}
	}
	else return false;
	return true;
}