//
// Created by tushar on 5/8/19.
//

#include "1605070_ScopeTable.h"
#include <iostream>
#include <assert.h>

using namespace std;

ScopeTable::ScopeTable(int bucketNo) : totalBucket(bucketNo) {
    symbolBucket = new SymbolInfo *[bucketNo];
    for(int i = 0; i < bucketNo; i++)
        symbolBucket[i] = nullptr;
    parentScope = nullptr;
    id = ++totalSt;
}
ScopeTable::ScopeTable(int bucketNo, FILE* log) : totalBucket(bucketNo) {
    logout = log;
    symbolBucket = new SymbolInfo *[bucketNo];
    for(int i = 0; i < bucketNo; i++)
        symbolBucket[i] = nullptr;
    parentScope = nullptr;
    id = ++totalSt;
}
int ScopeTable::totalSt = 0;

ScopeTable::~ScopeTable() {
    if (symbolBucket) {
        delete[] symbolBucket;
    }
}

int ScopeTable::getTotalSt() {
    return totalSt;
}


ScopeTable *ScopeTable::getParentScope() const {
    return parentScope;
}

void ScopeTable::setParentScope(ScopeTable *parentScope) {
    ScopeTable::parentScope = parentScope;
}

int ScopeTable::getId() const {
    return id;
}

ScopeTable::ScopeTable(int bucketNo, ScopeTable *parentScope) : totalBucket(bucketNo), parentScope(parentScope) {
    symbolBucket = new SymbolInfo *[totalBucket];
}

bool ScopeTable::insert(const string &name, const string &type) {
    SymbolInfo *symbol = new SymbolInfo(name, type);
    int listLength = 0;
    int index = hashFunction(name);
    assert(index >= 0 and index < totalBucket);
    if (symbolBucket[index] == nullptr)
        symbolBucket[index] = symbol;
    else {
        SymbolInfo *last = symbolBucket[index];
        listLength++;
        while (last->getNext() && last->getName() != name) {
            listLength++;
            last = last->getNext();
        }
        if(last->getName() == name) {
            //cout << "<" + name + "," + type + ">" + " already exits in current ScopeTable" << endl << endl;
            // fprintf(logout, "<%s, %s> already exists in current ScopeTable\n", name.c_str(), type.c_str());
            return false;
        }
        else last->setNext(symbol);
    }
    //printf("Inserted in ScopeTable# %d at position %d, %d\n\n", id, index, listLength);
    return true;
}

bool ScopeTable::insert(SymbolInfo* info) {
    int listLength = 0;
    int index = hashFunction(info->getName());
    assert(index >= 0 and index < totalBucket);
    if (symbolBucket[index] == nullptr)
        symbolBucket[index] = info;
    else {
        SymbolInfo *last = symbolBucket[index];
        listLength++;
        while (last->getNext()) {
            listLength++;
            last = last->getNext();
        }
        last->setNext(info);
    }
    return true;
}

SymbolInfo *ScopeTable::lookUp(const string &name) {
    int index = hashFunction(name);
    int listLength = 0;
    SymbolInfo *last = symbolBucket[index];
    if (last == nullptr) {
        // cout << "Not Found" << endl << endl;
        return nullptr;
    }
    do {
        if (last->getName() == name) break;
        listLength++;
        last = last->getNext();
        if (last == nullptr) break;
    } while (true);
    if (last != nullptr) {
        // printf("Found in ScopeTable# %d at position %d, %d\n\n", id, index, listLength);
        return last;
    }
    // cout << "Not Found" << endl << endl;
    return nullptr;
}

bool ScopeTable::deleteSymbol(const string &name) {
    int index = hashFunction(name);
    int listLength = 0;
    SymbolInfo *prev = symbolBucket[index];
    if (prev == nullptr) return false;
    SymbolInfo *current = prev->getNext();
    if (prev->getName() == name) {
        symbolBucket[index] = current;
        delete prev;
        // printf("Deleted entry at %d, %d from current ScopeTable\n\n", index, listLength);
        return true;
    }
    while (current != nullptr) {
        listLength++;
        if (current->getName() == name) {
            prev->setNext(current->getNext());
            delete current;
            // printf("Deleted entry at %d, %d from current ScopeTable\n\n", index, listLength);
            return true;
        }
        prev = current;
        current = current->getNext();
    }
    // cout << name + " not found" << endl << endl;
    return false;
}

void ScopeTable::print() {
    cout << "ScopeTable # " << id << endl;
    // fprintf(logout, "ScopeTable # %d\n", id);
    for (int i = 0; i < totalBucket; i++) {
        if(symbolBucket[i] == nullptr) continue;
        cout << i << " ---> ";
        // fprintf(logout, "%d ---> ", i);
        SymbolInfo *current = symbolBucket[i];
        while (current != nullptr) {
            cout << "< " << current->getName() << " : " << current->getType() << ">  ";
            // fprintf(logout, "<%s : %s> ", current->getName().c_str(), current->getType().c_str());
            current = current->getNext();
        }
        cout << endl;
        // fprintf(logout, "\n");
    }
    cout << endl;
    // fprintf(logout, "\n");
}

int ScopeTable::hashFunction(string str) {
    long hash = 5381;
    int c;
    for (int i = 0; i < str.length(); i++) {
        c = str[i];
        hash = ((hash << 5) + hash) + c;
    }
    return abs((int) hash % totalBucket);
}
