%{
#include <iostream>
#include "codeGenerate.h"
using namespace std;
int yylex(void);
void yyerror(char* s);
extern FILE *yyin;
extern SymbolTable sym;
extern int error;
extern int yylineno;
vector<SymbolInfo*> id_list;
SymbolInfo* head;
codeGenerate cg;
int arg_number = 0;
int local_vars = 0;
ofstream com("log.txt");
ofstream tree("parseTree.txt");
ofstream err("error.txt");
ofstream code("code.asm");
void PrintCFG(string first, string second){
    com << first << " : " << second << " " << endl;
}

void setRetType(string s)
{
	for(auto x:id_list)
	{
		x->setRetType(s);
	}
}

void insertSymbols()
{
	for(SymbolInfo* s:id_list)
	{	
		//s->printid();
		SymbolInfo* ss = s;
		sym.Insert(s);
		if(sym.getId()==1) {
			ss = sym.Lookup(s->getName());
			ss->setglobal(true);
			ss->offset = 0;
			ss->arraySize = s->arraySize;
			cg.globalList.push_back(ss);
			cout << "--global--";
			}
		else{
			if(s->arraySize == 0){
			sym.setoffset(sym.getoffset()-2);
			}
			else{
			sym.setoffset(sym.getoffset()-2 * s->arraySize);
			}
			ss = sym.Lookup(s->getName());
			ss->offset = sym.getoffset();
			}	
		// cout << "OK" << endl;
		
		cout << ss->getName() << "-----" << ss->offset << endl;		
	}
}

void insertSymbolsArguments()
{
	int stackOffset = 2;
	for(int i = id_list.size() - 1; i >=0; i--)
	{
		sym.Insert(id_list[i]);
		SymbolInfo* ss = sym.Lookup(id_list[i]->getName());
		stackOffset+=2;
		ss->offset = stackOffset;
		cout << ss->getName() << "---Params---" << ss->offset << endl;
	}
	// for(SymbolInfo* s :id_list)
	// {	
	// 	//s->printid();
	// 	sym.Insert(s);
	// 	SymbolInfo* ss = sym.Lookup(s->getName());
	// 	stackOffset+=2;
	// 	ss->offset = stackOffset;
	// 	cout << ss->getName() << "---Params---" << ss->offset << endl;
	// }
}

void insertSymbols(SymbolInfo* s)
{
	//s->printid();
		sym.Insert(s);
}

%}

%union {
	SymbolInfo* symbol;
}

%token<symbol> IF ELSE FOR WHILE ID LPAREN RPAREN SEMICOLON COMMA LCURL RCURL INT FLOAT VOID LTHIRD CONST_INT RTHIRD
%token<symbol> RETURN PRINTLN ASSIGNOP RELOP LOGICOP ADDOP MULOP NOT CONST_FLOAT INCOP DECOP
%type<symbol> start program unit func_declaration func_definition parameter_list compound_statement var_declaration type_specifier declaration_list statements statement expression_statement variable expression logic_expression rel_expression simple_expression term unary_expression factor argument_list arguments

/* %left ADDOP MULOP 
%right ASSIGNOP

%nonassoc LOGICOP */



%%

start : program
	{
		PrintCFG("start","program");
		$$ = new SymbolInfo();
		$$->setCFG("start","program");
		$$->makechild($1);
		$$->printparsetree(0);
		head = $$;
	}
	;

program : program unit {
        PrintCFG("program","program unit");
		$$ = new SymbolInfo();
		$$->setCFG("program","program unit");
		$$->makechild($1);$$->makechild($2);
    }
	| unit{
        PrintCFG("program","unit");
		$$ = new SymbolInfo();
		$$->setCFG("program","unit");
		$$->makechild($1);
    }
	;
	
unit : var_declaration{
        PrintCFG("unit","var_declaration");
		$$ = new SymbolInfo();
		$$->setCFG("unit","var_declaration");
		$$->makechild($1);
    }
     | func_declaration{
        PrintCFG("unit","func_declaration");
		$$ = new SymbolInfo();
		$$->setCFG("unit","func_declaration");
		$$->makechild($1);
     }
     | func_definition{
        PrintCFG("unit","func_definition");
		$$ = new SymbolInfo();
		$$->setCFG("unit","func_definition");
		$$->makechild($1);
     }
     ;
     
