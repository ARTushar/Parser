//
// Created by tushar on 5/8/19.
//

#ifndef SYMBOL_TABLE_SYMBOLINFO_H
#define SYMBOL_TABLE_SYMBOLINFO_H

#include <string>
#include <vector>
using namespace std;

class SymbolInfo {
private:
    string name;
    string type;
    SymbolInfo *next;

public:
    vector<string> parameterList;

    SymbolInfo();

    SymbolInfo(string name, string type);

    const string &getName() const;

    SymbolInfo *getNext() const;

    void setNext(SymbolInfo *next);


    void setName(const string &name);

    const string &getType() const;

    void setType(const string &type);

    ~SymbolInfo();

};


#endif //SYMBOL_TABLE_SYMBOLINFO_H
