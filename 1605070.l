%option noyywrap
%x comment
%x STR
%{
    #include "1605070_SymbolTable.h"
    #include <cstdio>
    #include <cstdlib>
    #include <string>
    #include "y.tab.h"

    using namespace std;

    int line_count = 1;
    int total_error = 0;
    // FILE *logout  = fopen("log.txt","w");
    // FILE *tokenout = fopen("token.txt","w");
    extern "C" int yylex();

    string current_comment = "";
    string current_str = "";
    int comment_start_line;

    // extern YYSTYPE yylval;
    void yyerror(char *);
    SymbolInfo* symbol;


    void strupr(char *str);
    void print_log(const char *type, const char *symbol);
    void filter_string(string& str);
    void error_print(const char *message, const char *symbol);
    void count_line_str(string str);

%}

DIGIT [0-9]+

%%

 /* identifying keywords */

"if" {return IF;}
"else" {return ELSE;}
"for" {return FOR;}
"while" {return WHILE;}
"int" {return INT;}
"char" {return CHAR;}
"float" {return FLOAT;}
"double" {return DOUBLE;}
"void" {return VOID;}
"return" {return RETURN;}
"println" {return PRINTLN;}
 /* identifying constants */

{DIGIT} {

    // fprintf(tokenout, "<CONST_INT, %s> ", yytext);
    // print_log("CONST_INT", yytext);
    string text(yytext);
    symbol = new SymbolInfo(text, "CONST_INT");
    yylval.info = symbol;
    return CONST_INT;

}
{DIGIT}[a-zA-Z_]+ {
    string message = "Invalid prefix on ID or invalid suffix on Number";
    // error_print(message.c_str(), yytext);
    total_error++;
}

[0-9]*\.{DIGIT}([eE][-+]?{DIGIT})? |
{DIGIT}[eE][-+]?{DIGIT} {

    // fprintf(tokenout, "<CONST_FLOAT, %s> ", yytext);
    // print_log("CONST_FLOAT", yytext);
    symbol = new SymbolInfo(string(yytext), "CONST_FLOAT");
    yylval.info = symbol;
    return CONST_FLOAT;
}

[0-9]*\.([0-9]*\.)+[0-9]* {
    string message = "Too many decimal point";
    // error_print(message.c_str(), yytext);
    total_error++;
}

[0-9]*\.?{DIGIT}[eE][-+]?([0-9]*\.)+[0-9]* {
    string message = "Ill formed number";
    // error_print(message.c_str(), yytext);
    total_error++;
}

 /* identifying characters */

\'(\\n|\\t|\\\\|\\\"|\\a|\\f|\\r|\\b|\\v|\\0)\' {
    string str(yytext);
    filter_string(str);
    // fprintf(tokenout, "<CONST_CHAR, %s> ", str.c_str());
    // print_log("CONST_CHAR", str.c_str());
    symbol = new SymbolInfo(string(yytext), "CONST_CHAR");
    // yylval = symbol;
    // return CONST_CHAR;

}

\'\\[^nt\\\"afrbv0\'\n] {
    string message = "Unrecogized character constant error";
    // error_print(message.c_str(), yytext);
    total_error++;
}

\'[^\\\n][^\n]+\' {
    string message = "Multi character constant error";
    // error_print(message.c_str(), yytext);
    total_error++;
}


\'[^\n\\]\' {
    string str = "";
    str += yytext[1];
    // fprintf(tokenout, "<CONST_CHAR, %c> ", yytext[1]);
    // print_log("CONST_CHAR", str.c_str());
}
\'[\\]\'|\'[^\n\\\'][^\'\n] {
    string message = "Unterminated character";
    string text(yytext);
    // text.pop_back();
    // error_print(message.c_str(), text.c_str());
    total_error++;
}
\'[^\']?[\n] {
    string message = "Unterminated character";
    string text(yytext);
    text.pop_back();
    // error_print(message.c_str(), text.c_str());
    total_error++;
    line_count++;
}

