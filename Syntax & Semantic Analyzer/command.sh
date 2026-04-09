yacc -d -y parser.y
g++ -w -c -o y.o y.tab.c
flex lexer.l
g++ -w -c -o l.o lex.yy.c
g++ y.o l.o -lfl -o final
./final input.c
rm final l.o lex.yy.c y.o y.tab.c y.tab.h