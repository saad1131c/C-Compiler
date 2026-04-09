%option noyywrap
%option yylineno
%x STRING
%x MLCOMMENT
%x SLCOMMENT

%{
#include <iostream>
#include <fstream>
#include <string>
#include "2005059_SymbolTable.cpp"
using namespace std;

#define sizes 10
ofstream out("2005059_token.txt");


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
	if(first == "ID"){
		bool decide = sym.Insert(second,first);
		if(decide == true) sym.PrintAllScope();
		else 
		{
			com << "\t" << second << " already exists in the current ScopeTable" << endl;
		}
	}
}

void printError(string first,string second)
{
	com << "Error at line# " << yylineno << ":" << " " << first << " " << second << endl;
}

void printtoken(string first, string second)
{    if(first != "SINGLE LINE STRING" && first != "MULTI LINE STRING")
		{printlog(first,second);}
     out << "<" << first << ", " << second << ">" << endl;
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

%}

DIGIT [0-9]
LETTER [a-zA-Z]


ADDOP [+-]
MULOP [*/%]
INCOP \+\+|--
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
^[ \t]+    {countWhiteSpace(yytext);printWarning();}
[ \t]+    {}
(\n([ \t]*))+	{
	countWhiteSpace(yytext);printWarning();
	}
(\n([ \t]*))+\}	{
	sym.ExitScope();requiredtab--;
	if(requiredtab < 0) requiredtab = 0;
	countWhiteSpace(yytext);printWarning(); 
	printtoken("RCURL","}");
	}

{KEYWORD} {printtoken(uppercase(yytext),yytext);}
{ADDOP} {printtoken("ADDOP",yytext);}
{MULOP} {printtoken("MULOP",yytext);}
{INCOP} {printtoken("INCOP",yytext);}
{RELOP} {printtoken("RELOP",yytext);} 
{ASSIGNOP} {printtoken("ASSIGNOP",yytext);}
{LOGICOP} {printtoken("LOGICOP",yytext);}
{BITOP} {printtoken("BITOP",yytext);} 
{NOT} {printtoken("NOT",yytext);} 
{LPAREN} {printtoken("LPAREN",yytext);} 
{RPAREN} {printtoken("RPAREN",yytext);} 
{LCURL} {printtoken("LCURL",yytext);sym.EnterScope();requiredtab++;} 
{RCURL}	{printtoken("RCURL","}");sym.ExitScope();requiredtab--;if(requiredtab < 0) requiredtab = 0;}
{LSQUARE} {printtoken("LSQUARE",yytext);}
{RSQUARE} {printtoken("RSQUARE",yytext);} 
{COMMA} {printtoken("COMMA",yytext);}
{SEMICOLON} {printtoken("SEMICOLON",yytext);}

{INTEGER} {printtoken("CONST_INT",yytext);}
{FLOAT} {printtoken("CONST_FLOAT",yytext);}  

\'{MULTICHAR}\' {printtoken("CONST_CHAR",getToken(removequote(yytext)));}
\'{SINGLECHAR}\' {printtoken("CONST_CHAR",removequote(yytext));}
{MULTIERROR} {printError("MULTICHAR_CONST_CHAR",yytext);error++;}
{EMPTYCHAR} {printError("EMPTY_CONST_CHAR",yytext);error++;}
{UNFINISHEDCHAR}  {printError("UNFINISHED_CONST_CHAR",yytext);error++;}

{IDENTIFIER} {printtoken("ID",yytext);sym.Insert(yytext,"ID");}
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
	sym.PrintAllScope();sym.quit();
	com << "Total lines: " << yylineno << endl;
	com << "Total errors: " << error << endl;
	com << "Total warnings: " << warning << endl;
	return 0;
	}
%%

int main(int argc,char *argv[]){
	
	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
	
	yyin= fin;
	yylex();
	fclose(yyin);
    out.close();
    com.close();
	return 0;
}