\'\' {
    string message = "Empty character constant error";
    // error_print(message.c_str(), yytext);
    total_error++;
}
 /* operators and punctuators */
[-+] {
    // fprintf(tokenout, "<ADDOP, %s> ", yytext);
    // print_log("ADDOP", yytext);;
    symbol = new SymbolInfo(string(yytext), "ADDOP");
    yylval.info = symbol;
    return ADDOP;
}

[*/%] {
    // fprintf(tokenout, "<MULOP, %s> ", yytext);
    // print_log("MULOP", yytext);
    symbol = new SymbolInfo(string(yytext), "MULOP");
    yylval.info = symbol;
    return MULOP;
}

\+\+ {
    // fprintf(tokenout, "<INCOP, %s> ", yytext);
    // print_log("INCOP", yytext);
    return INCOP;

}

-- { return DECOP; }

\<=|\<|\>=|\>|==|!= {
    // fprintf(tokenout, "<RELOP, %s> ", yytext);
    // print_log("RELOP", yytext);
    symbol = new SymbolInfo(string(yytext), "RELOP");
    yylval.info = symbol;
    return RELOP;

}

= {
    // fprintf(tokenout, "<ASSIGNOP, %s> ", yytext);
    // print_log("ASSIGNOP", yytext);
    return ASSIGNOP;
}

&&|\|\| {
    // fprintf(tokenout, "<LOGICOP, %s> ", yytext);
    // print_log("LOGICOP", yytext);
    symbol = new SymbolInfo(string(yytext), "LOGICOP");
    yylval.info = symbol;
    return LOGICOP;

}

&|\||\^|<<|>> {
    // fprintf(tokenout, "<BITOP, %s> ", yytext);
    // print_log("BITOP", yytext);
   // return BITOP;

}

! {
    // fprintf(tokenout, "<NOT, !>");
    // print_log("NOT", yytext);
    return NOT;

}

\) {
    // fprintf(tokenout, "<RPAREN, )> ");
    // print_log("RPAREN", yytext);
    return RPAREN;
}

\( {
    // fprintf(tokenout, "<LPAREN, (> ");
    // print_log("LPAREN", yytext);
    return LPAREN;
}

\{ {
    // fprintf(tokenout, "<LCURL, {> ");
    // print_log("LCURL", yytext);
    return LCURL;
}

\} {
    // fprintf(tokenout, "<RCURL, }> ");
    // print_log("RCURL", yytext);
    return RCURL;
}

\[ {
    // fprintf(tokenout, "<LTHIRD, [> ");
    // print_log("LTHIRD", yytext);
    return LTHIRD;

}

\] {
    // fprintf(tokenout, "<RTHIRD, ]> ");
    // print_log("RTHIRD", yytext);
    return RTHIRD;
}

, {
    // fprintf(tokenout, "<COMMA, ,> ");
    // print_log("COMMA", yytext);
    return COMMA;

}

; {
    // fprintf(tokenout, "<SEMICOLON, ;> ");
    // print_log("SEMICOLON", yytext);
    return SEMICOLON;

}



 /* Identifiers */

[a-zA-Z_][a-zA-Z_0-9]* {
    // fprintf(tokenout, "<ID, %s> ", yytext);
    // print_log("ID", yytext);
    symbol = new SymbolInfo(string(yytext), "ID");
    yylval.info = symbol;
    return ID;
}

[0-9]+[a-zA-Z_0-9]+ {
    string message = "Invalid prefix on ID or invalid suffix on Number";
    // error_print(message.c_str(), yytext);
    total_error++;
}

 /* strings */

(\"[^"\n]*\\(\n[^"\n]*\\)*\n[^"\n]*\")|(\"[^"\n]*\") {
    string str(yytext);
    filter_string(str);
    // fprintf(tokenout, "<STRING, %s> ", str.c_str());
    // print_log("STRING", str.c_str());
    symbol = new SymbolInfo(string(yytext), "STRING");
    // return CONST_INT;

}

