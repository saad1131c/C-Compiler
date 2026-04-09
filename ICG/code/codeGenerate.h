#include "SymbolTable.h"
class codeGenerate
{
public:
    SymbolTable *symtable;
    vector<SymbolInfo *> globalList;
    int labelCount;
    string current_func;

    string newlabel()
    {
        return "L" + to_string(labelCount++);
    }

    void print(string s)
    {
        code << "\t" << s << endl;
    }

    void printlabel(string s)
    {
        code << s << ":" << endl;
    }

    string getkeyword(string op)
    {
        string opcode = "";
        if (op == "<")
            opcode = "\tJL";
        else if (op == ">")
            opcode = "\tJG";
        else if (op == ">=")
            opcode = "\tJGE";
        else if (op == "<=")
            opcode = "\tJLE";
        else if (op == "==")
            opcode = "\tJE";
        else if (op == "!=")
            opcode = "\tJNE";
        return opcode;
    }

    void generateCode(SymbolInfo *sym)
    {
        if (sym->match("start", "program"))
        {
            // code << "hello world 1" << endl;
            // code << ".MODEL SMALL" << endl
            //      << ".STACK 1000H" << endl
            //      << ".Data" << endl
            //      << "\tnumber DB 00000$" << endl;
            // for (auto x : globalList)
            // {
            //     if (x->getvarType() == "ARRAY")
            //     {
            //         code << "\t" << x->getName() << " DW " << x->arraySize << " DUP (0000H)" << endl;
            //     }
            //     else
            //     {
            //         code << "\t" << x->getName() << " DW "
            //              << "1"
            //              << " DUP (0000H)" << endl;
            //     }
            // }
            // code << ".CODE" << endl;

            // for (auto child : sym->children)
            // {
            //     generateCode(child);
            // }
            // code << "END main" << endl;

            string newLineProc = "NEWLINE PROC\n\tPUSH AX\n\tPUSH DX\n\tMOV AH,2\n\tMOV DL,CR\n\tINT 21H\n\tMOV AH,2\n\tMOV DL,LF\n\tINT 21H\n\tPOP DX\n\tPOP AX\n\tRET\nNEWLINE ENDP\n";
            string printOutputProc = "PRINTNUMBER PROC  ;PRINT WHAT IS IN AX\n\tPUSH AX\n\tPUSH BX\n\tPUSH CX\n\tPUSH DX\n\tPUSH SI\n\tLEA SI,NUMBER\n\tMOV BX,10\n\tADD SI,4\n\tCMP AX,0\n\tJNGE NEGATE\n\tPRINT:\n\tXOR DX,DX\n\tDIV BX\n\tMOV [SI],DL\n\tADD [SI],'0'\n\tDEC SI\n\tCMP AX,0\n\tJNE PRINT\n\tINC SI\n\tLEA DX,SI\n\tMOV AH,9\n\tINT 21H\n\tPOP SI\n\tPOP DX\n\tPOP CX\n\tPOP BX\n\tPOP AX\n\tRET\n\tNEGATE:\n\tPUSH AX\n\tMOV AH,2\n\tMOV DL,'-'\n\tINT 21H\n\tPOP AX\n\tNEG AX\n\tJMP PRINT\nPRINTNUMBER ENDP\n";
            string header = ";-------\n;\n;-------\n.MODEL SMALL\n.STACK 1000H\n.DATA\n\tCR EQU 0DH\n\tLF EQU 0AH\n\tNUMBER DB \"00000$\"\n";
            code << header;
            for (auto x : globalList)
            {
                if (x->getvarType() == "ARRAY")
                {
                    code << "\t" << x->getName() << " DW " << x->arraySize << " DUP (0000H)" << endl;
                }
                else
                {
                    code << "\t" << x->getName() << " DW "
                         << "1"
                         << " DUP (0000H)" << endl;
                }
            }
            code << ".CODE\n";
            for (auto child : sym->children)
            {
                generateCode(child);
            }
            code << newLineProc;
            code << printOutputProc;
            code << "END main\n";
        }

        else if (sym->match("program", "program unit"))
        {
            // code << "hello world 2" << endl;
            for (auto child : sym->children)
            {
                generateCode(child);
            }
        }

        else if (sym->match("program", "unit"))
        {
            // code << "hello world 3" << endl;
            for (auto child : sym->children)
            {
                generateCode(child);
            }
        }

        else if (sym->match("unit", "var_declaration"))
        {
            // code << "hello world 4" << endl;
            for (auto child : sym->children)
            {
                generateCode(child);
            }
        }

        else if (sym->match("unit", "func_declaration"))
        {
            // code << "hello world 5" << endl;
            for (auto child : sym->children)
            {
                generateCode(child);
            }
        }

        else if (sym->match("unit", "func_definition"))
        {
            // code << "hello world 6" << endl;
            for (auto child : sym->children)
            {
                generateCode(child);
            }
        }

        else if (sym->match("func_declaration", "type_specifier ID LPAREN parameter_list RPAREN SEMICOLON"))
        {
            // code << "hello world 7" << endl;
            for (auto child : sym->children)
            {
                generateCode(child);
            }
        }
        else if (sym->match("func_declaration", "type_specifier ID LPAREN RPAREN SEMICOLON"))
        {
            // code << "hello world 8" << endl;
            for (auto child : sym->children)
            {
                generateCode(child);
            }
        }
        else if (sym->match("func_definition", "type_specifier ID LPAREN parameter_list RPAREN compound_statement"))
        {
            // code << "hello world 9" << endl;
            // for (auto child : sym->children)
            // {
            //     generateCode(child);
            // }

            current_func = sym->children[1]->getName();

            generateCode(sym->children[0]);
            generateCode(sym->children[3]);

            code << sym->children[1]->getName() << " "
                 << "PROC" << endl;

            if (sym->children[1]->getName() == "main")
            {
                print("MOV AX, @DATA");
                print("MOV DS, AX");
            }

            print("PUSH BP");
            print("MOV BP, SP");

            generateCode(sym->children[5]);

            // sym->children[1]->endlabel = newlabel();

            // printlabel(sym->children[1]->endlabel);

            code << sym->children[1]->getName() << "_exit:" << endl;

            if (sym->children[1]->getName() == "main")
            {
                print("MOV AX, 4CH");
                print("INT 21H");
            }

            if (sym->children[5]->total_local_var > 0 || true)
            {
                code << "\t"
                     << "ADD SP, " << -1 * sym->children[5]->offset << endl;
            }

            print("POP BP");

            if (sym->children[1]->getName() != "main")
            {
                code << "\tRET" << endl;
                // code << "\tRET " << sym->children[3]->getarg() * 2 << endl;
            }

            code << sym->children[1]->getName() << " "
                 << "ENDP" << endl;
            // current_func = "";
        }
        else if (sym->match("func_definition", "type_specifier ID LPAREN RPAREN compound_statement"))
        {
            current_func = sym->children[1]->getName();
            generateCode(sym->children[0]);
            // code << "hello world 10" << endl;
            code << sym->children[1]->getName() << " "
                 << "PROC" << endl;

            if (sym->children[1]->getName() == "main")
            {
                print("MOV AX, @DATA");
                print("MOV DS, AX");
            }

            print("PUSH BP");
            print("MOV BP, SP");

            generateCode(sym->children[4]);

            // sym->children[1]->endlabel = newlabel();

            // printlabel(sym->children[1]->endlabel);

            code << sym->children[1]->getName() << "_exit:" << endl;

            if (sym->children[1]->getName() == "main")
            {
                print("MOV AX, 4CH");
                print("INT 21H");
            }

            if (sym->children[4]->total_local_var > 0 || true)
            {
                code << "\t"
                     << "ADD SP, " << -1 * sym->children[4]->offset << endl;
            }
            print("POP BP");

            if (sym->children[1]->getName() != "main")
            {
                code << "\tRET" << endl;
            }

            code << sym->children[1]->getName() << " "
                 << "ENDP" << endl;
        }
        else if (sym->match("parameter_list", "parameter_list COMMA type_specifier ID"))
        {
            // code << "hello world 11" << endl;
            for (auto child : sym->children)
            {
                generateCode(child);
            }
        }
        else if (sym->match("parameter_list", "parameter_list COMMA type_specifier"))
        {
            // code << "hello world 12" << endl;
            for (auto child : sym->children)
            {
                generateCode(child);
            }
        }
        else if (sym->match("parameter_list", "type_specifier ID"))
        {
            // code << "hello world 13" << endl;
            for (auto child : sym->children)
            {
                generateCode(child);
            }
        }
        else if (sym->match("parameter_list", "type_specifier"))
        {
            // code << "hello world 14" << endl;
            for (auto child : sym->children)
            {
                generateCode(child);
            }
        }
        else if (sym->match("compound_statement", "LCURL statements RCURL"))
        {
            if (sym->endlabel == "")
            {
                sym->endlabel = newlabel();
            }
            // // code << "hello world 15" << endl;
            sym->children[1]->endlabel = sym->endlabel;

            // cout << sym->children[1]->endlabel << endl;

            for (auto child : sym->children)
            {
                generateCode(child);
            }
        }
        else if (sym->match("compound_statement", "LCURL RCURL"))
        {
            // code << "hello world 16" << endl;
            for (auto child : sym->children)
            {
                generateCode(child);
            }
        }
        else if (sym->match("var_declaration", "type_specifier declaration_list SEMICOLON"))
        {
            // code << "hello world 17" << endl;
            for (auto child : sym->children)
            {
                generateCode(child);
            }
        }
        else if (sym->match("type_specifier", "INT"))
        {
            // code << "hello world 18" << endl;
            for (auto child : sym->children)
            {
                generateCode(child);
            }
        }
        else if (sym->match("type_specifier", "FLOAT"))
        {
            // code << "hello world 19" << endl;
            for (auto child : sym->children)
            {
                generateCode(child);
            }
        }
        else if (sym->match("type_specifier", "VOID"))
        {
            // code << "hello world 20" << endl;
            for (auto child : sym->children)
            {
                generateCode(child);
            }
        }
        else if (sym->match("declaration_list", "declaration_list COMMA ID"))
        {
            // code << "hello world 21" << endl;
            for (auto child : sym->children)
            {
                generateCode(child);
            }
            bool gl = sym->children[2]->getglobal();
            if (!gl)
            {
                code << "\t"
                     << "SUB SP, 2" << endl;
            }
        }
        else if (sym->match("declaration_list", "declaration_list COMMA ID LSQUARE CONST_INT RSQUARE"))
        {
            // code << "hello world 22" << endl;
            for (auto child : sym->children)
            {
                generateCode(child);
            }

            bool gl = sym->children[2]->getglobal();
            int x = stoi(sym->children[4]->getName()) * 2;
            if (!gl)
            {
                code << "\t"
                     << "SUB SP, " << x << endl;
            }
        }
        else if (sym->match("declaration_list", "ID"))
        {
            // code << "hello world 23" << endl;
            for (auto child : sym->children)
            {
                generateCode(child);
            }
            bool gl = sym->children[0]->getglobal();
            if (!gl)
            {
                code << "\t"
                     << "SUB SP, 2" << endl;
            }
        }
        /*???????*/
        else if (sym->match("declaration_list", "ID LSQUARE CONST_INT RSQUARE"))
        {
            // code << "hello world 24" << endl;
            for (auto child : sym->children)
            {
                generateCode(child);
            }
            bool gl = sym->children[0]->getglobal();
            int x = stoi(sym->children[2]->getName()) * 2;
            if (!gl)
            {
                code << "\t"
                     << "SUB SP, " << x << endl;
            }
        }
        else if (sym->match("statements", "statement"))
        {
            // code << "hello world 25" << endl;
            // cout << sym->endlabel << endl;
            sym->children[0]->endlabel = sym->endlabel;

            for (auto child : sym->children)
            {
                generateCode(child);
            }

            printlabel(sym->endlabel);
            // printlabel(sym->children[0]->endlabel);
        }
        else if (sym->match("statements", "statements statement"))
        {
            // sym->children[0]->endlabel = newlabel();
            // sym->children[1]->endlabel = sym->endlabel;
            // code << "hello world 25" << endl;

            sym->children[0]->endlabel = newlabel();
            sym->children[1]->endlabel = sym->endlabel;

            // cout << sym->endlabel << endl;

            for (auto child : sym->children)
            {
                generateCode(child);
            }

            printlabel(sym->endlabel);
        }
        else if (sym->match("statement", "var_declaration"))
        {
            // code << "hello world 25" << endl;
            for (auto child : sym->children)
            {
                generateCode(child);
            }
        }
        else if (sym->match("statement", "expression_statement"))
        {
            // code << "hello world 25" << endl;
            for (auto child : sym->children)
            {
                generateCode(child);
            }
        }
        else if (sym->match("statement", "compound_statement"))
        {
            // code << "hello world 25" << endl;
            sym->children[0]->endlabel = newlabel();
            for (auto child : sym->children)
            {
                // child->endlabel = newlabel();
                generateCode(child);
            }
        }
        else if (sym->match("statement", "FOR LPAREN expression_statement expression_statement expression RPAREN statement"))
        {
            // // code << "hello world 26" << endl;
            // generateCode(sym->children[0]);
            // generateCode(sym->children[1]);
            // generateCode(sym->children[2]);

            // // string t = newlabel();
            // // printlabel(t);

            // // sym->children[3]->conditional = true;
            // // sym->children[3]->truelabel = newlabel();
            // // sym->children[3]->falselabel = sym->endlabel;

            // generateCode(sym->children[3]);

            // // printlabel(sym->children[3]->truelabel);

            // generateCode(sym->children[5]);

            // // sym->children[6]->endlabel = newlabel();

            // generateCode(sym->children[6]);

            // generateCode(sym->children[4]);
            // // print("JMP " + t);

            generateCode(sym->children[0]);
            generateCode(sym->children[1]);
            generateCode(sym->children[2]);

            string loop = newlabel();

            printlabel(loop);

            sym->children[3]->conditional = true;
            sym->children[3]->truelabel = newlabel();
            sym->children[3]->falselabel = sym->endlabel;
            sym->children[6]->endlabel = newlabel();

            generateCode(sym->children[3]);

            printlabel(sym->children[3]->truelabel);

            generateCode(sym->children[6]);
            generateCode(sym->children[4]);
            generateCode(sym->children[5]);

            code << "\tJMP " << loop << "\n";
        }
        else if (sym->match("statement", "IF LPAREN expression RPAREN statement"))
        {
            generateCode(sym->children[0]);
            generateCode(sym->children[1]);

            sym->children[2]->truelabel = newlabel();
            sym->children[2]->falselabel = sym->endlabel;
            sym->children[2]->conditional = true;
            sym->children[4]->endlabel = sym->endlabel;

            // code << "hello world 27" << endl;

            generateCode(sym->children[2]);
            printlabel(sym->children[2]->truelabel);
            generateCode(sym->children[3]);
            generateCode(sym->children[4]);
        }
        else if (sym->match("statement", "IF LPAREN expression RPAREN statement ELSE statement"))
        {
            // code << "hello world 28" << endl;
            generateCode(sym->children[0]);
            generateCode(sym->children[1]);

            sym->children[2]->truelabel = newlabel();
            sym->children[2]->falselabel = newlabel();
            sym->children[2]->conditional = true;

            sym->children[4]->endlabel = sym->children[2]->falselabel;
            sym->children[6]->endlabel = sym->endlabel;

            generateCode(sym->children[2]);

            printlabel(sym->children[2]->truelabel);

            generateCode(sym->children[3]);

            generateCode(sym->children[4]);

            print("JMP " + sym->endlabel);

            printlabel(sym->children[2]->falselabel);

            generateCode(sym->children[5]);

            generateCode(sym->children[6]);
        }
        else if (sym->match("statement", "WHILE LPAREN expression RPAREN statement"))
        {
            // code << "hello world 29" << endl;
            generateCode(sym->children[0]);
            generateCode(sym->children[1]);

            string loop = newlabel();

            sym->children[2]->conditional = true;
            sym->children[2]->truelabel = newlabel();
            sym->children[2]->falselabel = sym->endlabel;
            sym->children[4]->endlabel = sym->endlabel;

            printlabel(loop);

            generateCode(sym->children[2]);

            printlabel(sym->children[2]->truelabel);

            generateCode(sym->children[3]);

            generateCode(sym->children[4]);

            print("JMP " + loop);
        }
        else if (sym->match("statement", "PRINTLN LPAREN ID RPAREN SEMICOLON"))
        {
            // code << "hello world 30" << endl;
            for (auto child : sym->children)
            {
                generateCode(child);
            }

            bool gl = sym->children[2]->getglobal();
            if (!gl)
            {
                print("PUSH BP");
                code << "\tMOV BX, " << sym->children[2]->offset << endl;
                print("ADD BP, BX");
                print("MOV AX, [BP]");
                print("CALL PRINTNUMBER");
                print("CALL NEWLINE");
                print("POP BP");

                // print("MOV AX, [BP - OFFSET]");
                // print("CALL PRINTNUMBER");
                // print("CALL NEWLINE");
            }
            else
            {
                print("MOV AX, " + sym->children[2]->getName());
                print("CALL PRINTNUMBER");
                print("CALL NEWLINE");
            }
        }

        else if (sym->match("statement", "RETURN expression SEMICOLON"))
        {
            // code << "hello world 31" << endl;
            for (auto child : sym->children)
            {
                generateCode(child);
            }

            print("MOV DX,CX");
            code << "\tJMP "
                 << current_func
                 << "_exit" << endl;

            // code << "\tJMP" << " endfunc" << endl;
        }
        else if (sym->match("expression_statement", "SEMICOLON"))
        {
            // code << "hello world 31" << endl;
            for (auto child : sym->children)
            {
                generateCode(child);
            }
        }
        else if (sym->match("expression_statement", "expression SEMICOLON"))
        {
            sym->children[0]->falselabel = sym->falselabel;
            sym->children[0]->conditional = sym->conditional;
            sym->children[0]->truelabel = sym->truelabel;
            // code << "hello world 32" << endl;
            for (auto child : sym->children)
            {
                generateCode(child);
            }
        }
        else if (sym->match("variable", "ID"))
        {
            // code << "hello world 32" << endl;
            for (auto child : sym->children)
            {
                generateCode(child);
            }
            bool gl = sym->children[0]->getglobal();
            if (!gl)
            {
                code << "\t"
                     << "PUSH BP" << endl
                     << "\t"
                     << "MOV BX, "
                     << sym->children[0]->offset << endl
                     << "\t"
                     << "ADD BP, BX" << endl;
            }
        }
        else if (sym->match("variable", "ID LSQUARE expression RSQUARE"))
        {
            // code << "hello world 33" << endl;
            for (auto child : sym->children)
            {
                generateCode(child);
            }

            bool gl = sym->children[0]->getglobal();
            if (gl)
            {
                code << "\t"
                     << "LEA SI, " << sym->children[0]->getName() << endl
                     << "\t"
                     << "ADD SI, CX" << endl
                     << "\t"
                     << "ADD SI, CX" << endl
                     << "\t"
                     << "PUSH BP" << endl
                     << "\t"
                     << "MOV BP, SI" << endl;
            }
            else
            {
                code << "\t"
                     << "PUSH BP" << endl
                     << "\t"
                     << "MOV BX, CX" << endl
                     << "\t"
                     << "ADD BX, BX" << endl
                     << "\t"
                     << "ADD BX, "
                     << sym->children[0]->offset << endl
                     << "\t"
                     << "ADD BP, BX" << endl;
            }
        }
        else if (sym->match("expression", "logic_expression"))
        {
            sym->children[0]->conditional = sym->conditional;
            sym->children[0]->truelabel = sym->truelabel;
            sym->children[0]->falselabel = sym->falselabel;
            // code << "hello world 34" << endl;
            for (auto child : sym->children)
            {
                generateCode(child);
            }
        }
        else if (sym->match("expression", "variable ASSIGNOP logic_expression"))
        {
            // code << "hello world 34" << endl;
            generateCode(sym->children[2]);
            sym->children[0]->conditional = false;
            sym->children[2]->conditional = false;
            bool gl = sym->children[0]->getglobal();
            bool array = sym->children[0]->arraySize > 0;

            if (gl && !array)
            {
                generateCode(sym->children[0]);
                code << "\tMOV " << sym->children[0]->getName()
                     << ", CX" << endl;
            }

            else
            {
                code << "\tPUSH CX\n";

                generateCode(sym->children[0]);

                code << "\tPOP AX\n";
                code << "\tPOP CX\n";
                code << "\tMOV [BP], CX\n";
                code << "\tMOV BP, AX\n";
            }
            if (sym->conditional)
            {
                code << "\tCMP CX, 0\n";
                code << "\tJE " << sym->falselabel << endl;
                code << "\tJMP " << sym->truelabel << "\n";
            }
        }
        else if (sym->match("logic_expression", "rel_expression"))
        {
            sym->children[0]->conditional = sym->conditional;
            sym->children[0]->truelabel = sym->truelabel;
            sym->children[0]->falselabel = sym->falselabel;

            //    code << "hello world 34" << endl;
            for (auto child : sym->children)
            {
                generateCode(child);
            }
        }
        else if (sym->match("logic_expression", "rel_expression LOGICOP rel_expression"))
        {
            sym->children[0]->conditional = sym->conditional;
            sym->children[2]->conditional = sym->conditional;
            
            if (sym->children[1]->getName() == "||")
            {
                sym->children[0]->truelabel = sym->truelabel;
                sym->children[0]->falselabel = newlabel() + "jmpfalse";
                sym->children[2]->truelabel = sym->truelabel;
                sym->children[2]->falselabel = sym->falselabel;
            }
            else
            {
                sym->children[0]->truelabel = newlabel() + "jmptrue";
                sym->children[0]->falselabel = sym->falselabel;
                sym->children[2]->truelabel = sym->truelabel;
                sym->children[2]->falselabel = sym->falselabel;
            }

            generateCode(sym->children[0]);

            if (sym->conditional)
            {
                if (sym->children[1]->getName() == "||")
                {
                    code << sym->children[0]->falselabel << ":\n";
                }
                else
                {
                    code << sym->children[0]->truelabel << ":\n";
                }
            }
            else
            {
                code << "\tPUSH CX\n";
            }

            generateCode(sym->children[2]);

            if (!sym->conditional)
            {
                code << "\tPOP AX\n";

                if (sym->children[1]->getName() == "||")
                {
                    string x = newlabel();
                    string y = newlabel();
                    string z = newlabel();
                    string a = newlabel();
                    code << "\tCMP AX, 0\n";
                    code << "\tJE " << x << "\n";
                    code << "\tJMP " << y << "\n";
                    code << x << ":\n";
                    code << "\tJCXZ " << z << "\n";
                    code << y << ":\n";
                    code << "\tMOV CX, 1\n";
                    code << "\tJMP " << a << "\n";
                    code << z << ":\n";
                    code << "\tMOV CX, 0\n";
                    code << a << ":\n";
                }

                else
                {
                    string x = newlabel();
                    string y = newlabel();
                    string z = newlabel();
                    code << "\tCMP AX, 0\n";
                    code << "\tJE " << x << "\n";
                    code << "\tJCXZ " << x << "\n";
                    code << "\tJMP " << y << "\n";
                    code << x << ":\n";
                    code << "\tMOV CX, 0\n";
                    code << "\tJMP " << z << "\n";
                    code << y << ":\n";
                    code << "\tMOV CX, 1\n";
                    code << z << ":\n";
                }
            }

            //    code << "hello world 34" << endl;
            // for (auto child : sym->children)
            // {
            //     generateCode(child);
            // }
        }
        else if (sym->match("rel_expression", "simple_expression"))
        {
            sym->children[0]->conditional = sym->conditional;
            sym->children[0]->truelabel = sym->truelabel;
            sym->children[0]->falselabel = sym->falselabel;
            //    code << "hello world 34" << endl;
            for (auto child : sym->children)
            {
                generateCode(child);
            }
        }
        else if (sym->match("rel_expression", "simple_expression RELOP simple_expression"))
        {
            generateCode(sym->children[0]);
            code << "\tPUSH CX\n";
            generateCode(sym->children[2]);
            string opcode = getkeyword(sym->children[1]->getName());
            code << "\tPOP AX\n";
            code << "\tCMP AX, CX\n";
            if (sym->truelabel == "")
            {
                sym->truelabel = newlabel();
            }
            if (sym->falselabel == "")
            {
                sym->falselabel = newlabel();
            }
            code << opcode + " " + sym->truelabel + "\n";
            code << "\tJMP " + sym->falselabel + "\n";
            if (!sym->conditional)
            {
                code << sym->truelabel << ":\n";
                code << "\tMOV CX, 1\n";
                string leave = newlabel();
                code << "\tJMP " << leave << "\n";
                code << sym->falselabel << ":\n";
                code << "\tMOV CX, 0\n";
                code << leave << ":\n";
            }
            // code << "hello world 34" << endl;
            // for (auto child : sym->children)
            // {
            //     generateCode(child);
            // }
        }
        else if (sym->match("simple_expression", "term"))
        {
            sym->children[0]->conditional = sym->conditional;
            sym->children[0]->truelabel = sym->truelabel;
            sym->children[0]->falselabel = sym->falselabel;
            // code << "hello world 35" << endl;
            for (auto child : sym->children)
            {
                generateCode(child);
            }
        }
        else if (sym->match("simple_expression", "simple_expression ADDOP term"))
        {
            generateCode(sym->children[0]);
            code << "\tPUSH CX\n";
            generateCode(sym->children[2]);
            code << "\tPOP AX\n";
            if (sym->children[1]->getName() == "+")
                code << "\tADD CX, AX\n";
            if (sym->children[1]->getName() == "-")
                code << "\tSUB AX, CX\n\tMOV CX, AX\n";
            if (sym->conditional)
            {
                code << "\tJCXZ " << sym->falselabel << "\n";
                code << "\tJMP " << sym->truelabel << "\n";
            }

            // code << "hello world 35" << endl;
            // for (auto child : sym->children)
            // {
            //     generateCode(child);
            // }
        }
        else if (sym->match("term", "unary_expression"))
        {
            sym->children[0]->conditional = sym->conditional;
            sym->children[0]->truelabel = sym->truelabel;
            sym->children[0]->falselabel = sym->falselabel;
            // code << "hello world 35" << endl;
            for (auto child : sym->children)
            {
                generateCode(child);
            }
        }
        else if (sym->match("term", "term MULOP unary_expression"))
        {
            generateCode(sym->children[0]);
            code << "\tPUSH CX\n";
            generateCode(sym->children[2]);
            code << "\tPOP AX\n";
            if (sym->children[1]->getName() == "*")
            {
                code << "\tIMUL CX\n";
                code << "\tMOV CX, AX\n";
            }
            else if (sym->children[1]->getName() == "/")
            {
                code << "\tCWD\n";
                code << "\tIDIV CX\n";
                code << "\tMOV CX, AX\n";
            }
            else if (sym->children[1]->getName() == "%")
            {
                code << "\tCWD\n";
                code << "\tIDIV CX\n";
                code << "\tMOV CX, DX\n";
            }
            if (sym->conditional)
            {
                code << "\tJCXZ " << sym->falselabel << "\n";
                code << "\tJMP " << sym->truelabel << "\n";
            }
            // code << "hello world 35" << endl;
            // for (auto child : sym->children)
            // {
            //     generateCode(child);
            // }
        }
        else if (sym->match("unary_expression", "ADDOP unary_expression"))
        {
            sym->children[1]->conditional = sym->conditional;
            sym->children[1]->truelabel = sym->truelabel;
            sym->children[1]->falselabel = sym->falselabel;
            // code << "hello world 35" << endl;
            for (auto child : sym->children)
            {
                generateCode(child);
            }
            if (sym->children[0]->getName() == "-")
            {
                code << "\tNEG CX\n";
            }
        }
        else if (sym->match("unary_expression", "NOT unary_expression"))
        {
            sym->children[1]->conditional = sym->conditional;
            sym->children[1]->truelabel = sym->falselabel;
            sym->children[1]->falselabel = sym->truelabel;
            // code << "hello world 36" << endl;
            for (auto child : sym->children)
            {
                generateCode(child);
            }
            if (!sym->conditional)
            {
                string l0 = newlabel();
                string l1 = newlabel();
                code << "\tJCXZ " + l1 + "\n";
                code << "\tMOV CX,0\n";
                code << "\tJMP " << l0 << "\n";
                code << l1 + ":\n";
                code << "\tMOV CX,1\n";
                code << l0 + ":\n";
            }
        }
        else if (sym->match("unary_expression", "factor"))
        {
            sym->children[0]->conditional = sym->conditional;
            sym->children[0]->truelabel = sym->truelabel;
            sym->children[0]->falselabel = sym->falselabel;
            // code << "hello world 36" << endl;
            for (auto child : sym->children)
            {
                generateCode(child);
            }
        }
        else if (sym->match("factor", "variable"))
        {
            // code << "hello world 37" << endl;
            for (auto child : sym->children)
            {
                generateCode(child);
            }

            bool gl = sym->children[0]->getglobal();
            bool array = sym->children[0]->arraySize > 0;

            if (gl && !array)
            {
                code << "\tMOV CX, " << sym->children[0]->getName() << "\n";
            }
            else
            {
                code << "\tMOV CX, [BP]\n";
                code << "\tPOP BP\n";
            }
            if (sym->conditional)
            {
                code << "\tJCXZ " << sym->falselabel << "\n";
                code << "\tJMP " << sym->truelabel << "\n";
            }
        }
        else if (sym->match("factor", "ID LPAREN argument_list RPAREN"))
        {
            // code << "hello world 37" << endl;
            for (auto child : sym->children)
            {
                generateCode(child);
            }
            code << "\tCALL " + sym->children[0]->getName() + "\n";
            code << "\tMOV CX, DX\n";
            code << "\tADD SP, " << sym->children[0]->getarg() * 2 << "\n";
            if (sym->conditional)
            {
                code << "\tJCXZ " << sym->falselabel << "\n";
                code << "\tJMP " << sym->truelabel << "\n";
            }
        }
        else if (sym->match("factor", "LPAREN expression RPAREN"))
        {
            // code << "hello world 37" << endl;
            for (auto child : sym->children)
            {
                generateCode(child);
            }
            if (sym->conditional)
            {
                code << "\tJCXZ " << sym->falselabel << "\n";
                code << "\tJMP " << sym->truelabel << "\n";
            }
        }
        else if (sym->match("factor", "CONST_INT"))
        {
            // code << "hello world 37" << endl;
            for (auto child : sym->children)
            {
                generateCode(child);
            }
            code << "\tMOV CX, " + sym->children[0]->getName() + "\n";
            if (sym->conditional)
            {
                code << "\tJCXZ " << sym->falselabel << "\n";
                code << "\tJMP " << sym->truelabel << "\n";
            }
        }
        else if (sym->match("factor", "CONST_FLOAT"))
        {
            // code << "hello world 37" << endl;
            for (auto child : sym->children)
            {
                generateCode(child);
            }
            code << "\tMOV CX, " + sym->children[0]->getName() + "\n";
            if (sym->conditional)
            {
                code << "\tJCXZ " << sym->falselabel << "\n";
                code << "\tJMP " << sym->truelabel << "\n";
            }
        }
        else if (sym->match("factor", "variable INCOP"))
        {
            // code << "hello world 37" << endl;
            for (auto child : sym->children)
            {
                generateCode(child);
            }

            bool gl = sym->children[0]->getglobal();
            bool array = sym->children[0]->arraySize > 0;

            if (gl && !array)
            {
                code << "\tMOV CX, " << sym->children[0]->getName() << "\n";
            }
            else
            {
                code << "\tMOV CX, [BP]\n";
            }
            code << "\tMOV AX, CX\n";
            code << "\tINC CX\n";
            if (gl && !array)
            {
                code << "\tMOV " << sym->children[0]->getName() << ", CX\n";
            }
            else
            {
            code << "\tMOV [BP], CX\n";
            code << "\tPOP BP\n";
            }
            code << "\tMOV CX, AX\n";

            if (sym->conditional)
            {
                code << "\tJCXZ " << sym->falselabel << "\n";
                code << "\tJMP " << sym->truelabel << "\n";
            }
        }
        else if (sym->match("factor", "variable DECOP"))
        {
            // code << "hello world 38" << endl;
            for (auto child : sym->children)
            {
                generateCode(child);
            }

            bool gl = sym->children[0]->getglobal();
            bool array = sym->children[0]->arraySize > 0;

            if (gl && !array)
            {
                code << "\tMOV CX, " << sym->children[0]->getName() << "\n";
            }
            else
            {
                code << "\tMOV CX, [BP]\n";
            }
            code << "\tMOV AX, CX\n";
            code << "\tDEC CX\n";
            if (gl && !array)
            {
                code << "\tMOV " << sym->children[0]->getName() << ", CX\n";
            }
            else
            {
            code << "\tMOV [BP], CX\n";
            code << "\tPOP BP\n";
            }
            code << "\tMOV CX, AX\n";
            if (sym->conditional)
            {
                code << "\tJCXZ " << sym->falselabel << "\n";
                code << "\tJMP " << sym->truelabel << "\n";
            }
        }

        else if (sym->match("argument_list", "arguments"))
        {
            // code << "hello world 40" << endl;
            for (auto child : sym->children)
            {
                generateCode(child);
            }
        }
        else if (sym->match("argument_list", ""))
        {
            // code << "hello world 40" << endl;
            for (auto child : sym->children)
            {
                generateCode(child);
            }
        }
        else if (sym->match("arguments", "arguments COMMA logic_expression"))
        {
            // code << "hello world 41" << endl;
            for (auto child : sym->children)
            {
                generateCode(child);
            }
            code << "\tPUSH CX\n";
        }
        else if (sym->match("arguments", "logic_expression"))
        {
            // code << "hello world 41" << endl;
            for (auto child : sym->children)
            {
                generateCode(child);
            }
            code << "\tPUSH CX\n";
        }
    }

