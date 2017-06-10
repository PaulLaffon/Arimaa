:- module(bot,
      [  get_moves/3
      ]).
      
%Regarde si un element fait parti de la liste	
element(X, [X|_]) :- !.
element(X, [_|Q]) :- element(X,Q).

% Element avec l'indice de l'élément, commençant par 1
element(X, [X|_], 1).
element(X, [_|Q], N) :- element(X, Q, M), N is M + 1.

% Peut s'unifier plusieur fois si l'élément est présent plusieur fois dans le tableau
all_element(X, [X|_]).
all_element(X, [_|Q]) :- all_element(X,Q).

%Concatene deux liste dans une troisieme
concat([],L,L).
concat([T|Q],L,[T|R]):- concat(Q,L,R).

%indique si une case n'est pas vide 
est_pas_vide([X,Y],Board):-element([X,Y,_,_],Board).
est_vide(X, Y, Board) :- not(element([X, Y, _, _], Board)).

% Maximum entre 2 valeurs
max(A, B, A) :- A >= B, !.
max(A, B, B) :- B >= A, !.

% Retourne le Maximum d'une liste d'entier
max_list([T|Q], Max) :- max_list(Q, T, Max).

max_list([], Max, Max).
max_list([T|Q], Max0, Max) :- max(T, Max0, M), max_list(Q, M, Max).

% Minimum entre 2 valeurs
min(A, B, A) :- A =< B, !.
min(A, B, B) :- B =< A, !.

% Retourne le Maximum d'une liste d'entier
min_list([T|Q], Min) :- min_list(Q, T, Min).

min_list([], Min, Min).
min_list([T|Q], Min0, Min) :- min(T, Min0, M), min_list(Q, M, Min).

somme([], 0).
somme([T|Q], Somme) :- somme(Q, S), Somme is S + T.

%indique la force d'une piece
force([_,_,rabbit,_],0).
force([_,_,cat,_],1).
force([_,_,dog,_],2).
force([_,_,horse,_],3).
force([_,_,camel,_],4).
force([_,_,elephant,_],5).

% Position des pièges
is_trap(2, 2).
is_trap(2, 5).
is_trap(5, 2).
is_trap(5, 5).

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
get_moves(Moves, [Side|_], Board) :- best_deplacement(Moves, 4, Side, Board).


% Retourne les endroits ou une piece a le droit d'aller en 1 case, Xsuiv et Ysuiv sont les valeurs de retour
% ex : possibilite_deplacement([0, 1, camel, silver], X, Y, 3, Chemin, Board(à renseigner), NouveauBoard) => tout les deplacement à 3 cases maximum
% Le retour se fait sur les variables Xsuiv, Ysuiv, Chemin et NouveauBoard
possibilite_deplacement([X, Y, Type, Couleur], Xsuiv, Ysuiv, N, [[[X, Y], [Xsuiv, Ysuiv]]], Board, NouveauBoard) :- N > 0,
                                                                  deplacement_une_case([X, Y, Type, Couleur], Xsuiv, Ysuiv, Board, NouveauBoard),
                                                                  not(piece_morte([Xsuiv, Ysuiv, Type, Couleur], NouveauBoard)).

possibilite_deplacement([X, Y, Type, Couleur], W, Z, N, [[[X, Y], [Xsuiv, Ysuiv]]|Chemin], Board, NouveauBoard) :- N > 1,   
                                                            deplacement_une_case([X, Y, Type, Couleur], Xsuiv, Ysuiv, Board, BoardSuiv),
                                                            not(piece_morte([Xsuiv, Ysuiv, Type, Couleur], BoardSuiv)), 
                                                            possibilite_deplacement([Xsuiv, Ysuiv, Type, Couleur], W, Z, N - 1, Chemin, BoardSuiv, NouveauBoard).