func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON{
    	PrintCFG("func_declaration","type_specifier ID LPAREN parameter_list RPAREN SEMICOLON");
		$$ = new SymbolInfo();
		$$->setCFG("func_declaration","type_specifier ID LPAREN parameter_list RPAREN SEMICOLON");
		$$->makechild($1);$$->makechild($2);$$->makechild($3);$$->makechild($4);$$->makechild($5);$$->makechild($6);
		id_list.clear();
		$2->setVarType("FUNCTION");
		$2->setRetType($1->getType());
		insertSymbols($2);
		}
		| type_specifier ID LPAREN RPAREN SEMICOLON{
		PrintCFG("func_declaration","type_specifier ID LPAREN RPAREN SEMICOLON");
		$$ = new SymbolInfo();
		$$->setCFG("func_declaration","type_specifier ID LPAREN RPAREN SEMICOLON");
		$$->makechild($1);$$->makechild($2);$$->makechild($3);$$->makechild($4);$$->makechild($5);
		id_list.clear();
		$2->setVarType("FUNCTION");
		$2->setRetType($1->getType());
		insertSymbols($2);
		}
		;
		 
func_definition : type_specifier ID LPAREN parameter_list RPAREN {
	local_vars = 0;
	$2->setarg(arg_number);
	insertSymbols($2);
	SymbolInfo* ss = sym.Lookup($2->getName());
	ss->setarg(arg_number);
} compound_statement{
		PrintCFG("func_definition","type_specifier ID LPAREN parameter_list RPAREN compound_statement");
		$$ = new SymbolInfo();
		$$->setCFG("func_definition","type_specifier ID LPAREN parameter_list RPAREN compound_statement");
		$$->makechild($1);$$->makechild($2);$$->makechild($3);$$->makechild($4);$$->makechild($5);$$->makechild($7);
		$2->setVarType("FUNCTION");
		$2->setRetType($1->getType());
		$4->setarg(arg_number);
		
		// $2->setarg(arg_number);
		// insertSymbols($2);
		// SymbolInfo* ss = sym.Lookup($2->getName());
		// ss->setarg(arg_number);
		
		// cout << $2->getName() << " arg number " << ss->getarg() << endl;
		$7->total_local_var = local_vars;
		local_vars = 0;
		arg_number = 0;
		cout << "hi1 " << $7->offset << endl;
		} 
		| type_specifier ID LPAREN RPAREN {
			local_vars = 0;
			$2->setarg(0);
			insertSymbols($2);
			SymbolInfo* ss = sym.Lookup($2->getName());
			ss->setarg(0);
			} compound_statement{
		PrintCFG("func_definition","type_specifier ID LPAREN RPAREN compound_statement");
		$$ = new SymbolInfo();
		$$->setCFG("func_definition","type_specifier ID LPAREN RPAREN compound_statement");
		$$->makechild($1);$$->makechild($2);$$->makechild($3);$$->makechild($4);$$->makechild($6);
		$2->setVarType("FUNCTION");
		$2->setRetType($1->getType());
		$2->setarg(0);
		insertSymbols($2);
		SymbolInfo* ss = sym.Lookup($2->getName());
		ss->setarg(0);
		$6->total_local_var = local_vars;
		local_vars = 0;
		cout << "hi2 " << $6->offset << endl;
		}
 		;				


parameter_list  : parameter_list COMMA type_specifier ID{
		PrintCFG("parameter_list","parameter_list COMMA type_specifier ID");
		$$ = new SymbolInfo();
		$$->setCFG("parameter_list","parameter_list COMMA type_specifier ID");
		$$->makechild($1);$$->makechild($2);$$->makechild($3);$$->makechild($4);
		$4->setRetType($3->getType());
		id_list.push_back($4);
		arg_number++;
		}
		| parameter_list COMMA type_specifier{
		PrintCFG("parameter_list","parameter_list COMMA type_specifier");
		$$ = new SymbolInfo();
		$$->setCFG("parameter_list","parameter_list COMMA type_specifier");
		$$->makechild($1);$$->makechild($2);$$->makechild($3);
		arg_number++;
		}
 		| type_specifier ID{
		PrintCFG("parameter_list","type_specifier ID");
		$$ = new SymbolInfo();
		$$->setCFG("parameter_list","type_specifier ID");
		$$->makechild($1);$$->makechild($2);
		$2->setRetType($1->getType());
		id_list.push_back($2);
		arg_number++;
		}
		| type_specifier{
		PrintCFG("parameter_list","type_specifier");
		$$ = new SymbolInfo();
		$$->setCFG("parameter_list","type_specifier");
		$$->makechild($1);
		arg_number++;
		}
 		;

 		
