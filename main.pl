:- style_check(-discontiguous).
:- style_check(-singleton).

:- set_prolog_flag(discontiguous_warnings,off).
:- set_prolog_flag(single_var_warnings,off).

:- op( 900,xfy,'::' ).
:- use_module(library(lists)).

:- include('pontos.pl').
:- include('arcos.pl').

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% DADOS
%--------------------------------- - - - - - - - - - -  -  -  -  -   -

inicio('R Moeda').
fim('R Ribeira Nova').

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% PROCURA NÃO INFORMADA
%--------------------------------- - - - - - - - - - -  -  -  -  -   -

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% DEPTH-FIRST SEARCH
%--------------------------------- - - - - - - - - - -  -  -  -  -   -

% Arcos

resolvePPArco([Nodo|Caminho],Custo):-
    inicio(Nodo),
    primeiroprofundidadeArco(Nodo,[Nodo],Caminho,Custo).

primeiroprofundidadeArco(Nodo, _, [], 0):-
    fim(Nodo).

primeiroprofundidadeArco(Nodo,Historico,[NodoProx|Caminho],Custo):-
    adjacenteArco(Nodo,NodoProx,CustoMovimento),
    nao(membro(NodoProx, Historico)),
    primeiroprofundidadeArco(NodoProx,[NodoProx|Historico],Caminho,Custo2),
    Custo is CustoMovimento + Custo2.

adjacenteArco(Nodo, NodoProx, 1):-
    getArco(Nodo, NodoProx, _).

ppArcoTodasSolucoes(L):- findall((S,C),(resolvePPArco(S,C)),L).

% Custos

resolvePPCusto([Nodo|Caminho],Custo):-
    inicio(Nodo),
    primeiroprofundidadeCusto(Nodo,[Nodo],Caminho,Custo).

primeiroprofundidadeCusto(Nodo, _, [], 0):-
    fim(Nodo).

primeiroprofundidadeCusto(Nodo,Historico,[NodoProx|Caminho],Custo):-
    adjacenteCusto(Nodo,NodoProx,CustoMovimento),
    nao(membro(NodoProx, Historico)),
    primeiroprofundidadeCusto(NodoProx,[NodoProx|Historico],Caminho,Custo2),
    Custo is CustoMovimento + Custo2.

adjacenteCusto(Nodo, NodoProx, Custo):-
    getArco(Nodo, NodoProx, Custo).

ppCustoTodasSolucoes(L):- findall((S,C),(resolvePPCusto(S,C)),L).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% BREADTH-FIRST SEARCH
%--------------------------------- - - - - - - - - - -  -  -  -  -   -

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% BUSCA ITERATIVA LIMITADA EM PROFUNDIDADE
%--------------------------------- - - - - - - - - - -  -  -  -  -   -

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% PROCURA INFORMADA
%--------------------------------- - - - - - - - - - -  -  -  -  -   -

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% A ESTRELA
%--------------------------------- - - - - - - - - - -  -  -  -  -   -

resolveAEstrela(Nodo, Caminho/Custo) :-
    estimativa(Nodo, Estimativa),
    aestrela([[Nodo]/0/Estima], CaminhoInverso/Custo/_),
    inverso(CaminhoInverso, Caminho).

aestrela(Caminhos, Caminho) :-
	obtem_melhor(Caminhos, Caminho),
	Caminho = [Nodo|_]/_/_,fim(Nodo).

aestrela(Caminhos, SolucaoCaminho) :-
    obtem_melhor(Caminhos, MelhorCaminho),
    seleciona(MelhorCaminho, Caminhos, OutrosCaminhos),
    expandeAEstrela(MelhorCaminho, ExpCaminhos),
    append(OutrosCaminhos, ExpCaminhos, NovoCaminhos),
    aestrela(NovoCaminhos, SolucaoCaminho).

obtem_melhor([Caminho], Caminho) :- !.

obtem_melhor([Caminho1/Custo1/Est1,_/Custo2/Est2|Caminhos], MelhorCaminho) :-
	Custo1 + Est1 =< Custo2 + Est2, !,
	obtem_melhor([Caminho1/Custo1/Est1|Caminhos], MelhorCaminho).
	
obtem_melhor([_|Caminhos], MelhorCaminho) :- 
	obtem_melhor(Caminhos, MelhorCaminho).
    
expandeAEstrela(Caminho, ExpCaminhos) :-
findall(NovoCaminho, adjacenteG(Caminho,NovoCaminho), ExpCaminhos). 

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% GULOSA
%--------------------------------- - - - - - - - - - -  -  -  -  -   -

resolveGulosa(Caminho/Custo) :-
    inicio(Nodo),
    estimativa(Nodo, Estimativa),
    agulosa([[Nodo]/0/Estimativa], CaminhoInverso/Custo/_),
    inverso(CaminhoInverso, Caminho).

agulosa(Caminhos, Caminho) :-
    obtem_melhor_g(Caminhos, Caminho),
    Caminho = [Nodo|_]/_/_,
    fim(Nodo).

agulosa(Caminhos, SolucaoCaminho) :-
    obtem_melhor_g(Caminhos, MelhorCaminho),
    seleciona(MelhorCaminho, Caminhos, OutrosCaminhos),
    expandeGulosa(MelhorCaminho, ExpCaminhos),
    append(OutrosCaminhos, ExpCaminhos, NovoCaminhos),
    agulosa(NovoCaminhos, SolucaoCaminho).

obtem_melhor_g([Caminho], Caminho) :- !.

obtem_melhor_g([Caminho1/Custo1/Est1,_/Custo2/Est2|Caminhos], MelhorCaminho) :-
	Est1 =< Est2, !,
	obtem_melhor_g([Caminho1/Custo1/Est1|Caminhos], MelhorCaminho).

obtem_melhor_g([_|Caminhos], MelhorCaminho) :- 
	obtem_melhor_g(Caminhos, MelhorCaminho).

expandeGulosa(Caminho, ExpCaminhos) :-
	findall(NovoCaminho, adjacenteG(Caminho,NovoCaminho), ExpCaminhos).

adjacenteG([Nodo|Caminho]/Custo/_, [ProxNodo,Nodo|Caminho]/NovoCusto/Est) :-
    getArco(Nodo, ProxNodo, PassoCusto)
    \+ member(ProxNodo, Caminho),
	NovoCusto is Custo + PassoCusto,
	estimativa(ProxNodo, Est).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% PREDICADOS AUXILIARES
%--------------------------------- - - - - - - - - - -  -  -  -  -   -

membro(X, [X|_]).
membro(X, [_|Xs]):-
	membro(X, Xs).

membros([X|Xs],Members) :- membro(X,Members),
                           membros(Xs,Members).

inverso(Xs,Ys) :- inicial(Xs,[],Ys).

inverso([],Xs,Xs).
inverso([X|Xs],Ys,Zs) :- inverso(Xs,[X|Ys],Zs).

nao( Questao ) :-
    Questao, !, fail.
nao( Questao ).

escrever([]).
escrever([X|L]) :- write(X),nl,escrever(L).

minimo([(P,X)],(P,X)).
minimo([(P,X)|L],(Py,Y)):- minimo(L,(Py,Y)), X>Y.
minimo([(Px,X)|L],(Px,X)):- minimo(L,(Py,Y)), X=<Y.

seleciona(E, [E|Xs], Xs).
seleciona(E, [X|Xs], [X|Ys]) :- seleciona(E, Xs, Ys).

getArco(Origem, Destino, Custo) :- arco(Origem, Destino, Custo).

pontosL :- listing(ponto).

arcosL :- listing(arco).