% Quand on veut faire une autre action après pousser
possibilite_deplacement([X, Y, Type, Couleur], W, Z, N, Chemin, Board, NouveauBoard) :- N > 2,
                                                                  pousser([X, Y, Type, Couleur], Xsec, Ysec, Mouvements, Board, BoardSuiv),
                                                                  not(piece_morte([Xsec, Ysec, Type, Couleur], BoardSuiv)),
                                                                  possibilite_deplacement([Xsec, Ysec, Type, Couleur], W, Z, N - 2, FinChemin, BoardSuiv, NouveauBoard),
                                                                  append(Mouvements, FinChemin, Chemin).

% Lorsque pousser est la dernière action qu'on fait'
possibilite_deplacement([X, Y, Type, Couleur], Xsuiv, Ysuiv, N, Chemin, Board, NouveauBoard) :- N > 1,
                                                                  pousser([X, Y, Type, Couleur], Xsuiv, Ysuiv, Chemin, Board, NouveauBoard), 
                                                                  not(piece_morte([Xsuiv, Ysuiv, Type, Couleur], NouveauBoard)).

possibilite_deplacement([X, Y, Type, Couleur], W, Z, N, Chemin, Board, NouveauBoard) :- N > 2,
                                                                  tirer([X, Y, Type, Couleur], Xsuiv, Ysuiv, Mouvements, Board, BoardSuiv),
                                                                  not(piece_morte([Xsuiv, Ysuiv, Type, Couleur], BoardSuiv)),
                                                                  possibilite_deplacement([Xsuiv, Ysuiv, Type, Couleur], W, Z, N - 2, FinChemin, BoardSuiv, NouveauBoard),
                                                                  append(Mouvements, FinChemin, Chemin).

possibilite_deplacement([X, Y, Type, Couleur], Xsuiv, Ysuiv, N, Chemin, Board, NouveauBoard) :-  N > 1,
                                                                  tirer([X, Y, Type, Couleur], Xsuiv, Ysuiv, Chemin, Board, NouveauBoard),
                                                                  not(piece_morte([Xsuiv, Ysuiv, Type, Couleur], NouveauBoard)).

% Gère les possibilités de posser, est utilisé dans les possibilités de déplacement
pousser([X, Y, Type, Couleur], Xsec, Ysec, [[[Xsec, Ysec], [Xsuiv, Ysuiv]], [[X, Y], [Xsec, Ysec]]], Board, NouveauBoard) :- 
                                                                  piece_adjacente([X, Y, Type, Couleur], [Xsec, Ysec, T, C], Board),
                                                                  case_ennemi([X, Y, Type, Couleur], [Xsec, Ysec, T, C]),
                                                                  est_plus_fort([X, Y, Type, Couleur], [Xsec, Ysec, T, C]),
                                                                  pos_pousser([Xsec, Ysec, T, C], Xsuiv, Ysuiv),
                                                                  est_vide(Xsuiv, Ysuiv, Board),
                                                                  deplacement(Xsec, Ysec, Xsuiv, Ysuiv, Board, BoardTemp),
                                                                  deplacement(X, Y, Xsec, Ysec, BoardTemp, BoardTemp2),
                                                                  enlever_piece_morte(BoardTemp2, BoardTemp2, NouveauBoard).
                                                                  
% Renvoie les différentes position où on peut pousser un ennemi adjacent (On peut pousser dans tout les directions)
pos_pousser([X, Y, Type, Couleur], Xsuiv, Ysuiv) :- pos_adjacente([X, Y, Type, Couleur], Xsuiv, Ysuiv).

