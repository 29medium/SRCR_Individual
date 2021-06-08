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

inicio('Tv Ribeira Nova').
fim('Av 24 de Julho').

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% QUERIES
%--------------------------------- - - - - - - - - - -  -  -  -  -   -

% Querie 2
maisPontosRecolha(Tipo, L) :- dfsTipoTotal(R, Tipo), maximo(R,L).

% Querie 3
maisProdutividade(Tipo, L) :- dfsQuantidadeTotal(R, Tipo), maximo(R,L).

% Querie 4
circuitoMaisRapido(L) :- bfsCustoTotal(R), minimo(R,L).

% Querie 5
circuitoMaisEficiente(L) :- dfsArcosTotal(R), minimo(R, L).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% PROCURA NÃO INFORMADA
%--------------------------------- - - - - - - - - - -  -  -  -  -   -

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% DEPTH-FIRST SEARCH
%--------------------------------- - - - - - - - - - -  -  -  -  -   -

% Arcos

dfsArcosTotal(L):- findall((S,C),(dfsArcos(S,C)),L).

dfsArcos([Nodo|Caminho],Custo):-
    inicio(Nodo),
    dfsArcos2(Nodo,[Nodo],Caminho,Custo).

dfsArcos2(Nodo, _, [], 0):-
    fim(Nodo).

dfsArcos2(Nodo,Historico,[NodoProx|Caminho],Custo):-
    getArco(Nodo, NodoProx, _),
    nao(membro(NodoProx, Historico)),
    dfsArcos2(NodoProx,[NodoProx|Historico],Caminho,Custo2),
    Custo is Custo2 + 1.

% Custos

dfsCustoTotal(L):- findall((S,C),(dfsCusto(S,C)),L).

dfsCusto([Nodo|Caminho],Custo):-
    inicio(Nodo),
    dfsCusto2(Nodo,[Nodo],Caminho,Custo).

dfsCusto2(Nodo, _, [], 0):-
    fim(Nodo).

dfsCusto2(Nodo,Historico,[NodoProx|Caminho],Custo):-
    getArco(Nodo, NodoProx, CustoMovimento),
    nao(membro(NodoProx, Historico)),
    dfsCusto2(NodoProx,[NodoProx|Historico],Caminho,Custo2),
    Custo is CustoMovimento + Custo2.

% Tipo de Lixo

dfsTipoTotal(L,T):- findall((S,C), (dfsTipo(S, C, T)),L).

dfsTipo([Nodo|Caminho], Arcos, Tipo):-
    inicio(Nodo),
    dfsTipo2(Nodo,[Nodo],Caminho, Tipo, Arcos).

dfsTipo2(Nodo,_,[], Tipo, 0):-
    fim(Nodo).

dfsTipo2(Nodo, Historico, [NodoProx|Caminho], Tipo, Arcos):-
    getLixo(NodoProx, Tipo),
    getArco(Nodo, NodoProx,_),
    nao(membro(NodoProx, Historico)),
    dfsTipo2(NodoProx, [NodoProx|Historico], Caminho, Tipo, Arcos2),
    Arcos is Arcos2 + 1.

% Quantidade

dfsQuantidadeTotal(L, T):- findall((S,C),(dfsQuantidade(S,C,T)),L).

dfsQuantidade([Nodo|Caminho],Quantidade,Tipo):-
    inicio(Nodo),
    dfsQuantidade2(Nodo,[Nodo],Caminho,Quantidade,Tipo).

dfsQuantidade2(Nodo, _, [], 0,Tipo):-
    fim(Nodo).

dfsQuantidade2(Nodo,Historico,[NodoProx|Caminho],Quantidade, Tipo):-
    getLixo(NodoProx, Tipo),
    getArco(Nodo, NodoProx, CustoMovimento),
    getPonto(NodoProx, _, _, _, _, QuantidadeMovimento),
    nao(membro(NodoProx, Historico)),
    dfsQuantidade2(NodoProx,[NodoProx|Historico],Caminho,Quantidade2,Tipo),
    Quantidade is QuantidadeMovimento + Quantidade2.

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% BREADTH-FIRST SEARCH
%--------------------------------- - - - - - - - - - -  -  -  -  -   -

