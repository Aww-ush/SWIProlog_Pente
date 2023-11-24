

:-include('coin').
:-include('board').
:-include('tournament').
% player contains color, tournamentPoints, RoundPoints, TotalMove

startgame() :-
   write("Welcome to the Game!"),
   nl,
   write("To pick first player starting coin toss"),
   nl,
   coin_toss(HumanColor, ComputerColor),
   get_empty_board(Board),
   start_tournament([HumanColor, 0, 0, 0, 0], [ComputerColor, 0, 0, 0, 0], Board).
   