%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "include/tab_simb.h"
#include "y.tab.h"



FILE *yyin;

void validarCotaEntero(char*);
void validarCotaReal(char*);
void validarCotaCaracteres(char*);
extern Lista listaSimbolos;
extern int boolCompiladoOK;
	
%}
%option noyywrap  
%option yylineno 


DIGITO			[0-9]
LETRA			[a-zA-Z]
ID				{LETRA}({LETRA}|{DIGITO})*
INT				{DIGITO}+
FLOAT		({DIGITO})*"."({DIGITO})*
COMILLAS		"\""
COM_INI			"*-" 
COM_FIN			"-*"
CARACTERES		({LETRA}|@|\!|\$|\%|\&|\/|\(|\)|\=|\\|\?|\:|\*|\+|\-|\.|\[|\]|\,)
ESPACIO			" "
STRING		{COMILLAS}({CARACTERES}|{DIGITO}|{ESPACIO})+{COMILLAS}
COMENTARIO		{COM_INI}({LETRA}|{DIGITO}|{ESPACIO}|{CARACTERES})*{COM_FIN}




%%
("si")			     { printf("\nConstante SI: %s\n", yytext);return SI;}
("sino")		     { printf("\nConstante SINO: %s\n", yytext);return SINO;}
"mientras"			 { printf("\nConstante WHILE: %s\n", yytext);return WHILE;}
"leer"			     { printf("\nConstante READ: %s\n", yytext);return READ;}
"escribir"			 { printf("\nConstante WRITE: %s\n", yytext);return WRITE;}
"=="			     { printf("\nConstante COMP_IGUAL: %s\n", yytext);return COMP_IGUAL;}
">"				     { printf("\nConstante COMP_MAYOR: %s\n", yytext);return COMP_MAYOR;}
"<"				     { printf("\nConstante COMP_MENOR: %s\n", yytext);return COMP_MENOR;}
">="			     { printf("\nConstante COMP_MAYOR_IGUAL: %s\n", yytext);return COMP_MAYOR_IGUAL;} 
"<="			     { printf("\nConstante COMP_MENOR_IGUAL: %s\n", yytext);return COMP_MENOR_IGUAL;}
"!="			     { printf("\nConstante COMP_DISTINTO: %s\n", yytext);return COMP_DISTINTO;}
":""="			     { printf("\nConstante OPAR_ASIG: %s\n", yytext);return OPAR_ASIG;}
"Int"			     { printf("\nConstante TIPO_INT: %s\n", yytext);return TIPO_INT;} 
"Float"			     { printf("\nConstante TIPO_FLOAT: %s\n", yytext);return TIPO_FLOAT;} 
"String"		     { printf("\nConstante TIPO_STRING: %s\n", yytext);return TIPO_STRING;}
"init"			     { printf("\nConstante DECVAR: %s\n", yytext);return DECVAR;} 
"AND"			     { printf("\nConstante OP_LOG_AND: %s\n", yytext);return OP_LOG_AND;}
"OR"			     { printf("\nConstante OP_LOG_OR: %s\n", yytext);return OP_LOG_OR;}
"NOT"			     { printf("\nConstante OP_LOG_NOT: %s\n", yytext);return OP_LOG_NOT;} 
"ContarPrimos"		 { printf("\nConstante ContarPrimos: %s\n", yytext); return ContarPrimos;} 
"aplicarDescuento"   { printf("\nConstante aplicarDescuento: %s\n", yytext); return aplicarDescuento;} 


{INT}	     { validarCotaEntero(yytext); printf("\nConstante INT: %s\n", yytext); insertarEnLista(&listaSimbolos, yytext, tINT); yylval.int_val = atoi(yytext); return INT;}
{FLOAT}		     { validarCotaReal(yytext); printf("\nConstante FLOAT: %s\n", yytext); insertarEnLista(&listaSimbolos, yytext, tFLOAT); strcpy(yylval.string_val, yytext); return FLOAT; }
{STRING}	     { validarCotaCaracteres(yytext); printf("\nConstante STRING: %s\n", yytext); insertarEnLista(&listaSimbolos, yytext, tSTRING); strcpy(yylval.string_val, yytext); return STRING; }
{ID}			     { validarCotaCaracteres(yytext); printf("\nConstante ID: %s\n", yytext); insertarEnLista(&listaSimbolos, yytext, tID); strcpy(yylval.string_val, yytext); return ID; }
{COMENTARIO}	     { printf("\nComentario que sera descartado:  %s\n",yytext); }
     
"+"				     { printf("\nConstante OP_MAS: %s\n", yytext);return OP_MAS;}  
"-"				     { printf("\nConstante OP_MENOS: %s\n", yytext);return OP_MENOS;}
"*"				     { printf("\nConstante OP_MULT: %s\n", yytext);return OP_MULT;}
"/"				     { printf("\nConstante OP_DIV: %s\n", yytext);return OP_DIV;}
":"				     { printf("\nConstante DOS_PUNTOS: %s\n", yytext);return DOS_PUNTOS;}
";"				     { printf("\nConstante PUN_Y_COM: %s\n", yytext);return PUN_Y_COM;}
","				     { printf("\nConstante COMA: %s\n", yytext);return COMA;}
"("				     { printf("\nConstante PAR_A: %s\n", yytext);return PAR_A;}
")"				     { printf("\nConstante PAR_C: %s\n", yytext);return PAR_C;}
"{"				     { printf("\nConstante LLAVE_A: %s\n", yytext);return LLAVE_A;}
"}"				     { printf("\nConstante LLAVE_C: %s\n", yytext);return LLAVE_C;}
"["				     { printf("\nConstante COR_A: %s\n", yytext);return COR_A;}
"]"				     { printf("\nConstante COR_C: %s\n", yytext);return COR_C;}	

"\n"      		
"\t"
"\n\t"
"\r\n"
" "
.

%%

void validarCotaEntero(char* str)
{
	int numero = atoi(str);
	if(numero<=-32768|| numero>=32767)
	{
		printf("El valor ingresado para el entero se encuentra fuera del rango valido\n");
		boolCompiladoOK=0;
		system("Pause");
		exit(1);
	}
}


void validarCotaReal(char* str)
{
	float numero = atof(str);
	if((numero < pow(1.18,-38)) || (numero > pow(3.4,38)))
	{
		printf("ERROR! El valor ingresado para el real se encuentra fuera del rango valido\n");
		boolCompiladoOK=0;
		system("Pause");
		exit(1);	
	}
}

void validarCotaCaracteres(char* str)
{
	if(strlen(str)>40)
	{
		printf("ERROR! El valor ingresado para la cadena de caracteres se encuentra fuera del rango valido de 40 caracteres\n");
		boolCompiladoOK=0;
		system("Pause");
		exit(1);
	}
}

