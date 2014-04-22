proj: lex.yy.c parser.tab.c
	gcc lex.yy.c parser.tab.c -o parser

lex.yy.c: lexer.l parser.tab.h
	flex lexer.l

parser.tab.h: parser.tab.c
parser.tab.c: parser.y
	bison -d parser.y

clean:
	rm -f parser lex.yy.c parser.tab.h parser.tab.c