% Arcos

bfsArcosTotal(L):- findall((S,C),(bfsArcos(S,C)),L).

bfsArcos(Cam,Arcos):-
    inicio(Orig),
    fim(Dest),
    bfsArcos2(Dest,[[Orig]],Cam,Arcos).
    
bfsArcos2(Dest,[[Dest|T]|_],Cam,Arcos):-
    inversoArcos([Dest|T],Cam,Arcos2),
    Arcos is Arcos2 - 1.
    
bfsArcos2(Dest,[LA|Outros],Cam,Arcos):-
    LA=[Act|_],
    findall([X|LA],(Dest\==Act,getArco(Act,X,_),nao(membro(X,LA))),Novos),
    append(Outros,Novos,Todos),
    bfsArcos2(Dest,Todos,Cam,Arcos).

inversoArcos(Xs,Ys,Arcos) :- inversoArcos(Xs,[],Ys,Arcos).
inversoArcos([],Xs,Xs,0).
inversoArcos([X|Xs],Ys,Zs,Arcos) :- 
    inversoArcos(Xs,[X|Ys],Zs,Arcos2),
    Arcos is Arcos2 + 1.

% Custos

bfsCustoTotal(L):- findall((S,C),(bfsCusto(S,C)),L).

bfsCusto(Cam,Custo):-
    inicio(Orig),
    fim(Dest),
    bfsCusto2(Dest,[[Orig/0]],Cam,Custo).
    
bfsCusto2(Dest,[[Dest/C|T]|_],Cam,Custo):-
    inversoCusto([Dest/C|T],Cam,Custo).
    
bfsCusto2(Dest,[LA|Outros],Cam,Custo):-
    LA=[Act/_|_],
    findall([X/CustoMovimento|LA],(Dest\==Act,getArco(Act,X,CustoMovimento),nao(membro(X/CustoMovimento,LA))),Novos),
    append(Outros,Novos,Todos),
    bfsCusto2(Dest,Todos,Cam,Custo).

inversoCusto(Xs,Ys,Custo) :- inversoCusto(Xs,[],Ys,Custo).
inversoCusto([],Xs,Xs,0).
inversoCusto([X/C|Xs],Ys,Zs,Custo) :- 
    inversoCusto(Xs,[X|Ys],Zs,Custo2),
    Custo is Custo2 + C.

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% BUSCA ITERATIVA LIMITADA EM PROFUNDIDADE
%--------------------------------- - - - - - - - - - -  -  -  -  -   -

% Arcos

dfsArcosTotalLimit(Maxdepth,L):- findall((S,C),(dfsArcosLimit(S,C,Maxdepth)),L).

dfsArcosLimit([Nodo|Caminho],Custo,Maxdepth):-
    inicio(Nodo),
    dfsArcos2Limit(Nodo,[Nodo],Caminho,Custo,Maxdepth).

dfsArcos2Limit(Nodo, _, [], 0,_):-
    fim(Nodo).

dfsArcos2Limit(Nodo,Historico,[NodoProx|Caminho],Custo,Maxdepth):-
    Maxdepth > 0,   
    getArco(Nodo, NodoProx, _),
    nao(membro(NodoProx, Historico)),
    Max1 is Maxdepth - 1,
    dfsArcos2Limit(NodoProx,[NodoProx|Historico],Caminho,Custo2,Max1),
    Custo is Custo2 + 1.

% Custos

dfsCustoTotalLimit(Maxcusto, L):- findall((S,C),(dfsCustoLimit(S,C, Maxcusto)),L).

dfsCustoLimit([Nodo|Caminho],Custo, Maxcusto):-
    inicio(Nodo),
    dfsCusto2Limit(Nodo,[Nodo],Caminho,Custo, Maxcusto).

dfsCusto2Limit(Nodo, _, [], 0, _):-
    fim(Nodo).

dfsCusto2Limit(Nodo,Historico,[NodoProx|Caminho],Custo, Maxcusto):-
    getArco(Nodo, NodoProx, CustoMovimento),
    Max1 is Maxcusto - CustoMovimento,
    Max1 > 0,
    nao(membro(NodoProx, Historico)),
    dfsCusto2Limit(NodoProx,[NodoProx|Historico],Caminho,Custo2,Max1),
    Custo is CustoMovimento + Custo2.