compound_statement : LCURL{
	// int offset = sym.getoffset();
	sym.EnterScope();
	// sym.setoffset(offset);
	insertSymbolsArguments();
	id_list.clear();
} statements RCURL{
		$$ = new SymbolInfo();
		PrintCFG("compound_statement","LCURL statements RCURL");
		sym.PrintAllScope();
		$$->offset = sym.getoffset();
		cout << "1." << sym.getoffset() << endl;
		sym.ExitScope();
		$$->setCFG("compound_statement","LCURL statements RCURL");
		$$->makechild($1);$$->makechild($3);$$->makechild($4);
		}
 		| LCURL{
			// int offset = sym.getoffset();
			sym.EnterScope();
			// sym.setoffset(offset);
			insertSymbolsArguments();
			id_list.clear();
		} RCURL{
		$$ = new SymbolInfo();
		PrintCFG("compound_statement","LCURL RCURL");
		sym.PrintAllScope();
		$$->offset = sym.getoffset();
		cout << "2." << sym.getoffset() << endl;
		sym.ExitScope();
		$$->setCFG("compound_statement","LCURL RCURL");
		$$->makechild($1);$$->makechild($3);
		}
 		;
 		    
var_declaration : type_specifier declaration_list SEMICOLON{
		PrintCFG("var_declaration","type_specifier declaration_list SEMICOLON");
		$$ = new SymbolInfo();
		$$->setCFG("var_declaration","type_specifier declaration_list SEMICOLON");
		$$->makechild($1);$$->makechild($2);$$->makechild($3);
		setRetType($1->getType());
		insertSymbols();
		id_list.clear();
		}
 		;
 		 
type_specifier	: INT{
		PrintCFG("type_specifier","INT");
		$$ = new SymbolInfo("","INT");
		$$->setCFG("type_specifier","INT");
		$$->makechild($1);
		}
 		| FLOAT{
		PrintCFG("type_specifier","FLOAT");
		$$ = new SymbolInfo("","FLOAT");
		$$->setCFG("type_specifier","FLOAT");
		$$->makechild($1);
		}
 		| VOID{
		PrintCFG("type_specifier","VOID");
		$$ = new SymbolInfo("","VOID");
		$$->setCFG("type_specifier","VOID");
		$$->makechild($1);
		}
 		;
 		
declaration_list : declaration_list COMMA ID{
		PrintCFG("declaration_list","declaration_list COMMA ID");
		$$ = new SymbolInfo();
		$$->setCFG("declaration_list","declaration_list COMMA ID");
		$$->makechild($1);$$->makechild($2);$$->makechild($3);
		id_list.push_back($3);
		if(sym.getId()==1) {
			$3->setglobal(true);
		}
		local_vars++;

		}
 		| declaration_list COMMA ID LTHIRD CONST_INT RTHIRD{
		PrintCFG("declaration_list","declaration_list COMMA ID LSQUARE CONST_INT RSQUARE");
		$$ = new SymbolInfo();
		$$->setCFG("declaration_list","declaration_list COMMA ID LSQUARE CONST_INT RSQUARE");
		$$->makechild($1);$$->makechild($2);$$->makechild($3);$$->makechild($4);$$->makechild($5);$$->makechild($6);
		$3->setVarType("ARRAY");
		$3->arraySize = stoi($5->getName());
		id_list.push_back($3);
		if(sym.getId()==1) {
			$3->setglobal(true);
		}
		local_vars += $3->arraySize;
		}
 		| ID{
		PrintCFG("declaration_list","ID");
		$$ = new SymbolInfo();
		$$->setCFG("declaration_list","ID");
		$$->makechild($1);
		id_list.push_back($1);
		if(sym.getId()==1) {
			$1->setglobal(true);
		}
		local_vars++; 
		}
 		| ID LTHIRD CONST_INT RTHIRD{
		PrintCFG("declaration_list","ID LSQUARE CONST_INT RSQUARE");
		$$ = new SymbolInfo();
		$$->setCFG("declaration_list","ID LSQUARE CONST_INT RSQUARE");
		$$->makechild($1);$$->makechild($2);$$->makechild($3);$$->makechild($4);
		$1->setVarType("ARRAY");
		$1->arraySize = stoi($3->getName());
		id_list.push_back($1);
		if(sym.getId()==1) {
			$1->setglobal(true);
		}
		local_vars += $1->arraySize;
		}
 		;
 		  
