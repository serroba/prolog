/*Inicio del juego, con menu de explicacion*/

comenzar:- nl, write('Juego del Gato'), explicacionJuego, !, nl, juegos, nl, nl.

/*Explicacion de las movidas posibles del juego*/

explicacionJuego:-nl, write('Selecciona una posicion de acuerdo a los numeros mostrados'),
	nl, write('posicion donde deseas mover:'), nl, nl,
	write(' 1 | 2 | 3'), nl, printline,
	write(' 4 | 5 | 6'), nl, printline,
	write(' 7 | 8 | 9'), nl.
	/* muestra el cuadrado de juego */
	
printline :- write(' -----------'), nl.

/*definicion del juego a continuacion*/
juegos :- juego, !, continuarJugando.

continuarJugando :- nl, write('Deseas jugar otro  (s/n)? '),
	respuestaEntrada(Respuesta), !, proceder(Respuesta).
	
/* Las respuestas validas de entrada son: */
respuestaOk(s, si). respuestaOk('S', si). respuestaOk(s, si).
respuestaOk('SI', si). respuestaOk('Si', si).
respuestaOk(n, no). respuestaOk('N', no). respuestaOk(no, no).
respuestaOk('NO', no). respuestaOk('No', no).

proceder(no) :- !. /* fin del juego */
proceder(si) :- comenzar. /* continuar jugando */


/* El 3 argumento es el numero de posiciones libres que quedan, 9 en un comienzo */
juego :- nl, write('Deseas ser x or o? '), entradaJugador(Jugador), nl,
	write('Deseas ir primero (s/n)? '), respuestaEntrada(TurnoJugador),!,
	play(Jugador, TurnoJugador, 9, cuerpo(_,_,_,_,_,_,_,_,_)).
	

entradaJugador(Jugador) :- read(Jugador), x_or_o(Jugador). /* Chequeo de error */
entradaJugador(Jugador) :- write('No es una respuesta validad -- escribe x or o: '),
entradaJugador(Jugador). /* Reentrada de datos */

/*Chequeo de que el valor sea 'x' o 'o'*/
x_or_o(x). x_or_o(o).



respuestaEntrada(Respuesta) :- read(Pregunta), respuestaOk(Pregunta, Respuesta), !.
/* chequeo de error y confirmacion de respuesta */
respuestaEntrada(Respuesta) :- write('No es una respuesta valida -- escribe s o n: '),
respuestaEntrada(Respuesta). /* reinput */

/*Declaracion de las posibles jugadas ganadoras*/

seccion(1,2,3). seccion(4,5,6). seccion(7,8,9).
seccion(1,4,7). seccion(2,5,8). seccion(3,6,9).
seccion(1,5,9). seccion(7,5,3).

/*EL siguiente lo que hace es imprimir el contenido del juego, 
como va hasta el momento*/
imprimirGato(cuerpo(V1, V2, V3, V4, V5, V6, V7, V8, V9)) :-
	write(' '), imprimirValor(V1), write('|'), imprimirValor(V2), write('|'),
	imprimirValor(V3), nl, printline,
	write(' '), imprimirValor(V4), write('|'), imprimirValor(V5), write('|'),
	imprimirValor(V6), nl, printline,
	write(' '), imprimirValor(V7), write('|'), imprimirValor(V8), write('|'),
	imprimirValor(V9), nl, nl.

imprimirValor(V) :- var(V), !, write(' ').
imprimirValor(x) :- write(' x ').
imprimirValor(o) :- write(' o ').

/*Comienzo del juego*/

play(Jugador, TurnoJugador, CasillasAbiertas, Cuerpo) :-  
	unaMovida(Jugador, TurnoJugador, Cuerpo),   !,
	negar(TurnoJugador, NuevaTurnoJugador),
	Abierto is CasillasAbiertas - 1,
	siguienteJugada(Jugador, NuevaTurnoJugador, Abierto, Cuerpo).
	
negar(si, no). negar(no, si).
/*Esta funcion lo que hace es cambiar el turno de quien juega*/

opuesto(x,o). opuesto(o,x).