% Gère les possibilités de tirer une pièce, est utilisé dans les possibilités de déplacements
tirer([X, Y, Type, Couleur], Xsuiv, Ysuiv, [[[X, Y], [Xsuiv, Ysuiv]], [[Xsec, Ysec], [X, Y]]], Board, NouveauBoard) :-
                                                                  piece_adjacente([X, Y, Type, Couleur], [Xsec, Ysec, T, C], Board),
                                                                  case_ennemi([X, Y, Type, Couleur], [Xsec, Ysec, T, C]),
                                                                  est_plus_fort([X, Y, Type, Couleur], [Xsec, Ysec, T, C]),
                                                                  pos_adjacente([X, Y, Type, Couleur], Xsuiv, Ysuiv),
                                                                  est_vide(Xsuiv, Ysuiv, Board),
                                                                  deplacement(X, Y, Xsuiv, Ysuiv, Board, BoardTemp),
                                                                  deplacement(Xsec, Ysec, X, Y, BoardTemp, BoardTemp2),
                                                                  enlever_piece_morte(BoardTemp2, BoardTemp2, NouveauBoard).

% Indique si une piece est morte car elle se trouve sur un piege sans ami adjacent
piece_morte([X, Y, Type, Couleur], Board) :- is_trap(X, Y), not(ami_adjacent([X, Y, Type, Couleur], Board)).

% Enlever les possibles pièces ennemis qui deviennent morte lorsque l'on les pousse ou les tire
% ex : enlever_piece_morte(Board, Board, NouveauBoard) ==> retour sur NouveauBoard, on mets 2 fois le board car 1 sert à le parcourrir, l'autre à vérifier les pièces adjacentes
enlever_piece_morte(Board, [[X, Y, Type, Couleur]|Q], Q) :- is_trap(X, Y), not(ami_adjacent([X, Y, Type, Couleur], Board)), !.
enlever_piece_morte(_, [], []) :- !.
enlever_piece_morte(Board, [[X, Y, Type, Couleur]|Q], [[X, Y, Type, Couleur]|Q2]) :- enlever_piece_morte(Board, Q, Q2).

% Deplacement d'une piece d'une seule case dans le board, utilisé dans la fonction possibilite_deplacement
% ex : deplacement_une_case([1, 0, camel, silver], X, Y, Board(à renseigner), NouveauBoard) => retour sur Xsuiv, Ysuiv et NouveauBoard
deplacement_une_case([X, Y, Type, Couleur], Xsuiv, Ysuiv, Board, NouveauBoard) :- pos_adjacente([X, Y, Type, Couleur], Xsuiv, Ysuiv),
                                                                  not(is_freeze([X, Y, Type, Couleur], Board)),
                                                                  est_vide(Xsuiv, Ysuiv, Board),
                                                                  deplacement(X, Y, Xsuiv, Ysuiv, Board, BoardTemp),
                                                                  enlever_piece_morte(BoardTemp, BoardTemp, NouveauBoard).

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
piece_adjacente([X, Y, Type, Couleur], Case, Board) :- pos_adjacente([X, Y, Type, Couleur], Xsuiv, Ysuiv), get_case(Xsuiv, Ysuiv, Case, Board).

% Renvoie les positions adjacentes a une case qui sont sur le plateau
pos_adjacente([X, Y, Type, _], Xsuiv, Y) :- Type \= rabbit, dans_plateau(X - 1, Y), Xsuiv is X - 1.
pos_adjacente([X, Y, _, _], Xsuiv, Y) :- dans_plateau(X + 1, Y), Xsuiv is X + 1.
pos_adjacente([X, Y, _, _], X, Ysuiv) :- dans_plateau(X, Y - 1), Ysuiv is Y - 1.
pos_adjacente([X, Y, _, _], X, Ysuiv) :- dans_plateau(X, Y + 1), Ysuiv is Y + 1.

% Renvoie si la position se situe dans la plateau ou pas
dans_plateau(X, Y) :- X >= 0, Y >= 0, X < 8, Y < 8.

