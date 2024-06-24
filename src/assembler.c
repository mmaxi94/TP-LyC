#include "../include/assembler.h"
#include "../include/pila.h"

int contOp = 1;
char auxAsm[STRING_LARGO_MAX + 1], auxAsmOp[STRING_LARGO_MAX + 1], auxAsmSimbolo[STRING_LARGO_MAX + 1];
char auxAsmTipo[STRING_LARGO_MAX + 1], auxAsmIf[ID_LARGO_MAX + 1];
char auxTipoAsm[STRING_LARGO_MAX + 1], auxTipoAsm2[STRING_LARGO_MAX + 1],auxValor[STRING_LARGO_MAX + 1];
int existeElse = 0; // si es 1 entonces tengo doble condicion
int contFalso = 0;  //
int contVerdadero = 0;
int contOr = 0;
int contCiclo = 0;
char etiquetaFalso[100]; // apilar etiquetas true y false
char etiquetaVerdadero[100];
char etiquetaOr[100];
char etiquetaCiclo[100];
char nro[100];
char auxStrConcat[50];
int operadorOr = 0;
Pila ifFalso, ifVerdadero, ifOr, cicloAnidados;
void generarCodigoComparador(FILE *arch, NodoA *padre, int nro, char *etiquetaFalso);
void sacarPunto(char* str);
void sacarMenosInt(char* str);
void incializarPilas()
{
    crearPila(&ifFalso);
    crearPila(&ifVerdadero);
    crearPila(&ifOr);
    crearPila(&cicloAnidados);
}

void generarAssembler(Lista *listaSimbolos, Arbol *arbol, int cantAuxiliares)
{
    FILE *arch = fopen("final.asm", "a");
    incializarPilas(ifFalso, ifVerdadero, ifOr, cicloAnidados);

    imprimirEncabezado(listaSimbolos, cantAuxiliares);

    generarCodigo(arch, listaSimbolos, arbol);

    imprimirFin(arch);

    fclose(arch);
}

