  %{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "y.tab.h"


struct struct_tablaSimbolos
{
	char nombre[100];
	char tipo[100];
	char valor[50];
	char longitud[100];
};

int yystopparser=0;
FILE  *yyin;
extern int yylineno;
extern char *yytext;

int yylex();
int yyerror(char *);
extern struct struct_tablaSimbolos tablaSimbolos[1000]; 
extern int puntero_array;
int contadorTipos = 0;
char* auxTipoDato;
char matrizTipoDato[100][10];
char matrizVariables[100][10];
int contadorId = 0;
int agregarTipoEnTablaSimbolos(char* nombre, int contadorId);
void escribirEnTablaSimbolos();
int agregarTipoTablaDeSimbolos(char nombre[][10],int count, int contadorTipos);

%}
%right OPAR_ASIG
%left OP_MAS OP_MENOS
%left OP_MULT OP_DIV
%right MENOS_UNARIO

%token IF
%token ELSE
%token WHILE
%token WRITE
%token READ
%token DECVAR
%token COMP_IGUAL
%token COMP_MAYOR
%token COMP_MENOR
%token COMP_MAYOR_IGUAL
%token COMP_MENOR_IGUAL
%token COMP_DISTINTO
%token OPAR_ASIG
%token TIPO_INT
%token TIPO_FLOAT
%token TIPO_STRING
%token <num>CTE_ENTERA
%token <real>CTE_REAL
%token <str>CTE_STRING
%token OP_MAS 
%token OP_MENOS
%token OP_MULT
%token OP_DIV
%token OP_LOG_AND
%token OP_LOG_OR
%token OP_LOG_NOT
%token DOS_PUNTOS
%token PUN_Y_COM
%token COMA
%token <strid>ID
%token PAR_A
%token PAR_C
%token LLAVE_A
%token LLAVE_C
%token COR_A
%token COR_C
%token ContarPrimos
%token aplicarDescuento


%union{
char * strid;
char * num;
char * real; 
char * str;
}

%%
programa: { printf("***** Inicio de Programa *****\n"); } zona_declaracion algoritmo { printf("\n***** Compilacion exitosa: OK *****\n");};
				  
zona_declaracion:	declaraciones;

declaraciones:	declaracion
				|declaraciones declaracion;

declaracion:	DECVAR LLAVE_A { printf("***** Inicio declaracion de variables *****\n"); } lista_declaracion LLAVE_C {printf("***** Fin declaracion de variables *****\n");};

lista_declaracion:	lista_var DOS_PUNTOS lista_tipo
					| lista_declaracion lista_var DOS_PUNTOS lista_tipo;


lista_var:		ID {strcpy(matrizVariables[contadorId],yylval.strid) ;  contadorId++; }
				| lista_var COMA ID {strcpy(matrizVariables[contadorId],yylval.strid) ; contadorId++;  };

 
lista_tipo:		 TIPO_INT    { auxTipoDato="int"; strcpy(matrizTipoDato[contadorTipos],auxTipoDato); agregarTipoTablaDeSimbolos(matrizVariables,contadorId,contadorTipos); contadorTipos++; printf("Variable Entera\n"); }
				|TIPO_FLOAT  {  auxTipoDato="float"; strcpy(matrizTipoDato[contadorTipos],auxTipoDato); agregarTipoTablaDeSimbolos(matrizVariables,contadorId,contadorTipos); contadorTipos++; printf("Variable Real\n"); }
				|TIPO_STRING { auxTipoDato="string"; strcpy(matrizTipoDato[contadorTipos],auxTipoDato); agregarTipoTablaDeSimbolos(matrizVariables,contadorId,contadorTipos); contadorTipos++; printf("Constante String\n"); };
              

algoritmo:		bloque {printf("\n***** Fin de bloque *****\n");};

bloque:			sentencia
				|bloque sentencia;

sentencia:		asignacion { printf(" - asignacion - OK \n"); }
				|seleccion { printf(" - seleccion - OK \n"); }
				|ciclo     { printf(" - ciclo - OK \n"); }
				|entrada   { printf(" - entrada - OK \n"); }
				|salida    { printf(" - salida - OK \n"); }
				|descuento { printf(" - descuento - OK \n"); };


descuento: aplicarDescuento PAR_A parametro1 COMA COR_A lista COR_C COMA parametro2 PAR_C  { printf("aplicarDescuento - OK\n"); };

parametro1: CTE_REAL { printf("parametro 1 REAL monto descuento - OK\n"); } ; 

