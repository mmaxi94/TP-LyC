include ./asm/number.asm
include ./asm/macros.asm
.MODEL LARGE
.386
.STACK 200h
.DATA
z dd ?
x dd ?
variable1 dd ?
p3 dd ?
p2 dd ?
p1 dd ?
base dd ?
b dd ?
a dd ?
_s_ejecutando_contarprimos db "ejecutando contarprimos" , '$', 23 dup (?)
_s_ejecutando_aplicarDescuento db "ejecutando aplicarDescuento" , '$', 27 dup (?)
_s__coma_ db "," , '$', 1 dup (?)
_8 dd 8.00
_79_4 dd 79.4
_7 dd 7.00
_55 dd 55.00
_53 dd 53.00
_500 dd 500.00
_4 dd 4.00
_305 dd 305.00
_3 dd 3.00
_27_5 dd 27.5
_2 dd 2.00
_11 dd 11.00
_100 dd 100.00
_10 dd 10.00
_1 dd 1.00
_0 dd 0.00
C dd ?
@pos dd ?
@nuevoElemento_4 dd ?
@nuevoElemento_3 dd ?
@nuevoElemento_2 dd ?
@nuevoElemento_1 dd ?
@init dd ?
@indice dd ?
@elemento dd ?
@descuento dd ?
@cont dd ?
@cant_elementos dd ?
@auxExp dd ?
@CANT dd ?
@aux1 dd ?
@aux2 dd ?
@aux3 dd ?
@aux4 dd ?
@aux5 dd ?
@aux6 dd ?
@aux7 dd ?
@aux8 dd ?
@aux9 dd ?
@aux10 dd ?
@aux11 dd ?
@aux12 dd ?
@aux13 dd ?
@aux14 dd ?
@aux15 dd ?
@aux16 dd ?
@aux17 dd ?
@aux18 dd ?
@aux19 dd ?
@aux20 dd ?
@aux21 dd ?
@aux22 dd ?
.CODE
START:
mov AX, @DATA
mov DS, AX
mov es, ax

