:- style_check(-discontiguous).
:- style_check(-singleton).

:- set_prolog_flag(discontiguous_warnings,off).
:- set_prolog_flag(single_var_warnings,off).

:- op( 900,xfy,'::' ).
:- use_module(library(lists)).

:- include('pontos.pl').
:- include('arcos.pl').

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

pontosL :- listing(ponto).

arcosL :- listing(arco).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% PROCURA NÃO INFORMADA
%--------------------------------- - - - - - - - - - -  -  -  -  -   -

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% DEPTH-FIRST SEARCH
%--------------------------------- - - - - - - - - - -  -  -  -  -   -

resolvedF(Solucao):-
	inicial(InicialEstado),
	resolvedF(InicialEstado, [InicialEstado], Solucao).

resolvedF(Estado,_,[]) :-
	final(Estado),!.

resolvedF(Estado, Historico, [Move|Solucao]):-
	transicao(Estado,Move,NovoEstado),
	nao(membro(NovoEstado,Historico)),
	resolvedF(NovoEstado,[NovoEstado|Historico],Solucao).

todos(L) :- findall((S,C), (resolvedF(S), length(S,C)), L).

melhor(S,Custo) :- findall((S,C), (resolvedF(S), length(S,C)), L), minimo(L,(S,Custo)).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% BREADTH-FIRST SEARCH
%--------------------------------- - - - - - - - - - -  -  -  -  -   -

resolve_bfs(NodeS,NodeD,Sol) :- breadthfirst([[NodeS]],NodeD,Sol).

breadthfirst([[Node|Path]|_],Node,[Node|Path]).

breadthfirst([Path|Path],NodeD,Sol) :- extend(Path,NewPaths),
                                       concat(Paths,NewPaths,Paths1),
                                       breadthfirst(Paths1,NodeD,Sol).

extend([Node|Path],NewPaths) :- findall([NewPaths,Node|Path],aresta(Node,NewNode),
                                \+member(NewNode,[Node|Path]),NewPaths).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% BUSCA ITERATIVA LIMITADA EM PROFUNDIDADE
%--------------------------------- - - - - - - - - - -  -  -  -  -   -

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% PROCURA INFORMADA
%--------------------------------- - - - - - - - - - -  -  -  -  -   -

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% A ESTRELA
%--------------------------------- - - - - - - - - - -  -  -  -  -   -

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% GULOSA
%--------------------------------- - - - - - - - - - -  -  -  -  -   -