(\"[^"\n]*\\(\n[^"\n]*\\)*\n[^\"\n]*)|(\"[^"\n]*[^\\]) {
    string message = "Unterminated string";
    string test(yytext);
    count_line_str(test);
    // error_print(message.c_str(), yytext);
    total_error++;
}


 /* comment */
\/\* { comment_start_line = line_count; BEGIN comment;}
<comment>\*\/ {
    // print_log("COMMENT", current_comment.c_str());
    current_comment = "";
    BEGIN INITIAL;
}
<comment>[\n] {
     current_comment += yytext;
     line_count++;
}
<comment>([^*\n])+|. { current_comment += yytext; }
<comment><<EOF>> {
    string message = "Unterminated comment";
    // fprintf(logout, "Error at line %d: %s %s\n\n", comment_start_line, message.c_str(), current_comment.c_str());
    total_error++;
    current_comment = "";
    BEGIN INITIAL;
}

\/\/.*\\\n([^\n]+\\\n)*[^\n]*\n|\/\/.*\n {
    string str(yytext);
    str.erase(0,2);
    str.pop_back();
    // print_log("COMMENT", str.c_str());
    line_count++;
}

 /*line count */
[\n] { line_count++; }

  /* white space */
[ \t]+ { }


%%

/* int main(int argc, char *argv[]) {

    if(argc != 2) {
        printf("Please input the fileName\n");
        return 1;
    }

    FILE *finp = fopen(argv[1], "r");

    if(!finp) {
        printf("Cannot open the input file\n");
        return 1;
    }

    yyin = finp;
	yylex();
    fprintf(logout, "Total lines: %d\n", line_count);
    fprintf(logout, "Total errors: %d\n", total_error);
	fclose(yyin);
	fclose(tokenout);
	fclose(logout);

	return 0;
} */

void print_log(const char *type, const char *symbol){
    // fprintf(logout, "Line no. %d: Token <%s> Lexeme %s found\n\n", line_count, type, symbol);
}

void error_print(const char *message, const char *symbol) {
    // fprintf(logout, "Error at line %d: %s %s\n\n", line_count, message, symbol);
}

void strupr(char *str) {
    for(int i = 0; i < strlen(str); i++){
        str[i] = toupper(str[i]);
    }
}

void count_line_str(string str) {
    for(int i = 0; i < str.size(); i++){
        if(str[i] == '\n'){
            line_count++;
        }
    }
}

void filter_string(string& str) {
    str.pop_back();
    str.erase(0,1);
    int i = 0;
    for(; i < str.size()-1; i++) {
        if(str[i] == '\\'){
            if(str[i+1] == 'n') {
                str.replace(i, 2, 1,'\n');
                i++;
            } else if(str[i+1] == 'r'){
                str.replace(i, 2, 1, '\r');
                i++;
            } else if(str[i+1] == 't'){
                str.replace(i, 2, 1, '\t');
                i++;
            } else if(str[i+1] == '\\'){
                str.replace(i, 2, 1, '\\');
                i++;
            } else if(str[i+1] == '"'){
                str.replace(i, 2, 1, '"');
                i++;
            } else if(str[i+1] == 'a'){
                str.replace(i, 2, 1, '\a');
                i++;
            } else if(str[i+1] == 'f'){
                str.replace(i, 2, 1, '\f');
            } else if(str[i+1] == 'v'){
                str.replace(i, 2, 1, '\v');
                i++;
            } else if(str[i+1] == 'b'){
                str.replace(i, 2, 1, '\b');
                i++;
            } else if(str[i+1] == '0'){
                str.replace(i, 2, 1, '\0');
                i++;
            } else if(str[i+1] == '\n'){
                line_count++;
                str.replace(i, 2, "");
            }
        }
    }
}