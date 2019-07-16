//
// Created by tushar on 5/8/19.
//

#ifndef SYMBOL_TABLE_SCOPETABLE_H
#define SYMBOL_TABLE_SCOPETABLE_H
#include "1605070_SymbolInfo.h"

class ScopeTable {
protected:
    // used for unique id
    static int totalSt;

private:
    SymbolInfo **symbolBucket;
    ScopeTable *parentScope;
    FILE* logout;
    int totalBucket;
    int id;
    int hashFunction(string str);

public:
    // working methods
    bool insert(const string& name, const string& type);

    bool insert(SymbolInfo* info);

    SymbolInfo *lookUp(const string& name);

    bool deleteSymbol(const string& name);

    void print();

    //constructors
    explicit ScopeTable(int bucketNo, FILE* fileout);
    explicit ScopeTable(int bucketNo);
    ScopeTable(int bucketNo, ScopeTable *parentScope);

    // getter and setter
    static int getTotalSt();

    ScopeTable *getParentScope() const;

    void setParentScope(ScopeTable *parentScope);

    int getId() const;

    // destructor
    ~ScopeTable();

};


#endif //SYMBOL_TABLE_SCOPETABLE_H
