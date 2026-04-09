#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <utility>
#include <climits>

using namespace std;
extern ofstream com;
extern ofstream tree;
extern ofstream code;

class SymbolInfo
{
    string name;
    string type;
    string varType;
    string returnType;
    string cfg;
    pair<int, int> line;
    bool terminal;
    bool global;
    int number_of_arg;

public:
    string endlabel;
    SymbolInfo *next;
    vector<SymbolInfo *> children;
    int arraySize;
    bool conditional;
    string truelabel;
    string falselabel;
    int offset;
    int total_local_var;

    SymbolInfo()
    {
        name = "";
        type = "";
        varType = "";
        returnType = "";
        next = NULL;
        cfg = "";
        line.first = -1;
        line.second = -1;
        terminal = true;
        arraySize = 0;
        global = false;
        number_of_arg = 0;
        endlabel = "";
        conditional = false;
        truelabel = "";
    }

    SymbolInfo(const string &name, const string &type, string var = "", string ret = "")
    {
        this->name = name;
        this->type = type;
        varType = var;
        returnType = ret;
        next = NULL;
        cfg = type + " : " + name;
        line.first = -1;
        line.second = -1;
        terminal = true;
        arraySize = 0;
        global = false;
        number_of_arg = 0;
        endlabel = "";
        conditional = false;
        truelabel = "";
    }

    SymbolInfo(const string &name, const string &type, const int lineno)
    {
        this->name = name;
        this->type = type;
        varType = "";
        returnType = "";
        next = NULL;
        cfg = type + " : " + name;
        line.first = line.second = lineno;
        terminal = true;
        arraySize = 0;
        global = false;
        number_of_arg = 0;
        endlabel = "";
        conditional = false;
        truelabel = "";
    }

    string getName()
    {
        return name;
    }

    string setName(string s)
    {
        name = s;
    }

    string getType()
    {
        return type;
    }

    string getvarType()
    {
        return varType;
    }

    string getretType()
    {
        return returnType;
    }

    int getLine(string str)
    {
        if (str == "start")
            return line.first;
        else if (str == "end")
            return line.second;
    }

    bool getglobal() { return global; }
    int getarg() { return number_of_arg; }
    string getEndlabel() { return endlabel; }
    void setglobal(bool b) { global = b; }
    void setEndlabel(string l) { endlabel = l; }
    void setarg(int num)
    {
        number_of_arg = num;
    }

    void setVarType(const string &s)
    {
        varType = s;
    }

    void setRetType(const string &s)
    {
        returnType = s;
    }

    void setCFG(string first, string second)
    {
        cfg = first + " : " + second;
    }

    void makechild(SymbolInfo *c)
    {
        // cout << c->line.first << endl;
        if (line.first == -1)
        {
            line.first = c->line.first;
        }
        else
        {
            line.first = min(line.first, c->line.first);
        }
        line.second = max(line.second, c->line.second);
        terminal = false;
        children.push_back(c);
    }

    void printparsetree(int spacecount)
    {
        for (int i = 0; i < spacecount; i++)
            tree << " ";
        tree << cfg;
        if (terminal == true)
            tree << "\t";
        else
            tree << " \t";
        tree << "<Line: ";
        if (terminal == true)
            tree << line.first;
        else
            tree << line.first << "-" << line.second;
        tree << ">" << endl;
        for (auto c : children)
            c->printparsetree(spacecount + 1);
    }
    void printid()
    {
        cout << "<" << name << "," << varType << "," << returnType << ">" << endl;
    }

    bool match(string first, string second)
    {
        string s = first + " : " + second;
        if (cfg == s)
            return true;
        return false;
    }
};

class ScopeTable
{
    SymbolInfo *table;
    int bucketSize;
    int created_tables;
    int id;

    unsigned long long sdbm(string str)
    {
        unsigned long long hash = 0;
        int c = 0, i = 0;
        while (c = str[i])
        {
            hash = c + (hash << 6) + (hash << 16) - hash;
            i++;
        }

        return hash;
    }

public:
    int offset;
    ScopeTable *parentScope;

    ScopeTable() {}

    ScopeTable(int size)
    {
        bucketSize = size;
        table = new SymbolInfo[size];
        parentScope = NULL;
        created_tables = 0;
        offset = 0;
    }

