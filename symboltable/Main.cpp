#include "SymbolTable.h"
#include <sstream>

int main() {
    string s;
    freopen("Input.txt", "r", stdin);
    freopen("Output.txt", "w", stdout);
    int size;
    string str[3];
    cin >> size;
    SymbolTable table(size);
    cout << "\tScopeTable# 1 created" << endl;
    getline(cin, s);
    int j = 0;
    while (getline(cin, s)) {
        cout << "Cmd " << ++j << ": " << s << endl;

        stringstream ss(s);
        string word;
        int i = 0;
        while (ss >> word) {
            if (i < 3) { str[i] = word; }
            i++;
        }

//        cout << s << endl;
//        cout << str[0] << " ";

        string w = str[0];

        if (w == "I") {
            if (i != 3) cout << "\tWrong number of arugments for the command I" << endl;
            else {
                table.Insert(str[1], str[2]);
//                cout << str[1] << " " << str[2] << endl << endl;
            }
        } else if (w == "L") {
            if (i != 2) cout << "\tWrong number of arugments for the command L" << endl;
            else {
                table.Lookup(str[1]);
            }
        } else if (w == "P") {
            if (i != 2) cout << "\tWrong number of arugments for the command P" << endl;
            else {
                if (str[1] == "C") table.PrintCurrentScope();
                else if (str[1] == "A") table.PrintAllScope();
                else {
                    cout << "\tInvalid argument for the command P" << endl;
                }
            }
        } else if (w == "D") {
            if (i != 2) cout << "\tWrong number of arugments for the command D" << endl;
            else {
                table.Remove(str[1]);
            }
        } else if (w == "S") {
            if (i != 1) cout << "\tWrong number of arugments for the command S" << endl;
            else {
                table.EnterScope();
            }
        } else if (w == "E") {
            if (i != 1) cout << "\tWrong number of arugments for the command E" << endl;
            else {
                table.ExitScope();
            }
        } else if (w == "Q") {
            if (i != 1) cout << "\tWrong number of arugments for the command Q" << endl;
            else {
                table.quit();
            }
        } else {
            cout << "\tInvalid Instruction" << endl;
        }
    }
    return 0;
}