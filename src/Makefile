compiler: scanner.l parser.y main.c symbolTable.c codeGenerator.c
	flex scanner.l
	bison -y -d parser.y
	gcc -o compiler main.c symbolTable.c codeGenerator.c lex.yy.c y.tab.c -lfl

main.c:
	true

clean:
	rm -f core *.o lex.yy.c y.tab.c y.tab.h compiler compiler.exe