parametro2: CTE_ENTERA { printf("parametro 2 ENTERA indice descuento- OK\n"); } ;

lista: numero
	   | lista COMA numero { printf("aplicarDescuento Lista - OK\n"); };

numero:			CTE_ENTERA { printf("Condicion ENTERA descuento- OK\n"); } 
				|CTE_REAL { printf("Condicion REAL descuento - OK\n"); } ; 

ciclo:			WHILE PAR_A condicion PAR_C LLAVE_A bloque LLAVE_C;
       
asignacion:		ID OPAR_ASIG expresion
				| ID OPAR_ASIG primos ;

primos:			ContarPrimos PAR_A COR_A expre  COR_C PAR_C {printf("\n Contar Primos\n");} ;

seleccion: 		IF  PAR_A condicion PAR_C LLAVE_A bloque LLAVE_C { printf("seleccion - OK\n"); } 
				| IF  PAR_A condicion PAR_C LLAVE_A bloque LLAVE_C ELSE LLAVE_A bloque LLAVE_C;

condicion:		comparacion                         { printf("Comparacion - OK\n"); }
				|comparacion OP_LOG_AND comparacion { printf("Condicion OP_LOG_AND- OK\n"); }
				|comparacion OP_LOG_OR comparacion	{ printf("Condicion OP_LOG_OR- OK\n"); }
				|OP_LOG_NOT comparacion             { printf("Condicion OP_LOG_NOT- OK\n"); };

comparacion:	expresion COMP_IGUAL expresion
				|expresion COMP_MAYOR  expresion        {printf(" - Comparacion Mayor\n");}	
				|expresion COMP_MENOR expresion         {printf(" - Comparacion Menor\n");}
				|expresion COMP_MAYOR_IGUAL expresion   {printf(" - Comparacion Mayor Igual\n");}
				|expresion COMP_MENOR_IGUAL expresion   {printf(" - Comparacion Menor Igual\n");}
				|expresion COMP_DISTINTO expresion;

expre: expresion {printf("\n Contar Primos expresion\n");}
	  |expre COMA expresion {printf("\n Contar Primos expresiones\n");};

				
expresion:		expresion  { printf(" expresion"); } OP_MAS termino { printf(" termino"); }
				|expresion { printf(" expresion"); }OP_MENOS termino { printf(" termino"); }
				| OP_MENOS termino %prec MENOS_UNARIO { printf(" expresion menos_unario"); }
				|termino   { printf(" termino"); };
									

termino:		termino OP_MULT factor { printf(" factor"); }
				|termino OP_DIV factor { printf(" factor"); }
				|factor { printf(" factor"); };
                         
factor:			ID { printf("Condicion ID - OK\n"); } 
				|CTE_ENTERA { printf("Condicion ENTERA - OK\n"); } 
				|CTE_REAL { printf("Condicion REAL - OK\n"); } 
				|CTE_STRING { printf("Condicion STRING - OK\n"); };
				
				 
entrada: 		READ PAR_A ID PAR_C;

salida:			 WRITE CTE_STRING 
			    |WRITE PAR_A ID PAR_C 
				|WRITE PAR_A CTE_STRING PAR_C;
    
%%
 
int main(int argc,char *argv[])
{
  if ((yyin = fopen(argv[1], "rt")) == NULL)
  {
	printf("\nERROR! No se pudo abrir el archivo: %s\n", argv[1]);
  }
  else
  {
	yyparse();
	escribirEnTablaSimbolos();
  }
  fclose(yyin);
  system ("Pause");
  return 0;
}

int agregarTipoEnTablaSimbolos(char* nombre, int contadorTipos)
{     
		int i;          
        char lexema[50]; 
		//lexema[0]='_';
		//lexema[1]='\0';
		lexema[0]='\0';
		strcat(lexema,nombre);
                 
		for(i = 0; i < puntero_array; i++)
		{
			if(strcmp(tablaSimbolos[i].nombre, lexema) == 0)
			{
				if(tablaSimbolos[i].tipo[0] == '\0')
				strcpy(tablaSimbolos[i].tipo,matrizTipoDato[contadorTipos]);
		  
				return 1; 
			}
		}
	
	return 0;	
}

int agregarTipoTablaDeSimbolos(char nombre[][10],int count, int count_type)
{
	int e;
	for(e = 0; e < count; e++)
	{
		agregarTipoEnTablaSimbolos(nombre[e],count_type);
	}
}