//
// Created by tushar on 5/8/19.
//

#include "1605070_SymbolInfo.h"

SymbolInfo::SymbolInfo(){
    name = "";
    type = "";
    next = nullptr;
}

SymbolInfo::SymbolInfo(string name, string type)
: name(std::move(name)), type(std::move(type)) {
    next = nullptr;
}

const string & SymbolInfo::getName() const {
    return name;
}

SymbolInfo * SymbolInfo::getNext() const {
    return next;
}

void SymbolInfo::setNext(SymbolInfo *next) {
    SymbolInfo::next = next;
}


void SymbolInfo::setName(const string &name) {
    SymbolInfo::name = name;
}

const string &SymbolInfo::getType() const {
    return type;
}

void SymbolInfo::setType(const string &type) {
    SymbolInfo::type = type;
}


SymbolInfo::~SymbolInfo() {

}
