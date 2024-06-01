  %{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "include/constantes.h"
#include "include/tab_simb.h"
#include "y.tab.h"
#include "include/arbol.h"
#include "include/pila.h"
#include "include/cola.h"
#define MAX_BUFFER_SIZE 1024

extern int yylineno;
extern char *yytext;


//nuevo
    int yystopparser=0;
    extern FILE* yyin;

    int yyerror();
    int yylex();

    char* concatenar(char*, char*, int);
    int estaContenido(char*, char*);
    void invertirCondicionNOT(NodoA *padre);
    int esPositivo(NodoA * padre);
	int validarRango(char* str);
	void obtenerNumeroPorIndice(const char* cadena, char* str);

    void maximo();

    Arbol compilado;
    Lista listaSimbolos;
    Lista listaIds;
    Pila anidaciones;
    Pila condAnidados;

    Cola colaIds;
    
    int boolCompiladoOK = 1;
	
    NodoA* CompiladoPtr, *ProgramaPtr, *DeclaPtr, *AlgoPtr,*EntradaPtr,*SalidaPtr,*Expreptr,*Primosptr,*Param1ptr,*Param2ptr, *Descuentoptr, *zona_declaracionPtr, *BloPtr, *DecPtr, *ListPtr, *SentPtr, *AsigPtr, *tipoAux,
            *CicPtr, *EvalPtr, *Eptr, *StrPtr, *ConPtr, *CmpPtr, *EptrAux, *BloAux, *Tptr, *Fptr, *CmpAux, *StrPtrAux,*Auxcicloptr;
    NodoA* EjePtr, * ConAux;
    NodoA* DecAsigPTr,* DecAsigMPtr,* ParamAsigPtr,* CtePtr, * ParamContPtr;
    char AuxDec[ID_LARGO_MAX + 1];
    NodoA* AuxPtr;
    NodoA * auxCont;
    char  auxTipo[7], strAux[VALOR_LARGO_MAX + 1],strAuxPos[VALOR_LARGO_MAX + 1],strContador2[VALOR_LARGO_MAX + 1], strAux2[VALOR_LARGO_MAX + 1], strAux3[VALOR_LARGO_MAX + 1],strAux5[MAX_BUFFER_SIZE], strAux6[MAX_BUFFER_SIZE], cmpAux[3], opAux[3];
    char strAuxAsig[VALOR_LARGO_MAX + 1];
    int intAux;
    float floatAux;
    int contador;
    int cantidadAuxiliares = 0;
    int contadorAuxiliares = 0; 
	int contador2;
	int contpos = 0;
	int indiceAux=0;
	

%}
%right OPAR_ASIG
%left OP_MAS OP_MENOS
%left OP_MULT OP_DIV
%right MENOS_UNARIO 

%token SI
%token SINO
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
%token <int_val>INT
%token <float_val>FLOAT
%token <string_val>STRING
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
%token <string_val>ID
%token PAR_A
%token PAR_C
%token LLAVE_A
%token LLAVE_C
%token COR_A
%token COR_C
%token ContarPrimos
%token aplicarDescuento


%union{
    int int_val;
    float float_val;
    char string_val[50];
}

%%

compilado_ini: 
			programa    { compilado = ProgramaPtr;
						if(boolCompiladoOK == 1){
							printf("COMPILACION EXITOSA\n");
							imprimirArbolTexto(&compilado);
							imprimirArbolGrafico(&compilado);

						}
						else{
							printf("ERROR DE COMPILACION\n");
						}
						;  };

programa: { printf("***** Inicio de Programa *****\n"); } 	zona_declaracion algoritmo  
			{ProgramaPtr = crearNodo("Programa", AlgoPtr, NULL);  printf("\n***** Compilacion exitosa: OK *****\n");};
				  
zona_declaracion:	DECVAR LLAVE_A declaracion LLAVE_C  ;

//declaraciones:	declaracion
//				|declaraciones declaracion;

declaracion:	 { printf("***** Inicio declaracion de variables *****\n"); } lista_declaracion  {printf("***** Fin declaracion de variables *****\n");};
					
					
lista_declaracion:	dec
					| lista_declaracion dec {printf("\n declaraciones:");};

dec:		lista_var DOS_PUNTOS lista_tipo {asignarTipo(&listaIds, auxTipo);
														fusionarLista(&listaSimbolos, &listaIds);
     
														eliminarDeLista(&listaIds, AuxDec);
														while(!listaVacia(&listaIds)){
															eliminarDeLista(&listaIds, AuxDec);
															}
														};			


