
start_tournament(HumanPlayer, ComputerPlayer, NewBoard):-
    write("Starting new Tournament"),nl,
    print_current_status(HumanPlayer, ComputerPlayer, NewBoard).




print_current_status(HumanPlayer, ComputerPlayer, NewBoard):-
    [HumanColor, HumanTournamentPoint, HumanRoundPoint, HumanCapturePoint, HumanTotalMove] = HumanPlayer,
    [ComputerColor, ComputerTournamentPoint, ComputerRoundPoint, ComputerCapturePoint, ComputerTotalMove] = ComputerPlayer,
    write('Board:'),nl,
    print_board_with_index(NewBoard, 19),nl,
    write('Human:'),nl,
    write('HumanColor: '), write(HumanColor),nl,
    write('HumanCapturePoint: '), write(HumanCapturePoint),nl,
    write('HumanRoundPoint: '), write(HumanRoundPoint),nl,
    write('HumanTournamentPoint: '), write(HumanTournamentPoint),nl,nl,
    write('Computer: '),nl,
    write('ComputerColor: '), write(ComputerColor),nl,
    write('ComputerCapturePoint: '), write(ComputerCapturePoint),nl,
    write('ComputerRoundPoint: '), write(ComputerRoundPoint),nl,
    write('ComputerTournamentPoint: '), write(ComputerTournamentPoint),nl.


