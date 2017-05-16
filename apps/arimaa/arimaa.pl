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