lista_var:		ID {
						if(idDeclarado(&listaSimbolos, $1)){ 
							printf("\nError, id: *%s* ya fue declarado\n", $1);
							return 1;
						};
						insertarEnLista(&listaIds, $1, tID);
						ListPtr = crearHoja($1);
					}
				| lista_var COMA ID {
										if(idDeclarado(&listaSimbolos, $3)){ 
													printf("\nError, id: *%s* ya fue declarado\n", $3);
													return 1;
												};
												
												insertarEnLista(&listaIds, $3, tID);
												ListPtr = crearNodo(",", ListPtr, crearHoja($3));
					};

 
lista_tipo:		 TIPO_INT    { strcpy(auxTipo, TINT); printf("Variable Entera\n"); }
				|TIPO_FLOAT  {  strcpy(auxTipo, TFLOAT); printf("Variable Real\n"); }
				|TIPO_STRING { strcpy(auxTipo, TSTRING); printf("Constante String\n"); };
              

algoritmo:		bloque {AlgoPtr = BloPtr; printf("\n***** Fin de bloque *****\n");};

bloque:			sentencia {BloPtr = SentPtr;}
				|bloque { apilar(&anidaciones, &BloPtr, sizeof(BloPtr)); } sentencia { 
					printf("\tbloque sentencia es bloque\n"); 
					desapilar(&anidaciones, &BloAux, sizeof(BloAux));
					BloPtr = crearNodo("bloque", BloAux, SentPtr);
					};

sentencia:		asignacion { printf(" - asignacion - OK \n"); SentPtr = AsigPtr; }
				|seleccion { printf(" - seleccion - OK \n"); SentPtr = EvalPtr; }
				|ciclo     { printf(" - ciclo - OK \n"); SentPtr = CicPtr;}
				|entrada   { printf(" - entrada - OK \n"); SentPtr = EntradaPtr;}
				|salida    { printf(" - salida - OK \n"); SentPtr = SalidaPtr;}
				|descuento { printf(" - descuento - OK \n"); SentPtr= Descuentoptr;};


descuento: aplicarDescuento PAR_A parametro1 COMA COR_A {strAux5[0] = '\0'; strAux6[0] = '\0'; contador2=1;} lista COR_C COMA parametro2 PAR_C  { obtenerNumeroPorIndice(strAux5,strAux6); 
snprintf(strContador2, VALOR_LARGO_MAX, "%d", contador2);

Auxcicloptr=
		crearNodo("bloque",crearNodo("bloque", Param1ptr, Param2ptr),crearNodo("=", crearHoja("@cant_elementos"),crearHoja(strContador2)))
	;
	

while (indiceAux < contador2)
{
	desencolar(&colaIds, strAux, STRING_LARGO_MAX + 1);
contpos++;
snprintf(strAuxPos, VALOR_LARGO_MAX, "_%d", contpos);

Auxcicloptr=
	crearNodo("bloque",
		Auxcicloptr,
		crearNodo("bloque", crearNodo("=", crearHoja("@elemento"),crearHoja(strAux)), 
		crearNodo("bloque",crearNodo("=", crearHoja("@pos"),crearHoja(strAuxPos)),
		crearNodo("bloque",
		crearNodo("if",crearNodo("<", crearHoja("@pos"),crearHoja("@indice")),
		crearNodo("bloque", crearNodo("CONCAT", crearHoja("@nuevoElemento"),crearNodo("-", crearHoja("@elemento"),crearHoja("@descuento"))), 
		crearNodo("CONCAT", crearHoja("@nuevoElemento"),crearNodo("-", crearHoja("@elemento"),
		crearNodo("*", crearHoja("@elemento"),crearNodo("/", crearHoja("@descuento"),crearHoja("_100"))))))),
		crearNodo("if",crearNodo("!=", crearHoja("@pos"),crearNodo("-", crearHoja("@cant_elementos"),crearHoja("_1"))),crearNodo("CONCAT", crearHoja("@nuevoElemento"),crearHoja("\",\""))
		)))

		))
	;

	indiceAux++;
};
	    insertarEnLista(&listaSimbolos, "@cant_elementos",  tID);
        asignarTipoDato(&listaSimbolos, "@cant_elementos", "Int");
	    insertarEnLista(&listaSimbolos, "@elemento",  tID);
        asignarTipoDato(&listaSimbolos, "@elemento", "Float");	
	    insertarEnLista(&listaSimbolos, "@pos",  tID);
        asignarTipoDato(&listaSimbolos, "@pos", "Int");	
	    insertarEnLista(&listaSimbolos, "@nuevoElemento",  tID);
        asignarTipoDato(&listaSimbolos, "@nuevoElemento", "String");	
	    insertarEnLista(&listaSimbolos, "\",\"",  tSTRING);		

//Descuentoptr = Auxcicloptr;
Descuentoptr = crearNodo("bloque",Auxcicloptr, crearNodo("Write", crearHoja("@nuevoElemento"),crearHoja("Literal")));

//Descuentoptr = crearNodo("=", crearHoja("funcion descuento"), crearHoja("lista resultados"));
printf("aplicarDescuento - OK\n"); };

