:- module(bot,
      [  get_moves/3
      ]).
      
%Regarde si un element fait parti de la liste	
element(X, [X|_]) :- !.
element(X, [T|Q]) :- element(X,Q).

%Concatene deux liste dans une troisieme
concat([],L,L).
concat([T|Q],L,[T|R]):- concat(Q,L,R).

%indique si une case n'est pas vide 
est_pas_vide([X,Y],Board):-element([X,Y,_,_],Board).
est_vide(X, Y, Board) :- not(element([X, Y, _, _], Board)).


%indique la force d'une piece
force([_,_,rabbit,_],0).
force([_,_,cat,_],1).
force([_,_,dog,_],2).
force([_,_,horse,_],3).
force([_,_,camel,_],4).
force([_,_,elephant,_],5).

% Renvoie vrai si la piece sur la case1 est plus forte que sur la case2
est_plus_fort(Case1, Case2) :- force(Case1, F1), force(Case2, F2), F1 > F2.

%indique si deux pièces sont amies/ennemies
case_ennemi([_, _, _, X], [_, _, _, Y]) :- X \= Y.
case_ami([_,_,_,X],[_,_,_,X]).

	
% A few comments but all is explained in README of github

% get_moves signature
% get_moves(Moves, gamestate, board).

% Exemple of variable
% gamestate: [side, [captured pieces] ] (e.g. [silver, [ [0,1,rabbit,silver],[0,2,horse,silver] ]) 
% board: [[0,0,rabbit,silver],[0,1,rabbit,silver],[0,2,horse,silver],[0,3,rabbit,silver],[0,4,elephant,silver],[0,5,rabbit,silver],[0,6,rabbit,silver],[0,7,rabbit,silver],[1,0,camel,silver],[1,1,cat,silver],[1,2,rabbit,silver],[1,3,dog,silver],[1,4,rabbit,silver],[1,5,horse,silver],[1,6,dog,silver],[1,7,cat,silver],[2,7,rabbit,gold],[6,0,cat,gold],[6,1,horse,gold],[6,2,camel,gold],[6,3,elephant,gold],[6,4,rabbit,gold],[6,5,dog,gold],[6,6,rabbit,gold],[7,0,rabbit,gold],[7,1,rabbit,gold],[7,2,rabbit,gold],[7,3,cat,gold],[7,4,dog,gold],[7,5,rabbit,gold],[7,6,horse,gold],[7,7,rabbit,gold]]

% Call exemple:
% get_moves(Moves, [silver, []], [[0,0,rabbit,silver],[0,1,rabbit,silver],[0,2,horse,silver],[0,3,rabbit,silver],[0,4,elephant,silver],[0,5,rabbit,silver],[0,6,rabbit,silver],[0,7,rabbit,silver],[1,0,camel,silver],[1,1,cat,silver],[1,2,rabbit,silver],[1,3,dog,silver],[1,4,rabbit,silver],[1,5,horse,silver],[1,6,dog,silver],[1,7,cat,silver],[2,7,rabbit,gold],[6,0,cat,gold],[6,1,horse,gold],[6,2,camel,gold],[6,3,elephant,gold],[6,4,rabbit,gold],[6,5,dog,gold],[6,6,rabbit,gold],[7,0,rabbit,gold],[7,1,rabbit,gold],[7,2,rabbit,gold],[7,3,cat,gold],[7,4,dog,gold],[7,5,rabbit,gold],[7,6,horse,gold],[7,7,rabbit,gold]]).

% default call
get_moves([[[1,0],[2,0]],[[0,0],[1,0]],[[0,1],[0,0]],[[0,0],[0,1]]], Gamestate, Board).


% Retourne les endroits ou une piece a le droit d'aller en 1 case, Xsuiv et Ysuiv sont les valeurs de retour
% ex : possibilite_deplacement([0, 1, camel, silver], X, Y, 3, Chemin, Board(à renseigner), NouveauBoard) => tout les deplacement à 3 cases maximum
% Le retour se fait sur les variables Xsuiv, Ysuiv, Chemin et NouveauBoard
possibilite_deplacement([X, Y, Type, Couleur], Xsuiv, Ysuiv, N, [[[X, Y], [Xsuiv, Ysuiv]]], Board, NouveauBoard) :- N > 0,
                                                                  deplacement_une_case([X, Y, Type, Couleur], Xsuiv, Ysuiv, Board, NouveauBoard).

possibilite_deplacement([X, Y, Type, Couleur], W, Z, N, [[[X, Y], [Xsuiv, Ysuiv]]|Chemin], Board, NouveauBoard) :- N > 1,   
                                                            deplacement_une_case([X, Y, Type, Couleur], Xsuiv, Ysuiv, Board, BoardSuiv), 
                                                            possibilite_deplacement([Xsuiv, Ysuiv, Type, Couleur], W, Z, N - 1, Chemin, BoardSuiv, NouveauBoard).

% Quand on veut faire une autre action après pousser
possibilite_deplacement([X, Y, Type, Couleur], W, Z, N, Chemin, Board, NouveauBoard) :- N > 2,
                                                                  pousser([X, Y, Type, Couleur], Xsec, Ysec, Mouvements, Board, BoardSuiv),
                                                                  possibilite_deplacement([Xsec, Ysec, Type, Couleur], W, Z, N - 2, FinChemin, BoardSuiv, NouveauBoard),
                                                                  append(Mouvements, FinChemin, Chemin).

% Lorsque pousser est la dernière action qu'on fait'
possibilite_deplacement([X, Y, Type, Couleur], Xsuiv, Ysuiv, N, Chemin, Board, NouveauBoard) :- N > 1,
                                                                  pousser([X, Y, Type, Couleur], Xsuiv, Ysuiv, Chemin, Board, NouveauBoard).

possibilite_deplacement([X, Y, Type, Couleur], W, Z, N, Chemin, Board, NouveauBoard) :- N > 2,
                                                                  tirer([X, Y, Type, Couleur], Xsuiv, Ysuiv, Mouvements, Board, BoardSuiv),
                                                                  possibilite_deplacement([Xsuiv, Ysuiv, Type, Couleur], W, Z, N - 2, FinChemin, BoardSuiv, NouveauBoard),
                                                                  append(Mouvements, FinChemin, Chemin).

possibilite_deplacement([X, Y, Type, Couleur], Xsuiv, Ysuiv, N, Chemin, Board, NouveauBoard) :-  N > 1,
                                                                  tirer([X, Y, Type, Couleur], Xsuiv, Ysuiv, Chemin, Board, NouveauBoard).

% Gère les possibilités de posser, est utilisé dans les possibilités de déplacement
pousser([X, Y, Type, Couleur], Xsec, Ysec, [[[Xsec, Ysec], [Xsuiv, Ysuiv]], [[X, Y], [Xsec, Ysec]]], Board, NouveauBoard) :- 
                                                                  piece_adjacente([X, Y, Type, Couleur], [Xsec, Ysec, T, C], Board),
                                                                  case_ennemi([X, Y, Type, Couleur], [Xsec, Ysec, T, C]),
                                                                  est_plus_fort([X, Y, Type, Couleur], [Xsec, Ysec, T, C]),
                                                                  pos_pousser([Xsec, Ysec, T, C], Xsuiv, Ysuiv),
                                                                  est_vide(Xsuiv, Ysuiv, Board),
                                                                  deplacement(Xsec, Ysec, Xsuiv, Ysuiv, Board, BoardTemp),
                                                                  deplacement(X, Y, Xsec, Ysec, BoardTemp, NouveauBoard).
                                                                  
% Renvoie les différentes position où on peut pousser un ennemi adjacent (On peut pousser dans tout les directions)
pos_pousser([X, Y, _, _], Xsuiv, Ysuiv) :- pos_adjacente(X, Y, Xsuiv, Ysuiv).

% Gère les possibilités de tirer une pièce, est utilisé dans les possibilités de déplacements
tirer([X, Y, Type, Couleur], Xsuiv, Ysuiv, [[[X, Y], [Xsuiv, Ysuiv]], [[Xsec, Ysec], [X, Y]]], Board, NouveauBoard) :-
                                                                  piece_adjacente([X, Y, Type, Couleur], [Xsec, Ysec, T, C], Board),
                                                                  case_ennemi([X, Y, Type, Couleur], [Xsec, Ysec, T, C]),
                                                                  est_plus_fort([X, Y, Type, Couleur], [Xsec, Ysec, T, C]),
                                                                  pos_adjacente(X, Y, Xsuiv, Ysuiv),
                                                                  est_vide(Xsuiv, Ysuiv, Board),
                                                                  deplacement(X, Y, Xsuiv, Ysuiv, Board, BoardTemp),
                                                                  deplacement(Xsec, Ysec, X, Y, BoardTemp, NouveauBoard).

% Deplacement d'une piece d'une seule case dans le board, utilisé dans la fonction possibilite_deplacement
% ex : deplacement_une_case([1, 0, camel, silver], X, Y, Board(à renseigner), NouveauBoard) => retour sur Xsuiv, Ysuiv et NouveauBoard
deplacement_une_case([X, Y, Type, Couleur], Xsuiv, Ysuiv, Board, NouveauBoard) :- pos_adjacente(X, Y, Xsuiv, Ysuiv),
                                                                  not(is_freeze([X, Y, Piece, Couleur], Board)),
                                                                  est_vide(Xsuiv, Ysuiv, Board),
                                                                  deplacement(X, Y, Xsuiv, Ysuiv, Board, NouveauBoard).

% Déplace la piece en (X, Y) en (Xsuiv, Ysuiv) dans le board result, ne vérifie pas l'intégrité du nouveauBoard
% ex : deplacement(0, 0, 0, 1, ancienBoard, NouveauBoard) => la piece en (0, 0) passe en (0, 1)
deplacement(X, Y, Xsuiv, Ysuiv, [[X, Y, Piece, Couleur]|Q], [[Xsuiv, Ysuiv, Piece, Couleur]|Q]) :- !.
deplacement(X, Y, Xsuiv, Ysuiv, [T|Q], [T|Q2]) :- deplacement(X, Y, Xsuiv, Ysuiv, Q, Q2).

% Renvoie vrai si la piece sur la case est freeze (piece ennemie plus forte a côté)
is_freeze([X, Y, Type, Couleur], Board) :-      not(ami_adjacent([X, Y, Type, Couleur], Board)),
                                                piece_adjacente([X, Y, Type, Couleur], Case, Board),
                                                case_ennemi([X, Y, Type, Couleur], Case), 
                                                est_plus_fort(Case, [X, Y, Type, Couleur]), !.

% Renvoie vrai si une piece amie est adjacente
ami_adjacent([X, Y, Type, Couleur], Board) :-   piece_adjacente([X, Y, Type, Couleur], Case, Board),
                                                case_ami([X, Y, Type, Couleur], Case), !.

% Renvoie les différentes piece qui sont sur des cases adjacentes
piece_adjacente([X, Y, _, _], Case, Board) :- pos_adjacente(X, Y, Xsuiv, Ysuiv), get_case(Xsuiv, Ysuiv, Case, Board).

% Renvoie les positions adjacentes a une case qui sont sur le plateau
pos_adjacente(X, Y, Xsuiv, Y) :- dans_plateau(X - 1, Y), Xsuiv is X - 1.
pos_adjacente(X, Y, Xsuiv, Y) :- dans_plateau(X + 1, Y), Xsuiv is X + 1.
pos_adjacente(X, Y, X, Ysuiv) :- dans_plateau(X, Y - 1), Ysuiv is Y - 1.
pos_adjacente(X, Y, X, Ysuiv) :- dans_plateau(X, Y + 1), Ysuiv is Y + 1.

% Renvoie si la position se situe dans la plateau ou pas
dans_plateau(X, Y) :- X >= 0, Y >= 0, X < 8, Y < 8.

% Retourne la case correspondant a la position X, Y. Si aucune case n'est trouvé, renvoie false  
% ex : get_case(0, 0, Case, [[0,0,rabbit,silver],[0,1,rabbit,silver],[0,2,horse,silver],[0,3,rabbit,silver],[0,4,elephant,silver],[0,5,rabbit,silver],[0,6,rabbit,silver],[0,7,rabbit,silver],[1,0,camel,silver],[1,1,cat,silver],[1,2,rabbit,silver],[1,3,dog,silver],[1,4,rabbit,silver],[1,5,horse,silver],[1,6,dog,silver],[1,7,cat,silver],[2,7,rabbit,gold],[6,0,cat,gold],[6,1,horse,gold],[6,2,camel,gold],[6,3,elephant,gold],[6,4,rabbit,gold],[6,5,dog,gold],[6,6,rabbit,gold],[7,0,rabbit,gold],[7,1,rabbit,gold],[7,2,rabbit,gold],[7,3,cat,gold],[7,4,dog,gold],[7,5,rabbit,gold],[7,6,horse,gold],[7,7,rabbit,gold]])
get_case(X, Y, [X, Y, Piece, Couleur], Board) :- element([X, Y, Piece, Couleur], Board).