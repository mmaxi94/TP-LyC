flex Lexico.l
bison -dyv Sintactico.y

gcc.exe lex.yy.c y.tab.c ./src/tab_simb.c ./src/arbol.c ./src/pila.c ./src/cola.c -o lyc-compiler-2.0.0
lyc-compiler-2.0.0 test.txt
dot -Tpng intermediate-code.dot -o arbol.png

@echo off
del lyc-compiler-2.0.0
del lex.yy.c
del y.tab.c
del y.tab.h
del y.output
del intermediate-code.dot
pause
