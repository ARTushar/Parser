bison -d -y 1605070.y
g++ -w -c -o bison.o y.tab.c 
flex -o lexer.c 1605070.l 
g++ -w -c -o lexer.o lexer.c 
g++ -o final.out bison.o lexer.o 1605070_SymbolTable.cpp 1605070_ScopeTable.cpp 1605070_SymbolInfo.cpp -lfl -ly