parametro1: FLOAT { validarRango(yylval.string_val); 
							        strcpy(strAux, "_");
									strcat(strAux,yylval.string_val);						
									strcpy(auxTipo, TFLOAT);
Param1ptr= crearNodo("=", crearHoja("@descuento"), crearHoja(strAux)); 
	    insertarEnLista(&listaSimbolos, "@descuento",  tID);
        asignarTipoDato(&listaSimbolos, "@descuento", "Float");
printf("parametro 1 REAL monto descuento - OK\n"); } ; 


parametro2: INT { 
	strncpy(strAux6, yytext, MAX_BUFFER_SIZE - 1);
    strAux6[MAX_BUFFER_SIZE - 1] = '\0';
        snprintf(strAux, VALOR_LARGO_MAX, "_%d", $1);
        strcpy(auxTipo, TINT);
	Param2ptr= crearNodo("=", crearHoja("@indice"), crearHoja(strAux));
	
	    insertarEnLista(&listaSimbolos, "@indice",  tID);
        asignarTipoDato(&listaSimbolos, "@indice", "Int");
		
printf("parametro 2 ENTERA indice descuento- OK\n"); } ;

lista: numero 
{
	strncpy(strAux5, yytext, MAX_BUFFER_SIZE - 1);
    strAux5[MAX_BUFFER_SIZE - 1] = '\0';
	
}
	   | lista COMA {contador2++;}  numero { 
	   strncat(strAux5, ",", MAX_BUFFER_SIZE - strlen(strAux5) - 1);
        strncat(strAux5, yytext, MAX_BUFFER_SIZE - strlen(strAux5) - 1);	   
	   printf("aplicarDescuento Lista - OK\n"); };

numero:			INT { 
        snprintf(strAux, VALOR_LARGO_MAX, "_%d", $1);
        strcpy(auxTipo, TINT);
				encolar(&colaIds, strAux, STRING_LARGO_MAX + 1); 
				printf("Condicion ENTERA descuento- OK\n"); } 
				
				|FLOAT { 
				strcpy(strAux, "_");
				strcat(strAux,yylval.string_val);						
				strcpy(auxTipo, TFLOAT);				
				encolar(&colaIds, strAux, STRING_LARGO_MAX + 1); 
				printf("Condicion REAL descuento - OK\n"); } ; 

ciclo:			WHILE PAR_A condicion PAR_C LLAVE_A bloque LLAVE_C { 
																	desapilar(&condAnidados, &ConAux, sizeof(ConAux));
																	printf("\t\t: ciclo(Condicion) { bloque} es Ciclo\n"); CicPtr = crearNodo("ciclo", ConAux, BloPtr);
																};
       
asignacion:		ID OPAR_ASIG expresion
					{
						if(!idDeclarado(&listaSimbolos, $1)){ 
								printf("\nError, id: *%s* no fue declarado\n", $1);
								return 1;
							};
							if(!esMismoTipo(&listaSimbolos, $1, auxTipo)){ 
								printf("\nError, datos de diferente tipo para *%s*.\n", $1);
								return 1;
							}
							    AsigPtr = crearNodo("=", crearHoja($1), Eptr);
								maximo();
						
								contadorAuxiliares=0;
					}

				| ID OPAR_ASIG primos 
				{
						if(!idDeclarado(&listaSimbolos, $1)){ 
								printf("\nError, id: *%s* no fue declarado\n", $1);
								return 1;
							};
							if(!esMismoTipo(&listaSimbolos, $1, auxTipo)){ 
								printf("\nError, datos de diferente tipo para *%s*.\n", $1);
								return 1;
							}
							
							 //AsigPtr = crearNodo("=", crearHoja($1), crearHoja("@CANT"));
							 AsigPtr = crearNodo("bloque", Primosptr, crearNodo("=", crearHoja($1), crearHoja("@CANT")));
							 //AsigPtr = Primosptr;
							 
							maximo();
						
								contadorAuxiliares=0;
					};