% Tipos

dfsTipoTotalLimit(L,Max,T):- findall(S, (dfsTipoLimit(S, T, Max)),L).

dfsTipoLimit([Nodo|Caminho], Maxdepth, Tipo):-
    inicio(Nodo),
    dfsTipo2Limit(Nodo,[Nodo],Caminho, Tipo, Maxdepth).

dfsTipo2Limit(Nodo,_,[], Tipo, _):-
    fim(Nodo).

dfsTipo2Limit(Nodo, Historico, [NodoProx|Caminho], Tipo, Maxdepth):-
    Maxdepth > 0,
    getLixo(NodoProx, Tipo),
    getArco(Nodo, NodoProx,_),
    nao(membro(NodoProx, Historico)),
    Max1 is Maxdepth - 1,
    dfsTipo2Limit(NodoProx, [NodoProx|Historico], Caminho, Tipo, Max1).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% PROCURA INFORMADA
%--------------------------------- - - - - - - - - - -  -  -  -  -   -

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% A ESTRELA
%--------------------------------- - - - - - - - - - -  -  -  -  -   -

resolveAEstrela(Caminho/Custo) :-
    inicio(Nodo),
    getPonto(Nodo, _, _, _, _, Capacidade),
    aestrela([[Nodo]/0/Capacidade], CaminhoInverso/Custo/_),
    inverso(CaminhoInverso, Caminho).

aestrela(Caminhos, Caminho) :-
	obtem_melhor(Caminhos, Caminho),
	Caminho = [Nodo|_]/_/_,
    fim(Nodo).

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
    estimativa(Nodo, Est),
    agulosa([[Nodo]/0/Est], CaminhoInverso/Custo/_),
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
    getArco(Nodo, ProxNodo, PassoCusto),
    nao(member(ProxNodo, Caminho)),
	NovoCusto is Custo + PassoCusto,
    estimativa(ProxNodo, Est).

estimativa(Local,Est) :- 
    ponto(Local,Lat1,Lon1,_,_,_),
    fim(Destino),
    ponto(Destino,Lat2,Lon2,_,_,_),
    R is 6373.0,
    Dlon is Lon2 - Lon1,
    Dlat is Lat2 - Lat1,
    A is sin(Dlat / 2)**2 + cos(Lat1) * cos(Lat2) * sin(Dlon / 2)**2,
    C is 2 * atan2(sqrt(A), sqrt(1 - A)),
    Est is C * R.

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% PREDICADOS AUXILIARES
%--------------------------------- - - - - - - - - - -  -  -  -  -   -

membro(X, [X|_]).
membro(X, [_|Xs]):-
	membro(X, Xs).

membros([X|Xs],Members) :- membro(X,Members),
                           membros(Xs,Members).

inverso(Xs,Ys) :- inverso(Xs,[],Ys).
inverso([],Xs,Xs).
inverso([X|Xs],Ys,Zs) :- inverso(Xs,[X|Ys],Zs).

nao( Questao ) :-
    Questao, !, fail.
nao( Questao ).

escrever([]).
escrever([X|L]) :- write(X),nl,escrever(L).

minimo(L, (A,B)) :-
    seleciona((A,B), L, R),
    \+ (membro((A1,B1), R), B1 < B).

maximo(L, (A,B)) :-
    seleciona((A,B), L, R),
    \+ (membro((A1,B1), R), B1 > B).

seleciona(E, [E|Xs], Xs).
seleciona(E, [X|Xs], [X|Ys]) :- seleciona(E, Xs, Ys).

getArco(Origem, Destino, Custo) :- arco(Origem, Destino, Custo).

getPonto(Rua, Latitude, Longitude, Adjacentes, Lixo, Capacidade) :- ponto(Rua, Latitude, Longitude, Adjacentes, Lixo, Capacidade).

getLixo(Rua, Tipo) :- ponto(Rua,_,_,_,Lixo,_).

pontosL :- listing(ponto).

arcosL :- listing(arco).