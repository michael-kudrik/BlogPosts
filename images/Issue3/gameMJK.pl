/*

Assignment: COMSC 230 Midterm #2 - Programming Part
Name: Michael Kudrik
Date Due: 11/22/2024
Professor: Dr. Omar Rivera Morales

Description:
This is a little adventure game.  There are three
entities: you, a treasure, and an ogre.  There are
six places: a valley, a path, a cliff, a fork, a maze,
and a mountaintop.  Your goal is to get the treasure
without being killed first.
*/

/*
First, text descriptions of all the places in
the game.
*/
description(valley, 'You are in a pleasant valley, with a trail ahead.').
description(path,  'You are on a path, with ravines on both sides.').
description(cliff, 'You are teetering on the edge of a cliff.').
description(fork, 'You are at a fork in the path (go right or left').
description(gate, 'You are at the gate. \n -Use unlock to unlock the gate \n -Use forward to enter').
description(maze(_),'You are in a maze of twisty trails, all alike.').
description(mountaintop,  'You are on the mountaintop.').
/*_________________________Added secret room_________________________*/
description(secret_room, 'You are in a secret room. There is a Book of Knowledge here... \n You see an mysterious gate to the right. \n To the left is where you came from').

/* _____Add temporary gate_____ */
description(gateTemp, 'You have unlocked the gate! You gaze upon a mountaintop.').

/* report prints the description of your current  location. */

report :-  at(you,X),
  description(X,Y),
  write(Y), nl.

  /*These connect predicates establish the map.
  The meaning of connect(X,Dir,Y) is that if you
  are at X and you move in direction Dir, you
  get to Y.  Recognized directions are
  forward, right and left.*/
  connect(valley,forward,path).
  connect(path,right,cliff).
  connect(path,left,cliff).
  connect(path,forward,fork).
  connect(fork,left,maze(0)).
  connect(fork,right,gate).
  /* ___ Add gate connections____ */
  connect(gate,forward,gateTemp).
  connect(gate,backward,fork).
  connect(mountaintop,backward,gate).
  connect(maze(0),left,maze(1)).
  connect(maze(0),right,maze(3)).
  connect(maze(1),left,maze(0)).
  connect(maze(1),right,maze(2)).
  connect(maze(2),left,fork).
  connect(maze(2),right,maze(0)).
  connect(maze(3),left,maze(0)).
  connect(maze(3),right,maze(3)).
  /* ____ Add secret room ____ */
  connect(maze(2),forward,secret_room).
  connect(secret_room,backward,maze(2)).
  connect(secret_room,right,gate).

  
  /* move(Dir) moves you in direction Dir, then
  prints the description of your new location. */

  move(Dir) :- at(you,Loc),
  connect(Loc,Dir,Next),
  retract(at(you,Loc)),
  assert(at(you,Next)),
  report,
  !.

  /* But if the argument was not a legal direction,
  print an error message and don't move.*/

move(_) :-  write('That is not a legal move.\n'),
report.


/*Shorthand for moves.*/
forward :- move(forward).
left :- move(left).
right :- move(right).
open :- move(open).
backward :- move(backward).


/*If you and the ogre are at the same place, it  kills you.*/
ogre :- at(ogre,Loc),
at(you,Loc),
write('An ogre sucks your brain out through\n'),
write('your eyesockets, and you die.\n'),
retract(at(you,Loc)),
assert(at(you,done)),
!.
/*But if you and the ogre are not in the same place, nothing happens.*/
ogre.

/*If you and the key are at the same place, you can pick up the key. */
key :- 
at(key,Loc),
at(you,Loc),
write('You are in a room with a key\n'),
!.
/*But if you and the key are not in the same place, nothing happens.*/
key.


/* ____ Book of Knowledge ____ */
book :- at(book,Loc),
at(you,Loc),
write('You are in a room with a Book of Knowledge\n'),
!.
book.