primos:			ContarPrimos PAR_A COR_A expre  COR_C PAR_C {printf("\n Contar Primos\n"); Primosptr = Expreptr;

																		} ;

seleccion: 		SI  PAR_A condicion PAR_C LLAVE_A bloque LLAVE_C { printf("seleccion - OK\n"); 
																	desapilar(&condAnidados, &ConAux, sizeof(ConAux));
																	EvalPtr = crearNodo("if", ConAux, BloPtr);
} 
				| SI  PAR_A condicion PAR_C LLAVE_A bloque LLAVE_C { apilar(&anidaciones, &BloPtr, sizeof(BloPtr)); } SINO LLAVE_A bloque LLAVE_C 
					{
						        desapilar(&condAnidados, &ConAux, sizeof(ConAux));
								desapilar(&anidaciones, &BloAux, sizeof(BloAux));   
								EvalPtr = crearNodo("if", ConAux, crearNodo("Cuerpo", BloAux, BloPtr));
					};

condicion:		comparacion                         { printf("Comparacion - OK\n");  
															ConPtr = CmpPtr;
															apilar(&condAnidados, &ConPtr, sizeof(ConPtr));}
				|comparacion { CmpAux = CmpPtr; } OP_LOG_AND {strcpy(opAux,"AND");} comparacion { printf("Condicion OP_LOG_AND- OK\n"); 
																								ConPtr = crearNodo(opAux, CmpAux, CmpPtr);
																								apilar(&condAnidados, &ConPtr, sizeof(ConPtr));
				}
				|comparacion { CmpAux = CmpPtr; } OP_LOG_OR {strcpy(opAux,"OR");} comparacion	{ printf("Condicion OP_LOG_OR- OK\n"); 
																								ConPtr = crearNodo(opAux, CmpAux, CmpPtr);
																								apilar(&condAnidados, &ConPtr, sizeof(ConPtr));				
				}
				;

comparacion:	expresion { EptrAux = Eptr; } COMP_IGUAL {strcpy(cmpAux,"==");} expresion {
															CmpPtr = crearNodo(cmpAux, EptrAux, Eptr); 
															contadorAuxiliares = 0;	
}
				|expresion { EptrAux = Eptr; } COMP_MAYOR {strcpy(cmpAux,">");} expresion        {printf(" - Comparacion Mayor\n");
															CmpPtr = crearNodo(cmpAux, EptrAux, Eptr); 
															contadorAuxiliares = 0;					
				}	
				|expresion { EptrAux = Eptr; } COMP_MENOR {strcpy(cmpAux,"<");} expresion         {printf(" - Comparacion Menor\n");
															CmpPtr = crearNodo(cmpAux, EptrAux, Eptr); 
															contadorAuxiliares = 0;					
				}
				|expresion { EptrAux = Eptr; } COMP_MAYOR_IGUAL {strcpy(cmpAux,">=");} expresion   {printf(" - Comparacion Mayor Igual\n");
															CmpPtr = crearNodo(cmpAux, EptrAux, Eptr); 
															contadorAuxiliares = 0;					
				}
				|expresion { EptrAux = Eptr; } COMP_MENOR_IGUAL {strcpy(cmpAux,"<=");} expresion   {printf(" - Comparacion Menor Igual\n");
															CmpPtr = crearNodo(cmpAux, EptrAux, Eptr); 
															contadorAuxiliares = 0;					
				}
				|expresion { EptrAux = Eptr; } COMP_DISTINTO {strcpy(cmpAux,"!=");} expresion {
															CmpPtr = crearNodo(cmpAux, EptrAux, Eptr); 
															contadorAuxiliares = 0;						
				}
				|OP_LOG_NOT comparacion             { printf("Condicion OP_LOG_NOT- OK\n"); invertirCondicionNOT(CmpPtr);};
				

