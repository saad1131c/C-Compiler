%{
#include <iostream>
#include "SymbolTable.h"
using namespace std;
int yylex(void);
void yyerror(char* s);
extern FILE *yyin;
extern SymbolTable sym;
extern int error;
extern int yylineno;
vector<SymbolInfo*> id_list;
ofstream com("log.txt");
ofstream tree("parseTree.txt");
ofstream err("error.txt");
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
	for(auto s:id_list)
	{	
		//s->printid();
		sym.Insert(s);
	}
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
		 
func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement{
		PrintCFG("func_definition","type_specifier ID LPAREN parameter_list RPAREN compound_statement");
		$$ = new SymbolInfo();
		$$->setCFG("func_definition","type_specifier ID LPAREN parameter_list RPAREN compound_statement");
		$$->makechild($1);$$->makechild($2);$$->makechild($3);$$->makechild($4);$$->makechild($5);$$->makechild($6);
		$2->setVarType("FUNCTION");
		$2->setRetType($1->getType());
		insertSymbols($2);
		} 
		| type_specifier ID LPAREN RPAREN compound_statement{
		PrintCFG("func_definition","type_specifier ID LPAREN RPAREN compound_statement");
		$$ = new SymbolInfo();
		$$->setCFG("func_definition","type_specifier ID LPAREN RPAREN compound_statement");
		$$->makechild($1);$$->makechild($2);$$->makechild($3);$$->makechild($4);$$->makechild($5);
		$2->setVarType("FUNCTION");
		$2->setRetType($1->getType());
		insertSymbols($2);
		}
 		;				


parameter_list  : parameter_list COMMA type_specifier ID{
		PrintCFG("parameter_list","parameter_list COMMA type_specifier ID");
		$$ = new SymbolInfo();
		$$->setCFG("parameter_list","parameter_list COMMA type_specifier ID");
		$$->makechild($1);$$->makechild($2);$$->makechild($3);$$->makechild($4);
		$4->setRetType($3->getType());
		id_list.push_back($4);
		}
		| parameter_list COMMA type_specifier{
		PrintCFG("parameter_list","parameter_list COMMA type_specifier");
		$$ = new SymbolInfo();
		$$->setCFG("parameter_list","parameter_list COMMA type_specifier");
		$$->makechild($1);$$->makechild($2);$$->makechild($3);
		}
 		| type_specifier ID{
		PrintCFG("parameter_list","type_specifier ID");
		$$ = new SymbolInfo();
		$$->setCFG("parameter_list","type_specifier ID");
		$$->makechild($1);$$->makechild($2);
		$2->setRetType($1->getType());
		id_list.push_back($2);
		}
		| type_specifier{
		PrintCFG("parameter_list","type_specifier");
		$$ = new SymbolInfo();
		$$->setCFG("parameter_list","type_specifier");
		$$->makechild($1);
		}
 		;

 		
compound_statement : LCURL{
	sym.EnterScope();
	insertSymbols();
	id_list.clear();
} statements RCURL{
		PrintCFG("compound_statement","LCURL statements RCURL");
		sym.PrintAllScope();
		sym.ExitScope();
		$$ = new SymbolInfo();
		$$->setCFG("compound_statement","LCURL statements RCURL");
		$$->makechild($1);$$->makechild($3);$$->makechild($4);
		}
 		| LCURL{
			sym.EnterScope();
			insertSymbols();
			id_list.clear();
		} RCURL{
		PrintCFG("compound_statement","LCURL RCURL");
		sym.PrintAllScope();
		sym.ExitScope();
		$$ = new SymbolInfo();
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
		}
 		| declaration_list COMMA ID LTHIRD CONST_INT RTHIRD{
		PrintCFG("declaration_list","declaration_list COMMA ID LSQUARE CONST_INT RSQUARE");
		$$ = new SymbolInfo();
		$$->setCFG("declaration_list","declaration_list COMMA ID LSQUARE CONST_INT RSQUARE");
		$$->makechild($1);$$->makechild($2);$$->makechild($3);$$->makechild($4);$$->makechild($5);$$->makechild($6);
		$3->setVarType("ARRAY");
		id_list.push_back($3);
		}
 		| ID{
		PrintCFG("declaration_list","ID");
		$$ = new SymbolInfo();
		$$->setCFG("declaration_list","ID");
		$$->makechild($1);
		id_list.push_back($1);
		}
 		| ID LTHIRD CONST_INT RTHIRD{
		PrintCFG("declaration_list","ID LSQUARE CONST_INT RSQUARE");
		$$ = new SymbolInfo();
		$$->setCFG("declaration_list","ID LSQUARE CONST_INT RSQUARE");
		$$->makechild($1);$$->makechild($2);$$->makechild($3);$$->makechild($4);
		$1->setVarType("ARRAY");
		id_list.push_back($1);
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
		} 		
	 	| ID LTHIRD expression RTHIRD {
		PrintCFG("variable","ID LSQUARE expression RSQUARE");
		$$ = new SymbolInfo();
		$$->setCFG("variable","ID LSQUARE expression RSQUARE");
		$$->makechild($1);$$->makechild($2);$$->makechild($3);$$->makechild($4);
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
    
	return 0;
}