FLD _0
FRNDINT
FSTP z
FLD _0
FRNDINT
FSTP x
FLD _2
FRNDINT
FSTP a
FLD _2
FRNDINT
FSTP b
FLD _2
FRNDINT
FSTP C
displayString _s_ejecutando_contarprimos
newLine 1
FLD _11
FRNDINT
FSTP @auxExp
FLD _0
FRNDINT
FSTP @CANT
FLD _1
FRNDINT
FSTP @init
FLD _0
FRNDINT
FSTP @cont
etiquetaCiclo0:
fld @init
fcomp @auxExp
fstsw ax
sahf
JNBE falso0
FLD @auxExp
FLD @init
fxch
FPREM
FSTP @aux1
fld @aux1
fcomp _0
fstsw ax
sahf
JNE falso1
FLD @cont
FLD _1
FADD
FSTP @aux2
FLD @aux2
FRNDINT
FSTP @cont
falso1:
FLD @init
FLD _1
FADD
FSTP @aux1
FLD @aux1
FRNDINT
FSTP @init
JMP etiquetaCiclo0
falso0:
fld @cont
fcomp _2
fstsw ax
sahf
JNE falso2
FLD @CANT
FLD _1
FADD
FSTP @aux1
FLD @aux1
FRNDINT
FSTP @CANT
falso2:
FLD b
FLD _8
FADD
FSTP @aux1
FLD @aux1
FRNDINT
FSTP @auxExp
FLD _1
FRNDINT
FSTP @init
FLD _0
FRNDINT
FSTP @cont
etiquetaCiclo1:
fld @init
fcomp @auxExp
fstsw ax
sahf
JNBE falso3
FLD @auxExp
FLD @init
fxch
FPREM
FSTP @aux1
fld @aux1
fcomp _0
fstsw ax
sahf
JNE falso4
FLD @cont
FLD _1
FADD
FSTP @aux2
FLD @aux2
FRNDINT
FSTP @cont
falso4:
FLD @init
FLD _1
FADD
FSTP @aux1
FLD @aux1
FRNDINT
FSTP @init
JMP etiquetaCiclo1
falso3:
fld @cont
fcomp _2
fstsw ax
sahf
JNE falso5
FLD @CANT
FLD _1
FADD
FSTP @aux1
FLD @aux1
FRNDINT
FSTP @CANT
falso5:
FLD _2
FRNDINT
FSTP @auxExp
FLD _1
FRNDINT
FSTP @init
FLD _0
FRNDINT
FSTP @cont
etiquetaCiclo2:
fld @init
fcomp @auxExp
fstsw ax
sahf
JNBE falso6
FLD @auxExp
FLD @init
fxch
FPREM
FSTP @aux1
fld @aux1
fcomp _0
fstsw ax
sahf
JNE falso7
FLD @cont
FLD _1
FADD
FSTP @aux2
FLD @aux2
FRNDINT
FSTP @cont
falso7:
FLD @init
FLD _1
FADD
FSTP @aux1
FLD @aux1
FRNDINT
FSTP @init
JMP etiquetaCiclo2
falso6:
fld @cont
fcomp _2
fstsw ax
sahf
JNE falso8
FLD @CANT
FLD _1
FADD
FSTP @aux1
FLD @aux1
FRNDINT
FSTP @CANT
falso8:
FLD _55
FRNDINT
FSTP @auxExp
FLD _1
FRNDINT
FSTP @init
FLD _0
FRNDINT
FSTP @cont
etiquetaCiclo3:
fld @init
fcomp @auxExp
fstsw ax
sahf
JNBE falso9
FLD @auxExp
FLD @init
fxch
FPREM
FSTP @aux1
fld @aux1
fcomp _0
fstsw ax
sahf
JNE falso10
FLD @cont
FLD _1
FADD
FSTP @aux2
FLD @aux2
FRNDINT
FSTP @cont
falso10:
FLD @init
FLD _1
FADD
FSTP @aux1
FLD @aux1
FRNDINT
FSTP @init
JMP etiquetaCiclo3
falso9:
fld @cont
fcomp _2
fstsw ax
sahf
JNE falso11
FLD @CANT
FLD _1
FADD
FSTP @aux1
FLD @aux1
FRNDINT
FSTP @CANT
falso11:
FLD z
FLD b
FMUL
FSTP @aux1
FLD @aux1
FLD _7
FADD
FSTP @aux2
FLD @aux2
FRNDINT
FSTP @auxExp
FLD _1
FRNDINT
FSTP @init
FLD _0
FRNDINT
FSTP @cont
etiquetaCiclo4:
fld @init
fcomp @auxExp
fstsw ax
sahf
JNBE falso12
FLD @auxExp
FLD @init
fxch
FPREM
FSTP @aux1
fld @aux1
fcomp _0
fstsw ax
sahf
JNE falso13
FLD @cont
FLD _1
FADD
FSTP @aux2
FLD @aux2
FRNDINT
FSTP @cont
falso13:
FLD @init
FLD _1
FADD
FSTP @aux1
FLD @aux1
FRNDINT
FSTP @init
JMP etiquetaCiclo4
falso12:
fld @cont
fcomp _2
fstsw ax
sahf
JNE falso14
FLD @CANT
FLD _1
FADD
FSTP @aux1
FLD @aux1
FRNDINT
FSTP @CANT
falso14:
FLD C
FRNDINT
FSTP @auxExp
FLD _1
FRNDINT
FSTP @init
FLD _0
FRNDINT
FSTP @cont
etiquetaCiclo5:
fld @init
fcomp @auxExp
fstsw ax
sahf
JNBE falso15
FLD @auxExp
FLD @init
fxch
FPREM
FSTP @aux1
fld @aux1
fcomp _0
fstsw ax
sahf
JNE falso16
FLD @cont
FLD _1
FADD
FSTP @aux2
FLD @aux2
FRNDINT
FSTP @cont
falso16:
FLD @init
FLD _1
FADD
FSTP @aux1
FLD @aux1
FRNDINT
FSTP @init
JMP etiquetaCiclo5
falso15:
fld @cont
fcomp _2
fstsw ax
sahf
JNE falso17
FLD @CANT
FLD _1
FADD
FSTP @aux1
FLD @aux1
FRNDINT
FSTP @CANT
falso17:
FLD @CANT
FRNDINT
FSTP x
DisplayFloat x , 1
newLine 1
displayString _s_ejecutando_aplicarDescuento
newLine 1
FLD _27_5
FSTP @descuento
FLD _3
FRNDINT
FSTP @indice
FLD _4
FRNDINT
FSTP @cant_elementos
FLD _500
FSTP @elemento
FLD _1
FRNDINT
FSTP @pos
fld @pos
fcomp @indice
fstsw ax
sahf
JNB falso18
FLD @elemento
FLD @descuento
FSUB
FSTP @aux1
FLD @aux1
FSTP @nuevoElemento_1
JMP verdadero0
falso18:
FLD @descuento
FLD _100
FDIV
FSTP @aux1
FLD @elemento
FLD @aux1
FMUL
FSTP @aux2
FLD @elemento
FLD @aux2
FSUB
FSTP @aux3
FLD @aux3
FSTP @nuevoElemento_1
verdadero0:
FLD _305
FSTP @elemento
FLD _2
FRNDINT
FSTP @pos
fld @pos
fcomp @indice
fstsw ax
sahf
JNB falso19
FLD @elemento
FLD @descuento
FSUB
FSTP @aux1
FLD @aux1
FSTP @nuevoElemento_2
JMP verdadero1
falso19:
FLD @descuento
FLD _100
FDIV
FSTP @aux1
FLD @elemento
FLD @aux1
FMUL
FSTP @aux2
FLD @elemento
FLD @aux2
FSUB
FSTP @aux3
FLD @aux3
FSTP @nuevoElemento_2
verdadero1:
FLD _79_4
FSTP @elemento
FLD _3
FRNDINT
FSTP @pos
fld @pos
fcomp @indice
fstsw ax
sahf
JNB falso20
FLD @elemento
FLD @descuento
FSUB
FSTP @aux1
FLD @aux1
FSTP @nuevoElemento_3
JMP verdadero2
falso20:
FLD @descuento
FLD _100
FDIV
FSTP @aux1
FLD @elemento
FLD @aux1
FMUL
FSTP @aux2
FLD @elemento
FLD @aux2
FSUB
FSTP @aux3
FLD @aux3
FSTP @nuevoElemento_3
verdadero2:
FLD _10
FSTP @elemento
FLD _4
FRNDINT
FSTP @pos
fld @pos
fcomp @indice
fstsw ax
sahf
JNB falso21
FLD @elemento
FLD @descuento
FSUB
FSTP @aux1
FLD @aux1
FSTP @nuevoElemento_4
JMP verdadero3
falso21:
FLD @descuento
FLD _100
FDIV
FSTP @aux1
FLD @elemento
FLD @aux1
FMUL
FSTP @aux2
FLD @elemento
FLD @aux2
FSUB
FSTP @aux3
FLD @aux3
FSTP @nuevoElemento_4
verdadero3:
lea bx, @nuevoElemento_1
mov cx, 1
call ftoa
displayString _s__coma_
lea bx, @nuevoElemento_2
mov cx, 1
call ftoa
displayString _s__coma_
lea bx, @nuevoElemento_3
mov cx, 1
call ftoa
displayString _s__coma_
lea bx, @nuevoElemento_4
mov cx, 1
call ftoa

MOV AX, 4C00H
INT 21h
END START