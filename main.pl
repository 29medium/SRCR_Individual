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

ppArcoTodasSolucoes(L):- findall((S,C),(resolvePPArco(S,C)),L).

resolvePPArco([Nodo|Caminho],Custo):-
    inicio(Nodo),
    primeiroprofundidadeArco(Nodo,[Nodo],Caminho,Custo).

primeiroprofundidadeArco(Nodo, _, [], 0):-
    fim(Nodo).

primeiroprofundidadeArco(Nodo,Historico,[NodoProx|Caminho],Custo):-
    getArco(Nodo, NodoProx, _),
    nao(membro(NodoProx, Historico)),
    primeiroprofundidadeArco(NodoProx,[NodoProx|Historico],Caminho,Custo2),
    Custo is Custo2 + 1.

% Custos

ppCustoTodasSolucoes(L):- findall((S,C),(resolvePPCusto(S,C)),L).

resolvePPCusto([Nodo|Caminho],Custo):-
    inicio(Nodo),
    primeiroprofundidadeCusto(Nodo,[Nodo],Caminho,Custo).

primeiroprofundidadeCusto(Nodo, _, [], 0):-
    fim(Nodo).

primeiroprofundidadeCusto(Nodo,Historico,[NodoProx|Caminho],Custo):-
    getArco(Nodo, NodoProx, CustoMovimento),
    nao(membro(NodoProx, Historico)),
    primeiroprofundidadeCusto(NodoProx,[NodoProx|Historico],Caminho,Custo2),
    Custo is CustoMovimento + Custo2.

% Tipo de Lixo

resolveDPTiposAll(L,T):- findall((S,C), (resolveDPTipos(S, T)),L).

resolveDPTipos([Nodo|Caminho], Tipo):-
    inicio(Nodo),
    depthFirstT(Nodo,[Nodo],Caminho, Tipo).

depthFirstT(Nodo,_,[], Tipo):-
    fim(Nodo).

depthFirstT(Nodo, Historico, [NodoProx|Caminho], Tipo):-
    getLixo(NodoProx, Tipo),
    getArco(Nodo, NodoProx,_),
    nao(membro(NodoProx, Historico)),
    depthFirstT(NodoProx, [NodoProx|Historico], Caminho, Tipo).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% BREADTH-FIRST SEARCH
%--------------------------------- - - - - - - - - - -  -  -  -  -   -

% Arcos

bfsTotalArcos(L):- findall((S,C),(bfsArcos(S,C)),L).

bfsArcos(Cam,Arcos):-
    inicio(Orig),
    fim(Dest),
    bfsArcos2(Dest,[[Orig]],Cam,Arcos).
    
bfsArcos2(Dest,[[Dest|T]|_],Cam,0):-
    inverso([Dest|T],Cam).
    
bfsArcos2(Dest,[LA|Outros],Cam,Arcos):-
    LA=[Act|_],
    findall([X|LA],(Dest\==Act,getArco(Act,X,_),nao(membro(X,LA))),Novos),
    append(Outros,Novos,Todos),
    escrever(Todos),
    bfsArcos2(Dest,Todos,Cam,Arcos2),
    Arcos is 1 + Arcos2.

% Custos

bfsTotal(L):- findall((S,C),(bfs(S,C)),L).

bfs(Cam,Custo):-
    inicio(Orig),
    fim(Dest),
    bfs2(Dest,[[Orig/0]],Cam,Custo).
    
bfs2(Dest,[[Dest/C|T]|_],Cam,Custo):-
    inversoCusto([Dest/C|T],Cam,Custo).
    
bfs2(Dest,[LA|Outros],Cam,Custo):-
    LA=[Act/_|_],
    findall([X/CustoMovimento|LA],(Dest\==Act,getArco(Act,X,CustoMovimento),nao(membro(X/CustoMovimento,LA))),Novos),
    append(Outros,Novos,Todos),
    bfs2(Dest,Todos,Cam,Custo).

inversoCusto(Xs,Ys,Custo) :- inversoCusto(Xs,[],Ys,Custo).
inversoCusto([],Xs,Xs,0).
inversoCusto([X/C|Xs],Ys,Zs,Custo) :- 
    inversoCusto(Xs,[X|Ys],Zs,Custo2),
    Custo is Custo2 + C.

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% BUSCA ITERATIVA LIMITADA EM PROFUNDIDADE
%--------------------------------- - - - - - - - - - -  -  -  -  -   -