void generarCodigo(FILE *arch, Lista *listaSimbolos, Arbol *arbol)
{
    NodoA *padre = padreMasIzq(arbol);
    NodoA *condicion;
    NodoA *bloque;

    while (padre != NULL)
    {
   
        if (strcmp(padre->simbolo, "bloque") == 0)
        {
            generarCodigo(arch, listaSimbolos, &padre->der);
        }
        if (strcmp(padre->simbolo, "decAsigM") == 0){
          
            generarCodigo(arch, listaSimbolos, &padre->der);
        }
        if (strcmp(padre->simbolo, "concatenarConRecorte") == 0){
           
            fprintf(arch, "mov bx, %s\n", padre->izq->izq->simbolo);

            strncpy(auxValor, padre->izq->der->simbolo + 1, strlen(padre->izq->der->simbolo) - 2); // substring del simbolo sin las ""
            auxValor[strlen(padre->izq->der->simbolo) - 2] = '\0';
            fprintf(arch, "mov si, OFFSET %s\n", obtenerNombre(listaSimbolos, auxValor, TSTRING));

            strncpy(auxValor, padre->der->simbolo + 1, strlen(padre->der->simbolo) - 2); // substring del simbolo sin las ""
            auxValor[strlen(padre->der->simbolo) - 2] = '\0';
            fprintf(arch, "mov di, OFFSET %s\n", obtenerNombre(listaSimbolos, auxValor, TSTRING));


            fprintf(arch, "CONCATENARCONRECORTE\n");
            strcpy(padre->simbolo, padre->izq->der->simbolo);
        }
		
		if (strcmp(padre->simbolo, "concat") == 0){
          
			if (strcmp(padre->izq->simbolo, "print") != 0)
			{
				strcpy(auxStrConcat,padre->izq->simbolo);
			
			if(auxStrConcat[0] == '@')
				{
				    fprintf(arch, "lea bx, %s\n",padre->izq->simbolo);
					fprintf(arch, "mov cx, 1\n");   
					fprintf(arch, "call ftoa\n");
					   
				}
			else{
			
				obtenerSinComillas(auxValor, padre->izq->simbolo);
				
				fprintf(arch, "displayString %s\n", obtenerNombre(listaSimbolos, auxValor, TSTRINGCTE));
				}
			}
			
			if (strcmp(padre->der->simbolo, "concat") != 0)
			{
				strcpy(auxStrConcat,padre->der->simbolo);
				
				if(auxStrConcat[0] == '@')
				{
				    fprintf(arch, "lea bx, %s\n",padre->der->simbolo);
					fprintf(arch, "mov cx, 1\n");   
					fprintf(arch, "call ftoa\n");
					   
				}

			}
			
			
			generarCodigo(arch, listaSimbolos, &padre->der);
        }

        if (strcmp(padre->simbolo, "=") == 0)
        {

            strcpy(auxTipoAsm, obtenerTipo(listaSimbolos, padre->izq->simbolo));
        
            generarCodigo(arch, listaSimbolos, &padre->der);
         
            if ((strcmp(auxTipoAsm, "CTE_STRING") == 0) || (strcmp(auxTipoAsm, "String") == 0))
            {
                strncpy(auxValor, padre->der->simbolo + 1, strlen(padre->der->simbolo) - 2); // substring del simbolo sin las ""
                auxValor[strlen(padre->der->simbolo) - 2] = '\0';
                fprintf(arch, "mov si, OFFSET %s\nmov di, OFFSET %s\nSTRCPY\n",obtenerNombre(listaSimbolos, auxValor, TSTRINGCTE), padre->izq->simbolo );
               
            }
            else if ((strcmp(auxTipoAsm, "CTE_FLOAT") == 0) || (strcmp(auxTipoAsm, "Float") == 0))
            {
                sacarPunto(padre->der->simbolo);
                fprintf(arch, "FLD %s\n", padre->der->simbolo);
               
                fprintf(arch, "FSTP %s\n", padre->izq->simbolo);
            }
            else if ((strcmp(auxTipoAsm, "CTE_INTEGER") == 0) || (strcmp(auxTipoAsm, "Int") == 0))
            {   
                fprintf(arch, "FLD %s\n", padre->der->simbolo);
                fprintf(arch, "FRNDINT\n");
                
                fprintf(arch, "FSTP %s\n", padre->izq->simbolo);
            }
            // TODO: si es String usar _2_+_42, posiblemente buscar en TS

            contOp = 1;
        }
        if (esOperacionAritmetica(padre->simbolo) == 1)
        {

            // generarCodigo(arch, listaSimbolos, &padre->izq);
            generarCodigo(arch, listaSimbolos, &padre->der);
            //si existe un menos, cambio simbolo - por _menos_
            sacarMenosInt(padre->der->simbolo);
            sacarMenosInt(padre->izq->simbolo);
            sacarPunto(padre->der->simbolo);
            sacarPunto(padre->izq->simbolo);


            if (strcmp(padre->simbolo, "+") == 0)
            {

                fprintf(arch, "FLD %s\n", padre->izq->simbolo);
                fprintf(arch, "FLD %s\n", padre->der->simbolo);
                fprintf(arch, "FADD\n");
                if (strcmp(padre->izq->simbolo, "@_contI") == 0)
                {
                    fprintf(arch, "FSTP @_contI\n");
                }
                else
                {
                    fprintf(arch, "FSTP @aux%d\n", contOp);

                    strcpy(auxAsm, "@aux");
                    snprintf(auxAsmOp, STRING_LARGO_MAX + 1, "%d", contOp);
                    strcat(auxAsm, auxAsmOp);

                    strcpy(padre->simbolo, auxAsm);
                }
            }
            else if (strcmp(padre->simbolo, "-") == 0)
            {
                fprintf(arch, "FLD %s\n", padre->izq->simbolo);
                fprintf(arch, "FLD %s\n", padre->der->simbolo);
                fprintf(arch, "FSUB\n");

                fprintf(arch, "FSTP @aux%d\n", contOp);

                strcpy(auxAsm, "@aux");
                snprintf(auxAsmOp, STRING_LARGO_MAX + 1, "%d", contOp);
                strcat(auxAsm, auxAsmOp);

                strcpy(padre->simbolo, auxAsm);
            }
			else if (strcmp(padre->simbolo, "%") == 0)
            {
                fprintf(arch, "FLD %s\n", padre->izq->simbolo);
                fprintf(arch, "FLD %s\n", padre->der->simbolo);
				fprintf(arch, "fxch\n");
                fprintf(arch, "FPREM\n");

                fprintf(arch, "FSTP @aux%d\n", contOp);

                strcpy(auxAsm, "@aux");
                snprintf(auxAsmOp, STRING_LARGO_MAX + 1, "%d", contOp);
                strcat(auxAsm, auxAsmOp);

                strcpy(padre->simbolo, auxAsm);
            }
            else if (strcmp(padre->simbolo, "*") == 0)
            {
              
                fprintf(arch, "FLD %s\n", padre->izq->simbolo);
                fprintf(arch, "FLD %s\n", padre->der->simbolo);
                fprintf(arch, "FMUL\n");

                fprintf(arch, "FSTP @aux%d\n", contOp);

                strcpy(auxAsm, "@aux");
                snprintf(auxAsmOp, STRING_LARGO_MAX + 1, "%d", contOp);
                strcat(auxAsm, auxAsmOp);

                strcpy(padre->simbolo, auxAsm);
            }
            else if (strcmp(padre->simbolo, "/") == 0)
            {
                fprintf(arch, "FLD %s\n", padre->izq->simbolo);
                fprintf(arch, "FLD %s\n", padre->der->simbolo);
                fprintf(arch, "FDIV\n");

                fprintf(arch, "FSTP @aux%d\n", contOp);

                strcpy(auxAsm, "@aux");
                snprintf(auxAsmOp, STRING_LARGO_MAX + 1, "%d", contOp);
                strcat(auxAsm, auxAsmOp);

                strcpy(padre->simbolo, auxAsm);
            }

            contOp++;
        }

        if (strcmp(padre->simbolo, "Write") == 0)
        {

            if ((strcmp(padre->der->simbolo, "CTE_INTEGER") == 0) || (strcmp(padre->der->simbolo, "Int") == 0))
            {
                fprintf(arch, "DisplayFloat %s , 1\n", padre->izq->simbolo);
            }
            else if ((strcmp(padre->der->simbolo, "CTE_FLOAT") == 0) || (strcmp(padre->der->simbolo, "Float") == 0))
            {
                fprintf(arch, "DisplayFloat %s , 2\n", padre->izq->simbolo);
            }
            else if ((strcmp(padre->der->simbolo, "CTE_STRING") == 0) || (strcmp(padre->der->simbolo, "String") == 0))
            {
                fprintf(arch, "displayString %s\n", padre->izq->simbolo);
            }
            else
            { // este caso imprimo un string literal
                obtenerSinComillas(auxValor, padre->izq->simbolo);
                fprintf(arch, "displayString %s\n", obtenerNombre(listaSimbolos, auxValor, TSTRINGCTE));
            }
            fprintf(arch, "newLine 1\n");
        }

        if (strcmp(padre->simbolo, "READ") == 0)
        {
            if ((strcmp(padre->der->simbolo, "CTE_INTEGER") == 0) || (strcmp(padre->der->simbolo, "Int") == 0))
            {
                fprintf(arch, "getFloat %s\n", padre->izq->simbolo);
            }
            else if ((strcmp(padre->der->simbolo, "CTE_FLOAT") == 0) || (strcmp(padre->der->simbolo, "Float") == 0))
            {
                fprintf(arch, "getFloat %s\n", padre->izq->simbolo);
            }
            else if ((strcmp(padre->der->simbolo, "CTE_STRING") == 0) || (strcmp(padre->der->simbolo, "String") == 0))
            {
                fprintf(arch, "getString %s\n", padre->izq->simbolo);
            }
        }

        if (strcmp(padre->simbolo, "estaContenido") == 0){

            strncpy(auxValor, padre->izq->simbolo + 1, strlen(padre->izq->simbolo) - 2); // substring del simbolo sin las ""
            auxValor[strlen(padre->izq->simbolo) - 2] = '\0';
            fprintf(arch, "mov si, OFFSET %s\n", obtenerNombre(listaSimbolos, auxValor, TSTRING));

            strncpy(auxValor, padre->der->simbolo + 1, strlen(padre->der->simbolo) - 2); // substring del simbolo sin las ""
            auxValor[strlen(padre->der->simbolo) - 2] = '\0';
            fprintf(arch, "mov di, OFFSET %s\n", obtenerNombre(listaSimbolos, auxValor, TSTRING));

            fprintf(arch, "ESTACONTENIDO\n");
        }
        
        
        
        if (strcmp(padre->simbolo, "if") == 0)
        {
            
            if (strcmp(padre->der->simbolo, "Cuerpo") == 0)
            {
                existeElse = 1;
                
            }

            if (esComparador(padre->izq->simbolo) == 1)
            { // condicion simple
                strcpy(etiquetaFalso, "falso");
               
                generarCodigoComparador(arch, padre->izq, contFalso, etiquetaFalso);
                contFalso++;

                apilar(&ifFalso, etiquetaFalso, sizeof(etiquetaFalso));
            }
            else if (esOperadorLogico(padre->izq->simbolo) == 1)
            { // condicion multiple
                NodoA *opLogico = padre->izq;

                if (strcmp(padre->izq->simbolo, "AND") == 0)
                {
                    strcpy(etiquetaFalso, "falso");
                    generarCodigoComparador(arch, opLogico->izq, contFalso, etiquetaFalso);
                    // 2da condicion
                    strcpy(etiquetaFalso, "falso");
                    generarCodigoComparador(arch, opLogico->der, contFalso, etiquetaFalso);

                    contFalso++;

                    apilar(&ifFalso, etiquetaFalso, sizeof(etiquetaFalso));
                }
                else if (strcmp(padre->izq->simbolo, "OR") == 0)
                {
                    invertirCondicion(opLogico->izq);

                    strcpy(etiquetaVerdadero, "verdadero");
                    generarCodigoComparador(arch, opLogico->izq, contVerdadero, etiquetaVerdadero);
                   
                    apilar(&ifVerdadero, etiquetaVerdadero, sizeof(etiquetaVerdadero));
                    contVerdadero++;

                    // 2da condicion ///ETIQUETA OR

                    strcpy(etiquetaOr, "etiquetaOr");
                    generarCodigoComparador(arch, opLogico->der, contOr, etiquetaOr);
                    contOr++;
                    if(existeElse == 1){
                        desapilar(&ifVerdadero, etiquetaVerdadero, sizeof(etiquetaVerdadero));
                    
                        fprintf(arch, "%s:\n", etiquetaVerdadero);
                        existeElse = 0;
                    }
                    
                    apilar(&ifOr, etiquetaOr, sizeof(etiquetaOr));
                    operadorOr = 1;
                }
            }

            if (strcmp(padre->der->simbolo, "Cuerpo") == 0)
            { // if con else

                if (operadorOr == 1)
                {                                                         // si op logico es OR ||
                    generarCodigo(arch, listaSimbolos, &padre->der->izq); // true
                    strcpy(etiquetaVerdadero, "verdadero");
                    snprintf(nro, STRING_LARGO_MAX + 1, "%d", contVerdadero);
                    strcat(etiquetaVerdadero, nro);

                    contVerdadero++;
                    apilar(&ifVerdadero, etiquetaVerdadero, sizeof(etiquetaVerdadero));
                    fprintf(arch, "JMP %s\n", etiquetaVerdadero);

                    desapilar(&ifOr, etiquetaOr, sizeof(etiquetaOr));
                    fprintf(arch, "%s:\n", etiquetaOr);

                    generarCodigo(arch, listaSimbolos, &padre->der->der); // false
                    desapilar(&ifVerdadero, etiquetaVerdadero, sizeof(etiquetaVerdadero));
                    fprintf(arch, "%s:\n", etiquetaVerdadero);

                    operadorOr = 0;
                }
                else
                { // cualquier otro caso

                    generarCodigo(arch, listaSimbolos, &padre->der->izq); // true
                    strcpy(etiquetaVerdadero, "verdadero");
                    snprintf(nro, STRING_LARGO_MAX + 1, "%d", contVerdadero);
                    strcat(etiquetaVerdadero, nro);

                    contVerdadero++;
                    apilar(&ifVerdadero, etiquetaVerdadero, sizeof(etiquetaVerdadero));
                    fprintf(arch, "JMP %s\n", etiquetaVerdadero);

                    desapilar(&ifFalso, etiquetaFalso, sizeof(etiquetaFalso));
                    fprintf(arch, "%s:\n", etiquetaFalso);
                    generarCodigo(arch, listaSimbolos, &padre->der->der); // false
                    desapilar(&ifVerdadero, etiquetaVerdadero, sizeof(etiquetaVerdadero));
                    fprintf(arch, "%s:\n", etiquetaVerdadero);
                }
            }
            else
            { // if sin else
                if (operadorOr == 1)
                {
                    //  TODO: cambiar etiqueta a verdadero
                    desapilar(&ifFalso, etiquetaVerdadero, sizeof(etiquetaVerdadero));
                    fprintf(arch, "%s:\n", etiquetaVerdadero);
                    generarCodigo(arch, listaSimbolos, &padre->der);

                    desapilar(&ifOr, etiquetaOr, sizeof(etiquetaOr));
                    fprintf(arch, "%s:\n", etiquetaOr);

                    operadorOr = 0;
                }
                else
                {
                    generarCodigo(arch, listaSimbolos, &padre->der);
                    desapilar(&ifFalso, etiquetaFalso, sizeof(etiquetaFalso));
                    fprintf(arch, "%s:\n", etiquetaFalso);
                }
            }
        }

        if (strcmp(padre->simbolo, "ciclo") == 0)
        {
            strcpy(etiquetaCiclo, "etiquetaCiclo");
            snprintf(nro, STRING_LARGO_MAX + 1, "%d", contCiclo);
            strcat(etiquetaCiclo, nro);
            fprintf(arch, "%s:\n", etiquetaCiclo);
            apilar(&cicloAnidados, etiquetaCiclo, sizeof(etiquetaCiclo));
            contCiclo++;

            if (esComparador(padre->izq->simbolo) == 1)
            { // condicion simple
                NodoA *comparador = padre->izq;

                strcpy(etiquetaFalso, "falso");
                generarCodigoComparador(arch, comparador, contFalso, etiquetaFalso);
                contFalso++;

                apilar(&ifFalso, etiquetaFalso, sizeof(etiquetaFalso));
            }
            else if (esOperadorLogico(padre->izq->simbolo) == 1)
            { // condicion multiple
                NodoA *opLogico = padre->izq;

                if (strcmp(opLogico->simbolo, "AND") == 0)
                {
                    strcpy(etiquetaFalso, "falso");
                    generarCodigoComparador(arch, opLogico->izq, contFalso, etiquetaFalso);
                    
                    // 2da condicion

                    strcpy(etiquetaFalso, "falso");
                    generarCodigoComparador(arch, opLogico->der, contFalso, etiquetaFalso);
                    

                    apilar(&ifFalso, etiquetaFalso, sizeof(etiquetaFalso));
                    contFalso++;

                    
                }
                else if (strcmp(opLogico->simbolo, "OR") == 0)
                {

                    invertirCondicion(opLogico->izq);

                    strcpy(etiquetaVerdadero, "verdadero");
                    generarCodigoComparador(arch, opLogico->izq, contVerdadero, etiquetaVerdadero);
                    contVerdadero++;

                    // 2da condicion
                    strcpy(etiquetaFalso, "falso");
                    generarCodigoComparador(arch, opLogico->der, contFalso, etiquetaFalso);
                    contFalso++;

                    apilar(&ifFalso, etiquetaFalso, sizeof(etiquetaFalso));
                    fprintf(arch, "%s:\n", etiquetaVerdadero);
                }
            }
            generarCodigo(arch, listaSimbolos, &padre->der);

            desapilar(&cicloAnidados, etiquetaCiclo, sizeof(etiquetaCiclo));
            fprintf(arch, "JMP %s\n", etiquetaCiclo);

            desapilar(&ifFalso, etiquetaFalso, sizeof(etiquetaFalso));
            fprintf(arch, "%s:\n", etiquetaFalso);
        }

        borrarHijos(padre);
        padre = padreMasIzq(arbol);
    }
}