expre: expresion {printf("\n Contar Primos expresion\n"); Expreptr = 
																crearNodo("bloque", 
																	crearNodo("bloque", crearNodo("=",crearHoja("@auxExp"), Eptr),
																	crearNodo("bloque", crearNodo("=",crearHoja("@init"), crearHoja("_1")), 
																		crearNodo("bloque",crearNodo("=",crearHoja("@cont"), crearHoja("_0")),
																			crearNodo("ciclo", crearNodo("<",crearHoja("@init"), crearHoja("@auxExp") ),
																				crearNodo("Cuerpo",crearNodo("if",crearNodo("==",crearNodo("%", crearHoja("@auxExp"), crearHoja("@init")),crearHoja("_0")),crearNodo("=",crearHoja("@cont"),crearNodo("+",crearHoja("@cont"), crearHoja("_1"))   )
																				
																				),crearNodo("=",crearHoja("@init"),crearNodo("+",crearHoja("@init"), crearHoja("_1"))))))))
																				,crearNodo("if",crearNodo("==",crearHoja("@cont"), crearHoja("_2")), crearNodo("=",crearHoja("@CANT"),crearNodo("+",crearHoja("@CANT"), crearHoja("_1")))));
																
        insertarEnLista(&listaSimbolos, "@auxExp",  tID);
        asignarTipoDato(&listaSimbolos, "@auxExp", "Int");
	    insertarEnLista(&listaSimbolos, "@init",  tID);
        asignarTipoDato(&listaSimbolos, "@init", "Int");	
	    insertarEnLista(&listaSimbolos, "@cont",  tID);
        asignarTipoDato(&listaSimbolos, "@cont", "Int");	
	    insertarEnLista(&listaSimbolos, "@CANT",  tID);
        asignarTipoDato(&listaSimbolos, "@CANT", "Int");	
		insertarEnLista(&listaSimbolos, "0", tINT);
        insertarEnLista(&listaSimbolos, "1", tINT);
		insertarEnLista(&listaSimbolos, "2", tINT);
	    																			
																;}

															
	  |expre COMA expresion {printf("\n Contar Primos expresiones\n"); 
			Expreptr = crearNodo("bloque",Expreptr,
																crearNodo("bloque", 
																	crearNodo("bloque", crearNodo("=",crearHoja("@auxExp"), Eptr),
																	crearNodo("bloque", crearNodo("=",crearHoja("@init"), crearHoja("_1")), 
																		crearNodo("bloque",crearNodo("=",crearHoja("@cont"), crearHoja("_0")),
																			crearNodo("ciclo", crearNodo("<",crearHoja("@init"), crearHoja("@auxExp") ),
																				crearNodo("Cuerpo",crearNodo("if",crearNodo("==",crearNodo("%", crearHoja("@auxExp"), crearHoja("@init")),crearHoja("_0")),crearNodo("=",crearHoja("@cont"),crearNodo("+",crearHoja("@cont"), crearHoja("_1"))   )
																				
																				),crearNodo("=",crearHoja("@init"),crearNodo("+",crearHoja("@init"), crearHoja("_1"))))))))
																				,crearNodo("if",crearNodo("==",crearHoja("@cont"), crearHoja("_2")), crearNodo("=",crearHoja("@CANT"),crearNodo("+",crearHoja("@CANT"), crearHoja("_1"))))))
	  ;};

				
expresion:		expresion  { printf(" expresion"); } OP_MAS termino { printf(" termino"); Eptr = crearNodo("+", Eptr, Tptr); contadorAuxiliares++;}
				|expresion { printf(" expresion"); }OP_MENOS termino { printf(" termino"); Eptr = crearNodo("-", Eptr, Tptr); contadorAuxiliares++;}
				| OP_MENOS termino %prec MENOS_UNARIO { printf(" expresion menos_unario"); }
				|termino   { printf(" termino"); Eptr = Tptr; contadorAuxiliares++;};
									

termino:		termino OP_MULT factor { printf(" factor"); Tptr = crearNodo("*", Tptr, Fptr); contadorAuxiliares++;}
				|termino OP_DIV factor { printf(" factor"); Tptr = crearNodo("/", Tptr, Fptr); contadorAuxiliares++;}
				|factor { printf(" factor"); Tptr = Fptr;};
                         
factor:			ID { printf("Condicion ID - OK\n"); 
					if(!idDeclarado(&listaSimbolos, $1)){ 
						printf("\nError, id: *%s* no fue declarado\n", $1);
						return 1;
					}
					if(esMismoTipo(&listaSimbolos, $1, TSTRING)){ 
						printf("\nError: No es posible realizar operaciones aritmeticas sobre variables String.\n");
						return 1;
					}
					strcpy(auxTipo, obtenerTipo(&listaSimbolos, $1));
					Fptr= crearHoja($1); 
					} 
				|INT { printf("Condicion ENTERA - OK\n"); 
							        snprintf(strAux, VALOR_LARGO_MAX, "_%d", $1);
									strcpy(auxTipo, TINT);
									Fptr= crearHoja(strAux); 
						} 
				|FLOAT { printf("Condicion REAL - OK\n"); 
							        strcpy(strAux, "_");
									strcat(strAux,yylval.string_val);
							
									strcpy(auxTipo, TFLOAT);
									Fptr= crearHoja(strAux);
							} 
				|STRING { printf("Condicion STRING - OK\n"); 
							strcpy(auxTipo, TSTRING);
							Fptr = crearHoja($1);
							};
				
				 
