:- include(albums).
:- include(similar).
:- include(tags).
:- include(tracks).
:- dynamic(gustos/1).
:- dynamic(dontLike/1).

gustos([]).
dontLike([]).

buscarTema(X):- ;(
    ->(
	(
	topTracks(Artist, Temas), member(X,Temas),write('Este tema es de: '),write(Artist),nl,fail
	),
	true
    ),
    buscarTemasArtist
).

buscarTemasArtist:- searchByArtist;searchByTags;searchByYear.

searchByArtist:- write('Desea buscar por Artista? (s/n) '),inputResponse(Response),
	->(
            (=(Response,yes),write('Ingrese el nombre del Artista: ')),
            (read(A),topTracks(A,L),member(_,L),write('De '),write(A),write(' tenemos las siguientes canciones: '),write(L),nl,
	       write('Tiene asociado los siguientes tags: '),tags(A,T),write(T),nl,!
            )
	).
searchByTags:- write('Desea buscar por Tags? (s/n) '),inputResponse(Response),
	->(
            (=(Response,yes),write('Ingrese el Tag que desea buscar: ')),
            (read(T),tag(T),!)
	).
	searchByYear:-write('Desea buscar por Fecha? (s/n) '),inputResponse(Response),
        ;(->( =(Response,yes),year ), true ).

year:- write('Ingrese un numero que indique el rango que permitira de busqueda: '), read(Range1),Range is (Range1 * 10000),nl,
	write('Ingrese el anio que desea buscar: '), read(Year1),nl, Year is (Year1 * 10000),
	Inf is (Year - Range), Sup is (Year + Range),write(Inf), write(Sup),
	albums(Artist, Disc, Date, IsoDate),(@<(IsoDate, Sup),@>=(IsoDate,Inf)),
	write('Artista: '),write(Artist),nl,
	write('Disco: '),write(Disc),nl,
	write('Fecha: '),write(Date),nl,nl,fail.

sm(X,Y,L):- similar(L),member(X,L),member(Y,L),\=(X,Y).

tag(X):- ->((tags(A,L),member(X,L),write(A),nl,fail),write('buscar alternativas?')).

tagsYear:- write('Ingrese el tag que desea buscar: '),read(Tag),nl,write('Ingrese el anio al que corresponde: '),read(Year),
	Sup is ((Year*10000)+10000),Inf is ((Year*10000)-10000),
	tags(Art,L),member(Tag,L),albums(Art,Disc, Date, Iso),(@=<(Iso,Sup),@>=(Iso,Inf)),
	write('Artista: '),write(Art),nl,
	write('Disco: '),write(Disc),nl,
	write('Fecha: '),write(Date),nl,nl,fail.
	
buscar(Artist):- similar(L), member(Artist,L),fail,!.

inputResponse(Response) :- read(Answer), okResponse(Answer, Response), !.
inputResponse(Response) :- write('No es respuesta validad. Esciba s o n: '),
inputResponse(Response). 

recomendMusic(Artist):- similar(X),member(Artist,X),length(X,Num),random(1,Num,Rand),nth(Rand,X,NewArtist),topTracks(NewArtist,List),!,
	length(List,Largo),random(1,Largo,NewNumber),nth(NewNumber,List,Track),
	write('Te recomiendo que escuches: '),write(Track),write(' de '),write(NewArtist),!.

okResponse(s, yes). okResponse('S', yes). okResponse(si, yes).
okResponse('SI', yes). okResponse('Si', yes).
okResponse(n, no). okResponse('N', no). okResponse(no, no).
okResponse('NO', no). okResponse('No', no).

option(X):- ==(X,1),showArtis,menu,!.
option(X):- ==(X,2),showTags,menu,!.
option(X):- ==(X,3),showAlbums,menu,!.
option(X):- ==(X,4),searchByArtist,menu,!.
option(X):- ==(X,5),showArtis,menu,!.
option(X):- ==(X,6),showArtis,menu,!.
option(X):- ==(X,7),showArtis,menu,!.
option(X):- ==(X,8),showArtis,menu,!.
option(X):- ==(X,9),showArtis,menu,!.
option(X):- ==(X,0),!.
option(_):- write('No es respuesta valida.').


inferirArtist(A):- gustos(G),last(G,U),reverse(G,G1),last(G1,P),tags(A,T),member(P,T),member(U,T),!,
    topTracks(A,C),length(C,Largo),Large is Largo+1,random(1,Large,Rand),nth(Rand,C,X),
    write('Te recomiendo que escuches: '),write(X), write(' de '), write(A).

inferenceArtist:- gustos(G),last(G,U),reverse(G,G1),last(G1,P),tags(A,T),(member(P,T);member(U,T)),dontLike(DL),\+member(A,DL),
    write(A).

clean:-retractall(gustos(_)),asserta(gustos([])),retractall(dontLike(_)),asserta(dontLike([])). 

pushLike:- read(Tag),gustos(G),append(G,[Tag],Gustos),retract(gustos(G)),asserta(gustos(Gustos)).
pushLike(Tag):- gustos(G),append(G,[Tag],Gustos),retract(gustos(G)),asserta(gustos(Gustos)).

play:- clean,write('Cuentame, que estilo de musica escuchas?: '),pushLike,inferirArtist(Artist),
    write('\nTe gusto mi recomendacion? s/n: '),inputResponse(Response),modifyKnow(Response,Artist),
    write('Ahora, permiteme mostrarte lo que tengo similar o del estilo que te gusta\n '),artistByTag,learning.

artistByTag:- ;((->((tags(A,T),gustos(G),member(L,G),member(L,T),write(A),write('\t'),fail),true)),true).

dynamicKnow:- pushLike,inferirArtist(Artist),write('\nTe gusto mi recomendacion? s/n: '),inputResponse(Response),modifyKnow(Response,Artist).

learning:- write('\n\nAlgun grupo que te guste de los que ves? : '),read(Artista),atom(Artista),!,tags(Artista,Tags),gustos(G),append(G,[Tags],NewTags),
    retract(gustos(G)),asserta(gustos(NewTags)),length(NewTags,L),Largo is L+1,random(1,Largo,Rand),nth(Rand,NewTags,_).
learning:- write('\nDebes ingresar los nombre con mayusculas entre comillas simples\n'),learning.

modifyKnow(Response,Artist):- ;(->( 
        =(Response,no),
        (dontLike(NG),append(NG,[Artist],List),retract(dontLike(NG)),asserta(dontLike(List))) 
    ),write('Que bien!, es lo que esperaba\n')).

showArtis:- ;(->((similar(L),member(X,L),write(X),nl,fail),true),menu).
showTags:- ;(->((tags(X,L),write(X),write(' tiene asociado los tags '),write(L),nl,fail),true),menu).
showAlbums:- ;(->((albums(A,D,F,_),write(D),write(' de '),write(A),write('. Lanzado en: '),write(F),nl,fail),true),menu).
showTracks:- ;(->((topTracks(A,L),write('De '), write(A),write(' tenemos los siguientes temas:'),write(L),nl,fail),true),menu).
menu:- write('\n\t Bienvenido a MusikLog'),nl,
	write('Seleccione alguna de las siguientes opciones'),nl,
	write('1.- Mostrar artistas disponibles \t\t\t 2.- Mostrar los tags disponibles'),nl,
	write('3.- Mostrar los discos diferentes que hay disponibles\t'),write(' 4.- Buscar por Artista'),nl,
	read(Op),!,option(Op),!.