void generarCodigoComparador(FILE *arch, NodoA *comparacion, int cont, char *etiqueta)
{

    if(strcmp(comparacion->simbolo, "estaContenido") == 0){
        snprintf(nro, STRING_LARGO_MAX + 1, "%d", cont);
        strcat(etiqueta, nro);
        fprintf(arch, "mov _temp, ebx\n");
        fprintf(arch, "fild _temp\n");
        fprintf(arch, "frndint\n");
        fprintf(arch, "fstp _temp\n");
        fprintf(arch, "fld _1\n");
       
        fprintf(arch, "fcomp _temp\n");
        fprintf(arch, "fstsw ax\n"); // los flags del coprocesador en memoria
        fprintf(arch, "sahf\n");     // guardo los flags que estan en memoria en el registro FLAG del cpu
        fprintf(arch, "JNE %s\n", etiqueta);
        return;
    }
    fprintf(arch, "fld %s\n", comparacion->izq->simbolo);
    fprintf(arch, "fcomp %s\n", comparacion->der->simbolo);

    fprintf(arch, "fstsw ax\n"); // los flags del coprocesador en memoria
    fprintf(arch, "sahf\n");     // guardo los flags que estan en memoria en el registro FLAG del cpu

    if (strcmp(comparacion->simbolo, "<") == 0)
    {
        snprintf(nro, STRING_LARGO_MAX + 1, "%d", cont);
        strcat(etiqueta, nro);
        fprintf(arch, "JNB %s\n", etiqueta); // ini
    }
    else if (strcmp(comparacion->simbolo, ">") == 0)
    {
        snprintf(nro, STRING_LARGO_MAX + 1, "%d", cont);
        strcat(etiqueta, nro);
        fprintf(arch, "JBE %s\n", etiqueta);
    }
    else if (strcmp(comparacion->simbolo, "<=") == 0)
    {
        snprintf(nro, STRING_LARGO_MAX + 1, "%d", cont);
        strcat(etiqueta, nro);
        fprintf(arch, "JNBE %s\n", etiqueta);
    }
    else if (strcmp(comparacion->simbolo, ">=") == 0)
    {
        snprintf(nro, STRING_LARGO_MAX + 1, "%d", cont);
        strcat(etiqueta, nro);
        fprintf(arch, "JNAE %s\n", etiqueta);
    }
    else if (strcmp(comparacion->simbolo, "!=") == 0)
    {
        snprintf(nro, STRING_LARGO_MAX + 1, "%d", cont);
        strcat(etiqueta, nro);
        fprintf(arch, "JE %s\n", etiqueta);
    }
    else if (strcmp(comparacion->simbolo, "==") == 0)
    {
        snprintf(nro, STRING_LARGO_MAX + 1, "%d", cont);
        strcat(etiqueta, nro);
        fprintf(arch, "JNE %s\n", etiqueta);
    } 
}
void imprimirFin(FILE *arch)
{
    fprintf(arch, "\nMOV AX, 4C00H\n");
    fprintf(arch, "INT 21h\n");
    fprintf(arch, "END START");
}