% Retourne la case correspondant a la position X, Y. Si aucune case n'est trouvé, renvoie false  
% ex : get_case(0, 0, Case, [[0,0,rabbit,silver],[0,1,rabbit,silver],[0,2,horse,silver],[0,3,rabbit,silver],[0,4,elephant,silver],[0,5,rabbit,silver],[0,6,rabbit,silver],[0,7,rabbit,silver],[1,0,camel,silver],[1,1,cat,silver],[1,2,rabbit,silver],[1,3,dog,silver],[1,4,rabbit,silver],[1,5,horse,silver],[1,6,dog,silver],[1,7,cat,silver],[2,7,rabbit,gold],[6,0,cat,gold],[6,1,horse,gold],[6,2,camel,gold],[6,3,elephant,gold],[6,4,rabbit,gold],[6,5,dog,gold],[6,6,rabbit,gold],[7,0,rabbit,gold],[7,1,rabbit,gold],[7,2,rabbit,gold],[7,3,cat,gold],[7,4,dog,gold],[7,5,rabbit,gold],[7,6,horse,gold],[7,7,rabbit,gold]])
get_case(X, Y, [X, Y, Piece, Couleur], Board) :- element([X, Y, Piece, Couleur], Board).

% Valeur des différentes pièces
valeur([_,_,rabbit,_], 10).
valeur([_,_,cat,_], 5).
valeur([_,_,dog,_], 7).
valeur([_,_,horse,_], 10).
valeur([_,_,camel,_], 50).
valeur([_,_,elephant,_], 100).

opposite_color(silver, gold).
opposite_color(gold, silver).

% Différence des force par rapport à une couleur
difference_des_forces([], _, 0) :- !.
difference_des_forces([[X, Y, Type, Couleur]|Q], Couleur, Somme) :- difference_des_forces(Q, Couleur, Temp), valeur([X, Y, Type, Couleur], V), Somme is Temp + V.
difference_des_forces([[X, Y, Type, C]|Q], Couleur, Somme) :- C \= Couleur, difference_des_forces(Q, Couleur, Temp), valeur([X, Y, Type, Couleur], V), Somme is Temp - V.

% Itère sur toutes les pièces d'une couleur qui sont freeze (Renvoie la pièce actuelle sur Piece)
piece_freeze(Couleur, Piece, Board) :- piece_allie(Couleur, Piece, Board), is_freeze(Piece, Board).

% Renvoie le nombre de pièce d'une couleur qui sont freeze
nombre_piece_freeze(Couleur, Board, Nombre) :- findall(Piece, piece_freeze(Couleur, Piece, Board), Liste), length(Liste, Nombre).

% Renvoie la différence entre le nombre de pièce freeze
difference_piece_freeze(Couleur, Board, Nombre) :- nombre_piece_freeze(Couleur, Board, N1), opposite_color(Couleur, Ennemi), nombre_piece_freeze(Ennemi, Board, N2), Nombre is N2 - N1.


% Distance du lapin d'une couleur le plus proche par rapport à la ligne de victoire
dist_proche_lapin(Couleur, Board, Dist) :- bagof(D, distance_lapin(Couleur, Board, D), Liste), min_list(Liste, Dist).

% Distance de chacun des lapin d'une couleur par rapport à la ligne de victoire
distance_lapin(Couleur, Board, D) :- piece_allie(Couleur, [X, Y, rabbit, Couleur], Board), distance_victoire([X, Y, rabbit, Couleur], D).

victoire(Couleur, Board, Score) :- dist_proche_lapin(Couleur, Board, Dist), Dist \= 0, Score is 0, !.
victoire(Couleur, Board, Score) :- dist_proche_lapin(Couleur, Board, Dist), Score is 1000000.

% Distance d'un lapin par rapport à la ligne ou il gagne
distance_victoire([X, _, rabbit, silver], Distance) :- Distance is 7 - X, !.
distance_victoire([X, _, rabbit, gold], X) :- !.

distance(X, Y, X2, Y2, Dist) :- abs(X - X2, R), abs(Y - Y2, R2), Dist is R + R2.