    ScopeTable(ScopeTable *parentScope)
    {
        table = new SymbolInfo[bucketSize];
        this->parentScope = parentScope;
        offset = 0;
    }

    ~ScopeTable()
    {
        delete[] table;
    }

    SymbolInfo *Lookup(const string &s)
    {
        SymbolInfo *sym;
        int hash = sdbm(s) % bucketSize;
        sym = table + hash;
        while (sym)
        {
            if (sym->getName() == s)
                return sym;
            sym = sym->next;
        }
        return NULL;
    }

    bool Insert(SymbolInfo *s)
    {
        if (Lookup(s->getName()))
            return false;

        SymbolInfo *sym;

        int hash = sdbm(s->getName()) % bucketSize;
        sym = table + hash;

        if (sym->getName() == "")
        {
            table[hash] = SymbolInfo(s->getName(), s->getType(), s->getvarType(), s->getretType());
            return true;
        }

        while (sym->next)
        {
            sym = sym->next;
        }

        sym->next = new SymbolInfo(s->getName(), s->getType(), s->getvarType(), s->getretType());
        return true;
    }

    bool Delete(const string &s)
    {
        if (Lookup(s) == NULL)
            return false;

        SymbolInfo *sym;
        int hash = sdbm(s) % bucketSize;
        sym = table + hash;

        if (sym->getName() == s)
        {
            if (sym->next == NULL)
                table[hash] = SymbolInfo();
            else
            {
                table[hash] = *sym->next;
            }
            return true;
        }

        SymbolInfo *ptr = Lookup(s);

        while (sym->next != ptr)
        {
            sym = sym->next;
        }

        sym->next = ptr->next;
        return true;
    }

    void Print()
    {
        com << "\tScopeTable# " << id << endl;
        for (int i = 0; i < bucketSize; i++)
        {
            if (table[i].getName() != "")
            {
                com << "\t" << i + 1 << "-->";
                SymbolInfo *trav = table + i;
                while (trav)
                {
                    com << " ";
                    com << "<" << trav->getName() << ",";
                    if (trav->getvarType() == "ARRAY")
                        com << "ARRAY>";
                    else
                    {
                        if (trav->getvarType() != "")
                            com << trav->getvarType() << "," << trav->getretType() << ">";
                        else
                            com << trav->getretType() << ">";
                    }
                    trav = trav->next;
                }
                com << endl;
            }
        }
    }

    void Increment()
    {
        created_tables++;
    }

    void setId()
    {
        if (parentScope == NULL)
        {
            id = 1;
            return;
        }
        id = parentScope->id + parentScope->created_tables;
    }
    int getId()
    {
        return id;
    }
};

class SymbolTable
{
    ScopeTable *current;
    int bucketSize;

public:
    SymbolTable(int size)
    {
        current = new ScopeTable(size);
        bucketSize = size;
        current->parentScope = NULL;
        current->setId();
    }

    bool Insert(SymbolInfo *s)
    {
        return current->Insert(s);
    }

    bool Remove(string name)
    {
        return current->Delete(name);
    }

    void EnterScope()
    {
        ScopeTable *temp = current;
        current = new ScopeTable(bucketSize);
        current->parentScope = temp;
        temp->Increment();
        current->setId();
    }

    void ExitScope()
    {
        if (current->parentScope == NULL)
        {
            return;
        }
        ScopeTable *temp = current;
        current = current->parentScope;
        delete temp;
    }

    SymbolInfo *Lookup(string name)
    {
        ScopeTable *temp = current;
        while (temp)
        {
            SymbolInfo *s = temp->Lookup(name);
            if (s != NULL)
                return s;
            temp = temp->parentScope;
        }
        return NULL;
    }

    void PrintCurrentScope()
    {
        current->Print();
    }

    void PrintAllScope()
    {
        ScopeTable *temp = current;
        while (temp)
        {
            temp->Print();
            temp = temp->parentScope;
        }
    }

    void quit()
    {
        ScopeTable *temp = current;
        while (temp)
        {
            ExitScope();
            temp = temp->parentScope;
        }
    }
    int getId()
    {
        return current->getId();
    }
    void setoffset(int x)
    {
        current->offset = x;
    }

    int getoffset()
    {
        return current->offset;
    }
};
