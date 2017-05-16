:- module(bot,
      [  get_moves/3
      ]).
      
%Regarde si un element fait parti de la liste	
element(X, [X|Q]).
element(X, [T|Q]):- element (X,Q).

%Concatene deux liste dans une troisieme
concat([],L,L).
concat([T|Q],L,[T|R]):- concat(Q,L,R).

%indique si une case n'est pas vide 
est_pas_vide([X,Y],Board):-element([X,Y,_,_],Board).


%indique la force d'une piece
force([_,_,rabbit,_],0).
force([_,_,cat,_],1).
force([_,_,dog,_],2).
force([_,_,horse,_],3).
force([_,_,camel,_],4).
force([_,_,elephant,_],5).

%indique si deux pièces sont amies 
ami([_,_,_,X],[_,_,_,X]).


%Donne les quatres cases adjacentes de la piece
adjacent([X,Y,_,_],[X+1,Y],[X,Y+1]):- X=0,Y=0,!.
adjacent([X,Y,_,_],[X+1,Y],[X,Y-1]):- X=0,Y=8,!.
adjacent([X,Y,_,_],[X-1,Y],[X,Y+1]):- X=8,Y=0,!.
adjacent([X,Y,_,_],[X-1,Y],[X,Y-1]):- X=8,Y=8,!.
adjacent([X,Y,_,_],[X+1,Y],[X,Y+1],[X,Y-1]):- X=0,!.
adjacent([X,Y,_,_],[X-1,Y],[X,Y+1],[X,Y-1]):- X=8,!.
adjacent([X,Y,_,_],[X+1,Y],[X-1,Y],[X,Y+1]):- Y=0,!.
adjacent([X,Y,_,_],[X+1,Y],[X-1,Y],[X,Y-1]):- Y=8,!.
adjacent([X,Y,_,_],[X+1,Y],[X-1,Y],[X,Y+1],[X,Y-1]).
	
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

% Renvoie une liste des positions des cases adjacentes 
% ex : case_adjacente(1, 1, Cases) => Cases = [[0, 1], [1, 0], [2, 1], [1, 2]]
case_adjacente(X, Y, Cases) :- adjacent_bas(X, Y, C1), adjacent_haut(X, Y, C2), adjacent_droit(X, Y, C3), adjacent_gauche(X, Y, C4), append(C1, C2, R), append(R, C3, R2), append(R2, C4, Cases).

% Renvoie une liste vide si la case n'est pas dans le plateau ou une liste avec la postion adjacente si elle est dans le plateau
% ex : adjacent_gauche(1, 1, Cases) => Cases = [[0, 1]]
adjacent_gauche(X, Y, Cases) :- dans_plateau(X - 1, Y), Xsec is X - 1, append([Xsec], [Y], Temp), to_list(Temp, Cases).
adjacent_gauche(X, Y, []) :- not(dans_plateau(X - 1, Y)).

adjacent_droit(X, Y, Cases) :- dans_plateau(X + 1, Y), Xsec is X + 1, append([Xsec], [Y], Temp), to_list(Temp, Cases).
adjacent_droit(X, Y, []) :- not(dans_plateau(X + 1, Y)).

adjacent_haut(X, Y, Cases) :- dans_plateau(X, Y + 1), Ysec is Y + 1, append([X], [Ysec], Temp), to_list(Temp, Cases).
adjacent_haut(X, Y, []) :- not(dans_plateau(X, Y + 1)).

adjacent_bas(X, Y, Cases) :- dans_plateau(X, Y - 1), Ysec is Y - 1, append([X], [Ysec], Temp), to_list(Temp, Cases).
adjacent_bas(X, Y, []) :- not(dans_plateau(X, Y - 1)).

% Renvoie si la position se situe dans la plateau ou pas
dans_plateau(X, Y) :- X >= 0, Y >= 0, X < 8, Y < 8.

% Renvoie true si la case est occupée par une pièce amie/ennemie, sinon false.
% ex : is_amie(1, 1, silver, Board)
is_amie(X, Y, Couleur, Board) :- get_case(X, Y, Case, Board), case_amie(Couleur, Case).
is_ennemie(X, Y, Couleur, Board) :- get_case(X, Y, Case, Board), get_opposite_color(Couleur, Opposite), case_amie(Opposite, Case).

% Renvoie true si la case est libre sinon false  ex : is_free(1, 1, Board)
is_free(X, Y, Board) :- not(get_case(X, Y, _, Board)).

% Renvoie la couleur opposé d'une couleur
get_opposite_color(silver, gold).
get_opposite_color(gold, silver). 

% Retourne la case correspondant a la position X, Y. Si aucune case n'est trouvé, renvoie false  
% ex : get_case(0, 0, Case, [[0,0,rabbit,silver],[0,1,rabbit,silver],[0,2,horse,silver],[0,3,rabbit,silver],[0,4,elephant,silver],[0,5,rabbit,silver],[0,6,rabbit,silver],[0,7,rabbit,silver],[1,0,camel,silver],[1,1,cat,silver],[1,2,rabbit,silver],[1,3,dog,silver],[1,4,rabbit,silver],[1,5,horse,silver],[1,6,dog,silver],[1,7,cat,silver],[2,7,rabbit,gold],[6,0,cat,gold],[6,1,horse,gold],[6,2,camel,gold],[6,3,elephant,gold],[6,4,rabbit,gold],[6,5,dog,gold],[6,6,rabbit,gold],[7,0,rabbit,gold],[7,1,rabbit,gold],[7,2,rabbit,gold],[7,3,cat,gold],[7,4,dog,gold],[7,5,rabbit,gold],[7,6,horse,gold],[7,7,rabbit,gold]])
get_case(X, Y, Case, [Case|_]) :- get_X(Xsec, Case), get_Y(Ysec, Case), X == Xsec, Y == Ysec, !.
get_case(X, Y, Case, [_|SuiteCases]) :- get_case(X, Y, Case, SuiteCases).

% Savoir si une case est amie,   ex : case_amie(silver, [0,0,rabbit,silver])
case_amie(Couleur, Case) :- get_couleur(C, Case), C == Couleur.

% Récupère la position d'X et Y, la piece et la couleur dans la liste d'une case,   ex : get_X(X, [0,0,rabbit,silver])
get_X(X, Case) :- nth0(Case, 0, X).
get_Y(Y, Case) :- nth0(Case, 1, Y).
get_piece(Piece, Case) :- nth0(Case, 2, Piece).
get_couleur(Couleur, Case) :- nth0(Case, 3, Couleur).

% Permet de mettre une valeur sous forme de liste
to_list(X, [X]).