%option noyywrap
%option yylineno
%x STRING
%x MLCOMMENT
%x SLCOMMENT

%{
#include <iostream>
#include <fstream>
#include <string>
#include "SymbolTable.h"
#include "y.tab.h"

using namespace std;

extern ofstream com;
extern YYSTYPE yylval;

#define sizes 11
// ofstream out("token.txt");


string s;
string status;
string raw;
string comment;
SymbolTable sym(sizes);

int count = 0;
int requiredtab = 0;

int error = 0;
int warning = 0;

int tab;
int space;
int others;


void printlog(string first, string second)
{
	com << "Line# " << yylineno << ":" << " Token " << "<" << first << "> " << "Lexeme " << second << " found" << endl;
	// if(first == "ID"){
	// 	bool decide = sym.Insert(second,first);
	// 	if(decide == true) sym.PrintAllScope();
	// 	else 
	// 	{
	// 		com << "\t" << second << " already exists in the current ScopeTable" << endl;
	// 	}
	// }
}

void printError(string first,string second)
{
	com << "Error at line# " << yylineno << ":" << " " << first << " " << second << endl;
}

void printtoken(string first, string second)
{    if(first != "SINGLE LINE STRING" && first != "MULTI LINE STRING")
		{printlog(first,second);}
     //out << "<" << first << ", " << second << ">" << endl;
}

string uppercase(string s) {
    for (int i = 0; i < s.size(); i++)
        s[i] = toupper(s[i]);
    return s;
}

string getToken(string s)
{	
	switch(s[1]){
	case 'n':return "\n";
	case 't':return "\t";
	case 'a':return "\a";
	case 'f':return "\f";
	case 'r':return "\r";
	case 'b':return "\b";
	case 'v':return "\v";
    case '0':return "\0";
    case '"':return "\"";
    case '\\':return "\\";
    case '\'':return "\'";
	}

    return "";
}

string removequote(string s)
{
    s.erase(s.begin());
    s.pop_back();
    return s;
}

void countWhiteSpace(string str)
{
	tab = space = others = 0;
	for(int i = str.size()-1; i >= 0;i--)
	{
		if(str[i] == '\n') {break;}
		if(str[i] == '\t') {tab++;s += str[i];} 
		else if(str[i] == ' ') {space++;s += str[i];}
		else if(str[i] == '}') {}
		else {others++;s += str[i];}
	}
}

void printWarning()
{
	if(space == 0)
	{
		if(others == 0)
		{
		if(tab == requiredtab)
		{
			return;
		}
		else{
			com << "Line# " << yylineno << ": " << "warning, " << requiredtab << " of tabs needed but got " << tab << " tabs." << endl;
			warning++;
		}
		}
		else
		{
			com << "Line# " << yylineno << ": " << "warning, " << requiredtab << " of tabs needed but got " << "special chars." << endl;
			warning++;
		}
	}
	else{
			com << "Line# " << yylineno << ": " << "Warning, tab requrired but got space." << endl;
			warning++;
	}
}

// void InsertSymbol(string symname,string symtype)
// {
// 	SymbolInfo * s = sym.Lookup(symname);
// 	if(s == NULL)	{sym.Insert(symname,symtype);}
// }

%}

DIGIT [0-9]
LETTER [a-zA-Z]


ADDOP [+-]
MULOP [*/%]
INCOP \+\+
DECOP --
RELOP <=|>=|==|!=|<|>
ASSIGNOP [=]
LOGICOP &&|\|\|
BITOP &|\||\^|<<|>>
NOT !
LPAREN \(
RPAREN \)
LCURL \{
RCURL \}
LSQUARE \[
RSQUARE \]
COMMA \,
SEMICOLON \;			

KEYWORD if|for|do|int|float|void|switch|default|else|while|break|char|double|return|case|continue

INTEGER {DIGIT}+
REDUNDANT_DECIMAL {INTEGER}\.{INTEGER}(\.{INTEGER})+(E[+-]?({INTEGER}|{FRACTION}))?

FRACTION \.{INTEGER}|{INTEGER}\.|{INTEGER}\.{INTEGER}
POWERNUMBER ({FRACTION}|{INTEGER})E[+-]?{INTEGER}

FLOAT {FRACTION}|{POWERNUMBER}
ILL_FORMED_NUMBER ({INTEGER}|{FRACTION})E[+-]?{FRACTION}

IDENTIFIER (_|{LETTER})({LETTER}|{DIGIT}|_)*
INVALID_IDENTIFIER {INTEGER}{IDENTIFIER}