entrada: 		READ PAR_A ID PAR_C {
				if(!idDeclarado(&listaSimbolos, $3)){ 
					printf("\nError, id: *%s* no fue declarado\n", $3);
					return 1;
						};
					strcpy(auxTipo, obtenerTipo(&listaSimbolos, $3));
					EntradaPtr = crearNodo("READ", crearHoja($3), crearHoja(auxTipo));
				}

salida:			 WRITE STRING 
			    |WRITE PAR_A ID PAR_C {
					if(!idDeclarado(&listaSimbolos, $3)){ 
						printf("\nError, id: *%s* no fue declarado\n", $3);
						return 1;
					};
					strcpy(auxTipo, obtenerTipo(&listaSimbolos, $3));
					SalidaPtr = crearNodo("Write", crearHoja($3), crearHoja(auxTipo));
				}
				|WRITE PAR_A STRING PAR_C {SalidaPtr = crearNodo("Write", crearHoja($3), crearHoja("Literal"));}
    
%%
 
int main(int argc,char *argv[])
{
    crearLista(&listaSimbolos);
    crearLista(&listaIds);
    crearPila(&anidaciones);
    crearPila(&condAnidados);
    crearCola(&colaIds);
	
  if ((yyin = fopen(argv[1], "rt")) == NULL)
  {
	printf("\nERROR! No se pudo abrir el archivo: %s\n", argv[1]);
  }
  else
  {
	yyparse();
  }
  fclose(yyin);
  
    imprimirLista(&listaSimbolos);
    
    vaciarLista(&listaSimbolos);
    vaciarLista(&listaIds);
    vaciarPila(&anidaciones);
    vaciarPila(&condAnidados);
    vaciarArbol(&compilado);
    vaciarCola(&colaIds);
	
  system ("Pause");
  return 0;
}

int yyerror() { 
    printf("Error sintactico\n");
    exit(1);
}

int validarRango(char* str) {
	
	float numero_cmp = atof(str);
    if ((numero_cmp < 0.0) || (numero_cmp > 100.0)) {
		printf("ERROR! El valor ingresado para el real se encuentra fuera del rango valido\n");
		exit(1);
        return 1;
	}

}

void obtenerNumeroPorIndice(const char* cadena, char* str) {
	
	int indice = atoi(str);
    // Copiamos la cadena para no modificar la original
    char cadenaCopia[strlen(cadena) + 1];
    strcpy(cadenaCopia, cadena);
    
    // Contamos los elementos y separamos los números
    char* token = strtok(cadenaCopia, ", ");
    int contador = 0;
    char numeros[100][50];

    while (token != NULL) {
        strcpy(numeros[contador], token);
        contador++;
        token = strtok(NULL, ", ");
    }

    // Verificamos si el índice está dentro del rango
    if (indice > contador) {
        printf("ERROR! El valor ingresado para el indice se encuentra fuera del rango valido\n");
		exit(1);
    } 
}

void maximo(){
    
    if(contadorAuxiliares > cantidadAuxiliares){
        cantidadAuxiliares = contadorAuxiliares;
    }
}

void invertirCondicionNOT(NodoA *padre)
{
    if (strcmp(padre->simbolo, "<") == 0)
    {
        strcpy(padre->simbolo, ">=");
    }
    else if (strcmp(padre->simbolo, ">") == 0)
    {
        strcpy(padre->simbolo, "<=");
    }
    else if (strcmp(padre->simbolo, "<=") == 0)
    {
        strcpy(padre->simbolo, ">");
    }
    else if (strcmp(padre->simbolo, ">=") == 0)
    {
        strcpy(padre->simbolo, "<");
    }
    else if (strcmp(padre->simbolo, "==") == 0)
    {
        strcpy(padre->simbolo, "!=");
    }
    else if (strcmp(padre->simbolo, "!=") == 0)
    {
        strcpy(padre->simbolo, "==");
    }
}