/* movimiento del humano */
unaMovida(Jugador, si, Cuerpo) :-  !, movidaEntrada(Cuerpo, Posicion), 
	hacerMovimiento(m(Posicion, Jugador), Cuerpo). 

/* movimiento del computador */

unaMovida(Jugador, no, Cuerpo) :- opuesto(Jugador, Contrincante), !, 
	movidaEntrada(Cuerpo, Posicion), 
	hacerMovimiento(m(Posicion, Contrincante), Cuerpo),
	write('Movida del segundo jugador: '), write(Posicion), nl,
	hacerMovimiento(m(Posicion, Contrincante), Cuerpo). 

movidaEntrada(Cuerpo, Posicion) :- nl, write('Selecciona tu movida: '), read(Posicion),
	ubicacion(Posicion), vectorPosicion(Posicion, Cuerpo, Val),
	var(Val). /* Debe estar disponible esta variable */
movidaEntrada(Cuerpo, Posicion) :- nl, write('No es una ubicacion valida.'),
movidaEntrada(Cuerpo, Posicion). /* reentrada de la  ubicacion si es que fue incorrecta*/

ubicacion(1). ubicacion(2). ubicacion(3). ubicacion(4). ubicacion(5).
ubicacion(6). ubicacion(7). ubicacion(8). ubicacion(9).

/*Declaracion de la funcion hacerMovimiento */
hacerMovimiento(m(Posicion, Val), Cuerpo) :- vectorPosicion(Posicion, Cuerpo, Val),
	imprimirGato(Cuerpo).


/*Declaracion de las posibles posiciones de juego, junto con la
posicion que llevarian asociadas a el vector de lugares y la 
correspondiente variable que asumira el valor de 'x' o 'o'*/
vectorPosicion(1, cuerpo(Val,_,_,_,_,_,_,_,_), Val) :- !.
vectorPosicion(2, cuerpo(_,Val,_,_,_,_,_,_,_), Val) :- !.
vectorPosicion(3, cuerpo(_,_,Val,_,_,_,_,_,_), Val) :- !.
vectorPosicion(4, cuerpo(_,_,_,Val,_,_,_,_,_), Val) :- !.
vectorPosicion(5, cuerpo(_,_,_,_,Val,_,_,_,_), Val) :- !.
vectorPosicion(6, cuerpo(_,_,_,_,_,Val,_,_,_), Val) :- !.
vectorPosicion(7, cuerpo(_,_,_,_,_,_,Val,_,_), Val) :- !.
vectorPosicion(8, cuerpo(_,_,_,_,_,_,_,Val,_), Val) :- !.
vectorPosicion(9, cuerpo(_,_,_,_,_,_,_,_,Val), Val).



/* chequea si es que hay ganador*/
siguienteJugada(Jugador,_,_, Cuerpo) :- victoria(Quien, Cuerpo), 
!, finVictorioso(Quien, Jugador).

/* chequea si es que hay empate*/
siguienteJugada(_, _, CasillasAbiertas, _) :- CasillasAbiertas < 1,
	write('El juego esta empatado.'), nl.
/*Si es que las casillas que quedan son < 1 quiere decir que nadie gano*/

/*si aun no hay ganador ni empate, se sigue jugando*/
siguienteJugada(Jugador, TurnoJugador, CasillasAbiertas, Cuerpo) :- 
	play(Jugador, TurnoJugador, CasillasAbiertas, Cuerpo).

/*Esta funcion revisa si es que gano algun jugador, recorre las posibles
victorias definidas en seccion, y si es valido, avisa que hay ganador*/
victoria(Quien, Cuerpo) :- seccion(Pos1, Pos2, Pos3), vectorPosicion(Pos1, Cuerpo, Val1),
	nonvar(Val1), Quien = Val1, /* "Quien" es un potencial ganador */
	vectorPosicion(Pos2, Cuerpo, Val2), nonvar(Val2), Val1 == Val2,
	vectorPosicion(Pos3, Cuerpo, Val3), nonvar(Val3), Val1 == Val3.


finVictorioso(Jugador, Jugador) :- !, write('Felicitaciones! has ganado'), nl.