% Arcos

ppArcoTodasSolucoesLimit(Maxdepth,L):- findall((S,C),(resolvePPArcoLimit(S,C,Maxdepth)),L).

resolvePPArcoLimit([Nodo|Caminho],Custo,Maxdepth):-
    inicio(Nodo),
    primeiroprofundidadeArcoLimit(Nodo,[Nodo],Caminho,Custo,Maxdepth).

primeiroprofundidadeArcoLimit(Nodo, _, [], 0,_):-
    fim(Nodo).

primeiroprofundidadeArcoLimit(Nodo,Historico,[NodoProx|Caminho],Custo,Maxdepth):-
    Maxdepth > 0,   
    getArco(Nodo, NodoProx, _),
    nao(membro(NodoProx, Historico)),
    Max1 is Maxdepth - 1,
    primeiroprofundidadeArcoLimit(NodoProx,[NodoProx|Historico],Caminho,Custo2,Max1),
    Custo is Custo2 + 1.

% Custos

ppCustoTodasSolucoesLimit(Maxcusto, L):- findall((S,C),(resolvePPCustoLimit(S,C, Maxcusto)),L).

resolvePPCustoLimit([Nodo|Caminho],Custo, Maxcusto):-
    inicio(Nodo),
    primeiroprofundidadeCustoLimit(Nodo,[Nodo],Caminho,Custo, Maxcusto).

primeiroprofundidadeCustoLimit(Nodo, _, [], 0, _):-
    fim(Nodo).

primeiroprofundidadeCustoLimit(Nodo,Historico,[NodoProx|Caminho],Custo, Maxcusto):-
    getArco(Nodo, NodoProx, CustoMovimento),
    Max1 is Maxcusto - CustoMovimento,
    Max1 > 0,
    nao(membro(NodoProx, Historico)),
    primeiroprofundidadeCustoLimit(NodoProx,[NodoProx|Historico],Caminho,Custo2,Max1),
    Custo is CustoMovimento + Custo2.

% Tipos

resolveDPlimitadaTipo(Solucao,L, Tipo) :-
    inicio(No),
    depthFirstLimitedT([],No,Sol,L,Tipo),
    reverseL(Sol,Solucao).

depthFirstLimitedT(Caminho,No,[No|Caminho],L, Tipo) :-
    fim(No),!.

depthFirstLimitedT(Caminho,No,S,L,Tipo) :-
    L > 0,
    getLixo(No1, Tipo),
    getArco(No,No1,_),
    nao(membro(No1,Caminho)),
    L1 is L - 1,
    depthFirstLimitedT([No|Caminho],No1,S,L1,Tipo).

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
    getPonto(Nodo, _, _, _, _, Capacidade),
    agulosa([[Nodo]/0/Capacidade], CaminhoInverso/Custo/_),
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

adjacenteG([Nodo|Caminho]/Custo/_, [ProxNodo,Nodo|Caminho]/NovoCusto/Capacidade) :-
    getArco(Nodo, ProxNodo, PassoCusto),
    nao(member(ProxNodo, Caminho)),
	NovoCusto is Custo + PassoCusto,
	getPonto(Nodo, _, _, _, _, Capacidade).

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

minimo([(P,X)],(P,X)).
minimo([(P,X)|L],(Py,Y)):- minimo(L,(Py,Y)), X>Y.
minimo([(Px,X)|L],(Px,X)):- minimo(L,(Py,Y)), X=<Y.

seleciona(E, [E|Xs], Xs).
seleciona(E, [X|Xs], [X|Ys]) :- seleciona(E, Xs, Ys).

getArco(Origem, Destino, Custo) :- arco(Origem, Destino, Custo).

getPonto(Rua, Latitude, Longitude, Adjacentes, Lixo, Capacidade) :- ponto(Rua, Latitude, Longitude, Adjacentes, Lixo, Capacidade).

getLixo(Rua, Tipo) :- ponto(Rua,_,_,_,Lixo,_).

pontosL :- listing(ponto).

arcosL :- listing(arco).