    void optimizeCode()
    {
        vector<vector<string>> mycode;
        string line;
        ifstream cs1("code.asm");

        if (cs1.is_open())
        {
            while (getline(cs1, line))
            {
                string w = "";
                vector<string> words;
                for (int i = 0; i < line.size(); i++)
                {
                    if (line[i] == ' ' || line[i] == '\n' || line[i] == '\t' || line[i] == ',' || line[i] == ':' || line[i] == ';')
                    {
                        if (w.size() > 0)
                            words.push_back(w);
                        w = "";
                    }
                    else
                    {
                        w += line[i];
                    }
                }
                if (w.size() > 0)
                    words.push_back(w);
                words.push_back(line + '\n');
                mycode.push_back(words);
                // for(int i=0; i<words.size(); i++){
                //     cout<< words[i]<< " __ " ;
                // }
                // cout<< "."<< endl;
                // cout << line << endl;
            }
        }

        cs1.close();

        int g = INT_MAX;

        while (g > mycode.size())
        {
            g = mycode.size();
            vector<vector<string>> opt;
            for (int i = 0; i < mycode.size(); i++)
            {
                if (mycode[i].size() > 0)
                {
                    if ((mycode[i][0] == "ADD" || mycode[i][0] == "SUB") && mycode[i][2] == "0")
                    {
                        continue;
                    }
                    if (i < mycode.size() - 1 && mycode[i][0] == "PUSH" && mycode[i + 1][0] == "POP" && mycode[i][1] == mycode[i + 1][1])
                    {
                        i++;
                        continue;
                    }
                    if (i < mycode.size() - 1 && mycode[i][0] == "MOV" && mycode[i + 1][0] == "MOV" && mycode[i][1] == mycode[i + 1][2] && mycode[i][2] == mycode[i + 1][1])
                    {
                        i++;
                        continue;
                    }
                }
                // cout << mycode [2][0] << endl;
                opt.push_back(mycode[i]);
            }

            mycode = opt;
        }

        ofstream optcode("optcode.asm");
        for (int i = 0; i < mycode.size(); i++)
        {
            optcode << mycode[i][mycode[i].size() - 1];
        }
        optcode.close();

        // for(int i=0; i<mycode.size(); i++){
        //         for(int j = 0; j<mycode[i].size();j++){
        //             cout << mycode[i][j] << " ";
        //         }
        //         cout<< endl;
        //     }
    }
};