statements : statement{
		PrintCFG("statements","statement");
		$$ = new SymbolInfo();
		$$->setCFG("statements","statement");
		$$->makechild($1);
		}
	   	| statements statement{
		PrintCFG("statements","statements statement");
		$$ = new SymbolInfo();
		$$->setCFG("statements","statements statement");
		$$->makechild($1);$$->makechild($2);
	   	}
	   	;
	   
statement : var_declaration{
		PrintCFG("statement","var_declaration");
		$$ = new SymbolInfo();
		$$->setCFG("statement","var_declaration");
		$$->makechild($1);
		}
	  	| expression_statement{
		PrintCFG("statement","expression_statement");
		$$ = new SymbolInfo();
		$$->setCFG("statement","expression_statement");
		$$->makechild($1);
	  	}
	  	| compound_statement{
		PrintCFG("statement","compound_statement");
		$$ = new SymbolInfo();
		$$->setCFG("statement","compound_statement");
		$$->makechild($1);
	  	}
	  	| FOR LPAREN expression_statement expression_statement expression RPAREN statement{
		PrintCFG("statement","FOR LPAREN expression_statement expression_statement expression RPAREN statement");
		$$ = new SymbolInfo();
		$$->setCFG("statement","FOR LPAREN expression_statement expression_statement expression RPAREN statement");
		$$->makechild($1);$$->makechild($2);$$->makechild($3);$$->makechild($4);$$->makechild($5);$$->makechild($6);$$->makechild($7);
	  	}
	  	| IF LPAREN expression RPAREN statement{
		PrintCFG("statement","IF LPAREN expression RPAREN statement");
		$$ = new SymbolInfo();
		$$->setCFG("statement","IF LPAREN expression RPAREN statement");
		$$->makechild($1);$$->makechild($2);$$->makechild($3);$$->makechild($4);$$->makechild($5);
	  	}
	  	| IF LPAREN expression RPAREN statement ELSE statement{
		PrintCFG("statement","IF LPAREN expression RPAREN statement ELSE statement");
		$$ = new SymbolInfo();
		$$->setCFG("statement","IF LPAREN expression RPAREN statement ELSE statement");
		$$->makechild($1);$$->makechild($2);$$->makechild($3);$$->makechild($4);$$->makechild($5);$$->makechild($6);$$->makechild($7);
	  	}
	  	| WHILE LPAREN expression RPAREN statement{
		PrintCFG("statement","WHILE LPAREN expression RPAREN statement");
		$$ = new SymbolInfo();
		$$->setCFG("statement","WHILE LPAREN expression RPAREN statement");
		$$->makechild($1);$$->makechild($2);$$->makechild($3);$$->makechild($4);$$->makechild($5);
	  	}
	  	| PRINTLN LPAREN ID RPAREN SEMICOLON{
		PrintCFG("statement","PRINTLN LPAREN ID RPAREN SEMICOLON");
		$$ = new SymbolInfo();
		$$->setCFG("statement","PRINTLN LPAREN ID RPAREN SEMICOLON");
		$$->makechild($1);$$->makechild($2);$$->makechild($3);$$->makechild($4);$$->makechild($5);
		SymbolInfo* s = sym.Lookup($3->getName());
		$3->offset = s->offset;
		$3->setglobal(s->getglobal());
		cout << s->getName() << "-_-_-_" << s->getglobal() << "-_-_-_" << s->offset << endl;
		// SymbolInfo* sss = sym.Lookup($3->getName());
	  	}
	  	| RETURN expression SEMICOLON{
		PrintCFG("statement","RETURN expression SEMICOLON");
		$$ = new SymbolInfo();
		$$->setCFG("statement","RETURN expression SEMICOLON");
		$$->makechild($1);$$->makechild($2);$$->makechild($3);
	  	}
	  	;
	  
