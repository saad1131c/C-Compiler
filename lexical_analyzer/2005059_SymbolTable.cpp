#include <iostream>
#include <fstream>
#include <string>

using namespace std;

ofstream com("2005059_log.txt");











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










class ScopeTable {
    SymbolInfo *table;
    int bucketSize;
    int created_tables;
    string id;

    unsigned long long sdbm(string str) {
        unsigned long long hash = 0;
        int c = 0, i = 0;
        while (c = str[i]) {
            hash = c + (hash << 6) + (hash << 16) - hash;
            i++;
        }

        return hash;
    }

public:

    ScopeTable *parentScope;

    ScopeTable() {}

    ScopeTable(int size) {
        bucketSize = size;
        table = new SymbolInfo[size];
        parentScope = NULL;
        created_tables = 0;
        id = "";
    }

    ScopeTable(ScopeTable *parentScope) {
        table = new SymbolInfo[bucketSize];
        this->parentScope = parentScope;
    }

    ~ScopeTable() {
        delete[] table;
    }


    SymbolInfo *Lookup(const string &s) {
        SymbolInfo *sym;
        int hash = sdbm(s) % bucketSize;
        sym = table + hash;
        while (sym) {
            if (sym->getName() == s) return sym;
            sym = sym->next;
        }
        return NULL;
    }

    bool Insert(string name, string type) {
        if (Lookup(name)) return false;

        SymbolInfo s(name, type);
        SymbolInfo *sym;

        int hash = sdbm(name) % bucketSize;
        sym = table + hash;

        if (sym->getName() == "") {
            table[hash] = SymbolInfo(name, type);
            return true;
        }

        while (sym->next) {
            sym = sym->next;
        }

        sym->next = new SymbolInfo(name, type);
        return true;
    }

    bool Delete(const string &s) {
        if (Lookup(s) == NULL) return false;

        SymbolInfo *sym;
        int hash = sdbm(s) % bucketSize;
        sym = table + hash;

        if (sym->getName() == s) {
            if (sym->next == NULL) table[hash] = SymbolInfo();
            else {
                table[hash] = *sym->next;
            }
            return true;
        }

        SymbolInfo *ptr = Lookup(s);

        while (sym->next != ptr) {
            sym = sym->next;
        }

        sym->next = ptr->next;
        return true;

    }

    void Print() {
        com << "\tScopeTable# " << id << endl;
        for (int i = 0; i < bucketSize; i++) {
            com << "\t" << i + 1;
            if (table[i].getName() != "") {
                SymbolInfo *trav = table + i;
                while (trav) {
                    com << " --> ";
                    com << "(" << trav->getName() << "," << trav->getType() << ")";
                    trav = trav->next;
                }
            }
            com << endl;
        }
    }

    void Increment() {
        created_tables++;
    }

    void setId() {
        if (parentScope == NULL) {
            id += "1";
            return;
        }
        id = parentScope->id + "." + to_string(parentScope->created_tables);
    }
};














class SymbolTable {
    ScopeTable *current;
    int bucketSize;

public:
    SymbolTable(int size) {
        current = new ScopeTable(size);
        bucketSize = size;
        current->parentScope = NULL;
        current->setId();
    }

    bool Insert(string name, string type) {
        return current->Insert(name, type);
    }

    bool Remove(string name) {
        return current->Delete(name);
    }

    void EnterScope() {
        ScopeTable *temp = current;
        current = new ScopeTable(bucketSize);
        current->parentScope = temp;
        temp->Increment();
        current->setId();
    }

    void ExitScope() {
        if (current->parentScope == NULL) {
            return;
        }
        ScopeTable *temp = current;
        current = current->parentScope;
        delete temp;
    }

    SymbolInfo *Lookup(string name) {
        ScopeTable *temp = current;
        while (temp) {
            SymbolInfo *s = temp->Lookup(name);
            if (s != NULL) return s;
            temp = temp->parentScope;
        }
        return NULL;
    }

    void PrintCurrentScope() {
        current->Print();
    }

    void PrintAllScope() {
        ScopeTable *temp = current;
        while (temp) {
            temp->Print();
            temp = temp->parentScope;
        }
    }

    void quit() {
        ScopeTable *temp = current;
        while (temp) {
            ExitScope();
            temp = temp->parentScope;
        }
    }

};

