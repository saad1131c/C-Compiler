#include <bits/stdc++.h>

using namespace std;

class SymbolInfo {
    string name;
    string type;

public:

    SymbolInfo *next;

    SymbolInfo() {
        name = "";
        type = "";
        next = NULL;
    }

    SymbolInfo(const string &name, const string &type) {
        this->name = name;
        this->type = type;
        next = NULL;
    }
    
    string getName() {
        return name;
    }

    string getType() {
        return type;
    }
};