MULTICHAR (\\n)|(\\t)|(\\\\)|(\\')|(\\\")|(\\f)|(\\a)|(\\r)|(\\b)|(\\v)|(\\0)
SINGLECHAR [^\'\\\n\r]
EMPTYCHAR ''
MULTIERROR \'.(.)+\'
UNFINISHEDCHAR \'({SINGLECHAR}|{MULTICHAR})?


%%
^[ \t]+    {
	countWhiteSpace(yytext);//printWarning();
	}
[ \t]+    {}
(\n([ \t]*))+	{
	countWhiteSpace(yytext);
	//printWarning();
	}
(\n([ \t]*))+\}	{
	requiredtab--;
	if(requiredtab < 0) requiredtab = 0;
	countWhiteSpace(yytext);
	//printWarning(); 
	printtoken("RCURL","}");
	yylval.symbol = new SymbolInfo("}","RCURL",yylineno);
	return RCURL;
	}

{KEYWORD} {
		   printtoken(uppercase(yytext),yytext);
		   string upper = uppercase(yytext); 
		   if(upper == "IF") {yylval.symbol = new SymbolInfo(yytext,upper,yylineno);return IF;}
		   else if(upper == "FOR") {yylval.symbol = new SymbolInfo(yytext,upper,yylineno);return FOR;}
		   //else if(upper == "DO") return DO;
		   else if(upper == "INT") {yylval.symbol = new SymbolInfo(yytext,upper,yylineno);return INT;}
		   else if(upper == "FLOAT") {yylval.symbol = new SymbolInfo(yytext,upper,yylineno);return FLOAT;}
		   else if(upper == "VOID") {yylval.symbol = new SymbolInfo(yytext,upper,yylineno);return VOID;}
		   //else if(upper == "SWITCH") return SWITCH;
		   //else if(upper == "DEFAULT") return DEFAULT;
		   else if(upper == "ELSE") {yylval.symbol = new SymbolInfo(yytext,upper,yylineno);return ELSE;}
		   else if(upper == "WHILE") {yylval.symbol = new SymbolInfo(yytext,upper,yylineno);return WHILE;}
		   //else if(upper == "BREAK") return BREAK;
		   //else if(upper == "CHAR") return CHAR;
		   //else if(upper == "DOUBLE") return DOUBLE;
		   else if(upper == "RETURN") {yylval.symbol = new SymbolInfo(yytext,upper,yylineno);return RETURN;}
		   //else if(upper == "CASE") return CASE;
		   //else if(upper == "CONTINUE") return CONTINUE;
		   }
{ADDOP} {printtoken("ADDOP",yytext);yylval.symbol = new SymbolInfo(yytext,"ADDOP",yylineno);return ADDOP;}
{MULOP} {printtoken("MULOP",yytext);yylval.symbol = new SymbolInfo(yytext,"MULOP",yylineno);return MULOP;}
{INCOP} {printtoken("INCOP",yytext);yylval.symbol = new SymbolInfo(yytext,"INCOP",yylineno);return INCOP;}
{DECOP} {printtoken("DECOP",yytext);yylval.symbol = new SymbolInfo(yytext,"DECOP",yylineno);return DECOP;}
{RELOP} {printtoken("RELOP",yytext);yylval.symbol = new SymbolInfo(yytext,"RELOP",yylineno);return RELOP;} 
{ASSIGNOP} {printtoken("ASSIGNOP",yytext);yylval.symbol = new SymbolInfo(yytext,"ASSIGNOP",yylineno);return ASSIGNOP;}
{LOGICOP} {printtoken("LOGICOP",yytext);yylval.symbol = new SymbolInfo(yytext,"LOGICOP",yylineno);return LOGICOP;}
{BITOP} {
	printtoken("BITOP",yytext);
	//return BITOP;
	} 
{NOT} {printtoken("NOT",yytext);yylval.symbol = new SymbolInfo(yytext,"NOT",yylineno);return NOT;} 
{LPAREN} {printtoken("LPAREN",yytext);yylval.symbol = new SymbolInfo(yytext,"LPAREN",yylineno);return LPAREN;} 
{RPAREN} {printtoken("RPAREN",yytext);yylval.symbol = new SymbolInfo(yytext,"RPAREN",yylineno);return RPAREN;} 
{LCURL} {printtoken("LCURL",yytext);requiredtab++;yylval.symbol = new SymbolInfo(yytext,"LCURL",yylineno);return LCURL;} 
{RCURL}	{printtoken("RCURL","}");requiredtab--;if(requiredtab < 0) requiredtab = 0;yylval.symbol = new SymbolInfo(yytext,"RCURL",yylineno);return RCURL;}
{LSQUARE} {printtoken("LSQUARE",yytext);yylval.symbol = new SymbolInfo(yytext,"LSQUARE",yylineno);return LTHIRD;}
{RSQUARE} {printtoken("RSQUARE",yytext);yylval.symbol = new SymbolInfo(yytext,"RSQUARE",yylineno);return RTHIRD;} 
{COMMA} {printtoken("COMMA",yytext);yylval.symbol = new SymbolInfo(yytext,"COMMA",yylineno);return COMMA;}
{SEMICOLON} {printtoken("SEMICOLON",yytext);yylval.symbol = new SymbolInfo(yytext,"SEMICOLON",yylineno);return SEMICOLON;}

{INTEGER} {printtoken("CONST_INT",yytext);yylval.symbol = new SymbolInfo(yytext,"CONST_INT",yylineno);return CONST_INT;}
{FLOAT} {printtoken("CONST_FLOAT",yytext);yylval.symbol = new SymbolInfo(yytext,"CONST_FLOAT",yylineno);return CONST_FLOAT;}  







\'{MULTICHAR}\' {printtoken("CONST_CHAR",getToken(removequote(yytext)));}
\'{SINGLECHAR}\' {printtoken("CONST_CHAR",removequote(yytext));}
{MULTIERROR} {printError("MULTICHAR_CONST_CHAR",yytext);error++;}
{EMPTYCHAR} {printError("EMPTY_CONST_CHAR",yytext);error++;}
{UNFINISHEDCHAR}  {printError("UNFINISHED_CONST_CHAR",yytext);error++;}

{IDENTIFIER} {printtoken("ID",yytext);yylval.symbol = new SymbolInfo(yytext,"ID",yylineno);return ID;}
{INVALID_IDENTIFIER} {printError("INVALID_ID_SUFFIX_NUM_PREFIX",yytext);error++;}
{REDUNDANT_DECIMAL}  {printError("TOO_MANY_DECIMAL_POINTS",yytext);error++;}
{ILL_FORMED_NUMBER}  {printError("ILLFORMED_NUMBER", yytext);error++;}



(\")	{BEGIN STRING;s="";status = "SINGLE LINE STRING";raw="\"";count = 0;}
<STRING>\"  {BEGIN INITIAL;raw += yytext;yylineno -= count;printlog(status,raw);yylineno += count;printtoken(status,s);}
<STRING>{MULTICHAR} {s+=getToken(yytext);raw += yytext;}
<STRING>\\([ \t]*\n[ \t]*)	{status = "MULTI LINE STRING";raw += yytext;count++;countWhiteSpace(yytext);printWarning();}
<STRING>\n	{BEGIN INITIAL;count = 1;yylineno -= count;printError("UNFINISHED_STRING",raw);yylineno += count;error++;}
<STRING><<EOF>>	{BEGIN INITIAL;yylineno -= count;printError("UNFINISHED_STRING",raw);yylineno += count;error++;}
<STRING>.	{s+=yytext;raw += yytext;}


(\/\*)	{BEGIN MLCOMMENT;count = 0;comment = "/*";}
<MLCOMMENT>.	{comment += yytext;}
<MLCOMMENT>\n	{comment += yytext;count++;}
<MLCOMMENT><<EOF>>	{printError("UNFINISHED_COMMENT",comment);BEGIN INITIAL;error++;}
<MLCOMMENT>(\*\/)	{BEGIN INITIAL;comment += yytext;yylineno -= count;printlog("MULTI LINE COMMENT",comment);yylineno += count;} 



(\/\/)	{BEGIN SLCOMMENT;comment = "//";count = 0;}
<SLCOMMENT>\\([ \t]*\n) {comment+=yytext;count++;}
<SLCOMMENT>\n   {BEGIN INITIAL;count++;yylineno -= count;printlog("SINGLE LINE COMMENT",comment);yylineno += count;}
<SLCOMMENT><<EOF>>	{BEGIN INITIAL;yylineno -= count;printlog("SINGLE LINE COMMENT",comment);yylineno += count;}
<SLCOMMENT>.	{comment += yytext;}

.   {printError("UNRECOGNIZED_CHAR",yytext);error++;}



<<EOF>>	{
	return 0;
	}
%%