expression_statement : SEMICOLON{
		PrintCFG("expression_statement","SEMICOLON");
		$$ = new SymbolInfo();
		$$->setCFG("expression_statement","SEMICOLON");
		$$->makechild($1);
		}			
		| expression SEMICOLON{
		PrintCFG("expression_statement","expression SEMICOLON");
		$$ = new SymbolInfo();
		$$->setCFG("expression_statement","expression SEMICOLON");
		$$->makechild($1);$$->makechild($2);
		} 
		;
	  
variable : ID{
		PrintCFG("variable","ID");
		$$ = new SymbolInfo();
		$$->setCFG("variable","ID");
		$$->makechild($1);
		SymbolInfo* s = sym.Lookup($1->getName());
		$1->offset = s->offset;
		$1->setglobal(s->getglobal());
		$$->setglobal(s->getglobal());
		$1->arraySize = s->arraySize;
		$$->arraySize = s->arraySize;
		$$->setName($1->getName());
		// cout << s->getName() << endl;
		} 		
	 	| ID LTHIRD expression RTHIRD {
		PrintCFG("variable","ID LSQUARE expression RSQUARE");
		$$ = new SymbolInfo();
		$$->setCFG("variable","ID LSQUARE expression RSQUARE");
		$$->makechild($1);$$->makechild($2);$$->makechild($3);$$->makechild($4);
		SymbolInfo* s = sym.Lookup($1->getName());
		$1->offset = s->offset;
		$1->setglobal(s->getglobal());
		$$->setglobal(s->getglobal());
		$1->arraySize = s->arraySize;
		$$->arraySize = s->arraySize;
		$$->setName($1->getName());
	 	}
	 	;
	 
expression : logic_expression	{
		PrintCFG("expression","logic_expression");
		$$ = new SymbolInfo();
		$$->setCFG("expression","logic_expression");
		$$->makechild($1);
 		}
	   	| variable ASSIGNOP logic_expression {
		PrintCFG("expression","variable ASSIGNOP logic_expression");
		$$ = new SymbolInfo();
		$$->setCFG("expression","variable ASSIGNOP logic_expression");
		$$->makechild($1);$$->makechild($2);$$->makechild($3);
	   	}	
	   	;
			
logic_expression : rel_expression{
		PrintCFG("logic_expression","rel_expression");
		$$ = new SymbolInfo();
		$$->setCFG("logic_expression","rel_expression");
		$$->makechild($1);
		} 	
		| rel_expression LOGICOP rel_expression{
		PrintCFG("logic_expression","rel_expression LOGICOP rel_expression");
		$$ = new SymbolInfo();
		$$->setCFG("logic_expression","rel_expression LOGICOP rel_expression");
		$$->makechild($1);$$->makechild($2);$$->makechild($3);
		} 	
		;
			
rel_expression	: simple_expression{
		PrintCFG("rel_expression","simple_expression");
		$$ = new SymbolInfo();
		$$->setCFG("rel_expression","simple_expression");
		$$->makechild($1);
		} 
		| simple_expression RELOP simple_expression{
		PrintCFG("rel_expression","simple_expression RELOP simple_expression");
		$$ = new SymbolInfo();
		$$->setCFG("rel_expression","simple_expression RELOP simple_expression");
		$$->makechild($1);$$->makechild($2);$$->makechild($3);
		}	
		;
				
simple_expression : term{
		PrintCFG("simple_expression","term");
		$$ = new SymbolInfo();
		$$->setCFG("simple_expression","term");
		$$->makechild($1);
		} 
		| simple_expression ADDOP term{
		PrintCFG("simple_expression","simple_expression ADDOP term");
		$$ = new SymbolInfo();
		$$->setCFG("simple_expression","simple_expression ADDOP term");
		$$->makechild($1);$$->makechild($2);$$->makechild($3);
		} 
		;
					
term :	unary_expression{
		PrintCFG("term","unary_expression");
		$$ = new SymbolInfo();
		$$->setCFG("term","unary_expression");
		$$->makechild($1);
		}
     	|  term MULOP unary_expression{
		PrintCFG("term","term MULOP unary_expression");
		$$ = new SymbolInfo();
		$$->setCFG("term","term MULOP unary_expression");
		$$->makechild($1);$$->makechild($2);$$->makechild($3);
		}
     	;