void invertirCondicion(NodoA *padre)
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
int esComparador(char *op)
{
    if (strcmp(op, "<") == 0 ||
        strcmp(op, "<=") == 0 ||
        strcmp(op, ">") == 0 ||
        strcmp(op, ">=") == 0 ||
        strcmp(op, "==") == 0 ||
        strcmp(op, "!=") == 0 ||
        strcmp(op, "estaContenido") == 0)
        return 1;

    return 0;
}
int esOperacionAritmetica(char *op)
{
    if (strcmp(op, "+") == 0 ||
        strcmp(op, "-") == 0 ||
        strcmp(op, "*") == 0 ||
        strcmp(op, "/") == 0 ||
		strcmp(op, "%") == 0 
		)
        return 1;

    return 0;
}
int esOperadorLogico(char *op)
{
    if (strcmp(op, "AND") == 0 ||
        strcmp(op, "OR") == 0)
        return 1;

    return 0;
}

void sacarPunto(char *str) {
    for(int i = 0; str[i]; i++){
        if(str[i] == '.')
            str[i] = '_';
    }
}


void sacarMenosInt(char* str){
    char aux[STRING_LARGO_MAX + 1];
    int menos = 0;
    int j = 0;
    for(int i = 0; str[i]; i++){
        
        if(str[i] == '-'){
            menos = 1;
            aux[i] = '_';
            aux[i+1] = 'm';
            aux[i+2] = 'e';
            aux[i+3] = 'n';
            aux[i+4] = 'o';
            aux[i+5] = 's';
            aux[i+6] = '_';

            i++;
            j+=7;
        }
        aux[j] = str[i];
        j++;
    }
    aux[j] = '\0';
    if(menos == 1){
        strcpy(str, aux);
    }

}