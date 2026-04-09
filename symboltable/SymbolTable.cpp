#include "ScopeTable.cpp"

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

/*int main() {
    SymbolTable s(7);
    s.Insert("foo", "FUNCTION");
    s.Insert("i", "VAR");
    s.Insert("23", "NUMBER");
    s.PrintCurrentScope();
    s.Remove("i");
    s.Remove("j");
    s.PrintAllScope();
    s.EnterScope();
    s.Insert("<=", "RELOP");
    s.Insert("==", "RELOP");
    s.PrintAllScope();
    s.Insert(">=", "RELOP");
    s.PrintCurrentScope();
    return 0;
}*/