unary_expression : ADDOP unary_expression{
		PrintCFG("unary_expression","ADDOP unary_expression");
		$$ = new SymbolInfo();
		$$->setCFG("unary_expression","ADDOP unary_expression");
		$$->makechild($1);$$->makechild($2);
		}  
		| NOT unary_expression{
		PrintCFG("unary_expression","NOT unary_expression");
		$$ = new SymbolInfo();
		$$->setCFG("unary_expression","NOT unary_expression");
		$$->makechild($1);$$->makechild($2);
		} 
		| factor{
		PrintCFG("unary_expression","factor");
		$$ = new SymbolInfo();
		$$->setCFG("unary_expression","factor");
		$$->makechild($1);
		} 
		;
	
factor	: variable{
		PrintCFG("factor","variable");
		$$ = new SymbolInfo();
		$$->setCFG("factor","variable");
		$$->makechild($1);
		} 
		| ID LPAREN argument_list RPAREN{
		PrintCFG("factor","ID LPAREN argument_list RPAREN");
		$$ = new SymbolInfo();
		$$->setCFG("factor","ID LPAREN argument_list RPAREN");
		$$->makechild($1);$$->makechild($2);$$->makechild($3);$$->makechild($4);
		SymbolInfo* s = sym.Lookup($1->getName());
		$1->setarg(s->getarg());
		cout << "arg - " << s->getName() << " - " << s->getarg() << endl;
		}
		| LPAREN expression RPAREN{
		PrintCFG("factor","LPAREN expression RPAREN");
		$$ = new SymbolInfo();
		$$->setCFG("factor","LPAREN expression RPAREN");
		$$->makechild($1);$$->makechild($2);$$->makechild($3);
		}
		| CONST_INT{
		PrintCFG("factor","CONST_INT");
		$$ = new SymbolInfo();
		$$->setCFG("factor","CONST_INT");
		$$->makechild($1);
		} 
		| CONST_FLOAT{
		PrintCFG("factor","CONST_FLOAT");
		$$ = new SymbolInfo();
		$$->setCFG("factor","CONST_FLOAT");
		$$->makechild($1);
		}
		| variable INCOP{
		PrintCFG("factor","variable INCOP");
		$$ = new SymbolInfo();
		$$->setCFG("factor","variable INCOP");
		$$->makechild($1);$$->makechild($2);
		} 
		| variable DECOP{
		PrintCFG("factor","variable DECOP");
		$$ = new SymbolInfo();
		$$->setCFG("factor","variable DECOP");
		$$->makechild($1);$$->makechild($2);
		}
		;
	
argument_list : arguments{
		PrintCFG("argument_list","arguments");
		$$ = new SymbolInfo();
		$$->setCFG("argument_list","arguments");
		$$->makechild($1);
		}
		|{
		PrintCFG("argument_list","");
		$$ = new SymbolInfo();
		$$->setCFG("argument_list","");
		}
		;
	
arguments : arguments COMMA logic_expression{
		PrintCFG("arguments","arguments COMMA logic_expression");
		$$ = new SymbolInfo();
		$$->setCFG("arguments","arguments COMMA logic_expression");
		$$->makechild($1);$$->makechild($2);$$->makechild($3);
		}
	    | logic_expression{
		PrintCFG("arguments","logic_expression");
		$$ = new SymbolInfo();
		$$->setCFG("arguments","logic_expression");
		$$->makechild($1);
		}
	    ;
 
%%


void yyerror(char* s){
    printf("error - > %s \n",s);
}

void End()
{
	sym.quit();
	com << "Total Lines: " << yylineno << endl;
	com << "Total Errors: " << error << endl;
}

void SetUp()
{
	cg.generateCode(head);
	code.close();
	cg.optimizeCode();
	for(auto s:cg.globalList)
		s->printid();
}

int main(int argc,char *argv[])
{   
    FILE* fp;
    if((fp=fopen(argv[1],"r"))==NULL)
	{
		printf("Cannot Open Input File.\n");
		exit(1);
	}
    
	yyin = fp;
    
	yyparse();
    
	printf("Parsing Successful!\n");

	End();

    fclose(fp);
	tree.close();
	com.close();
	err.close();
	
	SetUp();
    
	return 0;
}