distance_min_piege([X, Y, Type, Couleur], Distance) :- bagof(D, distance_piege([X, Y, Type, Couleur], D), Liste), min_list(Liste, Distance).

distance_piege([X, Y, Type, Couleur], Distance) :- is_trap(X2, Y2), distance(X, Y, X2, Y2, Distance).

dist_piege(Couleur, Board, Distance) :- piece_allie(Couleur, [X, Y, Type, Couleur], Board), distance_min_piege([X, Y, Type, Couleur], D), D < 2, Distance is D + 2, Type \= elephant, !.
dist_piege(_, _, 0).

somme_dist_piege(Couleur, Board, Somme) :- bagof(D, dist_piege(Couleur, Board, D), Liste), somme(Liste, Somme).

%Renvoie une note qui evalue la situation du board. 
note(Board, Couleur, N) :-    opposite_color(Couleur, Ennemi),
                              difference_des_forces(Board, Couleur, D), 
                              difference_piece_freeze(Couleur, Board, F), 
                              dist_proche_lapin(Ennemi, Board, DistLapin), 
                              victoire(Couleur, Board, Score),
                              somme_dist_piege(Couleur, Board, Somme),
                              N is D + F + Score - DistLapin - Somme.

% Retourne toutes les piece d'une couleur
piece_allie(Couleur, [X, Y, Type, Couleur], Board) :- all_element([X, Y, Type, Couleur], Board).


% Effectuer une série de deplacement, utilisé pour construire le NouveauBoard dans best_deplacement, après avoir déjà trouver un déplacement
effectuer_deplacement([], Board, Board).
effectuer_deplacement([[[X, Y], [Xsuiv, Ysuiv]]|Q], Board, NouveauBoard) :-   deplacement(X, Y, Xsuiv, Ysuiv, Board, BoardTemp), 
                                                                              enlever_piece_morte(BoardTemp, BoardTemp, BoardTemp2),
                                                                              effectuer_deplacement(Q, BoardTemp2, NouveauBoard).

% Renvoie le meilleur déplacement à faire, appelé dans la fonction moves
% On prends d'abord le meilleur déplacement d'une seule pièce, et on continue à prendre le meilleur déplacement tant qu'il nous reste des déplacement à faire
best_deplacement([], 0, _, _) :- !.
best_deplacement(Deplacement, N, Couleur, Board) :- N > 0, bagof(Chemin, tout_deplacement(N, Couleur, Board, Chemin), ListeChemin),
                                                      bagof(Note, toute_note(N, Couleur, Board, Note), ListeNote),
                                                      max_list(ListeNote, Max), 
                                                      element(Max, ListeNote, Indice),
                                                      element(PortionDeplacement, ListeChemin, Indice),
                                                      length(PortionDeplacement, Longeur),
                                                      NouvelleLongeur is N - Longeur,
                                                      effectuer_deplacement(PortionDeplacement, Board, NouveauBoard), !,
                                                      best_deplacement(CheminSuiv, NouvelleLongeur, Couleur, NouveauBoard),
                                                      length(ListeNote, L1),
                                                      length(ListeChemin, L2),
                                                      writeln(L1), writeln(L2),
                                                      append(PortionDeplacement, CheminSuiv, Deplacement).

% Itère sur tous les déplacement possible de toutes les pièces, utilié par la fonction bagof pour générer une liste de tous les déplacement possible
tout_deplacement(N, Couleur, Board, Chemin) :- N > 0, piece_allie(Couleur, Piece, Board), possibilite_deplacement(Piece, _, _, N, Chemin, Board, _).

% Itère sur tous les NouveauBoard possible et calcule la note, utilié par la fonction bagof pour générer une liste de toutes les notes (même indice que dans tous_deplacement)
toute_note(N, Couleur, Board, Note) :- N > 0, piece_allie(Couleur, Piece, Board), possibilite_deplacement(Piece, _, _, N, _, Board, NouveauBoard), note(NouveauBoard, Couleur, Note).