/* ____ Pick up function ____ */
pick_up :- 
at(you,Loc),
at(key,Loc),
write('You have picked up the key\n'),
retract(at(key,Loc)),
assert(at(key, inv)).

pick_up :- 
at(you,Loc),
at(book,Loc),
write('You have picked up the book of knowledge\n'),
retract(at(book,Loc)),
assert(at(book, inv)).


pick_up :-
  write('There is nothing to pick up here\n').

/* ____ Drop function ____ */
drop :-
at(you,Loc),
at(key,inv),
write('You have dropped the key\n'),
retract(at(key,inv)),
assert(at(key,Loc)).

drop :-
at(you,Loc),
at(book,inv),
write('You have dropped the book\n'),
retract(at(book,inv)),
assert(at(book,Loc)).

drop :-
  write('You have nothing to drop\n').


/* ____ Unlock function ____ */
unlock :-
at(you,gate),
at(key,inv),
\+ unlocked(gate),
write('You have unlocked the gate\n'),
assert(unlocked(gate)),
!.

unlock :-
  at(you,gate),
  \+ at(key,inv),
  \+ unlocked(gate),
  write('You need the key to unlock the gate\n'),
  !.

unlock :-
  at(you,gate),
  unlocked(gate),
  write('The gate is already unlocked\n'),
  !.


unlock :-
  write('There is nothing to unlock!\n'),
  !.
  

unlock.

/*gate function. */
gate:- at(you, gateTemp),
\+ at(key,inv),
unlocked(gate),
retract(at(you,gateTemp)),
assert(at(you,mountaintop)),
/* report and treasure were added to keep game from breaking */
report, 
treasure,
!.

gate:- at(you, gateTemp),
\+ unlocked(gate),
write('The gate is locked\n'),
retract(at(you,gateTemp)),
assert(at(you,gate)),
!.

gate:- at(you, gateTemp),
unlocked(gate),
at(key,inv),
write('You got smitten by lightening! \n'),
retract(at(you,gateTemp)),
assert(at(you,done)),
!.
/*But if you and the gate are not in the same place, nothing happens.*/
gate.

/*If you and the treasure are at the same place, you win.*/
treasure :- at(treasure,Loc),
at(you,Loc),
at(book,inv),
write('The book of knowledge has guided you to a treasure.\n'),
write('Congratulations, you win!\n'),
retract(at(you,Loc)),
assert(at(you,done)),
!.

treasure :-
at(treasure,Loc),
at(you,Loc),
\+ at(book,inv),
write('You are wandering aimlessly, you need the book of knowledge for guidance\n You may return by using backward\n'),
!.

/*But if you and the treasure are not in the same place, nothing happens.*/
treasure.

/* If you are at the cliff, you fall off and die. */
cliff :- at(you,cliff),
write('You fall off and die.\n'),
retract(at(you,cliff)),
assert(at(you,done)),
!.
/* But if you are not at the cliff nothing happens.*/
cliff.

/*Main loop.  Stop if player won or lost.*/
main :- at(you,done),
write('Thanks for playing.\n'),
!.

/*  Main loop.  Not done, so get a move from the user and make it.
Then run all our special behaviors. Then repeat. */
main :-
write('\n Next move -- '),
read(Move),
call(Move),
ogre,
treasure,
cliff,
key,
book,
gate,
main.

/*This is the starting point for the game.  We
assert the initial conditions, print an initial
report, then start the main loop.*/
go :- 
retractall(at(_,_)), /* clean up from previous runs */
retractall(unlocked(_)),
assert(at(you,valley)),
assert(at(ogre,maze(3))),
assert(at(key,maze(2))),
assert(at(book,secret_room)),

assert(at(treasure,mountaintop)),
write('This is an adventure game. \n'),
write('Legal moves are left, right, forward, backward, unlock, pick_up and drop.\n'),
write('End each move with a period.\n\n'),
report,
main.
